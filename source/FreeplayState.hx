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

typedef FreeplayCharacter =
{
	var character:String;
	
	var title:String;
	var description:String;
	var hexcode:String;
	var locked:Bool;
	var weekFileName:String;
	var xAdd:Null<Float>;
	var yAdd:Null<Float>;
	var scaleX:Null<Float>;
	var scaleY:Null<Float>;
}

class FreeplayState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var characters:Array<Character> = [];
	private var freeplayList:Array<Array<Dynamic>> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;
	var descBox:AttachedSprite;

	var offsetThing:Float = -75;
	var center:Float = -1;
	var characterOffset:Float = 700;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);
		bg.screenCenter();

		var creditsList = CoolUtil.coolTextFile(Paths.txt('freeplayList'));
        for (i in 0...creditsList.length)
        {
            var name:String = creditsList[i];
            var path = "assets/dawn/images/weeks/" + name + ".json";
            if (FileSystem.exists(path))
			{
                //this means the folder exists.
                //so now we need to add it to the freeplayList.
              //  trace("folder exists: " + path);
                var files:Array<String> = [];
                files = FileSystem.readDirectory(path); //grabs all files in the directory
                var jsonc:FreeplayCharacter = null;

				var rawJson = Assets.getText(Paths.imageJson("weeks/" + name));
				var json:FreeplayCharacter = cast Json.parse(rawJson);
                jsonc = json;

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
					var array:Array<Dynamic> = [jsonc.character, jsonc.title, jsonc.description, jsonc.hexcode, jsonc.locked, xAdd, yAdd, scaleX, scaleY, jsonc.weekFileName];
					//trace(array);
                	freeplayList.push(array);
				}
            }
        }

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);
	
		for (i in 0...freeplayList.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			trace(i + " -/- " + freeplayList[i][0]);

			var text:Alphabet = new Alphabet(0, 15, freeplayList[i][1], true);
            text.menuPos = i;
            text.screenCenter(FlxAxes.X);
			grpOptions.add(text);

			var character:Character = new Character(0, 200, freeplayList[i][0], false, true);
			character.scrollFactor.set(0, 0);
			character.scale.set(freeplayList[i][7], freeplayList[i][8]);
		    character.screenCenter(X);
			if (center == -1) center = character.x;
			character.y += freeplayList[i][6];
			character.x += i * characterOffset;
		    character.antialiasing = ClientPrefs.globalAntialiasing;
			character.updateHitbox();
	
			// using a FlxGroup is too much fuss!
			characters.push(character);
			add(character);

			if(curSelected == -1) curSelected = i;

			if(!isSelectable) 
			{
				character.color = 0xff000000;
			}
		}
		
		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, 70 + 50, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER/*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		descText.scrollFactor.set();
		//descText.borderSize = 2.4;
		descBox.sprTracker = descText;
		add(descText);

		trace(freeplayList);

		bg.color = getCurrentBGColor();
		intendedColor = bg.color;
		changeSelection();

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		var leText:String = "Use the BACK control to go back. Use UI keys to traverse songs. Press F1 to reload and update the Information.";
		var size:Int = 18;
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);

		for (i in 0...characters.length)
			{
				var char:Character = characters[i];
				if (char != null) char.dance();
			}

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
			if(freeplayList.length > 1)
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

			if(controls.ACCEPT) 
			{
				if (!!unselectableCheck(curSelected))
				{
					FlxG.sound.play(Paths.soundRandom("missnote", 1, 3, "shared"));
					return;
				}
				FlxG.sound.play(Paths.sound('confirmMenu'));
				PrivateFreeplayState.currentWeek = freeplayList[curSelected][9];
				MusicBeatState.switchState(new PrivateFreeplayState());
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

		super.update(elapsed);
	}

	var moveTween:FlxTween = null;
	var enterTween:FlxTween = null;
	var leaveTween:FlxTween = null;
	function changeSelection(change:Int = 0, doTween:Bool = false, wrapAround:Bool = true)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		//trace("Switch Check (1/6)");
		curSelected += change;
		if (curSelected < 0) {
			if (wrapAround) curSelected = freeplayList.length - 1;
			else {
				curSelected = 0;
				return;
			}
		}
		if (curSelected >= freeplayList.length)
		{
			if (wrapAround) curSelected = 0;
			else {
				curSelected = freeplayList.length - 1;
				return;
			}
		}

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

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.alpha = 0;
			if (curSelected == item.menuPos)
				item.alpha = 1;
		}

		if (!unselectableCheck(curSelected)) descText.text = freeplayList[curSelected][2];
		else descText.text = descText.text = "Unlock this character first to view it's content.";

		if(moveTween != null) moveTween.cancel();
		if(enterTween != null) moveTween.cancel();
		if(leaveTween != null) moveTween.cancel();

		//trace("Switch Check (4/6)");

		//var doTween:Bool = false;

		if (doTween == true) 
		{
			for (i in 0...characters.length)
				{
					var photo:FlxSprite = characters[i];
					if (i == curSelected)
					{
						trace(i, "enterTween", curSelected);
						enterTween = FlxTween.tween(photo, {x: center, scale: {x: 2, y: 2}}, 1, {ease: FlxEase.sineOut});
					}
					else if (i == curSelected - 1)
					{
						if (i >= 0) {
							trace(i, "leaveTween", curSelected - 1);
						    leaveTween = FlxTween.tween(photo, {x: center - characterOffset, scale: {x: 1, y: 1}}, 1, {ease: FlxEase.sineOut});
						}
					}
					else if (i == curSelected + 1)
					{
						if (i <= characters.length) {
							trace(i, "moveTween", curSelected + 1);
						    moveTween = FlxTween.tween(photo, {x: center + characterOffset, scale: {x: 1, y: 1}}, 1, {ease: FlxEase.sineOut});
						}
					}
					else 
					{
						trace(i, "extra", curSelected);
						if (i > curSelected) {
							trace(center + characterOffset * (i - curSelected));
							photo.x = center + (characterOffset * (i - curSelected));	
						} else {
							trace(center - (characterOffset * (curSelected - i)));
							photo.x = center - (characterOffset * (curSelected - i));
						}
					}
				}
		} else {
			for (i in 0...characters.length)
				{
					var photo:FlxSprite = characters[i];
					if (i != curSelected) {
					//	photo.setGraphicSize(1, 1);
						photo.alpha = 0.5;
		//				trace(i, i - curSelected);

						if (i > curSelected) {
			//				trace(center + characterOffset * (i - curSelected));
							photo.x = (center + (characterOffset * (i - curSelected))) + freeplayList[i][5];	
						} else {
			//				trace(center - (characterOffset * (curSelected - i)));
							photo.x = (center - (characterOffset * (curSelected - i))) + freeplayList[i][5];
						}
					} else {
						photo.alpha = 1;
					//	photo.setGraphicSize(2, 2);
						photo.x = center + freeplayList[i][5];
					}
					//photo.updateHitbox();
				}
		}

		//trace("Switch Check (5/6)");

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
		//trace("Switch Check (6/6)");
	}

	function getCurrentBGColor() {
		var bgColor:String = freeplayList[curSelected][3];
		if (bgColor == "" || bgColor == "hexcode" || bgColor == null) 
		{
			trace("no bg color found. " + freeplayList[curSelected]);
			return 0xFFfd719b;
		}
		if(!bgColor.startsWith('0x')) {
			bgColor = '0xFF' + bgColor;
		}
		return Std.parseInt(bgColor);
	}

	private function unselectableCheck(num:Int):Bool {
		//return freeplayList[num].length <= 1;
		return freeplayList[num][4];
	}
}