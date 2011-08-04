/*
 * Copyright (c) 2009-2011, Ian Martins and Daniel Kuschny
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
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
 package umlgen.handler;

using StringTools;
import umlgen.HaxeUmlGen;
import umlgen.model.Package;

/**
 * A handler for generating a graph using Graphviz (dot)
 */
class GraphvizOutputHandler implements IOutputHandler
{
    /**
     * background color for image
     */
    private var bgColor : String;

    /**
     * foreground color for image
     */
    private var fgColor : String;

    /**
     * if true, write chxdoc html files to output directory
     */
    private var forChxdoc : Bool;


    /**
     * Initializes a new instance of the GraphvizOutputHandler class.
     */
    public function new()
    {
    	bgColor = "white";
        fgColor = "black";
        forChxdoc = false;
    }

    /**
     * Processes the specified argument
     * @param arg the argument contianing containing the setting to process
     * @param args the iterator containing the arguments (for accessing next args)
     * @param generator the generator containing the settings
     * @return true if the handler could process the arg, otherwise false
     */
    public function processArg(arg:String, args:Iterator<String>, generator:HaxeUmlGen) : Bool
    {
    	if(arg == "-b")
    	{
    		bgColor = args.next();
    		if( !bgColor.startsWith("#"))
                bgColor = "#" + bgColor;
    		return true;
    	}
    	else if(arg.indexOf("--bgcolor=") != 1)
    	{
            bgColor = arg.substr(10);
            if( !bgColor.startsWith("#"))
                bgColor = "#" + bgColor;
    		return true;
    	}
    	else if(arg == "-f")
    	{
    		fgColor = args.next();
    		 if( !fgColor.startsWith("#"))
                fgColor = "#" + fgColor;
    		return true;
    	}
    	else if(arg.indexOf("--fgcolor=") != 1)
    	{
            fgColor = arg.substr(10);
            if( !fgColor.startsWith("#"))
                fgColor = "#" + fgColor;
    		return true;
    	}
    	else if( arg == "-c" || arg == "--chxdoc" )
        {
        	 forChxdoc = true;
             return true;
        }


    	return false;
    }

    /**
     * first make sure dot is installed and in the path
     */
    public function checkRequirements(generator:HaxeUmlGen) : Void
    {
    	try
        {
            var ret = new neko.io.Process( "dot", [ "-V" ] );
            ret.exitCode();
        } catch( ex : String )
        {
            neko.Lib.println( "HaxeUmlGen Error: Graphviz is not installed" );
            neko.Sys.exit( 2 );
        }
    }

    /**
     * call dot.  this writes the dot input file and makes a system call to run dot.
     * @throws string if specified package isn't found or dot fails
     */
    public function run(packages:Hash<Package>, generator:HaxeUmlGen) : Void
    {
    	for( pp in packages )
        {
            var boxes = pp.dataTypes;
            if( boxes.isEmpty() )
                throw "No classes found in the desired package";

                // write dot commands to string buffer
            var buf = new StringBuf();
            buf.add( 'digraph uml\n' );
            buf.add( '{\n' );
            buf.add( '        label = "Package: ' + pp.name + '";\n' );
            buf.add( '        fontname = "Sans";\n' );
            buf.add( '        fontsize = "8";\n' );
            buf.add( '        bgcolor = "' + bgColor + '";\n' );
            buf.add( '           fontcolor = "' + fgColor + '";\n' );
            buf.add( '        node [ fontname="Sans", fontsize=8, shape="record", color="' + fgColor + '", fontcolor="' + fgColor + '" ]\n' );
            buf.add( '        edge [ fontname="Sans", fontsize=8, minlen=3, color="' + fgColor + '", fontcolor="' + fgColor + '" ]\n' );
            for( dd in boxes )
                buf.add( dd.getDotStr() + '\n' );
            buf.add( '}\n' );

            // call dot, pass string buffer to stdin
            if( pp.name == "" )
                pp.name = "Root";
            var pngFname = generator.outDir + "/" + pp.name + ".png";
            var proc = new neko.io.Process( 'dot', [ '-Tpng', '-o', pngFname ] );
            proc.stdin.writeString( buf.toString() );
            proc.stdin.close();

            // check exit code FIXME why does this fail on windows?
            if( proc.exitCode() != 0 )
                throw "Graphviz failed";
            if( forChxdoc )
                writeChxdocHtml( generator.outDir, pp.name );

            generator.log( "Generated Diagram for Package: " + pp.name);
        }
        generator.log( "\nComplete." );
    }

    /**
     * Prints the help for this handler.
     */
    public static function printHelp() : Void
    {
        neko.Lib.println("  Graphviz Options:");
        neko.Lib.println("    -b --bgcolor=COLOR  Set background color");
        neko.Lib.println("    -f --fgcolor=COLOR  Set foreground color");
        neko.Lib.println("    -c --chxdoc         Write html files to output directory for chxdoc");
    }
    /**
     * Gets the description of this handler
     */
    public static function getDescription() : String
    {
    	return "generate a image using Graphviz";
    }

    /**
     * Gets the mode how packages should get organized.
     */
    public function getPackageMode() : OutputPackageMode
    {
    	return OutputPackageMode.Flat;
    }

    /**
     * write html file to output directory for chxdoc integration
     * @param outDir output directory where uml images are.
     * @param packageName name of current package
     */
    private function writeChxdocHtml( outDir, packageName )
    {
        var fout = neko.io.File.write( outDir + "/" + packageName + ".html", false );
        fout.writeString( "<html>\n" );
        fout.writeString( "<head><title>Class Diagram for " + packageName + " Package</title></head>\n" );
        fout.writeString( "<body bgcolor=\"" + bgColor + "\">\n" );
        fout.writeString( "  <center>\n" );
        fout.writeString( "    <img alt=\"Class Diagram for " + packageName + " Packge\" src=\"" + packageName + ".png\">\n" );
        fout.writeString( "  </center>\n" );
        fout.writeString( "</body>\n" );
        fout.writeString( "</html>\n" );
        fout.close();
    }
}