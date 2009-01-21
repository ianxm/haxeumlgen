package umlgen.model;

class TestEnum extends haxe.unit.TestCase
{
  public function testEnumEmpty()
  {
    var testEnum = new EnumModel("the.pkg", "AnEnum");
    assertEquals(" AnEnum [ label = \"{AnEnum|}\" ]", testEnum.getDotStr());
  }

  public function testEnumOne()
  {
    var testEnum = new EnumModel("the.pkg", "AnEnum");
    testEnum.addField("field1");
    assertEquals(" AnEnum [ label = \"{AnEnum|field1\\l}\" ]", testEnum.getDotStr());
  }

  public function testEnumTwo()
  {
    var testEnum = new EnumModel("the.pkg", "AnEnum");
    testEnum.addField("field1");
    testEnum.addField("field2");
    assertEquals(" AnEnum [ label = \"{AnEnum|field1\\lfield2\\l}\" ]", testEnum.getDotStr());
  }
}