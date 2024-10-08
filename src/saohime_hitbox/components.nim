import pkg/[saohime, seiryu]

type
  Collidable* = ref object

  PointCollider* = ref object

  CircleCollider* = ref object
    radius*: float

  RectangleCollider* = ref object
    size*: Vector

proc new*(T: type Collidable): T {.construct.}

proc new*(T: type PointCollider): T {.construct.}

proc new*(T: type CircleCollider, radius: float): T {.construct.}

proc new*(T: type RectangleCollider, size: Vector): T {.construct.}

export new
