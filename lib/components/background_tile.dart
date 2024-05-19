import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixeladventure/pixel_adventure.dart';

class BackgroundTile extends SpriteComponent with HasGameRef<PixelAdventure>{
  final String color;
  BackgroundTile(
   {
   this.color="Gray", 
   position
  }) : super(position: position,);

  final scrollSpeed=0.4;

  @override
  FutureOr<void> onLoad() {
    priority=-1;
    size=Vector2.all(64.6);
    sprite=Sprite(game.images.fromCache('BackGround/$color.png'));
    return super.onLoad();
  }

    @override
  void update(double dt) {
    position.y+=scrollSpeed;
    double tileSize=64;
    int scrollHeight=(game.size.y/tileSize).floor();
    if (position.y > scrollHeight*tileSize -64) position.y = -tileSize;
    super.update(dt);
  }

}