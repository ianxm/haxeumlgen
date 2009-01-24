import Type;

class SLambda
{
  /**
	find first item in an iterable. return null if it doesn't exist. 
	sort of like it.filter(f).first() but doesn't have to go through the whole list.
   **/
  public static function findFirst<A>( it : Iterable<A>, f : A -> Bool ) : A
  {
    for( ii in it )
      if( f(ii) )
	return ii;
    return null;
  }

  /**
	returns a deep copy of anything
  **/
  public static function deepCopy<T>( v:T ) : T
  {
    var type = Type.typeof(v);
    if( type==TInt || type==TFloat || type==TNull || type==TUnknown || type==TFunction ) // simple type
      return v;

    else if( Std.is(v, Array) ) // array
    {
      var r = Type.createInstance(Type.getClass(v), []);
     untyped
     {
       for( ii in 0...v.length )
	 r.push(deepCopy(v[ii]));
     }
     return r;
    }
    else
    {
      var obj;
      switch( type )
      {
      case TClass(_): // class
	obj = Type.createEmptyInstance(Type.getClass(v));

      case TEnum(_): // enum
	obj = Type.createEnum(Type.getEnum(v), Type.enumConstructor(v), Type.enumParameters(v));

      default: // anonymous object
	obj = cast {};
      }
      for( ff in Reflect.fields(v) )
	Reflect.setField(obj, ff, deepCopy(Reflect.field(v, ff)));
      return cast obj;
    }
    return null;
  }


}