package flixel.input.touch;

import flash.geom.Point;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxPoint;

/**
 * Helper class, contains and track touch points in your game.
 * Automatically accounts for parallax scrolling, etc.
 */
class FlxTouch extends FlxPoint
{	
	/**
	 * A unique identification number (as an Int) assigned to the touch point. 
	 */
	public var touchPointID(default, null):Int;
	/**
	 * Current X position of the touch point on the screen.
	 */
	public var screenX:Int = 0;
	/**
	 * Current Y position of the touch point on the screen.
	 */
	public var screenY:Int = 0;
	
	/**
	 * Helper variable for tracking whether the touch was just began or just ended.
	 */
	@:allow(flixel.input.touch.FlxTouchManager)
	private var _current:Int = 0;
	/**
	 * Helper variable for tracking whether the touch was just began or just ended.
	 */
	@:allow(flixel.input.touch.FlxTouchManager)
	private var _last:Int = 0;
	/**
	 * Helper variables for recording purposes.
	 */
	private var _point:FlxPoint;
	/**
	 * Internal helper var storing the global screen position.
	 */
	private var _globalScreenPosition:FlxPoint;
	/**
	 * Internal helper var for updateTouchPosition().
	 */
	private var _flashPoint:Point;
	
	/**
	 * Constructor
	 * 
	 * @param	X			stageX touch coordinate
	 * @param	Y			stageX touch coordinate
	 * @param	PointID		touchPointID of the touch
	 */
	public function new(X:Float = 0, Y:Float = 0, PointID:Int = 0)
	{
		super();
		_point = new FlxPoint();
		_globalScreenPosition = new FlxPoint();
		
		_flashPoint = new Point();
		updateTouchPosition(X, Y);
		touchPointID = PointID;
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		_point = null;
		_globalScreenPosition = null;
		_flashPoint = null;
	}

	/**
	 * Called by the internal game loop to update the just pressed/just released flags.
	 */
	public function update():Void
	{
		if ((_last == -1) && (_current == -1))
		{
			_current = 0;
		}
		else if ((_last == 2) && (_current == 2))
		{
			_current = 1;
		}
		_last = _current;
	}
	
	/**
	 * Function for updating touch coordinates. Called by the TouchManager.
	 * 
	 * @param	X	stageX touch coordinate
	 * @param	Y	stageY touch coordinate
	 */
	public function updateTouchPosition(X:Float, Y:Float):Void
	{
		_flashPoint.x = X;
		_flashPoint.y = Y;
		_flashPoint = FlxG.game.globalToLocal(_flashPoint);
		
		_globalScreenPosition.x = _flashPoint.x;
		_globalScreenPosition.y = _flashPoint.y;
		updateCursor();
	}
	
	/**
	 * Internal function for helping to update world coordinates.
	 */
	private function updateCursor():Void
	{
		//update the x, y, screenX, and screenY variables based on the default camera.
		//This is basically a combination of getWorldPosition() and getScreenPosition()
		var camera:FlxCamera = FlxG.camera;
		screenX = Math.floor((_globalScreenPosition.x - camera.x) / camera.zoom);
		screenY = Math.floor((_globalScreenPosition.y - camera.y) / camera.zoom);
		x = screenX + camera.scroll.x;
		y = screenY + camera.scroll.y;
	}
	
	/**
	 * Fetch the world position of the touch on any given camera.
	 * NOTE: Touch.x and Touch.y also store the world position of the touch point on the main camera.
	 * 
	 * @param 	Camera	If unspecified, first/main global camera is used instead.
	 * @param 	point	An existing point object to store the results (if you don't want a new one created). 
	 * @return 	The touch point's location in world space.
	 */
	public function getWorldPosition(?Camera:FlxCamera, ?point:FlxPoint):FlxPoint
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		if (point == null)
		{
			point = new FlxPoint();
		}
		getScreenPosition(Camera,_point);
		point.x = _point.x + Camera.scroll.x;
		point.y = _point.y + Camera.scroll.y;
		return point;
	}
	
	/**
	 * Fetch the screen position of the touch on any given camera.
	 * NOTE: Touch.screenX and Touch.screenY also store the screen position of the touch point on the main camera.
	 * 
	 * @param 	Camera	If unspecified, first/main global camera is used instead.
	 * @param 	point		An existing point object to store the results (if you don't want a new one created). 
	 * @return 	The touch point's location in screen space.
	 */
	public function getScreenPosition(?Camera:FlxCamera, ?point:FlxPoint):FlxPoint
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		if (point == null)
		{
			point = new FlxPoint();
		}
		point.x = (_globalScreenPosition.x - Camera.x) / Camera.zoom;
		point.y = (_globalScreenPosition.y - Camera.y) / Camera.zoom;
		return point;
	}
	
	/**
	 * Checks to see if some <code>FlxObject</code> overlaps this <code>FlxObject</code> or <code>FlxGroup</code>.
	 * If the group has a LOT of things in it, it might be faster to use <code>FlxG.overlaps()</code>.
	 * WARNING: Currently tilemaps do NOT support screen space overlap checks!
	 * 
	 * @param 	ObjectOrGroup The object or group being tested.
	 * @param 	Camera Specify which game camera you want. If null getScreenXY() will just grab the first global camera.
	 * @return 	Whether or not the two objects overlap.
	*/
	public function overlaps(ObjectOrGroup:FlxBasic, ?Camera:FlxCamera):Bool
	{
		if (Std.is(ObjectOrGroup, FlxTypedGroup))
		{
			var i:Int = 0;
			var results:Bool = false;
			var basic:FlxBasic;
			var grp:FlxTypedGroup<FlxBasic> = cast ObjectOrGroup;
			var members:Array<FlxBasic> = grp.members;
			while (i < grp.length)
			{
				basic = members[i++];
				if (basic != null && basic.exists && overlaps(basic, Camera))
				{
					results = true;
					break;
				}
			}
			return results;
		}
		return cast(ObjectOrGroup, FlxObject).overlapsPoint(this, true, Camera);
	}
	
	/**
	 * Resets the just pressed/just released flags and sets touch to not pressed.
	 */
	public function reset(X:Float, Y:Float, PointID:Int):Void
	{
		updateTouchPosition(X, Y);
		touchPointID = PointID;
		_current = 0;
		_last = 0;
	}
	
	public function deactivate():Void
	{
		_current = 0;
		_last = 0;
	}
	
	/**
	 * Check to see if the touch is pressed.
	 * @return	Whether the touch is pressed.
	 */
	public var pressed(get, never):Bool;
	
	inline private function get_pressed():Bool { return _current > 0; }
	
	/**
	 * Check to see if the touch was just began.
	 * @return Whether the touch was just began.
	 */
	public var justPressed(get, never):Bool;
	
	inline private function get_justPressed():Bool { return _current == 2; }
	
	/**
	 * Check to see if the touch was just ended.
	 * @return	Whether the touch was just ended.
	 */
	public var justReleased(get, never):Bool;
	
	inline private function get_justReleased():Bool { return _current == -1; }
	
	/**
	 * Check to see if the touch is active.
	 * @return	Whether the touch is active.
	 */
	public var isActive(get, never):Bool;
	
	inline private function get_isActive():Bool { return _current != 0; }
}