package umlgen.model;

class TestParam extends haxe.unit.TestCase
{
  public function testParamInt()
  {
    var param = new ParamModel("aParam","Int");
    assertEquals("aParam : Int", param.getDotStr());
  }

  public function testParamCar()
  {
    var param = new ParamModel("anotherParam","Car");
    assertEquals("anotherParam : Car", param.getDotStr());
  }
}