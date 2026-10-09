extends RefCounted
## Pose frames are cosmetic; damage is exclusively driven by MobCombat.
const Sprites=preload("res://components/golden_sprite_runtime.gd")
const FRAME_COUNT:=24
const FRAME_SIZE:=Vector2(128,128)
const ANCHOR:=104.0
const DIRECTIONS=["south","south_west","west","north_west","north","north_east","east","south_east"]
const STRIDE_LENGTH:=84.0

static func path(direction:int)->String:
	return "res://art/sprites/mobs/wolf_v3/%s.png"%DIRECTIONS[posmod(direction,8)]

static func available(direction:int)->bool:
	return Sprites.texture(path(direction))!=null

static func frame(phase:float,attack:float,ability_id:String,visual:Dictionary)->int:
	var death:=float(visual.get("death",-1.0))
	if death>=0.0:return 22 if death<.28 else 23
	var hurt:=float(visual.get("hurt",0.0))
	if hurt>0.0:return 20 if hurt>.09 else 21
	if attack>=0.0:
		if ability_id=="sprungbiss":
			# Six distinct poses combine crouch, push, flight, landing and rise.
			if attack<.12:return 12
			if attack<.38:return 16
			if attack<.445:return 17
			if attack<.52:return 18
			if attack<.74:return 19
			if attack<.92:return 15
			return 0
		if attack<.28:return 12
		if attack<.4:return 13
		if attack<.55:return 14
		if attack<.86:return 15
		return 0
	if bool(visual.get("walking",absf(phase)>.0001)):
		return 4+posmod(floori(phase/TAU*8.0),8)
	return posmod(floori((float(visual.get("clock",0.0))+float(visual.get("seed",0.0)))*3.0),4)

static func advance_gait(phase:float,distance:float)->float:
	return fposmod(phase+maxf(0.0,distance)/STRIDE_LENGTH*TAU,TAU)

static func draw(c:CanvasItem,direction:int,phase:float,attack:float,ability_id:String,visual:Dictionary,scale_factor:float,tint:Color)->bool:
	if not available(direction):return false
	var index:=frame(phase,attack,ability_id,visual)
	var modulation:=tint
	var death:=float(visual.get("death",-1.0))
	if death>=0.0:modulation.a*=1.0-smoothstep(.35,.9,death)
	return Sprites.draw_animation_strip(c,path(direction),Vector2.ZERO,index,FRAME_COUNT,FRAME_SIZE,ANCHOR,scale_factor,modulation)
