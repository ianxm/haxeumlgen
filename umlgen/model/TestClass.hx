package umlgen.model;

class TestClass extends haxe.unit.TestCase
{
  public function testClassEmpty()
  {
    var testClass = new ClassModel("the.pkg", "AClass");
    assertEquals(' AClass [ label = "{AClass||}" ]', testClass.getDotStr());
  }

  public function testClassOneField()
  {
    var testClass = new ClassModel("the.pkg", "AClass");
    testClass.addField(new FieldModel(false, "private", "aField", "Int"));
    var check = ' AClass [ label = "{AClass|- aField : Int\\l|}" ]';
    assertEquals(check, testClass.getDotStr());
  }

  public function testClassTwoFields()
  {
    var testClass = new ClassModel("the.pkg", "AClass");
    testClass.addField(new FieldModel(false, "private", "aField1", "Int"));
    testClass.addField(new FieldModel(false, "public", "aField2", "String"));
    var check = ' AClass [ label = "{AClass|- aField1 : Int\\l+ aField2 : String\\l|}" ]';
    assertEquals(check, testClass.getDotStr());
  }

  public function testClassOneMethod()
  {
    var testClass = new ClassModel("the.pkg", "AClass");
    testClass.addMethod(new MethodModel(false, "private", "aMethod", "Void"));
    var check = ' AClass [ label = "{AClass||- aMethod() : Void\\l}" ]';
    assertEquals(check, testClass.getDotStr());
  }

  public function testClassOneMethodWithParam()
  {
    var testClass = new ClassModel("the.pkg", "AClass");
    var method = new MethodModel(false, "private", "aMethod", "Void");
    method.addParam(new ParamModel("aParam", "Int"));
    testClass.addMethod(method);
    var check = ' AClass [ label = "{AClass||- aMethod(aParam : Int) : Void\\l}" ]';
    assertEquals(check, testClass.getDotStr());
  }

  public function testClassTwoMethods()
  {
    var testClass = new ClassModel("the.pkg", "AClass");
    testClass.addMethod(new MethodModel(false, "private", "aMethod1", "Void"));
    testClass.addMethod(new MethodModel(false, "public", "aMethod2", "String"));
    var check = ' AClass [ label = "{AClass||- aMethod1() : Void\\l+ aMethod2() : String\\l}" ]';
    assertEquals(check, testClass.getDotStr());
  }

  public function testClassOneFieldOneMethod()
  {
    var testClass = new ClassModel("the.pkg", "AClass");
    testClass.addField(new FieldModel(false, "private", "aField", "Int"));
    testClass.addMethod(new MethodModel(false, "public", "aMethod", "String"));
    var check = ' AClass [ label = "{AClass|- aField : Int\\l|+ aMethod() : String\\l}" ]';
    assertEquals(check, testClass.getDotStr());
  }
}