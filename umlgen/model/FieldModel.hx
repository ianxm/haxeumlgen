package umlgen.model;

/**
	the field of a class or enum
 **/
class FieldModel implements SimpleType
{
  private var isStatic : Bool;
  private var protection : String;
  public var name(default,null) : String;
  public var type(default,null) : String;

  /**
	constructor
   **/
  public function new(s, p, n, t)
  {
    isStatic = s;
    name = n;
    type = t;
    protection =
      switch (p)
      {
      case "private": "-";
      case "public": "+";
      default: "?";
      }
  }

  /**
	output this type as a dot string
   **/
  public function getDotStr() : String
  {
    return protection + " " + name + " : " + type + "\\l";
  }
}
