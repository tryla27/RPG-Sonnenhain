"""Architektur-Set v2 für Sonnenhain: Mauern, Ecken, Endstücke, Torpfeiler
und Ruinenbauteile als echtes Mauerwerk.

Aufruf (Windows):
  blender --background --factory-startup --python tools/art_pipeline/build_architecture_v2.py

Jedes Teil wird exakt auf die Begrenzung des bisherigen Spielmodells gebracht
(FIT, Godot-Koordinaten: X rechts, Y oben, Z nach vorn). Dadurch bleiben
Atlasplatz, Projektion, Tiefensortierung und Kollision unverändert.
Seit 17.10. auch Felsen (Wiese, Asche, Küste, Dämmergrat).
Ausgabe: art/models/architecture_v2/<id>.glb, Vorschaubilder unter previews/.
Mit ONLY=<id,id> in der Umgebung werden nur diese Teile gebaut.
"""
import bpy
import bmesh
import math
import json
import random
import zlib
from pathlib import Path
from mathutils import Vector, Matrix

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "art/models/architecture_v2"
PREVIEW = OUT / "previews"
OUT.mkdir(parents=True, exist_ok=True)
PREVIEW.mkdir(parents=True, exist_ok=True)

# Begrenzung der bisherigen Spielmodelle (Godot): Position und Größe.
FIT = {
    "common-wall-01": ((-0.56, 0.01, -0.15), (1.11, 0.71, 0.30)),
    "common-wall-02": ((-0.15, 0.01, -0.56), (0.30, 0.71, 1.11)),
    "common-wall-03": ((-0.56, 0.01, -0.15), (1.12, 0.71, 1.12)),
    "common-wall-04": ((-0.57, 0.01, -0.15), (1.12, 0.71, 1.12)),
    "common-wall-05": ((-0.56, -0.01, -0.15), (1.01, 0.73, 0.45)),
    "common-wall-06": ((-0.95, 0.00, -0.22), (1.89, 1.42, 0.45)),
    "map03-obj01": ((-0.94, 0.00, -0.22), (1.54, 1.04, 0.51)),
    "map03-obj02": ((-0.23, 0.00, -0.22), (0.46, 1.19, 0.45)),
    "map03-obj03": ((-0.51, 0.00, -0.47), (0.67, 0.50, 0.85)),
    "map03-obj04": ((-0.67, 0.03, -0.17), (1.35, 1.20, 0.39)),
    "map03-obj05": ((-0.50, 0.00, -0.34), (1.00, 0.18, 0.68)),
    "map11-obj04": ((-0.22, 0.00, -0.22), (0.45, 1.19, 0.45)),
    "map12-obj04": ((-0.22, 0.00, -0.22), (0.45, 1.19, 0.45)),
    "map12-obj05": ((-0.67, 0.03, -0.17), (1.35, 1.20, 0.40)),
    # Felsen (17.10.): gleiche Begrenzung wie die bisherigen Felsgruppen.
    "map01-obj05": ((-0.60, -0.04, -0.50), (0.93, 0.67, 0.96)),
    "map05-obj05": ((-0.55, -0.04, -0.56), (0.87, 0.73, 0.96)),
    "map06-obj04": ((-0.58, -0.04, -0.54), (0.92, 0.80, 0.97)),
    "map11-obj03": ((-0.58, -0.06, -0.52), (1.16, 0.64, 0.98)),
}

# ---------------------------------------------------------------- Szene
bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene

def srgb(hex_color):
    return [int(hex_color[i:i + 2], 16) / 255 for i in (0, 2, 4)]

MATS = {}
def material(name, color, texture=None, roughness=.9, emission=None):
    mat = bpy.data.materials.new("SH2_" + name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    shader = nodes.get("Principled BSDF")
    rgb = srgb(color)
    shader.inputs["Base Color"].default_value = (*rgb, 1)
    shader.inputs["Roughness"].default_value = roughness
    if texture:
        path = ROOT / "art/textures/quality_v1" / texture
        if path.exists():
            # glTF übernimmt keine Farbmischknoten. Deshalb eine eigene Textur
            # backen: Struktur der Krita-Vorlage (entsättigt), Farbe vom Material.
            src = bpy.data.images.load(str(path))
            w, h = src.size
            pixels = list(src.pixels)
            out = [0.0] * len(pixels)
            lum = [pixels[i] * .3 + pixels[i + 1] * .59 + pixels[i + 2] * .11 for i in range(0, len(pixels), 4)]
            mean = sum(lum) / len(lum)
            for n, l in enumerate(lum):
                k = max(.55, min(1.35, 1 + (l - mean) * 2.2))
                i = n * 4
                out[i:i + 4] = [min(1, rgb[0] * k), min(1, rgb[1] * k), min(1, rgb[2] * k), 1.0]
            baked = bpy.data.images.new("SH2_" + name, w, h)
            baked.pixels = out
            baked.file_format = "PNG"
            baked.pack()
            tex = nodes.new("ShaderNodeTexImage")
            tex.image = baked
            tex.interpolation = "Closest"
            shader.inputs["Base Color"].default_value = (1, 1, 1, 1)
            mat.node_tree.links.new(tex.outputs["Color"], shader.inputs["Base Color"])
    if emission:
        shader.inputs["Emission Color"].default_value = (*srgb(emission), 1)
        shader.inputs["Emission Strength"].default_value = .4
    mat.diffuse_color = (*rgb, 1)
    MATS[name] = mat
    return mat

# Grau-beige Sonnenhain-Stein; helle Variante für den Himmelsgarten.
material("stone_a", "a7a89a", "stone_krita.png")
material("stone_b", "8f9085", "stone_krita.png")
material("stone_c", "b8b6a6", "stone_krita.png")
material("coping", "c9c6b4", "stone_krita.png")
material("flag_a", "9e9d8f", "stone_krita.png")
material("flag_b", "b0ae9e", "stone_krita.png")
material("mortar", "45473f")
material("moss", "7d9a58", "moss_krita.png")
material("moss_dark", "5d7543", "moss_krita.png")
material("pale_a", "efeae0", "stone_krita.png")
material("pale_b", "e0dccf", "stone_krita.png")
material("pale_trim", "f7f2e2", "stone_krita.png")
material("slate_a", "8a8794", "stone_krita.png")
material("slate_b", "77737f", "stone_krita.png")
# Felsen je Gebiet: Wiese moosgrau, Asche Basalt, Küste salzhell.
material("rock_meadow_a", "8b9286", "stone_krita.png")
material("rock_meadow_b", "767e72", "stone_krita.png")
material("basalt_a", "57505a", "stone_krita.png")
material("basalt_b", "6a626a", "stone_krita.png")
material("basalt_top", "7d7579", "stone_krita.png")
material("coast_a", "b8b29b", "stone_krita.png")
material("coast_b", "a19b85", "stone_krita.png")
material("salt", "e6e2d2")

def new_object(name, mesh):
    obj = bpy.data.objects.new(name, mesh)
    scene.collection.objects.link(obj)
    return obj

def block(parts, center, size, mat, rng, bevel=.022, tilt=.03, chip=.0):
    """Abgefaster Quader mit kleiner Unregelmäßigkeit; center/size in Blender-Koordinaten."""
    mesh = bpy.data.meshes.new("Stone")
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= size[0]; v.co.y *= size[1]; v.co.z *= size[2]
        # Leichte Verformung der Ecken: kein perfekter Würfel.
        v.co.x += rng.uniform(-1, 1) * size[0] * .04
        v.co.y += rng.uniform(-1, 1) * size[1] * .04
        v.co.z += rng.uniform(-1, 1) * size[2] * .05
        if chip and v.co.z > 0 and rng.random() < chip:
            v.co.z -= size[2] * rng.uniform(.15, .35)
    bmesh.ops.bevel(bm, geom=list(bm.edges), offset=min(bevel, min(size) * .3), segments=2, affect="EDGES", profile=.6)
    bm.to_mesh(mesh); bm.free()
    obj = new_object("Stone", mesh)
    obj.location = Vector(center)
    obj.rotation_euler = (rng.uniform(-tilt, tilt) * .4, rng.uniform(-tilt, tilt) * .4, rng.uniform(-tilt, tilt))
    obj.data.materials.append(MATS[mat])
    parts.append(obj)
    return obj

def blob(parts, center, scale, mat, rng, subdiv=2):
    mesh = bpy.data.meshes.new("Blob")
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=subdiv, radius=1.0)
    for v in bm.verts:
        v.co *= 1 + rng.uniform(-.18, .18)
        v.co.x *= scale[0]; v.co.y *= scale[1]; v.co.z *= scale[2]
    bm.to_mesh(mesh); bm.free()
    for poly in mesh.polygons: poly.use_smooth = False
    obj = new_object("Blob", mesh)
    obj.location = Vector(center)
    obj.data.materials.append(MATS[mat])
    parts.append(obj)
    return obj

STONES = ["stone_a", "stone_b", "stone_c"]

def masonry(parts, rng, length, height, depth, origin=(0, 0, 0), axis="x", step_down=0.0,
            stones=STONES, coping="coping", moss=True, broken=False):
    """Mauer entlang axis; origin = Mitte der Grundfläche. step_down senkt die
    Krone zum +Ende ab (Endstück). broken lässt Steine der obersten Lagen fehlen."""
    ox, oy, oz = origin
    courses = max(3, round(height / .17))
    course_h = (height - .08) / courses
    # Dunkler Fugenkern: Fugen wirken vertieft, auch zwischen versetzten Steinen.
    core_len = length - .04
    # Bei abgestufter oder gebrochener Krone darf der dunkle Kern nicht herausragen.
    core_h = height - .1 - step_down - (.2 if broken else 0)
    core = block(parts, (0, 0, 0), (core_len, depth * .78, core_h), "mortar", rng, bevel=.01, tilt=0)
    core.location = Vector((ox, oy, oz + core_h / 2))
    if axis == "y":
        core.rotation_euler = (0, 0, math.pi / 2)
    # Sockel: eine etwas breitere Lage.
    for course in range(courses):
        z = oz + .02 + course_h * (course + .5)
        x = -length / 2
        offset = (course % 2) * rng.uniform(.06, .12)
        x += offset * 0
        first = True
        while x < length / 2 - .02:
            w = rng.uniform(.17, .31) if not first or course % 2 == 0 else rng.uniform(.09, .16)
            first = False
            w = min(w, length / 2 - x)
            if w < .05: break
            cx = x + w / 2
            t = (cx + length / 2) / length
            top_limit = height - step_down * max(0.0, t - .35) / .65
            if z + course_h / 2 > top_limit + .02:
                x += w; continue
            if broken and course >= courses - 2 and rng.random() < .3:
                x += w; continue
            d = depth * (1.04 if course == 0 else rng.uniform(.9, 1.0))
            size = (w - .016, d, course_h - .014)
            pos = (ox + cx, oy + rng.uniform(-.008, .008), z) if axis == "x" else (ox + rng.uniform(-.008, .008), oy + cx, z)
            if axis == "y": size = (d, w - .016, course_h - .014)
            block(parts, pos, size, rng.choice(stones), rng, chip=.15 if course >= courses - 1 else 0)
            x += w
    # Abdecksteine mit Überstand.
    if coping:
        x = -length / 2
        while x < length / 2 - .02:
            w = min(rng.uniform(.24, .36), length / 2 - x)
            cx = x + w / 2
            t = (cx + length / 2) / length
            top = height - step_down * max(0.0, t - .35) / .65
            if not (broken and rng.random() < .35) and top > height * .7:
                size = (w - .012, depth * 1.12, .07)
                pos = (ox + cx, oy, oz + top - .02) if axis == "x" else (ox, oy + cx, oz + top - .02)
                if axis == "y": size = (depth * 1.12, w - .012, .07)
                block(parts, pos, size, coping, rng, bevel=.018, tilt=.04)
            x += w
    if moss:
        for _ in range(rng.randint(2, 4)):
            u = rng.uniform(-length * .45, length * .45)
            pos = (ox + u, oy - depth * .55, oz + rng.uniform(.03, .12)) if axis == "x" else (ox - depth * .55, oy + u, oz + rng.uniform(.03, .12))
            blob(parts, pos, (rng.uniform(.06, .12), .03, rng.uniform(.03, .06)), rng.choice(["moss", "moss_dark"]), rng, 1)
        for _ in range(rng.randint(1, 3)):
            u = rng.uniform(-length * .4, length * .4)
            pos = (ox + u, oy, oz + height + .015) if axis == "x" else (ox, oy + u, oz + height + .015)
            blob(parts, pos, (rng.uniform(.06, .1), depth * .5, .025), "moss", rng, 1)

def rampart(parts, rng, length, height, depth, step_down=0.0, broken=False, faces=("front", "back")):
    """Breiter Wehrgang entlang X in echten Spielproportionen: Plattenbelag oben,
    Mauerwerk an den Längsseiten, Randsteine, Moos in Fugen. Mitte der Grundfläche = 0."""
    def top_at(x):
        t = (x + length / 2) / length
        return height - step_down * max(0.0, t - .3) / .7
    core_h = height - .06 - (step_down if step_down else 0)
    core = block(parts, (0, 0, core_h / 2), (length - .02, depth - .1, core_h), "mortar", rng, bevel=.01, tilt=0)
    # Seitenflächen: Mauerwerk in Lagen, Steine ragen etwas über den Kern.
    courses = max(3, round(height / .16))
    ch = (height - .1) / courses
    for side in faces:
        y = -depth / 2 + .05 if side == "front" else depth / 2 - .05
        for course in range(courses):
            z = .02 + ch * (course + .5)
            x = -length / 2 + (ch * .9 if course % 2 else 0) * rng.uniform(.4, 1.0)
            if course % 2 and x + length / 2 > .05: block(parts, (-length / 2 + (x + length / 2) / 2, y, z), (x + length / 2 - .012, .12, ch - .014), rng.choice(STONES), rng)
            while x < length / 2 - .03:
                w = min(rng.uniform(.2, .36), length / 2 - x)
                cx = x + w / 2
                if z + ch / 2 <= top_at(cx) + .01 and not (broken and course >= courses - 1 and rng.random() < .4):
                    block(parts, (cx, y + rng.uniform(-.01, .01), z), (w - .016, .12, ch - .016), rng.choice(STONES), rng, chip=.2 if course == courses - 1 else 0)
                x += w
    # Plattenbelag oben in unregelmäßigen Reihen.
    rows = max(2, round((depth - .3) / .34))
    row_d = (depth - .3) / rows
    for r in range(rows):
        y = -depth / 2 + .15 + row_d * (r + .5)
        x = -length / 2 + (r % 2) * rng.uniform(.05, .15)
        while x < length / 2 - .03:
            w = min(rng.uniform(.26, .44), length / 2 - x)
            cx = x + w / 2
            if not (broken and rng.random() < .25):
                top = top_at(cx)
                block(parts, (cx, y + rng.uniform(-.015, .015), top - .03 + rng.uniform(-.008, .008)), (w - .026, row_d - .026, .06), rng.choice(["flag_a", "flag_b"]), rng, bevel=.012, tilt=.01)
                if rng.random() < .12:
                    blob(parts, (cx + w / 2, y, top + .003), (.035, row_d * .45, .012), "moss", rng, 1)
            x += w
    # Randsteine entlang beider Längskanten.
    for side in faces:
        y = -depth / 2 + .08 if side == "front" else depth / 2 - .08
        x = -length / 2
        while x < length / 2 - .03:
            w = min(rng.uniform(.24, .34), length / 2 - x)
            cx = x + w / 2
            if not (broken and rng.random() < .35):
                block(parts, (cx, y, top_at(cx) + .015), (w - .014, .17, .1), "coping", rng, bevel=.02, tilt=.02)
            x += w
        for _ in range(rng.randint(1, 3)):
            u = rng.uniform(-length * .42, length * .42)
            blob(parts, (u, y - (.07 if side == "front" else -.07), rng.uniform(.04, .14)), (rng.uniform(.06, .11), .025, rng.uniform(.025, .05)), rng.choice(["moss", "moss_dark"]), rng, 1)

def pillar(parts, rng, center, width, height, stones=STONES, trim="coping", fluted=False, broken=False):
    cx, cy, cz = center
    plinth_h = .1
    block(parts, (cx, cy, cz + plinth_h / 2), (width * 1.18, width * 1.18, plinth_h), trim, rng, bevel=.02, tilt=0)
    courses = max(3, round((height - .25) / .2))
    ch = (height - plinth_h - .12) / courses
    for c in range(courses):
        z = cz + plinth_h + ch * (c + .5)
        top = c == courses - 1
        block(parts, (cx, cy, z), (width, width, ch - .012), rng.choice(stones), rng, bevel=.025, tilt=.02, chip=.5 if (top and broken) else 0)
        if fluted:
            for k in range(4):
                a = k * math.pi / 2 + math.pi / 4
                block(parts, (cx + math.cos(a) * width * .5, cy + math.sin(a) * width * .5, z), (.03, .03, ch - .03), "mortar", rng, bevel=.008, tilt=0)
    if not broken:
        block(parts, (cx, cy, cz + height - .06), (width * 1.22, width * 1.22, .12), trim, rng, bevel=.025, tilt=.01)

def gate_post(parts, rng, cx, width, height):
    """Torpfeiler mit Sockel, Mauerwerk mit Fugen, gestuftem Kopf und Spitze."""
    block(parts, (cx, 0, .05), (width * 1.25, width * 1.25, .1), "coping", rng, bevel=.02, tilt=0)
    block(parts, (cx, 0, height * .45), (width * .86, width * .86, height * .8), "mortar", rng, bevel=.01, tilt=0)
    courses = 4
    ch = (height * .72) / courses
    for c in range(courses):
        z = .1 + ch * (c + .5)
        # Pro Lage zwei versetzte Steine je Seite: sichtbare Stoßfugen.
        split = rng.uniform(-.12, .12) * width + (width * .18 if c % 2 else -width * .18)
        for a, b in ((-width / 2, split), (split, width / 2)):
            w = b - a
            block(parts, (cx + (a + b) / 2, 0, z), (w - .018, width, ch - .02), rng.choice(STONES), rng, bevel=.018, tilt=.01)
    top = .1 + ch * courses
    block(parts, (cx, 0, top + .03), (width * 1.18, width * 1.18, .06), "coping", rng, bevel=.02, tilt=0)
    block(parts, (cx, 0, top + .085), (width * .9, width * .9, .05), "stone_c", rng, bevel=.015, tilt=0)
    # Pyramidenspitze.
    mesh = bpy.data.meshes.new("Finial")
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=4, radius1=width * .36, radius2=.0, depth=.16)
    bm.to_mesh(mesh); bm.free()
    obj = new_object("Finial", mesh)
    obj.location = (cx, 0, top + .19)
    obj.rotation_euler = (0, 0, math.pi / 4)
    obj.data.materials.append(MATS["coping"])
    parts.append(obj)
    blob(parts, (cx - width * .3, -width * .5, .14), (.08, .025, .05), "moss", rng, 1)

def arch(parts, rng, span, height, depth, stones, trim):
    leg_w = .26
    for side in (-1, 1):
        pillar(parts, rng, (side * (span / 2 - leg_w / 2), 0, 0), leg_w, height * .68, stones, trim)
    # Bogensteine entlang eines Halbkreises, mit fehlendem Schlussstein-Nachbar (beschädigt).
    radius = span / 2 - leg_w / 2
    base_z = height * .68
    count = 9
    for i in range(count):
        if i == 6: continue
        a = math.pi * (i + .5) / count
        x = -math.cos(a) * radius
        z = base_z + math.sin(a) * radius * .55
        stone = block(parts, (x, 0, z), (.17, depth, .16), rng.choice(stones), rng, bevel=.02, tilt=0)
        stone.rotation_euler = (0, -(a - math.pi / 2) * .9, 0)
    blob(parts, (span * .18, -depth * .3, base_z + radius * .5), (.08, .03, .05), "moss", rng, 1)

def boulder(parts, rng, center, size, mat, facets=1, flat_top=0.0, roughness=.22):
    """Kantiger Felsbrocken: grobe Ikosphäre, verschoben, unten flach, flach schattiert.
    flat_top schneidet eine Oberfläche ab (Moos oder Schichtplatte darauf)."""
    mesh = bpy.data.meshes.new("Boulder")
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=facets, radius=1.0)
    for v in bm.verts:
        v.co *= 1 + rng.uniform(-roughness, roughness)
        v.co.x *= size[0]; v.co.y *= size[1]; v.co.z *= size[2]
        if v.co.z < 0: v.co.z *= .25
        if flat_top and v.co.z > size[2] * (1 - flat_top): v.co.z = size[2] * (1 - flat_top) + (v.co.z - size[2] * (1 - flat_top)) * .15
    bm.to_mesh(mesh); bm.free()
    for poly in mesh.polygons: poly.use_smooth = False
    obj = new_object("Boulder", mesh)
    obj.location = Vector(center)
    obj.rotation_euler = (0, 0, rng.uniform(-math.pi, math.pi))
    obj.data.materials.append(MATS[mat])
    parts.append(obj)
    return obj

def meadow_rocks(parts, rng):
    # Drei Brocken: groß hinten, mittel vorn, klein seitlich; Moos auf den Kappen.
    boulder(parts, rng, (-.08, .12, .0), (.42, .36, .5), "rock_meadow_a", flat_top=.12)
    boulder(parts, rng, (.26, -.22, .0), (.28, .25, .3), "rock_meadow_b", flat_top=.1)
    boulder(parts, rng, (-.34, -.3, .0), (.17, .15, .17), "rock_meadow_a")
    blob(parts, (-.1, .1, .46), (.26, .2, .05), "moss", rng, 1)
    blob(parts, (.24, -.24, .28), (.15, .12, .035), "moss_dark", rng, 1)
    for i in range(4):
        blob(parts, (rng.uniform(-.45, .45), rng.uniform(-.45, -.3), .02), (.06, .05, .03), "moss", rng, 1)

def basalt_rocks(parts, rng):
    # Säulenbasalt: kantige Sechseckstümpfe unterschiedlicher Höhe, helle Kappen.
    columns = [(-.18, .1, .62), (.12, .14, .5), (.0, -.16, .38), (.3, -.12, .26), (-.36, -.12, .3)]
    for x, y, h in columns:
        mesh = bpy.data.meshes.new("Basalt")
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, cap_ends=True, segments=6, radius1=.15, radius2=.13, depth=h)
        for v in bm.verts: v.co.z += h * .5
        bm.to_mesh(mesh); bm.free()
        for poly in mesh.polygons: poly.use_smooth = False
        obj = new_object("Basalt", mesh)
        obj.location = Vector((x, y, 0)); obj.rotation_euler = (rng.uniform(-.05, .05), rng.uniform(-.05, .05), rng.uniform(0, math.pi))
        obj.data.materials.append(MATS[rng.choice(["basalt_a", "basalt_b"])])
        parts.append(obj)
        block(parts, (x, y, h + .015), (.24, .22, .035), "basalt_top", rng, bevel=.01, tilt=.08)
    for i in range(3):
        block(parts, (rng.uniform(-.4, .4), rng.uniform(-.42, -.3), .04), (.11, .09, .08), "basalt_b", rng, bevel=.015, tilt=.6, chip=.4)

def coast_rocks(parts, rng):
    # Rund gewaschener Fels mit flachen Schliffseiten und Salzrändern.
    boulder(parts, rng, (0, .05, 0), (.42, .38, .62), "coast_a", facets=2, roughness=.12)
    boulder(parts, rng, (.3, -.26, 0), (.2, .18, .22), "coast_b", facets=2, roughness=.14)
    for i in range(5):
        blob(parts, (rng.uniform(-.35, .35), rng.uniform(-.2, .2), rng.uniform(.25, .5)), (.07, .05, .012), "salt", rng, 1)

def slate_rocks(parts, rng):
    # Gestapelte Schieferplatten, jede leicht versetzt und gekippt.
    z = 0.0
    for layer in range(6):
        w = 1.0 - layer * .11 + rng.uniform(-.04, .04); d = .8 - layer * .07
        h = rng.uniform(.07, .11)
        block(parts, (rng.uniform(-.06, .06), rng.uniform(-.05, .05), z + h * .5), (w, d, h), rng.choice(["slate_a", "slate_b"]), rng, bevel=.015, tilt=.07, chip=.25)
        z += h
    for i in range(3):
        block(parts, (rng.uniform(-.5, .5), rng.uniform(-.45, -.3), .03), (.14, .1, .05), "slate_b", rng, bevel=.01, tilt=.5)

def rubble(parts, rng, stones):
    for i in range(9):
        s = rng.uniform(.12, .24)
        block(parts, (rng.uniform(-.25, .25), rng.uniform(-.3, .3), s * .45 + (.12 if i > 6 else 0)), (s * 1.2, s, s * .85), rng.choice(stones), rng, bevel=.03, tilt=.5, chip=.4)
    blob(parts, (0, 0, .05), (.25, .3, .04), "moss_dark", rng, 1)

def slab(parts, rng, stones):
    for i in range(3):
        block(parts, ((i - 1) * .34, rng.uniform(-.02, .02), .09), (.32, .68, .17), rng.choice(stones), rng, bevel=.03, tilt=.02, chip=.3)
    blob(parts, (.3, -.2, .18), (.1, .08, .02), "moss", rng, 1)

# ---------------------------------------------------------------- Bauteile
def build_piece(piece_id):
    rng = random.Random(zlib.crc32(piece_id.encode()))
    parts = []
    # Mauern: echte Spielproportionen (Tiefe = 92 px Wehrgang). fit() staucht auf die
    # alte Begrenzung, die Streckung der Spielzeile stellt die Form wieder her.
    if piece_id == "common-wall-01":
        rampart(parts, rng, 1.11, .71, 2.44)
    elif piece_id == "common-wall-02":
        rampart(parts, rng, 1.75, .71, 1.53)
        parts.append("ROTATE")
    elif piece_id in ("common-wall-03", "common-wall-04"):
        rampart(parts, rng, 1.62, .71, 1.62, faces=("front", "back"))
        for corner_x in (-.72, .72):
            for corner_y in (-.72, .72):
                block(parts, (corner_x, corner_y, .74), (.2, .2, .08), "coping", rng, bevel=.02, tilt=.02)
    elif piece_id == "common-wall-05":
        rampart(parts, rng, 1.6, .73, 3.0, step_down=.4, broken=True)
        for i in range(6):
            block(parts, (.62 + rng.uniform(-.08, .12), rng.uniform(-1.2, 1.2), .06), (.16, .14, .11), rng.choice(STONES), rng, bevel=.02, tilt=.6)
    elif piece_id == "common-wall-06":
        for side in (-1, 1):
            gate_post(parts, rng, side * .72, .44, .78)
    elif piece_id == "map03-obj01":
        masonry(parts, rng, 1.2, .78, .34, origin=(.12, 0, 0), axis="x", broken=True, step_down=.3)
        pillar(parts, rng, (-.7, 0, 0), .3, 1.04, broken=True)
    elif piece_id in ("map03-obj02", "map11-obj04", "map12-obj04"):
        stones = {"map03-obj02": STONES, "map11-obj04": ["slate_a", "slate_b"], "map12-obj04": ["pale_a", "pale_b"]}[piece_id]
        trim = {"map03-obj02": "coping", "map11-obj04": "slate_a", "map12-obj04": "pale_trim"}[piece_id]
        pillar(parts, rng, (0, 0, 0), .34, 1.19, stones, trim, fluted=True, broken=True)
    elif piece_id == "map03-obj03":
        rubble(parts, rng, STONES)
    elif piece_id in ("map03-obj04", "map12-obj05"):
        pale = piece_id == "map12-obj05"
        arch(parts, rng, 1.35, 1.2, .36, ["pale_a", "pale_b"] if pale else STONES, "pale_trim" if pale else "coping")
    elif piece_id == "map03-obj05":
        slab(parts, rng, STONES)
    elif piece_id == "map01-obj05":
        meadow_rocks(parts, rng)
    elif piece_id == "map05-obj05":
        basalt_rocks(parts, rng)
    elif piece_id == "map06-obj04":
        coast_rocks(parts, rng)
    elif piece_id == "map11-obj03":
        slate_rocks(parts, rng)
    return parts

def join(parts, name):
    rotate = "ROTATE" in parts
    parts = [p for p in parts if p != "ROTATE"]
    bpy.ops.object.select_all(action="DESELECT")
    for obj in parts: obj.select_set(True)
    bpy.context.view_layer.objects.active = parts[0]
    bpy.ops.object.join()
    obj = bpy.context.view_layer.objects.active
    obj.name = name
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    if rotate:
        # Senkrechte Mauer: Länge entlang der Spieltiefe.
        obj.rotation_euler = (0, 0, math.pi / 2)
        bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
    return obj

def fit(obj, piece_id):
    """Auf die Spielbegrenzung bringen. Godot (x,y,z) = Blender (x,z,-y)."""
    (gx, gy, gz), (sx, sy, sz) = FIT[piece_id]
    want_min = Vector((gx, -(gz + sz), gy))
    want_size = Vector((sx, sz, sy))
    coords = [obj.matrix_world @ v.co for v in obj.data.vertices]
    lo = Vector((min(c.x for c in coords), min(c.y for c in coords), min(c.z for c in coords)))
    hi = Vector((max(c.x for c in coords), max(c.y for c in coords), max(c.z for c in coords)))
    size = hi - lo
    scale = Vector((want_size.x / size.x, want_size.y / size.y, want_size.z / size.z))
    for v in obj.data.vertices:
        c = v.co - lo
        v.co = Vector((want_min.x + c.x * scale.x, want_min.y + c.y * scale.y, want_min.z + c.z * scale.z))
    obj.data.update()

def export(obj, piece_id):
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.export_scene.gltf(filepath=str(OUT / (piece_id + ".glb")), use_selection=True,
                              export_format="GLB", export_materials="EXPORT", export_yup=True,
                              export_apply=True, export_animations=False)

# ---------------------------------------------------------------- Vorschau
def preview(objects, path):
    cam_data = bpy.data.cameras.new("Cam"); cam_data.type = "ORTHO"; cam_data.ortho_scale = 2.6
    cam = bpy.data.objects.new("Cam", cam_data); scene.collection.objects.link(cam)
    # Spielneigung: 0,68 rad über dem Boden, Blick von vorn (Godot +Z = Blender -Y).
    pitch = .68
    cam.location = Vector((0, -math.cos(pitch) * 10, math.sin(pitch) * 10 + .5))
    cam.rotation_euler = (math.pi / 2 - pitch, 0, 0)
    scene.camera = cam
    sun_data = bpy.data.lights.new("Sun", "SUN"); sun_data.energy = 3.0
    sun = bpy.data.objects.new("Sun", sun_data); scene.collection.objects.link(sun)
    sun.rotation_euler = (math.radians(55), 0, math.radians(-30))
    world = bpy.data.worlds.new("World"); world.use_nodes = True
    world.node_tree.nodes["Background"].inputs[0].default_value = (.17, .24, .22, 1)
    world.node_tree.nodes["Background"].inputs[1].default_value = .9
    scene.world = world
    for engine in ("BLENDER_EEVEE", "BLENDER_EEVEE_NEXT", "BLENDER_WORKBENCH"):
        try:
            scene.render.engine = engine; break
        except TypeError:
            continue
    scene.render.resolution_x = 640; scene.render.resolution_y = 480
    scene.render.film_transparent = False
    scene.render.filepath = str(path)
    bpy.ops.render.render(write_still=True)
    for o in (cam, sun): bpy.data.objects.remove(o)

import os
ONLY = [p for p in os.environ.get("ONLY", "").split(",") if p]
manifest_path = OUT / "manifest.json"
old_manifest = json.loads(manifest_path.read_text(encoding="utf-8"))["assets"] if ONLY and manifest_path.exists() else []
manifest = [m for m in old_manifest if m["id"] not in ONLY]
for piece_id in FIT:
    if ONLY and piece_id not in ONLY: continue
    parts = build_piece(piece_id)
    obj = join(parts, piece_id.replace("-", "_"))
    fit(obj, piece_id)
    export(obj, piece_id)
    try:
        preview([obj], PREVIEW / (piece_id + ".png"))
    except Exception as error:  # Vorschau ist optional (z. B. ohne GPU)
        print("PREVIEW_FAILED", piece_id, error)
    manifest.append({"id": piece_id, "path": "art/models/architecture_v2/%s.glb" % piece_id,
                     "fit_position": FIT[piece_id][0], "fit_size": FIT[piece_id][1],
                     "triangles": sum(len(p.vertices) - 2 for p in obj.data.polygons)})
    obj.hide_render = True
    obj.hide_set(True)

manifest.sort(key=lambda m: list(FIT).index(m["id"]) if m["id"] in FIT else 999)
(OUT / "manifest.json").write_text(json.dumps({"schema": 1, "generator": "tools/art_pipeline/build_architecture_v2.py", "assets": manifest}, indent=1), encoding="utf-8")
if not ONLY: bpy.ops.wm.save_as_mainfile(filepath=str(ROOT / "art/source/blender/sonnenhain_architecture_v2.blend"))
print("ARCHITECTURE_V2_OK", len(manifest))
