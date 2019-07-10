package client;
import haxe.crypto.Hmac;
import haxe.io.Bytes;
class Login
{
    //login info
    public var email:String = "";
    public var challenge:String = "";
    public var key:String = "";
    var index:Int = 0;
    public var version:Int = 0;
    //functions
    public var accept:Void->Void;
    public var reject:Void->Void;
    public function new()
    {
        
    }
    public function message(data:String) {
        switch(Main.client.tag)
        {
            case SERVER_INFO:
			switch(index)
			{
				case 0:
				//current
				case 1:
				//challenge
				challenge = data;
				case 2: 
				//version
				version = Std.parseInt(data);
                request();
                Main.client.tag = "";
			}
			index++;
            default:
        }
    }
    private function request()
    {
		key = StringTools.replace(key,"-","");
        Main.client.send("LOGIN " + email + " " +

		new Hmac(SHA1).make(Bytes.ofString("262f43f043031282c645d0eb352df723a3ddc88f")
		,Bytes.ofString(challenge,RawNative)).toHex() + " " +

		new Hmac(SHA1).make(Bytes.ofString(key)
		,Bytes.ofString(challenge)).toHex() +  " " +

        //tutorial 1 = true 0 = false
        1 + " " +
        //twin extra code
        ""
        );
		Main.client.tag = "";
        trace("send login request");
    }
}