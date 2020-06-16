package openlife.data;
import openlife.data.object.player.PlayerInstance;
import haxe.ds.ObjectMap;
import openlife.data.object.ObjectData;
import openlife.data.transition.TransitionData;
import openlife.data.map.MapData;
import haxe.io.Path;
import haxe.ds.Vector;
import openlife.engine.Engine;
//data stored for the game to function (map data -> game data)

class GameData
{
    /**
     * Blocking tiles mapped, "x.y"
     */
    public var blocking:Map<String,Bool> = new Map<String,Bool>();
    public var playerMap:Map<Int,PlayerInstance> = new Map<Int,PlayerInstance>();
    /**
     * Transition data
     */
    public var transitionData:TransitionData;
    /**
     * Map data (ground,floor,objects)
     */
    public var map:MapData;
    #if visual
    /**
     * Map of sprites, id to data
     */
    public var spriteMap:Map<Int,SpriteData> = new Map<Int,SpriteData>();
    #end
    /**
     * Map of objects, id to data
     */
    public var objectMap:Map<Int,ObjectData> = new Map<Int,ObjectData>();
    /**
     * total non generated objects
     */
    public var nextObjectNumber:Int = 0;
    /**
     * Emote static array
     */
    #if visual
    public var emotes:Vector<EmoteData>;
    #end
    public function new()
    {
        create();
    }
    public function clear()
    {
        create();
    }
    private function create()
    {
        map = new openlife.data.map.MapData();
        blocking = new Map<String,Bool>();
        playerMap = new Map<Int,PlayerInstance>();
    }
    #if visual
    /**
     * Visual generate emote data
     */
    public function emoteData(settings:settings.Settings)
    {
        if (!settings.data.exists("emotionObjects") || settings.data.exists("emotionWords"))
        {
            trace("no emote data in settings");
            return;
        }
        var arrayObj:Array<String> = settings.data.get("emotionObjects").split("\n");
        var arrayWord:Array<String> = settings.data.get("emotionWords").split("\n");
        emotes = new Vector<EmoteData>(arrayObj.length);
        for (i in 0...arrayObj.length) emotes[i] = new EmoteData(arrayWord[i],arrayObj[i]);
    }
    #end
    /**
     * Generate object data
     */
    public function objectList():Vector<Int>
    {
        #if sys
        if (!sys.FileSystem.exists(Engine.dir + "objects/nextObjectNumber.txt")) 
        {
            trace("object data failed");
            nextObjectNumber = 0;
            return null;
        }
        //nextobject
        nextObjectNumber = Std.parseInt(sys.io.File.getContent(Engine.dir + "objects/nextObjectNumber.txt"));
        //go through objects
        var list:Array<Int> = [];
        var num:Int = 0;
        for (path in sys.FileSystem.readDirectory(Engine.dir + "objects"))
        {
            num = Std.parseInt(Path.withoutExtension(path));
            if (num > 0) 
            {
                list.push(num);
            }
        }
        list.sort(function(a:Int,b:Int)
        {
            if (a > b) return 1;
            return -1;
        });
        return Vector.fromArrayCopy(list);
        #else
        return Vector.fromArrayCopy([]);
        #end
    }
}