package bird;

import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxSave;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class GameoverScreen extends FlxSubState
{
	private var scoreSave:FlxSave;

	public function new(score:Int)
	{
		super();

		//------------- TODO: Highscores! -------------//
	/*	scoreSave = new FlxSave();
		scoreSave.bind("highscores");

		if(scoreSave.data.highNames == null)
		{
			var highNames:Array<String> = new Array<String>();
			var highScores:Array<Int> = new Array<Int>();

			for (i in 0...10) 
				highNames.push("Eric the Great");

			highScores.push(20);
			highScores.push(40);
			highScores.push(60);
			highScores.push(80);
			highScores.push(100);
			highScores.push(200);
			highScores.push(400);
			highScores.push(600);
			highScores.push(800);
			highScores.push(1000);

			scoreSave.data.highNames = highNames;
			scoreSave.data.highScores = highScores;
		}*/

		var bgOverlay:FlxSprite = new FlxSprite(0, 0);
		bgOverlay.makeGraphic(FlxG.width, FlxG.height, 0x80000000);
		add(bgOverlay);

		var spritesheet:FlxAtlasFrames = FlxAtlasFrames.fromTexturePackerJson("assets/images/flappy/spritesheet2.png", "assets/images/flappy/spritesheet2.json");
		var gameoverSprite:FlxSprite = new FlxSprite(0, 70);
		gameoverSprite.frame = spritesheet.getByName("gameover.png");
		gameoverSprite.scale.x = 2;
		gameoverSprite.scale.y = 2;
		gameoverSprite.updateHitbox();
		gameoverSprite.x = (FlxG.width - gameoverSprite.width) / 2;
		add(gameoverSprite);

		var pressAnything:FlxText = new FlxText(0, 200, FlxG.width, "SCORE: " + Std.string(score) + "\nPress space to restart.\nPress escape to leave.", 13);
		pressAnything.setFormat(null, 13, "center");

		#if mobile
			pressAnything.text = "SCORE: " + Std.string(score) + "\nTap anywhere to restart.\nPress escape to leave.";
		#end

		add(pressAnything);
	}

	override public function update(elasped:Float):Void
	{
		if(FlxG.keys.justReleased.SPACE || FlxG.mouse.justReleased)
		{
			//FlxG.state.closeSubState();
			FlxG.resetState();
		}
		if (FlxG.keys.anyJustPressed([FlxKey.ESCAPE, FlxKey.BACKSPACE]))
		{
			FlxG.switchState(new bird.MenuState());
			return;
		}

		super.update(elasped);
	}
}