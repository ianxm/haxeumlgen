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

import umlgen.model.Package;

/**
 * This is the base interface for implementing output generation handlers.
 * Also add this method to all handlers:
 * 
 * public static function printHelp() : Void;
 * public static function getDescription() : String;
 */
interface IOutputHandler 
{
	/**
	 * Called before any reading or writing happened to check whether all requirements are available.
	 * @param generator the generator containing the loaded settings
	 */
    public function checkRequirements(generator:HaxeUmlGen) : Void;
    
    /**
     * Tells the output handler to start the generation of the output.
     * @param generator the generator containing the loaded settings
     * @param packages a map containing all packages which contains the datatypes 
     */
    public function run(packages:Hash<Package>, generator:HaxeUmlGen) : Void;
    
    /**
     * Processes the specified argument
     * @param arg the argument contianing containing the setting to process
     * @param args the iterator containing the arguments (for accessing next args)
     * @param generator the generator containing the settings
     * @return true if the handler could process the arg, otherwise false
     */
    public function processArg(arg:String, args:Iterator<String>, generator:HaxeUmlGen) : Bool;
    
    ///**
    // * Prints the help for this handler.
    // */
    //public static function printHelp() : Void;
    
    ///**
    // * Gets the description of this handler
    // */
    //public static function getDescription() : String;
}
