extends RefCounted
## Stable choices: the same cell always receives the same variant after reload/network sync.
static func hash_cell(id:String,cell:Vector2i)->int:
	return posmod(cell.x*92821+cell.y*68917+id.hash(),2147483647)

static func variant_index(id:String,cell:Vector2i,count:int=4)->int:
	return 0 if count<=1 else posmod(hash_cell(id,cell),count)

static func chance(id:String,cell:Vector2i,modulo:int)->bool:
	return modulo<=1 or posmod(hash_cell(id,cell),modulo)==0
