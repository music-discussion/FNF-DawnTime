package;

import Controls.Control;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.FlxCamera;

import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.util.FlxAxes;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
import openfl.text.TextFormatAlign;

import editors.ChartingState;
import flash.display.BitmapData;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;

using StringTools;

class SearchSubstate extends MusicBeatSubstate
{
    public var textBox:TextField;
    public var canvas:FlxSprite;

    public function new()
    {
        super();

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

        var hintText:FlxText = new FlxText(12, FlxG.height - 24, 0, "Press ESCAPE to Exit", 16);
		hintText.scrollFactor.set();
		hintText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(hintText);

        var searchText:FlxText = new FlxText(12, 300, 0, "Search", 12);
		searchText.scrollFactor.set();
        searchText.screenCenter(FlxAxes.XY);
        searchText.y -= 30;
		searchText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(searchText);

        var defaultTextFormat = new TextFormat("VCR OSD Mono", 15, 0xff000000);
		defaultTextFormat.align = TextFormatAlign.CENTER;

        textBox = new TextField();
		textBox.background = true;
		textBox.backgroundColor = 0xffffffff;
		textBox.border = false;
		textBox.displayAsPassword = false;
		textBox.embedFonts = true;
		textBox.defaultTextFormat = defaultTextFormat;
		textBox.maxChars = 15;
		textBox.mouseWheelEnabled = false;
		textBox.multiline = false;
		textBox.type = TextFieldType.INPUT;
		textBox.text = "Search";
		textBox.height = 50;
		textBox.width = 100;
		textBox.x = searchText.x - 16;
		textBox.y = searchText.y + 60;
		textBox.visible = true;

		var bd:BitmapData = new BitmapData(25, 1000);
		bd.draw(textBox);
		canvas = new FlxSprite(200, 300);
		canvas.pixels = bd;

		FlxG.addChildBelowMouse(textBox);

        FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
    }

    var cantUnpause:Float = 0.1;
    override function update(elapsed:Float)
    {
        cantUnpause -= elapsed;
        super.update(elapsed);

        var accepted = controls.ACCEPT;
        var left = FlxG.keys.pressed.ESCAPE;

        if (left)
        {
            DesktopState.selectedSomethin = false;
            textBox.visible = false;
            close();
            return;
        }

        if (accepted && textBox.text.toLowerCase() == "dad battle")
        {
            FlxG.mouse.visible = false;
            DesktopState.selectedSomethin = true;
            FlxG.sound.play(Paths.sound('confirmMenu'));

            CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();

            var songLowercase:String = Paths.formatToSongPath("Dad Battle");
            var poop:String = Highscore.formatSong(songLowercase, 2);
            trace(poop);

            PlayState.SONG = Song.loadFromJson(poop, songLowercase);
            PlayState.isStoryMode = false;
            PlayState.storyDifficulty = 2;

            trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
            if (FlxG.keys.pressed.SHIFT){
                LoadingState.loadAndSwitchState(new ChartingState());
            }else{
                LoadingState.loadAndSwitchState(new PlayState());
            }
            FlxG.sound.music.volume = 0;
        }
    }
}