SketchbasicExporter
===================



base work for a generic exporter from Sketch
uses SketchApi https://github.com/postite/sketchApi

this lib is written in haxe see haxe.org for details.

- provide a generic exporter Tree filled with exportables nodes.
- provide Enums as export Behaviours (based on layer names for instances but can be changed .thanks to EnumFlags)
- choose between realslices or layernames ( slices winsin cascade)
- export to xml and Json by default
- proof of concept templates for Framer export ( json based ) end Html export ( dom ). not finished at all


this is very WIP even this file is not finished :)

#how to use it ?
install haxe (haxe.org)
this makes uses of the following librairies 
erazor (exporting html views)
polygonal-ds (Tree)




#TODO:
- use sketchApi as haxelib
- use it on a real use case 
- define more Behaviours ... adjust them.
- scaling ( retina etc...)
- masks
- border boundings
- centered elements
- rotation
- make generic export Options ( global scale etc ...) //done 

## html:
	- generate CSS
	- investingate Bootstraping
## Framer:
	- lots

## looping:
	- choose between all artboards/Page or single //done




// due to a bug in jsTalk a hack is necessary to convert escaped quotes // in CopyPlug
