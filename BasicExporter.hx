import Global.*;
using helpers.Layer;
using helpers.Document;
import de.polygonal.ds.TreeNode;
import de.polygonal.ds.TreeBuilder;
import exp.*;
import haxe.EnumFlags;
import exp.Behave;



class BasicExporter
{

	/// choose you paths ...! 
	static var lindent:String="";
	static var pindent:String="";
	static var aindent:String="";
	var builder:TreeBuilder<Exportable>;
	 var tree:TreeNode<Exportable>;
	function new()
	{
		_trace("----------------start---------------------");


		/*
		override flagging example
		exp.ExportFactory.extract=function(name:String){
			var flags=new EnumFlags();
		//trace("first="+beginWith(name));
		//return true;

		 switch(exp.ExportFactory.beginWith(name)){
		 
		// case "#": flags.set(Behave.set);
		 case '@': flags.set(Flat);
		 case "+": flags.set(Exportable);
		 //case "_":flags.set(Flat);
		 case _:flags.unset(Behave.Exportable);

		 //default:  false;
		 }
		 return flags;

		}
		*/
		cleanup();

		var indent="*";
		tree= new TreeNode(cast new exp.ExportContainer(null));
		builder= new TreeBuilder(tree);
		for (page in doc.pages()){
			doc.setCurrentPage(page);
			builder.appendChild(exp.ExportFactory.create(page).export());
			_trace(indent+page.name());
			ArtboardsLoop(cast page.artboards());
			
		}


		// //log(tree.toString());
		// log("xml");
		// try{
		// //had to modify StringTools & haxe.xml.Parse ( '"')
		// var xml:Xml=Xml.createElement("div");
		// var xm=toXml(tree,xml);
		// log( xm.toString());
		// //exporthtml(haxe.xml.Printer.print(xm));
		
		// }catch(msg:Dynamic){
		// log("xml error"+msg);
		// }
		// log("html");
		// try{
		
		// var xml:Xml=Xml.createElement("div");
		// var html=new HTMLExporter();
		// html.toHtml(tree,xml);
		// html.export();
		
		// }catch(msg:Dynamic){
		// log("xml error"+msg);
		// }
		// log("jason");
		// try{
		// 	var obj={};
		// 	var jon=toJson(tree,obj);
		// 	//log(jon.toString());
		// 	log(haxe.Json.stringify(jon));
		// 	exportjson( haxe.Json.stringify(jon));
		// }
		// catch(msg:Dynamic){
		// 	log("error"+msg);
		// }
		try{
			
			var framer= new FramerExporter();
			var jsonframe=framer.toJson(tree);

			exportFramer( haxe.Json.stringify(jsonframe));
		}catch(msg:Dynamic){
			_trace("error for framer"+msg);
		}

		//log( xm.firstChild().nodeName);
		_trace("done");
	}

	function ArtboardsLoop(arts:SketchArray<MSArtboardGroup>)
	{
		builder.down();
		_trace("ArtboardsLoop");
		var indent="+";
		var native=arts.iterator().haxeArray();
		native.reverse();
		for (art in native){
			builder.appendChild(exp.ExportFactory.create(art).export());
			_trace("name="+indent+art.name());
			bigloop(art.layers());

		}
		builder.up();
		_trace("end Artboard loop");

	}

	function bigloop(layers:SketchArray<MSLayer>,?indent:String)
	{
		_trace(" bigloop");
		builder.down();
		indent= (indent==null)? "-" :indent+"-"; 
		var native= layers.iterator().haxeArray();
		native.reverse();

		for(layer in native){
			var exported=exp.ExportFactory.create(layer).export();
				_trace("------------layer---------------"+layer.name());
			if(exported!=null){
				_trace("---------------------------"+exported.name);
			builder.appendChild(exported);
			_trace("name="+indent+layer.name());
			if(layer.isGroup() && !exported.behaviour.has(Flat)){
				_trace( 'isgroup');
				bigloop(layer.layers(),indent);
			};
			}
			
		}

		builder.up();
		_trace("end bigloop");
	}

	
	// function toJson()
	// {
	// 	try
	// 	tree.preorder(levelOrderfunc)
	// 	catch( err:Dynamic)
	// 	_trace( "eer"+err);


	// }
	// function levelOrderfunc(node:TreeNode<Exportable>,?preflight:Bool, ?userData:Dynamic):Bool
	// {
	// 	if (node.hasChildren())levelOrderfunc(node)
	// 	return true;
	// }


	function toXml(tree:TreeNode<Exportable>,xml:Xml):Xml
	{


		for (node in tree.childIterator()){
			var castednode:exp.ExportLayer= cast (node,exp.ExportLayer);
			var treeNode=tree.find(node); //heavy
			var _node:Xml=null;
			_trace(node.type);
			switch(node.type){
				case Page:
				_node=Xml.createElement("page");
				case ArtBoard:
				_node=Xml.createElement("Artboard");
				case _:
				_node=Xml.createElement("layer");
			}
			
			_node.set("name",node.name);
			
			//pattern matching ?
			switch(node.type){
				case Page:
					_node.set("class","page");
				case ArtBoard:
					_node.set("class","artboard");
				case Text:
					 _node.set("class","text");
					 
					 _node.insertChild(Xml.createCData(cast (node,exp.ExportText).text.text),0);
					 
				case Svg:
					_node.set("class","svg");
					var img=Xml.createElement("img");
					img.set("src",node.src);
					_node.insertChild(img,0);
					
				case Image:
					_node.set("class","image");
					var img=Xml.createElement("img");
					img.set("src",node.src);
					_node.insertChild(img,0);
				case Container:
					_node.set("class","container");
				case Slice:
					_node.set("class","slice");
					
			}
			
			xml.insertChild(_node,0);
			if (treeNode.hasChildren()){
				toXml(treeNode, _node);
			}
		}
		return xml;
	}


	
	function toJson(tree:TreeNode<Exportable>,obj:Dynamic)
	{
		if( obj.children==null)obj.children=[];
		for (node in tree.childIterator()){

			var treeNode=tree.find(node); //heavy
			var _obj=node.toObj();
			
			obj.children.push(_obj);
			
			// //pattern matching ?
			switch(node.type){
				case _:
			}
			
			if (treeNode.hasChildren()){
				toJson(treeNode,_obj);
			}
		}
		return obj;
	}


	
	
	function exportjson(content:String)
	{
		Global.writeToFile(content,doc.dir()+"/view/"+doc.displayName()+".json");
	}
	function exportFramer(content:String)
	{
		Global.writeToFile(content,doc.dir()+"/view/framer-"+doc.displayName()+".json");
	}


	static public function main()
	{
		var app = new BasicExporter();
	}
}
