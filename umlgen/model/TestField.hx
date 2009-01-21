package umlgen.model;

class TestField extends haxe.unit.TestCase
{
  public function testFieldInt()
  {
    var field = new FieldModel(false, "private", "aField","Int");
    assertEquals("- aField : Int\\l", field.getDotStr());
  }

  public function testFieldCar()
  {
    var field = new FieldModel(false, "public", "anotherField","Car");
    assertEquals("+ anotherField : Car\\l", field.getDotStr());
  }
}