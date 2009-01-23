package umlgen.model;

/**
	an enum
 **/
class EnumModel implements ModelType
{
  public var path(default,null) : String;
  private var fields : List<String>;

  public function new(p)
  {
    path = p;
    fields = new List<String>();
  }

  /**
	add a field to the enum
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
    return '\t "' + path + '" [ label = "{' + path + '|' + getFieldsDotStr() + '}" ]\n';
  }

  /**
	output the params as a dot string
   **/
  private function getFieldsDotStr() : String
  {
    var strBuf = new StringBuf();
    for( ff in fields )
      strBuf.add(ff + "\\l");

    return strBuf.toString();
  }
}
