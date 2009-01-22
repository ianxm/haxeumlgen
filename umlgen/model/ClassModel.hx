package umlgen.model;

/**
	a class
 **/
class ClassModel implements ModelType
{
  public var path(default,null) : String;

  /** this contains fields and methods **/
  private var fields : List<Reference>;

  private var parents : List<Reference>;
  private var children : List<Reference>;

  public function new(p)
  {
    path = p;
    fields = new List<Reference>();
    parents = new List<Reference>();
    children = new List<Reference>();
  }

  /**	add a super class   **/
  public function addParent(p)
  {
    parents.add(p);
  }

  /**	add a subclass   **/
  public function addChild(c)
  {
    children.add(c);
  }

  /**	add a field   **/
  public function addField(f)
  {
    fields.add(f);
  }

  public function getDotStr() : String
  {
    return " " + path + " [ label = \"{" + path + "|" + getFieldsDotStr() + "|" 
      + getMethodsDotStr() + "}\" ]";
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
