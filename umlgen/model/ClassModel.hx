package umlgen.model;

/**
	a class
 **/
class ClassModel implements ComplexType
{
  private var pkg : String;
  private var name : String;
  private var fields : List<FieldModel>;
  private var methods : List<MethodModel>;
  private var parents : List<ClassModel>;
  private var children : List<ClassModel>;
  private var associations : List<ComplexType>;

  public function new(p, n)
  {
    pkg = p;
    name = n;
    methods = new List<MethodModel>();
    fields = new List<FieldModel>();
    parents = new List<ClassModel>();
    children = new List<ClassModel>();
    associations = new List<ComplexType>();
  }

  public function addParent(p)
  {
    parents.add(p);
  }

  public function addChild(c)
  {
    children.add(c);
  }

  public function addAssociation(a)
  {
    associations.add(a);
  }

  /**
	add a field
   **/
  public function addField(f)
  {
    fields.add(f);
  }

  /**
	add a method
   **/
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
