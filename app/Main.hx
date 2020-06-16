package;

import sys.FileSystem;
import openlife.engine.Engine;

class Main
{
    public static function main()
    {
        var dir:String = "";
        if (FileSystem.exists("./OneLifeData7/objects/nextObjectNumber.txt"))
        {
            Engine.dir = "OneLifeData7/";
        }else if (FileSystem.exists("objects/nextObjectNumber.txt"))
        {
            Engine.dir = "";
        }else{
            trace("directory not found");
            return;
        }
        Sys.println("Starting OpenLife App");
        new App();
    }
}