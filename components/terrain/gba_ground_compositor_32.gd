extends RefCounted
const Plan=preload("res://components/map0_ground_plan_32.gd")
const Catalog=preload("res://components/terrain/terrain_catalog_32.gd")
const Rules=preload("res://components/terrain/gba_transition_rules_32.gd")
const REVISION:=2

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
		if mask==255:continue
		for y in 32:
			for x in 32:
				var p:=Vector2i(x,y)
				if Rules.foreground_pixel(mask,p,cell):continue
				var background:=Rules.background_family(current,cell,p,families)
				var sample:=Catalog.pixel_coord(background,cell*32+p)
				output.set_pixelv(cell*32+p,source.get_pixelv(sample))
	return {"image":output,"transitions":transitions}
