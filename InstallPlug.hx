	class InstallPlug
	{

	//need a plugin folder creation
	//create a folder for the plugin in the SketchPlufin Path 
	static public function main()
	{
	var username="ut";/// define userName or change path to your Plugin path

	var t = sys.io.File.getContent( "out/basicExporter.jstalk" );
		var f= new StringBuf();
		//define shortcut
		f.add("// basicExporter (ctrl alt command e) \n");

		//hack for escaped quotes 
		//need a regexp for that
		t=StringTools.replace(t,'"\\""',"'\"'"); //  "\""
		t=StringTools.replace(t,'"=\\""',"'=\"'");  // "=\""
		t=StringTools.replace(t,' \\""',' "');   // \"
		
		
		f.add(t);
		sys.io.File.saveContent("out/basicExporter.jstalk" ,f.toString());

		sys.io.File.saveContent('/Users/$username/Library/Application Support/sketch/Plugins/basicExporter/basicExporter.jstalk' ,f.toString());
		
		
	}

}