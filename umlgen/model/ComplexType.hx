package umlgen.model;

/**
	superclass for types that contain fields
 **/
interface ComplexType extends ModelType
{
  private var fields : List<FieldModel>;
}
