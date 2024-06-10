import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixeladventure/pixel_adventure.dart';

class Saw extends SpriteAnimationComponent with HasGameRef<PixelAdventure>{
  Saw( {this.isVertical=false, this.offneg=0, this.offpos=0,size, position}) : super(size: size, position: position);

  static const double stepTime=0.03;
  final bool isVertical;
  final double offneg;
  final double offpos;


  static const movespeed=50;
  static const tileSize=16;
  double direction=1;
  double rangeNeg=0;
  double rangePos=0;



  @override
  FutureOr<void> onLoad() {
    priority=-1;
    add(CircleHitbox());
    if (isVertical) {
      rangeNeg= position.y - offneg * tileSize;
      rangePos= position.y + offpos * tileSize; 
    } else {
      rangeNeg= position.x - offneg*tileSize;
      rangePos= position.x + offpos*tileSize;
    }

    animation=SpriteAnimation.fromFrameData(
      game.images.fromCache("Traps/Saw/On (38x38).png"),
     SpriteAnimationData.sequenced(
      amount: 8, 
      stepTime: stepTime,
      textureSize: Vector2(38, 38))
    
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if(isVertical){  
      moveVertical(dt);
    }
    else{
      
      moveHorizontal(dt);
    }
    super.update(dt);
  }
  
  void moveVertical(dt) {
   if (position.y >= rangePos) {
      direction=-1;
    }
    else if (position.y <= rangeNeg) {
      direction=1;
    }
    
    position.y += movespeed*direction*dt;
  }
  
  void moveHorizontal(double dt) {
    if(position.x >= rangePos){
      direction=-1;
    }
    else if(position.x <= rangeNeg){
      direction=1;
    }
    position.x+=movespeed*direction*dt;
  }
}