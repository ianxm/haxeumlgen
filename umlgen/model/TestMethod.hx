package umlgen.model;

class TestMethod extends haxe.unit.TestCase
{
  public function testMethodEmptyVoid()
  {
    var method = new MethodModel(false, false, "private", "aMethod", "Void");
    assertEquals("- aMethod() : Void\\l", method.getDotStr());
  }

  public function testMethodEmptyInt()
  {
    var method = new MethodModel(false, false, "public", "aMethod", "Int");
    assertEquals("+ aMethod() : Int\\l", method.getDotStr());
  }

  public function testMethodOneParam()
  {
    var method = new MethodModel(false, false, "public", "anotherMethod", "Car");
    method.addParam(new ParamModel("aParam", "Int"));
    assertEquals("+ anotherMethod(aParam : Int) : Car\\l", method.getDotStr());
  }

  public function testMethodTwoParams()
  {
    var method = new MethodModel(false, false, "public", "anotherMethod", "Car");
    method.addParam(new ParamModel("aParam", "Int"));
    method.addParam(new ParamModel("anotherParam", "Float"));
    assertEquals("+ anotherMethod(aParam : Int, anotherParam : Float) : Car\\l", method.getDotStr());
  }
}