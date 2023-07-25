package bird;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.math.FlxMath;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.text.FlxText.FlxTextBorderStyle;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	
	private var bird:FlxSprite;
	private var bgArr:Array<FlxSprite>;
	private var groundArr:Array<FlxSprite>;
	private var pipeArr:Array<Pipes>;
	private var score:Int = 0;
	private var scoreText:FlxText;
	private var deadTimer:FlxTimer;
	private var grav:Float = 2;

	public static var flapSpeed:Float = 100;
	public static var forwardSpeed:Float = 100;
	public static var pipeGap:Float = 250;			//How far between pipes
	public static var groundHeight:Float = 150;
	public static var maxHoleSize:Float = 300;
	public static var minHoleSize:Float = 120;
	private static var pipeMargin:Float = 20;

	// Variables that Discussions Added
	public static var bgSizeX:Float = 3;
	public static var bgSizeY:Float = 3;
	public static var groundSize:Float = 3;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		var spritesheet:FlxAtlasFrames = FlxAtlasFrames.fromTexturePackerJson("assets/images/flappy/spritesheet2.png", "assets/images/flappy/spritesheet2.json");

		//-------------------BACKGROUND
		var i:Int = 0;
		var bgWidth:Float = (spritesheet.frames[0].sourceSize.x) * bgSizeX; 	//bg.png is the first sprite in the spritesheet
		bgArr = new Array<FlxSprite>();
		while(bgWidth * (i - 1) < FlxG.width)						//Have an extra bg for scrolling
		{
			var tempBG = new FlxSprite(bgWidth * i, 0);
			tempBG.frame = spritesheet.getByName("bg.png");
			tempBG.scale.set(bgSizeX, bgSizeY);

			tempBG.velocity.x = -forwardSpeed / 2;

			bgArr.push(tempBG);
			add(tempBG);
			i++;
		}

		//-------------------PIPES
		i = 0;
		pipeArr = new Array<Pipes>();
		var pipeWidth:Float = spritesheet.frames[6].sourceSize.x; 	//pipe cap.png is the 7th sprite in the spritesheet
		pipeMargin += spritesheet.frames[6].sourceSize.y;

		while((pipeWidth + pipeGap) * (i - 1) < FlxG.width)
		{
			var size = FlxG.random.float(minHoleSize, maxHoleSize);
			var height =  FlxG.random.float(pipeMargin + size / 2, FlxG.height - groundHeight - pipeMargin - size / 2);

			var tmp:Pipes = new Pipes(300 + i * (pipeGap + pipeWidth), height, size, spritesheet);
			tmp.setXVel(-forwardSpeed);
			
			pipeArr.push(tmp);
			add(tmp);
			i++;	
		}

		//-------------------BIRD
		bird = new FlxSprite(100, 100);
		bird.frames = spritesheet;
		var names:Array<String> = ["flap up.png","flap mid.png","flap down.png","flap mid.png"];
		bird.animation.addByNames("flapping", names, 10);
		bird.animation.addByNames("dead", ["dead.png"], 10);
		bird.animation.play("flapping");
		bird.screenCenter(FlxAxes.Y);
		bird.resetSizeFromFrame();
		bird.centerOrigin();
		bird.scale.set(3, 3);
		add(bird);

		//-------------------GROUND
		i = 0;
		groundArr = new Array<FlxSprite>();
		var groundWidth:Float = (spritesheet.frames[5].sourceSize.x) * groundSize; 	//ground.png is the 6th sprite in the spritesheet
		while(groundWidth * (i - 1) < FlxG.width)								//Have an extra ground for scrolling
		{
			var tempG = new FlxSprite(groundWidth * i, FlxG.height - groundHeight);
			tempG.frame = spritesheet.getByName("ground.png");
			tempG.scale.set(groundSize, groundSize);

			tempG.velocity.x = -forwardSpeed;

			groundArr.push(tempG);
			add(tempG);
			i++;
		}

		scoreText = new FlxText(10, 10, FlxG.width, "SCORE: " + score, 15);
		scoreText.setFormat(null, 15, "center");
		scoreText.setBorderStyle(FlxTextBorderStyle.SHADOW, 0x000000, 2);
		scoreText.x = Math.floor(scoreText.x);
		scoreText.y = Math.floor(scoreText.y);
		scoreText.antialiasing = false;
		add(scoreText);

		deadTimer = new FlxTimer();
		deadTimer.active = false;

		super.create();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	private var cantReset:Float = 1;
	/**
	 * Function that is called once every frame.
	 */
	override public function update(elapsed:Float):Void
	{
		cantReset -= elapsed;
		//Collision
		for(i in 0...pipeArr.length)
		{
			if(pipeArr[i].collided(bird))
			{
				bird.alive = false;
				bird.animation.play("dead");
				bird.velocity.x = 0;
				FlxG.sound.play(Paths.sound("die"));

				if(bird.inWorldBounds())
					bird.velocity.y = -2 * flapSpeed;

				grav *= 5;
				break;
			}
			else if(pipeArr[i].passed(bird))
			{
				score += 1;
				scoreText.text = "SCORE: " + score;
				FlxG.sound.play(Paths.sound("point"));
			}
		}

		//BG rounding fix + scrolling
		for(i in 0...bgArr.length)
			bgArr[i].x = Math.round(bgArr[i].x * 1000) / 1000;

		if(bgArr[0].x + (144 * bgSizeX) < 0)
		{
			var temp = bgArr[0];
			bgArr.remove(bgArr[0]);
			temp.x = (144 * bgSizeX) * (bgArr.length);
			bgArr.push(temp);
		}

		//Ground rounding fix + scrolling
		for(i in 0...groundArr.length)
			groundArr[i].x = Math.round(groundArr[i].x * 10000) / 10000;

		if(groundArr[0].x + (154 * groundSize) < 0)
		{
			var temp = groundArr[0];
			groundArr.remove(groundArr[0]);
			temp.x = (154 * groundSize) * (groundArr.length);
			groundArr.push(temp);
		}

		//Pipe scrolling
		if(pipeArr[0].x + (26 * 3) < 0)
		{
			var temp = pipeArr[0];
			pipeArr.remove(pipeArr[0]);
			var size = FlxG.random.float(minHoleSize, maxHoleSize);
			var height =  FlxG.random.float(pipeMargin + size / 2, FlxG.height - groundHeight - pipeMargin - size / 2);
			var xOff = pipeArr[pipeArr.length - 1].x + temp.width + pipeGap;
			temp.reposition(xOff, height, size);
			pipeArr.push(temp);
		}


		if(bird.alive && (FlxG.keys.justPressed.SPACE || FlxG.mouse.justPressed)) 
		{
			bird.velocity.y = -flapSpeed;
			FlxG.sound.play(Paths.sound("wing"));
		}

		if (FlxG.keys.justPressed.R && cantReset <= 0) // resetting a bunch glitches the pipes so lets just avoid the issue instead of fixing it.
			FlxG.resetState();

		//Ground collision
		if(bird.y + bird.height >= FlxG.height - groundHeight)
		{
			bird.alive = false;
			bird.animation.play("dead");
			bird.velocity.y = 0;
			//bird.angle = 0;
			bird.y = FlxG.height - groundHeight - bird.height;

			if(!bird.alive && !deadTimer.active)
			{
				deadTimer.start(1, function (t:FlxTimer):Void
				{
					this.openSubState(new bird.GameoverScreen(score));
				});
			}
		}
		else
			bird.velocity.y += grav;

		//FUN ROTATION
		bird.angle += bird.velocity.y / 12;

		//Boring rotation
		/*if(bird.angle <= 70 && bird.angle >= -45)
			bird.angle += bird.velocity.y / 12;
		else if(bird.angle > 70)
			bird.angle = 70;
		else if(bird.angle < -45)
			bird.angle = -45;*/

		super.update(elapsed);
	}	
}