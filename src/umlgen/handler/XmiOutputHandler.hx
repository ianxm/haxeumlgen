/*
 * Copyright (c) 2011, Daniel Kuschny
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
import neko.io.Path;

import umlgen.HaxeUmlGen;
import umlgen.model.Package;
import umlgen.model.Reference;
import umlgen.model.ClassModel;
import umlgen.model.EnumModel;
import umlgen.model.TypedefModel;

/**
 * A handler which writes an xmi output file.
 */
class XmiOutputHandler implements IOutputHandler
{
    /**
     * The id for the xmi model
     */
	private static inline var MODEL_ID:String = "model:HaxeProject";
	
	/**
	 * a list containing the generic data types to be generated 
	 */
	private var globalGenerics:Hash<Dynamic>;
	
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
    public function run(packages:Hash<Package>, generator:HaxeUmlGen) : Void
    {
        var buf:StringBuf = new StringBuf();
        globalGenerics = new Hash<Dynamic>();
        
        // file start
        buf.add('<?xml version="1.0" encoding="UTF-8"?>');
        buf.add('<XMI xmi.version="1.1" xmlns:UML="org.omg.xmi.namespace.UML">');
        buf.add('<XMI.header><XMI.metamodel xmi.name="UML" xmi.version="1.4"/></XMI.header>');
        buf.add('<XMI.content>');
        
        // create a model for the packages
        buf.add('<UML:Model xmi.id="'+MODEL_ID+'" name="HaxeProject" isRoot="true" isLeaf="false" isAbstract="false">');
        
        
        buf.add('<UML:Namespace.ownedElement>');
        
        // create root packages
        for(pp in packages)
        {
        	writePackage(buf, pp, MODEL_ID, generator);
        }
        
        buf.add('</UML:Namespace.ownedElement>');
        buf.add('</UML:Model>');
        
        // generic datatypes
        for(generic in globalGenerics.keys())
        {
        	var id = "model:" + toId(generic);
        	buf.add('<UML:DataType xmi.id="'+id+'" name="'+generic+'" isRoot="false" isLeaf="false" isAbstract="false">');
        	buf.add('<UML:ModelElement.visibility xmi.value="private" />');
        	buf.add('</UML:DataType>');
        }
        
        
        // File End
        buf.add('</XMI.content>');
        buf.add('</XMI>');
        
        var xmiFname:String = Path.withoutExtension(generator.outDir + "/" + Path.withoutDirectory(generator.inFname)) + "-xmi.xml";
        var fout = neko.io.File.write( xmiFname, false );
        fout.writeString(buf.toString());
        fout.close();
        
        generator.log( "\nComplete." );
    }
    
    /**
     * Writes a package
     */
    private function writePackage(buf:StringBuf, pp:Package, namespace:String, generator:HaxeUmlGen)
    {
    	if(pp.name == "")
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
    	else
    	{
            var id = "package:" + toId(pp.fullName);
            buf.add('<UML:Package xmi.id="' + id + '" name="'+pp.name+'" isRoot="false" isLeaf="false" isAbstract="false">');
            buf.add('<UML:ModelElement.visibility xmi.value="public" />');
            buf.add('<UML:ModelElement.namespace>');
            buf.add('<UML:Namespace xmi.idref="'+namespace+'"/>');
            buf.add('</UML:ModelElement.namespace>');
        
            buf.add('<UML:Namespace.ownedElement>');
            // create types
            for(dd in pp.dataTypes)
            {
                if(Std.is(dd, ClassModel))
                {
                    var clz:ClassModel = cast(dd);
                    if(clz.isInterface)
                       writeInterface(buf, clz, id);
                    else
                       writeClass(buf, clz, id);
                }
                else if(Std.is(dd, EnumModel))
                {
                    var enm:EnumModel = cast(dd);
                    writeEnum(buf, enm, id); 
                } 
                else if(Std.is(dd, TypedefModel))
                {
                    var typ:TypedefModel = cast(dd);
                    writeTypedef(buf, typ, id);
                }
            }
            
            generator.log( "Generated Package: " + pp.fullName);
                
            // hierarchy
            for(subpkg in pp.subPackages)
            {
                writePackage(buf, subpkg, id, generator);
            }
            
            buf.add('</UML:Namespace.ownedElement>');
            buf.add('</UML:Package>');
        }   
    }
    
    /**
     * Converts the specified string into a valid xmi id.
     */
    private function toId(str:String)
    {
    	if(str == null) throw "null id";
    	return str.replace(".", "-");
    }
    
    /**
     * writes a class as an xmi string
     */
    private function writeClass(buf:StringBuf, clz:ClassModel, pkgId:String) 
    {
        buf.add('<UML:Class xmi.id="class:'+toId(clz.path)+'" name="'+clz.type+'" isSpecification="false" isRoot="false" isLeaf="false" isAbstract="false" isActive="false" namespace="' + pkgId + '">');
        buf.add('<UML:ModelElement.visibility xmi.value="public" />');
        // TODO: Generics
        
        buf.add('<UML:Classifier.feature>');
        writeFields(buf, clz);
        buf.add('</UML:Classifier.feature>');
        
        buf.add('</UML:Class>');  
        
         // write associations
        for(ref in clz.fields)
        {
            if(!ref.isFunc)
               writeAssociation(buf, ref, clz);
        }
          
        writeBaseTypes(buf, clz, pkgId);
    }
    
    /**
     * writes an interface as an xmi string
     */
    private function writeInterface(buf:StringBuf, clz:ClassModel, pkgId:String) 
    {
        buf.add('<UML:Interface xmi.id="class:'+toId(clz.path)+'" name="'+clz.type+'" isSpecification="false" isRoot="false" isLeaf="false" isAbstract="false" isActive="false" namespace="' + pkgId + '">');
        buf.add('<UML:ModelElement.visibility xmi.value="public" />');
        // TODO: Generics
        
        // mark as <<interface>>
        buf.add('<UML:ModelElement.stereoType>');
        buf.add('<UML:Stereotype name="interface" isRoot="false" isLeaf="false" isAbstract="false">');
        buf.add('<UML:Stereotype.baseClass>Interface</UML:Stereotype.baseClass>');
        buf.add('</UML:Stereotype>');
        buf.add('</UML:ModelElement.stereoType>');
        
        buf.add('<UML:Classifier.feature>');
        writeFields(buf, clz);
        buf.add('</UML:Classifier.feature>');
        
        buf.add('</UML:Interface>');    	
        
        writeBaseTypes(buf, clz, pkgId);
    }
    
    /**
     * write base types (generalization realization)
     */
    private function writeBaseTypes(buf:StringBuf, clz:ClassModel, pkgId:String) 
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
     * writes an interface implementation as xmi 
     */
    private function writeDependency(buf:StringBuf, parent:Reference, clz:ClassModel)
    {
    	var subClass = "class:" + toId(clz.path);
        var baseClass = "class:" + toId(parent.path);
        var id = "dependency:" + toId(clz.path) + toId(parent.path);
        
        // TODO: all uml tools handle interface implementations different. need to find a common technique
        buf.add('<UML:Dependency client="'+subClass+'" supplier="'+baseClass+'" xmi.id="'+id+'" visibility="public">');
        buf.add('<UML:ModelElement.stereotype>');
        buf.add('<UML:Stereotype name="realize" isRoot="false" isLeaf="false" isAbstract="false">');
        buf.add('</UML:Stereotype>');
        buf.add('</UML:ModelElement.stereotype>');
        buf.add('</UML:Dependency>');
    }
    
    /**
     * writes an baseclass extension as xmi 
     */
    private function writeGeneralization(buf:StringBuf, parent:Reference, clz:ClassModel)
    {
    	var subClass = "class:" + toId(clz.path);
    	var baseClass = "class:" + toId(parent.path);
    	var id = "generalization:" + toId(clz.path);
    	
    	buf.add('<UML:Generalization subtype="'+subClass+'" supertype="'+baseClass+'" xmi.id="'+id+'" visibility="public">');
        buf.add('</UML:Generalization>');
    }
    
    /**
     * writes the class fields as an xmi string
     */
    private function writeFields(buf:StringBuf, clz:ClassModel)
    {
        for(ref in clz.fields)
        {
        	if(!ref.isFunc)
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
    	var ownerScope = ref.isStatic ? "classifier" : "instance";
    	buf.add('<UML:Operation name="'+ref.name+'" ownerScope="'+ownerScope+'" isQuery="true" concurrenty="sequential" isRoot="false" isLeaf="false" isAbstract="false">');
            buf.add('<UML:ModelElement.namespace>');
                buf.add('<UML:Namespace xmi.idref="class:'+toId(clz.path)+'" />');
            buf.add('</UML:ModelElement.namespace>');
            
            var visibility = ref.protection == '+' ? "public" : "private"; 
            buf.add('<UML:ModelElement.visibility xmi.value="'+visibility+'" />');
        
            buf.add('<UML:Feature.owner>');
                buf.add('<UML:Classifier xmi.idref="class:'+toId(clz.path)+'"/>');
            buf.add('</UML:Feature.owner>');
            buf.add('<UML:Feature.visibility xmi.value="'+visibility+'"/>');

            buf.add('<UML:BehavioralFeature.parameter>');
 
                // return type
                var ret = ref.path == null ? "Void" : ref.path;
                buf.add('<UML:Parameter name="" kind="return">');
                    buf.add('<UML:ModelElement.namespace>');
                        buf.add('<UML:Namespace xmi.idref="class:'+toId(clz.path)+'"/>');
                    buf.add('</UML:ModelElement.namespace>');
                    buf.add('<UML:ModelElement.visibility xmi.value="public"/>');
                    buf.add('<UML:Parameter.behavioralFeature>');
                        buf.add('<UML:BehavioralFeature xmi.idref="class:'+toId(clz.path)+'"/>');
                     buf.add('</UML:Parameter.behavioralFeature>');
                    buf.add('<UML:Parameter.type>');
                        buf.add('<UML:Classifier xmi.idref="class:'+toId(ret)+'"/>');
                    buf.add('</UML:Parameter.type>');
                buf.add('</UML:Parameter>');
        
        // parameters
        for(param in ref.params) 
        {
            buf.add('<UML:Parameter name="'+param.name+'" kind="in">');
                buf.add('<UML:ModelElement.namespace>');
                    buf.add('<UML:Namespace xmi.idref="class:'+toId(clz.path)+'"/>');
                buf.add('</UML:ModelElement.namespace>');
                buf.add('<UML:ModelElement.visibility xmi.value="public"/>');
                buf.add('<UML:Parameter.behavioralFeature>');
                    buf.add('<UML:BehavioralFeature xmi.idref="class:'+toId(clz.path)+'"/>');
                buf.add('</UML:Parameter.behavioralFeature>');
                buf.add('<UML:Parameter.type>');
                    buf.add('<UML:Classifier xmi.idref="class:'+toId(param.path)+'"/>');
                buf.add('</UML:Parameter.type>');
            buf.add('</UML:Parameter>');
        }
        
        // TODO: register type arguments as global data types and reference them
        
        buf.add('</UML:BehavioralFeature.parameter>');

        
        buf.add('</UML:Operation>');
    }
    
    /**
     * writes the specified reference as an attribute xmi string. 
     */
    private function writeAttribute(buf:StringBuf, ref:Reference, clz:ClassModel)
    {
    	var ownerScope = ref.isStatic ? "classifier" : "instance";
        var visibility = ref.protection == '+' ? "public" : "private"; 
        
        var ret = ref.path == null ? "Void" : ref.path;
        
        if(ref.tParams.length == 0)
        {
        	ret = "class:" + ret;
        }
        else
        {
        	// build generic datatype
        	ret += "&lt;";
        	
        	for(tparam in ref.tParams)
        	{
        		ret += tparam.path;
        		
        		if(tparam != ref.tParams.last())
        		{
        			ret += ",";
        		}
        	}
        	ret += "&gt;";
        	globalGenerics.set(ret, 1);
            ret = "model:" + ret;
        }
        
    	buf.add('<UML:Attribute name="'+ref.name+'" ownerScope="'+ownerScope+'" targetScope="instance" changeability="changeable" aggregation="composite" namespace="class:'+toId(clz.type)+'">');
        buf.add('<UML:ModelElement.visibility xmi.value="'+visibility+'" />');
        buf.add('<UML:StructuralFeature.type>');
        buf.add('<UML:Classifier xmi.idref="'+toId(ret)+'"/>');
        buf.add('</UML:StructuralFeature.type>');
        buf.add('</UML:Attribute>');
    }
    
    /**
     * writes an association as an xmi string
     */
    private function writeAssociation(buf:StringBuf, ref:Reference, clz:ClassModel)
    {
    	var visibility = ref.protection == '+' ? "public" : "private"; 
    	
    	var assocId = "assoc:" + toId(clz.path + '-' + ref.name);
    	buf.add('<UML:Association xmi.id="'+assocId+'" visibility="public" isRoot="false" isLeaf="false" isAbstract="false">');
    	buf.add('<UML:Association.connection>');
    	
    	// navigation source role (the end on the target class)
    	var targetType:String = "";
    	var multiplicity = "";
    	// target generic type on lists
    	if(ref.path == "Array" || ref.path == "List")
    	{
    		targetType = ref.tParams.first().path;
    		multiplicity = '0..*';
    	}
    	else
    	{
    		targetType = ref.path;
    		multiplicity = '1';
    	}
    	
    	buf.add('<UML:AssociationEnd visibility="'+visibility+'" aggregation="none" isOrdered="false" targetScope="instance" changeable="none" isNavigable="false" type="class:'+toId(clz.path)+'">');
        buf.add('</UML:AssociationEnd>');
        
        buf.add('<UML:AssociationEnd visibility="private" multiplicity="'+multiplicity+'" name="'+ref.name+'" aggregation="none" isOrdered="false" targetScope="instance" changeable="none" isNavigable="true" type="class:'+toId(targetType)+'">');
        buf.add('</UML:AssociationEnd>');
    	
    	buf.add('</UML:Association.connection>');
    	buf.add('</UML:Association>');
    }
    
    /**
     * Writes an enum into a xmi file
     */
    private function writeEnum(buf:StringBuf, enm:EnumModel, pkgId:String) 
    {
        buf.add('<UML:Class xmi.id="class:'+toId(enm.path)+'" name="'+enm.type+'" isSpecification="false" isRoot="false" isLeaf="false" isAbstract="false" isActive="false" namespace="' + pkgId + '">');
        buf.add('<UML:ModelElement.visibility xmi.value="public" />');
        // mark as <<enumeration>>
        buf.add('<UML:ModelElement.stereoType>');
            buf.add('<UML:Stereotype name="enumeration" isRoot="false" isLeaf="false" isAbstract="false">');
                buf.add('<UML:Stereotype.baseClass>Class</UML:Stereotype.baseClass>');
            buf.add('</UML:Stereotype>');
        buf.add('</UML:ModelElement.stereoType>');
        
        buf.add('<UML:Classifier.feature>');
        for(val in enm.fields)
        {
            buf.add('<UML:Attribute name="'+val+'" ownerScope="classifier" targetScope="instance" changeability="frozen" aggregation="composite" namespace="class:'+toId(enm.path)+'">');
            buf.add('<UML:ModelElement.visibility xmi.value="public" />');
            // mark as <<enum constant>>
            /*buf.add('<UML:ModelElement.stereotype>');
                buf.add('<UML:Stereotype name="enum+constant" isRoot="false" isLeaf="false" isAbstract="false">');
                    buf.add('<UML:Stereotype.baseClass>Attribute</UML:Stereotype.baseClass>');
                buf.add('</UML:Stereotype>');
            buf.add('</UML:ModelElement.stereotype>');*/
            
            buf.add('</UML:Attribute>');
        }
       
        buf.add('</UML:Classifier.feature>');
        
        buf.add('</UML:Class>');        
    }
    
    private function writeTypedef(buf:StringBuf, typ:TypedefModel, pkgId:String) 
    {
        buf.add('<UML:Class xmi.id="class:'+typ.type+'" name="'+typ.type+'" isSpecification="false" isRoot="true" isLeaf="true" isAbstract="true" isActive="false" namespace="package:' + pkgId + '">');
            buf.add('<UML:ModelElement.visibility xmi.value="public" />');
            buf.add('<UML:ModelElement.stereoType>');
                buf.add('<UML:Stereotype xmi.idref="'+pkgId+':typedef" />');
            buf.add('</UML:ModelElement.stereoType>');
        
        // TODO: how to render the definition of the typedef?
        
        buf.add('</UML:Class>');        
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
