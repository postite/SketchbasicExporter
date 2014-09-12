import Global.*;
using helpers.Layer;
using helpers.Document;
import de.polygonal.ds.TreeNode;
import de.polygonal.ds.TreeBuilder;
import exp.*;
import haxe.EnumFlags;
import exp.Behave;
 import exp.Config;
using helpers.UI;

class BasicExporter
{

	/// choose you paths ...! 
	static var lindent:String="";
	static var pindent:String="";
	static var aindent:String="";

	var builder:TreeBuilder<Exportable>;
	public var tree:TreeNode<Exportable>;
	var config:Conf;


	var activeArtboard:MSArtboardGroup;
	var activePage:MSPage;
	public function new()
	{
		log("----------------start---------------------");
		
		
		setup();
	}
	function setup():Void
	{
		var conf= new Config();
		conf.check();
		config=exp.ExportFactory.config=conf.data;
		
		if (config.cleanUp==true)
		cleanup();
		_trace("allPages?="+config.allPages);
	}
	
	public function generate(){

		//exp.ExportStyledText.createMocks();
		var indent="*";
		tree= new TreeNode(cast new exp.ExportContainer(null));
		builder= new TreeBuilder(tree);
		activePage=doc.currentPage();
		
		if(config.allPages!=true){
			builder.appendChild(exp.ExportFactory.create(activePage).export());

			ArtboardsLoop(cast activePage.artboards());
		}else{
			
		for (page in doc.pages()){
			doc.setCurrentPage(page);
			var factoPage=exp.ExportFactory.create(page);
			if( factoPage!=null){
			builder.appendChild(factoPage.export());
			_trace(indent+page.name());

			ArtboardsLoop(cast page.artboards());
			}
			
		}
		doc.setCurrentPage(activePage);
		}
		_trace("exporter done");
	}

	
	//	path = path +"/"+page.name()+"/"+artboard.name()+"/"+  layer.name().clean()+ '.png';
		//do not know what it does !
	function cleanup(){
		try ns.NSFileManager.defaultManager().removeItemAtPath(config.imagesPath)
			catch(msg:Dynamic)_trace("failde to clean view"+ msg);
	}
	function cleanupArtboardDir(art:MSArtboardGroup):Void
	{
		var path=config.imagesPath+art.parentPage().name()+"/"+art.name()+"/";
		_trace("remove artboard "+ path);
		try ns.NSFileManager.defaultManager().removeItemAtPath(path)
			catch(msg:Dynamic)_trace("failde to clean artBoardDir"+ msg);
	}
	

	function ArtboardsLoop(arts:SketchArray<MSArtboardGroup>)
	{
		builder.down();
		_trace("ArtboardsLoop");
		
		 var native=arts.iterator().haxeArray();
		 log("nat="+native);
		// var native=arts;
		 native.reverse();
		//_trace( "artslength"+arts.array());

		//
		if( config.allArtBoards!=true){
			if(selection!=null && selection.firstObject()._class()==MSArtboardGroup){
			processArtboard(cast selection.firstObject());
			}else{
			"selectan artboard\n aborting".alert();
			throw ( "abort");
			}
		}else{
		for (art in native)
			processArtboard(art);
		}
		builder.up();
		_trace("end Artboard loop");

	}
	function processArtboard(art:MSArtboardGroup){
		_trace( "processArtboard");
		activeArtboard=art;
		var exportable=exp.ExportFactory.create(art);
			if(exportable!=null){
				try
				if(config.cleanUp==true) // TODO specify for cache 
			cleanupArtboardDir(cast selection.firstObject())
				catch(msg:Dynamic)_trace("cleanupFailed");
			builder.appendChild(exportable.export());
			//_trace("befor bigloop name="+indent+art.name());
			bigloop(art.layers());
			}
		_trace( "bigloop");
	}

	function bigloop(layers:SketchArray<MSLayer>,?indent:String)
	{
		_trace(" bigloop");
		builder.down();
		indent= (indent==null)? "-" :indent+"-"; 
		var native= layers.iterator().haxeArray();
		native.reverse();

		for(layer in native){
			var exported:Exportable=null;
			var factory=exp.ExportFactory.create(layer);
			if (factory!=null)exported=factory.export();
				
			if(exported!=null){
				
			builder.appendChild(exported);
			
			
			if(layer.isGroup() && !exported.behaviour.has(Flat) ){
			
				bigloop(layer.layers(),indent);
			};
			}
			
		}

		builder.up();
		
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
				case Text,StyledText:
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
				case Mask:
					_node.set("class","mask");
				case Zone:
				case Symbol:
				case Mock:
					
			}
			
			xml.insertChild(_node,0);
			if (treeNode.hasChildren()){
				toXml(treeNode, _node);
			}
		}
		return xml;
	}


	
	public function toJson(tree:TreeNode<Exportable>,obj:Dynamic)
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


	
	
	public function exportjson(content:String)
	{
		Global.writeToFile(content,doc.dir()+"/view/"+doc.displayName()+".json");
	}
	


	static public function main()
	{
		var app = new BasicExporter();
		app.generate();
	}
}
