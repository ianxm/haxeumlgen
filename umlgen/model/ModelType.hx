package umlgen.model;

/**
	superclass for all data types
 **/
interface ModelType
{
  private var pkg : String;
  private var name : String;
  public function getDotStr() : String;
}
