package flixel.system.frontEnds;

import flixel.plugin.FlxPlugin;
import flixel.plugin.PathManager;
import flixel.plugin.TimerManager;
import flixel.plugin.TweenManager;
import flixel.tweens.FlxTween;
import flixel.util.FlxPath;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;

class PluginFrontEnd
{
	/**
	 * An array container for plugins.
	 */
	public var list(default, null):Array<FlxPlugin>;
	
	/**
	 * Sets up two plugins: <code>DebugPathDisplay</code> 
	 * in debugging mode and <code>TimerManager</code>
	 */
	public function new() 
	{
		list = new Array<FlxPlugin>();
		
		add(FlxTimer.manager = new TimerManager());
		add(FlxTween.manager = new TweenManager());
		add(FlxPath.manager = new PathManager());
	}
	
	/**
	 * Adds a new plugin to the global plugin array.
	 * 
	 * @param	Plugin	Any object that extends FlxPlugin. Useful for managers and other things. See flixel.plugin for some examples!
	 * @return	The same <code>FlxPlugin</code>-based plugin you passed in.
	 */
	@:generic public function add<T:FlxPlugin>(Plugin:T):T
	{
		// Don't add repeats
		for (plugin in list)
		{
			if (FlxStringUtil.sameClassName(Plugin, plugin))
			{
				return Plugin;
			}
		}
		
		// No repeats! safe to add a new instance of this plugin
		list.push(Plugin);
		return Plugin;
	}
	
	/**
	 * Retrieves a plugin based on its class name from the global plugin array.
	 * 
	 * @param	ClassType	The class name of the plugin you want to retrieve. See the <code>FlxPath</code> or <code>FlxTimer</code> constructors for example usage.
	 * @return	The plugin object, or null if no matching plugin was found.
	 */
	public function get(ClassType:Class<FlxPlugin>):FlxPlugin
	{
		for (plugin in list)
		{
			if (Std.is(plugin, ClassType))
			{
				return plugin;
			}
		}
		
		return null;
	}
	
	/**
	 * Removes an instance of a plugin from the global plugin array.
	 * 
	 * @param	Plugin	The plugin instance you want to remove.
	 * @return	The same <code>FlxPlugin</code>-based plugin you passed in.
	 */
	public function remove(Plugin:FlxPlugin):FlxPlugin
	{
		// Don't add repeats
		var i:Int = list.length - 1;
		
		while(i >= 0)
		{
			if (list[i] == Plugin)
			{
				list.splice(i, 1);
				return Plugin;
			}
			i--;
		}
		
		return Plugin;
	}
	
	/**
	 * Removes all instances of a plugin from the global plugin array.
	 * 
	 * @param	ClassType	The class name of the plugin type you want removed from the array.
	 * @return	Whether or not at least one instance of this plugin type was removed.
	 */
	public function removeType(ClassType:Class<FlxPlugin>):Bool
	{
		// Don't add repeats
		var results:Bool = false;
		var i:Int = list.length - 1;
		
		while(i >= 0)
		{
			if (Std.is(list[i], ClassType))
			{
				list.splice(i,1);
				results = true;
			}
			i--;
		}
		
		return results;
	}
	
	/**
	 * Used by the game object to call <code>update()</code> on all the plugins.
	 */
	inline public function update():Void
	{
		for (plugin in list)
		{
			if (plugin.exists && plugin.active)
			{
				plugin.update();
			}
		}
	}
	
	/**
	 * Used by the game object to call <code>draw()</code> on all the plugins.
	 */
	inline public function draw():Void
	{
		for (plugin in list)
		{
			if (plugin.exists && plugin.visible)
			{
				plugin.draw();
			}
		}
	}
	
	/**
	 * Used by the game object to call <code>onStateSwitch()</code> on all the plugins.
	 */
	inline public function onStateSwitch():Void
	{
		for (plugin in list)
		{
			if (plugin.exists)
			{
				plugin.onStateSwitch();
			}
		}
	}
	
	/**
	 * Used by the game object to call <code>onResize()</code> on all the plugins.
	 * @param 	Width	The new window width
	 * @param 	Height	The new window Height
	 */
	inline public function onResize(Width:Int, Height:Int):Void
	{
		for (plugin in list)
		{
			if (plugin.exists)
			{
				plugin.onResize(Width, Height);
			}
		}
	}
	
	#if !FLX_NO_DEBUG
	/**
	 * You shouldn't need to call this. Used to draw the debug graphics for any installed plugins.
	 */
	inline public function drawDebug():Void
	{
		for (plugin in list)
		{
			if (plugin.exists && plugin.visible && !plugin.ignoreDrawDebug)
			{
				plugin.drawDebug();
			}
		}
	}
	#end
}