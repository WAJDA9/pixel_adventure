import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixeladventure/components/collision_block.dart';
import 'package:pixeladventure/components/custom_hitbox.dart';
import 'package:pixeladventure/components/fruit.dart';
import 'package:pixeladventure/components/saw.dart';
import 'package:pixeladventure/components/utils.dart';

import 'package:pixeladventure/pixel_adventure.dart';

enum PlayerState { idle, run,jump,fall,doublejump,hit,appearing }
class Player extends SpriteAnimationGroupComponent with HasGameRef<PixelAdventure>, KeyboardHandler , CollisionCallbacks {
  String character;

  Player({position, this.character='Pink Man'}):super(position: position);
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation fallAnimation;
  late final SpriteAnimation doublejumpAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  final double stepTime=0.05;
  final double _gravity=9.8;
  final double _jumpForce=380;
  final double _terminalVelocity=300;
  double horizontalmvmnt = 0;
  Vector2 startingPos=Vector2.zero();
  double movespeed=100;
  Vector2 velocity = Vector2.zero();
  List<CollisionBlock> collisionBlocks=[];
  bool isOnGround=false;
  bool HasJumped=false;
  bool hasdoubleJump=true;
  bool gotHit=false;

  CustomHitbox hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 10,
    width: 12,
    height: 20,
  );

  @override
  FutureOr<void> onLoad() {
    _loadAnimations();
   startingPos=position.clone();
    add(RectangleHitbox(
      size: Vector2(hitbox.width, hitbox.height),
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
    ));
    return super.onLoad();
  }
  @override
  void update(double dt) {
    if(!gotHit){
      _updateplayerstate();
    _updateplayermovement(dt);
    _checkhorizontalcollisions();
    _applyGravity(dt);
    _checkVerticalCollisions();
    }
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalmvmnt = 0;
    final isLeftKeyPressed=keysPressed.contains(LogicalKeyboardKey.arrowLeft) || keysPressed.contains(LogicalKeyboardKey.keyQ);
    final isRightKeyPressed=keysPressed.contains(LogicalKeyboardKey.arrowRight) || keysPressed.contains(LogicalKeyboardKey.keyD);
    final isUpKeyPressed=keysPressed.contains(LogicalKeyboardKey.arrowUp) || keysPressed.contains(LogicalKeyboardKey.keyZ);
   
   horizontalmvmnt += isLeftKeyPressed ? -1 : 0; 
   horizontalmvmnt += isRightKeyPressed ? 1 : 0;
    HasJumped= keysPressed.contains(LogicalKeyboardKey.space) || keysPressed.contains(LogicalKeyboardKey.arrowUp) || keysPressed.contains(LogicalKeyboardKey.keyZ);
    
   

    return super.onKeyEvent(event, keysPressed);
  }



@override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if(other is Fruit){
      other.collidingWithPlayer();
    }
    if (other is Saw) {
      _Respawn();
    }
    super.onCollision(intersectionPoints, other);
  }


  
  void _loadAnimations() {
    idleAnimation = _spriteanimation("Idle", 11);
    runAnimation = _spriteanimation("Run", 12);
    jumpAnimation = _spriteanimation("Jump", 1);
    fallAnimation = _spriteanimation("Fall", 1);
    doublejumpAnimation= _spriteanimation("Double Jump", 6);
    hitAnimation= _spriteanimation("Hit", 7);
    appearingAnimation= _specialspriteanimation("Appearing", 7);

    
    
    //List of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.run: runAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.fall: fallAnimation,
      PlayerState.doublejump: doublejumpAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
    };

    //setting the current animations
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteanimation(state, ammount){
    return SpriteAnimation.fromFrameData(game.images.fromCache("Main Characters/$character/$state (32x32).png"), SpriteAnimationData.sequenced(
      amount: ammount,
      stepTime: stepTime, 
      textureSize: Vector2(32, 32)));
  }
  

   SpriteAnimation _specialspriteanimation(state, ammount){
    return SpriteAnimation.fromFrameData(game.images.fromCache("Main Characters/$state (96x96).png"), SpriteAnimationData.sequenced(
      amount: ammount,
      stepTime: stepTime, 
      textureSize: Vector2(96,96))
      
      );
  }



  void _updateplayerstate() {
    PlayerState playerstate= PlayerState.idle;
    if(velocity.x<0 && scale.x > 0){
      flipHorizontallyAroundCenter();
    }else if(velocity.x>0 && scale.x < 0){
      flipHorizontallyAroundCenter();
    }
    if (velocity.x >0 || velocity.x <0){
      playerstate = PlayerState.run;
    }

      // if (!hasdoubleJump){
      //   playerstate = PlayerState.doublejump;
      // }
    if(velocity.y<0){
    
      playerstate = PlayerState.jump;
    }
    if(velocity.y>_gravity){
      playerstate = PlayerState.fall;
    }

    current = playerstate;

  }


  void _updateplayermovement(double dt) {
    if(HasJumped && isOnGround){
      _playerJump(dt);
    }
    // if (!isOnGround && hasdoubleJump){
    //   if (HasJumped){
    //     hasdoubleJump=false;
    //     _playerdoubleJump(dt);
    //   }
    // }
    velocity.x = horizontalmvmnt * movespeed;
    
    position.x += velocity.x * dt;
  }
  
  void _checkhorizontalcollisions() {
    for (final block in collisionBlocks){
      if(checkCollision(this, block)){
        if(!block.isPlatform){
          if(velocity.x>0){
            velocity.x = 0;
         position.x = block.x -hitbox.offsetX - hitbox.width;
      }
      if(velocity.x<0){
            velocity.x = 0;
         position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
      }
        }
      }
  }
  }
  
  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }
  
  void _checkVerticalCollisions() {
    for(final block in collisionBlocks){
      if(block.isPlatform){
        if(checkCollision(this, block)){
           if(velocity.y>0){
           velocity.y = 0;
           //comment this for quick sand
           position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround=true;
            // hasdoubleJump=true;
         }
        }
      }
      else{
        if(checkCollision(this, block)){
         if(velocity.y>0){
           velocity.y = 0;
           //comment this for quick sand
           position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround=true;
            hasdoubleJump=true;
         }
         if(velocity.y<0){
           velocity.y = 0;
           position.y = block.y + block.height - hitbox.offsetY;
         }
      }
    }
    }
  }
  
  _playerJump(double dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    HasJumped = false;  
    isOnGround = false;
  }
  
  void _playerdoubleJump(double dt) {
     velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    HasJumped = false; 
     
    isOnGround = false;
  }
  
  void _Respawn() {
    gotHit=true;
    const hitduration = Duration(milliseconds: 350);
    const appearingduration = Duration(milliseconds: 350);
    const cantmoveduration = Duration(milliseconds: 400);
   current=PlayerState.hit;
   Future.delayed(hitduration, () {
     scale.x=1;
     position=startingPos - Vector2.all(32);
     current=PlayerState.appearing; 
     Future.delayed(appearingduration, () {
       position=startingPos;
       velocity=Vector2.zero();
       _updateplayerstate();
      Future.delayed(cantmoveduration, () {
        gotHit=false;
      });
     });
     }
   );
  }
  
  

}