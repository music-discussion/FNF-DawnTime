package;

import openfl.display.Sprite;
import openfl.text.TextFormat;
import openfl.display.Loader;
import openfl.display.DisplayObjectContainer;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
import openfl.text.TextFormatAlign;
import editors.ChartingState;
import flash.display.BitmapData;
//import ObjectManager;

using StringTools;

class DesktopState extends MusicBeatState
{
	public static var psychEngineVersion:String = '1.0.0'; //This is also used for Discord RPC
	public static var dawnTimeModVersion:String = '1.0.0a';
	public static var curSelected:Int = 0;
	public static var selectedSomethin:Bool = false;

	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	// there is a better way to do this but it's too late i'm afraid

	var storyModeSprite:ExecutableSprite;
	var optionsSprite:ExecutableSprite;
	var creditsMenuSprite:ExecutableSprite;
	var freeplaySprite:ExecutableSprite;

	var funnySprite:ExecutableSprite;
	var searchSprite:ExecutableSprite;
	var discordSprite:ExecutableSprite;
	var uselessSprite:ExecutableSprite;
	var baldiBackSprite:ExecutableSprite;
	var flappyBirdSprite:ExecutableSprite;

	var lastSpriteClicked:FlxSprite = null;
	var bigBackground:Bool = true;

	//var objectManager:ObjectManager;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("On the Desktop", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;
		lastSpriteClicked = null;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		if (bigBackground) 
		{
			var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('dawnassets/mainmenu/bg'));
			bg.scrollFactor.set(0, 0);
			bg.scale.set(2, 2);
			bg.updateHitbox();
			bg.screenCenter();
			bg.antialiasing = ClientPrefs.globalAntialiasing;
			add(bg);
		}
		else
		{
			var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('dawnassets/mainmenu/bg'));
			bg.scrollFactor.set(0, 0);
			bg.scale.set(1, 1);
			bg.updateHitbox();
			bg.screenCenter();
			bg.antialiasing = ClientPrefs.globalAntialiasing;
			add(bg);
		}

		// 1ST ROW SPRITES

		storyModeSprite = new ExecutableSprite(200, 35, "storymode", 'dawnassets/mainmenu/story');
		storyModeSprite.scrollFactor.set(0, 0);
		storyModeSprite.antialiasing = ClientPrefs.globalAntialiasing;
		storyModeSprite.scale.set(0.2, 0.2);
		storyModeSprite.updateHitbox();
		add(storyModeSprite);
		add(storyModeSprite.fileText);

		optionsSprite = new ExecutableSprite(370, 35, "options", 'dawnassets/mainmenu/options');
		optionsSprite.scrollFactor.set(0, 0);
		optionsSprite.antialiasing = ClientPrefs.globalAntialiasing;
		optionsSprite.scale.set(0.2, 0.2);
		optionsSprite.updateHitbox();
		add(optionsSprite);
		add(optionsSprite.fileText);

		creditsMenuSprite = new ExecutableSprite(540, 35, "credits", 'dawnassets/mainmenu/credits');
		creditsMenuSprite.scrollFactor.set(0, 0);
		creditsMenuSprite.antialiasing = ClientPrefs.globalAntialiasing;
		creditsMenuSprite.scale.set(0.2, 0.2);
		creditsMenuSprite.updateHitbox();
		add(creditsMenuSprite);
		add(creditsMenuSprite.fileText);

		freeplaySprite = new ExecutableSprite(710, 35, "freeplay", 'dawnassets/mainmenu/freeplay');
		freeplaySprite.scrollFactor.set(0, 0);
		freeplaySprite.antialiasing = ClientPrefs.globalAntialiasing;
		freeplaySprite.scale.set(1, 1);
		freeplaySprite.updateHitbox();
		add(freeplaySprite);
		add(freeplaySprite.fileText);

		// 2ND ROW SPRITES

		funnySprite = new ExecutableSprite(200, 230, "funny", 'dawnassets/mainmenu/funny');
		funnySprite.scrollFactor.set(0, 0);
		funnySprite.antialiasing = ClientPrefs.globalAntialiasing;
		funnySprite.scale.set(1.5, 1.5);
		funnySprite.updateHitbox();
		funnySprite.xAdd = 10;
		funnySprite.yAdd = 90;
		add(funnySprite);
		add(funnySprite.fileText);

		discordSprite = new ExecutableSprite(375, 230, "discord", 'dawnassets/mainmenu/discord');
		discordSprite.scrollFactor.set(0, 0);
		discordSprite.antialiasing = ClientPrefs.globalAntialiasing;
		discordSprite.scale.set(0.5, 0.5);
		discordSprite.updateHitbox();
		discordSprite.xAdd = 0;
		discordSprite.yAdd = 100;
		add(discordSprite);
		add(discordSprite.fileText);

		baldiBackSprite = new ExecutableSprite(530, 230, "baldiback", 'dawnassets/mainmenu/baldiback');
		baldiBackSprite.scrollFactor.set(0, 0);
		baldiBackSprite.antialiasing = ClientPrefs.globalAntialiasing;
		baldiBackSprite.scale.set(0.17, 0.17);
		baldiBackSprite.updateHitbox();
		baldiBackSprite.xAdd = 10;
		baldiBackSprite.yAdd = 150;
		add(baldiBackSprite);
		add(baldiBackSprite.fileText);

		uselessSprite = new ExecutableSprite(710, 230, "useless", 'dawnassets/mainmenu/useless');
		uselessSprite.scrollFactor.set(0, 0);
		uselessSprite.antialiasing = ClientPrefs.globalAntialiasing;
		uselessSprite.scale.set(0.3, 0.3);
		uselessSprite.updateHitbox();
		uselessSprite.xAdd = 8;
		uselessSprite.yAdd = 120;
		add(uselessSprite);
		add(uselessSprite.fileText);

		// 3RD ROW SPRITES

		flappyBirdSprite = new ExecutableSprite(200, 400, "flappybird", 'dawnassets/mainmenu/bird');
		flappyBirdSprite.scrollFactor.set(0, 0);
		flappyBirdSprite.antialiasing = ClientPrefs.globalAntialiasing;
		flappyBirdSprite.scale.set(0.75, 0.75);
		flappyBirdSprite.updateHitbox();
		flappyBirdSprite.xAdd = 5;
		flappyBirdSprite.yAdd = 140;
		add(flappyBirdSprite);
		add(flappyBirdSprite.fileText);

		// ?????

		searchSprite = new ExecutableSprite(200, FlxG.height - 125, "search", 'dawnassets/mainmenu/search');
		searchSprite.scrollFactor.set(0, 0);
		searchSprite.antialiasing = ClientPrefs.globalAntialiasing;
		searchSprite.scale.set(0.2, 0.2);
		searchSprite.updateHitbox();
		searchSprite.fileText.text = "";
		add(searchSprite);
		add(searchSprite.fileText);

		// continue;

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		var scale:Float = 1;

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 64, 0, "Dawn Time v" + dawnTimeModVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Dawn Engine v" + psychEngineVersion + " (Based on Psych Engine v0.7b)", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		// changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		FlxG.mouse.visible = true;
		FlxG.mouse.useSystemCursor = true;
		selectedSomethin = false;

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var uselessTimes:Int = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(PrivateFreeplayState.vocals != null) PrivateFreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (FlxG.mouse.overlaps(storyModeSprite))
			{
				if (lastSpriteClicked != storyModeSprite)
				{
					lastSpriteClicked = storyModeSprite;
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				if (FlxG.mouse.justPressed) 
				{
					FlxG.mouse.visible = false;
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					MusicBeatState.switchState(new StoryMenuState());
				}
			} else if (lastSpriteClicked == storyModeSprite && !FlxG.mouse.overlaps(storyModeSprite))
			{
				lastSpriteClicked = null;
			}

			if (FlxG.mouse.overlaps(optionsSprite))
			{
				if (lastSpriteClicked != optionsSprite)
				{
					lastSpriteClicked = optionsSprite;
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				if (FlxG.mouse.justPressed) 
				{
					FlxG.mouse.visible = false;
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					LoadingState.loadAndSwitchState(new options.OptionsState());
				}
			} else 
			if (lastSpriteClicked == optionsSprite && !FlxG.mouse.overlaps(optionsSprite))
			{
				lastSpriteClicked = null;
			}

			if (FlxG.mouse.overlaps(creditsMenuSprite))
			{
				if (lastSpriteClicked != creditsMenuSprite)
				{
					lastSpriteClicked = creditsMenuSprite;
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				if (FlxG.mouse.justPressed) 
				{
					FlxG.mouse.visible = false;
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					MusicBeatState.switchState(new CreditsState());
				}
			} else 
			if (lastSpriteClicked == creditsMenuSprite && !FlxG.mouse.overlaps(creditsMenuSprite))
			{
				lastSpriteClicked = null;
			}

			if (FlxG.mouse.overlaps(freeplaySprite))
			{
				if (lastSpriteClicked != freeplaySprite)
				{
					lastSpriteClicked = freeplaySprite;
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				if (FlxG.mouse.justPressed) 
				{
					FlxG.mouse.visible = false;
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					// load shared assets so we can load the characters.
					LoadingState.loadAndSwitchState(new FreeplayState());
				}
			} else 
			if (lastSpriteClicked == freeplaySprite && !FlxG.mouse.overlaps(freeplaySprite))
			{
				lastSpriteClicked = null;
			}

			if (FlxG.mouse.overlaps(baldiBackSprite))
				{
					if (lastSpriteClicked != baldiBackSprite)
					{
						lastSpriteClicked = baldiBackSprite;
						FlxG.sound.play(Paths.sound('scrollMenu'));
					}
					if (FlxG.mouse.justPressed) 
					{
						FlxG.mouse.visible = false;
						selectedSomethin = true;
						FlxG.sound.play(Paths.sound('confirmMenu'));
						MusicBeatState.switchState(new BaldiBackState());
					}
				} else 
				if (lastSpriteClicked == baldiBackSprite && !FlxG.mouse.overlaps(baldiBackSprite))
				{
					lastSpriteClicked = null;
				}

			if (FlxG.mouse.overlaps(searchSprite))
			{
				if (lastSpriteClicked != searchSprite)
				{
					lastSpriteClicked = searchSprite;
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				if (FlxG.mouse.justPressed) 
				{
					//FlxG.sound.play(Paths.soundRandom("missnote", 1, 3, "shared"));
					selectedSomethin = true;
					openSubState(new SearchSubstate());
				}
			} else 
			if (lastSpriteClicked == searchSprite && !FlxG.mouse.overlaps(searchSprite))
			{
				lastSpriteClicked = null;
			}

			if (FlxG.mouse.overlaps(funnySprite))
			{
				if (lastSpriteClicked != funnySprite)
				{
					lastSpriteClicked = funnySprite;
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				if (FlxG.mouse.justPressed) 
				{
					FlxG.mouse.visible = false;
					selectedSomethin = true;
					//FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxG.sound.play(Paths.soundRandom("missnote", 1, 3, "shared"));
					MusicBeatState.switchState(new FunnyState());
				}
			} else 
			if (lastSpriteClicked == funnySprite && !FlxG.mouse.overlaps(funnySprite))
			{
				lastSpriteClicked = null;
			}

			if (FlxG.mouse.overlaps(discordSprite))
			{
				if (lastSpriteClicked != discordSprite)
				{
					lastSpriteClicked = discordSprite;
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				if (FlxG.mouse.justPressed) 
				{
					FlxG.sound.play(Paths.sound('confirmMenu'));
					CoolUtil.browserLoad("https://discord.gg/S7rwkB8z");
				}
			} else 
			if (lastSpriteClicked == discordSprite && !FlxG.mouse.overlaps(discordSprite))
			{
				lastSpriteClicked = null;
			}

			if (FlxG.mouse.overlaps(uselessSprite))
			{
				if (lastSpriteClicked != uselessSprite)
				{
					lastSpriteClicked = uselessSprite;
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				if (FlxG.mouse.justPressed) 
				{
					uselessTimes++;
					if (uselessTimes == 5)
					{
						FlxG.sound.play(Paths.sound('confirmMenu'));
						FlxG.mouse.visible = false;
            			DesktopState.selectedSomethin = true;
            			FlxG.sound.play(Paths.sound('confirmMenu'));

            			CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();

            			var songLowercase:String = Paths.formatToSongPath("n-a-real");
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
					else
						FlxG.sound.play(Paths.soundRandom("missnote", 1, 3, "shared"));
				}
			} else 
			if (lastSpriteClicked == uselessSprite && !FlxG.mouse.overlaps(uselessSprite))
			{
				lastSpriteClicked = null;
			}

			if (controls.BACK)
			{
				FlxG.mouse.visible = false;
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (FlxG.mouse.overlaps(flappyBirdSprite))
				{
					if (lastSpriteClicked != flappyBirdSprite)
					{
						lastSpriteClicked = flappyBirdSprite;
						FlxG.sound.play(Paths.sound('scrollMenu'));
					}
					if (FlxG.mouse.justPressed) 
					{
						//FlxG.mouse.visible = false;
						selectedSomethin = true;
						FlxG.sound.play(Paths.sound('confirmMenu'));
						//FlxG.sound.play(Paths.soundRandom("missnote", 1, 3, "shared"));
						MusicBeatState.switchState(new bird.MenuState());
					}
				} else 
				if (lastSpriteClicked == flappyBirdSprite && !FlxG.mouse.overlaps(flappyBirdSprite))
				{
					lastSpriteClicked = null;
				}

			#if desktop
			if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				if (CoolUtil.difficulties == [])
				{
					CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
					trace("Difficulties are empty. Set them to default to prevent crash when using the Chart Editor.");
				}
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
			#if debug
			if (FlxG.keys.justPressed.SPACE)
			{
				MusicBeatState.switchState(new test.PlayState());
			}
			#end
		}

		super.update(elapsed);
	}
}
