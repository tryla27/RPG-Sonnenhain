extends SceneTree
# Goldener Ritter (menschlicher Krieger): Blatt vollständig, Richtungen wie die
# Dateinamen (S, SW, W, …), Bildwahl für Stehen/Gehen/Laufen/Angriff/Treffer,
# nur Menschen-Krieger.

const Hero=preload("res://components/rpg_hero.gd")

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("GOLDEN_KNIGHT_FAIL "+label)

func _initialize()->void:
	var tex:Texture2D=load(Hero.KNIGHT_SHEET)
	check(tex!=null,"Ritter-Blatt vorhanden")
	if tex!=null:
		var cols:=0
		for k in Hero.KNIGHT_ANIMS:cols=maxi(cols,int(Hero.KNIGHT_ANIMS[k][0])+int(Hero.KNIGHT_ANIMS[k][1]))
		check(tex.get_width()==int(Hero.KNIGHT_CELL.x)*cols and tex.get_height()==int(Hero.KNIGHT_CELL.y)*8,"Blatt %dx%d" % [tex.get_width(),tex.get_height()])
		# Jede Zelle enthält eine Figur.
		var img:Image=tex.get_image()
		for row in 8:
			for col in cols:
				var filled:=0
				for y in range(0,80,2):
					for x in range(0,64,2):
						if img.get_pixel(col*64+x,row*80+y).a>0.5:filled+=1
				if filled<120:check(false,"Zelle %d/%d leer (%d)" % [row,col,filled])
	# Richtungen: S, SW, W, NW, N, NO, O, SO (Bildschirm, y nach unten).
	check(Hero.knight_row(Vector2.DOWN)==0 and Hero.knight_row(Vector2.LEFT)==2 and Hero.knight_row(Vector2.UP)==4 and Hero.knight_row(Vector2.RIGHT)==6,"Hauptrichtungen")
	check(Hero.knight_row(Vector2(-1,1))==1 and Hero.knight_row(Vector2(1,1))==7 and Hero.knight_row(Vector2(1,-1))==5 and Hero.knight_row(Vector2(-1,-1))==3,"Diagonalen")
	# Bildwahl.
	check(Hero.knight_frame(0.0,false,0.0,-1.0,0.0) in range(0,4),"Stehen")
	check(Hero.knight_frame(1.0,false,0.0,-1.0,0.0) in range(4,10),"Gehen")
	check(Hero.knight_frame(1.0,true,0.0,-1.0,0.0) in range(10,16),"Laufen")
	check(Hero.knight_frame(0.0,false,0.0,0.5,0.0) in range(16,20),"Angriff")
	check(Hero.knight_frame(0.0,false,0.9,-1.0,0.0) in range(20,22),"Treffer")
	var walk:={}
	for k in 12:walk[Hero.knight_frame(0.01+k*TAU/12.0,false,0.0,-1.0,0.0)]=true
	check(walk.size()==6,"sechs Gehbilder (%d)" % walk.size())
	check(Hero.uses_knight(0,0) and not Hero.uses_knight(0,1) and not Hero.uses_knight(0,2) and not Hero.uses_knight(1,0),"nur menschliche Krieger")
	if failures>0:
		push_error("GOLDEN_KNIGHT_FAILED %d" % failures);quit(1);return
	print("GOLDEN_KNIGHT_OK")
	quit()
