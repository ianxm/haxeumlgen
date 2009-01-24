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

package umlgen;

import umlgen.model.ModelType;
import umlgen.model.ClassModel;
import umlgen.model.TypedefModel;
import umlgen.model.EnumModel;
import umlgen.model.Reference;

class InputHandler
{
  public function new()
  { }

  public function readXml(fname)
  {
    var dataTypes = new List<ModelType>();
    var fData = neko.io.File.getContent(fname);
    var xmlData = Xml.parse(fData).firstElement();
    for( nn in xmlData.elements() )
    {
      var builder : Xml -> ModelType = null;
      switch( nn.nodeName )
      {
      case "enum": builder = buildEnum;
      case "typedef": builder = buildTypedef;
      case "class": builder = buildClass;
      default: continue; // unknown type
      }

      var ret = builder(nn);
      if( ret != null )
	dataTypes.add(ret);

      //neko.Lib.println("element: " + nn.nodeName + " " + nn.get("path"));
    }
    return dataTypes;
  }

  private function buildEnum(xmlNode:Xml)
  {
    var path = xmlNode.get("path");
    var e = new EnumModel(path);
    for( ee in xmlNode.elements() )
      if( ee.nodeName != "haxe_doc" )
	e.addField(ee.nodeName);

    //trace("enum: " + Std.string(e));
    return e;
  }

  private function buildTypedef(xmlNode:Xml)
  {
    // this is to skip some basic typedefs that are formatted strangely
    if( !xmlNode.elementsNamed("a").hasNext() )
      return null;

    var path = xmlNode.get("path");
    var ret = new TypedefModel(path);
    for( ee in xmlNode.elementsNamed("a").next().elements() )
      if( ee.nodeName != "haxe_doc" )
	ret.addField(buildReference(ee.elements().next(), ee.nodeName, true, false));

    //trace("typedef: " + Std.string(ret));
    return ret;
  }

 private function buildClass(xmlNode:Xml)
  {
    var path = xmlNode.get("path");
    var isInterface = xmlNode.exists("interface") && xmlNode.get("interface")=="1";
    var ret = new ClassModel(path, isInterface);
    for( ee in xmlNode.elements() )
    {
      if( ee.nodeName == "implements" )
	ret.addParent(new Reference("implements", ee.get("path")));

      else if( ee.nodeName == "extends" )
	ret.addParent(new Reference("extends", ee.get("path")));

      else if( ee.nodeName == "haxe_doc" )
	continue;

      else
      {
	var isPublic = ee.exists("public") && ee.get("public")=="1";
	var isStatic = ee.exists("static") && ee.get("static")=="1";
	ret.addField(buildReference(ee.elements().next(), ee.nodeName, isPublic, isStatic));
      }
    }

    //trace("class: " + Std.string(ret));
    return ret;
  }

  /**
	this creates a reference
   **/
  private function buildReference(node:Xml, name, isPublic, isStatic)
  {
    switch( node.nodeName )
    {
    case "e": return new Reference(name, node.get("path"), false, isPublic, isStatic);
    case "t": return new Reference(name, node.get("path"), false, isPublic, isStatic);
    case "c": return buildClassRef(node, name, isPublic, isStatic);
    case "d": return new Reference(name, "Dynamic", false, isPublic, isStatic);
    case "a": return new Reference(name, "Anonymous", false, isPublic, isStatic);
    case "unknown": return new Reference(name, "Unknown", false, isPublic, isStatic);
    case "f": return buildFuncRef(node, name, isPublic, isStatic);
    }
    return null;
  }

  /**
	this builds a class reference, adds type params if there are any
   **/
  private function buildClassRef(node:Xml, name, isPublic, isStatic)
  {
    var ret = new Reference(name, node.get("path"), false, isPublic, isStatic);
    for( ee in node.elements() )
      ret.addTParam(buildReference(ee, "param", false, false));
    return ret;
  }

  /**
	this builds a function reference, filling in the params
   **/
  private function buildFuncRef(node:Xml, name, isPublic, isStatic)
  {
    var ref = new Reference(name, null, true, isPublic, isStatic);
    var pnames = node.get("a").split(":").iterator();
    var params = node.elements();
    while( pnames.hasNext() )
    {
      var pname = pnames.next();
      if( pname=="" ) break;
      ref.addParam(buildReference(params.next(), pname, false, false));
    }
    ref.path = params.next().get("path"); // set return type
    return ref;
  }
}