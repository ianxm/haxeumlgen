package umlgen;

import umlgen.model.ModelType;
import umlgen.model.EnumModel;
import umlgen.model.TypedefModel;
import umlgen.model.ParamModel;

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
  private var dataTypes : List<ModelType>;

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
    dataTypes = new List<ModelType>();
    var fData = neko.io.File.getContent(inFname);
    var xmlData = Xml.parse(fData).firstElement();
    for( nn in xmlData.elements() )
    {
      var builder : Xml -> ComplexType = null;
      switch( nn.nodeName )
      {
      case "enum": builder = buildEnum;
      case "typedef": builder = buildTypedef;
      case "class": continue; // not done yet
      default: continue; // unknown type
      }

      var ret = builder(nn);
      if( ret != null )
	dataTypes.add(ret);

      neko.Lib.println("element: " + nn.nodeName + " " + nn.get("path"));
    }
  }

  private function buildEnum(xmlNode:Xml)
  {
    var path = xmlNode.get("path");
    var sep = path.lastIndexOf(".");
    var pkg  = (sep==-1) ? "" : path.substr(0, sep);
    var name = (sep==-1) ? path : path.substr(sep+1, path.length-sep-1);

    var e = new EnumModel(pkg, name);
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
    var sep = path.lastIndexOf(".");
    var pkg  = (sep==-1) ? "" : path.substr(0, sep);
    var name = (sep==-1) ? path : path.substr(sep+1, path.length-sep-1);

    var t = new TypedefModel(pkg, name);
    for( ee in xmlNode.elementsNamed("a").next().elements() )
      if( ee.nodeName != "haxe_doc" )
	t.addField(new ParamModel(ee.nodeName, ee.elements().next().get("path")));

    trace("typedef: " + Std.string(t));
    return t;
  }

  /**
	call dot.  this writes the dot input file and makes a system call to run dot.
	@todo replace this with a library call
   **/
  private function callDot()
  { }
}
