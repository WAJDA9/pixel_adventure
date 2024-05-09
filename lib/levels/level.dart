import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixeladventure/actors/player.dart';

class Level extends World {
  final String levelName;
  final Player player;
  Level({required this.levelName,required this.player});
  late TiledComponent level;
  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load("$levelName.tmx", Vector2(16,16));
    add(level);
    final spawnpoints = level.tileMap.getLayer<ObjectGroup>('spawnpoints');
    for (final spawnpoint in spawnpoints!.objects){
      switch (spawnpoint.class_){
        case 'Player':
          
          player.position=Vector2(spawnpoint.x,spawnpoint.y);
          add(player);
          break;
        default:
      }
    }

  }
}