package umlgen.model;

class TestClass extends haxe.unit.TestCase
{
  public function testClassEmpty()
  {
    var testClass = new ClassModel("the.pkg.AClass");
    assertEquals(' the.pkg.AClass [ label = "{the.pkg.AClass||}" ]', testClass.getDotStr());
  }

  public function testClassOneField()
  {
    var testClass = new ClassModel("the.pkg.AClass");
    testClass.addField(new Reference("aField", "Int", false, false, false));
    var check = ' the.pkg.AClass [ label = "{the.pkg.AClass|- aField : Int\\l|}" ]';
    assertEquals(check, testClass.getDotStr());
  }

  public function testClassTwoFields()
  {
    var testClass = new ClassModel("the.pkg.AClass");
    testClass.addField(new Reference("aField1", "Int", false, false, false));
    testClass.addField(new Reference("aField2", "String", false, true, false));
    var check = ' the.pkg.AClass [ label = "{the.pkg.AClass|- aField1 : Int\\l+ aField2 : String\\l|}" ]';
    assertEquals(check, testClass.getDotStr());
  }

  public function testClassOneMethod()
  {
    var testClass = new ClassModel("the.pkg.AClass");
    testClass.addField(new Reference("aMethod", "Void", true, false, false));
    var check = ' the.pkg.AClass [ label = "{the.pkg.AClass||- aMethod() : Void\\l}" ]';
    assertEquals(check, testClass.getDotStr());
  }

  public function testClassOneMethodWithParam()
  {
    var testClass = new ClassModel("the.pkg.AClass");
    var method = new Reference("aMethod", "Void", true, false, false);
    method.addParam(new Reference("aParam", "Int"));
    testClass.addField(method);
    var check = ' the.pkg.AClass [ label = "{the.pkg.AClass||- aMethod(aParam : Int) : Void\\l}" ]';
    assertEquals(check, testClass.getDotStr());
  }

  public function testClassTwoMethods()
  {
    var testClass = new ClassModel("the.pkg.AClass");
    testClass.addField(new Reference("aMethod1", "Void", true, false, false));
    testClass.addField(new Reference("aMethod2", "String", true, true, false));
    var check = ' the.pkg.AClass [ label = "{the.pkg.AClass||- aMethod1() : Void\\l+ aMethod2() : String\\l}" ]';
    assertEquals(check, testClass.getDotStr());
  }

  public function testClassOneFieldOneMethod()
  {
    var testClass = new ClassModel("the.pkg.AClass");
    testClass.addField(new Reference("aField", "Int", false, false, false));
    testClass.addField(new Reference("aMethod", "String", true, true, false));
    var check = ' the.pkg.AClass [ label = "{the.pkg.AClass|- aField : Int\\l|+ aMethod() : String\\l}" ]';
    assertEquals(check, testClass.getDotStr());
  }
}