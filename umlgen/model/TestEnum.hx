package umlgen.model;

class TestEnum extends haxe.unit.TestCase
{
  public function testEnumEmpty()
  {
    var testEnum = new EnumModel("the.pkg.AnEnum");
    assertEquals('\t "the.pkg.AnEnum" [ label = "{\\<enum\\>\\nAnEnum|}" ]\n', testEnum.getDotStr());
  }

  public function testEnumOne()
  {
    var testEnum = new EnumModel("the.pkg.AnEnum");
    testEnum.addField("field1");
    assertEquals('\t "the.pkg.AnEnum" [ label = "{\\<enum\\>\\nAnEnum|field1\\l}" ]\n', testEnum.getDotStr());
  }

  public function testEnumTwo()
  {
    var testEnum = new EnumModel("the.pkg.AnEnum");
    testEnum.addField("field1");
    testEnum.addField("field2");
    assertEquals('\t "the.pkg.AnEnum" [ label = "{\\<enum\\>\\nAnEnum|field1\\lfield2\\l}" ]\n', testEnum.getDotStr());
  }
}