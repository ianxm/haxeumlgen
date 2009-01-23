package umlgen.input;

import umlgen.model.ModelType;
import umlgen.model.ClassModel;
import umlgen.model.TypedefModel;
import umlgen.model.EnumModel;
import umlgen.model.Reference;

class InputHandler
{
  public function new()
  { }

  public function readXml(fname)
  {
    var dataTypes = new Hash<ModelType>();
    var fData = neko.io.File.getContent(fname);
    var xmlData = Xml.parse(fData).firstElement();
    for( nn in xmlData.elements() )
    {
      var builder : Xml -> ModelType = null;
      switch( nn.nodeName )
      {
      case "enum": builder = buildEnum;
      case "typedef": builder = buildTypedef;
      case "class": builder = buildClass;
      default: continue; // unknown type
      }

      var ret = builder(nn);
      if( ret != null )
	dataTypes.set(ret.path, ret);

      //neko.Lib.println("element: " + nn.nodeName + " " + nn.get("path"));
    }
    return dataTypes;
  }

  private function buildEnum(xmlNode:Xml)
  {
    var path = xmlNode.get("path");
    var e = new EnumModel(path);
    for( ee in xmlNode.elements() )
      if( ee.nodeName != "haxe_doc" )
	e.addField(ee.nodeName);

    //trace("enum: " + Std.string(e));
    return e;
  }

  private function buildTypedef(xmlNode:Xml)
  {
    // this is to skip some basic typedefs that are formatted strangely
    if( !xmlNode.elementsNamed("a").hasNext() )
      return null;

    var path = xmlNode.get("path");
    var ret = new TypedefModel(path);
    for( ee in xmlNode.elementsNamed("a").next().elements() )
      if( ee.nodeName != "haxe_doc" )
	ret.addField(buildReference(ee.elements().next(), ee.nodeName, true, false));

    //trace("typedef: " + Std.string(ret));
    return ret;
  }

 private function buildClass(xmlNode:Xml)
  {
    var path = xmlNode.get("path");
    var ret = new ClassModel(path);
    for( ee in xmlNode.elements() )
    {
      if( ee.nodeName == "implements" )
	ret.addParent(new Reference("implements", ee.get("path")));

      else if( ee.nodeName == "extends" )
	ret.addParent(new Reference("extends", ee.get("path")));

      else if( ee.nodeName == "haxe_doc" )
	continue;

      else
      {
	var isPublic = ee.exists("public") && ee.get("public")=="1";
	var isStatic = ee.exists("static") && ee.get("static")=="1";
	ret.addField(buildReference(ee.elements().next(), ee.nodeName, isPublic, isStatic));
      }
    }

    //trace("class: " + Std.string(ret));
    return ret;
  }

  private function buildReference(node:Xml, name, isPublic, isStatic)
  {
    switch( node.nodeName )
    {
    case "e": return new Reference(name, node.get("path"), false, isPublic, isStatic);
    case "c": return new Reference(name, node.get("path"), false, isPublic, isStatic);
    case "f": return buildFuncRef(node, name, isPublic, isStatic);
    }
    return null;
  }

  private function buildFuncRef(node:Xml, name, isPublic, isStatic)
  {
    var ref = new Reference(name, null, true, isPublic, isStatic);
    var pnames = node.get("a").split(":").iterator();
    var params = node.elements();
    while( pnames.hasNext() )
    {
      var pname = pnames.next();
      if( pname=="" ) break;
      ref.addParam(buildReference(params.next(), pname, false, false));
    }
    ref.type = params.next().get("path"); // set return type
    return ref;
  }
}