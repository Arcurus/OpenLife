package data;
import haxe.io.Input;
import sys.FileSystem;
import sys.io.File;
import haxe.ds.Vector;
enum ObjectType {
    OBJECT;
    FLOOR;
    PLAYER;
    GROUND;
}
class ObjectData extends LineReader
{
    //static 
    public static inline var CLOTHING_PIECES:Int = 6;
    //set
    public var id:Int=0;
    public var description:String = "";
    public var containable:Bool=false;
    public var containSize:Int = 0;
    public var noFlip:Bool = false;
    public var sideAcess:Bool = false;
    public var vertSlotRot:Float = 0.000000;
    public var permanent:Int = 0;
    public var minPickupAge:Int = 0;
    public var heldInHand:Bool = false;
    public var rideable:Bool = false;
    public var blocksWalking:Bool = false;
    public var leftBlockingRadius:Int = 0;
    public var rightBlockingRadius:Int = 0;
    public var drawBehindPlayer:Int = 0;
    public var mapChance:Float = 0.000000;//#biomes_0
    public var heatValue:Int =0;
    public var rValue:Float =0.000000;
    public var person:Bool = false;
    public var noSpawn:Bool = false;
    //int -> bool
    public var male:Bool=false;//=0
    public var deathMarker:Int =0;
    public var homeMarker:Int = 0;
    public var floor:Bool = false;
    public var floorHugging:Bool = false;
    public var foodValue:Int =0;
    public var speedMult:Float =1.000000;
    public var heldOffset:Point;//=0.000000,0.000000
    public var clothing:String="n";
    public var clothingOffset:Point;//=0.000000,0.000000
    public var deadlyDistance:Int=0;
    public var useDistance:Int=1;
    public var creationSoundInitialOnly:Bool = false;
    public var creationSoundForce:Bool = false;
    public var numSlots:Int=0;
    public var timeStretch:Float=1.000000;
    public var slotSize:Int=1;
    public var slotsLocked:Int = 1;
    public var slotPos:Vector<Point>;
    public var slotVert:Vector<Bool>;
    public var slotParent:Vector<Int>;
    public var numSprites:Int=0;
    public var spriteArray:Vector<SpriteData>;

    public var headIndex:Int = -1;
    public var bodyIndex:Int = -1;
    public var backFootIndex:Int = -1;
    public var frontFootIndex:Int = -1;
    // derrived automatically for person objects from sprite name
    // tags (if they contain Eyes or Mouth)
    // only filled in if sprite bank has been loaded before object bank
    public var eyesIndex:Int = -1;
    public var mouthIndex:Int = -1;
    //eyes offset
    //derrived automatically from whatever eyes are visible at age 30
    //(old eyes may have wrinkles around them, so they end up
    //getting centered differently)
    public var eyesOffset:Point = null;

    public var numUses:Int = 0;
    public var useChance:Int = 0;
    public var useVanishIndex:Array<Int> = [];
    public var useAppearIndex:Array<Int> = [];
    // -1 if not set
    // used to avoid recomputing height repeatedly at client/server runtime
    public var cacheHeight:Int = -1;

    public var apocalypseTrigger:Bool = false;
    public var monumentStep:Bool = false;
    public var monumentDone:Bool = false;
    public var monumentCall:Bool = false;

    public var toolSetIndex:Int = 0;
    public var toolLearned:Bool = false;

    public var fail:Bool = false;
    //animation
    #if openfl
    public var animation:AnimationData;
    public var sounds:Vector<SoundData>;//=-1:0.250000,-1:0.250000,-1:0.250000,-1:1.000000
    #end
    public function new(i:Int=0)
    {
        super();
        try {
            readLines(File.getContent(Static.dir + "objects/" + i + ".txt"));
        }catch(e:Dynamic)
        {
            trace("object txt e " + e);
            return;
        }
        //setup animation
        #if openfl
        animation = new AnimationData(i);
        if (animation.fail) animation = null;
        #end
        read();
    }
    public function read()
    {
        id = getInt();
        description = getString();
        //tool setup
        var toolPos = description.indexOf("+tool");
        if (toolPos > -1)
        {
            var setTag = description.substring(toolPos + 5,description.length);
            var set:Bool = false;
            for (record in toolsetRecord)
            {
                if (record.setTag == setTag)
                {
                    //already exists
                    if (record.setMembership.indexOf(id) == -1)
                    {
                        record.setMembership.push(id);
                        set = true;
                        break;
                    }
                }
            }
            //new
            if (!set) toolsetRecord.push({setTag: setTag, setMembership: [id]});
            
        }
        containable = getBool();

        var i = getArrayInt();
        containSize = i[0];
        vertSlotRot = i[1];

        i = getArrayInt();
        permanent = i[0];
        minPickupAge = i[0];

        if(readName("noFlip"))
        {
            noFlip = getBool();
        }
        if(readName("sideAccess"))
        {
            sideAcess = getBool();
        }

        var string = getString();
        if (string == "1") heldInHand = true;
        if (string == "2") rideable = true;

        i = getArrayInt();
        blocksWalking = i[0] == 1 ? true : false;
        leftBlockingRadius = i[1];
        rightBlockingRadius = i[2];
        drawBehindPlayer = i[3];

        //skipping map chance
        getString();
        //values
        heatValue = getInt();
        rValue = getInt();

        i = getArrayInt();
        //person is the race of the person
        person = i[0] == 1 ? true : false;
        noSpawn = i[1] == 1 ? true : false;

        male = getBool();

        deathMarker = getInt();

        //from death (I don't know what this does)
        if(readName("fromDeath"))
        {
            trace("from death " + line[next]);
        }
        if(readName("homeMarker"))
        {
            homeMarker = getInt();
        }
        if(readName("floor"))
        {
            floor = getBool();
        }
        if(readName("floorHugging"))
        {
            floorHugging = getBool();
        }

        foodValue = getInt();
        speedMult = getFloat();

        heldOffset = getPoint();

        clothing = getString();
        clothingOffset = getPoint();

        deadlyDistance = getInt();

        if(readName("useDistance"))
        {
            useDistance = getInt();
        }
        if(readName("sounds"))
        {
            #if openfl
            var array = getStringArray();
            sounds = new Vector<SoundData>(array.length);
            for (i in 0...array.length) sounds[i] = new SoundData(array[i]);
            #else
            getString();
            #end
        }

        if(readName("creationSoundInitialOnly")) creationSoundInitialOnly = getBool();
        if(readName("creationSoundForce")) creationSoundForce = getBool();

        //num slots and time stretch
        string = getString();
        string = string.substring(0,string.indexOf("#"));
        numSlots = Std.parseInt(string);

        slotSize = getInt();
        if(readName("slotsLocked"))
        {
            //trace("slot lock");
            slotsLocked = getInt();
        }
        slotPos = new Vector<Point>(numSlots);
        slotVert = new Vector<Bool>(numSlots);
        slotParent = new Vector<Int>(numSlots);
        var set:Int = 0;
        for(j in 0...numSlots)
        {
            string = getString();
            set = string.indexOf(",");
            slotPos[j] = new Point(
                Std.parseInt(string.substring(0,set)),
                Std.parseInt(string.substring(set + 1,set = string.indexOf(",",set)))
            );
            set = string.indexOf("=",set) + 1;
            slotVert[j] = string.substring(set,set = string.indexOf(",",set)) == "1" ? true : false;
            set = string.indexOf("=",set) + 1;
            slotParent[j] = Std.parseInt(string.substring(set,string.length));
        }
        #if openfl
        //visual
        numSprites = getInt();
        spriteArray = new Vector<SpriteData>(numSprites);
        for(j in 0...numSprites)
        {
            spriteArray[j] = new SpriteData();
            spriteArray[j].spriteID = getInt();
            spriteArray[j].pos = getPoint();
            spriteArray[j].rot = getFloat();
            spriteArray[j].hFlip = getInt();
            spriteArray[j].color = getFloatArray();
            spriteArray[j].ageRange = getFloatArray();
            spriteArray[j].parent = getInt();
            //invis holding, invisWorn, behind slots
            getString();
            if (readName("invisCont"))  spriteArray[j].invisCont = getBool();
        }
        //get offset center
        getSpriteData();

        //extra
        if(readName("spritesDrawnBehind"))
        {
            //throw("sprite drawn behind " + line[next]);
            next++;
        }
        if(readName("spritesAdditiveBlend"))
        {
            //throw("sprite additive blend " + line[next]);
            next++;
        }
        
        headIndex = getInt();
        bodyIndex = getInt();
        //arrays
        backFootIndex = getInt();
        frontFootIndex = getInt();
        
        if(next < line.length)
        {
            numUses = getInt();
            if (next < line.length) useVanishIndex = getIntArray();
            if (next < line.length) useAppearIndex = getIntArray();
            if (next < line.length) cacheHeight = getInt();

        }
        #end
    }
    public function getSpriteData()
    {
        //get sprite data
        for(i in 0...spriteArray.length)
        {
            if (spriteArray[i].spriteID <= 0) continue;
            var s:String;
            try { 
                s = File.getContent(Static.dir + "sprites/" + spriteArray[i].spriteID + ".txt");
            }catch(e:Dynamic)
            {
                trace("sprite text e " + e);
                //continue;
                return;
            }
            var j:Int = 0;
            var a = s.split(" ");
            for(string in a)
            {
                switch(j++)
                {
                    case 0:
                    //name
                    spriteArray[i].name = string;
                    case 1:
                    //multitag

                    case 2:
                    //centerX
                    spriteArray[i].inCenterXOffset = Std.parseInt(string);
                    case 3:
                    //centerY
                    spriteArray[i].inCenterYOffset = Std.parseInt(string);
                }              
            }
        }
    }
    public static var toolsetRecord:Array<ToolSetRecord> = [];
}
//toolset
typedef ToolSetRecord = {
    setTag:String,
    setMembership:Array<Int>
}