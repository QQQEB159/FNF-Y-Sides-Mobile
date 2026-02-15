package objects;

import objects.CheckboxThingie;

class CheckOptionObject extends FlxSpriteGroup
{
	public var background:FlxSprite;
	public var optionText:Alphabet;
	public var checkbox:CheckboxThingie;
	public var value(default, set):Bool = false;

	public function set_value(v:Bool)
	{
		checkbox.daValue = v;
		value = v;
		return v;
	}

	public function new(x:Float, y:Float, name:String, initialValue:Bool)
	{
		super(x, y);

		background = new FlxSprite();
		background.alpha = 0;
		add(background);

		optionText = new Alphabet(0, 0, name, true);
		optionText.setScale(0.5);
		add(optionText);

		checkbox = new CheckboxThingie(0, 0, initialValue);
		checkbox.scale.set(0.6, 0.6);
		//checkbox.updateHitbox();
		//checkbox.sprTracker = optionText;
		checkbox.y += -40;
		checkbox.x += -(checkbox.width + 20);
		checkbox.offsetX -= optionText.width + checkbox.width + 40;
		checkbox.offsetY = -52;
		add(checkbox);

		background.makeGraphic(Std.int(checkbox.width + 20 + optionText.width + 20), Std.int(checkbox.height - 10));
		background.x += -(checkbox.width + 20);
		background.y += -25;

		value = initialValue;
	}
}