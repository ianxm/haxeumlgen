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


class TestTypedef extends haxe.unit.TestCase 
{

    public function testTypedefEmpty() 
    {
        var testTypedef = new TypedefModel( "the.pkg.ATypedef" );
        assertEquals( '\t "the.pkg.ATypedef" [ label = "{\\<typedef\\>\\nATypedef|}" ]\n', testTypedef.getDotStr() );
    }

    public function testTypedefOne() 
    {
        var testTypedef = new TypedefModel( "the.pkg.ATypedef" );
        testTypedef.addField( new Reference( "field1", "Int" ) );
        assertEquals( '\t "the.pkg.ATypedef" [ label = "{\\<typedef\\>\\nATypedef|field1 : Int\\l}" ]\n', testTypedef.getDotStr() );
    }

    public function testTypedefTwo() 
    {
        var testTypedef = new TypedefModel( "the.pkg.ATypedef" );
        testTypedef.addField( new Reference( "field1", "String" ) );
        testTypedef.addField( new Reference( "field2", "Cat" ) );
        assertEquals( '\t "the.pkg.ATypedef" [ label = "{\\<typedef\\>\\nATypedef|field1 : String\\lfield2 : Cat\\l}" ]\n', testTypedef.getDotStr() );
    }

}
