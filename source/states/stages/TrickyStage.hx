package states.stages;

import states.stages.objects.*;
import objects.Character;

class TrickyStage extends BaseStage
{
	override function create()
	{
		var bg:BGSprite = new BGSprite('stages/trickyStage/bg', -1350, -1020, 1, 1);
        bg.scale.set(2, 2);
        bg.updateHitbox();
		add(bg);
	}
}