package umlgen;

class TestSuite
{
  static function main()
  {
    var r = new haxe.unit.TestRunner();

    r.add(new umlgen.model.TestReference());
    r.add(new umlgen.model.TestEnum());
    r.add(new umlgen.model.TestTypedef());
    r.add(new umlgen.model.TestClass());
    r.run();
  }
}
