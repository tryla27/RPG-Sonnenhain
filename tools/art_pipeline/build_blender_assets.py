"""Reproduzierbare Blender-Quellen und GLB-Assets für Sonnenhains Grafiklabor.

Aufruf: blender --background --factory-startup --python tools/art_pipeline/build_blender_assets.py
Die Vorschau ersetzt keine vorhandenen Live-Assets.
"""
import bpy
import math
import json
from pathlib import Path
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "art/models/quality_v1"
SOURCE = ROOT / "art/source/blender"
OUT.mkdir(parents=True, exist_ok=True)
SOURCE.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)

PALETTE = {"stone": "899080", "edge": "b5b39b", "shadow": "555e59", "moss": "58784b",
           "wood": "71533e", "gold": "d5aa48", "gold_light": "f0ce72", "cloth": "386875",
           "steel": "9dafb0", "dark": "303c42", "skin": "d4ac86", "rose": "c97e99", "leaf": "68874f"}
MATS = {}
for name, color in PALETTE.items():
    rgb = [int(color[i:i+2], 16) / 255 for i in (0, 2, 4)]
    mat = bpy.data.materials.new("Sonnenhain_" + name)
    mat.diffuse_color = (*rgb, 1)
    mat.use_nodes = True
    shader = mat.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*rgb, 1)
    shader.inputs["Roughness"].default_value = .85
    texture_path = ROOT / "art/textures/quality_v1" / (name + "_krita.png")
    if texture_path.exists():
        tex = mat.node_tree.nodes.new("ShaderNodeTexImage")
        tex.image = bpy.data.images.load(str(texture_path)); tex.interpolation = "Closest"
        mat.node_tree.links.new(tex.outputs["Color"], shader.inputs["Base Color"])
    MATS[name] = mat

assets = []
def collection(name):
    col = bpy.data.collections.new(name)
    bpy.context.scene.collection.children.link(col)
    return col

def move_to(obj, col):
    for old in list(obj.users_collection): old.objects.unlink(obj)
    col.objects.link(obj)
    return obj

def box(col, name, pos, size, material, bevel=0):
    bpy.ops.mesh.primitive_cube_add(size=1, location=pos)
    obj = move_to(bpy.context.object, col); obj.name = name
    obj.dimensions = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(MATS[material])
    if bevel:
        mod = obj.modifiers.new("Stone_edges", "BEVEL"); mod.width = bevel; mod.segments = 1
        bpy.ops.object.modifier_apply(modifier=mod.name)
    return obj

def sphere(col, name, pos, scale, material):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=1, location=pos)
    obj = move_to(bpy.context.object, col); obj.name = name; obj.scale = scale
    obj.data.materials.append(MATS[material]); return obj

def export(col, kind, **metadata):
    bpy.ops.object.select_all(action="DESELECT")
    for obj in col.objects: obj.select_set(True)
    bpy.context.view_layer.objects.active = next(iter(col.objects))
    filename = col.name + ".glb"
    bpy.ops.export_scene.gltf(filepath=str(OUT / filename), use_selection=True,
        export_format="GLB", export_animations=True, export_animation_mode="NLA_TRACKS",
        export_materials="EXPORT", export_yup=True, export_extras=True)
    assets.append({"id": col.name, "path": "art/models/quality_v1/" + filename,
        "kind": kind, "source": "art/source/blender/sonnenhain_quality_v1.blend",
        "unit": "meter", "origin": "Bodenmitte", **metadata})

def wall(name, axis="x", end=False, corner=False):
    col = collection(name)
    for direction in (["x", "y"] if corner else [axis]):
        for row in range(3):
            for cell in range(3):
                pos = [(cell - 1) * .64 + (0.12 if row % 2 else 0), 0, .22 + row * .4]
                size = [.61, .42, .37]
                if direction == "y": pos[0], pos[1] = pos[1], pos[0]; size[0], size[1] = size[1], size[0]
                box(col, "Wall_stone", pos, size, "stone" if (row+cell)%3 else "edge", .025)
        box(col, "Coping", (0,0,1.3), (2.1,.54,.16) if direction=="x" else (.54,2.1,.16), "edge", .035)
    if end: box(col,"Endpost",(.84,0,.72),(.58,.64,1.44),"shadow",.03)
    box(col,"Moss",(-.6,-.225,.2),(.48,.025,.12),"moss")
    export(col,"architecture", footprint=[2.1,.64], collision="Vorhandene Weltgeometrie bleibt maßgeblich")

wall("wall_horizontal")
wall("wall_vertical", "y")
wall("wall_corner", corner=True)
wall("wall_end", end=True)
for name, closed in [("gate_open",False),("gate_closed",True)]:
    col = collection(name)
    for x in [-1.05,1.05]:
        box(col,"Pillar",(x,0,.85),(.5,.6,1.7),"stone",.035)
        box(col,"Pillar_cap",(x,0,1.76),(.65,.72,.16),"edge",.03)
    box(col,"Arch_lintel",(0,0,1.94),(2.65,.65,.24),"edge",.025)
    if closed:
        for x in range(-4,5): box(col,"Wood_bar",(x*.2,0,.88),(.13,.12,1.65),"wood",.015)
        for z in [.4,1.25]:box(col,"Gate_band",(0,-.08,z),(1.9,.08,.11),"steel")
    export(col,"state", state="closed" if closed else "open", opening=1.6)
col=collection("moss_rock")
for i in range(4):sphere(col,"Rock",((i%2-.5)*.65,(i//2-.5)*.4,.3),(.55,.4,.45),"stone" if i%2 else "shadow")
sphere(col,"Moss",(-.3,0,.65),(.35,.27,.1),"moss"); export(col,"architecture")

for typ in ["sword","staff","bow"]:
    for tier in [1,2,3]:
        col=collection(f"{typ}_tier{tier}")
        if typ=="sword":
            box(col,"Grip",(0,0,.15),(.09,.09,.3),"wood")
            box(col,"Guard",(0,0,.34),(.33+tier*.05,.10,.08),"gold",.01)
            box(col,"Blade",(0,0,.8),(.10+tier*.025,.045,.85),"steel",.015)
            if tier>1:sphere(col,"Gem",(0,-.07,.35),(.07,.05,.08),"cloth")
        elif typ=="staff":
            box(col,"Shaft",(0,0,.7),(.075,.075,1.4),"wood")
            sphere(col,"Crown",(0,0,1.5),(.12+tier*.035,.12, .2),"gold" if tier==1 else "cloth")
            for side in [-1,1]:box(col,"Prong",(side*.16,0,1.4),(.04,.06,.32),"gold")
        else:
            curve=bpy.data.curves.new("Bow_curve","CURVE");curve.dimensions="3D";curve.bevel_depth=.035+tier*.005;curve.bevel_resolution=0
            spline=curve.splines.new("POLY");spline.points.add(8)
            for i,p in enumerate(spline.points):
                z=i/8*1.3;p.co=(math.sin(i/8*math.pi)*.3,0,z,1)
            obj=bpy.data.objects.new("Bow_limb",curve);col.objects.link(obj);obj.data.materials.append(MATS["wood"])
            box(col,"String",(0,0,.65),(.009,.009,1.3),"edge")
            box(col,"Grip",(.3,0,.65),(.08,.08,.22),"gold")
        export(col,"weapon", weapon_type=typ,tier=tier)

for name, roof in [("smithy", "shadow"),("tavern","rose"),("townhall","cloth")]:
    col=collection("building_"+name)
    box(col,"Foundation",(0,0,.12),(3,2.4,.24),"stone")
    box(col,"Body",(0,0,1.1),(2.8,2.2,1.8),"edge")
    for x in [-1.2,1.2]:box(col,"Timber",(x,-1.12,1.1),(.12,.08,1.85),"wood")
    for side in [-1,1]:
        obj=box(col,"Roof",(side*.75,0,2.25),(1.9,2.7,.18),roof);obj.rotation_euler.y=side*math.radians(28)
    box(col,"Door",(0,-1.12,.67),(.6,.08,1.2),"wood")
    for x in [-.85,.85]:box(col,"Window",(x,-1.15,1.2),(.45,.04,.45),"gold_light")
    if name=="smithy":box(col,"Chimney",(.9,.5,2.35),(.4,.4,1.1),"stone")
    if name=="tavern":box(col,"Sign",(-.65,-1.4,1.7),(.45,.08,.4),"wood")
    if name=="townhall":box(col,"Entrance_lintel",(0,-1.3,1.6),(1.1,.5,.15),"gold")
    export(col,"building", role=name, collision="Vorschau, vorhandene Dorfgebäude unverändert")

for state,flowers in [("resting",0),("helped",3),("celebration",7)]:
    col=collection("stone_rose_"+state)
    box(col,"Rose_plinth",(0,0,.1),(1.5,1.3,.2),"stone",.07)
    sphere(col,"Stone_rose",(0,0,.38),(.45,.4,.3),"edge")
    for i in range(flowers):
        angle=i/max(1,flowers)*math.tau
        sphere(col,"Blossom",(math.cos(angle)*.55,math.sin(angle)*.45,.35),(.15,.12,.1),"rose")
    export(col,"state",state=state,cosmetic=True)

# Ein vollständiger erster Krieger mit gemeinsamem Skelett und getrennten Aktionen.
col=collection("warrior_gold")
arm=bpy.data.armatures.new("Warrior_skeleton");rig=bpy.data.objects.new("Warrior",arm);col.objects.link(rig)
bpy.context.view_layer.objects.active=rig;rig.select_set(True);bpy.ops.object.mode_set(mode="EDIT")
bones={"root":((0,0,0),(0,0,.25),None),"hips":((0,0,.8),(0,0,1.05),"root"),
"torso":((0,0,1.05),(0,0,1.45),"hips"),"head":((0,0,1.45),(0,0,1.85),"torso"),
"arm_l":((-.34,0,1.4),(-.45,0,.93),"torso"),"arm_r":((.34,0,1.4),(.45,0,.93),"torso"),
"leg_l":((-.16,0,.85),(-.16,0,.18),"hips"),"leg_r":((.16,0,.85),(.16,0,.18),"hips")}
for name,(head,tail,parent) in bones.items():
    bone=arm.edit_bones.new(name);bone.head=head;bone.tail=tail
    if parent:bone.parent=arm.edit_bones[parent]
bpy.ops.object.mode_set(mode="OBJECT")
def skin(obj,bone):
    bpy.context.view_layer.objects.active=obj
    obj.select_set(True);bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    group=obj.vertex_groups.new(name=bone);group.add(list(range(len(obj.data.vertices))),1,"REPLACE")
    mod=obj.modifiers.new("Skeleton","ARMATURE");mod.object=rig;obj.parent=rig
skin(box(col,"Breastplate",(0,0,1.2),(.6,.33,.5),"gold",.04),"torso")
skin(box(col,"Belt",(0,-.01,.92),(.58,.36,.12),"dark"),"hips")
skin(box(col,"Helmet",(0,0,1.67),(.47,.4,.43),"gold",.04),"head")
skin(box(col,"Visor",(0,-.215,1.68),(.34,.025,.065),"dark"),"head")
skin(box(col,"Crest",(0,0,1.94),(.07,.34,.16),"cloth"),"head")
for side,bone in [(-1,"arm_l"),(1,"arm_r")]:
    skin(box(col,"Pauldron",(side*.36,0,1.4),(.27,.38,.23),"gold_light",.035),bone)
    skin(box(col,"Gauntlet",(side*.43,0,1.06),(.17,.2,.35),"gold",.025),bone)
for side,bone in [(-1,"leg_l"),(1,"leg_r")]:
    skin(box(col,"Greave",(side*.16,0,.52),(.23,.28,.56),"gold",.02),bone)
    skin(box(col,"Boot",(side*.16,-.08,.16),(.27,.43,.18),"dark",.02),bone)
skin(box(col,"Cape",(0,.22,1.1),(.5,.06,.67),"cloth"),"torso")
skin(box(col,"Sword_blade",(.48,-.08,.55),(.10,.04,.85),"steel",.01),"arm_r")
skin(box(col,"Sword_guard",(.48,-.08,.98),(.3,.08,.07),"gold"),"arm_r")
ANIMS={"idle":48,"walk":24,"run":18,"attack":20,"skill":30,"jump":32,"dodge":24,"hit":14,"defeated":40}
for name,duration in ANIMS.items():
    action=bpy.data.actions.new(name);rig.animation_data_create();rig.animation_data.action=action
    for f in range(1,duration+1,2):
        t=(f-1)/(duration-1);wave=math.sin(t*math.tau)
        for bone in rig.pose.bones:
            bone.rotation_mode="XYZ";bone.rotation_euler=(0,0,0);bone.location=(0,0,0)
        if name in ["walk","run"]:
            strength=.5 if name=="walk" else .8
            for limb,sign in [("leg_l",1),("leg_r",-1),("arm_l",-1),("arm_r",1)]:rig.pose.bones[limb].rotation_euler.x=wave*strength*sign
            rig.pose.bones["root"].location.z=abs(wave)*.035
        elif name=="idle":rig.pose.bones["torso"].rotation_euler.x=wave*.025
        elif name in ["attack","skill"]:
            pulse=math.sin(t*math.pi);rig.pose.bones["arm_r"].rotation_euler.x=-pulse*(2.1 if name=="attack" else 2.6)
            rig.pose.bones["torso"].rotation_euler.z=math.sin(t*math.tau)*.3
        elif name=="jump":rig.pose.bones["root"].location.z=math.sin(t*math.pi)*.7
        elif name=="dodge":rig.pose.bones["root"].rotation_euler.x=t*math.tau;rig.pose.bones["root"].location.z=math.sin(t*math.pi)*.4
        elif name=="hit":rig.pose.bones["torso"].rotation_euler.x=-math.sin(t*math.pi)*.35
        elif name=="defeated":rig.pose.bones["root"].rotation_euler.x=-min(t*2,1)*math.pi/2;rig.pose.bones["root"].location.z=.08
        for bone in rig.pose.bones:
            bone.keyframe_insert("rotation_euler",frame=f,group=bone.name);bone.keyframe_insert("location",frame=f,group=bone.name)
    rig.animation_data.action=None
    track=rig.animation_data.nla_tracks.new();track.name=name
    strip=track.strips.new(name,1,action)
for bone in rig.pose.bones:bone.rotation_euler=(0,0,0);bone.location=(0,0,0)
bpy.context.scene.render.fps=24
export(col,"character",animations=list(ANIMS),identity="Menschlicher goldener Krieger, isolierter Prototyp",ragdoll="Godot-Physikprototyp im Grafiklabor: components/quality_ragdoll.gd")

for material in list(bpy.data.materials):
    if material.users == 0:bpy.data.materials.remove(material)
bpy.context.preferences.filepaths.save_version=0
bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/"sonnenhain_quality_v1.blend"))
(OUT/"manifest.json").write_text(json.dumps({"schema":1,"generator":"tools/art_pipeline/build_blender_assets.py","assets":assets},ensure_ascii=False,indent=2),encoding="utf-8")
print("SONNENHAIN_ASSETS_OK",len(assets))
