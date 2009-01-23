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

  /** target package for diagram **/
  private var pkg : String;

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
    outFname = "umlgen.dot";
    pkg = "umlgen";

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
    // write file
    var fout = neko.io.File.write(outFname, false);
    fout.writeString('digraph uml\n');
    fout.writeString('{\n');
    fout.writeString('	center="false";\n');
    fout.writeString('        fontname = "Sans";\n');
    fout.writeString('        fontsize = "8";\n');
    fout.writeString('	rankdir = "TB";\n');
    fout.writeString('        node [ fontname="Sans", fontsize=8, shape="record" ]\n');
    fout.writeString('        edge [ fontname="Sans", fontsize=8, minlen=3 ]\n');

    for( dd in dataTypes.iterator() )
    {
      if( dd.path.indexOf(pkg) != -1 )
	fout.writeString(dd.getDotStr() + '\n');
    }

    fout.writeString('}\n');
    fout.close();

    // call dot
    neko.Sys.command('"c:/Program Files/Graphviz 2.21/bin/dot.exe" -T png -o umlgen.png umlgen.dot');
  }
}
