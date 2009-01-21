package umlgen.model;

/**
	a class
 **/
class ClassModel implements ComplexType
{
  private var methods : List<MethodModel>;
  private var parents : List<ClassModel>;
  private var children : List<ClassModel>;
  private var associations : List<ComplexType>;

  public function new(n)
  {
    name = n;
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

  overrides public function getDotStr() : String
  {
    return "";
  }
}
