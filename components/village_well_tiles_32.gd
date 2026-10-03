extends RefCounted
## Native 32px village well for Map 0. No legacy sprite atlas.
const TILE:=32
const STONE_DARK:=Color("4f514a")
const STONE:=Color("7c7d70")
const STONE_LIGHT:=Color("aaa995")
const WOOD_DARK:=Color("5b422f")
const WOOD:=Color("8a6642")
const WOOD_LIGHT:=Color("bf9259")
const WATER:=Color("355c67")
const WATER_LIGHT:=Color("65a5b2")

static func paint(c:CanvasItem,p:Vector2)->void:
	# Footprint: 4x4 tiles (128x128), centered on the historical well anchor.
	var o:=p-Vector2(64,96)
	# Ground shadow.
	c.draw_rect(Rect2(o+Vector2(16,108),Vector2(96,16)),Color("202b2a",0.28))
	# Stone basin, assembled in 32px-aligned blocks.
	for tx in range(4):
		c.draw_rect(Rect2(o+Vector2(tx*TILE,64),Vector2(TILE,TILE)),STONE if tx%2==0 else STONE_DARK)
		c.draw_rect(Rect2(o+Vector2(tx*TILE,64),Vector2(TILE,5)),STONE_LIGHT)
	c.draw_rect(Rect2(o+Vector2(16,54),Vector2(96,16)),STONE_DARK)
	c.draw_rect(Rect2(o+Vector2(24,58),Vector2(80,10)),STONE_LIGHT)
	# Water opening.
	c.draw_rect(Rect2(o+Vector2(32,70),Vector2(64,18)),WATER)
	c.draw_rect(Rect2(o+Vector2(40,73),Vector2(48,4)),WATER_LIGHT)
	# Two timber posts and crossbeam.
	for x in [16,104]:
		c.draw_rect(Rect2(o+Vector2(x,10),Vector2(8,58)),WOOD_DARK)
		c.draw_rect(Rect2(o+Vector2(x+2,12),Vector2(4,54)),WOOD_LIGHT)
	c.draw_rect(Rect2(o+Vector2(12,8),Vector2(104,10)),WOOD_DARK)
	c.draw_rect(Rect2(o+Vector2(16,10),Vector2(96,5)),WOOD_LIGHT)
	# Small roof/cap in 32px language.
	c.draw_rect(Rect2(o+Vector2(16,-8),Vector2(96,16)),Color("74362d"))
	c.draw_rect(Rect2(o+Vector2(32,-16),Vector2(64,8)),Color("a84c35"))
	c.draw_rect(Rect2(o+Vector2(48,-24),Vector2(32,8)),Color("c96a48"))
	# Rope, crank and bucket.
	c.draw_rect(Rect2(o+Vector2(62,18),Vector2(4,43)),Color("c7b38b"))
	c.draw_rect(Rect2(o+Vector2(47,27),Vector2(18,5)),WOOD_DARK)
	c.draw_rect(Rect2(o+Vector2(43,25),Vector2(5,9)),WOOD_LIGHT)
	c.draw_rect(Rect2(o+Vector2(58,54),Vector2(14,14)),Color("6e5941"))
	c.draw_rect(Rect2(o+Vector2(60,56),Vector2(10,8)),Color("a38257"))
