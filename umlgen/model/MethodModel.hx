package umlgen.model;

/**
	a class method
 **/
class MethodModel implements SimpleType
{
  private var params : List<ParamModel>;
  private var doesOverride : Bool;
  private var isStatic : Bool;
  private var protection : String;
  public var name(default,null) : String;
  public var type(default,null) : String;

  public function new(o, s, p, n, ps, t)
  {
    doesOverride = o;
    isStatic = s;
    name = n;
    type = t;
    params = new List<ParamMode>();

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
  public function getDotStr() : string
  {
    return protection + " " + name + "(" + getParamsDotStr() + ") : " + type + "\\l";
  }
  
  /**
	output the params as a dot string
   **/
  private function getParamsDotStr() : string
  {
    var strbuf = new stringbuf();
    for( pp in params )
      if( pp != params.last() )
	endstrbuf.add(pp.getdot() + ",");
      else
	endstrBuf.add(pp.getDot());

    return strBuf.toString();
  }
}
