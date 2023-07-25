package bird;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxObject;
import flixel.FlxG;

/**
 * An extended FlxObject that handles pipes and their positions.
 * This took wayyy too long to convert to 4.0.0 Haxe. (this was made in 3.0.0) like 3 hours
 */
class Pipes extends FlxObject
{
	private var pipeCap1:FlxSprite;
	private var pipeCap2:FlxSprite;
	private var pipeBod1:FlxSprite;
	private var pipeBod2:FlxSprite;
	private var hasPassed:Bool;

	public function new(xOffset:Float, holeHeight:Float, holeSize:Float, spritesheet:FlxAtlasFrames)
	{
		super();

		x = xOffset;
		y = 0;

		pipeCap2 = new FlxSprite(xOffset, holeSize / 2 + holeHeight);
		pipeCap2.frame = spritesheet.getByName("pipe cap.png");
		pipeCap2.scale.set(3, 3);

		pipeCap1 = new FlxSprite(xOffset, holeHeight - holeSize / 2 - pipeCap2.height);
		pipeCap1.frame = spritesheet.getByName("pipe cap.png");
		pipeCap1.flipY = true;
		pipeCap1.scale.set(3, 3);

		pipeBod2 = new FlxSprite(xOffset, 0);
		pipeBod2.frame = spritesheet.getByName("pipe main.png");
		pipeBod2.scale.set(3, 3);

		pipeBod1 = new FlxSprite(xOffset, 0);
		pipeBod1.frame = spritesheet.getByName("pipe main.png");
		pipeBod1.scale.set(3, 3);

		var pipe1Scale:Float = getPipe1Scale(pipeCap1.y, pipeCap1.height);
		var pipe2Scale:Float = getPipe2Scale(pipeCap2.y, pipeCap2.height);

		pipeBod1.scale.y = pipe1Scale;
		pipeBod1.updateHitbox();
		pipeBod1.y = 0;
		
		pipeBod2.scale.y = pipe2Scale;
		pipeBod2.updateHitbox();
		pipeBod2.y = pipeCap2.y + pipeCap2.height;

		height = FlxG.height - PlayState.groundHeight;
		width = pipeCap1.width;
		// trace("Pipe 1: " + pipe1Scale + ", " + pipeCap1.y + ", " + pipeCap1.height);
		// trace("Pipe 2: " + pipe2Scale + ", " + FlxG.height + ", " + pipeCap2.y + ", " + pipeCap2.height);
	}

	public function collided(bird:FlxSprite):Bool
	{
		if(!bird.alive)
			return false;

		if(!bird.inWorldBounds() && bird.x >= x)
			return true;

		if(bird.overlaps(pipeCap1) || bird.overlaps(pipeCap2) || bird.overlaps(pipeBod1) || bird.overlaps(pipeBod2))
			return true;

		return false;
	}

	public function passed(bird:FlxSprite):Bool
	{
		if(!bird.alive || hasPassed)
			return false;
		else if(bird.x > x + width)
		{
			hasPassed = true;
			return true;
		}

		return false;
	}
	
	public function setXVel(vel:Float):Void
	{
		pipeCap1.velocity.x = vel;
		pipeCap2.velocity.x = vel;
		pipeBod1.velocity.x = vel;
		pipeBod2.velocity.x = vel;
		velocity.x = vel;
	}

	public function getPipe1Scale(yNum:Float, heightNum:Float):Float
	{
		return ((yNum - heightNum) / 6) + 1;
	}

	public function getPipe2Scale(yNum:Float, heightNum:Float):Float
	{
		// I'm not dividing this by 6 because there is no point.
		return (FlxG.height - PlayState.groundHeight - yNum - heightNum) - 1;
	}

	public function reposition(xOffset:Float, holeHeight:Float, holeSize:Float):Void
	{
		hasPassed = false;

		x = xOffset;

		pipeBod1.scale.y = 1;
		pipeBod1.updateHitbox();
		pipeBod2.scale.y = 1;
		pipeBod2.updateHitbox();

		pipeCap1.x = xOffset;
		pipeCap2.x = xOffset;
		pipeBod1.x = xOffset;
		pipeBod2.x = xOffset;

		pipeCap1.y = holeHeight - holeSize / 2 - pipeCap2.height;
		pipeCap2.y = holeSize / 2 + holeHeight;

		var pipe1Scale:Float = getPipe1Scale(pipeCap1.y, pipeCap1.height);
		var pipe2Scale:Float = getPipe2Scale(pipeCap2.y, pipeCap2.height);
		
		pipeBod1.scale.y = pipe1Scale;
		pipeBod1.updateHitbox();
		pipeBod1.y = 0;
		
		pipeBod2.scale.y = pipe2Scale;
		pipeBod2.updateHitbox();
		pipeBod2.y = pipeCap2.y + pipeCap2.height - 1;
	}

	override public function draw()
	{
		pipeBod1.draw();
		pipeBod2.draw();
		pipeCap1.draw();
		pipeCap2.draw();

		super.draw();
	}

	override public function update(elasped:Float)
	{
		pipeCap1.update(elasped);
		pipeCap2.update(elasped);
		pipeBod1.update(elasped);
		pipeBod2.update(elasped);

		super.update(elasped);
	}
}