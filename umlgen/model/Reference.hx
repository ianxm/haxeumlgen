package umlgen.model;

class Reference
{
  /** package and type, for functions this is the return type **/
  private var type : String;

  /** variable name **/
  private var name : String;

  /** true if variable is static **/
  private var isStatic : Bool;

  /** public or private, stored as symbol **/
  private var protection : String;

  /** return true if this references a function **/
  public var isFunc(default,null):Bool;

  /** list of params if this is a function **/
  private var params : List<Reference>;

  /**
	constructor
	@param n name
	@param t type
	@param f if true, function
	@param s if true, static
	@param p protection
   **/
  public function new(n, t, ?f=false, ?s, ?p)
  {
    name = n;
    type = t;
    isStatic = s;

    protection =
      switch (p)
      {
      case "private": "-";
      case "public": "+";
      default: "?";
      }

    isFunc = f;
    params = (isFunc) ? new List<Reference>() : null;
  }

  /**	add a param	**/
  inline public function addParam(r)
  {    params.add(r);  }

  /**
	output this type as a function parameter
   **/
  public function getParamStr() : String
  {
    return name + getFuncParams() + " : " + type;
  }

  /**
	output this type as a class field
   **/
  public function getFieldStr() : String
  {
    return protection + " " + name + getFuncParams() + " : " + type + "\\l";
  }

  /**
	output the params as a dot string
   **/
  public function getFuncParams() : String
  {
    if (!isFunc) return "";

    var strBuf = new StringBuf();
    strBuf.add("(");
    for( pp in params )
      if( pp != params.last() )
	strBuf.add(pp.getParamStr() + ", ");
      else
	strBuf.add(pp.getParamStr());
    strBuf.add(")");

    return strBuf.toString();
  }
}