"""Einheitliche Inventarbilder aus genau denselben Blender-Waffenquellen."""
import bpy
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[2]
bpy.ops.wm.open_mainfile(filepath=str(ROOT/"art/source/blender/sonnenhain_quality_v1.blend"))
OUT=ROOT/"art/ui/quality_v1/items";OUT.mkdir(parents=True,exist_ok=True)
scene=bpy.context.scene;scene.render.engine="CYCLES";scene.cycles.samples=12
scene.render.resolution_x=96;scene.render.resolution_y=96;scene.render.resolution_percentage=100
scene.render.image_settings.file_format="PNG";scene.render.image_settings.color_mode="RGBA";scene.render.film_transparent=True
camera_data=bpy.data.cameras.new("InventoryCamera");camera=bpy.data.objects.new("InventoryCamera",camera_data);scene.collection.objects.link(camera);scene.camera=camera
camera_data.type="ORTHO";camera_data.ortho_scale=2.05
camera.location=(2,-5,2.1);camera.rotation_euler=(Vector((0,0,.8))-camera.location).to_track_quat("-Z","Y").to_euler()
light_data=bpy.data.lights.new("InventoryLight","AREA");light_data.energy=450;light_data.shape="DISK";light_data.size=4
light=bpy.data.objects.new("InventoryLight",light_data);scene.collection.objects.link(light);light.location=(0,-3,5)
light.rotation_euler=(Vector((0,0,.7))-light.location).to_track_quat("-Z","Y").to_euler()
for obj in scene.objects:
    if obj.type not in ["LIGHT","CAMERA"]:obj.hide_render=True
for typ in ["sword","staff","bow"]:
    for tier in [1,2,3]:
        name=f"{typ}_tier{tier}"
        objects=list(bpy.data.collections[name].objects)
        for obj in objects:obj.hide_render=False
        scene.render.filepath=str(OUT/(name+".png"));bpy.ops.render.render(write_still=True)
        for obj in objects:obj.hide_render=True
print("ITEM_ICONS_OK 9 Bilder aus gemeinsamen 3D-Quellen")
