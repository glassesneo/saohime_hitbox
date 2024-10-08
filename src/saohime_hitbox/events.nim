import pkg/[saohime, seiryu]

type
  CollisionEnterEvent* = object
    targets*: set[EntityId]
    normal*: Vector

  CollisionExitEvent* = object
    targets*: set[EntityId]

proc new*(
  T: type CollisionEnterEvent, targets: set[EntityId], normal: Vector
): T {.construct.}

proc new*(T: type CollisionExitEvent, targets: set[EntityId]): T {.construct.}

export new
