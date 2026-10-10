extends RefCounted
## One procedural model family for selection, all maps and multiplayer.
const H = preload("res://components/reference_house.gd")
const GoldenSprites = preload("res://components/golden_sprite_runtime.gd")
const GOLDEN_HUMAN_WARRIOR_IDLE := "res://art/sprites/characters/golden_human_warrior/idle_8dir.png"
const GOLDEN_HUMAN_WARRIOR_JUMP := [
	"res://art/sprites/characters/golden_human_warrior/jump/jump-south-8f-v1.png",
	"res://art/sprites/characters/golden_human_warrior/jump/jump-south-west-8f-v1.png",
	"res://art/sprites/characters/golden_human_warrior/jump/jump-west-8f-v1.png",
	"res://art/sprites/characters/golden_human_warrior/jump/jump-north-west-8f-v1.png",
	"res://art/sprites/characters/golden_human_warrior/jump/jump-north-8f-v1.png",
	"res://art/sprites/characters/golden_human_warrior/jump/jump-north-east-8f-v1.png",
	"res://art/sprites/characters/golden_human_warrior/jump/jump-east-8f-v1.png",
	"res://art/sprites/characters/golden_human_warrior/jump/jump-south-east-8f-v1.png"
]
const TILE_SIZE := 32
const PIXEL_STEP := 2.0
static var hurt_flash:=0.0

static func r(c: CanvasItem, x: float,y: float,w: float,h: float,color: String) -> void:
	var position := Vector2(roundf(x/PIXEL_STEP),roundf(y/PIXEL_STEP))*PIXEL_STEP
	var size := Vector2(maxf(1.0,roundf(w/PIXEL_STEP)),maxf(1.0,roundf(h/PIXEL_STEP)))*PIXEL_STEP
	c.draw_rect(Rect2(position,size),Color(color).lerp(Color("fff3de"),hurt_flash*.75))

static func poly(c:CanvasItem,p:Vector2,points:Array,color:Color)->void:
	var vertices := PackedVector2Array()
	for point in points:
		vertices.append(p+Vector2(roundf(float(point[0])/PIXEL_STEP),roundf(float(point[1])/PIXEL_STEP))*PIXEL_STEP)
	c.draw_colored_polygon(vertices,color.lerp(Color("fff3de"),hurt_flash*.75))

static func direction_index(look:Vector2)->int:
	if look.length_squared()<0.0001:return 0
	return posmod(roundi(atan2(look.x,look.y)/(PI/4.0)),8)

static func paint(c: CanvasItem,p: Vector2,role: int,race: int,gender: int,look: Vector2,phase: float,s: float,offset: Vector2,roll: float=-1.0,roll_dir: Vector2=Vector2.RIGHT,armor: int=-1,death: float=-1.0,hurt:float=0.0,head:int=-1,rings:int=0,running:bool=false,jump_progress:float=-1.0,necklace:int=-1) -> void:
	hurt_flash=clampf(hurt,0,1)
	var female := gender == 1
	var heading:=direction_index(look)
	if role==0 and race==0 and gender==0 and jump_progress>=0.0 and death<0.0:
		var frame:=clampi(floori(clampf(jump_progress,0.0,0.9999)*8.0),0,7)
		var tint:=Color("fff3de").lerp(Color.WHITE,1.0-clampf(hurt,0.0,1.0)*0.45)
		if GoldenSprites.draw_animation_strip(c,GOLDEN_HUMAN_WARRIOR_JUMP[heading],p+offset,frame,8,Vector2(96,96),75.0,s,tint):
			preload("res://components/arcane_necklaces.gd").paint_actor(c,p+offset+(Vector2(0,-sin(jump_progress*PI)*20)*s if jump_progress>=0 else Vector2.ZERO),look,necklace,s,phase)
			hurt_flash=0.0
			return
	# Golden pilot: authored idle strip for the base human warrior. Incomplete
	# animation/equipment states deliberately fall back to the proven renderer.
	if role==0 and race==0 and gender==0 and phase==0.0 and not running and roll<0.0 and death<0.0 and armor<0 and head<0:
		var tint:=Color("fff3de").lerp(Color.WHITE,1.0-clampf(hurt,0.0,1.0)*0.45)
		if GoldenSprites.draw_direction_strip(c,GOLDEN_HUMAN_WARRIOR_IDLE,p+offset,heading,Vector2(24,24),20.0,s*4.0,tint):
			preload("res://components/arcane_necklaces.gd").paint_actor(c,p+offset+(Vector2(0,-sin(jump_progress*PI)*20)*s if jump_progress>=0 else Vector2.ZERO),look,necklace,s,phase)
			hurt_flash=0.0
			return
	look=Vector2(sin(heading*PI/4.0),cos(heading*PI/4.0))
	var back := heading==4
	var diagonal := heading in [1,3,5,7]
	var rear_diagonal := heading in [3,5]
	var width := (17 if female else 20)+(3 if race == 1 else 0)
	var skin: String = ["d6a478","87a76a","aebbc1"][clampi(race,0,2)]
	var shade: String = ["a47758","537949","677985"][clampi(race,0,2)]
	var cloth: String = ["416579","544477","386454"][role]
	var trim: String = ["d9b964","c5a7e6","c1ac76"][role]
	if armor >= 0:
		# 0–5 Grundrüstungen, 6–12 legendäre Rüstungen (master_armor.gd).
		cloth = ["95734e","536d86","674e8c","426b55","963f40","a7aeb0","6f8a4e","3b2a6b","2f5a3a","8c96a0","7a1f2b","6aa8d6","26232b"][clampi(armor,0,12)]
		trim = ["cfb47c","d5c5a0","8fdedd","d2be79","e7c46b","86d8ed","ece4b4","8fe6ff","a8c36a","e0b85a","d9dde6","f3f0c8","b45cff"][clampi(armor,0,12)]
	var hair: String = "ba7147" if female else "604737"
	var run_stride:float=([5.5,5.0,7.0][clampi(role,0,2)]+([0.0,0.5,0.8][clampi(race,0,2)] if running else 0.0)) if running else 4.0
	var stride := int(sin(phase)*run_stride)
	var rotation := 0.0
	var squash := Vector2.ONE
	# Race/class anatomy is shared by walking, equipment, rolling and death.
	squash.y = [1.0,0.94,1.08][clampi(race,0,2)]*(1.02 if female else 1.0)
	squash.x = 1.06 if role == 0 else (0.96 if role == 1 else 1.0)
	if running and roll<0.0 and death<0.0:
		# Sprint bleibt klar dieselbe Figur: kräftiger Schritt, tieferer Schwerpunkt,
		# rassenspezifisch unterschiedlich schwer bzw. mechanisch gestreckt.
		squash.y *= [0.99,0.96,1.02][clampi(race,0,2)]
		squash.x *= [1.0,1.035,0.985][clampi(race,0,2)]
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
	var profile := heading in [1,2,3,5,6,7]
	if profile:
		squash.x *= (0.96 if diagonal else 0.90)*(1.0 if look.x > 0 else -1.0)
	var scale := Vector2.ONE*s*squash
	var pivot := p+offset+Vector2(0,-10+(2 if running and role==0 else (1 if running else 0)))*s
	if death >= 0: pivot.y += smoothstep(0.0,0.7,death)*19.0*s
	var body_transform:=Transform2D(rotation,scale,0.0,Vector2.ZERO)
	body_transform.origin=pivot-body_transform*Vector2(28,44)
	c.draw_set_transform_matrix(body_transform)
	# Klassen-Hintergrunddetails. Der Krieger besitzt keinen fest eingebauten
	# braunen Umhang mehr; sein Umhang kommt ausschließlich aus dem Atelier-Layer
	# in main.gd, damit Farbe, Form, Blickrichtung und Sprung konsistent bleiben.
	if role == 1:
		poly(c,Vector2.ZERO,[[12,29],[44,29],[49,70],[33,74],[9,69]],Color("302e51"))
	elif role == 2:
		poly(c,Vector2.ZERO,[[8,27],[18,23],[27,63],[16,67]],Color("674836"))
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
	poly(c,Vector2.ZERO,[[28-width,31],[28+width,31],[28+width-3,49],[28+width+1,61],[28-width-1,61],[28-width+3,49]],Color("253541"))
	poly(c,Vector2.ZERO,[[30-width,33],[26+width,33],[24+width,49],[27+width,59],[29-width,59],[32-width,49]],Color(cloth))
	r(c,14,55,28,5,"604733")
	r(c,25,55,7,5,trim)
	if role == 0:
		for side in [-1,1]:
			var x: int = 28+side*(width-4)-6
			poly(c,Vector2.ZERO,[[x,29],[x+12,29],[x+15,36],[x+11,41],[x-3,39]],Color("445565"))
			r(c,x,31,12,4,"b6c9c8")
			r(c,x+2,35,9,3,trim)
		poly(c,Vector2.ZERO,[[18,37],[38,37],[36,50],[28,54],[20,50]],Color("82999d"))
		r(c,20,38,15,3,"c8d7ca")
		poly(c,Vector2.ZERO,[[28,41],[33,45],[28,50],[23,45]],Color(trim))
	elif role == 1:
		for y in [36,43,50]: r(c,27,y,3,3,trim)
		poly(c,Vector2.ZERO,[[10,32],[19,35],[24,49],[19,55],[8,49]],Color("75618e"))
		r(c,13,41,7,3,"ead5a7")
		r(c,36,50,7,10,"b89e73")
		r(c,38,52,4,5,"80dad6")
	else:
		poly(c,Vector2.ZERO,[[12,34],[18,31],[44,55],[40,59]],Color("aa8456"))
		r(c,34,50,8,12,"76583b")
		r(c,36,51,5,3,trim)
		poly(c,Vector2.ZERO,[[24,37],[30,32],[35,40],[29,46]],Color("91ad70"))
	if rear_diagonal:
		poly(c,Vector2.ZERO,[[12,31],[30,29],[34,63],[11,66]],Color("302e51" if role==1 else cloth))
		r(c,14,34,3,25,trim)
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
		if armor >= 6: paint_master_armor(c,armor-6,cloth,trim,back)
	for side in [-1,1]:
		var x: int = 28+side*(width+2)-4
		r(c,x,37-stride*side/2,8,16,cloth)
		r(c,x,50-stride*side/2,8,4,trim)
		r(c,x+1,54-stride*side/2,6,5,skin)
	for side in [-1,1]:
		var bit:int=1 if side==1 else 2
		if rings&bit:
			var x:int=28+side*(width+2)-4
			r(c,x+1,55-stride*side/2,6,2,"f8d982")
			r(c,x+3,54-stride*side/2,2,2,"8ce4e1" if bit==1 else "d6b5ff")
	# Race-specific head construction.
	var head_width := 14 if race != 1 else 17
	poly(c,Vector2.ZERO,[[28-head_width,11],[28+head_width,11],[28+head_width,25],[36,32],[20,32],[28-head_width,25]],Color(shade))
	r(c,30-head_width,12,head_width*2-4,15,skin)
	if race == 2:
		poly(c,Vector2.ZERO,[[14,12],[20,6],[37,6],[43,12],[40,30],[17,30]],Color("627c8c"))
		r(c,18,10,21,5,"cad1c4")
		if not back:
			r(c,18,18,21,7,"25384c")
			r(c,20,20,7,3,"8cece0")
			r(c,30,20,7,3,"8cece0")
			r(c,24,27,10,2,"d7b979")
		if female:
			poly(c,Vector2.ZERO,[[11,14],[5,5],[16,8],[19,14]],Color("d1ae73"))
			poly(c,Vector2.ZERO,[[42,14],[50,5],[39,8],[36,14]],Color("d1ae73"))
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
				poly(c,Vector2.ZERO,[[18,25],[23,27],[33,27],[38,25],[33,34],[23,34]],Color("76503b"))
		if back:
			r(c,28-head_width,13,head_width*2,17,hair if race==0 else "34493b")
		else:
			var dx := 3 if look.x > 0.5 else (-3 if look.x < -0.5 else 0)
			if profile:
				if rear_diagonal:r(c,28-head_width,13,head_width,17,hair if race==0 else "34493b")
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
				poly(c,Vector2.ZERO,[[16,27],[20,20],[23,29]],Color("efe5bd"))
				poly(c,Vector2.ZERO,[[34,29],[38,20],[41,27]],Color("efe5bd"))
				r(c,23,13,10,3,"c7c6a1" if female else "9b563e")
	if head>=3:
		paint_boss_hat(c,head-3,female)
	elif head==role:
		# Class helmets above the race face, with gender-specific crest/hood details.
		if role == 0:
			r(c,12,7,32,5,"69828d")
			r(c,16,4,24,4,"bacac7")
			r(c,26,4,5,10,trim)
			poly(c,Vector2.ZERO,[[26,5],[26,-5],[31,-9],[35,-3],[31,5]],Color("b76254" if female else "d8bb6f"))
		elif role == 1:
			poly(c,Vector2.ZERO,[[8,10],[18,2],[25,-15],[35,-20],[33,-7],[42,10]],Color("302c51"))
			poly(c,Vector2.ZERO,[[13,9],[23,0],[28,-10],[32,-13],[30,-3],[36,9]],Color("76638e"))
			r(c,6,10,42,5,"b89965")
			r(c,9,15,37,3,"493b63")
			r(c,27,-4,3,3,"eee7b6")
			if female: r(c,37,8,4,9,"8bdfd5")
		else:
			poly(c,Vector2.ZERO,[[10,16],[12,4],[25,-1],[38,4],[46,16],[38,14],[34,9],[20,9],[16,14]],Color("254a3d"))
			poly(c,Vector2.ZERO,[[14,5],[26,2],[38,6],[35,10],[21,8]],Color("76915b"))
			poly(c,Vector2.ZERO,[[37,5],[46,-8],[49,-5],[41,8]],Color("c5af74" if female else "91bd80"))
	preload("res://components/arcane_necklaces.gd").paint_actor(c,Vector2(28,56),look,necklace,1.0,phase)
	hurt_flash=0.0
	c.draw_set_transform(offset)


## Bosshüte (head 3–5): eigene Form, unabhängig von der Klasse des Trägers.
## 3 Helm des Kriegsherrn, 4 Hut des Dunklen Arkanhüters, 5 Hut des Jagdmeisters.
static func paint_boss_hat(c:CanvasItem,boss:int,female:bool)->void:
	match boss:
		0:
			# Dunkler Eisenhelm mit Hörnern, Goldrand und rotem Kamm.
			r(c,11,6,34,7,"3d4448")
			r(c,14,1,28,6,"5a646a")
			r(c,18,-2,20,4,"6f7a80")
			r(c,11,12,34,2,"c9a24e")
			r(c,26,-3,4,16,"c9a24e")
			poly(c,Vector2.ZERO,[[11,8],[2,-2],[0,-10],[6,-4],[14,5]],Color("e3dccb"))
			poly(c,Vector2.ZERO,[[45,8],[54,-2],[56,-10],[50,-4],[42,5]],Color("e3dccb"))
			poly(c,Vector2.ZERO,[[24,-2],[27,-16],[33,-20],[38,-12],[33,-1]],Color("a8322a"))
			poly(c,Vector2.ZERO,[[28,-6],[31,-15],[34,-12],[32,-3]],Color("d8553f"))
		1:
			# Hoher, geknickter Magierhut in Nachtviolett mit leuchtendem Runenband.
			poly(c,Vector2.ZERO,[[6,12],[17,2],[22,-14],[28,-28],[40,-34],[36,-22],[33,-10],[40,2],[50,12]],Color("1d1733"))
			poly(c,Vector2.ZERO,[[12,10],[21,1],[25,-12],[30,-24],[36,-28],[32,-18],[30,-6],[36,4],[44,10]],Color("3a2c63"))
			r(c,4,10,48,5,"241c3f")
			r(c,9,7,38,3,"5fd6e0")
			for k in 5:r(c,11+k*8,7,3,3,"dffcff")
			poly(c,Vector2.ZERO,[[38,-36],[40,-31],[45,-30],[41,-27],[42,-22],[38,-25],[34,-22],[35,-27],[31,-30],[36,-31]],Color("f3e48e"))
			if female:r(c,46,10,4,10,"8bdfd5")
		_:
			# Breitkrempiger Jägerhut aus Leder mit Blattband und langer Feder.
			poly(c,Vector2.ZERO,[[2,13],[10,9],[46,9],[54,13],[46,16],[10,16]],Color("4e3423"))
			poly(c,Vector2.ZERO,[[13,10],[15,0],[22,-5],[34,-5],[41,0],[43,10]],Color("7a5232"))
			r(c,15,5,26,4,"3d6b3a")
			r(c,18,6,4,2,"8fbf5a")
			r(c,30,6,4,2,"8fbf5a")
			poly(c,Vector2.ZERO,[[40,6],[50,-18],[54,-24],[53,-14],[44,8]],Color("e8d39a"))
			poly(c,Vector2.ZERO,[[45,0],[52,-18],[53,-14],[47,2]],Color("b5462e" if not female else "c76a9a"))


## Legendäre Rüstungen: eigene Details über dem Grundkörper (Brust 16–40 x, 29–53 y).
static func paint_master_armor(c:CanvasItem,id:int,cloth:String,trim:String,back:bool)->void:
	match id:
		0: # Windläufer: helles Leder, Schärpe quer, flatternde Bänder.
			poly(c,Vector2.ZERO,[[16,36],[20,36],[40,50],[36,52]],Color("3f7a3a"))
			poly(c,Vector2.ZERO,[[38,50],[46,56],[44,60],[36,53]],Color("5f9c4c"))
			r(c,18,47,20,3,trim)
		1: # Arkanweber: lange Robe bis über die Knie, leuchtende Runennähte.
			r(c,15,50,26,14,cloth)
			r(c,15,62,26,2,trim)
			for y in [40,46,52,58]:r(c,27,y,2,2,trim)
			r(c,19,38,2,22,"5b4a9b");r(c,35,38,2,22,"5b4a9b")
		2: # Dornenpanzer: Platten mit Dornen an Schultern und Armen.
			for side in [-1,1]:
				var x:int=28+side*17
				poly(c,Vector2.ZERO,[[x-4,30],[x,22],[x+4,30]],Color("d6e2a8"))
				poly(c,Vector2.ZERO,[[x+side*6,38],[x+side*11,35],[x+side*6,42]],Color("d6e2a8"))
			for y in [40,47]:r(c,20,y,16,2,"1d3a25")
		3: # Bollwerk: breite Schulterplatten, Brustplatte mit Goldkante.
			for side in [-1,1]:
				r(c,28+side*19-8,27,16,12,cloth)
				r(c,28+side*19-8,27,16,3,trim)
				r(c,28+side*19-8,38,16,2,"5c646c")
			r(c,20,38,16,12,"a9b3bc");r(c,20,38,16,2,trim)
		4: # Blutmond: tiefroter Mantel, silberner Mond (hinten) bzw. Schließe (vorn).
			r(c,13,33,30,4,cloth)
			if back:
				r(c,14,36,28,26,cloth)
				poly(c,Vector2.ZERO,[[25,42],[31,40],[34,46],[31,52],[25,50],[29,46]],Color(trim))
			else:
				r(c,26,34,5,5,trim)
		5: # Sternenquell: helles Gewand mit Sternfunken.
			for pt in [[20,40],[34,44],[24,50],[37,37]]:
				r(c,pt[0],pt[1],2,2,trim);r(c,pt[0]-1,pt[1]+0.5,4,1,trim)
			r(c,16,51,24,3,"4a86b8")
		6: # Golem-Rüstung (v2): kantige Basaltplatten mit Licht- und Schattenkante,
			# gezackte lila Risse, Schulterbrocken und zwei schwebende Steine.
			for side in [-1,1]:
				var sx:int=28+side*19
				poly(c,Vector2.ZERO,[[sx-9,30],[sx-6,25],[sx+6,25],[sx+9,30],[sx+8,39],[sx-8,39]],Color("2e2a35"))
				poly(c,Vector2.ZERO,[[sx-8,29],[sx-5,26],[sx+5,26],[sx+8,29]],Color("57505f"))
				r(c,sx-8,37,16,2,"1d1a22")
				poly(c,Vector2.ZERO,[[sx-1,28],[sx+1,31],[sx-1,33],[sx+1,36]],Color(trim))
				# schwebender Stein über der Schulter
				poly(c,Vector2.ZERO,[[sx-3,19],[sx,17],[sx+3,19],[sx+2,22],[sx-2,22]],Color("4a4454"))
				r(c,sx-1,19,2,1,trim)
			if not back:
				# Brust: zwei versetzte Platten, Bauchplatte, Steingürtel.
				poly(c,Vector2.ZERO,[[18,36],[27,34],[28,44],[19,45]],Color("3a3540"))
				poly(c,Vector2.ZERO,[[29,34],[38,36],[37,45],[29,44]],Color("332f39"))
				r(c,18,36,9,2,"57505f");r(c,29,34,9,2,"4c4654")
				poly(c,Vector2.ZERO,[[20,46],[36,46],[35,52],[21,52]],Color("2a2730"))
				r(c,20,46,16,1,"4c4654")
				for k in 4:r(c,19+k*5,52,4,3,"3d3945" if k%2==0 else "2e2a35")
				poly(c,Vector2.ZERO,[[23,37],[25,40],[23,42],[26,46],[25,50]],Color(trim))
				poly(c,Vector2.ZERO,[[33,37],[31,41],[33,43]],Color(trim))
			else:
				poly(c,Vector2.ZERO,[[18,35],[38,35],[37,52],[19,52]],Color("2e2a35"))
				for k in 3:r(c,26,37+k*5,4,4,"4a4454")
				poly(c,Vector2.ZERO,[[21,38],[23,43],[21,47]],Color(trim))
				poly(c,Vector2.ZERO,[[35,40],[33,45],[35,49]],Color(trim))
