import std/[tables]
import pkg/saohime, pkg/saohime/default_plugins
import ./[components, events, resources]

proc detectPointCollision*(
    points: [All[Collidable, PointCollider, Transform]],
    observer: Resource[CollisionObserver],
) {.system.} =
  for i in 0 ..< points.len:
    let entity1 = points[i]
    let tf1 = entity1[Transform]
    for j in i + 1 ..< points.len:
      let entity2 = points[j]
      let targets = {entity1.id, entity2.id}
      let tf2 = entity2[Transform]
      let areCollided = tf1.position == tf2.position
      if observer.durationTable.hasKey(targets):
        if not areCollided:
          let event = CollisionExitEvent.new(targets)
          commands.dispatchEvent(event)
          observer.durationTable.del(targets)
      elif areCollided:
        let event = CollisionEnterEvent.new(targets, normal = ZeroVector)
        commands.dispatchEvent(event)
        observer.durationTable[targets] = 0

proc detectCircleCollision*(
    circles: [All[Collidable, CircleCollider, Transform]],
    observer: Resource[CollisionObserver],
) {.system.} =
  for i in 0 ..< circles.len:
    let entity1 = circles[i]
    let (tf1, collider1) = entity1[Transform, CircleCollider]
    for j in i + 1 ..< circles.len:
      let entity2 = circles[j]
      let targets = {entity1.id, entity2.id}
      let (tf2, collider2) = entity2[Transform, CircleCollider]
      let diff = tf1.position - tf2.position
      let areCollided = diff.len <= collider1.radius + collider2.radius
      if observer.durationTable.hasKey(targets):
        if not areCollided:
          let event = CollisionExitEvent.new(targets)
          commands.dispatchEvent(event)
          observer.durationTable.del(targets)
      elif areCollided:
        let event = CollisionEnterEvent.new(targets, normal = diff.normalized())
        commands.dispatchEvent(event)
        observer.durationTable[targets] = 0

proc detectRectangleCollision*(
    rectangles: [All[Collidable, RectangleCollider, Transform]],
    observer: Resource[CollisionObserver],
) {.system.} =
  for i in 0 ..< rectangles.len:
    let entity1 = rectangles[i]
    let (tf1, collider1) = entity1[Transform, RectangleCollider]
    for j in i + 1 ..< rectangles.len:
      let entity2 = rectangles[j]
      let targets = {entity1.id, entity2.id}
      let (tf2, collider2) = entity2[Transform, RectangleCollider]
      let areCollided =
        tf1.position <= tf2.position + collider2.size and
        tf2.position <= tf1.position + collider1.size

      if observer.durationTable.hasKey(targets):
        if not areCollided:
          let event = CollisionExitEvent.new(targets)
          commands.dispatchEvent(event)
          observer.durationTable.del(targets)
      elif areCollided:
        let event = CollisionEnterEvent.new(targets, normal = ZeroVector)
        commands.dispatchEvent(event)
        observer.durationTable[targets] = 0

proc detectPointCircleCollision*(
    points: [All[Collidable, PointCollider, Transform]],
    circles: [All[Collidable, CircleCollider, Transform]],
    observer: Resource[CollisionObserver],
) {.system.} =
  for pointEntity, pointTf in points[Transform]:
    for circleEntity, circleCol, circleTf in circles[CircleCollider, Transform]:
      let targets = {pointEntity.id, circleEntity.id}
      let diff = pointTf.position - circleTf.position
      let areCollided = diff.len <= circleCol.radius
      if observer.durationTable.hasKey(targets):
        if not areCollided:
          let event = CollisionExitEvent.new(targets)
          commands.dispatchEvent(event)
          observer.durationTable.del(targets)
      elif areCollided:
        let event = CollisionEnterEvent.new(targets, normal = diff.normalized())
        commands.dispatchEvent(event)
        observer.durationTable[targets] = 0

proc detectPointRectangleCollision*(
    points: [All[Collidable, PointCollider, Transform]],
    rectangles: [All[Collidable, RectangleCollider, Transform]],
    observer: Resource[CollisionObserver],
) {.system.} =
  for pointEntity, pointTf in points[Transform]:
    for rectEntity, rectCol, rectTf in rectangles[RectangleCollider, Transform]:
      let targets = {pointEntity.id, rectEntity.id}
      let areCollided =
        pointTf.position.x in rectTf.position.x .. rectTf.position.x + rectCol.size.x and
        pointTf.position.y in rectTf.position.y .. rectTf.position.y + rectCol.size.y

      if observer.durationTable.hasKey(targets):
        if not areCollided:
          let event = CollisionExitEvent.new(targets)
          commands.dispatchEvent(event)
          observer.durationTable.del(targets)
      elif areCollided:
        let diff = pointTf.position - (rectTf.position + rectCol.size / 2)
        let event = CollisionEnterEvent.new(targets, normal = diff)
        commands.dispatchEvent(event)
        observer.durationTable[targets] = 0

proc detectCircleRectangleCollision*(
    circles: [All[Collidable, CircleCollider, Transform]],
    rectangles: [All[Collidable, RectangleCollider, Transform]],
    observer: Resource[CollisionObserver],
) {.system.} =
  for circleEntity, circleCol, circleTf in circles[CircleCollider, Transform]:
    for rectEntity, rectCol, rectTf in rectangles[RectangleCollider, Transform]:
      let targets = {circleEntity.id, rectEntity.id}
      let nearestEdge = block:
        let
          cPos = circleTf.position
          rPos = rectTf.position
          rEndPos = rectTf.position + rectCol.size

        let x =
          if cPos.x < rPos.x:
            rPos.x
          elif rEndPos.x < cPos.x:
            rEndPos.x
          else:
            cPos.x
        let y =
          if cPos.y < rPos.y:
            rPos.y
          elif rEndPos.y < cPos.y:
            rEndPos.y
          else:
            cPos.y
        Vector.new(x, y)
      let diff = nearestEdge - circleTf.position
      let areCollided = diff.len <= circleCol.radius
      if observer.durationTable.hasKey(targets):
        if not areCollided:
          let event = CollisionExitEvent.new(targets)
          commands.dispatchEvent(event)
          observer.durationTable.del(targets)
      elif areCollided:
        let event = CollisionEnterEvent.new(targets, normal = diff.normalized())
        commands.dispatchEvent(event)
        observer.durationTable[targets] = 0
