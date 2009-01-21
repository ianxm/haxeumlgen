package umlgen;

/**
	The haxe uml generator dynamically creates class diagrams for haxe projects.
**/
class HaxeUmlGen
{
  /** input filename (xml file from haxe compiler) **/
  var inFname : String;

  /** output filename (png file) **/
  var outFname : String;

  /** list of classes **/
  var classes : List<ComplexType>;

  /**
	this is the main function.
   **/
  public static function main()
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
  public static function parseArgs()
  { }

  /**
	read the input file
   **/
  public static function readXml()
  {
    classes = new List<ComplexType>();
  }

  /**
	call dot.  this writes the dot input file and makes a system call to run dot.
	@todo replace this with a library call
   **/
  public static function callDot()
  { }
}
