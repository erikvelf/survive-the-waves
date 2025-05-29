# Survival

Gioco in Godot 4 in 3D dove tu devi sopravvivere alle ondate di nemici.

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
