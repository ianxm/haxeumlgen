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
  public static var pkg(default,null) : String;

  /** list of data types **/
  private var dataTypes : List<ModelType>;

  private var VERSION : String;

  /**
	this is the main function.
   **/
  public static function main()
  {
    new HaxeUmlGen().run();
  }

  public function new()
  {
    VERSION = "0.0.1";
  }

  public function run()
  {
    parseArgs(); // parse command line arguemnts
    readXml(); // read input xml file
    callDot(); // write dot input, call dot
  }

  /**
	parse the command line args
   **/
  private function parseArgs()
  {
    var args = neko.Sys.args();
    if( args.length<2 )
      showHelp();

    for( aa in args )
      if( aa == args[args.length-2] )
	inFname = aa;

      else if( aa == args[args.length-1] )
	pkg = aa;

      else if( aa=="-h" || aa=="--help" )
	showHelp();
  }

  private function showHelp()
  {
    neko.Lib.println("HaxeUmlGen v" + VERSION);
    neko.Lib.println("usage: haxeUmlGen [options] [xml file] [package]");
    neko.Lib.println("");
    neko.Lib.println("options:");
    neko.Lib.println(" -h --help	show this message and exit");
    neko.Sys.exit(0);
  }

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
    var boxes = dataTypes.filter(function(dd) { return dd.pkg==pkg; });
    if( boxes.isEmpty() )
    {
      neko.Lib.println("No classes found in the desired package");
      neko.Sys.exit(0);
    }

    // write file
    var fout = neko.io.File.write(pkg+".dot", false);
    fout.writeString('digraph uml\n');
    fout.writeString('{\n');
    fout.writeString('        fontname = "Sans";\n');
    fout.writeString('        fontsize = "8";\n');
    fout.writeString('        node [ fontname="Sans", fontsize=8, shape="record" ]\n');
    fout.writeString('        edge [ fontname="Sans", fontsize=8, minlen=3 ]\n');

    for( dd in boxes )
      fout.writeString(dd.getDotStr() + '\n');

    fout.writeString('}\n');
    fout.close();

    // call dot
    neko.Sys.command('dot -T png -o '+pkg+'.png '+pkg+'.dot');
  }
}
