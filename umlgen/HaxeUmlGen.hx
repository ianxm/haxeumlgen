package umlgen;

import umlgen.model.ModelType;
import umlgen.input.InputHandler;

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
    inFname = "umlgen.xml";
    outFname = "umlgen_uml.png";

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
    dataTypes = new InputHandler().readXml(inFname);
  }

  /**
	call dot.  this writes the dot input file and makes a system call to run dot.
	@todo replace this with a library call
   **/
  private function callDot()
  { 
    //var fout = neko.io.File.write(outFname);
  }
}
