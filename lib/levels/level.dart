import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixeladventure/actors/player.dart';

class Level extends World {
  final String levelName;
  Level({required this.levelName});
  late TiledComponent level;
  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load("$levelName.tmx", Vector2(16,16));
    add(level);
    final spawnpoints = level.tileMap.getLayer<ObjectGroup>('spawnpoints');
    for (final spawnpoint in spawnpoints!.objects){
      switch (spawnpoint.class_){
        case 'Player':
          final player = Player(character: 'Pink Man',position: Vector2(spawnpoint.x,spawnpoint.y)) ;
          add(player);
          break;
        default:
      }
    }

  }
}