extends SceneTree
const Fixtures=preload("res://components/village_fixtures.gd")
const Layout=preload("res://components/village_layout.gd")
const Paths=preload("res://components/village_paths.gd")
func _initialize()->void:
	var image:=Fixtures.glow_texture().get_image()
	var size:=image.get_width()
	for i in size:
		assert(image.get_pixel(i,0).a==0 and image.get_pixel(i,size-1).a==0,"Glow must have transparent top/bottom borders")
		assert(image.get_pixel(0,i).a==0 and image.get_pixel(size-1,i).a==0,"Glow must have transparent side borders")
	assert(image.get_pixel(size/2,size/2).a>0.98)
	var previous:=1.0
	for x in range(size/2,size):
		var alpha:=image.get_pixel(x,size/2).a
		assert(alpha<=previous,"Glow must fade without hard rings")
		previous=alpha
	assert(Fixtures.glow_strength(0)==0 and Fixtures.glow_strength(0.1)==0,"No colored light patches during daylight")
	assert(Fixtures.glow_strength(1)>Fixtures.glow_strength(0.5) and Fixtures.glow_strength(1)<=0.14)
	assert(Layout.BUSHES.size()==4)
	assert(Vector2(1232,848) not in Layout.BUSHES,"Orange bush beside well must be removed")
	for p:Vector2 in Layout.BUSHES:assert(Paths.distance(p)>88,"Relocated green bushes must stay off the road")
	var source:=FileAccess.get_file_as_string("res://main.gd")
	assert(source.contains('"bush": StartScenery32.scenery(self,p,"busch-oliv")'))
	print("VILLAGE_LIGHTING_OK transparent glow edges, smooth falloff, no daylight tint; four fixed green bushes off roads")
	quit()
