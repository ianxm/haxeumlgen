/*
 * Copyright (c) 2009, Ian Martins
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

package umlgen.model;

import umlgen.HaxeUmlGen;

class Reference 
{
    /**
     * package and type, for functions this is the return type
     */
    public var path( default, set ) : String;

    /**
     * package
     */
    public var pkg( default, null ) : String;

    /**
     * class name
     */
    public var type( default, null ) : String;

    /**
     * variable name
     */
    public var name( default, null ) : String;

    /**
     * true if variable is static
     */
    public var isStatic( default, null ) : Bool;

    /**
     * public or private, stored as symbol
     */
    public var protection( default, null ) : String;

    /**
     * return true if this references a function
     */
    public var isFunc( default, null ) : Bool;

    /**
     * type parameter
     */
    public var tParams( default, null ) : List<Reference>;

    /**
     * list of params if this is a function
     */
    public var params( default, null ) : List<Reference>;	
	
	public var valueGet:String;
	public var valueSet:String;
	public var isPublic:Bool;
	public var defaultValue:String;

	public function toString():String
	{
		return this.name + " " + this.type + " " + this.pkg;
	}
	
    /**
     * constructor
     * @param n name
     * @param p path
     * @param f if true, function
     * @param s if true, static
     * @param pr protection
     */
    public function new( n, p, ?f = false, ?pr = false, ?s = false ) 
    {
        name = n;
        path = p;
        isFunc = f;
        protection = ( pr ) ? "+" : "-";
        isStatic = s;
        params = ( isFunc ) ? new List<Reference>() : null;
        tParams = new List<Reference>();
    }

    private function set_path( path )
    {
        this.path = path;
        var pathSep = Reference.separatePath( path );
        pkg = pathSep.pkg;
        type = pathSep.type;
        return path;
    }

    /**
     * add a param
     * @param r new param
     */
    inline public function addParam( r ) 
    {
        if( r != null )
            params.add( r );
    }

    /**
     * add a type param
     * @param r new type param
     */
    inline public function addTParam( r ) 
    {
        tParams.add( r );
    }

    /**
     * output this type as a function parameter
     * @return dot expression for a parameter
     */
    public function getParamStr() : String 
    { 
        var type = ( pkg == HaxeUmlGen.pkg ) ? type : path;
        return name + getFuncParams() + " : " + type + getTParamsStr();
    }

    /**
     * output this type as a class field
     * @return dot expression for a field
     * @todo underline statics
     */
    public function getFieldStr() : String 
    {
        var type = ( pkg == HaxeUmlGen.pkg ) ? type : path;
        return protection + " " + name + getFuncParams() + " : " + type + getTParamsStr() + "\\l";
    }

    /**
     * get type params for field str
     * @return dot expression for a type parameter
     */
    private function getTParamsStr() : String 
    {
        if( tParams.isEmpty() ) 
            return "";        
        var strBuf = new StringBuf();
        strBuf.add( "\\<" );
        for( pp in tParams ) 
        {
            var type = ( pp.pkg == HaxeUmlGen.pkg ) ? pp.type : pp.path;
            strBuf.add( type );
            if( pp != tParams.last() ) 
                strBuf.add( ", " );            
        }
        strBuf.add( "\\>" );
        return strBuf.toString();
    }

    /**
     * output the params as a dot string
     * @return dot expression for a function param
     */
    public function getFuncParams() : String 
    {
        if( !isFunc ) 
            return "";        
        var strBuf = new StringBuf();
        strBuf.add( " (" );
        for( pp in params )
            if( pp != params.last() ) 
                strBuf.add( pp.getParamStr() + ", " );
            else
                strBuf.add( pp.getParamStr() );
        strBuf.add( ")" );
        
        return strBuf.toString();
    }

    /**
     * get a list of this type and its children that are in the specified package
     * @param p package name
     * @return list of types in the package
     */
    public function inPkg( p : String ) : List<Reference> 
    {
        var ret = new List<Reference>();

        // check type params
        for( pp in tParams )
            for( pp2 in pp.inPkg( p ) )
                ret.add( pp2 );

        // check params
        if( isFunc ) 
            for( pp in params )
                for( pp2 in pp.inPkg( p ) )
                    ret.add( pp2 );

        // check me
        if( p == pkg ) 
            ret.add( this );        
        return ret;
    }

    /**
     * separate path into package and type name
     * @param path the full path
     * @return package and type names
     */
    public static function separatePath( path : String ) 
    {
        if( path == null ) 
            return 
            { pkg : null, type : null };        
        var sep = path.lastIndexOf( "." );
        var pkg = ( sep == -1 ) ? "" : path.substr( 0, sep );
        var type = ( sep == -1 ) ? path : path.substr( sep + 1, path.length - sep - 1 );
        return { pkg : pkg, type : type };
    }
}
