import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pixeladventure/pixel_adventure.dart';

class JumpButton extends SpriteComponent with HasGameRef<PixelAdventure>, TapCallbacks{
  JumpButton();
  var margin=32;
  var buttonSize=64;
  @override
  FutureOr<void> onLoad() {
    sprite=Sprite(game.images.fromCache('HUD/Button.png'));
    position=Vector2(game.size.x -margin -buttonSize , game.size.y -margin -buttonSize);
    priority=10;
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
     game.player.HasJumped=true;
      super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.HasJumped=false;
    super.onTapUp(event);
  }
}