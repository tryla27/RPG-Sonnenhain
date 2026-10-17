extends RefCounted
## Browser-Messmodus: Adresse mit ?bench=1 öffnen. Das Webspiel fährt dieselben
## drei Landschaftsrouten wie tools/benchmark_landscape.gd ab (60 Bilder stehen,
## 90 hin, 90 zurück, 5 Einheiten pro Bild; 30 Bilder Aufwärmen nicht gewertet)
## und sendet die Bildzeiten per POST an /bench des ausliefernden Servers
## (tools/web_bench_server.py). Ohne Konto, Netzwerk oder Speichern;
## standardmäßig ohne Gegner, mit ?ai=1 als gesonderte Kampfmessung.
## Erste Runde ("aufwaermen") lädt Shader, Modelle und Kartenabschnitte und
## wird getrennt ausgewiesen; danach die drei Vergleichsrouten.
const ROUTES:=[["aufwaermen",Vector2(3650,2650)],["wiese",Vector2(3650,2650)],["mauertor",Vector2(5000,1250)],["pilzwald",Vector2(3150,4780)]]
const WARMUP:=30
const AtlasPage=preload("res://components/landscape_atlas_page.gd")
const Obstacles=preload("res://components/world_obstacles_3d.gd")
const FRAMES:=240

var active:=false
var finished:=false
var variant:="normal"
var route:=0
## Nächstes zu zeichnendes Bild; step() misst jeweils das vorherige Bild.
var frame:=0
var last_us:=0
var times:Array=[]
var draw_times:Array=[]
var process_times:Array=[]
var draw_calls:Array=[]
var enemy_counts:Array=[]
var route_start:Dictionary={}
var results:Array=[]

static func requested()->bool:
	if not OS.has_feature("web") or not ClassDB.class_exists("JavaScriptBridge"):return false
	return str(JavaScriptBridge.eval("location.search",true)).contains("bench=1")

static func percentile(values:Array,part:float)->float:
	if values.is_empty():return 0.0
	var ordered:=values.duplicate();ordered.sort()
	return float(ordered[mini(ordered.size()-1,ceili(ordered.size()*part)-1)])

func start(g)->void:
	active=true
	# Diagnoseschalter: ?noanim=1 hält seltene Landschaftsanimationen an,
	# ?no3d=1 zeigt die bisherige 2D-Landschaft.
	var query:=str(JavaScriptBridge.eval("location.search",true)) if OS.has_feature("web") else ""
	variant=("noanim" if query.contains("noanim=1") else ("no3d" if query.contains("no3d=1") else ("ai" if query.contains("ai=1") else "normal")))
	if variant=="noanim":AtlasPage.freeze_animation=true
	if variant=="no3d":
		Obstacles.active=false
		if g.has_method("invalidate_static_cache"):g.invalidate_static_cache()
	# Keine Verbindung zum Live-Server, kein Konto, kein Speichern.
	g.konflux_preview_mode=true
	g.panel="";g.character_created=true;g.hero_name="Messung";g.level=40
	g.enemies.clear();g.world_fog.bytes.fill(255);g.world_fog.mark_changed()
	last_us=Time.get_ticks_usec()

## Zu Beginn jedes Spielbilds aufrufen.
func step(g)->void:
	if not active or finished:return
	var now:=Time.get_ticks_usec()
	# Die Dauer gehört zum vorigen Bild. Auch das letzte Bild einer Route
	# vollständig abwarten, bevor dessen Messwerte abgeschlossen werden.
	if frame>WARMUP:
		times.append(float(now-last_us)/1000.0)
		draw_times.append(float(g.performance_draw_us)/1000.0)
		process_times.append(Performance.get_monitor(Performance.TIME_PROCESS)*1000.0)
		draw_calls.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
		enemy_counts.append(g.enemies.size())
	if frame>=FRAMES:
		finish_route(g)
		if finished:return
	if frame==WARMUP:route_start=counters(g)
	last_us=now
	# Landschaft messen, nicht Gegner: Spawns und Blütenweiler-Angriff aussetzen.
	# ?ai=1 lässt Spawns und den Blütenweiler-Angriff zu (Gegner-KI im Browser).
	g.panel=""
	if variant!="ai":g.enemies.clear();g.spawn_timer=-1000.0;g.rescue_state=3
	var local:=frame
	var offset:=0.0 if local<60 else float(local-60 if local<150 else FRAMES-local)*5.0
	g.player_pos=ROUTES[route][1]+Vector2(offset,0)
	g.camera_pos=g.player_pos-g.VIEW*.5;g.camera_smooth=g.camera_pos
	frame+=1

func finish_route(g)->void:
	var over:=0
	for ms in times:
		if float(ms)>50.0:over+=1
	var entry:={"scene":ROUTES[route][0],"frames":times.size(),"p50_ms":percentile(times,.5),"p95_ms":percentile(times,.95),"p99_ms":percentile(times,.99),"over_50_ms":over,"draw_cpu_p95_ms":percentile(draw_times,.95),"process_p95_ms":percentile(process_times,.95),"draw_calls_p95":percentile(draw_calls,.95),"active_3d":g.world_obstacles_3d.active}
	var enemy_total:=0
	for amount in enemy_counts:enemy_total+=int(amount)
	entry["enemies_min"]=enemy_counts.min() if not enemy_counts.is_empty() else 0
	entry["enemies_max"]=enemy_counts.max() if not enemy_counts.is_empty() else 0
	entry["enemies_mean"]=float(enemy_total)/maxi(1,enemy_counts.size())
	var end:=counters(g)
	for key in end:entry[key]=int(end[key])-int(route_start.get(key,0))
	results.append(entry)
	times=[];draw_times=[];process_times=[];draw_calls=[];enemy_counts=[];route+=1;frame=0
	g.world_obstacles_3d.signature=""
	if route>=ROUTES.size():
		finished=true
		send(g)

## Zähler des Landschaftsrenderers und des Kartencaches (Differenz je Route).
func counters(g)->Dictionary:
	var metrics:Dictionary=g.world_obstacles_3d.metrics_snapshot()
	return {"page_updates":metrics["page_updates"],"collections":metrics["collections"],"instances_created":metrics["instances_created"],"static_chunks":g.static_chunks.size()}

func send(g)->void:
	var report:={"schema":2,"frames_per_route":FRAMES,"discarded_frames":WARMUP,"variant":variant,"agent":str(JavaScriptBridge.eval("navigator.userAgent",true)),"brave":bool(JavaScriptBridge.eval("!!navigator.brave",true)),
		"adapter":RenderingServer.get_video_adapter_name(),"api":RenderingServer.get_video_adapter_api_version(),
		"viewport":[g.get_viewport().get_visible_rect().size.x,g.get_viewport().get_visible_rect().size.y],"results":results}
	var body:=JSON.stringify(report)
	JavaScriptBridge.eval("fetch('/bench',{method:'POST',headers:{'Content-Type':'application/json'},body:%s}).then(()=>{document.title='BENCH_DONE'})"%JSON.stringify(body),true)
	print("WEB_BENCH ",body)
