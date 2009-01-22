package umlgen;

import umlgen.model.ModelType;
import umlgen.model.EnumModel;
import umlgen.model.TypedefModel;
import umlgen.model.Reference;

/**
	The haxe uml generator dynamically creates class diagrams for haxe projects.
**/
class HaxeUmlGen
{
  /** input filename (xml file from haxe compiler) **/
  private var inFname : String;

  /** output filename (png file) **/
  private var outFname : String;

  /** list of data types **/
  private var dataTypes : Hash<ModelType>;

  /**
	this is the main function.
   **/
  public static function main()
  {
    new HaxeUmlGen().run();
  }

  public function new()
  {}

  public function run()
  {
    inFname = "ffi.xml";
    outFname = "ffi_uml.png";

    parseArgs();

    readXml();

    callDot();
  }

  /**
	parse the command line args
   **/
  private function parseArgs()
  { }

  /**
	read the input file
   **/
  private function readXml()
  {
    dataTypes = new Hash<ModelType>();
    var fData = neko.io.File.getContent(inFname);
    var xmlData = Xml.parse(fData).firstElement();
    for( nn in xmlData.elements() )
    {
      var builder : Xml -> ModelType = null;
      switch( nn.nodeName )
      {
      case "enum": builder = buildEnum;
      case "typedef": builder = buildTypedef;
      case "class": continue; // not done yet
      default: continue; // unknown type
      }

      var ret = builder(nn);
      if( ret != null )
	dataTypes.set(ret.path, ret);

      neko.Lib.println("element: " + nn.nodeName + " " + nn.get("path"));
    }
  }

  private function buildEnum(xmlNode:Xml)
  {
    var path = xmlNode.get("path");
    /*
    var sep = path.lastIndexOf(".");
    var pkg  = (sep==-1) ? "" : path.substr(0, sep);
    var name = (sep==-1) ? path : path.substr(sep+1, path.length-sep-1);
    */
    var e = new EnumModel(path);
    for( ee in xmlNode.elements() )
      if( ee.nodeName != "haxe_doc" )
	e.addField(ee.nodeName);

    trace("enum: " + Std.string(e));
    return e;
  }

  private function buildTypedef(xmlNode:Xml)
  {
    // this is to skip some basic typedefs that are formatted strangely
    if( !xmlNode.elementsNamed("a").hasNext() )
      return null;

    var path = xmlNode.get("path");
    /*
    var sep = path.lastIndexOf(".");
    var pkg  = (sep==-1) ? "" : path.substr(0, sep);
    var name = (sep==-1) ? path : path.substr(sep+1, path.length-sep-1);
    */
    var t = new TypedefModel(path);
    for( ee in xmlNode.elementsNamed("a").next().elements() )
      if( ee.nodeName != "haxe_doc" )
	t.addField(buildReference(ee, ee.nodeName));

    trace("typedef: " + Std.string(t));
    return t;
  }

  private function buildReference(node:Xml, name)
  {
    var sub = node.elements().next();
    switch( sub.nodeName )
    {
    case "e": return new Reference(name, sub.get("path"));
    case "c": return new Reference(name, sub.get("path")); // TODO get optional parameter
    case "f": return buildFuncRef(sub, name);
    }
    return null;
  }

  private function buildFuncRef(node:Xml, name)
  {
    var ref = new Reference(name, null, true);
    var pnames = node.get("a").split(":").iterator();
    var params = node.elements();
    while( pnames.hasNext() )
    {
      var pname = pnames.next();
      if( pname=="" ) break;
      var ptype = params.next().get("path");
      ref.addParam(new Reference(pname, ptype));
    }
    ref.type = params.next().get("path"); // set return type
    return ref;
  }

  /**
	call dot.  this writes the dot input file and makes a system call to run dot.
	@todo replace this with a library call
   **/
  private function callDot()
  { }
}
