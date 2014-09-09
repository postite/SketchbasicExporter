import Global.*;
using helpers.Layer;
using helpers.Document;
using HTMLExporter;
import de.polygonal.ds.TreeNode;
import de.polygonal.ds.TreeBuilder;
import exp.*;
import exp.ExportText;
import exp.ExportText.TextProperties;
import haxe.EnumFlags;
import exp.Behave;
import helpers.StringSketch.Tag;

class HTMLExporter extends BasicExporter
{

	var html:Xml;
	var positionneMe:Bool;
	var mesureMe:Bool;
	public function new()
	{
		super();
		exp.ExportStyledText.createMocks();
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
		//_trace(config);
		if (config.cleanUp==true)
		cleanup();
	}

	function launch():Void
	{
		var open_task=ns.NSTask.alloc().init();
			//var open_task_args=ns.NSArray.arrayWithObjects(config.imagesPath+activePage.name()+"/"+activeArtboard.name()+"/"+activeArtboard.name()+".html");
			var open_task_args=ns.NSArray.arrayWithObjects(config.imagesPath+activePage.name()+"/"+activeArtboard.name()+".html");
			//open_task.setCurrentDirectoryPath(framer_folder);
			open_task.setLaunchPath("/usr/bin/open");
			open_task.setArguments(open_task_args);
			untyped _trace( open_task.launchPath());
			open_task.launch();
	}

	override function cleanup(){
		try ns.NSFileManager.defaultManager().removeItemAtPath(config.imagesPath+activePage.name()+"/"+activeArtboard.name()+"/")
			catch(msg:Dynamic)_trace("failde to clean view"+ msg);
	}
	
	public function toHtml(tree:TreeNode<Exportable>,xml:Xml):Xml
	{

		positionneMe=true;
		mesureMe=true;
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
					_node=processText(cast node,_node,inlineTextStyle);
					_trace( node);
					mesureMe=false;

				case StyledText:
				
					_node=processText(cast node,_node,externTextStyle);
					mesureMe=false;
				case Image:
					_node.set("class","image");
					var img=Xml.createElement("img");
					img.set("src",activeArtboard.name()+"/"+node.src);
					_node=img;
					var tag=helpers.StringSketch.getTextTag(node.name,"img");
					_node.nodeName=tag.tagName;
					_node.set("name",tag.name);
					var classOrId=helpers.StringSketch.getClassOrId(node.name);
					_node.set("name",classOrId.cleanName);
					//img.set("src",node.src);
					

					for ( classe in classOrId.classes)
						_node.addAtt("class",classe);
					for (id in classOrId.ids)
						_node.addAtt("id",id);
					//_node.insertChild(img,0);
					
				case Container,Symbol:
					var tag=helpers.StringSketch.getTextTag(node.name,"div");
					var classOrId=helpers.StringSketch.getClassOrId(node.name);

					var subXml=Xml.parse('<${tag.tagName}  class="${tag.name}" ></${tag.tagName}>');
					_node=subXml.firstChild();
					_node.set("name",tag.name);
					_node.set("class","container");
					for ( classe in classOrId.classes)
						_node.addAtt("class",classe);
					for (id in classOrId.ids)
						_node.addAtt("id",id);
					mesureMe=true; // in case this is a textContainer;
					positionneMe=true;

					// if( node.orig.parentOrSelfIsSymbol())
					// helpers.UI.alert("symbol");

				case Mask:
					_node.set("class","mask");
					var img=Xml.createElement("img");
					///img.set("src",node.src);
					img.set("src",activeArtboard.name()+"/"+node.src);
					_node.insertChild(img,0);
					_node.set("style",'clip: rect(${node.masque.y}px, ${node.masque.width}px, ${node.masque.height}px, ${node.masque.x}px);');
				case Slice:
					_node.set("class","slice");
					var img=Xml.createElement("img");
					img.set("src",activeArtboard.name()+"/"+node.src);
					_node.insertChild(img,0);
				case Mock:
				continue;
				case _:

				helpers.UI.alert("badTypefor"+node.name);
					
			}
			
			// if(position=="absolute"){
			// 	var style=(_node.get("style")!=null)? _node.get("style") : "";
			// 	var genericStyle=' position:$position;
			// 	left:${castednode.relx}px;
			// 	top:${castednode.rely}px;
			// 	width:${castednode.width}px;
			// 	height:${castednode.height}px; ';
			// _node.set("style",genericStyle+style);
				
			// }
			

			//reduce if pos==0 ?
			if( positionneMe){
				var style=(_node.get("style")!=null)? _node.get("style") : "";
				var genericStyle='position:absolute;
				left:${castednode.relx}px;
				top:${castednode.rely}px;';
				
			_node.set("style",style+genericStyle);
			}
			if (mesureMe){
				var style=(_node.get("style")!=null)? _node.get("style") : "";
				var genericStyle='
					width:${castednode.width}px;
					height:${castednode.height}px; ';
				_node.set("style",style+genericStyle);
			}
			if( node.type==Symbol)
			_node.addAtt("class",cast (node,exp.ExportSymbol).symbolName());
			

			
			xml.insertChild(_node,0);
			if (treeNode.hasChildren()){
				toHtml(treeNode, _node); //recursion
			}
		}
		html=xml;
		return xml;
	}

	function inlineTextStyle(node:exp.ExportText,_node:Xml,tag:Tag, texteProps:TextProperties):Xml
	{
		/*line-height is a hack for first line 1.5 is completly arbitrary TODO*/
					//also width +3 is arbitrary (webfonts)
		var lineHeight=(node.height>= texteProps.lineSpacing*1.5)? texteProps.lineSpacing : node.height;
		var style='font-size:${texteProps.fontSize}px;
								font-family:${texteProps.fontPostscriptName};
								text-align:${texteProps.textAlignment};
								line-height:${lineHeight}px;
								color:#${texteProps.color};
								width:${node.width +texteProps.fontSize/7}px;
								';
					//var style='';
					//// _node.insertChild(Xml.createCData(cast (node,exp.ExportText).text.text),0);
					//_trace( "op"+'<${tag.tagName} class="${tag.name}" style="$style">${texteProps.text}</${tag.tagName}>');
					 
					 var subXml=Xml.parse('<${tag.tagName} class="${tag.name}" style="$style">${texteProps.text}</${tag.tagName}>');
					 	//cast (node,exp.ExportText).text.text),0);
						//var subXml=Xml.parse("<p/>");
					//_node.insertChild(subXml,0);
					//subXml.firstChild().set("popo","one");
					
					_node=subXml.firstChild();
					
					return _node;
	}

	function externTextStyle(node:exp.ExportText,_node:Xml,tag:Tag,texteProps:TextProperties):Xml{

		var style='top:${node.rely}px;
					width:${node.width +texteProps.fontSize/7}px;
								';
					//var style='';
					//// _node.insertChild(Xml.createCData(cast (node,exp.ExportText).text.text),0);
					//_trace( "op"+'<${tag.tagName} class="${tag.name}" style="$style">${texteProps.text}</${tag.tagName}>');
					 var subXml=Xml.parse('<${tag.tagName} class="${tag.name}" style="$style">${texteProps.text}</${tag.tagName}>');
					 	//cast (node,exp.ExportText).text.text),0);
						//var subXml=Xml.parse("<p/>");
					//_node.insertChild(subXml,0);
					//subXml.firstChild().set("popo","one");
					
					_node=subXml.firstChild();
					_node.addAtt("class",cast(node ,exp.ExportStyledText).styleName());
					return _node;

	}
	function templateProcess(node:exp.ExportText,_node:Xml,tag:Tag):Xml
	{
		// var inc=new HTMLExporter.IncView();
						// inc.data={content:"<div>pipo</div>"};
						// var inked= inc.execute();
						// _node=Xml.parse(inked).firstChild();
						var template=doc.loadTxt(config.imagesPath+activePage.name()+"/"+tag.name+".html");

						var subNode=Xml.parse(template).firstChild();
						
						mesureMe=false;
						positionneMe=false;
						_node=subNode;
						_node.addAtt("id",tag.name);
						_node.addAtt("style","display:none");
						return _node; //firstChild ?
						//Global.doc.loadTxt(Global.doc.tag.name+".html");
						//helpers.UI.alert(template);
	}
	function processText(node:ExportText,_node:Xml,outputFunc:ExportText->Xml->Tag->TextProperties->Xml):Xml{
					_trace("isText" +node.name);
					_node.set("class","text");
					_trace( "kiloz");
					var tag=helpers.StringSketch.getTextTag(node.name,"span");
					if (tag.tagName=="T"){
					_node=templateProcess(cast node,_node,tag);
						
					}else{

					 var texteProps:TextProperties=  cast (node,exp.ExportText).text;
					
					_node=outputFunc(cast node,_node,tag,texteProps);
					// log( texteProps);
					
					
					}
					return _node;
				
	}

	public function exportHtml()
	{
		var t= new HtmlView();
		t.title=doc.displayName();
		t.content=html.toString();
		t.textStyles=exp.ExportStyledText.generateCss();
		// var incTemplate= new IncView();
		// incTemplate.data={content:"popop"};
		// var inked=incTemplate.execute();
		// t.inc=function(s:String)return "inked";
		var export = t.execute();
		//Global.writeToFile(export,config.imagesPath+activePage.name()+"/"+activeArtboard.name()+"/"+activeArtboard.name()+".html");
		Global.writeToFile(export,config.imagesPath+activePage.name()+"/"+activeArtboard.name()+".html");
	}
	public static function main(){
		new HTMLExporter();
	}

	static function addAtt(node:Xml,attributeName:String,value:String){
		if( node.exists(attributeName)){
		var stringlist=node.get(attributeName);
		var tab:Array<String>= stringlist.split(" ");
		tab.push(value);
		node.set(attributeName,tab.join(" "));
		}else{
			node.set(attributeName,value);
		}
	}
}


#if !display
@template('<html lang="fr"><head><meta charset="UTF-8" /><title>@title</title>
<style>
img{display:block;}
@textStyles
</style>
<script src="client.js"></script>
<link rel="stylesheet" href="style.css" />
</head><body>
@content
</body></html>
	')

class HtmlView extends erazor.macro.Template{
	public var content:String;
	public var title:String;
	public var textStyles:String;
	dynamic public function inc(s:String):String{return s;}
}
#end
