package;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.text.FlxText.FlxTextBorderStyle;

using StringTools;

class ExecutableSprite extends FlxSprite
{
    public var fileText:FlxText;
	public var xAdd:Float = 17.5;
	public var yAdd:Float = 150;
	public var angleAdd:Float = 0;
	public var alphaMult:Float = 1;

	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;
	public var copyVisible:Bool = false;

	public function new(x:Float, y:Float, fileName:String, ?file:String = null, ?anim:String = null, ?library:String = null, ?loop:Bool = false)
	{
		super();
		if(anim != null) {
			frames = Paths.getSparrowAtlas(file, library);
			animation.addByPrefix('idle', anim, 24, loop);
			animation.play('idle');
		} else if(file != null) {
			loadGraphic(Paths.image(file));
		}
		antialiasing = ClientPrefs.globalAntialiasing;
		scrollFactor.set();
		setPosition(x, y);
        fileText = new FlxText(x + xAdd, y + yAdd, 0, fileName + ".exe", 12);
		fileText.scrollFactor.set();
		fileText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		fileText.text = "";
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (fileText != null && this != null) {
			fileText.setPosition(this.x + xAdd, this.y + yAdd);
			fileText.scrollFactor.set(this.scrollFactor.x, this.scrollFactor.y);

			if(copyAngle)
				angle = fileText.angle + angleAdd;

			if(copyAlpha)
				alpha = fileText.alpha * alphaMult;

			if(copyVisible) 
				visible = fileText.visible;
		}
	}
}