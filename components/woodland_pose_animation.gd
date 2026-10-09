extends RefCounted
## Shared pose graph for the three early woodland creatures.
const Sprites=preload("res://components/golden_sprite_runtime.gd")
const Wolf=preload("res://components/wolf_animation.gd")
const NAMES=["forest_slime","flower_beetle","mushroom"]
const STRIDES=[52.0,64.0,56.0]
const FRAME_COUNT:=24
const FRAME_SIZE:=Vector2(128,128)
const ANCHOR:=104.0

static func path(type:int,direction:int)->String:
	return "res://art/sprites/mobs/woodland_v3/%s/%s.png"%[NAMES[type],Wolf.DIRECTIONS[posmod(direction,8)]]
static func available(type:int,direction:int)->bool:
	return type in [0,1,2] and Sprites.texture(path(type,direction))!=null
static func advance_gait(type:int,phase:float,distance:float)->float:
	return fposmod(phase+maxf(0.0,distance)/STRIDES[type]*TAU,TAU)
static func frame(phase:float,attack:float,visual:Dictionary)->int:
	var death:=float(visual.get("death",-1.0))
	if death>=0:return 22 if death<.28 else 23
	var hurt:=float(visual.get("hurt",0.0))
	if hurt>0:return 20 if hurt>.09 else 21
	if attack>=0:
		if attack<.4:return 12+clampi(floori(attack/.4*4),0,3)
		if attack<.55:return 16+clampi(floori((attack-.4)/.15*2),0,1)
		if attack<.75:return 18
		if attack<.92:return 19
		return 0
	if bool(visual.get("walking",absf(phase)>.0001)):return 4+posmod(floori(phase/TAU*8),8)
	return posmod(floori((float(visual.get("clock",0.0))+float(visual.get("seed",0.0)))*2.5),4)
static func lift(type:int,phase:float,attack:float,visual:Dictionary)->float:
	if type!=0 or attack>=0 or not bool(visual.get("walking",false)):return 0.0
	return sin(clampf((fposmod(phase,TAU)/TAU-.22)/.53,0,1)*PI)*6.0
static func draw(c:CanvasItem,type:int,direction:int,phase:float,attack:float,visual:Dictionary,scale_factor:float,tint:Color)->bool:
	if not available(type,direction):return false
	var modulation:=tint
	var death:=float(visual.get("death",-1.0))
	if death>=0:modulation.a*=1.0-smoothstep(.35,.9,death)
	return Sprites.draw_animation_strip(c,path(type,direction),Vector2.ZERO,frame(phase,attack,visual),FRAME_COUNT,FRAME_SIZE,ANCHOR,scale_factor,modulation)
