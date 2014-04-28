import Global.*;
using helpers.Layer;
using helpers.Document;
import de.polygonal.ds.TreeNode;
import de.polygonal.ds.TreeBuilder;
import exp.*;
import haxe.EnumFlags;
import exp.Behave;

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
class FramerExporter{

	var id:Int;
	var sketch:Sketch;

	public function new()
	{
		// exp.ExportFactory.extract=function(name:String){
		//  var flags=new EnumFlags();

		//  switch(exp.ExportFactory.beginWith(name)){
		//  case '_': flags.set(Flat);
		//  case "+": flags.set(Exportable);		 
		//  case _:flags.set(Behave.Exportable);		 
		//  }
		//  return flags;

		// }
	}

	public function toJson(tree:TreeNode<Exportable>,?obj:Dynamic)
	{
		_trace("toJson");
		for (node in tree.childIterator()){
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
				layer.children=[];
				
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
			//_trace("end Switch for "+node.type);
			
			if(obj==null){
				obj=[];
				obj.push(layer);
			}else if(_node.type==Page){
				obj.push(layer);
			}
			else{
			obj.children.push(layer);
			}
			if (treeNode.hasChildren()){
				toJson(treeNode,layer);
			}
		}

		return obj;	
	}

}