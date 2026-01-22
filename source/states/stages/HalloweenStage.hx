package states.stages;

class HalloweenStage extends BaseStage
{
	override function create()
	{
		if(!ClientPrefs.data.lowQuality)
		{
                        var sky:BGSprite = new BGSprite('stages/halloweenStage/sky', -1248, -1041, 1, 1);
                        add(sky);

                        var moon:BGSprite = new BGSprite('stages/halloweenStage/moon', -1315, -995, 0.1, 0.1);
                        add(moon);

                        var clouds:BGSprite = new BGSprite('stages/halloweenStage/clouds', -1286, -1146, 0.2, 0.2);
                        add(clouds);
                }
                
                var buildings:BGSprite = new BGSprite('stages/halloweenStage/buildings', -1288, -1235, 0.6, 0.6);
                add(buildings);

                var bgmain:BGSprite = new BGSprite('stages/halloweenStage/bgmain', -1230, -1378, 1, 1);
                add(bgmain);

		if(!ClientPrefs.data.lowQuality)
		{
                        var lolas:BGSprite = new BGSprite('stages/halloweenStage/lolas', -17, 263, 1, 1, ['persjnaoi'], true);
                        add(lolas);
                }
	}

	override function createPost()
	{

	}
}