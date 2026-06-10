package states;

import states.gallery.GalleryPreload;
import flixel.FlxSubState;
import flixel.util.FlxGradient;
import flixel.addons.display.FlxBackdrop;
import objects.ParticleGroup;
import objects.CheckOptionObject;
import openfl.events.KeyboardEvent;
import flixel.input.keyboard.FlxKey;

import openfl.filters.ShaderFilter;
import shaders.DeflectiveLens;
import shaders.BloomShader;
import shaders.ChromaticAberration;

import flixel.effects.FlxFlicker;
import lime.app.Application;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var bg:FlxSprite;
	var icons:FlxBackdrop;
	var particles:ParticleGroup;
	var gradient:FlxSprite;
	var gradient2:FlxSprite;
	var warningText:Alphabet;
	var infoText:Alphabet;
	var infoText2:Alphabet;
	var infoText3:Alphabet;

	var flashingLightsOpt:CheckOptionObject;
	var shadersOpt:CheckOptionObject;

	var pressEnterToContinueText:Alphabet;

	var deflectiveLensShader:DeflectiveLens;
	var deflectiveLensFilter:ShaderFilter;
	var bloomShader:BloomShader;
	var bloomFilter:ShaderFilter;
	var rgbShader:ChromaticAberration;
	var rgbFilter:ShaderFilter;

	override function create()
	{
		super.create();

		FlxG.sound.playMusic(Paths.music('initialSetup'), 0);
		FlxG.sound.music.fadeIn(1.6);

		var startTweenDuration:Float = 0.6;

		FlxG.mouse.visible = true;

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF030007);
		add(bg);

		icons = new FlxBackdrop(Paths.image('mainmenu/icons'), XY);
		icons.velocity.set(10, 10);
		icons.alpha = 1;
		icons.antialiasing = ClientPrefs.data.antialiasing;
		icons.blend = MULTIPLY;
		add(icons);

		particles = new ParticleGroup(0, 0, FlxG.width, 400, 'particle');
		//particles.y = FlxG.height - particles.height;
		particles.startY = FlxG.height;
		particles.endY = FlxG.height - 450;
		particles.initialScale = 0.25;
		particles.fadeSpeed = 0.8;
		particles.randomX = 90;
		particles.randomY = 90;
		add(particles);

		gradient = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, ([0xFF030007, 0xFF4B2E71]));
		//gradient.alpha = 0.45;
		gradient.alpha = 0;
		add(gradient);

		FlxTween.tween(gradient, {alpha: 0.45}, startTweenDuration);

		gradient2 = FlxGradient.createGradientFlxSprite(FlxG.width, Std.int(FlxG.height * 0.5), ([0xFF030007, 0xFFFFFFFF]));
		//gradient2.alpha = 0.15;
		gradient2.alpha = 0;
		gradient2.blend = ADD;
		gradient2.y = FlxG.height - gradient2.height;
		add(gradient2);

		FlxTween.tween(gradient2, {alpha: 0.15}, startTweenDuration);

		warningText = new Alphabet(0, 80, 'WARNING!', true);
		warningText.screenCenter(X);
		warningText.color = 0xFFFF877E;
		warningText.y += 10;
		warningText.alpha = 0;
		add(warningText);
		
		FlxTween.tween(warningText, {y: warningText.y - 10, alpha: 1}, startTweenDuration);

		var text:String = 'This mod contains shaders and flashing lights.';
		var text2:String = 'Before you start playing, we would like to know';
		var text3:String = 'if you wish to disable them!';
		infoText = new Alphabet(0, warningText.y + warningText.height + 10, text, true);
		infoText.setScale(0.4, 0.4);
		infoText.screenCenter(X);
		infoText.y += 10;
		infoText.alpha = 0;
		//infoText.setFormat(Paths.font("FredokaOne-Regular.ttf"), 30, 0xFFF1E7FF, CENTER);
		add(infoText);

		FlxTween.tween(infoText, {y: infoText.y - 10, alpha: 1}, startTweenDuration);

		infoText2 = new Alphabet(0, infoText.y + infoText.height + 10, text2, true);
		infoText2.setScale(0.4, 0.4);
		infoText2.screenCenter(X);
		infoText2.y += 10;
		infoText2.alpha = 0;
		//infoText2.setFormat(Paths.font("FredokaOne-Regular.ttf"), 30, 0xFFF1E7FF, CENTER);
		add(infoText2);

		FlxTween.tween(infoText2, {y: infoText2.y - 10, alpha: 1}, startTweenDuration);

		infoText3 = new Alphabet(0, infoText2.y + infoText2.height + 10, text3, true);
		infoText3.setScale(0.4, 0.4);
		infoText3.screenCenter(X);
		infoText3.y += 10;
		infoText3.alpha = 0;
		//infoText3.setFormat(Paths.font("FredokaOne-Regular.ttf"), 30, 0xFFF1E7FF, CENTER);
		add(infoText3);

		FlxTween.tween(infoText3, {y: infoText3.y - 10, alpha: 1}, startTweenDuration);

		flashingLightsOpt = new CheckOptionObject(0, 0, 'Flashing Lights', ClientPrefs.data.flashing);
		flashingLightsOpt.screenCenter(X);
		flashingLightsOpt.x += 110;
		flashingLightsOpt.y = infoText3.y + infoText3.height + 80;
		flashingLightsOpt.y += 10;
		flashingLightsOpt.checkbox.alpha = 0;
		flashingLightsOpt.optionText.alpha = 0;
		add(flashingLightsOpt);

		FlxTween.tween(flashingLightsOpt, {y: flashingLightsOpt.y - 10}, startTweenDuration);
		FlxTween.tween(flashingLightsOpt.checkbox, {alpha: 1}, startTweenDuration);
		FlxTween.tween(flashingLightsOpt.optionText, {alpha: 1}, startTweenDuration);

		shadersOpt = new CheckOptionObject(0, 0, 'Shaders', ClientPrefs.data.shaders);
		shadersOpt.screenCenter(X);
		shadersOpt.x += 110;
		shadersOpt.y = flashingLightsOpt.y + flashingLightsOpt.height - 10;
		shadersOpt.y += 10;
		shadersOpt.checkbox.alpha = 0;
		shadersOpt.optionText.alpha = 0;
		add(shadersOpt);

		FlxTween.tween(shadersOpt, {y: shadersOpt.y - 10}, startTweenDuration);
		FlxTween.tween(shadersOpt.checkbox, {alpha: 1}, startTweenDuration);
		FlxTween.tween(shadersOpt.optionText, {alpha: 1}, startTweenDuration);

		pressEnterToContinueText = new Alphabet(0, 0, 'Press ENTER to continue!', false);
		pressEnterToContinueText.setScale(0.8, 0.8);
		pressEnterToContinueText.y = FlxG.height - pressEnterToContinueText.height - 100;
		//pressEnterToContinueText.x += (128 * i) - 80;
        pressEnterToContinueText.screenCenter(X);
		pressEnterToContinueText.y += 10;
		pressEnterToContinueText.alpha = 0;
		pressEnterToContinueText.antialiasing = ClientPrefs.data.antialiasing;
		add(pressEnterToContinueText);

		FlxTween.tween(pressEnterToContinueText, {alpha: 1, y: pressEnterToContinueText.y - 10}, 0.2);

		deflectiveLensShader = new DeflectiveLens();
		deflectiveLensShader.distortionScale.value = [0.0];
		//deflectiveLensShader.fringeScale.value = [0.02];
		deflectiveLensFilter = new ShaderFilter(deflectiveLensShader);

		bloomShader = new BloomShader();
		bloomShader.dim.value = [2.0]; // 1.8
		bloomShader.Directions.value = [10.0]; // 2.0, 100.0 to remove
		bloomShader.Quality.value = [8.0]; // 8.0
		bloomShader.Size.value = [0.0]; // 8.0, 1.0

		bloomFilter = new ShaderFilter(bloomShader);

		rgbShader = new ChromaticAberration();
		rgbShader.rOffset.value = [0.0];
		rgbShader.gOffset.value = [0.0];
		rgbShader.bOffset.value = [0.0];
		rgbFilter = new ShaderFilter(rgbShader);
	}

	override function update(elapsed:Float)
	{
		if(leftState) {
			super.update(elapsed);
			return;
		}

		if(isChangingControls)
		{
			if(selectBox != null) selectBox.y = FlxMath.lerp(selectBox.y, selectBoxTargetY, elapsed * 21);
			if(controls.UI_UP_P)
			{
				controlsChangeSelect(-1);
			}

			if(controls.UI_DOWN_P)
			{
				controlsChangeSelect(1);
			}

			if(FlxG.keys.justPressed.ENTER && !selectedControl)
			{
				selectBindThing();
			}

			// in this case i want harcoded ENTER
			if(FlxG.keys.justPressed.SPACE && !selectedControl)
			{
				leftState = true;
				var tweenDuration:Float = 1.2;

				FlxTween.cancelTweensOf(explainText);
				FlxTween.cancelTweensOf(selectBox);
				FlxTween.cancelTweensOf(spaceToContinueText);
				for(obj in bindNameGrp)
				{
					FlxTween.cancelTweensOf(obj);
					FlxTween.tween(obj, {alpha: 0}, tweenDuration);
				}
				for(obj in bindAssignedGrp)
				{
					FlxTween.cancelTweensOf(obj);
					FlxTween.tween(obj, {alpha: 0}, tweenDuration);
				}

				FlxTween.cancelTweensOf(gradient);
				FlxTween.cancelTweensOf(gradient2);
				FlxTween.cancelTweensOf(particles);
				FlxTween.cancelTweensOf(icons);

				FlxTween.tween(explainText, {alpha: 0}, tweenDuration);
				FlxTween.tween(selectBox, {alpha: 0}, tweenDuration);
				FlxTween.tween(spaceToContinueText, {alpha: 0}, tweenDuration);
				
				FlxTween.tween(gradient, {alpha: 0}, tweenDuration, {ease: FlxEase.cubeOut});
				FlxTween.tween(gradient2, {alpha: 0}, tweenDuration, {ease: FlxEase.cubeOut});
				FlxTween.tween(particles, {alpha: 0}, tweenDuration, {ease: FlxEase.cubeOut});
				FlxTween.tween(icons, {alpha: 0}, tweenDuration, {ease: FlxEase.cubeOut});

				FlxG.sound.music.fadeOut(tweenDuration);
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
				new FlxTimer().start(1.5, function(t:FlxTimer)
				{
					MusicBeatState.switchState(new TitleState());
				});
			}
		}
		else
		{
			if(FlxG.mouse.overlaps(flashingLightsOpt))
			{
				FlxTween.cancelTweensOf(flashingLightsOpt.background);
				FlxTween.tween(flashingLightsOpt.background, {alpha: 0.3}, 0.05);
				if(FlxG.mouse.justPressed)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					trace('Changing from ${flashingLightsOpt.value} to ${!flashingLightsOpt.value}');
					flashingLightsOpt.value = !flashingLightsOpt.value;
				}
			}
			else
			{
				FlxTween.cancelTweensOf(flashingLightsOpt.background);
				FlxTween.tween(flashingLightsOpt.background, {alpha: 0}, 0.05);
			}

			if(FlxG.mouse.overlaps(shadersOpt))
			{
				FlxTween.cancelTweensOf(shadersOpt.background);
				FlxTween.tween(shadersOpt.background, {alpha: 0.3}, 0.05);
				if(FlxG.mouse.justPressed)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					trace('Changing from ${shadersOpt.value} to ${!shadersOpt.value}');
					shadersOpt.value = !shadersOpt.value;
				}
			}
			else
			{
				FlxTween.cancelTweensOf(shadersOpt.background);
				FlxTween.tween(shadersOpt.background, {alpha: 0}, 0.05);
			}

			if (controls.ACCEPT) {
				isChangingControls = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				var tweenDuration:Float = 1.2;

				//FlxG.camera.zoom = 1.15;
				//FlxTween.tween(FlxG.camera, {zoom: 1}, tweenDuration, {ease: FlxEase.cubeOut});

				ClientPrefs.data.shaders = shadersOpt.value;
				ClientPrefs.data.flashing = flashingLightsOpt.value;
				ClientPrefs.saveSettings();

				if(ClientPrefs.data.flashing && ClientPrefs.data.shaders) FlxG.camera.filters = [bloomFilter, rgbFilter];

				FlxTween.num(0, 1.8, tweenDuration, {ease: FlxEase.cubeOut}, function(v:Float)
				{
					deflectiveLensShader.distortionScale.value[0] = v;
				});

				FlxTween.num(0.001, 0, tweenDuration, {ease: FlxEase.cubeOut}, function(v:Float)
				{
					rgbShader.rOffset.value[0] = v;
					rgbShader.gOffset.value[0] = 0;
					rgbShader.bOffset.value[0] = -v;
				});

				FlxTween.num(1.35, 10, tweenDuration, {ease: FlxEase.cubeOut}, function(v:Float)
				{
					bloomShader.Directions.value[0] = v;
				});

				FlxTween.num(1.45, 2, tweenDuration, {ease: FlxEase.cubeOut}, function(v:Float)
				{
					bloomShader.dim.value[0] = v;
				});

				FlxTween.cancelTweensOf(gradient);
				FlxTween.cancelTweensOf(gradient2);
				//FlxTween.cancelTweensOf(particles);
				FlxTween.cancelTweensOf(infoText);
				FlxTween.cancelTweensOf(infoText2);
				FlxTween.cancelTweensOf(infoText3);
				FlxTween.cancelTweensOf(flashingLightsOpt.checkbox);
				FlxTween.cancelTweensOf(flashingLightsOpt.optionText);
				FlxTween.cancelTweensOf(flashingLightsOpt.background);
				FlxTween.cancelTweensOf(shadersOpt.checkbox);
				FlxTween.cancelTweensOf(shadersOpt.optionText);
				FlxTween.cancelTweensOf(shadersOpt.background);
				FlxTween.cancelTweensOf(pressEnterToContinueText);

				FlxTween.tween(gradient, {alpha: 0.55}, tweenDuration, {ease: FlxEase.cubeOut});
				FlxTween.tween(gradient2, {alpha: 0.25}, tweenDuration, {ease: FlxEase.cubeOut});
				//FlxTween.tween(particles, {alpha: 0}, tweenDuration, {ease: FlxEase.cubeOut});

				FlxTween.tween(warningText, {alpha: 0, y: warningText.y - 10}, tweenDuration, {ease: FlxEase.cubeOut});
				FlxTween.tween(infoText, {alpha: 0, y: infoText.y - 10}, tweenDuration, {ease: FlxEase.cubeOut});
				FlxTween.tween(infoText2, {alpha: 0, y: infoText2.y - 10}, tweenDuration, {ease: FlxEase.cubeOut});
				FlxTween.tween(infoText3, {alpha: 0, y: infoText3.y - 10}, tweenDuration, {ease: FlxEase.cubeOut});
				FlxTween.tween(flashingLightsOpt.checkbox, {alpha: 0, y: flashingLightsOpt.checkbox.y - 10}, tweenDuration, {ease: FlxEase.cubeOut});
				FlxTween.tween(flashingLightsOpt.optionText, {alpha: 0, y: flashingLightsOpt.optionText.y - 10}, tweenDuration, {ease: FlxEase.cubeOut});
				FlxTween.tween(flashingLightsOpt.background, {alpha: 0, y: flashingLightsOpt.background.y - 10}, tweenDuration, {ease: FlxEase.cubeOut});
				FlxTween.tween(shadersOpt.checkbox, {alpha: 0, y: shadersOpt.checkbox.y - 10}, tweenDuration, {ease: FlxEase.cubeOut});
				FlxTween.tween(shadersOpt.optionText, {alpha: 0, y: shadersOpt.optionText.y - 10}, tweenDuration, {ease: FlxEase.cubeOut});
				FlxTween.tween(shadersOpt.background, {alpha: 0, y: shadersOpt.background.y - 10}, tweenDuration, {ease: FlxEase.cubeOut});
				FlxTween.tween(pressEnterToContinueText, {alpha: 0, y: pressEnterToContinueText.y - 10}, tweenDuration, {ease: FlxEase.cubeOut});

				new FlxTimer().start(1.5, function(t:FlxTimer)
				{
					goToControlsConfig();
					//MusicBeatState.switchState(new TitleState());
				});
			}
		}
		super.update(elapsed);
	}

	var bindsToConfig:Array<Dynamic> = [
		['Left', 'note_left'],
		['Down', 'note_down'],
		['Up', 'note_up'],
		['Right', 'note_right'],
		['Mechanic', 'mechanic']
	];
	var explainText:FlxText;
	var spaceToContinueText:FlxText;
	var selectBox:FlxSprite;
	var bindNameGrp:FlxTypedGroup<Alphabet>;
	var bindAssignedGrp:FlxTypedGroup<Alphabet>;
	function goToControlsConfig()
	{
		explainText = new FlxText(0, 0, 0, 'To change, press ENTER and reconfig your bind. You can press ESCAPE to deselect it.');
		explainText.setFormat(Paths.font("FredokaOne-Regular.ttf"), 30, 0xFFF1E7FF, CENTER);
		explainText.screenCenter(X);
		explainText.y = 110;
		explainText.antialiasing = ClientPrefs.data.antialiasing;
		add(explainText);

		selectBox = new FlxSprite();
		selectBox.makeGraphic(850, 80, 0xFF000000);
		selectBox.screenCenter(X);
		selectBox.alpha = 0.5;
		add(selectBox);

		spaceToContinueText = new FlxText(0, 0, 0, 'Press SPACE to continue');
		spaceToContinueText.setFormat(Paths.font("FredokaOne-Regular.ttf"), 30, 0xFFF1E7FF, CENTER);
		spaceToContinueText.screenCenter(X);
		spaceToContinueText.y = 630;
		spaceToContinueText.antialiasing = ClientPrefs.data.antialiasing;
		add(spaceToContinueText);

		bindNameGrp = new FlxTypedGroup<Alphabet>();
		add(bindNameGrp);

		bindAssignedGrp = new FlxTypedGroup<Alphabet>();
		add(bindAssignedGrp);

		for(num => bind in bindsToConfig)
		{
			var bindNameText = new Alphabet(200, 200 + (num * 70), bind[0], true);
			bindNameText.x = FlxG.width / 2 - 150 - 225;
			bindNameGrp.add(bindNameText);

			bindNameText.alpha = 0;
			FlxTween.tween(bindNameText, {alpha: 1}, 0.7);

			var bindAssignedText = new Alphabet(700, 200 + (num * 70), ClientPrefs.keyBinds.get(bind[1])[0]);
			bindAssignedText.x = FlxG.width / 2 + 185;
			bindAssignedGrp.add(bindAssignedText);

			bindAssignedText.alpha = 0;
			FlxTween.tween(bindAssignedText, {alpha: 1}, 0.7);
		}

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		controlsChangeSelect();
	}

	var isChangingControls:Bool = false;
	var curSelectedControls:Int = 0;
	var selectBoxTargetY:Float = 0;
	function controlsChangeSelect(change:Int = 0)
	{
		if(selectedControl) return;

		if(change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
		curSelectedControls = FlxMath.wrap(curSelectedControls + change, 0, bindsToConfig.length - 1);

		selectBoxTargetY = bindNameGrp.members[curSelectedControls].y + bindNameGrp.members[curSelectedControls].height / 2 - selectBox.height / 2;
	}

	function selectBindThing()
	{
		bindNameGrp.members[curSelectedControls].color = 0xFFF7F16A;
		bindAssignedGrp.members[curSelectedControls].color = 0xFFF7F16A;

		FlxG.sound.play(Paths.sound('confirmMenuFlash'));
		selectedControl = true;
	}

	var selectedControl:Bool = false;
	function onKeyPress(event:KeyboardEvent)
	{
		var eventKey:FlxKey = event.keyCode;
		//if(eventKey == LEFT || eventKey == DOWN || eventKey == UP || eventKey == RIGHT || eventKey == ENTER) return;

		if(!selectedControl) return;
		if(eventKey == ESCAPE) return;

		var ogArray:Array<FlxKey> = ClientPrefs.keyBinds.get(bindsToConfig[curSelectedControls][1]);
		ogArray.remove(ogArray[0]);
		ogArray.unshift(eventKey);

		ClientPrefs.keyBinds.set(bindsToConfig[curSelectedControls][1], ogArray);
		bindAssignedGrp.members[curSelectedControls].text = ClientPrefs.keyBinds.get(bindsToConfig[curSelectedControls][1])[0];
		bindAssignedGrp.members[curSelectedControls].color = 0xFFF7F16A;
		FlxG.sound.play(Paths.sound('keyInput'));

		new FlxTimer().start(0.1, function(tmr:FlxTimer)
		{
			bindNameGrp.members[curSelectedControls].color = 0xFFFFFFFF;
			bindAssignedGrp.members[curSelectedControls].color = 0xFFFFFFFF;
			selectedControl = false;
			trace(selectedControl);
		});
	}
}