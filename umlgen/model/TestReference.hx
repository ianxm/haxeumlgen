package umlgen.model;

class TestReference extends haxe.unit.TestCase
{
  public function testReferenceVarInt()
  {
    var field = new Reference("aField", "Int", false, false);
    assertEquals("- aField : Int\\l", field.getFieldStr());
    assertEquals("aField : Int", field.getParamStr());
  }

  public function testReferenceVarCar()
  {
    var field = new Reference("anotherField", "Car", false, true);
    assertEquals("+ anotherField : Car\\l", field.getFieldStr());
    assertEquals("anotherField : Car", field.getParamStr());
  }

  public function testReferenceFuncEmpty()
  {
    var field = new Reference("aFunc", "Foo", true, false);
    assertEquals("- aFunc() : Foo\\l", field.getFieldStr());
    assertEquals("aFunc() : Foo", field.getParamStr());
  }

  public function testReferenceFuncOne()
  {
    var field = new Reference("aFunc", "some.Foo", true, false);
    field.addParam(new Reference("aParam", "some.Int"));
    assertEquals("- aFunc(aParam : some.Int) : some.Foo\\l", field.getFieldStr());
    assertEquals("aFunc(aParam : some.Int) : some.Foo", field.getParamStr());
  }

  public function testReferenceFuncTwo()
  {
    var field = new Reference("aFunc", "Foo", true, false);
    field.addParam(new Reference("aParam", "Int"));
    field.addParam(new Reference("anotherParam", "some.Boat"));
    assertEquals("- aFunc(aParam : Int, anotherParam : some.Boat) : Foo\\l", field.getFieldStr());
    assertEquals("aFunc(aParam : Int, anotherParam : some.Boat) : Foo", field.getParamStr());
  }
}