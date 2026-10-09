extends SceneTree
## Import preparation for the ImageGen-authored material sheet, not procedural texture synthesis.
const OUT:="res://art/terrain/gba_v1/"
const SOURCE:=OUT+"source/production-materials.png"
const PATCH:=128

func _initialize()->void:call_deferred("build")

func reduced_palette(image:Image,color_count:int)->Array[Color]:
	var counts:Dictionary={}
	for y in image.get_height():
		for x in image.get_width():
			var c:=image.get_pixel(x,y)
			var k:=Vector3i(int(c.r*31),int(c.g*31),int(c.b*31))
			counts[k]=int(counts.get(k,0))+1
	var keys:Array=counts.keys()
	keys.sort_custom(func(a,b):return counts[a]>counts[b])
	var centers:Array[Vector3]=[Vector3(keys[0])/31.0]
	while centers.size()<color_count:
		var best:=Vector3.ZERO
		var score:=-1.0
		for k:Vector3i in keys:
			var p:=Vector3(k)/31.0
			var d:=INF
			for c:Vector3 in centers:d=minf(d,p.distance_squared_to(c))
			var weighted:=d*sqrt(float(counts[k]))
			if weighted>score:score=weighted;best=p
		centers.append(best)
	for _iteration in 5:
		var sums:Array[Vector3]=[]
		var weights:Array[float]=[]
		for _i in color_count:sums.append(Vector3.ZERO);weights.append(0.0)
		for k:Vector3i in keys:
			var p:=Vector3(k)/31.0
			var index:=0
			var nearest:=INF
			for i in centers.size():
				var d:=p.distance_squared_to(centers[i])
				if d<nearest:nearest=d;index=i
			var weight:=float(counts[k])
			sums[index]+=p*weight;weights[index]+=weight
		for i in color_count:
			if weights[i]>0:centers[i]=sums[i]/weights[i]
	var palette:Array[Color]=[]
	for p in centers:palette.append(Color(roundf(p.x*255)/255.0,roundf(p.y*255)/255.0,roundf(p.z*255)/255.0,1))
	return palette

func prepare_patch(patch:Image,color_count:int)->Image:
	patch.resize(PATCH,PATCH,Image.INTERPOLATE_NEAREST)
	patch.convert(Image.FORMAT_RGBA8)
	var palette:=reduced_palette(patch,color_count)
	for y in PATCH:
		for x in PATCH:
			var c:=patch.get_pixel(x,y)
			var p:=Vector3(c.r,c.g,c.b)
			var best:=palette[0]
			var nearest:=INF
			for shade in palette:
				var d:=p.distance_squared_to(Vector3(shade.r,shade.g,shade.b))
				if d<nearest:nearest=d;best=shade
			patch.set_pixel(x,y,best)
	# Pair exact opposite pixel boundaries. Preserve the texture's interior drawing.
	# These are 128px coherent patches; the sixteen 32px subtiles remain in spatial order.
	for y in PATCH:patch.set_pixel(PATCH-1,y,patch.get_pixel(0,y))
	for x in PATCH:patch.set_pixel(x,PATCH-1,patch.get_pixel(x,0))
	return patch

func build()->void:
	var source:=Image.load_from_file(SOURCE)
	assert(not source.is_empty())
	assert(source.get_width()%4==0 and source.get_height()%3==0)
	var width:=source.get_width()/4
	var height:=source.get_height()/3
	assert(width==height,"source must contain twelve equal square materials")
	var atlas:=Image.create(512,416,false,Image.FORMAT_RGBA8)
	var patches:=Image.create(512,384,false,Image.FORMAT_RGBA8)
	var foliage:=Image.create(512,256,false,Image.FORMAT_RGBA8)
	for row in 12:
		# The approved correction uses village cobbles, never purple wall-like blocks, at the arena rim.
		var source_row:=5 if row in [8,9,10] else row
		var patch:=prepare_patch(source.get_region(Rect2i(source_row%4*width+2,floori(source_row/4.0)*height+2,width-4,height-4)),6 if row in [0,1,2,3,4,11] else 8)
		patches.blit_rect(patch,Rect2i(0,0,PATCH,PATCH),Vector2i(row%4*PATCH,floori(row/4.0)*PATCH))
		for v in 16:
			atlas.blit_rect(patch,Rect2i(v%4*32,floori(v/4.0)*32,32,32),Vector2i(v*32,row*32))
		if row==2:
			# Extract only the existing bright copper leaf pixels; do not carry the brown soil under trees.
			for y in 128:
				for x in 128:
					var color:=patch.get_pixel(x,y)
					if color.v>0.6 and color.s>0.58 and color.r>color.g*1.22:
						var v:=x/32+(y/32)*4
						foliage.set_pixel(v*32+x%32,y%32,color)
	# Interlocking bands of the existing two authored stone materials, not a noisy blend.
	var mixed:=Image.create(128,128,false,Image.FORMAT_RGBA8)
	for y in 128:
		for x in 128:
			var brick:bool=(posmod(x,64)>=16 and posmod(x,64)<40) or (posmod(y,64)>=16 and posmod(y,64)<40)
			var v:=x/32+(y/32)*4
			mixed.set_pixel(x,y,atlas.get_pixel(v*32+x%32,(7 if brick else 5)*32+y%32))
	mixed=prepare_patch(mixed,8)
	for v in 16:atlas.blit_rect(mixed,Rect2i(v%4*32,floori(v/4.0)*32,32,32),Vector2i(v*32,12*32))
	assert(mixed.save_png(OUT+"mixed_crossing_128.png")==OK)
	assert(atlas.save_png(OUT+"ground_32.png")==OK)
	assert(patches.save_png(OUT+"material_patches_128.png")==OK)
	# Reuse the existing native flower drawings, with their original crisp alpha.
	var flowers:=Image.new()
	assert(flowers.load_svg_from_string(FileAccess.get_file_as_string("res://art/terrain/map0_overlays_32.svg"),1.0)==OK)
	flowers.convert(Image.FORMAT_RGBA8)
	foliage.blit_rect(flowers,Rect2i(0,0,512,32),Vector2i(0,32))
	assert(foliage.save_png(OUT+"foliage_32.png")==OK)
	print("GBA_GROUND_ASSETS_OK 12 ImageGen materials, 192 native tiles, 6 natural/8 stone colors, opaque, exact paired 128px boundaries")
	quit()
