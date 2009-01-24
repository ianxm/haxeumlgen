package umlgen.model;

import umlgen.HaxeUmlGen;

/**
	a class
 **/
class ClassModel implements ModelType
{
  /** package and class name **/
  public var path(default,null) : String;

  /** package **/
  public var pkg(default,null) : String;

  /** class name **/
  public var type(default,null) : String;

  /** if true, this is an interface **/
  private var isInterface : Bool;

  /** this contains fields and methods **/
  private var fields : List<Reference>;

  /** this is a list of super classes **/
  private var parents : List<Reference>;

  public function new(p, i)
  {
    path = p;
    var pathSep = Reference.separatePath(path);
    pkg = pathSep.pkg;
    type = pathSep.type;
    isInterface = i;
    fields = new List<Reference>();
    parents = new List<Reference>();
  }

  /**	add a super class   **/
  public function addParent(p)
  {
    parents.add(p);
  }

  /**	add a field   **/
  public function addField(f)
  {
    fields.add(f);
  }

  /**
	output the class in dot format.  this also connects it to others
   **/
  public function getDotStr() : String
  {
    var strBuf = new StringBuf();
    var topBox = (isInterface) ? '\\<interface\\>\\n' + type : type;
    strBuf.add('\t "' + path + '" [ label = "{' + topBox + '|' + getFieldsDotStr() + '|' + getMethodsDotStr() + '}" ]\n');
    if( !parents.isEmpty() )
    {
      strBuf.add('\t  edge [ arrowhead = "empty" ]\n');
      for( pp in parents )
	strBuf.add('\t  "' + path + '" -> "' + pp.path + '"\n');
    }

    var assoc = findAssociations();
    if( !assoc.isEmpty() )
    {
      strBuf.add('\t  edge [ arrowhead = "none" ]\n');
      for( aa in assoc )
	strBuf.add('\t  "' + path + '" -> "' + aa.path + '"\n');
    }

    return strBuf.toString();
  }

  /**
	output the fields as a dot string
	@todo skip inherited fields
   **/
  private function getFieldsDotStr() : String
  {
    var strBuf = new StringBuf();
    for( ff in fields.filter(function(ii) { return !ii.isFunc; }) )
      strBuf.add(ff.getFieldStr());

    return strBuf.toString();
  }

  /**
	output the methods as a dot string
	@todo skip inherited methods
   **/
  private function getMethodsDotStr() : String
  {
    var strBuf = new StringBuf();
    for( mm in fields.filter(function(ii) { return ii.isFunc; }) )
      strBuf.add(mm.getFieldStr());

    return strBuf.toString();
  }

  /**
	find out which data types this class is associated with
	@return list of references of associated data types
   **/
  private function findAssociations()
  {
    var assoc = new List<Reference>();
    for( rr in fields )
    {
      // skip functions
      if( rr.path == null )
	continue;

      // add fields and field type params, only add each reference once
      for( aa in rr.inPkg(HaxeUmlGen.pkg) )
	if( !Lambda.exists(assoc, function(tt) { return aa.path==tt.path; }) )
	  assoc.add(aa);
    }
    return assoc;
  }
}


