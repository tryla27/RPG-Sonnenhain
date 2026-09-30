extends SceneTree
## Compile generated material swatches into exact native 32px tiles.
const T=32
var atlas:Image
var materials:Image
var patches:Array[Image]=[]
func region_tile(kind:int,variant:int)->Image:
	return patches[kind].get_region(Rect2i((variant%4)*32,(variant/4)*32,32,32))
func edge_tile(kind:int,mask:int,variant:int)->Image:
	var im=region_tile(kind,variant)
	for x in 32:
		for y in 32:
			var alpha:float=1.0
			var ripple:int=posmod((x/3)*7+(y/3)*11,3)
			if not mask&8:alpha=minf(alpha,clampf((x-3-ripple)/4.0,0,1))
			if not mask&2:alpha=minf(alpha,clampf((28-x-ripple)/4.0,0,1))
			if not mask&1:alpha=minf(alpha,clampf((y-3-ripple)/4.0,0,1))
			if not mask&4:alpha=minf(alpha,clampf((28-y-ripple)/4.0,0,1))
			var col=im.get_pixel(x,y)
			col.a=alpha
			im.set_pixel(x,y,col)
	return im
func _initialize()->void:
	materials=Image.load_from_file("res://art/start32/materials-faithful.webp")
	for i in 6:
		var patch=materials.get_region(Rect2i((i%3)*512,(i/3)*512,512,512))
		patch.convert(Image.FORMAT_RGBA8)
		patch.resize(128,128,Image.INTERPOLATE_NEAREST)
		patches.append(patch)
	atlas=Image.create(768,384,false,Image.FORMAT_RGBA8)
	atlas.fill(Color.TRANSPARENT)
	# Grass, flowers, paving, dirt, wall and forest material have coherent 4x4 tile patches.
	for i in 6:
		var kind:int=[0,1,3,2,4,5][i]
		atlas.blit_rect(patches[kind],Rect2i(0,0,128,128),Vector2i(i*128,0))
	for mask in 16:
		for variant in 4:
			atlas.blit_rect(edge_tile(2,mask,variant*4+mask%4),Rect2i(0,0,32,32),Vector2i(mask*32,(4+variant)*32))
			atlas.blit_rect(edge_tile(3,mask,variant*4+mask%4),Rect2i(0,0,32,32),Vector2i(mask*32,(8+variant)*32))
	assert(atlas.save_webp("res://art/start32/terrain_32.webp")==OK)
	print("FAITHFUL_TERRAIN_ATLAS_OK 32px, native 4x4 material patches and blended road edges")
	quit()
