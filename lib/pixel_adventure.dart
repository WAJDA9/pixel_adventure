
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
  Color backgroundColor() => const Color(0xFF211F30);
  late CameraComponent cam;
  Player player = Player(character: 'Pink Man');
  late JoystickComponent joystick;
  bool playsounds=true;
  double volume=10.0;
  bool showControls = false;
  int fruitNum=0;
  List<String> levelNames = ['Level-01', 'Level-02','Level-03'];
  int currentLevelIndex = 0;



@override
FutureOr<void> onLoad() async {
  await images.loadAllImages();
  
  await _loadLevel();
 

    if(showControls){
    addJoystick();
    add(JumpButton());
    
  }

  

  return super.onLoad();
}



    

  @override
  void update(double dt) {
   if (showControls){
     updateJoystick();
   }
    super.update(dt);
  }



  
  void addJoystick() {
    joystick=JoystickComponent(
        priority: 10,
      knob: SpriteComponent(
        priority: 10,
        sprite: Sprite(
          
          images.fromCache('HUD/knob.png')),

      ),
      background: SpriteComponent(
        priority: 10,
        sprite: Sprite(images.fromCache('HUD/Joystick.png')),
      ),
      margin: const EdgeInsets.only(left: 15, bottom: 32,right: 30),
    );

     add(joystick);
     print("done joystick");
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
        player.horizontalmvmnt = 0;
        break;
      default:
    }
  }

  void loadNextLevel() {
    removeWhere((component) => component is Level);

    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    } else {
     
      currentLevelIndex = 0;
      _loadLevel();
    }
  }
  
   _loadLevel() async  {
     
        final world = Level(

      levelName: levelNames[currentLevelIndex], 
      player: player);
     cam = CameraComponent.withFixedResolution(  world: world, width: 640, height: 360,);
      cam.viewfinder.anchor = Anchor.topLeft;
      await addAll([cam, world]);
     
  }
 
}