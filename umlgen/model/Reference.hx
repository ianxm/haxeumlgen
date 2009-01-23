package umlgen.model;

class Reference
{
  /** package and type, for functions this is the return type **/
  public var path(default,default) : String;

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
	@param p path
	@param f if true, function
	@param s if true, static
	@param pr protection
   **/
  public function new(n, p, ?f=false, ?pr=false, ?s=false)
  {
    name = n;
    path = p;
    isFunc = f;
    protection = (pr) ? "+" : "-";
    isStatic = s;
    params = (isFunc) ? new List<Reference>() : null;
  }

  /**	add a param	**/
  inline public function addParam(r)
  {	params.add(r);  }

  /**
	output this type as a function parameter
   **/
  public function getParamStr() : String
  {
    return name + getFuncParams() + " : " + path;
  }

  /**
	output this type as a class field
   **/
  public function getFieldStr() : String
  {
    return protection + " " + name + getFuncParams() + " : " + path + "\\l";
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