extends RefCounted
# Startmenü mit Konto: Die drei Speicherplätze zeigen die Charaktere des
# angemeldeten Kontos (vom Server), nicht die lokalen Browser-Spielstände.
# Lokale Stände können zu einem anderen Konto oder einem alten Charakter
# gehören und wurden sonst anders angezeigt als in der Charakterauswahl.

## Index in `characters` für einen Speicherplatz (1–3), sonst -1.
static func index_for_slot(characters:Array,slot:int)->int:
	for i in mini(3,characters.size()):
		var row:Variant=characters[i]
		if row is Dictionary and clampi(int(row.get("slot",1)),1,3)==slot:return i
	return -1

static func label_for(characters:Array,slot:int,class_names:Array)->String:
	var index:=index_for_slot(characters,slot)
	if index<0:return "LEER"
	var row:Dictionary=characters[index]
	var cls:=clampi(int(row.get("class_id",0)),0,class_names.size()-1)
	return "%s · LV %d · %s" % [str(row.get("name","Held")),maxi(1,int(row.get("level",1))),class_names[cls]]

## Die Liste vom Login wird mit dem laufenden Charakter aktuell gehalten
## (Stufe und Name ändern sich beim Spielen).
static func refresh_current(characters:Array,uuid:String,hero_name:String,level:int,class_id:int)->void:
	if uuid=="":return
	for row in characters:
		if row is Dictionary and str(row.get("uuid",""))==uuid:
			row["name"]=hero_name
			row["level"]=level
			row["class_id"]=class_id
