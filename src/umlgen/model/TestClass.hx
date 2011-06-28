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


class TestClass extends haxe.unit.TestCase 
{

    public function testClassEmpty() 
    {
        var testClass = new ClassModel( "the.pkg.AClass", false );
        assertEquals( '\t "the.pkg.AClass" [ label = "{AClass||}" ]\n', testClass.getDotStr() );
    }

    public function testClassOneField() 
    {
        var testClass = new ClassModel( "the.pkg.AClass", false );
        testClass.addField( new Reference( "aField", "Int", false, false, false ) );
        var check = '\t "the.pkg.AClass" [ label = "{AClass|- aField : Int\\l|}" ]\n';
        assertEquals( check, testClass.getDotStr() );
    }

    public function testClassTwoFields() 
    {
        var testClass = new ClassModel( "the.pkg.AClass", false );
        testClass.addField( new Reference( "aField1", "Int", false, false, false ) );
        testClass.addField( new Reference( "aField2", "String", false, true, false ) );
        var check = '\t "the.pkg.AClass" [ label = "{AClass|- aField1 : Int\\l+ aField2 : String\\l|}" ]\n';
        assertEquals( check, testClass.getDotStr() );
    }

    public function testClassOneMethod() 
    {
        var testClass = new ClassModel( "the.pkg.AClass", false );
        testClass.addField( new Reference( "aMethod", "Void", true, false, false ) );
        var check = '\t "the.pkg.AClass" [ label = "{AClass||- aMethod () : Void\\l}" ]\n';
        assertEquals( check, testClass.getDotStr() );
    }

    public function testClassOneMethodWithParam() 
    {
        var testClass = new ClassModel( "the.pkg.AClass", false );
        var method = new Reference( "aMethod", "Void", true, false, false );
        method.addParam( new Reference( "aParam", "Int" ) );
        testClass.addField( method );
        var check = '\t "the.pkg.AClass" [ label = "{AClass||- aMethod (aParam : Int) : Void\\l}" ]\n';
        assertEquals( check, testClass.getDotStr() );
    }

    public function testClassTwoMethods() 
    {
        var testClass = new ClassModel( "the.pkg.AClass", false );
        testClass.addField( new Reference( "aMethod1", "Void", true, false, false ) );
        testClass.addField( new Reference( "aMethod2", "String", true, true, false ) );
        var check = '\t "the.pkg.AClass" [ label = "{AClass||- aMethod1 () : Void\\l+ aMethod2 () : String\\l}" ]\n';
        assertEquals( check, testClass.getDotStr() );
    }

    public function testClassOneFieldOneMethod() 
    {
        var testClass = new ClassModel( "the.pkg.AClass", false );
        testClass.addField( new Reference( "aField", "Int", false, false, false ) );
        testClass.addField( new Reference( "aMethod", "String", true, true, false ) );
        var check = '\t "the.pkg.AClass" [ label = "{AClass|- aField : Int\\l|+ aMethod () : String\\l}" ]\n';
        assertEquals( check, testClass.getDotStr() );
    }

    public function testInterface() 
    {
        var testClass = new ClassModel( "the.pkg.AClass", true );
        var check = '\t "the.pkg.AClass" [ label = "{\\<interface\\>\\nAClass||}" ]\n';
        assertEquals( check, testClass.getDotStr() );
    }

}
