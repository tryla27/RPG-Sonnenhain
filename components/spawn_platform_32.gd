extends RefCounted
# A 16 m wide shrine platform at 32 world pixels/metre, with a 5 m crystal.
const SOURCE := Rect2(253,162,896,839)
const SIZE := Vector2(512,480)
const OFFSET := Vector2(-256,-260)
static var texture:Texture2D

static func init_art()->void:
	if texture!=null:return
	var source:Texture2D=load("res://art/village/objects/spawnpunkt.png")
	var image:=source.get_image()
	if image.is_compressed():image.decompress()
	image=image.get_region(Rect2i(SOURCE))
	image.resize(512,480,Image.INTERPOLATE_NEAREST)
	image.convert(Image.FORMAT_RGBA8)
	var pixels:=image.get_data()
	for i in range(3,pixels.size(),4):pixels[i]=255 if pixels[i]>=230 else 0
	texture=ImageTexture.create_from_image(Image.create_from_data(512,480,false,Image.FORMAT_RGBA8,pixels))

static func bounds(center:Vector2)->Rect2:
	return Rect2(center+OFFSET,SIZE)

static func platform(c:CanvasItem,center:Vector2)->void:
	init_art()
	c.draw_texture_rect(texture,bounds(center),false)

static func core(c:CanvasItem,p:Vector2)->void:
	init_art()
	# The crystal and rune posts are also drawn in the depth-sorted foreground.
	# The walkable floor is never redrawn over a player standing in front.
	var center:=p+Vector2(0,16)
	c.draw_texture_rect_region(texture,Rect2(center+OFFSET,Vector2(512,280)),Rect2(0,0,512,280))

static func height_at(pos:Vector2,center:Vector2)->float:
	var local:=pos-center
	if not Rect2(-256,-104,512,324).has_point(local):return 0
	return 16.0 if local.y<160 else (8.0 if local.y<196 else 0.0)
