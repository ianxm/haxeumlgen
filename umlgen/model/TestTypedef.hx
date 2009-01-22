package umlgen.model;

class TestTypedef extends haxe.unit.TestCase
{
  public function testTypedefEmpty()
  {
    var testTypedef = new TypedefModel("the.pkg.ATypedef");
    assertEquals(" the.pkg.ATypedef [ label = \"{the.pkg.ATypedef|}\" ]", testTypedef.getDotStr());
  }

  public function testTypedefOne()
  {
    var testTypedef = new TypedefModel("the.pkg.ATypedef");
    testTypedef.addField(new Reference("field1", "Int"));
    assertEquals(" the.pkg.ATypedef [ label = \"{the.pkg.ATypedef|field1 : Int\\l}\" ]", testTypedef.getDotStr());
  }

  public function testTypedefTwo()
  {
    var testTypedef = new TypedefModel("the.pkg.ATypedef");
    testTypedef.addField(new Reference("field1", "String"));
    testTypedef.addField(new Reference("field2", "Cat"));
    assertEquals(" the.pkg.ATypedef [ label = \"{the.pkg.ATypedef|field1 : String\\lfield2 : Cat\\l}\" ]", testTypedef.getDotStr());
  }
}