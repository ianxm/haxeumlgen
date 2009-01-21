package umlgen.model;

/**
	superclass for types that don't contain any fields
 **/
interface SimpleType implements ModelType
{
  public var name(default,null) : String;
  public var type(default,null) : String;
}

