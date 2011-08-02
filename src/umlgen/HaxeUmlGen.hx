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

package umlgen;

using StringTools;
import umlgen.model.ModelType;
import umlgen.model.Package;
import umlgen.handler.IOutputHandler;
import umlgen.handler.GraphvizOutputHandler;
import umlgen.handler.XmiOutputHandler;
import umlgen.handler.OutputPackageMode;

/**
 * The haxe uml generator dynamically creates class diagrams for haxe projects.
 * exit codes:
 * 0 good
 * 1 error
 * 2 dot not installed
 */
class HaxeUmlGen 
{
    /**
     * input filename (xml file from haxe compiler)
     */
    public var inFname(default,default) : String;

    /**
     * output directory. if not set, same as input file
     */
    public var outDir(default, null) : String;

    /**
     * The output handler to use for generation.
     */
    private var handler : IOutputHandler;

    /**
     * if true, don't output anything to the console
     */
    public static var quiet : Bool;

    /**
     * list of data types
     */
    public static var dataTypes( default, null ) : List<ModelType>;
    
    /** 
     * target package for diagram
     */  
    public static var pkg(default,null) : String;
    

    /**
     * current app version
     */
    private static var VERSION = "0.1.1";
    
    private static var AVAILABLE_HANDLERS = {
    	var h:Hash<Class<IOutputHandler>> = new Hash<Class<IOutputHandler>>();
    	h.set("dot", GraphvizOutputHandler);
    	h.set("xmi", XmiOutputHandler);
    	h;
    }

    /**
     * this is the main function.
     */
    public static function main() 
    {
        new HaxeUmlGen().run();
    }

    /**
     * constructor
     */
    public function new() 
    {
        outDir = null;
    }

    /**
     * this is the main driver.
     */
    public function run() 
    {
        try 
        {
        	// parse command line arguemnts
            parseArgs(); 
            
            printInfo();
            
            // let the handler check the requirements
            handler.checkRequirements(this);
            
            // read the input xml file
            readXml(); 
            
            // call the handler
            callHandler(); 
        } catch( ex : String )  
        {
            neko.Lib.println( "HaxeUmlGen Error: " + ex );
            neko.Lib.println( "stack: " + haxe.Stack.exceptionStack() );
            neko.Sys.exit( 1 );
        }
    }
    
    /**
     * Logs the specified string to the console if quiet is not enabled
     * @param out the text to print
     */
    public function log(out:String) : Void
    {
    	if(!quiet)
    	   neko.Lib.println(out);
    }
    
    /**
     * Prints the application information
     */
    private function printInfo() : Void
    {
        // some info
        log( "HaxeUmlGen v" + VERSION + " - (c) 2011 Ian Martins, Daniel Kuschny" );    
    }

    /**
     * parse the command line args
     * @throws string if bad option, input file not found, or output dir not found
     */
    private function parseArgs() 
    {
        var args = neko.Sys.args();
        if( args.length < 2 ) 
        {
        	printInfo();
            checkHelpVer( args[0] );
            neko.Sys.exit(1);
        }
        
        var iter = args.iterator();
         
        // read an create the output handler
        var mode = iter.next();
        if(AVAILABLE_HANDLERS.exists(mode))
        {
            handler = Type.createInstance(AVAILABLE_HANDLERS.get(mode), []);
        }
        else
        {
            throw "invalid output mode: " + mode;
        }
        
        // read the rest of the commands
        while( iter.hasNext() ) 
        {
            var aa = iter.next();
            checkHelpVer( aa , false);
            
            if( aa == "-o" ) 
                outDir = iter.next();
            else if( aa.indexOf( "--outdir=" ) != -1 ) 
                outDir = aa.substr( 9 );
            else if( aa == "-q" || aa == "--quiet" ) 
                quiet = true;
            else if( aa == args[args.length - 1] ) 
                inFname = aa;
            else if(handler.processArg(aa, iter, this))
            {}
            else
            {
            	throw "Unknown option: " + aa;          
            }
        }
        
        // use current dir if none was specified
        if( outDir == null ) 
        {
            var indx = inFname.lastIndexOf( "/" );
            outDir = ( indx == -1 ) ? "." : inFname.substr( 0, indx );
        }
        
        // check data
        if( !neko.FileSystem.exists( inFname ) ) 
            throw "Input file doesn't exist";        
        if( outDir.charAt( outDir.length - 1 ) == "/" || outDir.charAt( outDir.length - 1 ) == "\\" ) 
            outDir = outDir.substr( 0, outDir.length - 1 );        
        if( !neko.FileSystem.exists( outDir ) ) 
            makeOutDir( outDir );        
    }

    /**
     * Ensures the specified output directory exists. 
     * @param outDir the path to the directory to create if not existing
     */
    private function makeOutDir( outDir:String ) 
    {
        if( !neko.FileSystem.exists( outDir ) ) 
            neko.FileSystem.createDirectory( outDir );
        if( !neko.FileSystem.exists( outDir ) ) 
            throw "Couldn't create output directory: " + outDir;        
    }

    /**
     * check for help or version flag.  if found, display output and exit.
     * @param aa current command line arg
     */
    private function checkHelpVer( aa, printError:Bool = true ) 
    {
        if( aa == "-h" || aa == "--help" ) 
        {
            neko.Lib.println( "Usage: haxeumlgen MODE [OPTIONS] [FILE]" );
            neko.Lib.println( "Generate UML diagrams for haXe projects" );
            neko.Lib.println( "  Modes:" );
            
            // print descriptions of all handlers
            for(key in AVAILABLE_HANDLERS.keys())
            {
            	var cl:Class<IOutputHandler> = AVAILABLE_HANDLERS.get(key);
            	var getDescription:Dynamic = Reflect.field(cl, "getDescription");
            	var description:String = Reflect.callMethod(cl, getDescription, []);
            	neko.Lib.println( "    " + key + " - " + description );
            }
            
            neko.Lib.println( "  Global Options:" );
            neko.Lib.println( "    -o --outdir=DIR  Change the output directory.  Defaults to the input directory." );
            neko.Lib.println( "    -q --quiet       Don't output to console" );
            neko.Lib.println( "    -v --version     Show version and exit" );
            neko.Lib.println( "    -h --help        Show this message and exit" );
            
            // let the handlers print their help string for additional arguments
            for(key in AVAILABLE_HANDLERS.keys())
            {
                var cl:Class<IOutputHandler> = AVAILABLE_HANDLERS.get(key);
                var printHelp:Dynamic = Reflect.field(cl, "printHelp");
                Reflect.callMethod(cl, printHelp, []);
            }
            neko.Sys.exit( 0 );
        } else if( aa == "-v" || aa == "--version" ) 
            neko.Sys.exit( 0 );  
        else if(printError)
        {
            log("too few arguments");
            log("try `HaxeUmlGen --help` for more information");      
        }
    }

    /**
     * read the input file
     */
    private function readXml() 
    {
        dataTypes = new InputHandler().readXml( inFname );
    }

    /**
     * Prepares the read xml data and calles the current handler. 
     */
    private function callHandler() 
    {
        // prepare of packages
        var packages:Hash<Package> = new Hash<Package>();
        if(handler.getPackageMode() == OutputPackageMode.Flat)
        {
            for( dd in dataTypes )
            {
            	if(!packages.exists(dd.pkg))
            	{
            		packages.set(dd.pkg, new Package(dd.pkg));
            	}
            	
            	var pkg:Package = packages.get(dd.pkg);
            	pkg.addDataType(dd);
            }
        }
        else
        {
        	for( dd in dataTypes )
            {
            	var pkg = dd.pkg == null ? "" : dd.pkg;
            	var parts = pkg.split(".");
            	
            	// a root package type?
            	if(parts.length == 0) 
            	{
            		if(!packages.exists(""))
            		{
            			packages.set("", new Package(""));
            		}
            		packages.get("").addDataType(dd);
            	}
            	else
            	{
            		var i = 0;
                    var curPkg:Package = null;
                    var pkgList:Hash<Package> = packages;
                    
                    // traverse hierarchy down
                    for(i in 0 ... parts.length)
                    {
                    	// create current node if not available
                    	if(!pkgList.exists(parts[i]))
                        {
                        	if(curPkg == null)
                                pkgList.set(parts[i], new Package(parts[i]));
                            else
                                curPkg.addSubPackage(new Package(parts[i]));
                        }
                        
                        // use this subnode as navigation point 
                        curPkg = pkgList.get(parts[i]);
                        pkgList = curPkg.subPackages;
                    }
                    // add datatype to bottom package
                    curPkg.addDataType(dd);
            	}
            }
        }
        
        // call the handler
        handler.run(packages, this);
    }

}
