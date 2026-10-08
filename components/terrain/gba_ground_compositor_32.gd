extends RefCounted
const Plan=preload("res://components/map0_ground_plan_32.gd")
const Catalog=preload("res://components/terrain/terrain_catalog_32.gd")
const Rules=preload("res://components/terrain/gba_transition_rules_32.gd")
const REVISION:=3

static func crossing_family(world:Vector2i)->String:
	# Broad irregular joints follow the courtyard boundary, never a repeating plaid.
	# Quantized contours keep hard pixel edges and group stones into useful patches.
	var p:=Vector2(world)
	var q:=(p-Vector2(825,895)).abs()-Vector2(288,272)
	var distance:=maxf(q.x,q.y)
	var joint:=floorf((sin(p.x*0.039+p.y*0.013)*13.0+sin(p.y*0.047-p.x*0.019)*9.0+cos(p.x*0.017+p.y*0.029)*7.0)/4.0)*4.0
	return "plaza_stone" if distance<joint else "village_stone"

static func sample(source:Image,family:String,world:Vector2i)->Color:
	var material:=crossing_family(world) if family=="spawn_crossing" else family
	return source.get_pixelv(Catalog.pixel_coord(material,world))

static func compose(source:Image,families:Dictionary)->Dictionary:
	if source.is_compressed():source.decompress()
	source.convert(Image.FORMAT_RGBA8)
	var output:=Image.create(Plan.GRID.x*32,Plan.GRID.y*32,false,Image.FORMAT_RGBA8)
	var transitions:Dictionary={}
	for cell:Vector2i in families:
		var current:String=str(families[cell])
		var mask:=Rules.mask_for(current,cell,families)
		if mask!=255:transitions[cell]=mask
		var origin:Vector2i=Catalog.atlas_coord(current,Catalog.coherent_variant(cell))*32
		output.blit_rect(source,Rect2i(origin,Vector2i(32,32)),cell*32)
		if current=="spawn_crossing":
			for y in 32:
				for x in 32:
					var world:=cell*32+Vector2i(x,y)
					output.set_pixelv(world,sample(source,current,world))
		if mask==255:continue
		for y in 32:
			for x in 32:
				var p:=Vector2i(x,y)
				if Rules.foreground_pixel(mask,p,cell):continue
				var background:=Rules.background_family(current,cell,p,families)
				output.set_pixelv(cell*32+p,sample(source,background,cell*32+p))
	return {"image":output,"transitions":transitions}
