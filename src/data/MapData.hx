package data;
import haxe.ds.Either;
import haxe.ds.Vector;
#if sys
import sys.io.File;
#end
import haxe.io.Bytes;
import game.Player;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;
import data.ArrayDataArray.ArrayDataInt;
class MapData
{
    //container links index to objects array data when negative number
    public var containers:Array<Vector<Int>> = [];
    //biome 0-7
    public var biome:ArrayDataInt = new ArrayDataInt();
    //floor objects
    public var floor:ArrayDataInt = new ArrayDataInt();
    //object is a postive number, container is a negative that maps 
    public var object:ArrayDataArray<Int> = new ArrayDataArray<Int>();

    public var loaded:Bool = false;

    public var valleyOffsetY:Int = 0;
    public var valleyOffsetX:Int = 0;
    public var valleySpacing:Int = 0;
    public var valleyBool:Bool = true;

    public var offsetX:Int = 0;
    public var offsetY:Int = 0;
    public var offsetBoolX:Bool = true;
    public var offsetBoolY:Bool = true;
    
    //all chunks combined
    public var x:Int = 0;
    public var y:Int = 0;
    public var width:Int = 0;
    public var height:Int = 0;
    public function new()
    {
        
    }
    public function setRect(x:Int,y:Int,width:Int,height:Int,string:String)
    {
        //loaded in data
        loaded = true;
        //create array
        var a:Array<String> = string.split(" ");
        //data array for object
        var data:Array<String>;
        var objectArray:Array<Int> = [];
        var array:Array<Array<Int>> = [];
        //bottom left
        for(j in y...y + height)
        {
            for (i in x...x + width)
            {
                string = a.shift();
                data = string.split(":");
                biome.set(i,j,Std.parseInt(data[0]));
                floor.set(i,j,Std.parseInt(data[1]));
                //setup containers
                object.set(i,j,id(data[2]));
            }
        }
    }
    public static function id(string:String):Array<Int>
    {
        //postive is container, negative is subcontainer that goes into postive container
        //0 is first container, untill another postive number comes around
            var a = string.split(",");
            var array:Array<Int> = [];
            for (i in 0...a.length)
            {
                //container
                var s = a[i].split(":");
                array.push(Std.parseInt(s[0]));
                for (k in 1...s.length - 1)
                {
                    //subcontainer
                    array.push(Std.parseInt(s[k]) * -1);
                }
            }
            if (array.length == 1 && array[0] > Main.data.nextObjectNumber)
            {
                var alt = Main.data.objectAlt.get(array[0]);
                if (array != null) return [alt];
            }
            return array;
    }
}
class MapInstance
{
    //current chunk
    public var x:Int = 0;
    public var y:Int = 0;
    public var width:Int = 0;
    public var height:Int = 0;
    public var rawSize:Int = 0;
    public var compressedSize:Int = 0;
    public function new()
    {

    }
    public function toString():String
    {
        return "pos(" + x + "," + y +") size(" + width + "," + height + ") raw: " + rawSize + " compress: " + compressedSize;
    }
}
class MapChange
{
    public var x:Int = 0;
    public var y:Int = 0;
    public var floor:Int = 0;
    public var id:Array<Int> = [];
    public var pid:Int = 0;
    public var oldX:Int = 0;
    public var oldY:Int = 0;
    public var speed:Float = 0;
    public function new(array:Array<String>)
    {
        x = Std.parseInt(array[0]);
        y = Std.parseInt(array[1]);
        floor = Std.parseInt(array[2]);
        //trace("change " + array[3]);
        //array[3].split(",")
        id = MapData.id(array[3]);
        pid = Std.parseInt(array[4]);
        //optional speed
        if(array.length > 5)
        {
            oldX = Std.parseInt(array[5]);
            oldY = Std.parseInt(array[6]);
            speed = Std.parseFloat(array[7]);
        }
    }
    public function toString():String
    {
        var string:String = "";
        for(field in Reflect.fields(this))
        {
            string += field + ": " + Reflect.getProperty(this,field) + "\n";
        }
        return string;
    }
}