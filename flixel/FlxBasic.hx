package flixel;

import flixel.FlxG;
import flixel.interfaces.IFlxDestroyable;
import flixel.system.FlxCollisionType;
import flixel.util.FlxStringUtil;

/**
 * This is a useful "generic" Flixel object. Both <code>FlxObject</code> and 
 * <code>FlxGroup</code> extend this class. Has no size, position or graphical data.
 */
class FlxBasic implements IFlxDestroyable
{
	/**
	 * IDs seem like they could be pretty useful, huh?
	 * They're not actually used for anything yet though.
	 */
	public var ID:Int = -1;
	/**
	 * An array of camera objects that this object will use during <code>draw()</code>. This value will initialize itself during the first draw to automatically
	 * point at the main camera list out in <code>FlxG</code> unless you already set it. You can also change it afterward too, very flexible!
	 */
	public var cameras:Array<FlxCamera>;
	/**
	 * Controls whether <code>update()</code> is automatically called by FlxState/FlxGroup.
	 */
	public var active(default, set):Bool = true;
	/**
	 * Controls whether <code>draw()</code> is automatically called by FlxState/FlxGroup.
	 */
	public var visible(default, set):Bool = true;
	/**
	 * Useful state for many game objects - "dead" (!alive) vs alive.
	 * <code>kill()</code> and <code>revive()</code> both flip this switch (along with exists, but you can override that).
	 */
	public var alive(default, set):Bool = true;
	/**
	 * This flag indicates whether this objects has been destroyed or not. Cannot be set, use <code>destroy()</code> and <code>revive()</code>.
	 */
	public var exists(default, set):Bool = true;
	
	/**
	 * Enum that informs the collision system which type of object this is (to avoid expensive type casting).
	 */
	public var collisionType(default, null):FlxCollisionType;
	
	#if !FLX_NO_DEBUG
	/**
	 * Setting this to true will prevent the object from appearing
	 * when the visual debug mode in the debugger overlay is toggled on.
	 */
	public var ignoreDrawDebug:Bool = false;
	/**
	 * Static counters for performance tracking.
	 */
	static public var _ACTIVECOUNT:Int = 0;
	static public var _VISIBLECOUNT:Int = 0;
	#end
	
	public function new() 
	{ 
		collisionType = FlxCollisionType.NONE;
	}
	
	/**
	 * WARNING: This will remove this object entirely. Use <code>kill()</code> if you want to disable it temporarily only and <code>revive()</code> it later.
	 * Override this function to null out variables manually or call destroy() on class members if necessary. Don't forget to call super.destroy()!
	 */
	public function destroy():Void 
	{
		exists = false;
		collisionType = null;
	}
	
	/**
	 * Handy function for "killing" game objects. Use <code>reset()</code> to revive them. Default behavior is to flag them as nonexistent AND dead. However, if you want the 
	 * "corpse" to remain in the game, like to animate an effect or whatever, you should override this, setting only alive to false, and leaving exists true.
	 */
	public function kill():Void
	{
		alive = false;
		exists = false;
	}
	
	/**
	 * Handy function for bringing game objects "back to life". Just sets alive and exists back to true.
	 * In practice, this function is most often called by <code>FlxObject.reset()</code>.
	 */
	public function revive():Void
	{
		alive = true;
		exists = true;
	}
	
	/**
	 * Override this function to update your class's position and appearance.
	 * This is where most of your game rules and behavioral code will go.
	 */
	public function update():Void 
	{ 
		#if !FLX_NO_DEBUG
		_ACTIVECOUNT++;
		#end
	}
	
	/**
	 * Override this function to control how the object is drawn.
	 * Overriding <code>draw()</code> is rarely necessary, but can be very useful.
	 */
	public function draw():Void
	{
		#if !FLX_NO_DEBUG
		if (cameras == null)
		{
			cameras = FlxG.cameras.list;
		}
		
		for (camera in cameras)
		{
			_VISIBLECOUNT++;
		}
		#end
	}
	
	#if !FLX_NO_DEBUG
	public function drawDebug():Void
	{
		if (!ignoreDrawDebug)
		{
			var i:Int = 0;
			if (cameras == null)
			{
				cameras = FlxG.cameras.list;
			}
			var l:Int = cameras.length;
			while (i < l)
			{
				drawDebugOnCamera(cameras[i++]);
			}
		}
	}
	
	/**
	 * Override this function to draw custom "debug mode" graphics to the
	 * specified camera while the debugger's visual mode is toggled on.
	 * @param	Camera	Which camera to draw the debug visuals to.
	 */
	public function drawDebugOnCamera(?Camera:FlxCamera):Void { }
	#end
	
	/**
	 * Property setters, to provide override functionality in sub-classes
	 */
	private function set_visible(Value:Bool):Bool
	{
		return visible = Value;
	}
	private function set_active(Value:Bool):Bool
	{
		return active = Value;
	}
	private function set_alive(Value:Bool):Bool
	{
		return alive = Value;
	}
	private function set_exists(Value:Bool):Bool
	{
		return exists = Value;
	}
	
	/**
	 * Convert object to readable string name.  Useful for debugging, save games, etc.
	 */
	public function toString():String
	{
		return "(active: " + active + " | visible: " +  visible + " | alive: " +  alive + " | exists: " +  exists + ")"; 
	}
}