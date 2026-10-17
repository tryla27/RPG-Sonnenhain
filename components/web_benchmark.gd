extends RefCounted
## Browser-Messmodus: Adresse mit ?bench=1 öffnen. Das Webspiel fährt dieselben
## drei Landschaftsrouten wie tools/benchmark_landscape.gd ab (60 Bilder stehen,
## 90 hin, 90 zurück, 5 Einheiten pro Bild; 30 Bilder Aufwärmen nicht gewertet)
## und sendet die Bildzeiten per POST an /bench des ausliefernden Servers
## (tools/web_bench_server.py). Ohne Konto, Netzwerk, Gegner oder Speichern.
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
var frame:=-WARMUP
var last_us:=0
var times:Array=[]
var draw_times:Array=[]
var process_times:Array=[]
var draw_calls:Array=[]
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
	variant=("noanim" if query.contains("noanim=1") else ("no3d" if query.contains("no3d=1") else "normal"))
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
	if frame>=0:
		times.append(float(now-last_us)/1000.0)
		draw_times.append(float(g.performance_draw_us)/1000.0)
		process_times.append(Performance.get_monitor(Performance.TIME_PROCESS)*1000.0)
		draw_calls.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	if frame==0:route_start=counters(g)
	last_us=now
	# Landschaft messen, nicht Gegner: Spawns und Blütenweiler-Angriff aussetzen.
	g.panel="";g.enemies.clear();g.spawn_timer=-1000.0;g.rescue_state=3
	var local:=maxi(frame,0)
	var offset:=0.0 if local<60 else float(local-60 if local<150 else FRAMES-local)*5.0
	g.player_pos=ROUTES[route][1]+Vector2(offset,0)
	g.camera_pos=g.player_pos-g.VIEW*.5;g.camera_smooth=g.camera_pos
	frame+=1
	if frame<FRAMES-WARMUP:return
	var over:=0
	for ms in times:
		if float(ms)>50.0:over+=1
	var entry:={"scene":ROUTES[route][0],"frames":times.size(),"p50_ms":percentile(times,.5),"p95_ms":percentile(times,.95),"p99_ms":percentile(times,.99),"over_50_ms":over,"draw_cpu_p95_ms":percentile(draw_times,.95),"process_p95_ms":percentile(process_times,.95),"draw_calls_p95":percentile(draw_calls,.95),"active_3d":g.world_obstacles_3d.active}
	var end:=counters(g)
	for key in end:entry[key]=int(end[key])-int(route_start.get(key,0))
	results.append(entry)
	times=[];draw_times=[];process_times=[];draw_calls=[];route+=1;frame=-WARMUP
	g.world_obstacles_3d.signature=""
	if route>=ROUTES.size():
		finished=true
		send(g)

## Zähler des Landschaftsrenderers und des Kartencaches (Differenz je Route).
func counters(g)->Dictionary:
	var metrics:Dictionary=g.world_obstacles_3d.metrics_snapshot()
	return {"page_updates":metrics["page_updates"],"collections":metrics["collections"],"instances_created":metrics["instances_created"],"static_chunks":g.static_chunks.size()}

func send(g)->void:
	var report:={"variant":variant,"agent":str(JavaScriptBridge.eval("navigator.userAgent",true)),"brave":bool(JavaScriptBridge.eval("!!navigator.brave",true)),
		"adapter":RenderingServer.get_video_adapter_name(),"api":RenderingServer.get_video_adapter_api_version(),
		"viewport":[g.get_viewport().get_visible_rect().size.x,g.get_viewport().get_visible_rect().size.y],"results":results}
	var body:=JSON.stringify(report)
	JavaScriptBridge.eval("fetch('/bench',{method:'POST',headers:{'Content-Type':'application/json'},body:%s}).then(()=>{document.title='BENCH_DONE'})"%JSON.stringify(body),true)
	print("WEB_BENCH ",body)
