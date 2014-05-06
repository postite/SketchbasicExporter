import Global.*;
using helpers.Layer;
using helpers.Document;
import de.polygonal.ds.TreeNode;
import de.polygonal.ds.TreeBuilder;
import exp.*;
import haxe.EnumFlags;
import exp.Behave;
using StringTools;
typedef Sketch=Array<PageType>

typedef PageType=Array<LayerType>

typedef Frame={
	x:Float,
	y:Float,
	
	width:Float,
	height:Float
}
typedef LayerFrame={
	> Frame,
	rotation:Float,
}
typedef ImageType={
	path:String,
	frame:Frame,
	
}
typedef TexteType={
	content:String,
	fontSize:Int,
	?fontPostscriptName:String,
	textColor:String,
	alpha:String,
	textAlignment:Int,
	characterSpacing:Int,
	lineSpacing:Int
}
typedef LayerType={
	id:Int,
	name:String,
	layerFrame:LayerFrame,
	maskFrame:Dynamic,
	?image:ImageType,
	imageType:String,
	?text:TexteType,
	children:Array<LayerType>,
	visible:Bool

}
// extends BasicExporer ?
class FramerExporter extends BasicExporter{

	var id:Int;
	var sketch:Sketch;
	 /* Configuration */
 static var framerjs_url = "http://rawgit.com/koenbok/Framer/master/build/framer.js";
 static var framerPS="var loadViews = function() {\n\t\n\tvar Views = []\n\tvar ViewsByName = {}\n\t\n\tcreateView = function(info, superView) {\n\t\t\n\t\t// console.log(\"createView\", info.name, \"superView: \", superView)\n\t\t\n\t\tvar viewType, viewFrame\n\t\tvar viewInfo = {\n\t\t\tclip: false\n\t\t}\n\t\t\n\t\tif (info.image) {\n\t\t\tviewType = ImageView\n\t\t\tviewFrame = info.image.frame\n\t\t\tviewInfo.image = \"images/\" + info.name + \".\" + info.imageType\n\t\t}\n\t\t\n\t\telse {\n\t\t\tviewType = View\n\t\t\tviewFrame = info.layerFrame\n\t\t\tviewInfo.style = { background: 'transparent' }\n\t\t}\n\n\t\tviewInfo.visible = info.visible\n\t\t\n\t\t// If this layer group has a mask, we take the mask bounds\n\t\t// as the frame and clip the layer\n\t\tif (info.maskFrame) {\n\t\t\tviewFrame = info.maskFrame\n\t\t\tviewInfo.clip = true\n\t\t\t\n\t\t\t// If the layer name has \"scroll\" we make this a scroll view\n\t\t\tif (info.name.toLowerCase().indexOf(\"scroll\") != -1) {\n\t\t\t\tviewType = ScrollView\n\t\t\t}\n\t\t\t\n\t\t\t// If the layer name has \"paging\" we make this a paging view\n\t\t\tif (info.name.toLowerCase().indexOf(\"paging\") != -1) {\n\t\t\t\tviewType = ui.PagingView\n\t\t\t}\n\n\t\t}\n\t\t\n\t\tvar view = new viewType(viewInfo)\n\t\t\n\t\tview.frame = viewFrame\n\t\t\n\t\t// If the view has a contentview (like a scrollview) we add it\n\t\t// to that one instead.\n\t\tif (superView && superView.contentView) {\n\t\t\tview.superView = superView.contentView\n\t\t} else {\n\t\t\tview.superView = superView\n\t\t}\n\t\t\n\t\tview.name = info.name\n\t\tview.viewInfo = info\n\t\t\n\t\tViews.push(view)\n\t\tViewsByName[info.name] = view\n\n\t\t// If the layer name contains draggable we create a draggable for this layer\n\t\tif (info.name.toLowerCase().indexOf(\"draggable\") != -1) {\n\t\t\tview.draggable = new ui.Draggable(view)\n\t\t}\n\n\t\tfor (var i in info.children) {\n\t\t\tcreateView(info.children[info.children.length - 1 - i], view)\n\t\t}\n\n\t}\n\t\t\n\t// Loop through all the photoshop documents\n\tfor (var documentName in FramerPS) {\n\t\t// Load the layers for this document\n\t\tfor (var layerIndex in FramerPS[documentName]) {\n\t\t\tcreateView(FramerPS[documentName][layerIndex])\n\t\t}\n\t}\n\t\n\t\n\tfor (var i in Views) {\n\t\t\n\t\tvar view = Views[i]\n\t\t\n\t\t// // Views without subviews and image should be 0x0 pixels\n\t\tif (!view.image && !view.viewInfo.maskFrame && !view.subViews.length) {\n\t\t\tconsole.log(view.name, view.viewInfo.maskFrame)\n\t\t\tview.frame = {x:0, y:0, width:0, height:0}\n\t\t}\n\t\t\n\t\tfunction shouldCorrectView(view) {\n\t\t\treturn !view.image && !view.viewInfo.maskFrame\n\t\t}\n\n\t\t// If a view has no image or mask, make it the size of it's combined subviews\n\t\tif (shouldCorrectView(view)) {\n\n\t\t\tvar frame = null\n\t\t\t\n\t\t\tfunction traverse(views) {\n\t\t\t\tviews.map(function(view) {\n\n\t\t\t\t\tif (shouldCorrectView(view)) {\n\t\t\t\t\t\treturn\n\t\t\t\t\t}\n\n\t\t\t\t\tif (!frame) {\n\t\t\t\t\t\tframe = view.frame\n\t\t\t\t\t} else {\n\t\t\t\t\t\tframe = frame.merge(view.frame)\n\t\t\t\t\t}\n\n\t\t\t\t\ttraverse(view.subViews)\n\t\t\t\t})\n\t\t\t}\n\t\t\t\n\t\t\ttraverse(view.subViews)\n\t\t\tview.frame = frame\n\t\t\t\n\t\t}\n\t\t\n\t\t// Correct all the view frames for the superView coordinate system\n\t\tif (view.superView) {\n\t\t\tview.frame = view.superView.convertPoint(view.frame)\n\t\t}\n\t\t\n\t}\n\t\n\treturn ViewsByName\n\n}\n\nwindow.PSD = loadViews()\n";
 // static var framer_folder = doc.dir()+ "/framer";
 // static var target_folder = doc.dir()+ "/framer";


//static var  document_path = [[doc fileURL] path].split([doc displayName])[0],
static var  document_path = doc.fileURL().path().split(doc.displayName())[0];
static var  document_name = doc.displayName().replace(".sketch","");
static var  target_folder = document_path;
static var 	images_folder = target_folder + "/images";
static var  framer_folder = target_folder + "/framer";

 
	public function new()
	{
		super();

		try
		getdependencies()
		catch(err:Dynamic)log(err);
		generate();
		var framer=toFramer(tree.getFirstChild().getFirstChild());
		//_trace( framer);
		exportFramer(haxe.Json.stringify(framer));
		createHtml();
		_trace("donnz");
	}
	override function setup():Void
	{
		_trace( "setup");
		var conf= new Config();
		Config.defaults.imagesPath=doc.dir()+"/images/";

		conf.check();
		config=exp.ExportFactory.config=conf.data;
		_trace(config);
		if (config.cleanUp==true)
		cleanup();
	}

	function exportFramer(content:String)
	{

		if(config.allArtBoards!=true){
			
			content =  'window.FramerPS = window.FramerPS || {};
		window.FramerPS["$document_name"] ='+content;
			//_trace("singleArtBoard" +doc.dir()+"view/images/"+activePage.name()+"/"+activeArtboard.name()+"/framer-"+activeArtboard.name()+".json");
			//Global.writeToFile(content,doc.dir()+"view/images/"+activePage.name()+"/"+activeArtboard.name()+"/framer-"+activeArtboard.name()+".json");
			Global.writeToFile(content,framer_folder + "/views." + document_name + ".js");
		}else{
		Global.writeToFile(content,doc.dir()+"/view/framer-"+doc.displayName()+".json");
		}
	}


	public function getdependencies():Void
	{
		// Get JS files from Github
  // var task = [[NSTask alloc] init],
  //     argsArray = [NSArray arrayWithObjects:"-O", framerjs_url, nil];
  // [task setCurrentDirectoryPath:framer_folder];
  // [task setLaunchPath:"/usr/bin/curl"];
  // [task setArguments:argsArray];
  // [task launch];

  var task =ns.NSTask.alloc().init();
  task.setCurrentDirectoryPath(framer_folder);
   task.setLaunchPath("/usr/bin/curl");
   var argsArray= ns.NSArray.arrayWithObjects("-O", framerjs_url, null);
   //var argsArray=untyped  __js__('[NSArray arrayWithObjects:"-O", framerjs_url, nil]');
   task.setArguments(argsArray);
   task.launch();
   Global.writeToFile(framerPS,framer_folder+"/framerps.js");
   Global.writeToFile("var p='popo';",target_folder+"/app.js");
  // // Get library files if one if configured and isn't yet downloaded
  // if(FramerLibraryUrl) {
  //   if(![file_manager fileExistsAtPath:(framer_folder + "/" + FramerLibraryFileName)]) {
  //     var task2 = [[NSTask alloc] init],
  //         argsArray = [NSArray arrayWithObjects:"-O", FramerLibraryUrl, nil];
  //     [task2 setCurrentDirectoryPath:framer_folder];
  //     [task2 setLaunchPath:"/usr/bin/curl"];
  //     [task2 setArguments:argsArray];
  //     [task2 launch];
  //   }
  // }
	}

	function createHtml(){
		_trace( "createHtml");
		// mm better do it with erazor
		 // Create HTML and open in default browser if it's the first time we're exporting
		//if( !ns.NSFileManager.defaultManager().fileExistsAtPath(target_folder + "/index.html",false)){
			_trace( "index.html not exists");
			  var index= new HtmlTemplate();
			  index.docname=doc.displayName()+".js";
			 var out=index.execute();
		
			 _trace( "out="+target_folder+"/index.html");
			 doc.createText(out,target_folder+"/index.html");
		//}
		_trace("after Html" );


			//save_file_from_string(target_folder + "/index.html",  FramerIndexFileContents.replace("{{ views }}",'<script src="framer/views.' + document_name + '.js"></script>'));
			var open_task=ns.NSTask.alloc().init();
			var open_task_args=ns.NSArray.arrayWithObjects(target_folder + "/index.html");
			open_task.setCurrentDirectoryPath(framer_folder);
			open_task.setLaunchPath("/usr/bin/open");
			open_task.setArguments(open_task_args);
			untyped _trace( open_task.launchPath());
			open_task.launch();
		

	// //Obj-c version
 //  if(![file_manager fileExistsAtPath:(target_folder + "/index.html")]) {
 //    save_file_from_string(target_folder + "/index.html",  FramerIndexFileContents.replace("{{ views }}",'<script src="framer/views.' + document_name + '.js"></script>'));
 //    var open_task = [[NSTask alloc] init],
 //        open_task_args = [NSArray arrayWithObjects:(target_folder + "/index.html"), nil];

 //    [open_task setCurrentDirectoryPath:framer_folder];
 //    [open_task setLaunchPath:"/usr/bin/open"];
 //    [open_task setArguments:open_task_args];
 //    [open_task launch];
 //  }
	}

	public function toFramer(tree:TreeNode<Exportable>,?obj:Dynamic)
	{
		_trace("toFramer"+tree.val.name);
		for (node in tree.childIterator()){
			_trace( "inloop"+node.name);
			var treeNode=tree.find(node); //heavy
			//_trace("for in tree");
			//generic 
			var layer:LayerType=cast {};
			var _node= cast(node,exp.ExportLayer);

				layer.id=++id;
				layer.name=_node.name;
					var layerframe:LayerFrame= cast {};
					//_trace('height=${_node.height} type=${_node.type} visible=${_node.visible}');
					layerframe.height=_node.height;
					layerframe.width=_node.width;
					layerframe.x=_node.relx;
					layerframe.y=_node.rely;
					layerframe.rotation=0; //Todo
					
				layer.layerFrame=layerframe;
				layer.maskFrame=null; //Todo
				layer.imageType=null;
				layer.image=null;
				layer.text=null;
				layer.visible=_node.visible;
				//layer.children=[];
				
			_trace("switch type"+node.type);
			switch(node.type){

				case Image:

					var image:ImageType=cast {};
						var frame:Frame=cast {};
							frame.x=_node.relx;
							frame.y=_node.rely;
							frame.width=_node.width;
							frame.height=_node.height;
						image.frame=frame;
						
						image.path=_node.src;
						layer.imageType=_node.format;
						layer.image=image;
				case Svg:
					var image:ImageType=cast {};
						var frame:Frame=cast {};
							frame.x=_node.relx;
							frame.y=_node.rely;
							frame.width=_node.width;
							frame.height=_node.height;
						image.frame=frame;
						
						image.path=_node.src;
						layer.imageType=_node.format;
						layer.image=image;
				case Text:
					untyped layer.text=node.toObject();

				case _:
				_trace("badtype");
				
			}
			_trace("end Switch for "+node.type);
			
			if(obj==null){
				obj=[];
				obj.push(layer);
			}else if(_node.type==ArtBoard){
				_trace("page");
				
				//obj.push(layer);

			

			}else{
				_trace( obj);
				_trace("act");
				if( obj.children!=null)
				obj.children.push(layer);
				else{
					obj.push(layer);
				}
			}
			if (treeNode.hasChildren()){
				layer.children=[];
				toFramer(treeNode,layer);
			}
			_trace("end loop"+layer.name);
		}

		return obj;	
	}
	public static function main(){
		new FramerExporter();
	}

}
@:template('
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black">
<meta name="format-detection" content="telephone=no">
<meta name="viewport" content="width=640,initial-scale=0.5,user-scalable=no">
<style type="text/css" media="screen">
	* {margin:0;padding:0;border:none;-webkit-user-select:none;}
	body {
		background-image: url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAMAAAC6V+0/AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAAZQTFRFMzMzDBMatgEYWQAAABhJREFUeNpiYIADRjhgGNKCw8UfcAAQYACltADJ8fw9RwAAAABJRU5ErkJggg==);
		font: 28px/1em "Helvetica";
		color: #FFF;
		-webkit-tap-highlight-color: rgba(0,0,0,0);
		-webkit-perspective: 1000px;
	}
	::-webkit-scrollbar {
		width: 0px;
		height: 0px;
	}
</style>
</head>
<body>
<script src="framer/views.@docname"></script>

<script src="framer/framer.js"></script><script src="framer/framerps.js"></script>


 <script src="app.js"></script>
 </body>
 </html>
	')

class HtmlTemplate extends erazor.macro.Template{
	public var docname:String;
}