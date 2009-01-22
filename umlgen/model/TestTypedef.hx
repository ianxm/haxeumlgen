package umlgen.model;

class TestTypedef extends haxe.unit.TestCase
{
  public function testTypedefEmpty()
  {
    var testTypedef = new TypedefModel("the.pkg", "ATypedef");
    assertEquals(" ATypedef [ label = \"{ATypedef|}\" ]", testTypedef.getDotStr());
  }

  public function testTypedefOne()
  {
    var testTypedef = new TypedefModel("the.pkg", "AnTypedef");
    testTypedef.addField(new ParamModel("field1", "Int"));
    assertEquals(" AnTypedef [ label = \"{AnTypedef|field1 : Int\\l}\" ]", testTypedef.getDotStr());
  }

  public function testTypedefTwo()
  {
    var testTypedef = new TypedefModel("the.pkg", "AnTypedef");
    testTypedef.addField(new ParamModel("field1", "String"));
    testTypedef.addField(new ParamModel("field2", "Cat"));
    assertEquals(" AnTypedef [ label = \"{AnTypedef|field1 : String\\lfield2 : Cat\\l}\" ]", testTypedef.getDotStr());
  }
}