import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixeladventure/components/background_tile.dart';
import 'package:pixeladventure/components/collision_block.dart';
import 'package:pixeladventure/components/player.dart';
import 'package:pixeladventure/pixel_adventure.dart';

class Level extends World with HasGameRef<PixelAdventure> {
  final String levelName;
  final Player player;
  Level({required this.levelName,required this.player});
  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
  
    level = await TiledComponent.load("$levelName.tmx", Vector2(16,16));
    add(level);

    _ScrollingBackGround();
    _SpawningObjects();
    _addCollisions();
    

    
    return super.onLoad();
  }
  
  void _addCollisions() {
    final collisionlayer = level.tileMap.getLayer<ObjectGroup>('Collisions');
    if (collisionlayer != null) {
      for (final collision in collisionlayer.objects){
        switch (collision.class_) {
          case 'Platform':
            final platform= CollisionBlock(position: Vector2(collision.x, collision.y), size: Vector2(collision.width, collision.height), isPlatform: true);
            collisionBlocks.add(platform);
            add(platform);
            
            break;
          default:
          final block= CollisionBlock(position: Vector2(collision.x, collision.y), size: Vector2(collision.width, collision.height));
          collisionBlocks.add(block);
          add(block);
          }

      }
    }
    player.collisionBlocks=collisionBlocks;
  }
  
  void _SpawningObjects() {
    final spawnpoints = level.tileMap.getLayer<ObjectGroup>('spawnpoints');
    if (spawnpoints == null) {
      return;
    }
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
  
  void _ScrollingBackGround() {
    final backgroundLayer=level.tileMap.getLayer('Background');
    
    final numTilesY=(game.size.y/64).floor();
        final numTilesX=(game.size.x/64).floor();
    if (backgroundLayer != null) {
      final backgroundColor=backgroundLayer.properties.getValue('BackgroundColor');
      
      for(double y =0;y<numTilesY;y++){
        for (double x=0;x<numTilesX;x++){
        final backgroundtile= BackgroundTile(
        position: Vector2(x*64,y*64 - 64),
        color: backgroundColor != null ? backgroundColor : 'Gray',
      );
      add(backgroundtile);
      }
      }
      
      
    }

  }
}