package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import math.Vector3;

using StringTools;

class StrumNote extends FlxSprite
{
	public var vec3Cache:Vector3 = new Vector3(); // for vector3 operations in modchart code
	public var defScale:FlxPoint = FlxPoint.get(); // for modcharts to keep the scaling

	override function destroy()
	{
		defScale.put();
		super.destroy();
	}	
	public var isQuant:Bool = false;
	private var colorSwap:ColorSwap;
	public var resetAnim:Float = 0;
	public var noteData:Int = 0;
	public var direction:Float = 90;//plan on doing scroll directions soon -bb
	public var downScroll:Bool = false;//plan on doing scroll directions soon -bb
	public var sustainReduce:Bool = true;
	
	private var player:Int;
	
	public var texture(default, set):String = null;
	private function set_texture(value:String):String {
		if(texture != value) {
			texture = value;
			reloadNote();
		}
		return value;
	}

	public function new(x:Float, y:Float, leData:Int, player:Int) {
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		noteData = leData;
		this.player = player;
		this.noteData = leData;
		super(x, y);

		var skin:String = 'NOTE_assets';
		if(PlayState.SONG.arrowSkin != null && PlayState.SONG.arrowSkin.length > 1) skin = PlayState.SONG.arrowSkin;
		texture = skin; //Load texture and anims

		scrollFactor.set();
	}

	public function reloadNote()
	{
		isQuant = false;
		var lastAnim:String = null;
		if(animation.curAnim != null) lastAnim = animation.curAnim.name;
		var br:String = texture;
		if (ClientPrefs.noteSkin == 'Quants')
		{
			trace(Paths.getPath("images/QUANT" + texture + ".png", IMAGE));
			if (Paths.exists(Paths.getPath("images/QUANT" + texture + ".png", IMAGE)))
			{
				br = "QUANT" + texture;
				isQuant = true;
			}
		}

		frames = Paths.getSparrowAtlas(br);
		animation.addByPrefix('green', 'arrowUP');
		animation.addByPrefix('blue', 'arrowDOWN');
		animation.addByPrefix('purple', 'arrowLEFT');
		animation.addByPrefix('red', 'arrowRIGHT');

		antialiasing = ClientPrefs.globalAntialiasing;
		setGraphicSize(Std.int(width * 0.7));

		switch (Math.abs(noteData) % 4)
		{
			case 0:
				animation.addByPrefix('static', 'arrowLEFT');
				animation.addByPrefix('pressed', 'left press', 24, false);
				animation.addByPrefix('confirm', 'left confirm', 24, false);
			case 1:
				animation.addByPrefix('static', 'arrowDOWN');
				animation.addByPrefix('pressed', 'down press', 24, false);
				animation.addByPrefix('confirm', 'down confirm', 24, false);
			case 2:
				animation.addByPrefix('static', 'arrowUP');
				animation.addByPrefix('pressed', 'up press', 24, false);
				animation.addByPrefix('confirm', 'up confirm', 24, false);
			case 3:
				animation.addByPrefix('static', 'arrowRIGHT');
				animation.addByPrefix('pressed', 'right press', 24, false);
				animation.addByPrefix('confirm', 'right confirm', 24, false);
		}
		
		defScale.copyFrom(scale);
		updateHitbox();

		if(lastAnim != null)
		{
			playAnim(lastAnim, true);
		}
	}

	public function postAddedToGroup() {
		playAnim('static');
		x += Note.swagWidth * noteData;
		x += 50;
		x += ((FlxG.width* 0.5) * player);
		ID = noteData;
	}

	override function update(elapsed:Float) {
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}
		//if(animation.curAnim != null){ //my bad i was upset
		if(animation.curAnim.name == 'confirm') {
			centerOrigin();
		//}
		}

		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false, ?note:Note) {
		animation.play(anim, force);
		centerOffsets();
		centerOrigin();
		if(animation.curAnim == null || animation.curAnim.name == 'static') {
			colorSwap.hue = 0;
			colorSwap.saturation = 0;
			colorSwap.brightness = 0;
		} else {
			if (note == null)
			{
				if(!isQuant){
					colorSwap.hue = ClientPrefs.arrowHSV[noteData % 4][0] / 360;
					colorSwap.saturation = ClientPrefs.arrowHSV[noteData % 4][1] / 100;
					colorSwap.brightness = ClientPrefs.arrowHSV[noteData % 4][2] / 100;
				}else{
					colorSwap.hue =  0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
				}
			}
			else
			{
				// ok now the quants should b fine lol
				colorSwap.hue = note.colorSwap.hue;
				colorSwap.saturation = note.colorSwap.saturation;
				colorSwap.brightness = note.colorSwap.brightness;
			}

			if(animation.curAnim.name == 'confirm') {
				centerOrigin();
			}
		}
	}
}