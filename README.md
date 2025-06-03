# Brainrot Survival

Godot 4 3D game where you are fighting waves of enemies to then defeat the final
boss. These enemies from the game are based off the Italian Brainrot and this
game was made as a school project in around 2 weeks.

Brainrot characters:

- Tung Tung Tunb Sahur
- Chimpanzini Bananini
- Br Br Patapim

# How to try it out

Clone this repo, then download the [Godot](https://godotengine.org/) game engine
for your platform. Then open it and import the project by clicking "import"
button. After importing you should click F5 to launch the game.

## Giocatore

- Healt: 100
- Damage: 40
- Speed: 7
- AttackCoolDownTimer: 0.5s Speed:

## Nemici

Il gioco ha 3 tipi di nemici:

- EnemySmall: il piu piccolo, il piu scarso e il piu svelto, ma prevalgono nelle
  onde di quantita
- EnemyMedium: piu grande di EnemySmall
- EnemyBig: Il boss finale

### Struttura del nemico

```
CharacterBody3D (tipo di nemico)
├── AttackCoolDownTimer (Timer)
├── MoveFrequencyTimer (Timer che definisce quanto il mob deve aspettare per muoversi, ottimo per rendere i nemici piu forti piu ritardati, dando a te la possibilita di evaderli)
├── CollisionShape3D
└── EnemyModel (modello 3D del modello)
└── HurtSound (suono di danno come una scimmia)
└── EnemySound (souno normale, tipo una scimmia)
```

| Caratteristiche | EnemySmall | EnemyMedium | EnemyBig |
| --------------- | ---------- | ----------- | -------- |
| Health          | 70         | 220         | 410      |
| Damage          | 7          | 25          | 45       |
| Speed           | 6          | 5           | 4        |
| AttackCoolDown  | 1          | 2           | 4        |

# Credits

Amazing game ready 3D models for EnemySmall and EnemyBig are from
https://sketchfab.com/alex.cgwarrior, without him i would't be able to make this
game

"Tung Sahur Game 3D model NO AI Free Download" (https://skfb.ly/pwQRS) by Alex
CGW is licensed under Creative Commons Attribution
(http://creativecommons.org/licenses/by/4.0/).

"Brr Brr Patapim Game Ready 3D model FREE" (https://skfb.ly/pwG8D) by Alex CGW
is licensed under Creative Commons Attribution
(http://creativecommons.org/licenses/by/4.0/).

"Udin Din Din Dun Madin Din Din Dun Game Model" (https://skfb.ly/pwNCX) by Alex
CGW is licensed under Creative Commons Attribution
(http://creativecommons.org/licenses/by/4.0/).

"Low Poly Stylized Mushroom" (https://skfb.ly/o7VOY) by Natural_Disbuster is
licensed under Creative Commons Attribution
(http://creativecommons.org/licenses/by/4.0/).

EnemyMedium was taken from
https://sketchfab.com/3d-models/chimpanzini-bananini-c9a2c49871b242c7b1a047dad8d9f218

Healthbar.png and LongHealthBar.png from `art/` folder were based off this nice
progress bar:
https://forum.godotengine.org/t/how-to-make-health-bar-with-texture-progress-bar/4204/2

Healing sound from EminYILDIRIM:
https://freesound.org/people/EminYILDIRIM/sounds/587603/

Enemy hit sound: Enemy_Hit.wav by D001447733 -- https://freesound.org/s/464623/
-- License: Attribution 3.0

# How to create animated models for godot

1. Download any .gbl or .fbx file
2. Upload the model to mixamo.com for rigging
3. Download the standard model from Mixamo, with your chosen animation if you
   want (it has to be ready for animations)
4. Watch the video for the Mixamo animations plugin located here in this repo in
   `/addons` from SOME_NAME_OF_THE_AUTHOR_OF_THIS_AMAZING_PLUGIN
