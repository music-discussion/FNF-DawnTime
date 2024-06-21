package;

import haxe.Timer;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.display.BitmapData;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.FlxCamera;

class FreezeFrameTransition extends MusicBeatSubstate 
{
	public static var finishCallback:Void->Void;
	private var leTween:FlxTween = null;
	public static var nextCamera:FlxCamera;
	var isTransIn:Bool = false;
    var gameScreenShot:FlxSprite;

	public function new(isTransIn:Bool, tweenOutDur:Null<Float> = null) {
		super();

		this.isTransIn = isTransIn;
		var zoom:Float = CoolUtil.boundTo(FlxG.camera.zoom, 0.05, 1);
		var width:Int = Std.int(FlxG.width / zoom);
		var height:Int = Std.int(FlxG.height / zoom);

		gameScreenShot = new FlxSprite().loadGraphic(BitmapData.fromImage(FlxG.stage.window.readPixels()), false, width, height);
        gameScreenShot.scrollFactor.set();
		add(gameScreenShot);

		if(nextCamera != null) {
			gameScreenShot.cameras = [nextCamera];
		}
		nextCamera = null;

        if (isTransIn) {
            FlxTween.tween(gameScreenShot, {x:1280}, tweenOutDur, {
				onComplete: function(twn:FlxTween) {
                    close();
				},
			ease: FlxEase.linear});
        } else {
            Timer.delay(function()
                {
                    if(finishCallback != null) {
						finishCallback();
					}
                }, 100);
        }
	}

	override function destroy() {
		if(leTween != null) {
			finishCallback();
			leTween.cancel();
		}
		super.destroy();
	}
}