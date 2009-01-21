package umlgen.model;

/**
	a method parameter
 **/
class ParamModel implements SimpleType
{
  public var name(default,null) : String;
  public var type(default,null) : String;

  public function new(n, t)
  {
    name = n;
    type = t;
  }

  public function getDotStr() : String
  {
    return name + " : " + type;
  }
}