package umlgen.model;

import umlgen.HaxeUmlGen;

class Reference
{
  /** package and type, for functions this is the return type **/
  public var path(default,default) : String;

  /** package **/
  public var pkg(default,null) : String;

  /** class name **/
  public var type(default,null) : String;

  /** variable name **/
  private var name : String;

  /** true if variable is static **/
  private var isStatic : Bool;

  /** public or private, stored as symbol **/
  private var protection : String;

  /** return true if this references a function **/
  public var isFunc(default,null):Bool;

  /** type parameter **/
  private var tParams : List<Reference>;

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
    var pathSep = Reference.separatePath(path);
    pkg = pathSep.pkg;
    type = pathSep.type;
    isFunc = f;
    protection = (pr) ? "+" : "-";
    isStatic = s;
    params = (isFunc) ? new List<Reference>() : null;
    tParams = new List<Reference>();
  }

  /**	add a param	**/
  inline public function addParam(r)
  {	params.add(r);  }

  /**	add a type param	**/
  inline public function addTParam(r)
  {	tParams.add(r);  }

  /**
	output this type as a function parameter
   **/
  public function getParamStr() : String
  {
    var type = (pkg == HaxeUmlGen.pkg) ? type : path;
    return name + getFuncParams() + " : " + type + getTParamsStr();
  }

  /**
	output this type as a class field
   **/
  public function getFieldStr() : String
  {
    var type = (pkg == HaxeUmlGen.pkg) ? type : path;
    return protection + " " + name + getFuncParams() + " : " + type + getTParamsStr() + "\\l";
  }

  /**
	get type params for field str
   **/
  private function getTParamsStr() : String
  {
    if( tParams.isEmpty() )
      return "";
    var strBuf = new StringBuf();
    strBuf.add("\\<");
    for( pp in tParams )
    {
      var type = (pp.pkg == HaxeUmlGen.pkg) ? pp.type : pp.path;
      strBuf.add(type);
      if( pp != tParams.last())
	strBuf.add(", ");
    }
    strBuf.add("\\>");
    return strBuf.toString();
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

  /**
	@return true if this reference is in any way in the given package
   **/
  public function inPkg(p:String) : List<Reference>
  {
    var ret = new List<Reference>();

    // check type params
    for( pp in tParams )
      for( pp2 in pp.inPkg(p) )
	ret.add(pp2);

    // check me
    if( p == pkg )
      ret.add(this);

    return ret;
  }

  /**
	separate the package from the type name
   **/
  public static function separatePath(path:String)
  {
    if( path==null )
    return {pkg: null, type: null};
    var sep = path.lastIndexOf(".");
    var pkg  = (sep==-1) ? "" : path.substr(0, sep);
    var type = (sep==-1) ? path : path.substr(sep+1, path.length-sep-1);
    return {pkg: pkg, type: type};
  }
}