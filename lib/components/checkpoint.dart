import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixeladventure/components/player.dart';
import 'package:pixeladventure/pixel_adventure.dart';

class Checkpoint extends SpriteAnimationComponent with HasGameRef<PixelAdventure>, CollisionCallbacks{
  Checkpoint({position, size}):super(position: position, size: size);
 bool reachedCheckpoint=false; 
  
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
        if (other is Player) {
          changeAnimation();
        }

    super.onCollisionStart(intersectionPoints, other);
  }
  @override
  FutureOr<void> onLoad() {
    priority = -1;
    
    add(RectangleHitbox(
      position: Vector2(7, 20),
      size: Vector2(10, 8),
      collisionType: CollisionType.passive,
    ));
    animation=SpriteAnimation.fromFrameData(
    game.images.fromCache("Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png"),
    SpriteAnimationData.sequenced(
      amount: 1,
      stepTime: 0.5,
      textureSize: Vector2.all(64),
    ),
    );
        return super.onLoad();
  }


  

  changeAnimation() async {
    if (game.fruitNum==0){
      animation=SpriteAnimation.fromFrameData(
      game.images.fromCache("Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png"),
      SpriteAnimationData.sequenced(
        amount: 26,
        stepTime: 0.05,
        textureSize: Vector2.all(64),
        loop: false,
      ),
    );
    await animationTicker?.completed;
    animation=SpriteAnimation.fromFrameData(
      game.images.fromCache("Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png"),
      SpriteAnimationData.sequenced(
        amount: 10,
        stepTime: 0.05,
        textureSize: Vector2.all(64),
      ));
   
      
    } 
  }
}