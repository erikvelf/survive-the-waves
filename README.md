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

Amazing game ready 3D models for EnemySmall, EnemyMedium and EnemyBig are from
https://sketchfab.com/alex.cgwarrior, without him i would't be able to make this
game
