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
	children:Array<LayerType>

}
class FramerExporter{

	var id:Int;
	var sketch:Sketch;

	public function new()
	{
		exp.ExportFactory.extract=function(name:String){
			var flags=new EnumFlags();
		//trace("first="+beginWith(name));
		//return true;

		 switch(exp.ExportFactory.beginWith(name)){
		 
		// case "#": flags.set(Behave.set);
		 case '_': flags.set(Flat);
		 case "+": flags.set(Exportable);
		 //case "_":flags.set(Flat);
		 case _:flags.unset(Behave.Exportable);

		 //default:  false;
		 }
		 return flags;

		}
	}

	public function toJson(tree:TreeNode<Exportable>,obj:Dynamic)
	{
		if( obj.children==null)obj.children=[];
		for (node in tree.childIterator()){
			var treeNode=tree.find(node); //heavy

			//generic 
			var layer:LayerType=cast {};
			var _node= cast(node,exp.ExportLayer);
				layer.id=++id;
				layer.name=_node.name;
					var layerframe:LayerFrame= cast {};
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
				layer.children=[];
				

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
						layer.imageType="png";
						layer.image=image;

				case Text:
					untyped layer.text=node.toObject();

				case _:
				
			}
			
			obj.children.push(layer);
			//xml.insertChild(_node,0);
			if (treeNode.hasChildren()){
				toJson(treeNode,layer);
			}
		}
		return obj;	
	}

}