package umlgen.model;

/**
	an enum
 **/
class TypedefModel implements ModelType
{
  public var path(default,null) : String;
  private var fields : List<Reference>;

  public function new(p)
  {
    path = p;
    fields = new List<Reference>();
  }

  /**
	add a field
   **/
  public function addField(f)
  {
    fields.add(f);
  }

  /**
	output this type as a dot string
   **/
  public function getDotStr() : String
  {
    return '\t "' + path + '" [ label = "{' + path + '|' + getFields() + '}" ]\n';
  }

  /**
	output the params as a dot string
   **/
  private function getFields() : String
  {
    var strBuf = new StringBuf();
    for( ff in fields )
      strBuf.add(ff.getParamStr() + "\\l");

    return strBuf.toString();
  }
}
