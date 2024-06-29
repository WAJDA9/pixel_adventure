import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixeladventure/components/background_tile.dart';
import 'package:pixeladventure/components/checkpoint.dart';
import 'package:pixeladventure/components/collision_block.dart';
import 'package:pixeladventure/components/fruit.dart';
import 'package:pixeladventure/components/player.dart';
import 'package:pixeladventure/components/saw.dart';
import 'package:pixeladventure/pixel_adventure.dart';

class Level extends World with HasGameRef<PixelAdventure> {
  final String levelName;
  final Player player;
  Level({required this.levelName,required this.player});
  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
   priority = -1;
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
          player.scale.x=1;
          add(player);
          break;
        case 'Fruit':
          final fruit= Fruit(fruit: spawnpoint.name, position: Vector2(spawnpoint.x,spawnpoint.y), size: Vector2(spawnpoint.width,spawnpoint.height));
          add(fruit);
          game.fruitNum++;
          break;
        case 'Saw':
        final bool isVertical=spawnpoint.properties.getValue('isVertical');
        final double offneg=spawnpoint.properties.getValue('offneg');
        final double offpos=spawnpoint.properties.getValue('offpos');
          final saw= Saw(
            size: Vector2(spawnpoint.width,spawnpoint.height), 
            position: Vector2(spawnpoint.x,spawnpoint.y),
            isVertical: isVertical,
            offneg: offneg,
            offpos: offpos,
            );
          add(saw);
          break;
        case 'Checkpoint':
          final checkpoint= Checkpoint( position: Vector2(spawnpoint.x,spawnpoint.y), size: Vector2(spawnpoint.width,spawnpoint.height));
          add(checkpoint);
          break;
        default:
      }
    }
  }
  
  void _ScrollingBackGround() {
    final backgroundLayer=level.tileMap.getLayer('Background');
    
    if (backgroundLayer != null) {
      final backgroundColor=backgroundLayer.properties.getValue('BackgroundColor');
       final backgroundtile= BackgroundTile(
        position: Vector2(0,0),
        color: backgroundColor != null ? backgroundColor : 'Gray',
      );
     
       
      add(backgroundtile);
      
      
      
    }

  }
}