package backend;

import flixel.FlxState;
import backend.PsychCamera;

class MusicBeatState extends FlxState
{
	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	public var controls(get, never):Controls;
	private function get_controls()
	{
		return Controls.instance;
	}

	var _psychCameraInitialized:Bool = false;

	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	public static function getVariables()
		return getState().variables;

	static var iconTransitionActive:Bool = false;
	static var lastIconName:String = '';
	static var lastDuration:Float = 0.5;
	override function create() {
		var skip:Bool = FlxTransitionableState.skipNextTransOut;
		#if MODS_ALLOWED Mods.updatedOnState = false; #end

		if(!_psychCameraInitialized) initPsychCamera();

		super.create();

		if(!skip) {
			if(iconTransitionActive) 
			{	
				persistentUpdate = true;
				openSubState(new IconFadeTransition(lastDuration, lastIconName, false, function() {IconFadeTransition.instance?.close();}));
			}
			else
			{
				openSubState(new CustomFadeTransition(0.5, true));
			}
		}
		FlxTransitionableState.skipNextTransOut = false;
		timePassedOnState = 0;
		
		var sprite = new FlxSprite().loadGraphic(Paths.image('mouse'));
		FlxG.mouse.load(sprite.pixels);
		
		new FlxTimer().start(1, function(t:FlxTimer) {
			PlayedTime.updateTime();
		}, 0);
	}

	public function initPsychCamera():PsychCamera
	{
		var camera = new PsychCamera();
		FlxG.cameras.reset(camera);
		FlxG.cameras.setDefaultDrawTarget(camera, true);
		_psychCameraInitialized = true;
		//trace('initialized psych camera ' + Sys.cpuTime());
		return camera;
	}

	public static var timePassedOnState:Float = 0;
	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;
		timePassedOnState += elapsed;

		updateCurStep();
		updateBeat();

		if(FlxG.mouse.justPressed) {
			if(FlxG.mouse.visible) {
				var clicks = Achievements.addScore('click');
				var clicks2 = Achievements.addScore('click2');
				trace('Clicked $clicks times...');
				trace('Clicked $clicks2 times... (V2)');
			}
		}

		if (oldStep != curStep)
		{
			if(curStep > 0)
				stepHit();

			if(PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}

		if(FlxG.save.data != null) FlxG.save.data.fullscreen = FlxG.fullscreen;
		
		stagesFunc(function(stage:BaseStage) {
			stage.update(elapsed);
		});

		if(FlxG.mouse.visible)
		{
			if(FlxG.mouse.justPressed) {
				createSplash();
			}
		}

		super.update(elapsed);
	}

    function createSplash()
	{
        trace('creating splash');
		var splash = new FlxSprite(FlxG.mouse.x, FlxG.mouse.y);
		splash.frames = Paths.getSparrowAtlas("boing");
		splash.animation.addByPrefix('s', 'boing', 24, false);
		splash.animation.play('s');
		splash.offset.set(30, 35);
		splash.antialiasing = ClientPrefs.data.antialiasing;
		splash.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]]; // add to the last camera (the one that draws on top of the others)
		add(splash);

		trace('splash position: ${splash.x}, ${splash.y} | mouse position: ${FlxG.mouse.x}, ${FlxG.mouse.y}');

		splash.animation.finishCallback = function(name:String)
		{
            if(name == 's')
            {
                splash.kill();
                trace('killin splash');
            }
        }
    }

	private function updateSection():Void
	{
		if(stepsToDo < 1) stepsToDo = Math.round(getBeatsOnSection() * 4);
		while(curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if(curStep < 0) return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if(stepsToDo > curStep) break;
				
				curSection++;
			}
		}

		if(curSection > lastSection) sectionHit();
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public static function switchState(nextState:FlxState = null) {
		if(nextState == null) nextState = FlxG.state;
		if(nextState == FlxG.state)
		{
			resetState();
			return;
		}

		if(FlxTransitionableState.skipNextTransIn) FlxG.switchState(nextState);
		else startTransition(nextState);
		FlxTransitionableState.skipNextTransIn = false;
	}
	
	public static function switchStateIcon(nextState:FlxState = null, iconName:String, duration:Float) {
		if(nextState == null) nextState = FlxG.state;
		if(nextState == FlxG.state)
		{
			resetState();
			return;
		}

		if(FlxTransitionableState.skipNextTransIn) FlxG.switchState(nextState);
		else startIconTransition(nextState, iconName, duration);
		FlxTransitionableState.skipNextTransIn = false;
	}

	public static function resetState() {
		if(FlxTransitionableState.skipNextTransIn) FlxG.resetState();
		else startTransition();
		FlxTransitionableState.skipNextTransIn = false;
	}

	// Custom made Trans in
	public static function startTransition(nextState:FlxState = null)
	{
		if(nextState == null)
			nextState = FlxG.state;

		FlxG.state.openSubState(new CustomFadeTransition(0.5, false));
		if(nextState == FlxG.state)
			CustomFadeTransition.finishCallback = function() FlxG.resetState();
		else
			CustomFadeTransition.finishCallback = function() FlxG.switchState(nextState);
	}

	public static function startIconTransition(nextState:FlxState = null, iconName:String, duration:Float, ?transIn:Bool = true)
	{
		if(nextState == null)
			nextState = FlxG.state;

		lastDuration = duration;
		iconTransitionActive = true;
		lastIconName = iconName;
		var callback:Void->Void = function() {};
		if(transIn)
		{
			callback = function()
			{
				FlxG.switchState(nextState);
			}
		}
		FlxG.state.openSubState(new IconFadeTransition(duration, iconName, transIn, callback));
	}

	public static function getState():MusicBeatState {
		return cast (FlxG.state, MusicBeatState);
	}

	public function stepHit():Void
	{
		stagesFunc(function(stage:BaseStage) {
			stage.curStep = curStep;
			stage.curDecStep = curDecStep;
			stage.stepHit();
		});

		if (curStep % 4 == 0)
			beatHit();
	}

	public var stages:Array<BaseStage> = [];
	public function beatHit():Void
	{
		//trace('Beat: ' + curBeat);
		stagesFunc(function(stage:BaseStage) {
			stage.curBeat = curBeat;
			stage.curDecBeat = curDecBeat;
			stage.beatHit();
		});
	}

	public function sectionHit():Void
	{
		//trace('Section: ' + curSection + ', Beat: ' + curBeat + ', Step: ' + curStep);
		stagesFunc(function(stage:BaseStage) {
			stage.curSection = curSection;
			stage.sectionHit();
		});
	}

	function stagesFunc(func:BaseStage->Void)
	{
		for (stage in stages)
			if(stage != null && stage.exists && stage.active)
				func(stage);
	}

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if(PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}
}
