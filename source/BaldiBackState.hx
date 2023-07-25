package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flash.text.TextField;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import lime.utils.Assets;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import flixel.FlxSubState;
import flash.media.Sound;

import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxTimer;
import flixel.util.FlxAxes;

import haxe.Json;
import haxe.format.JsonParser;

using StringTools;

typedef BaldiBackFile =
{
	var hexcode:String;
	var xAdd:Null<Float>;
	var yAdd:Null<Float>;
	var scaleX:Null<Float>;
	var scaleY:Null<Float>;
}

class BaldiBackState extends MusicBeatState 
{
	var curSelected:Int = -1;

	private var photos:Array<FlxSprite> = [];
	private var creditsStuff:Array<Array<Dynamic>> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var offsetThing:Float = -75;
	var center:Float = -1;
	var photoOffset:Float = 500;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Baldiback Menu", null);
		#end

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);
		bg.screenCenter();

		var creditsList = CoolUtil.coolTextFile(Paths.txt('baldiback'));
        for (i in 0...creditsList.length)
        {
            var name:String = creditsList[i];
            var path = "assets/dawn/images/baldiback/" + name;
            if (FileSystem.exists(path))
			{
                //this means the folder exists.
                //so now we need to add it to the photos.
              //  trace("folder exists: " + path);
                var files:Array<String> = [];
                files = FileSystem.readDirectory(path); //grabs all files in the directory
                var jsonc:BaldiBackFile = null;

                for (file in files)
				{
                    if (file.endsWith(".json")) {
						var rawJson = Assets.getText(Paths.imageJson("baldiback/" + name + "/config"));
				        var json:BaldiBackFile = cast Json.parse(rawJson);
                        jsonc = json;
                    }
                }
				if (jsonc != null) 
				{
					var xAdd:Float = 0;
					var yAdd:Float = 0;
					var scaleX:Float = 1;
					var scaleY:Float = 1;
					if (jsonc.xAdd != null) xAdd = jsonc.xAdd;
					if (jsonc.yAdd != null) yAdd = jsonc.yAdd;
					if (jsonc.scaleX != null) scaleX = jsonc.scaleX;
					if (jsonc.scaleY != null) scaleY = jsonc.scaleY;
					var array:Array<Dynamic> = ["", "", "", jsonc.hexcode, xAdd, yAdd, scaleX, scaleY];
                	creditsStuff.push(array);
				}
            }
        }

		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			trace(i + " -/- " + creditsStuff[i][0]);

			if(isSelectable) 
			{
				var pic:FlxSprite = new FlxSprite(0, 20);
            	var name:String = creditsList[i];
            	pic.loadGraphic(Paths.image('baldiback/' + name + "/image", 'dawn'));
		    	pic.scrollFactor.set(0, 0);
				pic.scale.set(creditsStuff[i][6], creditsStuff[i][7]);
            	//pic.setGraphicSize(Std.int(pic.width * photos[i].json.scale));
		    	pic.screenCenter(X);
				if (center == -1) center = pic.x;
				pic.y += creditsStuff[i][5];
				pic.x += i * photoOffset;
		    	pic.antialiasing = ClientPrefs.globalAntialiasing;
				pic.updateHitbox();			
	
				// using a FlxGroup is too much fuss!
				photos.push(pic);
            	add(pic);

				if(curSelected == -1) curSelected = i;
			}
		}

		trace(creditsStuff);

		bg.color = getCurrentBGColor();
		intendedColor = bg.color;
		changeSelection();

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		var leText:String = "Use the BACK control to go back. Use UI keys to traverse pictures. Press F1 to reload and update the Information.";
		var size:Int = 18;
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);

		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if(!quitting)
		{
			if(creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

				var upP = controls.UI_LEFT_P;
				var downP = controls.UI_RIGHT_P;

				if (upP)
				{
					changeSelection(-1 * shiftMult, false);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(1 * shiftMult, false);
					holdTime = 0;
				}

				if(controls.UI_LEFT || controls.UI_RIGHT)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

			if (FlxG.keys.justPressed.F1)
				MusicBeatState.resetState();

			if(controls.ACCEPT && (creditsStuff[curSelected][2] != null && creditsStuff[curSelected][2].length > 4)) 
			{
				CoolUtil.browserLoad(creditsStuff[curSelected][2]);
			}
			if (controls.BACK)
			{
				if(colorTween != null) {
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new DesktopState());
				quitting = true;
			}
		}

		/*
		for (item in grpOptions.members)
		{
			if(!item.isBold)
			{
				var lerpVal:Float = CoolUtil.boundTo(elapsed * 12, 0, 1);
				if(item.targetY == 0)
				{
					var lastX:Float = item.x;
					item.screenCenter(X);
					item.x = FlxMath.lerp(lastX, item.x - 70, lerpVal);
					item.forceX = item.x;
				}
				else
				{
					item.x = FlxMath.lerp(item.x, 200 + -40 * Math.abs(item.targetY), lerpVal);
					item.forceX = item.x;
				}
			}
		}
		*/
		super.update(elapsed);
	}

	var moveTween:FlxTween = null;
	var enterTween:FlxTween = null;
	var leaveTween:FlxTween = null;
	function changeSelection(change:Int = 0, doTween:Bool = false, wrapAround:Bool = true)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		//trace("Switch Check (1/6)");
		do {
			curSelected += change;
			if (curSelected < 0) {
				if (wrapAround) curSelected = creditsStuff.length - 1;
				else {
					curSelected = 0;
					return;
				}
			}
			if (curSelected >= creditsStuff.length)
			{
				if (wrapAround) curSelected = 0;
				else {
					curSelected = creditsStuff.length - 1;
					return;
				}
			}
		} while(unselectableCheck(curSelected));

		//trace("Switch Check (2/6)");

		var newColor:Int = getCurrentBGColor();
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		//trace("Switch Check (3/6)");

		if(moveTween != null) moveTween.cancel();
		if(enterTween != null) moveTween.cancel();
		if(leaveTween != null) moveTween.cancel();

		//trace("Switch Check (4/6)");

		//var doTween:Bool = false;

		if (doTween == true) 
		{
			for (i in 0...creditsStuff.length)
				{
					var photo:FlxSprite = photos[i];
					if (i == curSelected)
					{
						trace(i, "enterTween", curSelected);
						enterTween = FlxTween.tween(photo, {x: center, scale: {x: 2, y: 2}}, 1, {ease: FlxEase.sineOut});
					}
					else if (i == curSelected - 1)
					{
						if (i >= 0) {
							trace(i, "leaveTween", curSelected - 1);
						    leaveTween = FlxTween.tween(photo, {x: center - photoOffset, scale: {x: 1, y: 1}}, 1, {ease: FlxEase.sineOut});
						}
					}
					else if (i == curSelected + 1)
					{
						if (i <= creditsStuff.length) {
							trace(i, "moveTween", curSelected + 1);
						    moveTween = FlxTween.tween(photo, {x: center + photoOffset, scale: {x: 1, y: 1}}, 1, {ease: FlxEase.sineOut});
						}
					}
					else 
					{
						trace(i, "extra", curSelected);
						if (i > curSelected) {
							trace(center + photoOffset * (i - curSelected));
							photo.x = center + (photoOffset * (i - curSelected));	
						} else {
							trace(center - (photoOffset * (curSelected - i)));
							photo.x = center - (photoOffset * (curSelected - i));
						}
					}
				}
		} else {
			for (i in 0...creditsStuff.length)
				{
					var photo:FlxSprite = photos[i];
					if (i != curSelected) {
					//	photo.setGraphicSize(1, 1);
						photo.alpha = 0.5;
		//				trace(i, i - curSelected);

						if (i > curSelected) {
			//				trace(center + photoOffset * (i - curSelected));
							photo.x = (center + (photoOffset * (i - curSelected))) + creditsStuff[i][4];	
						} else {
			//				trace(center - (photoOffset * (curSelected - i)));
							photo.x = (center - (photoOffset * (curSelected - i))) + creditsStuff[i][4];
						}
					} else {
						photo.alpha = 1;
					//	photo.setGraphicSize(2, 2);
						photo.x = center + creditsStuff[i][4];
					}
					//photo.updateHitbox();
				}
		}

		//trace("Switch Check (5/6)");

		//trace("Switch Check (6/6)");
	}

	function getCurrentBGColor() {
		var bgColor:String = creditsStuff[curSelected][3];
		if (bgColor == "" || bgColor == "hexcode") 
		{
			trace("no bg color found. " + creditsStuff[curSelected]);
			return 0xff242323;
		}
		if(!bgColor.startsWith('0x')) {
			bgColor = '0xFF' + bgColor;
		}
		return Std.parseInt(bgColor);
	}

	private function unselectableCheck(num:Int):Bool {
		//return creditsStuff[num].length <= 1;
		return false;
	}
}