import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:pixeladventure/components/checkpoint.dart';
import 'package:pixeladventure/components/collision_block.dart';
import 'package:pixeladventure/components/custom_hitbox.dart';
import 'package:pixeladventure/components/fruit.dart';
import 'package:pixeladventure/components/saw.dart';
import 'package:pixeladventure/components/utils.dart';

import 'package:pixeladventure/pixel_adventure.dart';

enum PlayerState { idle, run,jump,fall,doublejump,hit,appearing, disappearing }
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
  late final SpriteAnimation disappearingAnimation;
  final double stepTime=0.05;
  final double _gravity=9.8;
  final double _jumpForce=240;
  // for pc final double _jumpForce=380;

  double fixedDeltaTime=1/60;
  double accumulatedTime=0;
  final double _terminalVelocity=300;
  double horizontalmvmnt = 0;
  Vector2 startingPos=Vector2.zero();
  double movespeed=100;
  Vector2 velocity = Vector2.zero();
  List<CollisionBlock> collisionBlocks=[];
  bool reachedCheckpoint=false;
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
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      if(!gotHit && !reachedCheckpoint){
      _updateplayerstate();
    _updateplayermovement(fixedDeltaTime);
    _checkhorizontalcollisions();
    _applyGravity(fixedDeltaTime);
    _checkVerticalCollisions();
    }
      
      accumulatedTime -= fixedDeltaTime;
      
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
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!reachedCheckpoint){
      if(other is Fruit){
        game.fruitNum--;
      other.collidingWithPlayer();
    }
    if (other is Saw) {
      _respawn();
    }
    if(other is Checkpoint && !other.reachedCheckpoint){
      other.changeAnimation();
      _reachedCheckpoint();
    }

    }
    
    super.onCollisionStart(intersectionPoints, other);
  }



  
  void _loadAnimations() {
    idleAnimation = _spriteanimation("Idle", 11);
    runAnimation = _spriteanimation("Run", 12);
    jumpAnimation = _spriteanimation("Jump", 1);
    fallAnimation = _spriteanimation("Fall", 1);
    doublejumpAnimation= _spriteanimation("Double Jump", 6);
    hitAnimation= _spriteanimation("Hit", 7)..loop=false;
    appearingAnimation= _specialspriteanimation("Appearing", 7)..loop=false;
    disappearingAnimation= _specialspriteanimation("Desappearing", 7)..loop=false;

    
    //List of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.run: runAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.fall: fallAnimation,
      PlayerState.doublejump: doublejumpAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.disappearing: disappearingAnimation,
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
    if (game.playsounds){
      FlameAudio.play('jump.wav', volume: game.volume);
    }
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
  
   void _respawn() async {
    if (game.playsounds) FlameAudio.play('hit.wav', volume: game.volume);
    const canMoveDuration = Duration(milliseconds: 400);
    gotHit = true;
    current = PlayerState.hit;

    await animationTicker?.completed;
    animationTicker?.reset();

    scale.x = 1;
    position = startingPos - Vector2.all(32);
    current = PlayerState.appearing;

    await animationTicker?.completed;
    animationTicker?.reset();

    velocity = Vector2.zero();
    position = startingPos;
    _updateplayerstate();
    Future.delayed(canMoveDuration, () => gotHit = false);
  }
  
  void _reachedCheckpoint() async {
    if (game.fruitNum==0){
      reachedCheckpoint=true;
    if (game.playsounds){
      FlameAudio.play('disappear.wav', volume: game.volume);
    }
    
    if (scale.x > 0){
      position-= Vector2.all(32);
    }
    else{
      position += Vector2(32,-32);
    }
    current=PlayerState.disappearing;
    await animationTicker?.completed;
    animationTicker?.reset();
   
    reachedCheckpoint = false;
    position = Vector2.all(-640);

    const waitToChangeDuration = Duration(seconds: 3);
    Future.delayed(waitToChangeDuration, () => game.loadNextLevel());

    }
  }
  
  

}