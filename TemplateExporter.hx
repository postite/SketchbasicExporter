import exp.ExportStyledText;
class TemplateExporter extends HTMLExporter
{
	public function new()
	{
		super();
	}
	override public function exportHtml()
	{
		var t= new IncView();

		//t.content=html.toString();
		t.data={content:html.firstElement().firstElement().toString()};//skip page and go to artboard !
		//t.data={content:html.firstElement().firstElement().toString(),styles:ExportStyledText.generateCss()};//skip page and go to artboard !
		
		// var incTemplate= new IncView();
		// incTemplate.data={content:"popop"};
		// var inked=incTemplate.execute();
		// t.inc=function(s:String)return "inked";
		var export = t.execute();
		//Global.writeToFile(export,config.imagesPath+activePage.name()+"/"+activeArtboard.name()+"/"+activeArtboard.name()+".html");
		Global.writeToDir(export,config.modelPath+"/"+activeArtboard.name()+".html");
	}

	static public function main()
  	{
		var app = new TemplateExporter ();
	}
}
#if !display
@template("@if(styles!=null){<style>@styles</style> \n }@content")
class IncView extends erazor.macro.SimpleTemplate<{content:String,?styles:String}>{}
#end
