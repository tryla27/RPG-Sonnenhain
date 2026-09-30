extends RefCounted
## One procedural model family for selection, all maps and multiplayer.
const H = preload("res://components/reference_house.gd")

static func r(c: CanvasItem, x: float,y: float,w: float,h: float,color: String) -> void:
	H.box(c,Vector2.ZERO,Rect2(x,y,w,h),color)

static func paint(c: CanvasItem,p: Vector2,role: int,race: int,gender: int,look: Vector2,phase: float,s: float,offset: Vector2,roll: float=-1.0,roll_dir: Vector2=Vector2.RIGHT,armor: int=-1,death: float=-1.0) -> void:
	var female := gender == 1
	var back := look.y < -0.5
	var width := (17 if female else 20)+(3 if race == 1 else 0)
	var skin: String = ["d6a478","87a76a","aebbc1"][clampi(race,0,2)]
	var shade: String = ["a47758","537949","677985"][clampi(race,0,2)]
	var cloth: String = ["416579","544477","386454"][role]
	var trim: String = ["d9b964","c5a7e6","c1ac76"][role]
	if armor >= 0:
		cloth = ["95734e","536d86","674e8c","426b55","963f40","a7aeb0"][clampi(armor,0,5)]
		trim = ["cfb47c","d5c5a0","8fdedd","d2be79","e7c46b","86d8ed"][clampi(armor,0,5)]
	var hair: String = "ba7147" if female else "604737"
	var stride := int(sin(phase)*4)
	var rotation := 0.0
	var squash := Vector2.ONE
	# Race/class anatomy is shared by walking, equipment, rolling and death.
	squash.y = [1.0,0.94,1.08][clampi(race,0,2)]*(1.02 if female else 1.0)
	squash.x = 1.06 if role == 0 else (0.96 if role == 1 else 1.0)
	if roll >= 0 and role != 1:
		var direction := -1.0 if roll_dir.x < 0 else 1.0
		rotation = direction*TAU*roll
		squash.y *= 1.0-sin(roll*PI)*(0.18 if role==0 else 0.10)
		stride = int(sin(roll*TAU)*(3 if race == 1 else 5))
	elif roll >= 0:
		rotation = roll_dir.x*0.13*sin(roll*PI)
	if death >= 0:
		var fall := smoothstep(0.12,0.72,death)
		rotation = fall*(PI*0.46 if race != 2 else PI*0.40)*(1.0 if look.x >= 0 else -1.0)
		squash.y = 1.0-fall*0.15
		stride = 0
	var profile := absf(look.x) > absf(look.y)
	if profile:
		squash.x *= 0.72*(1.0 if look.x > 0 else -1.0)
	var scale := Vector2.ONE*s*squash
	var pivot := p+offset+Vector2(0,-10)*s
	if death >= 0: pivot.y += smoothstep(0.0,0.7,death)*19.0*s
	var origin := pivot-(Vector2(28,44)*scale).rotated(rotation)
	c.draw_set_transform(origin,rotation,scale)
	# Cloak/quiver behind the figure, never over the face.
	if role == 0:
		H.poly(c,Vector2.ZERO,[[10,29],[46,29],[49,66],[38,70],[9,64]],Color("753e43" if not female else "804752"))
	elif role == 1:
		H.poly(c,Vector2.ZERO,[[12,29],[44,29],[49,70],[33,74],[9,69]],Color("302e51"))
	else:
		H.poly(c,Vector2.ZERO,[[8,27],[18,23],[27,63],[16,67]],Color("674836"))
		for arrow in 3:
			r(c,9+arrow*4,17,2,18,"bdad86")
			r(c,7+arrow*4,16,5,5,"d4ddd1")
	# Walking legs: alternating knees and boots with a stable torso.
	for side in [-1,1]:
		var x: int = 28+side*9-5
		var step: int = stride*side
		r(c,x,59,10,11+step,"334450")
		r(c,x,68+step,10,9,"55433a")
		r(c,x-2,75+step,15,4,"8d7755")
		r(c,x+1,69+step,7,3,trim)
	# Distinct tailored silhouettes, waist straps and class equipment.
	H.poly(c,Vector2.ZERO,[[28-width,31],[28+width,31],[28+width-3,49],[28+width+1,61],[28-width-1,61],[28-width+3,49]],Color("253541"))
	H.poly(c,Vector2.ZERO,[[30-width,33],[26+width,33],[24+width,49],[27+width,59],[29-width,59],[32-width,49]],Color(cloth))
	r(c,14,55,28,5,"604733")
	r(c,25,55,7,5,trim)
	if role == 0:
		for side in [-1,1]:
			var x: int = 28+side*(width-4)-6
			H.poly(c,Vector2.ZERO,[[x,29],[x+12,29],[x+15,36],[x+11,41],[x-3,39]],Color("445565"))
			r(c,x,31,12,4,"b6c9c8")
			r(c,x+2,35,9,3,trim)
		H.poly(c,Vector2.ZERO,[[18,37],[38,37],[36,50],[28,54],[20,50]],Color("82999d"))
		r(c,20,38,15,3,"c8d7ca")
		H.poly(c,Vector2.ZERO,[[28,41],[33,45],[28,50],[23,45]],Color(trim))
	elif role == 1:
		for y in [36,43,50]: r(c,27,y,3,3,trim)
		H.poly(c,Vector2.ZERO,[[10,32],[19,35],[24,49],[19,55],[8,49]],Color("75618e"))
		r(c,13,41,7,3,"ead5a7")
		r(c,36,50,7,10,"b89e73")
		r(c,38,52,4,5,"80dad6")
	else:
		H.poly(c,Vector2.ZERO,[[12,34],[18,31],[44,55],[40,59]],Color("aa8456"))
		r(c,34,50,8,12,"76583b")
		r(c,36,51,5,3,trim)
		H.poly(c,Vector2.ZERO,[[24,37],[30,32],[35,40],[29,46]],Color("91ad70"))
	# Hands stay below the head, including during walking and tumbling.
	if armor >= 0:
		# Equipment follows the same body transform in every direction and animation.
		r(c,16,35,24,18,cloth)
		r(c,17,36,22,3,trim)
		r(c,26,39,4,15,trim)
		if armor in [1,4,5]:
			for side in [-1,1]:
				r(c,28+side*17-5,29,10,10,cloth)
				r(c,28+side*17-5,30,10,3,trim)
		if armor in [2,3]:
			for y in [43,48,53]: r(c,19,y,3,3,trim)
	for side in [-1,1]:
		var x: int = 28+side*(width+2)-4
		r(c,x,37-stride*side/2,8,16,cloth)
		r(c,x,50-stride*side/2,8,4,trim)
		r(c,x+1,54-stride*side/2,6,5,skin)
	# Race-specific head construction.
	var head_width := 14 if race != 1 else 17
	H.poly(c,Vector2.ZERO,[[28-head_width,11],[28+head_width,11],[28+head_width,25],[36,32],[20,32],[28-head_width,25]],Color(shade))
	r(c,30-head_width,12,head_width*2-4,15,skin)
	if race == 2:
		H.poly(c,Vector2.ZERO,[[14,12],[20,6],[37,6],[43,12],[40,30],[17,30]],Color("627c8c"))
		r(c,18,10,21,5,"cad1c4")
		if not back:
			r(c,18,18,21,7,"25384c")
			r(c,20,20,7,3,"8cece0")
			r(c,30,20,7,3,"8cece0")
			r(c,24,27,10,2,"d7b979")
		if female:
			H.poly(c,Vector2.ZERO,[[11,14],[5,5],[16,8],[19,14]],Color("d1ae73"))
			H.poly(c,Vector2.ZERO,[[42,14],[50,5],[39,8],[36,14]],Color("d1ae73"))
		else:
			r(c,15,4,5,10,"b2c1c3")
			r(c,38,4,5,10,"b2c1c3")
			r(c,15,2,5,3,"9be8ed")
			r(c,38,2,5,3,"9be8ed")
		if back: r(c,20,18,17,8,"384d60")
	else:
		r(c,28-head_width,8,head_width*2,7,hair if race==0 else "34493b")
		if female:
			for braid in 5:
				r(c,12,20+braid*5,5,5,hair if race==0 else "384d3c")
				r(c,13,22+braid*5,2,3,"e0ad69" if braid==4 else ("d08a4f" if race==0 else "7d9358"))
		else:
			if race == 0 and not back:
				H.poly(c,Vector2.ZERO,[[18,25],[23,27],[33,27],[38,25],[33,34],[23,34]],Color("76503b"))
		if back:
			r(c,28-head_width,13,head_width*2,17,hair if race==0 else "34493b")
		else:
			var dx := 3 if look.x > 0.5 else (-3 if look.x < -0.5 else 0)
			if profile:
				r(c,34,19,4,4,"283137")
				r(c,35,19,2,2,"eee3be" if race==0 else "ecce6d")
				r(c,40,22,5,4,skin)
			else:
				r(c,19+dx,19,4,4,"283137")
				r(c,32+dx,19,4,4,"283137")
				r(c,20+dx,19,2,2,"eee3be" if race==0 else "ecce6d")
				r(c,33+dx,19,2,2,"eee3be" if race==0 else "ecce6d")
				r(c,26+dx,23,5,3,shade)
			if race == 1:
				H.poly(c,Vector2.ZERO,[[16,27],[20,20],[23,29]],Color("efe5bd"))
				H.poly(c,Vector2.ZERO,[[34,29],[38,20],[41,27]],Color("efe5bd"))
				r(c,23,13,10,3,"c7c6a1" if female else "9b563e")
	# Class helmets above the race face, with gender-specific crest/hood details.
	if role == 0:
		r(c,12,7,32,5,"69828d")
		r(c,16,4,24,4,"bacac7")
		r(c,26,4,5,10,trim)
		H.poly(c,Vector2.ZERO,[[26,5],[26,-5],[31,-9],[35,-3],[31,5]],Color("b76254" if female else "d8bb6f"))
	elif role == 1:
		H.poly(c,Vector2.ZERO,[[8,10],[18,2],[25,-15],[35,-20],[33,-7],[42,10]],Color("302c51"))
		H.poly(c,Vector2.ZERO,[[13,9],[23,0],[28,-10],[32,-13],[30,-3],[36,9]],Color("76638e"))
		r(c,6,10,42,5,"b89965")
		r(c,9,15,37,3,"493b63")
		r(c,27,-4,3,3,"eee7b6")
		if female: r(c,37,8,4,9,"8bdfd5")
	else:
		H.poly(c,Vector2.ZERO,[[10,16],[12,4],[25,-1],[38,4],[46,16],[38,14],[34,9],[20,9],[16,14]],Color("254a3d"))
		H.poly(c,Vector2.ZERO,[[14,5],[26,2],[38,6],[35,10],[21,8]],Color("76915b"))
		H.poly(c,Vector2.ZERO,[[37,5],[46,-8],[49,-5],[41,8]],Color("c5af74" if female else "91bd80"))
	c.draw_set_transform(offset)
