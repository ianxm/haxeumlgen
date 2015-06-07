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
package umlgen.handler;

using StringTools;
import haxe.io.Path;

import umlgen.HaxeUmlGen;
import umlgen.model.Package;
import umlgen.model.Reference;
import umlgen.model.ClassModel;
import umlgen.model.EnumModel;
import umlgen.model.TypedefModel;

/**
 * A handler which writes an xmi output file.
 */
class Xmi2OutputHandler implements IOutputHandler
{
    /**
     * The id for the xmi model
     */
    private static inline var MODEL_ID:String = "model:HaxeProject";

    /**
     * a list containing the generic data types to be generated
     */
    private var globalGenerics:Map<String, Dynamic>;

    /**
     * Initializes a new instance of the XmiOutputHandler class.
     */
    public function new()
    {
    }


    /**
     * Called before any reading or writing happened to check whether all requirements are available.
     * @param generator the generator containing the loaded settings
     */
    public function checkRequirements(generator:HaxeUmlGen) : Void
    {
        // no requirements
    }

    /**
     * Tells the output handler to start the generation of the output.
     * @param generator the generator containing the loaded settings and the logger
     * @param packages a map containing all packages which contains the datatypes
     */
    public function run(packages:Map<String, Package>, generator:HaxeUmlGen) : Void
    {
        this.globalGenerics = new Map<String, Dynamic>();
        this.globalGenerics.set("Float", "Float");
        this.globalGenerics.set("Int", "Int");
        this.globalGenerics.set("Boolean", "Boolean");
        this.globalGenerics.set("Bool", "Bool");

        // -------------------- //

        var buf:StringBuf = new StringBuf();

        // file start
        buf.add('<?xml version="1.0" encoding="UTF-8"?>');
        buf.add('<xmi:XMI xmi:version="2.1" xmlns:uml="http://schema.omg.org/spec/UML/2.1" xmlns:xmi="http://schema.omg.org/spec/XMI/2.1">');
        buf.add('<xmi:Documentation exporter="HaxeUmlGen" exporterVersion="' + HaxeUmlGen.VERSION + '"/>');
        // buf.add('<xmi:Documentation exporter="Enterprise Architect" exporterVersion="6.5"/>');
        buf.add('<uml:Model xmi:type="uml:Model" name="' + MODEL_ID + '" visibility="public">');
        // buf.add('<uml:Model xmi:type="uml:Model" name="EA_Model" visibility="public">');
        buf.add('<packagedElement xmi:type="uml:Package" xmi:id="' + "HaxeSource" + '" name="' + "HaxeSource" + '" visibility="public">');

        // create root packages
        for(pp in packages)
        {
            writePackage(buf, pp, MODEL_ID, generator);
        }

        for(generic in globalGenerics.keys())
        {
            buf.add('<packagedElement xmi:type="uml:Class" xmi:id="' + generic + '" name="' + globalGenerics.get(generic) + '" visibility="public">');
            buf.add('</packagedElement>');
        }

        buf.add('</packagedElement>');
        buf.add('</uml:Model>');

        // File End
        buf.add('</xmi:XMI>');

        var xmiFname:String = Path.withoutExtension(generator.outDir + "/" + Path.withoutDirectory(generator.inFname)) + "-xmi.xml";
        var fout = sys.io.File.write( xmiFname, false );
        fout.writeString(buf.toString());
        fout.close();

        // trace( "\nComplete." );
    }

    /**
     * Writes a package
     */
    private function writePackage(buf:StringBuf, pp:Package, namespace:String, generator:HaxeUmlGen)
    {
        // trace("package: " + namespace + " " + pp.name );

        if(pp.name == "")
        {
            this.createTypes(buf, pp, namespace, generator);
        }
        else
        {
            var id = toId(pp.fullName);

            buf.add('<packagedElement xmi:type="uml:Package" xmi:id="' + id + '" name="' + pp.name + '" visibility="public">');

            this.createTypes(buf, pp, namespace, generator);

            // hierarchy
            for(subpkg in pp.subPackages)
            {
                writePackage(buf, subpkg, id, generator);
            }

            buf.add('</packagedElement>');
        }
    }

    /**
     *
     * @param   buf
     * @param   pp
     * @param   namespace
     * @param   generator
     */
    private function createTypes(buf:StringBuf, pp:Package, namespace:String, generator:HaxeUmlGen)
    {
        // create types
        for(dd in pp.dataTypes)
        {
            if(Std.is(dd, ClassModel))
            {
                var clz:ClassModel = cast(dd);
                if(clz.isInterface)
                    writeInterface(buf, clz, namespace);
                else
                    writeClass(buf, clz, namespace);
            }
            else if(Std.is(dd, EnumModel))
            {
                var enm:EnumModel = cast(dd);
                writeEnum(buf, enm, namespace);
            }
            else if(Std.is(dd, TypedefModel))
            {
                var typ:TypedefModel = cast(dd);
                writeTypedef(buf, typ, namespace);
            }
        }
    }

    /**
     *
     * @param   ref
     */
    private function buildGeneric( ref:Reference )
    {
        var ret = ref.path == null ? "Void" : ref.path;
        var name = ret.split(".").pop();

        if(ref.tParams.length != 0) // build generic datatype
        {
            ret += "&lt;";
            name += "&lt;";

            for(tparam in ref.tParams)
            {
                ret += tparam.path;
                name += tparam.path.split(".").pop();

                if(tparam != ref.tParams.last())
                {
                    ret += ",";
                    name += ",";
                }
            }

            ret += "&gt;";
            name += "&gt;";

            ret = toId( ret );

            globalGenerics.set(ret, name);
        }

        return ret;
    }

    /**
     * Converts the specified string into a valid xmi id.
     */
    private function toId(str:String, ?param:Reference )
    {
        if(str == null)
        {
            // trace("null id: " + param + " most likely unsupported type (e.g. Void->Void): using Void instead" );
            str = "Void"; // throw "null id";
        }

        return str.replace(".", "-");
    }

    /**
     * writes a class as an xmi string
     */
    private function writeClass(buf:StringBuf, clz:ClassModel, pkgId:String)
    {
        var id = toId(clz.path);

        buf.add('<packagedElement xmi:type="uml:Class" xmi:id="' + id + '" name="' + clz.type + '" visibility="public">');

        writeFields(buf, clz);
        writeExtends(buf, clz, pkgId);

        buf.add('</packagedElement>');

        // write associations
        for(ref in clz.fields)
        {
            if(!ref.isFunc)
                writeAssociation(buf, ref, clz);
        }

        writeImplements(buf, clz, pkgId);
    }

    /**
     * writes an interface as an xmi string
     */
    private function writeInterface(buf:StringBuf, clz:ClassModel, pkgId:String)
    {
        var id = toId(clz.path);

        buf.add('<packagedElement xmi:type="uml:Interface" xmi:id="' + id + '" name="' + clz.type + '" visibility="public" isAbstract="true">');

        writeFields(buf, clz);
        writeExtends(buf, clz, pkgId);

        buf.add('</packagedElement>');

        // write associations
        for(ref in clz.fields)
        {
            if(!ref.isFunc)
                writeAssociation(buf, ref, clz);
        }

        writeImplements(buf, clz, pkgId);
    }

    /**
     * write base types (generalization realization)
     */
    private function writeImplements(buf:StringBuf, clz:ClassModel, pkgId:String)
    {
        for(parent in clz.parents)
        {
            if(parent.name == "implements")
            {
                writeDependency(buf, parent, clz);
            }
            else if(parent.name == "extends")
            {
                writeGeneralization(buf, parent, clz);
            }
        }
    }

    /**
     * write base types (generalization realization)
     */
    private function writeExtends(buf:StringBuf, clz:ClassModel, pkgId:String)
    {
        for(parent in clz.parents)
        {
            if(parent.name == "extends")
            {
                writeGeneralization(buf, parent, clz);
            }
        }
    }

    /**
     * writes an interface implementation as xmi
     */
    private function writeDependency(buf:StringBuf, parent:Reference, clz:ClassModel)
    {
        var client = toId(clz.path);
        var supplier = toId(parent.path);
        var id = toId(clz.path) + toId(parent.path);

        buf.add('<packagedElement xmi:type="uml:Realization" xmi:id="' + id + '" visibility="public" supplier="' + supplier + '" client="' + client + '"/>');
    }

    /**
     * writes an baseclass extension as xmi
     */
    private function writeGeneralization(buf:StringBuf, parent:Reference, clz:ClassModel)
    {
        var client = toId(clz.path);
        var supplier = toId(parent.path);
        var id = toId(clz.path) + toId(parent.path);

        buf.add('<generalization xmi:type="uml:Generalization" xmi:id="' + id + '" general="' + supplier + '"/>');
    }

    /**
     * writes the class fields as an xmi string
     */
    private function writeFields(buf:StringBuf, clz:ClassModel)
    {
        for(ref in clz.fields)
        {
            var isAccessor:Bool = ref.valueGet == "accessor";

            if(!ref.isFunc || isAccessor)
                writeAttribute(buf, ref, clz);
            else
                writeMethod(buf, ref, clz);
        }

    }


    /**
     * writes the specified reference as a method xmi string
     */
    private function writeMethod(buf:StringBuf, ref:Reference, clz:ClassModel)
    {
        var id = toId(clz.path) + "-" + ref.name;
        var name = ref.name;
        var visibility = ref.protection == '+' ? "public" : "private";
        var isStatic = ref.isStatic;

        var ret = toId( this.buildGeneric( ref ) );
        var type = ret;
        var idReturn = id + "-return";

        buf.add('<ownedOperation xmi:id="' + id + '" name="' + name + '" visibility="' + visibility + '" type="' + type + '" isStatic="' + isStatic + '">');

        for(param in ref.params)
        {
            var idParam = id + "-" + param.name;
            var nameParam = param.name;
            var typeParam = toId( this.buildGeneric( param ) );
            var defVal = param.defaultValue;

            buf.add('<ownedParameter xmi:id="' + idParam + '" name="' + nameParam + '" direction="in" isStream="false" isException="false" isOrdered="true" isUnique="true" type="' + typeParam + '">');

            if( defVal != null)
                buf.add('<defaultValue xmi:type="uml:LiteralString" xmi:id="' + idParam + "-default-value" + '" value="' + defVal + '"/>');

            buf.add('</ownedParameter>');
        }

        buf.add('<ownedParameter xmi:id="' + idReturn + '" name="return" direction="return" type="' + toId(ret) + '"/>');
        buf.add('</ownedOperation>');
    }

    /**
     * writes the specified reference as an attribute xmi string.
     */
    private function writeAttribute(buf:StringBuf, ref:Reference, clz:ClassModel)
    {
        var id = toId(clz.path) + "-" + ref.name;
        var name = ref.name;
        var visibility = ref.protection == '+' ? "public" : "private";

        var isStatic = ref.isStatic;
        var isDerived = false;
        var isReadOnly = false;
        var typeID = toId( this.buildGeneric( ref ) );

        if( ref.valueGet == "accessor" && ref.valueSet != "accessor" )
            isReadOnly = true;

        buf.add('<ownedAttribute xmi:type="uml:Property" xmi:id="' + id + '" name="' + name + '" visibility="' + visibility + '" isStatic="' + isStatic + '" isReadOnly="' + isReadOnly + '" isDerived="' + isDerived + '" isOrdered="false" isUnique="true" isDerivedUnion="false">');
        buf.add('<type xmi:idref="' + typeID + '"/>');
        buf.add('</ownedAttribute>');
    }

    /**
     * writes an association as an xmi string
     */
    private function writeAssociation(buf:StringBuf, ref:Reference, clz:ClassModel)
    {
        var assoID = toId(clz.path + '-' + ref.name) + "-asso";
        var assoName = ref.name;
        var mID = assoID + "-member";
        var tID = "";

        if( ref.tParams != null && ref.tParams.length != 0 && (ref.name == "Array" || ref.name == "List" || ref.name == "Vector") )
        {
            tID = ref.tParams.first().path;
        }
        else
        {
            tID = ref.path;
        }

        buf.add('<packagedElement xmi:type="uml:Association" xmi:id="' + assoID + '" visibility="public">');

        buf.add('<memberEnd xmi:idref="' + mID + '"/>');
        buf.add('<ownedEnd xmi:type="uml:Property" xmi:id="' + mID + '" name="' + assoName + '" visibility="public" association="' + assoID + '" isStatic="false" isReadOnly="true" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false" aggregation="none">');
        buf.add('<type xmi:idref="' + tID + '"/>');
        buf.add('</ownedEnd>');

        buf.add('</packagedElement>');
    }

    /**
     * Writes an enum into a xmi file
     */
    private function writeEnum(buf:StringBuf, enm:EnumModel, pkgId:String)
    {
        var id = toId(enm.path);
        var name = enm.type;

        buf.add('<packagedElement xmi:type="uml:Enumeration" xmi:id="' + id + '" name="' + name + '" visibility="public">');

        for(val in enm.fields)
        {
            if( val == "meta" )
                continue;

            var eID = toId(id + "-" + val);
            var eName = val;

            buf.add('<ownedLiteral xmi:type="uml:EnumerationLiteral" xmi:id="' + eID + '" name="' + eName + '" visibility="public" classifier="Int"/>');
        }

        buf.add('</packagedElement>');
    }

    private function writeTypedef(buf:StringBuf, typ:TypedefModel, pkgId:String)
    {
        //buf.add('<UML:Class xmi.id="class:'+typ.type+'" name="'+typ.type+'" isSpecification="false" isRoot="true" isLeaf="true" isAbstract="true" isActive="false" namespace="package:' + pkgId + '">');
        //buf.add('<UML:ModelElement.visibility xmi.value="public" />');
        //buf.add('<UML:ModelElement.stereoType>');
        //buf.add('<UML:Stereotype xmi.idref="'+pkgId+':typedef" />');
        //buf.add('</UML:ModelElement.stereoType>');
        //
        //// TODO: how to render the definition of the typedef?
        //
        //buf.add('</UML:Class>');
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
        // no additional args
        return false;
    }

    /**
     * Prints the help for this handler.
     */
    public static function printHelp() : Void
    {
        // no args - no help
    }

    /**
     * Gets the description of this handler
     */
    public static function getDescription() : String
    {
        return "writes an XMI project file";
    }

    /**
     * Gets the mode how packages should get organized.
     */
    public function getPackageMode() : OutputPackageMode
    {
        return OutputPackageMode.Hierarchical;
    }
}
