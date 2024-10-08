import std/colors
import pkg/saohime, pkg/saohime/default_plugins
import ../src/saohime_hitbox

type InputTarget = ref object

proc setup() {.system.} =
  commands
  .create()
  .attach(InputTarget())
  .attach(Transform.new(x = 0, y = 0))
  .attach(Collidable.new())
  # .attach(PointCollider.new())
  # .attach(CircleCollider.new(radius = 20))
  .attach(RectangleCollider.new(size = Vector.new(20, 20)))
  .RectangleBundle(size = Vector.new(20, 20), bg = colRed.toSaohimeColor())

  commands
  .create()
  .attach(Transform.new(x = 100, y = 100))
  .attach(CircleCollider.new(radius = 50))
  .attach(Collidable.new())
  .CircleBundle(radius = 50, bg = colBlue.toSaohimeColor())

  commands
  .create()
  .attach(Transform.new(x = 400, y = 100))
  .attach(RectangleCollider.new(size = Vector.new(50, 50)))
  .attach(Collidable.new())
  .RectangleBundle(size = Vector.new(50, 50), bg = colBlue.toSaohimeColor())

proc pollEvent(appEvent: Event[ApplicationEvent]) {.system.} =
  for e in appEvent:
    let app = commands.getResource(Application)
    app.terminate()

proc traceMousePosition(
    inputTargets: [All[InputTarget, Transform]], mouseInput: Resource[MouseInput]
) {.system.} =
  for _, tf in inputTargets[Transform]:
    tf.position.x = mouseInput.x.float
    tf.position.y = mouseInput.y.float

proc detectCollisionEnter(collisionEnter: Event[CollisionEnterEvent]) {.system.} =
  for event in collisionEnter:
    for id in event.targets:
      let entity = commands.getEntity(id)
      if entity.has(InputTarget):
        continue
      entity[Fill].color = colYellow.toSaohimeColor()

proc detectCollisionExit(collisionExit: Event[CollisionExitEvent]) {.system.} =
  for event in collisionExit:
    for id in event.targets:
      let entity = commands.getEntity(id)
      if entity.has(InputTarget):
        continue
      entity[Fill].color = colBlue.toSaohimeColor()

let app = Application.new()

app.loadPluginGroup(DefaultPlugins)
app.loadPlugin(HitboxPlugin)

app.start:
  world.registerStartupSystems(setup)
  world.registerSystems(pollEvent, traceMousePosition)
  world.registerSystems(detectCollisionEnter, detectCollisionExit)
