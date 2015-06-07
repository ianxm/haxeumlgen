/*
 * Copyright (c) 2009-2015, haxeumlgen contrubuters
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

/**
 * a typedef
 */
class TypedefModel implements ModelType
{
    /**
     * package and type, for functions this is the return type
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
    private var fields : List<Reference>;

    /**
     * constructor
     * @param p path (package and type name)
     */
    public function new( p )
    {
        path = p;
        var pathSep = Reference.separatePath( path );
        pkg = pathSep.pkg;
        type = pathSep.type;
        fields = new List<Reference>();
    }

    /**
     * add a field
     * @param f the new field
     */
    public function addField( f )
    {
        fields.add( f );
    }

    /**
     * output this type as a dot string
     * @return dot statement
     */
    public function getDotStr() : String
    {
        var sep = path.lastIndexOf( "." );
        var name = ( sep == -1 ) ? path : path.substr( sep + 1, path.length - sep - 1 );
        return '\t "' + path + '" [ label = "{\\<typedef\\>\\n' + name + '|' + getFields() + '}" ]\n';
    }

    /**
     * output the params as a dot string
     * @return dot expression
     */
    private function getFields() : String
    {
        var strBuf = new StringBuf();
        for( ff in fields )
            strBuf.add( ff.getParamStr() + "\\l" );
        return strBuf.toString();
    }

}
