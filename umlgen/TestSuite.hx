package umlgen;

class TestSuite
{
  static function main()
  {
    var r = new haxe.unit.TestRunner();

    r.add(new umlgen.model.TestParam());
    r.add(new umlgen.model.TestField());

    r.run();
  }
}
