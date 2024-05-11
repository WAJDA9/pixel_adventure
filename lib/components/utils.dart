import 'package:pixeladventure/components/player.dart';

bool checkCollision(Player player,block){
  final hitbox=player.hitbox;  
  final playerX= player.position.x + hitbox.offsetX;
  final playerY=player.position.y + hitbox.offsetY;
  final playerWidth=hitbox.width;
  final playerHeight=hitbox.height;

  final FixedX= player.scale.x <0 ? playerX - playerWidth -(2 * hitbox.offsetX) : playerX;
  final FixedY= block.isPlatform ? playerY+ playerHeight :playerY;



  final blockX=block.x;
  final blockY=block.y;
  final blockWidth=block.width;
  final blockHeight=block.height;
  return(
    FixedY<blockY+blockHeight &&
    playerY+playerHeight>blockY &&
    FixedX<blockX+blockWidth &&
    FixedX+playerWidth>blockX
  );

}