package umlgen.model;

/**
	superclass for all data types
 **/
interface ModelType
{
  public var path(default,null) : String;
  public var pkg(default,null) : String;
  public var type(default,null) : String;
  public function getDotStr() : String;
}
