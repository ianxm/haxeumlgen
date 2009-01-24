/*
 * Copyright (c) 2009, Ian Martins
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE HAXE PROJECT CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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