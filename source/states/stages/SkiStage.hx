package states.stages;

import states.stages.objects.*;
import objects.Character;

class SkiStage extends BaseStage
{
	override function create()
	{
		var sky:BGSprite = new BGSprite('stages/skiStage/sky', -1000, -1000, 0, 0);
		add(sky);

		var sun:BGSprite = new BGSprite('stages/skiStage/sun', -1000, -1000, 0, 0);
		add(sun);

		var sunLight:BGSprite = new BGSprite('stages/skiStage/sun_light', -1000, -1000, 0, 0);
		add(sunLight);

		var mountains:BGSprite = new BGSprite('stages/skiStage/mountains', -600, -500, 0.3, 0.3);
		add(mountains);

		var mountainsFront:BGSprite = new BGSprite('stages/skiStage/mountainsFront', -550, -450, 0.4, 0.4);
		add(mountainsFront);

		var city:BGSprite = new BGSprite('stages/skiStage/city', -400, -200, 0.6, 0.6);
		add(city);

		var cityFront:BGSprite = new BGSprite('stages/skiStage/cityFront', -300, -100, 0.75, 0.75);
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
		lights.blend = ADD;
		add(lights);

		var shadow:BGSprite = new BGSprite('stages/skiStage/shadow', 0, 0, 1, 1);
		add(shadow);
	}
}