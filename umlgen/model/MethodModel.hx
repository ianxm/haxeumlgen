package umlgen.model;

/**
	a class method
 **/
class MethodModel implements SimpleType
{
  private var params : List<ParamModel>;
  private var isStatic : Bool;
  private var protection : String;
  public var doesOverride(default,null) : Bool;
  public var name(default,null) : String;
  public var type(default,null) : String;

  public function new(o, s, p, n, t)
  {
    doesOverride = o;
    isStatic = s;
    name = n;
    type = t;
    params = new List<ParamModel>();

    protection =
      switch (p)
      {
      case "private": "-";
      case "public": "+";
      default: "?";
      }
  }

  /**
	add a param to this method
   **/
  public function addParam(p)
  {
    params.add(p);
  }

  /**
	output this type as a dot string
   **/
  public function getDotStr() : String
  {
    return protection + " " + name + "(" + getParamsDotStr() + ") : " + type + "\\l";
  }
  
  /**
	output the params as a dot string
   **/
  private function getParamsDotStr() : String
  {
    var strBuf = new StringBuf();
    for( pp in params )
      if( pp != params.last() )
	strBuf.add(pp.getDotStr() + ", ");
      else
	strBuf.add(pp.getDotStr());

    return strBuf.toString();
  }
}
