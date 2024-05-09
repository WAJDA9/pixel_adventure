
import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixeladventure/actors/player.dart';
import 'package:pixeladventure/levels/level.dart';

class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks{

  @override
  Color backgroundColor() =>const Color(0xFF211F30);
late final CameraComponent cam;
Player player = Player();
late final world = Level(levelName: "Level-01", player: player);
late JoystickComponent joystick;
@override
  FutureOr<void> onLoad() async {
    //load into cache
    await images.loadAllImages();
    await images.load('HUD/knob.png');

    cam = CameraComponent.withFixedResolution( world: world, width: 640, height: 360);
    cam.viewfinder.anchor = Anchor.topLeft;

  await addAll([cam, world]);

  addJoystick();


    return super.onLoad();
  }

  @override
  void update(double dt) {
    updateJoystick();
    super.update(dt);
  }



  
  void addJoystick() {

    joystick=JoystickComponent(
    
      priority: 1,
      knob: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/knob.png')),

      ),
      background: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Joystick.png')),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );
  
     add(joystick);
  }
  
  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.up:
        player.playerdirection = PlayerDirection.up;
        break;
      case JoystickDirection.down:
        player.playerdirection = PlayerDirection.down;
        break;
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.playerdirection = PlayerDirection.left;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.playerdirection = PlayerDirection.right;
        break;
      case JoystickDirection.idle:
        player.playerdirection = PlayerDirection.none;
        break;
      default:
    }
  }
 
}