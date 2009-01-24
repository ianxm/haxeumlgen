package umlgen.model;

/**
	an enum
 **/
class TypedefModel implements ModelType
{
  /** package and type, for functions this is the return type **/
  public var path(default,null) : String;

  /** package **/
  public var pkg(default,null) : String;

  /** class name **/
  public var type(default,null) : String;

  private var fields : List<Reference>;

  public function new(p)
  {
    path = p;
    var pathSep = Reference.separatePath(path);
    pkg = pathSep.pkg;
    type = pathSep.type;
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
    var sep = path.lastIndexOf(".");
    var name = (sep==-1) ? path : path.substr(sep+1, path.length-sep-1);
    return '\t "' + path + '" [ label = "{\\<typedef\\>\\n' + name + '|' + getFields() + '}" ]\n';
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
