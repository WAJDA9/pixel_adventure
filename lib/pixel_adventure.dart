
import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:pixeladventure/levels/level.dart';

class PixelAdventure extends FlameGame{

  @override
  Color backgroundColor() =>const Color(0xFF211F30);
late final CameraComponent cam;
late final world = Level(levelName: "Level-02");

@override
  FutureOr<void> onLoad() async {
    //load into cache
    await images.loadAllImages();

    cam = CameraComponent.withFixedResolution( world: world, width: 640, height: 360);
    cam.viewfinder.anchor = Anchor.topLeft;

  addAll([cam, world]);


    return super.onLoad();
  }
}