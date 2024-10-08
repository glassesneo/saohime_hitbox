import pkg/saohime
import saohime_hitbox/[components, events, resources, systems]

type HitboxPlugin* = ref object

proc build*(plugin: HitboxPlugin, world: World) =
  world.addResource(CollisionObserver.new())
  world.addEvent(CollisionEnterEvent)
  world.addEvent(CollisionExitEvent)
  world.registerSystems(
    detectPointCollision, detectCircleCollision, detectRectangleCollision,
    detectPointCircleCollision, detectPointRectangleCollision,
    detectCircleRectangleCollision,
  )

export components, events, resources, systems
