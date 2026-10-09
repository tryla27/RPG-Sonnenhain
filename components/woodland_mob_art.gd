extends RefCounted
## Authored woodland sprites retain the same body throughout a combat cycle.
const Sprites=preload("res://components/golden_sprite_runtime.gd")
const Hero=preload("res://components/rpg_hero.gd")
const AttackVFX=preload("res://components/woodland_attack_vfx.gd")
const WolfAnimation=preload("res://components/wolf_animation.gd")
const PATHS=[
	"res://art/sprites/mobs/woodland_v2/forest_slime_8dir.png",
	"res://art/sprites/mobs/woodland_v2/flower_beetle_8dir.png",
	"res://art/sprites/mobs/woodland_v2/mushroom_8dir.png",
	"res://art/sprites/mobs/woodland_v2/moss_wolf_8dir.png",
]
const SIZES=[Vector2(96,96),Vector2(96,96),Vector2(96,96),Vector2(96,96)]
const SCALES=[.9,1.05,1.12,1.22]
const ANCHORS=[80.0,80.0,80.0,80.0]
const PALETTES=[Color("73cb88"),Color("e998b6"),Color("e3ad77"),Color("789983")]

static func pose(type:int,phase:float,attack:float,ability_id:String="")->Dictionary:
	var offset:=Vector2.ZERO
	var stretch:=Vector2.ONE
	var lunge:=0.0
	if attack>=0.0:
		# MobCombat.visual_progress maps normal windup to 0..0.4 and
		# the active hit phase to 0.4..0.55; keep the visual strike in it.
		var windup:=smoothstep(0.0,.4,attack)*(1.0-smoothstep(.4,.55,attack))
		var impact:=smoothstep(.4,.55,attack)*(1.0-smoothstep(.55,1.0,attack))
		lunge=(-3.0*windup+8.0*impact) if type in [0,3] else 0.0
		if type==0:
			stretch=Vector2(1.0+.16*windup-.10*impact,1.0-.13*windup+.10*impact)
		elif type==2:
			offset.y=-3.0*windup
		else:
			offset.y=-4.0*impact
		if type==3 and ability_id=="sprungbiss":
			lunge=0.0
			offset.y=-AttackVFX.leap_height(attack)
	elif absf(phase)>.0001:
		var bounce:=absf(sin(phase))
		offset.y=-bounce*([3.0,1.5,2.0,3.0][type])
		if type==0:stretch=Vector2(1.0+bounce*.09,1.0-bounce*.07)
		elif type==2:stretch=Vector2(1.0+sin(phase)*.025,1.0)
	return {"offset":offset,"stretch":stretch,"lunge":lunge}

static func paint(c:CanvasItem,foot:Vector2,type:int,look:Vector2,base:Color,phase:float,attack:float,scale_factor:float,stretch:Vector2,ability_id:String="",visual:Dictionary={})->bool:
	if type<0 or type>=PATHS.size() or Sprites.texture(PATHS[type])==null:return false
	var heading:=direction_index(look)
	var motion:=pose(type,phase,attack,ability_id)
	var animated_wolf:=type==3 and WolfAnimation.available(heading)
	if animated_wolf:
		# Joint poses already move the body. Keep only the real leap height.
		motion={"offset":Vector2(0,-AttackVFX.leap_height(attack)) if ability_id=="sprungbiss" else Vector2.ZERO,"stretch":Vector2.ONE,"lunge":0.0}
	var canvas_scale:=stretch*scale_factor
	c.draw_set_transform(foot,0,canvas_scale)
	# The ground contact stays fixed when the creature hops or lunges.
	var shadow_alpha:=1.0-smoothstep(.35,.9,float(visual["death"])) if animated_wolf and float(visual.get("death",-1.0))>=0.0 else 1.0
	c.draw_rect(Rect2(-22,0,44,6),Color("172a23",.18*shadow_alpha))
	c.draw_rect(Rect2(-17,-2,34,8),Color("172a23",.20*shadow_alpha))
	var offset:Vector2=motion["offset"]+look.normalized()*float(motion["lunge"])
	c.draw_set_transform(foot+offset*canvas_scale,0,canvas_scale*Vector2(motion["stretch"]))
	var tint:=Color.WHITE
	# Combat flash and fading corpses continue to use the caller's tint.
	var palette:Color=PALETTES[type]
	if base.v<palette.v*.85:tint=Color(base.v/palette.v,base.v/palette.v,base.v/palette.v)
	elif base.s<palette.s*.7:tint=Color(1.15,1.12,1.08)
	if animated_wolf:WolfAnimation.draw(c,heading,phase,attack,ability_id,visual,SCALES[type],tint)
	else:Sprites.draw_direction_strip(c,PATHS[type],Vector2.ZERO,heading,SIZES[type],ANCHORS[type],SCALES[type],tint)
	c.draw_set_transform(Vector2.ZERO)
	return true

static func direction_index(look:Vector2)->int:
	# Hero headings run S,SE,E,NE,N,NW,W,SW; authored mob strips run
	# S,SW,W,NW,N,NE,E,SE. Convert rather than mirroring the artwork.
	return posmod(-Hero.direction_index(look),8)
