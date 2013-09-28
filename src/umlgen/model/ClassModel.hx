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

using Lambda;
import umlgen.HaxeUmlGen;
import umlgen.Utils;

/**
 * a class
 */
class ClassModel implements ModelType 
{
    /**
     * package and class name
     */
    public var path( default, null ) : String;

    /**
     * package
     */
    public var pkg( default, null ) : String;

    /**
     * class name
     */
    public var type( default, null ) : String;

    /**
     * if true, this is an interface
     */
    public var isInterface(default, null) : Bool;

    /**
     * this contains fields and methods
     */
    public var fields(default, null) : List<Reference>;

    /**
     * this is a list of super classes
     */
    public var parents(default, null) : List<Reference>;

    /**
     * constructor
     * @param p the class' path (package and class name)
     * @param i if true, this is an interface
     */
    public function new( p, i ) 
    {
        path = p;
        var pathSep = Reference.separatePath( path );
        pkg = pathSep.pkg;
        type = pathSep.type;
        isInterface = i;
        fields = new List<Reference>();
        parents = new List<Reference>();
    }

    /**
     * add a super class
     * @param p this class' parent
     */
    inline public function addParent( p ) 
    {
        parents.add( p );
    }

    /**
     * add a field
     * @param f the new field
     */
    inline public function addField( f ) 
    {
        if( f != null )
            fields.add( f );
    }

    /**
     * output the class in dot format.  this also connects it to others
     * @return dot statements for this class
     */
    public function getDotStr() : String 
    {
        var strBuf = new StringBuf();
        var topBox = ( isInterface ) ? '\\<interface\\>\\n' + type : type;
        strBuf.add( '\t "' + path + '" [ label = "{' + topBox + '|' + getFieldsDotStr() + '|' + getMethodsDotStr() + '}" ]\n' );
        if( !parents.isEmpty() ) 
        {
            strBuf.add( '\t  edge [ arrowhead = "empty" ]\n' );
            for( pp in parents )
                strBuf.add( '\t  "' + path + '" -> "' + pp.path + '"\n' );
        }
        var assoc = findAssociations();
        if( !assoc.isEmpty() ) 
        {
            strBuf.add( '\t  edge [ arrowhead = "none" ]\n' );
            for( aa in assoc )
                strBuf.add( '\t  "' + path + '" -> "' + aa.path + '"\n' );
        }
        return strBuf.toString();
    }

    /**
     * output the fields as a dot string
     * @return dot expression for all fields
     */
    private function getFieldsDotStr() : String 
    {
        var strBuf = new StringBuf();
        var isInherited = this.isInherited;
        var sortedFields = fields.filter( function(ii) return !ii.isFunc && !isInherited(ii) ).array();
        sortedFields.reverse();
        for( ff in sortedFields )
            strBuf.add( ff.getFieldStr() );
        return strBuf.toString();
    }

    /**
     * output the methods as a dot string
     * @return dot expression for all methods
     */
    private function getMethodsDotStr() : String 
    {
        var strBuf = new StringBuf();
        var isInherited = this.isInherited;
        var sortedFields = fields.filter( function(ii) return ii.isFunc && !isInherited(ii) ).array();
        sortedFields.reverse();
        for( mm in sortedFields )
            strBuf.add( mm.getFieldStr() );
        return strBuf.toString();
    }

    /**
     * @return true if this field is inherited from a parent
     */
    private function isInherited( ref : Reference ) 
    {
        for( pp in parents ) 
        {
            var pobj = Utils.findFirst( HaxeUmlGen.dataTypes, function(dd) return dd.path==pp.path );
            if( pobj == null ) 
                throw "parent not found";            
            if( !Std.is( pobj, ClassModel ) ) 
                throw "parent not class";            
            if( cast( pobj, ClassModel ).hasRef( ref ) ) 
                return true;            
        }
        return false;
    }

    /**
     * find out if this class has the given reference
     * @return true if this class has the given field
     */
    public function hasRef( ref : Reference ) 
    {
        return fields.exists( function(ff) return ff.name == ref.name );
    }

    /**
     * find out which data types this class is associated with
     * @return list of references of associated data types
     */
    private function findAssociations() 
    {
        var assoc = new List<Reference>();
        for( rr in fields ) 
        {
            // add fields and field type params, only add each reference once
            for( aa in rr.inPkg( HaxeUmlGen.pkg ) )
                if( !assoc.exists( function(tt) return aa.path==tt.path ) )
                    assoc.add( aa );
        }
        return assoc;
    }

}
