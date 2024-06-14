
import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:pixeladventure/components/jump_button.dart';
import 'package:pixeladventure/components/level.dart';
import 'package:pixeladventure/components/player.dart';

class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection , TapCallbacks {

  @override
Color backgroundColor() =>const Color(0xFF211F30);
late  CameraComponent cam;
//pass player
Player player = Player();
bool showControls=true;
late JoystickComponent joystick;
var currentLevelIndex=1;



@override
FutureOr<void> onLoad() async {
  //load into cache
  await images.loadAllImages();
  _loadLevel();
  if(showControls){
    addJoystick();
    add(JumpButton());
  }

  

  return super.onLoad();
}



    

  @override
  void update(double dt) {
    updateJoystick();
    super.update(dt);
  }



  
  void addJoystick() {
    joystick=JoystickComponent(
        priority: 10,
      knob: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/knob.png')),

      ),
      background: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Joystick.png')),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32,right: 30),
    );

     add(joystick);
  }
  
  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalmvmnt = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
       player.horizontalmvmnt = 1;
        break;
      case JoystickDirection.idle:
               
        break;
      default:
    }
  }

  loadNextLevel() {
    currentLevelIndex++;
     _loadLevel();
  }
  
  void _loadLevel()  {
     Future.delayed(Duration(seconds: 1), (){
        final world = Level(
      levelName: "Level-0$currentLevelIndex", 
      player: player);
     cam = CameraComponent.withFixedResolution( world: world, width: 640, height: 360);
      cam.viewfinder.anchor = Anchor.topLeft;
      addAll([cam, world]);
     });
  }
 
}