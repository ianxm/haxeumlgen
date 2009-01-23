package umlgen.model;

class TestClass extends haxe.unit.TestCase
{
  public function testClassEmpty()
  {
    var testClass = new ClassModel("the.pkg.AClass", false);
    assertEquals('\t "the.pkg.AClass" [ label = "{AClass||}" ]\n', testClass.getDotStr());
  }

  public function testClassOneField()
  {
    var testClass = new ClassModel("the.pkg.AClass", false);
    testClass.addField(new Reference("aField", "Int", false, false, false));
    var check = '\t "the.pkg.AClass" [ label = "{AClass|- aField : Int\\l|}" ]\n';
    assertEquals(check, testClass.getDotStr());
  }

  public function testClassTwoFields()
  {
    var testClass = new ClassModel("the.pkg.AClass", false);
    testClass.addField(new Reference("aField1", "Int", false, false, false));
    testClass.addField(new Reference("aField2", "String", false, true, false));
    var check = '\t "the.pkg.AClass" [ label = "{AClass|- aField1 : Int\\l+ aField2 : String\\l|}" ]\n';
    assertEquals(check, testClass.getDotStr());
  }

  public function testClassOneMethod()
  {
    var testClass = new ClassModel("the.pkg.AClass", false);
    testClass.addField(new Reference("aMethod", "Void", true, false, false));
    var check = '\t "the.pkg.AClass" [ label = "{AClass||- aMethod() : Void\\l}" ]\n';
    assertEquals(check, testClass.getDotStr());
  }

  public function testClassOneMethodWithParam()
  {
    var testClass = new ClassModel("the.pkg.AClass", false);
    var method = new Reference("aMethod", "Void", true, false, false);
    method.addParam(new Reference("aParam", "Int"));
    testClass.addField(method);
    var check = '\t "the.pkg.AClass" [ label = "{AClass||- aMethod(aParam : Int) : Void\\l}" ]\n';
    assertEquals(check, testClass.getDotStr());
  }

  public function testClassTwoMethods()
  {
    var testClass = new ClassModel("the.pkg.AClass", false);
    testClass.addField(new Reference("aMethod1", "Void", true, false, false));
    testClass.addField(new Reference("aMethod2", "String", true, true, false));
    var check = '\t "the.pkg.AClass" [ label = "{AClass||- aMethod1() : Void\\l+ aMethod2() : String\\l}" ]\n';
    assertEquals(check, testClass.getDotStr());
  }

  public function testClassOneFieldOneMethod()
  {
    var testClass = new ClassModel("the.pkg.AClass", false);
    testClass.addField(new Reference("aField", "Int", false, false, false));
    testClass.addField(new Reference("aMethod", "String", true, true, false));
    var check = '\t "the.pkg.AClass" [ label = "{AClass|- aField : Int\\l|+ aMethod() : String\\l}" ]\n';
    assertEquals(check, testClass.getDotStr());
  }

  public function testInterface()
  {
    var testClass = new ClassModel("the.pkg.AClass", true);
    var check = '\t "the.pkg.AClass" [ label = "{\\<interface\\>\\nAClass||}" ]\n';
    assertEquals(check, testClass.getDotStr());
  }
}