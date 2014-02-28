	class CopyPlug
	{

	static public function main()
	{

	var t = sys.io.File.getContent( "basicExporter/out/basicExporter.jstalk" );
		var f= new StringBuf();
		f.add("// basicExporter (ctrl alt command e) \n");

		//hack for escaped quotes 
		//need a regexp for that
		t=StringTools.replace(t,'"\\""',"'\"'"); //  "\""
		t=StringTools.replace(t,'"=\\""',"'=\"'");  // "=\""
		t=StringTools.replace(t,' \\""',' "');   // \"
		
		
		f.add(t);
		sys.io.File.saveContent("basicExporter/out/basicExporter.jstalk" ,f.toString());
		sys.io.File.saveContent("/Users/ut/Library/Application Support/sketch/Plugins/basicExporter/basicExporter.jstalk" ,f.toString());
		//sys.io.File.copy("./out/testApi.jstalk", "/Users/ut/Library/Application Support/sketch/Plugins/TestApi/testApi.jstalk" );
		
		
	}

}