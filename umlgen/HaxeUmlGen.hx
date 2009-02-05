/*
 * Copyright (c) 2009, Ian Martins
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE HAXE PROJECT CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
 * OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
 * THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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

  /** output directory. if not set, same as input file **/
  private var outDir : String;

  /** background color for image **/
  private var bgColor : String;

  /** foreground color for image **/
  private var fgColor : String;

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
    VERSION = "0.0.2";
    outDir = null;
    bgColor = "white";
    fgColor = "black";
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
	@throws string if dot is not on the execution path
   **/
  private function checkForDot()
  {
    var ret = new neko.io.Process("dot", ["-V"]);
    if( ret.exitCode() != 0 )
      throw "dot is not installed";
  }

  /**
	parse the command line args
	@throws string if bad option, input file not found, or output dir not found
   **/
  private function parseArgs()
  {
    var args = neko.Sys.args();
    if( args.length<1 )
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

      else if( aa=="-b" )
	bgColor = iter.next();

      else if( aa.indexOf("--bgcolor=") != -1 )
	bgColor = aa.substr(10);

      else if( aa=="-f" )
	fgColor = iter.next();
      
      else if( aa.indexOf("--fgcolor=") != -1 )
	fgColor = aa.substr(10);

      else if( aa == args[args.length-1] )
	inFname = aa;

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
	@param aa current command line arg
   **/
  private function checkHelpVer(aa)
  {
      if( aa=="-h" || aa=="--help" )
      {
	neko.Lib.println("HaxeUmlGen v" + VERSION);
	neko.Lib.println("Usage: haxeumlgen [OPTIONS] [FILE]");
	neko.Lib.println("Generate UML diagrams for haXe projects");
	neko.Lib.println("");
	neko.Lib.println(" -o --outdir=DIR	Change the output directory.  Same as input by default");
	neko.Lib.println(" -b --bgcolor=COLOR	Set background color");
	neko.Lib.println(" -f --fgcolor=COLOR	Set foreground color");
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
	@throws string if specified package isn't found or dot fails
   **/
  private function callDot()
  {
    // get list of packages
    var packages = new List<String>();
    for( dd in dataTypes )
      if( !Lambda.exists(packages, function(pp) { return pp==dd.pkg; }) )
	packages.add(dd.pkg);

    // generate a diagram for each package
    for( pp in packages )
    {
      pkg = pp;
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
      buf.add('        bgcolor = "' + bgColor + '";\n');
      buf.add('        node [ fontname="Sans", fontsize=8, shape="record", color="' + fgColor + '", fontcolor="' + fgColor + '" ]\n');
      buf.add('        edge [ fontname="Sans", fontsize=8, minlen=3, color="' + fgColor + '", fontcolor="' + fgColor + '" ]\n');
      for( dd in boxes )
	buf.add(dd.getDotStr() + '\n');
      buf.add('}\n');

      // call dot, pass string buffer to stdin
      if( pkg=="" ) pkg = "Root";
      var pngFname = outDir + "/" + pkg + ".png";
      var proc = new neko.io.Process('dot',['-Tpng', '-o', pngFname]);
      proc.stdin.writeString(buf.toString());
      proc.stdin.close();

      // check exit code
      if( proc.exitCode() != 0 )
	throw "Graphviz failed";
    }
  }
}
