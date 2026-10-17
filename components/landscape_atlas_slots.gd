extends RefCounted
## Stabile Atlasplätze und begrenzter Rückweg-Cache, unabhängig vom Renderer.
var pages:Array=[]
var entries:Dictionary={}
var clock:=0
const KEEP_HIDDEN:=32

func reconcile(rows:Array,animated:Callable)->Dictionary:
	clock+=1
	var wanted:Dictionary={};var added:Array=[];var removed:Array=[]
	for row in rows:wanted[str(row["key"])]=true
	var hidden:Array=[]
	for key in entries:
		if not wanted.has(key):hidden.append(key)
	hidden.sort_custom(func(a,b):return int(entries[a]["seen"])<int(entries[b]["seen"]))
	while hidden.size()>KEEP_HIDDEN:
		var key:String=hidden.pop_front();var old:Dictionary=entries[key]
		pages[int(old["page"])]["used"].erase(int(old["slot"]))
		entries.erase(key);removed.append(key)
	for row in rows:
		var key:=str(row["key"])
		if not entries.has(key):
			var moving:bool=animated.call(row)
			var page_index:=-1;var slot:=-1
			for index in pages.size():
				var page:Dictionary=pages[index]
				if bool(page["animated"])!=moving:continue
				for candidate in int(page["capacity"]):
					if not page["used"].has(candidate):page_index=index;slot=candidate;break
				if page_index>=0:break
			if page_index<0:
				page_index=pages.size();slot=0
				pages.append({"animated":moving,"capacity":16 if moving else 64,"used":{}})
			pages[page_index]["used"][slot]=key
			entries[key]={"page":page_index,"slot":slot,"seen":clock};added.append(key)
		entries[key]["seen"]=clock
	return {"added":added,"removed":removed,"wanted":wanted}

func source(key:String,cell:int=128)->Rect2:
	var entry:Dictionary=entries[key]
	var columns:=4 if bool(pages[int(entry["page"])]["animated"]) else 8
	var slot:=int(entry["slot"])
	return Rect2(Vector2(slot%columns,slot/columns)*cell,Vector2.ONE*cell)
