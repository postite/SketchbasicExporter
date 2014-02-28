import Global.*;
using helpers.Layer;
using helpers.Document;
import de.polygonal.ds.TreeNode;
import de.polygonal.ds.TreeBuilder;
import exp.*;

class HTMLExporter
{

	var html:Xml;
	public function new()
	{
		
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
				case Text:
					 _node.set("class","text");
					 position="relative";
					 var tag=helpers.StringSketch.getTextTag(node.name);
					 var texte=  cast (node,exp.ExportText).text.text;
					// _node.insertChild(Xml.createCData(cast (node,exp.ExportText).text.text),0);
					 var subXml=Xml.parse('<${tag.tagName} class="${tag.name}">$texte</${tag.tagName}>');
					 	//cast (node,exp.ExportText).text.text),0);
						
					//_node.insertChild(subXml,0);
					_node=subXml;
				case Image:
					_node.set("class","image");
					var img=Xml.createElement("img");
					img.set("src",node.src);
					_node.insertChild(img,0);
				case Container:
					_node.set("class","container");
					
			}
			if(position=="absolute")
			_node.set("style",
				'position:$position;
				left:${castednode.relx}px;
				top:${castednode.rely}px;
				width:${castednode.width}px;
				height:${castednode.height}px;'
				);
			xml.insertChild(_node,0);
			if (treeNode.hasChildren()){
				toHtml(treeNode, _node); //recursion
			}
		}
		html=xml;
		return xml;
	}


	public function export()
	{
	
		var t= new HtmlView();
		t.title=doc.displayName();
		t.content=html.toString();
		var export = t.execute();
		Global.writeToFile(export,doc.dir()+"/view/"+doc.displayName()+".html");
	
	}
}


#if !display
@template('
<!doctype html><html lang="en"><head><meta charset="UTF-8" /><title>@title</title></head><body>
@content
</body></html>

	')

class HtmlView extends erazor.macro.Template{
	public var content:String;
	public var title:String;
}
#end