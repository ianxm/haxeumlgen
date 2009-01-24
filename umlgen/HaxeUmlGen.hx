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

  /** output directory. if not set, same as input file  **/
  private var outDir : String;

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

  /**
	constructor
   **/
  public function new()
  {
    VERSION = "0.0.1";
    outDir = null;
  }

  /**
	this is the main driver.
   **/
  public function run()
  {
    try
    {
      parseArgs(); // parse command line arguemnts
      readXml(); // read input xml file
      callDot(); // write dot input, call dot
    }
    catch (ex:String)
    {
      neko.Lib.println(ex);
      neko.Sys.exit(1);
    }
  }

  /**
	parse the command line args
   **/
  private function parseArgs()
  {
    var args = neko.Sys.args();
    if( args.length<2 )
    {
      checkHelpVer(args[0]);
      throw ("Not enough arguments");
    }

    var iter = args.iterator();
    while( iter.hasNext() )
    {
      var aa = iter.next();
      checkHelpVer(aa);

      if( aa=="-o" )
	outDir = iter.next();
      
      else if( aa.indexOf("--outdir=") != -1 )
	outDir = aa.substr(9);

      else if( aa == args[args.length-2] )
	inFname = aa;

      else if( aa == args[args.length-1] )
	pkg = aa;

      else
	throw "Unknown option: " + aa;
    }

    if( outDir == null )
    {
      var indx = inFname.lastIndexOf("/");
      outDir = (indx == -1) ? "." : inFname.substr(0, indx);
    }

    if( !neko.FileSystem.exists(inFname) )
      throw "Error: Input file doesn't exist";

    if( !neko.FileSystem.exists(outDir) )
      throw "Error: Output directory doesn't exist";
  }

  /**
	check for help or version flag.  if found, display output and exit.
   **/
  private function checkHelpVer(aa)
  {
      if( aa=="-h" || aa=="--help" )
      {
	neko.Lib.println("HaxeUmlGen v" + VERSION);
	neko.Lib.println("Usage: haxeumlgen [OPTION] [FILE] [PACKAGE]");
	neko.Lib.println("Generate UML diagrams for haXe projects");
	neko.Lib.println("");
	neko.Lib.println(" -o --outdir=DIR	Change the output directory.  Same as input by default");
	neko.Lib.println(" -v --version		Show version and exit");
	neko.Lib.println(" -h --help		Show this message and exit");
	neko.Sys.exit(0);
      }
      else if( aa=="-v" || aa=="--version" )
      {
	neko.Lib.println("HaxeUmlGen v" + VERSION);
	neko.Sys.exit(0);
      }
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
      throw "No classes found in the desired package";

    // write file
    var dotFname = outDir + "/" + pkg + ".dot";
    var fout = neko.io.File.write(dotFname, false);
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
    var pngFname = outDir + "/" + pkg + ".png";
    neko.Sys.command('dot -T png -o ' + pngFname + ' ' + dotFname);
    neko.FileSystem.deleteFile(dotFname);
  }
}
