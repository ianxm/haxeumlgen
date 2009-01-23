package umlgen.model;

/**
	a class
 **/
class ClassModel implements ModelType
{
  public var path(default,null) : String;
  private var isInterface : Bool;

  /** this contains fields and methods **/
  private var fields : List<Reference>;

  private var parents : List<Reference>;

  public function new(p, i)
  {
    path = p;
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

  public function getDotStr() : String
  {
    var strBuf = new StringBuf();
    var topBox = (isInterface) ? '\\<interface\\>\\n' + path : path;
    strBuf.add('\t "' + path + '" [ label = "{' + topBox + '|' + getFieldsDotStr() + '|' + getMethodsDotStr() + '}" ]\n');
    if( !parents.isEmpty() )
    {
      strBuf.add('\t  edge [ arrowhead = "empty" ]\n');
      for( pp in parents )
	strBuf.add('\t  "' + path + '" -> "' + pp.path + '"\n');
    }
    return strBuf.toString();
  }

  /**
	output the fields as a dot string
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
   **/
  private function getMethodsDotStr() : String
  {
    var strBuf = new StringBuf();
    for( mm in fields.filter(function(ii) { return ii.isFunc; }) )
      strBuf.add(mm.getFieldStr());

    return strBuf.toString();
  }
}
