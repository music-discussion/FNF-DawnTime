package;

import openfl.display.DisplayObject;
import openfl.display.Sprite;    
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
import openfl.display.DisplayObjectContainer;
import openfl.display.DisplayObject;

class ObjectManager extends DisplayObjectContainer 
{
    public function new() 
    {
        super();
    }
    public function addToScreen(child: DisplayObject)
    {
        this.addChild(child);
    }
}