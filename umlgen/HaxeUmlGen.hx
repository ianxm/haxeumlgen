package umlgen;

import umlgen.model.ModelType;

/**
	The haxe uml generator dynamically creates class diagrams for haxe projects.

	exit codes:
	 0 good
	 1 error
	 2 dot not installed
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
  public static var dataTypes(default,null) : List<ModelType>;

  /** current app version **/
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
      checkForDot();
      parseArgs(); // parse command line arguemnts
      readXml(); // read input xml file
      callDot(); // write dot input, call dot
    }
    catch (ex:String)
    {
      neko.Lib.println("Error: " + ex);
      if( ex=="dot is not installed" )
	neko.Sys.exit(2);
      else
	neko.Sys.exit(1);
    }
  }

  /**
	first make sure dot is installed and in the path
   **/
  private function checkForDot()
  {
    var ret = new neko.io.Process("dot", ["-V"]);
    if( ret.exitCode() != 0 )
      throw "dot is not installed";
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

    // write dot commands to string buffer
    var buf = new StringBuf();
    buf.add('digraph uml\n');
    buf.add('{\n');
    buf.add('        label = "Package: ' + pkg + '";\n');
    buf.add('        fontname = "Sans";\n');
    buf.add('        fontsize = "8";\n');
    buf.add('        node [ fontname="Sans", fontsize=8, shape="record" ]\n');
    buf.add('        edge [ fontname="Sans", fontsize=8, minlen=3 ]\n');
    for( dd in boxes )
      buf.add(dd.getDotStr() + '\n');
    buf.add('}\n');

    // call dot, pass string buffer to stdin
    var pngFname = outDir + "/" + pkg + ".png";
    var proc = new neko.io.Process('dot',['-Tpng', '-o', pngFname]);
    proc.stdin.writeString(buf.toString());
    proc.stdin.close();

    // check exit code
    if( proc.exitCode() != 0 )
      throw "Graphviz failed";
  }
}
