package umlgen.model;

/**
	a class
 **/
class ClassModel implements ModelType
{
  private var pkg : String;
  private var name : String;
  private var fields : List<Reference>;
  private var methods : List<Reference>;
  private var parents : List<Reference>;
  private var children : List<Reference>;

  public function new(p, n)
  {
    pkg = p;
    name = n;
    methods = new List<Reference>();
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

  /**	add a method   **/
  public function addMethod(m)
  {
    methods.add(m);
  }

  public function getDotStr() : String
  {
    return " " + name + " [ label = \"{" + name + "|" + getFieldsDotStr() + "|" 
      + getMethodsDotStr() + "}\" ]";
  }

  /**
	output the fields as a dot string
   **/
  private function getFieldsDotStr() : String
  {
    var strBuf = new StringBuf();
    for( ff in fields )
      strBuf.add(ff.getDotStr());

    return strBuf.toString();
  }

  /**
	output the methods as a dot string
   **/
  private function getMethodsDotStr() : String
  {
    var strBuf = new StringBuf();
    for( mm in methods )
      strBuf.add(mm.getDotStr());

    return strBuf.toString();
  }
}
