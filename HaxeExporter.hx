import Global.*;
import de.polygonal.ds.TreeNode;
import exp.*;
import FramerExporter;
using helpers.Document;


typedef PropsLayerType={
	>LayerType,
	props:Dynamic,
	type:String
}

class HaxeExporter extends FramerExporter{




	function new():Void
	{
		super();
	}
	override function init():Void
	{
		_trace(" helo"+config.imagesPath);
		config.imagesPath= doc.dir()+config.imagesPath;
		generate();

		var framer=toHaxeJson(tree);
		_trace( framer);
		var json=haxe.Json.stringify(framer);
		writeToFile(json);
		_trace(" done");
	}


	function writeToFile(content:String):Void
	{
		_trace("pop");
		Global.writeToFile(content,config.imagesPath+"pop.json");
	}
	
	public function toHaxeJson(tree:TreeNode<Exportable>,?obj:Dynamic)
	{
		_trace("toJson");
		for (node in tree.childIterator()){
			var treeNode=tree.find(node); //heavy
			//_trace("for in tree");
			//generic 
			var layer:PropsLayerType=cast {};
			var _node= cast(node,exp.ExportLayer);

				layer.id=++id;
				layer.name=_node.name;
				layer.props=_node.props;
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
				layer.children=[];
				layer.type=Std.string (_node.type);

			//_trace("switch type"+node.type);
			switch(node.type){

				case Image:

					var image:ImageType=cast {};
						var frame:Frame=cast {};
							frame.x=_node.relx;
							frame.y=_node.rely;
							frame.width=_node.width;
							frame.height=_node.height;
						image.frame=frame;
						
						
						
						image.path=_node.rootSrc;
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

						image.path=_node.rootSrc;
						layer.imageType=_node.format;
						layer.image=image;
				case Text:
					untyped layer.text=node.toObject();

				case _:
				_trace("badtype"+node.type);

			}
			//_trace("end Switch for "+node.type);

			if(obj==null){
				obj=[];
				obj.push(layer);

			}else if(_node.type==Page){
				//listeArts= new List();
				obj.push(layer);
			// }else if (_node.type==ArtBoard){
			// 	stockeArtBoard(layer);
			}else{
			obj.children.push(layer);
			}
			if (treeNode.hasChildren()){
				toHaxeJson(treeNode,layer);
			}
		}

		return obj;	
	}
	var listeArts:List<MSArtboardGroup>= new List();
	function stockeArtBoard(layer:MSArtboardGroup):Void
	{
		listeArts.add(layer);
	}

	static function main():Void
	{
		new HaxeExporter();
	}
}