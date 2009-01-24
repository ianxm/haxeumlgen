package umlgen.model;

/**
	an enum
 **/
class EnumModel implements ModelType
{
  /** package and class name **/
  public var path(default,null) : String;

  /** package **/
  public var pkg(default,null) : String;

  /** class name **/
  public var type(default,null) : String;

  private var fields : List<String>;

  public function new(p)
  {
    path = p;
    var pathSep = Reference.separatePath(path);
    pkg = pathSep.pkg;
    type = pathSep.type;
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
    var sep = path.lastIndexOf(".");
    var name = (sep==-1) ? path : path.substr(sep+1, path.length-sep-1);
    return '\t "' + path + '" [ label = "{\\<enum\\>\\n' + name + '|' + getFieldsDotStr() + '}" ]\n';
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
