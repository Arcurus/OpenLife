package settings;
import haxe.DynamicAccess;
import game.Game;
import haxe.io.Path;
#if (sys || nodejs)
import sys.io.FileOutput;
import sys.io.File;
import sys.FileSystem;
#end
#if nativeGen @:nativeGen #end
class Settings
{
    @:isVar public var data(default,set):Data = {};
    function set_data(value:Data):Data
    {
        var a = value.keys();
        var b = data.keys();
        if (a.length != b.length)
        {
            var name = a[a.length - 1] + ".ini";
            var obj = value.get(name);
            #if sys
            var file:FileOutput;
            //set settings
            file = File.write(Game.dir + "settings/" + name,false);
            file.writeString(obj);
            file.close();
            #end

            #if (js || html)
            
            #end
        }
        data = value;
        return data;
    }
    public var fail:Bool = true;
    public function new()
    {
        var path:String = Game.dir + "settings/";
        #if sys
        if (FileSystem.exists(path) && FileSystem.isDirectory(path))
        {
            fail = false;
            for (name in FileSystem.readDirectory(path))
            {
                Reflect.setField(data,Path.withoutExtension(name),File.getContent(path + name));
            }
        }else{
            fail = true;
            trace("settings failed");
        }
        #end
    }
}
typedef Data = DynamicAccess<Dynamic> 