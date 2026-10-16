extends RefCounted
## Rein persönlicher Blütenschmuck aus vorhandenem Storyfortschritt, ohne Collider.
static func stage(event_states:Array,rescue_state:int,final_completed:bool)->int:
	if final_completed:return 3
	if rescue_state>=3:return 2
	if not event_states.is_empty() and int(event_states[0])>=3:return 1
	return 0
static func paint(c:CanvasItem,center:Vector2,event_states:Array,rescue_state:int,final_completed:bool)->void:
	var progress:=stage(event_states,rescue_state,final_completed)
	if progress==0:return
	for i in progress*4:
		var side:=-1 if i%2==0 else 1
		var p:=center+Vector2(side*(142+(i/2%3)*14),90+(i/6)*16)
		c.draw_rect(Rect2(p+Vector2(-2,0),Vector2(4,7)),Color("65894f"))
		var tint:=Color("e9bd72") if progress==3 else Color("dc9cae")
		c.draw_rect(Rect2(p+Vector2(-4,-4),Vector2(8,5)),tint)
		c.draw_rect(Rect2(p+Vector2(-2,-6),Vector2(4,9)),tint)
		c.draw_rect(Rect2(p+Vector2(-1,-3),Vector2(2,2)),Color("fff0bd"))
