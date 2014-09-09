import Global.*;
using helpers.Layer;
using helpers.Document;
using HTMLExporter;
import de.polygonal.ds.TreeNode;
import de.polygonal.ds.TreeBuilder;
import exp.*;
import haxe.EnumFlags;
import exp.Behave;

class ZoneExporter extends TemplateExporter{
	public function new():Void
	{
		super();
		
	}

	override public function toHtml(tree:TreeNode<Exportable>,xml:Xml):Xml
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
					var tag=helpers.StringSketch.getTextTag(node.name,"span");
					if (tag.tagName=="T"){


						// var inc=new HTMLExporter.IncView();
						// inc.data={content:"<div>pipo</div>"};
						// var inked= inc.execute();
						// _node=Xml.parse(inked).firstChild();
						var template=doc.loadTxt(config.imagesPath+activePage.name()+"/"+tag.name+".html");

						_node=Xml.parse(template).firstChild();
						_node.addAtt("id",tag.name);
						_node.addAtt("style","display:none");
						position="relative";
						//Global.doc.loadTxt(Global.doc.tag.name+".html");
						//helpers.UI.alert(template);
						
					}else{
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
					}

				case Image:
					_node.set("class","image");
					var img=Xml.createElement("img");
					var tag=helpers.StringSketch.getTextTag(node.name,"div");
					_node.nodeName=tag.tagName;
					_node.set("name",tag.name);
					var classOrId=helpers.StringSketch.getClassOrId(node.name);
					_node.set("name",classOrId.cleanName);
					//img.set("src",node.src);
					// make it fit for perifStrip ( absolute to localhost);
					img.set("src","/"+activePage.name()+"/"+activeArtboard.name()+"/"+node.src);
					for ( classe in classOrId.classes)
						_node.addAtt("class",classe);
					for (id in classOrId.ids)
						_node.addAtt("id",id);
					_node.insertChild(img,0);
				case Container:
					var tag=helpers.StringSketch.getTextTag(node.name,"div");
					var classOrId=helpers.StringSketch.getClassOrId(node.name);

					var subXml=Xml.parse('<${tag.tagName} class="${tag.name}" ></${tag.tagName}>');
					_node=subXml.firstChild();
					_node.set("name",tag.name);
					_node.set("class","container");
					for ( classe in classOrId.classes)
						_node.addAtt("class",classe);
					for (id in classOrId.ids)
						_node.addAtt("id",id);
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
				case Zone:
				_node=Xml.parse("<zone></zone>").firstChild();
				_node.set("class","zone");
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
	static function main():Void
	{
		new ZoneExporter();
	}
}