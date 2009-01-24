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
 * THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE HAXE PROJECT CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package umlgen.model;

class TestEnum extends haxe.unit.TestCase
{
  public function testEnumEmpty()
  {
    var testEnum = new EnumModel("the.pkg.AnEnum");
    assertEquals('\t "the.pkg.AnEnum" [ label = "{\\<enum\\>\\nAnEnum|}" ]\n', testEnum.getDotStr());
  }

  public function testEnumOne()
  {
    var testEnum = new EnumModel("the.pkg.AnEnum");
    testEnum.addField("field1");
    assertEquals('\t "the.pkg.AnEnum" [ label = "{\\<enum\\>\\nAnEnum|field1\\l}" ]\n', testEnum.getDotStr());
  }

  public function testEnumTwo()
  {
    var testEnum = new EnumModel("the.pkg.AnEnum");
    testEnum.addField("field1");
    testEnum.addField("field2");
    assertEquals('\t "the.pkg.AnEnum" [ label = "{\\<enum\\>\\nAnEnum|field1\\lfield2\\l}" ]\n', testEnum.getDotStr());
  }
}