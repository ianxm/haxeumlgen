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

package umlgen.model;

class TestReference extends haxe.unit.TestCase
{
  public function testReferenceVarInt()
  {
    var field = new Reference("aField", "Int", false, false);
    assertEquals("- aField : Int\\l", field.getFieldStr());
    assertEquals("aField : Int", field.getParamStr());
  }

  public function testReferenceVarCar()
  {
    var field = new Reference("anotherField", "Car", false, true);
    assertEquals("+ anotherField : Car\\l", field.getFieldStr());
    assertEquals("anotherField : Car", field.getParamStr());
  }

  public function testReferenceFuncEmpty()
  {
    var field = new Reference("aFunc", "Foo", true, false);
    assertEquals("- aFunc() : Foo\\l", field.getFieldStr());
    assertEquals("aFunc() : Foo", field.getParamStr());
  }

  public function testReferenceFuncOne()
  {
    var field = new Reference("aFunc", "some.Foo", true, false);
    field.addParam(new Reference("aParam", "some.Int"));
    assertEquals("- aFunc(aParam : some.Int) : some.Foo\\l", field.getFieldStr());
    assertEquals("aFunc(aParam : some.Int) : some.Foo", field.getParamStr());
  }

  public function testReferenceFuncTwo()
  {
    var field = new Reference("aFunc", "Foo", true, false);
    field.addParam(new Reference("aParam", "Int"));
    field.addParam(new Reference("anotherParam", "some.Boat"));
    assertEquals("- aFunc(aParam : Int, anotherParam : some.Boat) : Foo\\l", field.getFieldStr());
    assertEquals("aFunc(aParam : Int, anotherParam : some.Boat) : Foo", field.getParamStr());
  }
}