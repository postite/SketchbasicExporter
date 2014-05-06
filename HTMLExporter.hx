import Global.*;
using helpers.Layer;
using helpers.Document;
import de.polygonal.ds.TreeNode;
import de.polygonal.ds.TreeBuilder;
import exp.*;
import haxe.EnumFlags;
import exp.Behave;

class HTMLExporter extends BasicExporter
{

	var html:Xml;
	public function new()
	{
		super();
		generate();
		var xml:Xml=Xml.createElement("div");
		html=toHtml(tree,xml);
		exportHtml();
		launch();
	}

	override function setup():Void
	{
		_trace( "setup");
		var conf= new Config();
		Config.defaults.imagesPath=doc.dir()+"/html/images/";

		conf.check();
		config=exp.ExportFactory.config=conf.data;
		_trace(config);
		if (config.cleanUp==true)
		cleanup();
	}

	function launch():Void
	{
		var open_task=ns.NSTask.alloc().init();
			var open_task_args=ns.NSArray.arrayWithObjects(config.imagesPath+activePage.name()+"/"+activeArtboard.name()+"/"+activeArtboard.name()+".html");
			//open_task.setCurrentDirectoryPath(framer_folder);
			open_task.setLaunchPath("/usr/bin/open");
			open_task.setArguments(open_task_args);
			untyped _trace( open_task.launchPath());
			open_task.launch();
	}

	public function toHtml(tree:TreeNode<Exportable>,xml:Xml):Xml
	{


		for (node in tree.childIterator()){
			var castednode:exp.ExportLayer= cast (node,exp.ExportLayer);
			var treeNode=tree.find(node); //heavy
			var _node:Xml=null;
			_trace(node.type);
			switch(node.type){
				case Page:
				_node=Xml.createElement("section");
				case _:
				_node=Xml.createElement("div");
			}
			
			_node.set("name",node.name);
			var position="absolute";
			//pattern matching ?
			switch(node.type){
				case Page:
					_node.set("class","page");
				case ArtBoard:
					_node.set("class","artboard");
				case Svg:
					_node.set("class","svg");
					var img=Xml.createElement("img");
					img.set("src",node.src);
					_node.insertChild(img,0);
				case Text:
				_trace("isText" +node.name);
					 _node.set("class","text");
					 //position="relative";
					var tag=helpers.StringSketch.getTextTag(node.name);
					 var texteProps:exp.ExportText.TextProperties=  cast (node,exp.ExportText).text;
					// log( texteProps);
					/*line-height is a hack for first line 1.5 is completly arbitrary TODO*/
					//also width +3 is arbitrary (webfonts)
					var lineHeight=(node.height>= texteProps.lineSpacing*1.5)? texteProps.lineSpacing : node.height;
					var style='font-size:${texteProps.fontSize}px;
								font-family:${texteProps.fontPostscriptName};
								text-align:${texteProps.textAlignment};
								line-height:${lineHeight}px;
								color:#${texteProps.color};
								top:${node.rely}px;
								left:${node.relx}px;
								width:${node.width +texteProps.fontSize/7}px;
								';
					//var style='';
					//// _node.insertChild(Xml.createCData(cast (node,exp.ExportText).text.text),0);
					 var subXml=Xml.parse('<${tag.tagName} class="${tag.name}" style="$style">${texteProps.text}</${tag.tagName}>');
					 	//cast (node,exp.ExportText).text.text),0);
						//var subXml=Xml.parse("<p/>");
					//_node.insertChild(subXml,0);
					//subXml.firstChild().set("popo","one");
					_node=subXml.firstChild();
					_trace( "text done"+subXml.toString());
				case Image:
					_node.set("class","image");
					var img=Xml.createElement("img");
					img.set("src",node.src);
					_node.insertChild(img,0);
				case Container:
					_node.set("class","container");
				case Slice:
					_node.set("class","slice");
					var img=Xml.createElement("img");
					img.set("src",node.src);
					_node.insertChild(img,0);
				case _:
				_trace("badtype");
					
			}
			_trace("check position");
			if(position=="absolute"){
				var style=(_node.get("style")!=null)? _node.get("style") : "";
				var genericStyle=' position:$position;
				left:${castednode.relx}px;
				top:${castednode.rely}px;
				width:${castednode.width}px;
				height:${castednode.height}px; ';
			_node.set("style",genericStyle+style);
				
			}
			

			_trace("piko");
			xml.insertChild(_node,0);
			if (treeNode.hasChildren()){
				toHtml(treeNode, _node); //recursion
			}
		}
		html=xml;
		return xml;
	}


	public function exportHtml()
	{
		var t= new HtmlView();
		t.title=doc.displayName();
		t.content=html.toString();
		var export = t.execute();
		Global.writeToFile(export,config.imagesPath+activePage.name()+"/"+activeArtboard.name()+"/"+activeArtboard.name()+".html");
	}
	public static function main(){
		new HTMLExporter();
	}
}


#if !display
@template('
<!doctype html><html lang="en"><head><meta charset="UTF-8" /><title>@title</title>
<style>
img{display:block;}
</style>
</head><body>
@content
</body></html>

	')

class HtmlView extends erazor.macro.Template{
	public var content:String;
	public var title:String;
}
#end