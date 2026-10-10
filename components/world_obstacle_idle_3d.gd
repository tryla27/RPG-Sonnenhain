extends Node3D
## Kurze seltene Bewegung mit langer Ruhephase; feste Körper und Collider bleiben stehen.
@export var idle_min:=25.0
@export var idle_max:=60.0
@export var motif_seed:=0
var countdown:=0.0
var random:=RandomNumberGenerator.new()
func _ready()->void:
	random.seed=motif_seed ^ hash(global_position.snapped(Vector3(.01,.01,.01)))
	countdown=random.randf_range(idle_min,idle_max)
func _process(delta:float)->void:
	var notifier:=get_node_or_null("Visibility") as VisibleOnScreenNotifier3D
	if notifier!=null and not notifier.is_on_screen():return
	countdown-=delta
	if countdown>0:return
	var player:=get_node_or_null("AnimationPlayer") as AnimationPlayer
	if player!=null and player.has_animation("rare_event"):player.play("rare_event")
	countdown=random.randf_range(idle_min,idle_max)
