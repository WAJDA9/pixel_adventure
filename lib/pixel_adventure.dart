
import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:pixeladventure/components/level.dart';
import 'package:pixeladventure/components/player.dart';

class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection{

  @override
  Color backgroundColor() =>const Color(0xFF211F30);
late final CameraComponent cam;
Player player = Player();
late final world = Level(levelName: "Level-02", player: player);
late JoystickComponent joystick;
@override
FutureOr<void> onLoad() async {
  //load into cache
  await images.loadAllImages();
  await images.load('HUD/knob.png');
  await images.load('BackGround/Blue.png');

  cam = CameraComponent.withFixedResolution( world: world, width: 640, height: 360);
  cam.viewfinder.anchor = Anchor.topLeft;
  addJoystick();
  addButton(); // Add this line to add the button

  await addAll([cam, world]);

  return super.onLoad();
}

void addButton() {
  final button = SpriteButtonComponent(
    
    anchor: Anchor.bottomRight,
    button: Sprite(images.fromCache('HUD/knob.png'),
    srcPosition: Vector2(900 , 360 ),
    ),
    onPressed: () {
      player.HasJumped=true; // Call the jump method of the player when the button is pressed
    },
    position: Vector2(600, 300), // Adjust the position of the button as needed
  );

  add(button);
}


    

  @override
  void update(double dt) {
    updateJoystick();
    super.update(dt);
  }



  
  void addJoystick() {

    joystick=JoystickComponent(
    
      priority: 999,
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
      case JoystickDirection.up:
        player.HasJumped=true;
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
 
}