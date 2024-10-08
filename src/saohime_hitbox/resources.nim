import std/[tables]
import pkg/[saohime, seiryu]

type CollisionObserver* = ref object
  durationTable*: Table[set[EntityId], Natural]

proc new*(T: type CollisionObserver): T {.construct.}

export new
