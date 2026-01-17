package states.stages;

import states.stages.objects.*;
import objects.Character;

class SkiStage extends BaseStage
{
	override function create()
	{
		var sky:BGSprite = new BGSprite('stages/skiStage/sky', 0, 0, 1, 1);
		add(sky);

		var sun:BGSprite = new BGSprite('stages/skiStage/sun', 0, 0, 1, 1);
		add(sun);

		var sunLight:BGSprite = new BGSprite('stages/skiStage/sun_light', 0, 0, 1, 1);
		add(sunLight);

		var mountains:BGSprite = new BGSprite('stages/skiStage/mountains', 0, 0, 1, 1);
		add(mountains);

		var mountainsFront:BGSprite = new BGSprite('stages/skiStage/mountainsFront', 0, 0, 1, 1);
		add(mountainsFront);

		var city:BGSprite = new BGSprite('stages/skiStage/city', 0, 0, 1, 1);
		add(city);

		var cityFront:BGSprite = new BGSprite('stages/skiStage/cityFront', 0, 0, 1, 1);
		add(cityFront);

		var fence:BGSprite = new BGSprite('stages/skiStage/fence', 0, 0, 1, 1);
		add(fence);

		var snow:BGSprite = new BGSprite('stages/skiStage/snow', 0, 0, 1, 1);
		add(snow);

		var buildings:BGSprite = new BGSprite('stages/skiStage/buildings', 0, 0, 1, 1);
		add(buildings);
		
		var snowboards:BGSprite = new BGSprite('stages/skiStage/snowboards', 0, 0, 1, 1);
		add(snowboards);
	}

	override function createPost()
	{
		var lights:BGSprite = new BGSprite('stages/skiStage/lights', 0, 0, 1, 1);
		add(lights);

		var shadow:BGSprite = new BGSprite('stages/skiStage/shadow', 0, 0, 1, 1);
		add(shadow);
	}
}