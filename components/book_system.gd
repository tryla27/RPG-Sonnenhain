extends RefCounted
## Character-bound book progression. Books are discovered in the world and learned permanently,
## but only a level-scaled number can be active at once.
const MAX_BOOK_RANK:=4
const MAX_ACTIVE:=6
var learned:Dictionary={}
var active:Array[String]=[]

func active_cap(level:int)->int:
	if level>=40:return 6
	if level>=30:return 5
	if level>=20:return 4
	if level>=10:return 3
	return 2

func learn(book_id:String)->int:
	if book_id=="":return 0
	var next:=mini(MAX_BOOK_RANK,int(learned.get(book_id,0))+1)
	learned[book_id]=next
	return next

func rank(book_id:String)->int:
	return clampi(int(learned.get(book_id,0)),0,MAX_BOOK_RANK)

func set_active(level:int,book_id:String,enabled:bool)->bool:
	if rank(book_id)<=0:return false
	if enabled:
		if book_id in active:return true
		if active.size()>=active_cap(level):return false
		active.append(book_id)
	else:
		active.erase(book_id)
	return true

func snapshot()->Dictionary:
	return {"learned":learned.duplicate(true),"active":active.duplicate()}

func restore(raw:Variant,level:int)->void:
	learned.clear();active.clear()
	if raw is not Dictionary:return
	var stored:Variant=raw.get("learned",{})
	if stored is Dictionary:
		for key in stored.keys():
			var value:=clampi(int(stored[key]),0,MAX_BOOK_RANK)
			if value>0:learned[str(key)]=value
	var slots:Variant=raw.get("active",[])
	if slots is Array:
		for id in slots:
			var key:=str(id)
			if rank(key)>0 and active.size()<active_cap(level):active.append(key)
