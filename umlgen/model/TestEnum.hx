package umlgen.model;

class TestEnum extends haxe.unit.TestCase
{
  public function testEnumEmpty()
  {
    var testEnum = new EnumModel("the.pkg.AnEnum");
    assertEquals(" the.pkg.AnEnum [ label = \"{the.pkg.AnEnum|}\" ]", testEnum.getDotStr());
  }

  public function testEnumOne()
  {
    var testEnum = new EnumModel("the.pkg.AnEnum");
    testEnum.addField("field1");
    assertEquals(" the.pkg.AnEnum [ label = \"{the.pkg.AnEnum|field1\\l}\" ]", testEnum.getDotStr());
  }

  public function testEnumTwo()
  {
    var testEnum = new EnumModel("the.pkg.AnEnum");
    testEnum.addField("field1");
    testEnum.addField("field2");
    assertEquals(" the.pkg.AnEnum [ label = \"{the.pkg.AnEnum|field1\\lfield2\\l}\" ]", testEnum.getDotStr());
  }
}