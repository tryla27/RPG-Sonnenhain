from pathlib import Path
from PIL import Image, ImageDraw
import random, math
ROOT=Path(__file__).resolve().parents[1]
ART=ROOT/'art'; ART.mkdir(exist_ok=True)

def px(draw, x,y,w,h,c): draw.rectangle((x,y,x+w-1,y+h-1), fill=c)
def line(draw, pts, c, w=1): draw.line(pts, fill=c, width=w)
def outline_rect(draw, box, fill, outline): draw.rectangle(box, fill=fill, outline=outline)

# --- Terrain: 13 regions x 8 variants, 16x16 ---
region_palettes=[
 ('#4f7f52','#6ea45f','#8fc878','#365f42'), # village
 ('#56875a','#78ad68','#9dd681','#3a6548'), # meadows
 ('#425f4c','#5d7e59','#7fa56a','#293f36'), # mushroom forest
 ('#666b66','#858a7d','#a9aa96','#444a49'), # ruins
 ('#47787c','#659da0','#8ac8c5','#31565b'), # crystal
 ('#5c4945','#795854','#a06c59','#3d3437'), # ash
 ('#bca476','#d7bd87','#efdaa3','#8c765b'), # coast
 ('#55546c','#747292','#9c91b4','#393849'), # starfall
 ('#6d8580','#8ca6a0','#b1cbc3','#4c6663'), # mist
 ('#83733f','#aa9151','#d1b36c','#5a4d32'), # amber
 ('#50777a','#6c9c9e','#99c9c6','#36565c'), # spring
 ('#5e6078','#7b7e9a','#a5a7bd','#414356'), # ridge
 ('#82779b','#a294ba','#c8b8d8','#5c526f'), # sky garden
]
terrain=Image.new('RGBA',(16*16,7*16),(0,0,0,0))
for z,pal in enumerate(region_palettes):
    base,mid,hi,dark=pal
    for v in range(8):
        im=Image.new('RGBA',(16,16),base); d=ImageDraw.Draw(im); rng=random.Random(1000+z*97+v*13)
        # subtle 16px material pattern
        for _ in range(18):
            x,y=rng.randrange(16),rng.randrange(16)
            c=mid if rng.random()<0.55 else dark
            px(d,x,y,1+(rng.randrange(4)==0),1,c)
        for _ in range(5):
            x,y=rng.randrange(15),rng.randrange(15); px(d,x,y,2,1,hi)
        if z in (0,1,8,9,12):
            for _ in range(3):
                x,y=rng.randrange(2,14),rng.randrange(2,14); px(d,x,y,1,3,dark); px(d,x-1,y,3,1,mid)
        elif z==2:
            # roots/spores
            for _ in range(3):
                x,y=rng.randrange(2,13),rng.randrange(2,13); px(d,x,y,2,2,'#c88ca0' if v%2==0 else '#d6aa6d')
        elif z in (3,11):
            # stone cracks
            x=rng.randrange(3,12); y=rng.randrange(2,8); line(d,[(x,y),(x+2,y+3),(x+1,y+6)],dark,1)
        elif z in (4,7,10):
            x,y=rng.randrange(3,12),rng.randrange(3,12); px(d,x,y,2,4,hi); px(d,x+1,y-2,1,2,'#e7fbff')
        elif z==5:
            if v%3==0: line(d,[(1,12),(5,9),(9,10),(14,6)],'#d3794f',2); px(d,8,9,2,1,'#f6c36e')
        elif z==6:
            for x in range(-2,16,6): line(d,[(x,5+v%3),(x+4,5+v%3)],'#f5e5b8',1)
        terrain.paste(im,((z*8+v)%16*16,((z*8+v)//16)*16))
terrain.save(ART/'regions_16.png')

# --- Weapons 32x32: 3 families x 12 designs ---
weapons=Image.new('RGBA',(12*32,3*32),(0,0,0,0))
metal=['#cfdce0','#a9c4cf','#d6bf79','#9dd9e8']
for fam in range(3):
    for design in range(12):
        im=Image.new('RGBA',(32,32),(0,0,0,0)); d=ImageDraw.Draw(im); rng=random.Random(fam*100+design)
        accent=['#d9b15e','#83c4e3','#9bcf7b','#c896db'][design%4]
        if fam==0: # swords and axes alternating groups
            if design in (2,5,8,11):
                # axe
                line(d,[(7,27),(22,8)],'#6f4c33',4); line(d,[(8,27),(23,8)],'#b28456',2)
                head=metal[design%4]
                d.polygon([(18,5),(28,3),(27,12),(21,15),(18,10)],fill='#34434d')
                d.polygon([(20,6),(27,5),(26,11),(21,13)],fill=head)
                px(d,10,23,7,3,accent)
            else:
                line(d,[(6,27),(22,10)],'#5a3d3f',4); line(d,[(7,26),(22,10)],'#bd8a50',2)
                d.polygon([(20,11),(24,2),(29,1),(28,7),(23,13)],fill='#33434c')
                d.polygon([(22,10),(25,3),(27,3),(26,7),(23,12)],fill=metal[design%4])
                line(d,[(13,19),(19,25)],accent,3)
                if design>=6: px(d,21,8,2,2,'#f8efc8')
        elif fam==1: # Stäbe: verästelte Köpfe, gebundene Splitter und Runen
            tier=design//4; form=design%4
            line(d,[(6,29),(20,6)],'#332c34',6); line(d,[(7,28),(20,6)],'#60422e',4); line(d,[(8,27),(20,7)],'#b17d4d',1)
            for y in (22,26): line(d,[(8+(y%3),y),(13+(y%3),y-2)],'#dbbb72',2)
            if form==0: # Drachenkrone
                line(d,[(19,9),(16,2),(20,5),(23,0),(24,8)],'#344d46',4); line(d,[(20,8),(17,2)],'#8ca778',1)
                d.polygon([(17,8),(20,3),(24,8),(22,13),(18,12)],fill=accent); px(d,20,5,2,4,'#f4fbff')
            elif form==1: # Mondsichel und Stern
                d.arc((14,0,29,15),205,145,fill='#d7b76f',width=2); px(d,19,5,7,6,'#35424e'); px(d,21,4,4,5,accent); px(d,23,2,2,2,'#fff3c4')
            elif form==2: # Wurzelstab
                line(d,[(20,9),(14,1),(15,8),(10,5)],'#5d4538',4); line(d,[(20,9),(25,1),(24,8),(29,4)],'#79573b',4)
                d.polygon([(17,8),(20,3),(24,8),(22,13),(18,12)],fill=accent); px(d,20,5,2,4,'#fff2ba')
            else: # Runenlaterne
                line(d,[(14,7),(18,2),(25,2),(28,7),(24,12),(17,12),(14,7)],'#c7c7b5',2)
                px(d,18,5,7,5,accent); px(d,20,6,3,3,'#fff6c9')
            if tier>=1:
                line(d,[(13,17),(17,14)],accent,2); px(d,13,15,2,2,'#fff4cd')
            if tier>=2:
                px(d,7,23,3,3,accent); px(d,17,12,2,2,'#f7e9b8'); px(d,5,27,3,2,'#c6d8d1')
        else: # Fantasybögen und Armbrüste mit lesbarer Sehne und Recurveform
            if design in (3,7,11):
                line(d,[(5,17),(27,17)],'#3c3436',7); line(d,[(5,16),(27,16)],'#a36e46',4)
                line(d,[(16,6),(16,27)],'#493a36',5); line(d,[(16,8),(16,27)],'#c0905a',2)
                line(d,[(8,10),(8,24)],'#e1c98c',3); line(d,[(24,10),(24,24)],'#e1c98c',3); px(d,13,13,7,7,accent)
                d.polygon([(30,16),(25,13),(25,19)],fill='#f2ead6'); px(d,15,6,3,3,'#e4c477')
            else:
                curve=[(18,3),(23,5),(27,10),(28,16),(27,22),(23,27),(18,29)]
                d.line(curve,fill='#342d35',width=7); d.line(curve,fill='#6b4a34',width=4)
                line(d,[(19,5),(23,8),(26,13)],'#bd8b57',2); line(d,[(26,19),(23,24),(19,27)],'#bd8b57',2)
                line(d,[(18,3),(18,16),(18,29)],'#efe6cf',1)
                line(d,[(8,16),(28,16)],'#4a3734',4); line(d,[(8,16),(27,16)],accent,2)
                d.polygon([(30,16),(25,13),(25,19)],fill='#f2ead6')
                px(d,24,4,3,3,'#e7d5ab'); px(d,25,24,3,3,'#e7d5ab')
                if design%4==1:
                    px(d,21,12,5,7,'#344b5b'); px(d,22,13,3,5,accent); px(d,22,5,2,2,'#fff0ba')
                elif design%4==2:
                    px(d,24,9,4,3,'#576f87'); px(d,25,21,4,3,'#576f87'); px(d,22,14,4,4,accent)
        weapons.paste(im,(design*32,fam*32))
weapons.save(ART/'weapons_32.png')

# --- Character sheet 18 variants * 4 dirs rows, 4 frames columns ---
# combo index = ((race*2+gender)*3+class)
char=Image.new('RGBA',(4*32,18*4*32),(0,0,0,0))
skins=[('#efbd8d','#d8946c'),('#7fa866','#5e7e4d'),('#b4c2c9','#738792')]
class_cols=[('#607fa4','#c8ad6d'),('#4a5f9d','#bcae79'),('#4f785b','#c5a56e')]
for race in range(3):
  for gender in range(2):
    for cls in range(3):
      combo=((race*2+gender)*3+cls)
      skin,skin_dark=skins[race]; cloth,trim=class_cols[cls]
      for direction in range(4): # down,left,right,up
        for frame in range(4): # idle,walk1,walk2,attack
          im=Image.new('RGBA',(32,32),(0,0,0,0)); d=ImageDraw.Draw(im)
          step=(-2 if frame==1 else (2 if frame==2 else 0))
          # shadow omitted; game draws it
          # legs
          px(d,9,23+step,6,7,'#344451'); px(d,17,23-step,6,7,'#344451')
          px(d,8,29+step,7,3,'#4d3944'); px(d,17,29-step,7,3,'#4d3944')
          # torso silhouette
          if cls==0:
            px(d,5,11,22,15,'#344755'); px(d,7,12,18,12,cloth); px(d,3,12,7,9,'#9fb0b5'); px(d,22,12,7,9,'#9fb0b5'); px(d,5,13,4,5,'#d5ded7'); px(d,23,13,4,5,'#d5ded7'); px(d,8,22,16,3,'#65494c'); px(d,13,14,6,9,trim); px(d,14,16,4,5,'#dbe6df'); px(d,8,25,16,2,'#292f3b')
          elif cls==1:
            d.polygon([(8,10),(24,10),(29,29),(16,26),(3,29)],fill='#34426c'); px(d,10,11,12,11,cloth); px(d,4,12,6,12,cloth); px(d,22,12,6,12,cloth); line(d,[(8,15),(12,24),(16,26),(20,24),(24,15)],trim,2); px(d,13,17,6,6,'#d4c5e5'); px(d,14,18,4,4,'#91dce9'); px(d,7,23,5,3,'#293d75'); px(d,20,23,5,3,'#293d75')
          else:
            d.polygon([(6,10),(23,11),(28,25),(7,28)],fill='#314d3f'); px(d,9,12,14,11,cloth); line(d,[(7,13),(24,24)],'#c1a16f',3); line(d,[(8,14),(23,24)],'#ead3a1',1); px(d,4,10,4,17,'#694a39'); px(d,3,10,6,5,'#886246'); px(d,3,18,6,5,'#886246'); px(d,17,19,5,5,'#986d4a')
            for f in range(3): line(d,[(6+f,10),(3+f,4)],'#d9d1b4',1)
          # head/race
          if race==2:
            px(d,9,3,14,10,'#738792'); px(d,11,1,10,3,'#aebbc1'); px(d,11,6,3,2,'#80e8ec'); px(d,18,6,3,2,'#80e8ec'); px(d,15,9,2,2,'#3a4d56')
          else:
            px(d,10,3,12,10,skin_dark); px(d,11,4,10,9,skin)
            if race==1:
              px(d,7,7,4,4,skin); px(d,21,7,4,4,skin); px(d,8,4,3,3,'#4b3c32'); px(d,21,4,3,3,'#4b3c32')
            # Gesicht folgt der tatsächlichen Blickrichtung statt immer nach unten zu schauen.
            if direction==0:
              px(d,12,7,2,2,'#27343a'); px(d,18,7,2,2,'#27343a'); px(d,15,10,2,1,skin_dark)
            elif direction==1:
              px(d,10,7,2,2,'#27343a'); px(d,10,10,2,1,skin_dark); px(d,8,7,2,3,skin_dark)
            elif direction==2:
              px(d,20,7,2,2,'#27343a'); px(d,20,10,2,1,skin_dark); px(d,22,7,2,3,skin_dark)
            else:
              px(d,9,4,14,3,skin_dark); px(d,10,6,12,5,skin_dark)
          # Frisuren und Klassenkopfbedeckung erhalten eigene, erkennbare Silhouetten.
          if gender==1 and race != 2:
            hair_dark='#49353b'; hair='#68474b'; hair_hi='#a06a5e'
            if direction==0: # Pony und zwei unterschiedlich lange Seitensträhnen
              d.polygon([(7,7),(8,3),(12,0),(21,0),(25,4),(25,9),(21,7),(18,10),(15,7),(12,10),(10,7)],fill=hair_dark)
              px(d,7,8,4,10,hair); px(d,21,8,4,12,hair); px(d,10,4,11,2,hair_hi); px(d,9,7,3,2,hair_hi)
              for lock in range(3):
                px(d,6+lock%2,18+lock*2,4,2,hair_dark if lock%2==0 else hair)
                px(d,23-lock%2,18+lock*2,4,2,hair if lock%2==0 else hair_dark)
              px(d,5,18,2,2,'#c78d72'); px(d,25,20,2,2,'#c78d72')
            elif direction==3: # geflochtener Hinterkopf mit Strähnen
              d.polygon([(7,7),(8,3),(12,0),(21,0),(25,4),(25,14),(22,17),(19,13),(13,16),(9,13)],fill=hair_dark)
              px(d,9,4,12,3,hair); px(d,8,8,4,6,hair); px(d,20,8,4,7,hair); px(d,13,13,5,4,hair_hi); px(d,18,16,4,4,hair_dark)
            else: # Profil: kurzer Pony plus sichtbare geflochtene Seitenpartie
              facing_right=direction==2
              x0=17 if facing_right else 7
              d.polygon([(x0,6),(x0+2,2),(x0+7,0),(x0+13,3),(x0+14,8),(x0+10,7),(x0+7,10),(x0+4,7)],fill=hair_dark)
              px(d,x0+2,3,8,2,hair_hi); px(d,x0+8,8,4,8,hair); px(d,x0+9,15,3,3,hair_dark)
          # Klassenkopfbedeckung: der Krieger erhält einen echten geschichteten Helm.
          if cls==0:
            d.polygon([(7,10),(7,5),(10,2),(13,1),(16,3),(19,1),(23,3),(25,7),(25,12),(21,10),(20,7),(12,7),(11,11)],fill='#303b48')
            px(d,9,4,14,3,'#8999a1'); px(d,11,3,10,2,'#c1c9c4'); px(d,8,8,4,6,'#74868f'); px(d,20,8,4,6,'#74868f')
            px(d,12,8,8,2,'#27343e'); px(d,13,8,6,1,'#e4bf70'); px(d,14,2,4,3,'#d5ad65')
          elif cls==1:
            d.polygon([(5,9),(7,3),(16,0),(25,4),(28,12),(23,9),(21,6),(11,6),(9,11)],fill='#263f78'); px(d,8,4,14,3,'#5477bb'); px(d,11,8,10,2,'#8c79bd')
          else:
            d.polygon([(7,7),(9,2),(16,0),(24,4),(25,9),(20,7),(11,8)],fill='#294a3d'); px(d,10,4,11,2,'#64895f'); px(d,8,8,4,5,'#456447')
          # Ärmel, Handschuhe und freie Hand schwingen mit dem Schritt.
          stride=0 if frame==0 else (-2 if frame==1 else (2 if frame==2 else 0))
          arm_swing=(-2 if frame==1 else (2 if frame==2 else (3 if frame==3 else 0)))
          active_side=-1 if direction in (0,1) else 1
          if direction in (0,3):
            if active_side > 0:
              line(d,[(25,14),(27+arm_swing,20-stride)],'#344451',5); line(d,[(25,14),(27+arm_swing,19-stride)],trim,3); px(d,25+arm_swing,19-stride,4,4,'#51464a')
            else:
              line(d,[(7,14),(5-arm_swing,20+stride)],'#344451',5); line(d,[(7,14),(5-arm_swing,19+stride)],trim,3); px(d,3-arm_swing,19+stride,4,4,'#51464a')
          else:
            if active_side > 0:
              line(d,[(23,14),(27+arm_swing,19-stride)],trim,4); px(d,24+arm_swing,18-stride,4,4,'#51464a')
            else:
              line(d,[(9,14),(5+arm_swing,19+stride)],trim,4); px(d,4+arm_swing,18+stride,4,4,'#51464a')
          # Die Frisur liegt zuletzt über Schulter und Umhang, damit sie auch
          # unter Helm und Kapuze sichtbar bleibt und als Haarform lesbar ist.
          if gender==1 and race != 2:
            if direction==0:
              px(d,5,10,3,8,'#49353b'); px(d,6,13,2,6,'#a06a5e')
              px(d,24,9,3,9,'#49353b'); px(d,24,13,2,6,'#a06a5e')
              px(d,4,19,4,2,'#49353b'); px(d,24,21,4,2,'#49353b')
            elif direction==1:
              px(d,7,9,4,10,'#49353b'); px(d,8,13,3,5,'#a06a5e'); px(d,8,20,4,2,'#49353b')
            elif direction==2:
              px(d,21,9,4,10,'#49353b'); px(d,21,13,3,5,'#a06a5e'); px(d,20,20,4,2,'#49353b')
            else:
              px(d,6,10,4,8,'#49353b'); px(d,22,10,4,8,'#49353b'); px(d,7,17,3,5,'#a06a5e'); px(d,22,17,3,5,'#a06a5e')
          char.paste(im,(frame*32,(combo*4+direction)*32))
char.save(ART/'characters_32.png')

# --- Dorfhäuser: vier hochwertige, wiederverwendbare Pixelart-Fassaden ---
house_sheet=Image.new('RGBA',(4*96,80),(0,0,0,0))
house_palettes=[
    ('#754548','#a85c50','#d17a58','#ead9b7','#765545','#594239'),
    ('#46525d','#647684','#879aa0','#e6d7b4','#786146','#493e38'),
    ('#4c674b','#708456','#a1a16c','#e4d8bd','#795a43','#493e35'),
    ('#4b445e','#756486','#a17c91','#e9d8bd','#765744','#47383e'),
]
for design,palette in enumerate(house_palettes):
    roof_dark,roof,roof_hi,plaster,wood_dark,wood=palette
    im=Image.new('RGBA',(96,80),(0,0,0,0)); d=ImageDraw.Draw(im)
    # Steinsockel und warmer Fußschatten in derselben Pixelpalette.
    d.rectangle((5,72,91,78),fill='#423a37'); d.rectangle((8,69,88,75),fill='#79624d')
    d.rectangle((11,34,85,73),fill=plaster); d.rectangle((11,34,85,73),outline=wood_dark,width=2)
    d.rectangle((14,37,82,41),fill='#f4e8ca'); d.rectangle((14,67,82,70),fill='#c5ae88')
    # Überlappendes Schindeldach, dunkle Traufe und klarer Dachfirst.
    roof_points=[(4,31),(12,11),(27,5),(48,1),(69,5),(84,11),(92,31),(86,50),(10,50)]
    d.polygon(roof_points,fill=roof_dark)
    d.polygon([(8,30),(15,13),(29,8),(48,4),(67,8),(81,13),(88,30),(82,46),(14,46)],fill=roof)
    rng=random.Random(900+design)
    for row in range(6):
        y=12+row*5
        for col in range(9):
            x=13+col*9-(4 if row%2 else 0)
            if x<11 or x>82 or y>43: continue
            tile=roof_dark if rng.random()<0.32 else roof_hi
            d.rectangle((x,y,x+5,y+1),fill=tile)
            if (col+row+design)%4==0: px(d,x+2,y+2,2,1,roof_dark)
    d.line([(9,31),(87,31)],fill=roof_dark,width=3); d.line([(15,10),(48,2),(81,10)],fill=roof_hi,width=1)
    # Fachwerkpfosten und Querbalken rahmen die hellen Lehmfelder.
    for x in (13,47,83):
        d.rectangle((x,34,x+3,70),fill=wood_dark); d.line([(x+1,36),(x+1,66)],fill='#b58d62',width=1)
    d.line([(14,44),(82,44)],fill=wood_dark,width=3); d.line([(14,65),(82,65)],fill=wood_dark,width=3)
    if design in (0,3):
        d.line([(16,47),(43,63)],fill=wood,width=2); d.line([(80,47),(52,63)],fill=wood,width=2)
    # Bleiglasfenster mit Läden, Licht und Blumenkästen.
    for x in (22,65):
        d.rectangle((x-2,48,x+12,63),fill=wood_dark)
        d.rectangle((x,49,x+10,60),fill='#5d8a91' if design!=2 else '#80a7a0')
        d.rectangle((x+1,50,x+4,58),fill='#ffdf9b'); d.rectangle((x+6,50,x+9,58),fill='#d5e2c9')
        d.line([(x+5,49),(x+5,60)],fill=wood,width=1); d.line([(x,55),(x+10,55)],fill=wood,width=1)
        d.rectangle((x-2,47,x+12,49),fill='#d3b482'); d.rectangle((x-3,61,x+13,64),fill=wood_dark)
        d.rectangle((x-1,63,x+11,66),fill='#9b704e')
        for leaf in range(3): px(d,x+1+leaf*3,61-(leaf%2),1,3,'#75965b')
    # Tür mit sichtbarem Rahmen, Stufen und Messingknauf.
    d.rectangle((39,49,56,74),fill=wood_dark); d.rectangle((42,52,53,73),fill='#8d6246')
    d.rectangle((44,54,51,57),fill='#b28459'); d.line([(46,60),(46,70)],fill='#694938',width=1)
    px(d,51,63,2,2,'#f1cf79'); d.rectangle((36,72,59,75),fill='#c9ad7e')
    # Hauszeichen, Zierlaterne und materialspezifische Details.
    if design==0:
        d.rectangle((69,15,80,28),fill='#62605d'); d.rectangle((72,13,78,16),fill='#c9b691')
    elif design==1:
        d.rectangle((16,18,22,29),fill='#80766b'); d.rectangle((18,15,21,19),fill='#c4b499')
    elif design==2:
        d.rectangle((72,16,81,25),fill='#725d49'); d.rectangle((74,13,79,17),fill='#d3b07a')
    else:
        d.rectangle((16,18,22,29),fill='#725d49'); d.rectangle((18,15,21,19),fill='#d8bd85')
    for nail in (18,46,79): px(d,nail,34,2,2,'#e2c278')
    house_sheet.alpha_composite(im,(design*96,0))
house_sheet.resize((4*192,160),Image.Resampling.NEAREST).save(ART/'houses_192.png')

# --- Enemies: 27 rows x 4 animation frames, 32x32 ---
enemy_names=['slime','beetle','mushroom','wolf','stone_golem','beholder','crystal_crab','crystal_spirit','ash_runner','lava_golem','sand_crab','water_spirit','tower_guard','crystal_golem','ash_lord','star_shadow','rift_guard','mist_stag','wisp','resin_beast','root_witch','spring_crawler','pearl_spirit','ridge_griffin','shadow_knight','sky_moth','star_guardian']
enemy_cols=['#73cb88','#e998b6','#e3ad77','#789983','#bea78c','#a8b9e9','#8de0eb','#c6a6f0','#dc835e','#a75c52','#e9a67e','#76bfd2','#8c9b9e','#9bc6dd','#d28467','#b5a3d9','#dfac91','#b9cfcc','#a6d8da','#caac5a','#a0b379','#8fbfc6','#c5e0e4','#a7a0b8','#77748f','#d9c6e8','#e4d4b5']
enemy_sheet=Image.new('RGBA',(4*32,27*32),(0,0,0,0))
for idx,(name,col) in enumerate(zip(enemy_names,enemy_cols)):
  for frame in range(4):
    im=Image.new('RGBA',(32,32),(0,0,0,0)); d=ImageDraw.Draw(im); bob=(-1 if frame==1 else (1 if frame==2 else 0)); dark='#273238'; hi='#f4edc9'
    if name=='slime':
      d.ellipse((5,9+bob,27,29),fill='#4c8b61'); d.ellipse((6,6+bob,26,25),fill=col); px(d,9,10+bob,5,4,'#a7e1af'); px(d,11,16+bob,3,4,dark); px(d,19,16+bob,3,4,dark); px(d,15,21+bob,4,2,'#ffe0a0')
    elif name=='beetle':
      for y in (11,17,23): line(d,[(9,y),(3,y-3+bob)],'#55444e',2); line(d,[(23,y),(29,y-3-bob)],'#55444e',2)
      d.ellipse((7,7+bob,25,28),fill=col); line(d,[(16,8),(16,27)],'#754d67',2); px(d,11,10,3,3,hi); px(d,18,10,3,3,hi)
    elif name=='mushroom':
      px(d,11,13,10,15,'#e7d9b5'); d.polygon([(4,13),(8,5+bob),(16,2+bob),(24,5+bob),(28,13)],fill='#bd7882'); px(d,10,8+bob,3,3,'#fff2d2'); px(d,19,6+bob,3,3,'#fff2d2'); px(d,13,17,2,3,dark); px(d,18,17,2,3,dark)
    elif name=='wolf':
      d.polygon([(4,18),(7,9),(12,4),(16,9),(21,4),(25,10),(28,20),(22,26),(9,26)],fill=col); px(d,9,13,3,3,hi); px(d,20,13,3,3,hi); px(d,14,19,5,4,'#c6bbaa'); line(d,[(6,20),(1,16+bob)],col,4)
    elif 'golem' in name or name in ('tower_guard','rift_guard','ash_lord','star_guardian'):
      base=col; px(d,8,6+bob,16,9,base); px(d,5,14+bob,22,12,base if name!='lava_golem' else '#5b484b'); px(d,2,15+bob,6,10,base); px(d,24,15+bob,6,10,base); px(d,8,25,6,6,'#55515a'); px(d,18,25,6,6,'#55515a')
      eye='#ffe38a' if name in ('lava_golem','ash_lord') else ('#b5f4ff' if name=='crystal_golem' else '#f6e0a2'); px(d,11,9+bob,3,2,eye); px(d,18,9+bob,3,2,eye)
      if name=='lava_golem': line(d,[(8,18),(14,22),(20,16),(25,21)],'#f2a45e',2)
      elif name=='crystal_golem': d.polygon([(16,10),(21,18),(16,25),(11,18)],fill='#d9fbff')
      elif name=='tower_guard': px(d,3,12,5,15,'#59666a'); line(d,[(25,25),(28,4)],'#e8dfc2',3)
      elif name=='ash_lord': d.polygon([(7,8),(5,1),(12,6),(20,6),(27,1),(25,8)],fill='#e09a68'); line(d,[(11,17),(21,24)],'#ffc06e',2)
      elif name=='star_guardian': px(d,10,3,12,4,'#f2dfb3'); px(d,14,17,4,5,'#fff4c8')
    elif name=='beholder':
      d.ellipse((5,7+bob,27,28+bob),fill='#7788bd'); d.ellipse((9,11+bob,23,24+bob),fill='#efe4cf'); d.ellipse((13,14+bob,19,21+bob),fill='#40527a'); px(d,15,16+bob,2,3,dark)
      for a in (-2.5,-1.8,-1.1,-0.4):
        x=16+int(math.cos(a)*11); y=15+int(math.sin(a)*11)+bob; line(d,[(16,12+bob),(x,y)],'#8b99c7',2); d.ellipse((x-2,y-2,x+2,y+2),fill='#e8d8bb')
    elif 'crab' in name or name=='spring_crawler':
      d.ellipse((7,10+bob,25,27+bob),fill=col); px(d,9,11+bob,14,5,'#d9edf0' if 'crystal' in name else '#f0d0a0');
      for y in (14,20,25): line(d,[(8,y),(2,y-3+bob)],col,2); line(d,[(24,y),(30,y-3-bob)],col,2)
      px(d,11,15+bob,2,2,dark); px(d,19,15+bob,2,2,dark)
    elif name in ('crystal_spirit','water_spirit','star_shadow','wisp','pearl_spirit'):
      spirit=col; d.polygon([(16,3+bob),(24,10+bob),(26,22),(19,28),(16,24),(12,29),(6,22),(8,9+bob)],fill=spirit); px(d,11,12+bob,3,3,hi); px(d,19,12+bob,3,3,hi)
      if name=='crystal_spirit': d.polygon([(16,2+bob),(20,11),(16,17),(12,11)],fill='#e7d5fa')
      if name=='water_spirit': line(d,[(7,21),(3,24+bob)],'#d1f7f0',2); line(d,[(25,21),(29,24-bob)],'#d1f7f0',2)
      if name=='star_shadow': px(d,15,5+bob,3,3,'#fff1c3')
      if name=='wisp': d.ellipse((9,8+bob,23,22+bob),fill='#d7ffff'); px(d,14,12+bob,4,4,col)
      if name=='pearl_spirit': px(d,14,17,5,5,'#fff7ed')
    elif name=='ash_runner':
      d.polygon([(7,24),(9,10+bob),(13,4),(16,10),(22,4),(24,11),(26,24),(17,28)],fill=col); px(d,11,13,3,3,'#ffe388'); px(d,19,13,3,3,'#ffe388'); line(d,[(8,24),(3,28+bob)],'#f7ab6a',2)
    elif name in ('mist_stag','resin_beast','ridge_griffin'):
      d.polygon([(5,20),(8,10+bob),(14,5),(22,8),(27,18),(23,26),(9,26)],fill=col); px(d,11,12+bob,3,3,hi); px(d,20,12+bob,3,3,hi)
      if name=='mist_stag': line(d,[(12,8),(7,1)],col,2); line(d,[(20,8),(25,1)],col,2)
      if name=='resin_beast': px(d,14,16,5,6,'#e2c66c')
      if name=='ridge_griffin': d.polygon([(7,14),(1,9),(5,20)],fill='#c8c0d0'); d.polygon([(25,14),(31,9),(27,20)],fill='#c8c0d0')
    elif name=='root_witch':
      d.polygon([(7,27),(9,9+bob),(16,3+bob),(23,9+bob),(25,27)],fill='#6d724c'); d.polygon([(5,12),(16,1+bob),(27,12)],fill=col); px(d,12,13,3,3,'#e9f0c9'); px(d,18,13,3,3,'#e9f0c9'); line(d,[(9,22),(3,30)],'#70563b',2); line(d,[(23,22),(29,30)],'#70563b',2)
    elif name=='shadow_knight':
      px(d,8,6+bob,16,9,'#4f4d63'); px(d,7,14+bob,18,14,col); px(d,10,9+bob,4,2,'#c7b9ff'); px(d,18,9+bob,4,2,'#c7b9ff'); line(d,[(25,25),(29,5)],'#bfc5c5',3); px(d,4,15,4,11,'#64627a')
    elif name=='sky_moth':
      d.polygon([(15,12+bob),(5,5),(2,16),(12,22)],fill='#c7b3df'); d.polygon([(17,12+bob),(27,5),(30,16),(20,22)],fill=col); px(d,14,8+bob,4,17,'#6e617d'); px(d,15,11+bob,2,2,hi)
    else:
      d.ellipse((7,7+bob,25,27+bob),fill=col); px(d,11,12+bob,3,3,hi); px(d,19,12+bob,3,3,hi)
    # hurt frame white accent / attack frame details
    if frame==3:
      px(d,14,1,4,3,'#fff2b3')
    enemy_sheet.paste(im,(frame*32,idx*32))
enemy_sheet.save(ART/'enemies_32.png')

# --- Skill icons 16x16, 34 icons ---
skills=Image.new('RGBA',(16*16,3*16),(0,0,0,0))
for i in range(34):
    im=Image.new('RGBA',(16,16),(0,0,0,0)); d=ImageDraw.Draw(im)
    cls=0 if i<16 else (1 if i<25 else 2)
    base=['#d8b56c','#8eb9e3','#8fb875'][cls]; accent=['#fff0b2','#d7f5ff','#e7e0ae'][cls]
    outline='#24343c'
    if cls==0:
        if i%4==0: line(d,[(3,12),(12,3)],outline,4); line(d,[(4,11),(12,3)],base,2)
        elif i%4==1: d.arc((2,2,13,13),20,340,fill=base,width=3); px(d,6,5,4,6,accent)
        elif i%4==2: d.polygon([(8,1),(14,8),(8,14),(2,8)],fill=base); px(d,7,4,2,7,accent)
        else: line(d,[(1,8),(15,8)],base,3); px(d,6,3,4,10,accent)
    elif cls==1:
        mode=i%5
        if mode==0: d.ellipse((3,3,13,13),fill='#e77b4e'); px(d,6,2,4,5,'#ffd17a')
        elif mode==1: d.polygon([(8,1),(14,7),(8,15),(2,7)],fill='#9ee7f0'); line(d,[(8,3),(8,13)],accent,2)
        elif mode==2: line(d,[(3,14),(8,8),(5,8),(12,2)],'#ffe276',2); px(d,10,1,3,3,accent)
        elif mode==3: d.arc((2,2,14,14),0,300,fill='#c7a7ed',width=3); px(d,7,7,3,3,accent)
        else: d.ellipse((2,2,14,14),outline='#a9ecce',width=2); px(d,7,3,3,10,'#e7fff4')
    else:
        mode=i%4
        line(d,[(2,8),(13,8)],base,2); d.polygon([(14,8),(10,5),(10,11)],fill=accent)
        if mode==1: line(d,[(3,4),(13,8)],base,2); line(d,[(3,12),(13,8)],base,2)
        elif mode==2: px(d,4,5,3,3,'#9ddd76'); px(d,4,9,3,3,'#9ddd76')
        elif mode==3: d.arc((1,1,15,15),0,330,fill='#d9cfa0',width=2)
    skills.paste(im,((i%16)*16,(i//16)*16))
skills.save(ART/'skills_16.png')

print('generated:', ', '.join(p.name for p in [ART/'regions_16.png',ART/'weapons_32.png',ART/'characters_32.png',ART/'enemies_32.png',ART/'skills_16.png']))

# --- NPCs: 12 role/name rows x 4 subtle idle frames ---
npc_sheet=Image.new('RGBA',(4*32,12*32),(0,0,0,0))
role_defs=[
 ('mira','#8d67ad','#d3b36f'),('borin','#667fae','#b7c5ca'),('liora','#5da58e','#d5cf9a'),
 ('smith','#9b6658','#6f7378'),('merchant','#78945f','#d2b17e'),('alchemy','#b28b56','#776894'),
 ('healer','#d3ae84','#f0e6d4'),('arena','#9179a8','#d6b86f'),('innkeeper','#9b765c','#eee0be'),
 ('rescued','#a87568','#e8c090'),('event','#7f91a8','#d4c4a0'),('generic','#7a8a78','#d8c3a0')]
for row,(role,cloth,accent) in enumerate(role_defs):
    for frame in range(4):
        im=Image.new('RGBA',(32,32),(0,0,0,0)); d=ImageDraw.Draw(im)
        bob=(-1 if frame==1 else (1 if frame==2 else 0))
        # legs/boots
        px(d,9,23,6,7,'#403943'); px(d,17,23,6,7,'#403943')
        # robe or tunic
        if role in ('mira','liora','alchemy','healer','arena'):
            d.polygon([(7,11+bob),(25,11+bob),(28,28),(16,25),(4,28)],fill=cloth)
        else:
            px(d,7,11+bob,18,15,cloth)
        # head
        px(d,10,3+bob,12,10,'#d4936c'); px(d,11,4+bob,10,9,'#efbd8d')
        px(d,12,7+bob,2,2,'#2d3940'); px(d,18,7+bob,2,2,'#2d3940')
        # role silhouettes
        if role=='mira':
            px(d,8,2+bob,16,4,'#724a75'); px(d,14,15,4,7,accent)
        elif role=='borin':
            px(d,7,2+bob,18,5,'#6d7883'); px(d,4,12+bob,5,9,'#acbbc1'); px(d,23,12+bob,5,9,'#acbbc1'); line(d,[(25,24),(29,5+bob)],'#d9d9c8',2)
        elif role=='liora':
            d.polygon([(7,5+bob),(16,0+bob),(25,5+bob)],fill='#4e7d76'); px(d,22,13+bob,4,10,accent)
        elif role=='smith':
            px(d,5,10+bob,22,5,'#6f7378'); px(d,10,15+bob,12,11,'#4c3d37'); line(d,[(24,24),(29,8+bob)],'#c7d0d0',3)
        elif role=='merchant':
            px(d,7,1+bob,18,4,'#98775c'); px(d,10,-1+bob,12,4,'#b4996d'); line(d,[(6,14),(25,24)],accent,2)
        elif role=='alchemy':
            d.polygon([(6,6+bob),(16,0+bob),(26,6+bob)],fill='#524a72'); px(d,5,5+bob,22,4,'#786a93'); px(d,22,18,5,7,'#8fe5c6')
        elif role=='healer':
            px(d,6,10+bob,20,4,'#f6e8d2'); px(d,14,13+bob,4,11,'#fff4dd'); px(d,9,17+bob,14,4,'#fff4dd')
        elif role=='arena':
            px(d,7,1+bob,18,5,'#5c526c'); px(d,14,-2+bob,4,4,'#e2bf7e'); line(d,[(26,28),(27,4+bob)],'#d9c6a0',2)
        elif role=='innkeeper':
            px(d,8,13+bob,16,13,'#eee0be'); px(d,7,1+bob,18,4,'#633f36'); px(d,10,4+bob,4,9,'#704438'); px(d,18,4+bob,4,9,'#704438')
        elif role=='rescued':
            px(d,7,1+bob,18,4,'#854b42'); px(d,14,16+bob,4,9,accent)
        elif role=='event':
            px(d,6,1+bob,20,4,'#5e6e80'); px(d,5,14+bob,5,10,accent)
        # tiny frame variation gesture
        if frame==3: line(d,[(24,16+bob),(29,11+bob)],'#efbd8d',2)
        npc_sheet.paste(im,(frame*32,row*32))
npc_sheet.save(ART/'npcs_32.png')
print('generated:', ART/'npcs_32.png')

# --- VFX: 8 effect families x 4 frames, 16x16 ---
vfx=Image.new('RGBA',(4*16,8*16),(0,0,0,0))
for kind in range(8):
    for frame in range(4):
        im=Image.new('RGBA',(16,16),(0,0,0,0)); d=ImageDraw.Draw(im)
        if kind==0: # fire
            d.polygon([(8,1+frame%2),(12,6),(10,7),(14,12),(9,15),(3,12),(5,7)],fill='#ee7e43'); d.polygon([(8,5),(10,9),(8,13),(5,10)],fill='#ffd57a')
        elif kind==1: # ice
            d.polygon([(8,0),(11,5),(16,8),(11,10),(8,16),(5,10),(0,8),(5,5)],fill='#8fddec'); px(d,7,3,2,10,'#e8fdff')
        elif kind==2: # lightning
            d.polygon([(8,0),(4,8),(8,7),(5,16),(13,6),(9,7),(12,0)],fill='#ffe36f'); px(d,8,2,2,4,'#fffbd5')
        elif kind==3: # poison
            d.ellipse((2+frame%2,4,13,14),fill='#8bcf62'); d.ellipse((5,1,10,7),fill='#c4ef8f'); px(d,6,7,2,2,'#efffc4')
        elif kind==4: # arcane
            d.arc((1,1,14,14),20+frame*20,300+frame*20,fill='#bd9aeb',width=3); px(d,6,6,4,4,'#f2e7ff')
        elif kind==5: # arrow
            line(d,[(1,12),(12,4)],'#c4a06b',2); d.polygon([(14,2),(9,3),(12,7)],fill='#f5edd8'); line(d,[(3,11),(1,8)],'#d7c291',1)
        elif kind==6: # impact
            for a in range(0,360,45):
                rad=math.radians(a+frame*8); x=8+int(math.cos(rad)*(4+frame)); y=8+int(math.sin(rad)*(4+frame)); px(d,x,y,2,2,'#f1d58a')
            px(d,6,6,4,4,'#fff4cc')
        else: # heal/shield
            d.ellipse((2,2,13,13),outline='#95e7ce',width=2); px(d,7,3,2,10,'#eafff6'); px(d,3,7,10,2,'#eafff6')
        vfx.paste(im,(frame*16,kind*16))
vfx.save(ART/'vfx_16.png')

# --- Structures: compact 16x16 modular wall/material tiles ---
structures=Image.new('RGBA',(8*16,16),(0,0,0,0))
materials=[('#64736f','#96a098','#3e4a4e'),('#6d7773','#a8ada4','#454f50'),('#546c69','#88aaa0','#34484a'),('#735447','#a87c5c','#4d3932'),('#547d82','#8fc7c6','#355b60'),('#694c48','#9f6858','#423638'),('#b18e66','#d5b185','#775b46'),('#77756f','#aaa594','#4e504d')]
for i,(mid,hi,dark) in enumerate(materials):
    im=Image.new('RGBA',(16,16),dark); d=ImageDraw.Draw(im)
    for y in (1,7,13):
        shift=0 if y!=7 else -4
        for x in range(shift,16,8):
            d.rectangle((max(0,x+1),y,min(15,x+7),min(15,y+5)),fill=mid)
            if x+2<16: px(d,max(0,x+2),y+1,3,1,hi)
    structures.paste(im,(i*16,0))
structures.save(ART/'structures_16.png')
print('generated:', ART/'vfx_16.png', ART/'structures_16.png')
