package test;

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
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
    /**
	 * Function that is called up when to state is created to set it up. 
	 */
    public static var walls:FlxSprite;
    public var player:Player;

    override public function create():Void
    {
        walls = new FlxSprite(0, 700);
        walls.makeGraphic(300, 50, FlxColor.BLUE);
        walls.screenCenter(FlxAxes.X);
        walls.immovable = true;
        walls.updateHitbox();
        add(walls);

        player = new Player(0, 0, 'dawnassets/mainmenu/useless');
        player.screenCenter(FlxAxes.XY);
        add(player);
        walls.y = player.y + 100;
        walls.updateHitbox();
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

    /**
	 * Function that is called once every frame.
	 */
	override public function update(elapsed:Float):Void
    {
        if (FlxG.keys.anyJustPressed([FlxKey.ESCAPE, FlxKey.BACKSPACE]))
        {
            FlxG.switchState(new DesktopState());
            return;
        }
        super.update(elapsed);
    }
}