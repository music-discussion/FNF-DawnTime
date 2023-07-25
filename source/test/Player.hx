package	test;

import flixel.FlxG;
import flixel.FlxSprite;
// import flixel.sound.FlxSound;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

/**
 * An FlxSprite that is the player.
 */
class Player extends FlxSprite
{
	public var runSpeed:Float = 800;
	public var speed:Float = 400;
	public var dragAmt:Float = 15;
	public var accel:Float = 20;
	public var grav:Float = 2.5;
	public var jumpH:Float = 800;
	public var coinCount:Int = 0;
	public var cayoteTime:Float = 0.25; // how long after falling should they be able to jump (in seconds)

	var prevY:Float = 0;
	var deltaY:Float = 0;

	var whar:Float = 0;
	var jumpCounter:Int = 0;
	var jumpTimer:Float = 0;
	var currentCayoteTime:Float = 0;

	var jumping:Bool = false;
	var pounding:Bool = false;
	var onGround:Bool = false;
	var wallJumped:Bool = false;
	var acceptInputs:Bool = true;
	var canCancel:Bool = false;
	var cayoteJumped:CayaoteJumpStage = CayaoteJumpStage.NotInitiated;
	var jumpSound:FlxSound;
	var slideSound:FlxSound;

	public function new(x:Float, y:Float, imgPath:String)
	{
		//super(x, y, imgPath);
		super();

		loadGraphic(Paths.image(imgPath));
		antialiasing = false;
		acceleration.y = grav * 1000;
		scale.set(0.1, 0.1);

		jumpSound = new FlxSound().loadEmbedded('assets/sounds/point.wav');
		jumpSound.volume = 0.6;
		FlxG.sound.list.add(jumpSound);

		slideSound = new FlxSound().loadEmbedded('assets/sounds/wing.wav', true);
		slideSound.volume = 0.6;
		FlxG.sound.list.add(slideSound);
		updateHitbox();
	}

	override public function update(elapsed:Float)
	{
		prevY = y;
		super.update(elapsed);
		deltaY = y - prevY;

		FlxG.collide(this, PlayState.walls);
		// FlxG.overlap(this, PlayState.coins, playerTouchCoin);

		if (isTouching(FLOOR))
		{
			if (pounding)
			{
				FlxG.camera.shake(0.003 / FlxG.camera.zoom, 0.3);
			//	FlxG.sound.play('assets/sounds/gp-land.wav', 0.8);
				pounding = false;
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					acceptInputs = true;
				});
			}
			else if (!pounding && !onGround)
			{
				onGround = true;
			//	FlxG.sound.play('assets/sounds/land.wav', 0.6);
			}
		}

		if (wallJumped)
		{
			if (velocity.x > 0)
				flipX = false;
			else if (velocity.x < 0)
				flipX = true;
		}

		if (pounding && FlxG.keys.pressed.W && canCancel)
		{
			velocity.y = -100;
			pounding = false;
			acceptInputs = true;
			canCancel = false;
		}

		if (acceptInputs)
			updateMovement(elapsed);
	}

	public function updateMovement(elapsed:Float):Void
	{
		// Check key states
		var jumpPressed:Bool = FlxG.keys.pressed.SPACE;
		var isSprinting:Bool = FlxG.keys.pressed.SHIFT;
		var bypassJump:Bool = false;

		// Adjust speed and acceleration based on key states
		if (isSprinting)
		{
			speed = runSpeed;
			dragAmt = 30;
			accel = 40;
		}
		else
		{
			speed = 400;
			dragAmt = 15;
			accel = 20;
		}

		// Handle jumping and jump counters
		if (jumping && !jumpPressed)
		{
			jumping = false;
		}

		if (cayoteJumped == CayaoteJumpStage.NotInitiated)
		{
			if (jumpPressed && jumpCounter > 0)
			{
				maxVelocity.y = 200;
			}
			else if (!jumpPressed)
			{
				maxVelocity.y = 0;
			}
		}

		if (FlxG.keys.justPressed.SPACE)
		{
			jumpCounter++;
		}

		// Reset jumpTimer
		if (isTouching(FLOOR))
		{
			if (!jumping)
			{
				jumpTimer = 0;
				jumpCounter = 0;
				onGround = true;
				wallJumped = false;
				currentCayoteTime = cayoteTime;
				cayoteJumped = CayaoteJumpStage.NotInitiated;
			}
			currentCayoteTime = cayoteTime;
		}
		else 
		{
			currentCayoteTime -= elapsed;
			if (currentCayoteTime >= 0 && !pounding && cayoteJumped == CayaoteJumpStage.NotInitiated && !jumping && jumpPressed) // idk if gliding interferes with this.
			{
				trace("cayote jump");
				currentCayoteTime = -1;
				bypassJump = true;
				cayoteJumped = CayaoteJumpStage.Initiated;
				maxVelocity.y = 0;
				jumpCounter = 0;
				jumpTimer = 0;
				jumpPressed = true;
			}
		}

		// Handle jumpTimer and jumping state
		if (jumpTimer >= 0 && jumpPressed && !wallJumped && (maxVelocity.y != 200 || (bypassJump && cayoteJumped == CayaoteJumpStage.Initiated)))
		{
			currentCayoteTime = -1;
			if (!jumping)
			{
				jumpSound.pitch = FlxG.random.float(0.8, 1.2);
				jumpSound.play();
				if (bypassJump && cayoteJumped == CayaoteJumpStage.Initiated)
					cayoteJumped = CayaoteJumpStage.Passed;
			}

			jumping = true;
			onGround = false;
			jumpTimer += elapsed;
		}
		else
		{
			jumpTimer = -1;

		}

		// Handle ground pounding
		if (!isTouching(FLOOR) && FlxG.keys.justPressed.S && !pounding)
		{
			if (flipX)
			{
				FlxTween.tween(this, {angle: -360}, 0.1);
			}
			else
			{
				FlxTween.tween(this, {angle: 360}, 0.1);
			}
			maxVelocity.y = -5;
			canCancel = false;
			acceptInputs = false;
			pounding = true;
		//	FlxG.sound.play('assets/sounds/gp-start.wav', 0.8);
			new FlxTimer().start(0.2, function(tmr:FlxTimer)
			{
				angle = 0;
				canCancel = true;
				maxVelocity.y = 0;
				velocity.y = 1500;
			});
		}

		// Handle Walljumping
		if (isTouching(WALL) && !isTouching(FLOOR) && !pounding)
		{
			maxVelocity.y = 200;
			slideSound.play();
			if (FlxG.keys.justPressed.SPACE)
			{
				velocity.x = speed * (isTouching(LEFT) ? 1.1 : -1.1);
				slideSound.stop();
			//	FlxG.sound.play('assets/sounds/wallJump.wav');
				maxVelocity.y = 0;
				velocity.y = -jumpH * 1.2;
				jumpTimer = 0;
				jumping = true;
				acceptInputs = false;
				wallJumped = true;
				new FlxTimer().start(0.3, function(tmr:FlxTimer)
				{
					acceptInputs = true;
				});
			}
		}
		else if (!isTouching(WALL) || isTouching(FLOOR))
			slideSound.stop();

		if (isTouching(CEILING))
		{
		//	FlxG.sound.play('assets/sounds/bonk.wav');
			jumpTimer = -1;
		}

		// Handle left and right movement
		if (!pounding)
		{
			if (FlxG.keys.pressed.A)
			{
				flipX = true;
				if (velocity.x == speed && isSprinting)
				{
					velocity.x = -speed;
				}
				else
				{
					velocity.x -= accel;
				}
			}
			else if (FlxG.keys.pressed.D)
			{
				flipX = false;
				if (velocity.x == -speed && isSprinting)
				{
					velocity.x = speed;
				}
				else
				{
					velocity.x += accel;
				}
			}
			else
			{
				// Apply drag if no movement keys are pressed
				if (!wallJumped)
				{
					if (velocity.x != 0)
					{
						if (flipX)
						{
							if (velocity.x <= 0)
							{
								velocity.x += dragAmt;
							}

							if (velocity.x >= 0)
							{
								velocity.x = 0;
							}
						}
						else
						{
							if (velocity.x >= 0)
							{
								velocity.x -= dragAmt;
							}

							if (velocity.x <= 0)
							{
								velocity.x = 0;
							}
						}
					}
				}
			}
		}
		else
		{
			velocity.x = 0;
		}

		// Limit maximum velocity
		if (flipX && velocity.x < -speed)
		{
			velocity.x = -speed;
		}
		else if (!flipX && velocity.x > speed)
		{
			velocity.x = speed;
		}

		// Hold button to jump higher (up to 0.4s)
		if (jumpTimer > 0 && jumpTimer < 0.4)
		{
			velocity.y = -jumpH;
		}
	}

	// function playerTouchCoin(player:Player, coin:Coin):Void
	// {
	// 	if (player.alive && player.exists && coin.alive && coin.exists)
	// 	{
	// 		coin.kill();
	// 		coinCount++;
	// 	}
	// }
}

enum CayaoteJumpStage // enum for jump stage
{
	NotInitiated;
	Initiated;
	Passed;
}