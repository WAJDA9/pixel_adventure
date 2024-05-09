import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import 'package:pixeladventure/pixel_adventure.dart';

enum PlayerState { idle, run, }
enum PlayerDirection { up, down, left, right, none}
class Player extends SpriteAnimationGroupComponent with HasGameRef<PixelAdventure>, KeyboardHandler{
  String character;

  Player({position, this.character='Pink Man'}):super(position: position);
  late final SpriteAnimation idle;
  late final SpriteAnimation run;
  final double stepTime=0.05;
  
  PlayerDirection playerdirection = PlayerDirection.none;
  double movespeed=100;
  Vector2 velocity = Vector2.zero();
  bool isfacingright = true;


  @override
  FutureOr<void> onLoad() {
    _loadAnilations();
    return super.onLoad();
  }
  @override
  void update(double dt) {
    
    _updateplayermovement(dt);
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isLeftKeyPressed=keysPressed.contains(LogicalKeyboardKey.arrowLeft) || keysPressed.contains(LogicalKeyboardKey.keyQ);
    final isRightKeyPressed=keysPressed.contains(LogicalKeyboardKey.arrowRight) || keysPressed.contains(LogicalKeyboardKey.keyD);
    final isUpKeyPressed=keysPressed.contains(LogicalKeyboardKey.arrowUp) || keysPressed.contains(LogicalKeyboardKey.keyZ);
    if(isLeftKeyPressed && isRightKeyPressed){
      playerdirection = PlayerDirection.none;
    } else if(isLeftKeyPressed){
      playerdirection = PlayerDirection.left;
    } else if(isRightKeyPressed){
      playerdirection = PlayerDirection.right;
    } else {
      playerdirection = PlayerDirection.none;
    }

    if(isUpKeyPressed){
      playerdirection = PlayerDirection.up;
    } else if(keysPressed.contains(LogicalKeyboardKey.arrowDown) || keysPressed.contains(LogicalKeyboardKey.keyS)){
      playerdirection = PlayerDirection.down;
    }

    return super.onKeyEvent(event, keysPressed);
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
    current = PlayerState.run;
  }

  SpriteAnimation _spriteanimation(state, ammount){
    return SpriteAnimation.fromFrameData(game.images.fromCache("Main Characters/$character/$state (32x32).png"), SpriteAnimationData.sequenced(
      amount: ammount,
      stepTime: stepTime, 
      textureSize: Vector2(32, 32)));
  }
  
  void _updateplayermovement(double dt) {
    double dirx=0.0;
    double diry=0.0;
    switch(playerdirection){
      case PlayerDirection.left:
      if(isfacingright){
        isfacingright = false;
        flipHorizontallyAroundCenter();
      }
      current = PlayerState.run;
        dirx -= movespeed;
        break;
      case PlayerDirection.right:
      if(!isfacingright){
        isfacingright = true;
        flipHorizontallyAroundCenter();
      }
      current = PlayerState.run;
        dirx+=movespeed;
        break;
      case PlayerDirection.up:
      current = PlayerState.run;
      diry-=movespeed;
        break;
      case PlayerDirection.down:
      current = PlayerState.run;
      diry+=movespeed;
        break;
      case PlayerDirection.none:
      current = PlayerState.idle;
        dirx=0;
        break;
      default:
    }
    velocity = Vector2(dirx,diry);
    position += velocity*dt;
  }

}