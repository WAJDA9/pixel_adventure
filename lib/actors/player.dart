import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixeladventure/pixel_adventure.dart';

enum PlayerState { idle, run, }

class Player extends SpriteAnimationGroupComponent with HasGameRef<PixelAdventure>{
  String character;

  Player({position,required this.character}):super(position: position);
  late final SpriteAnimation idle;
  late final SpriteAnimation run;
  final double stepTime=0.05;
  
  @override
  FutureOr<void> onLoad() {
    _loadAnilations();
    return super.onLoad();
  }
  
  void _loadAnilations() {
    idle = _spriteanimation("Idle", 11);
    run = _spriteanimation("Run", 12);

    
    
    //List of all animations
    animations = {
      PlayerState.idle: idle,
      PlayerState.run: run,
    };

    //setting the current animations
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteanimation(state, ammount){
    return SpriteAnimation.fromFrameData(game.images.fromCache("Main Characters/$character/$state (32x32).png"), SpriteAnimationData.sequenced(
      amount: ammount,
      stepTime: stepTime, 
      textureSize: Vector2(32, 32)));
  }

}