using System;
using System.Collections.Generic;

namespace nv {
	public class Selector: Identifiable {
		Guid _id;
		public Guid ID {
			get{ return _id; }
		}

		private LuaSession _luaSession;

		string _code;
		public string Code {
			get{ return _code; }
			set{ _code = value; }
		}

		public Selector(Guid id, LuaSession luaSession) {
			this._id = id;
			this._luaSession = luaSession;
			this._code = "";
		}

		public List<Entity> evaluate() {
			// build unique function name based on GUID
			string funcName = "_" + _id.ToString().Replace("-", "");
			// wrap user code in a function
			string funcCode = "function " + funcName + "()\n";
			funcCode += _code;
			funcCode += "\nend\n";
			funcCode += "return " + funcName + "()"; // call and return the actual function

			// load function into lua and call it
			var luaFunc = _luaSession.loadString(funcCode, funcName);
			if(null == luaFunc) {
				return new List<Entity>();
			}
			var result = luaFunc.Call();

			// no data returned
			if(0 == result.Length) {
				return new List<Entity>();
			}

			// attempt cast to a single entity
			if(result[0] is Entity) {
				return new List<Entity>{(Entity)result[0]};
			}

			// attempt to cast to a list of entities
			if(result[0] is List<Entity>) {
				return (List<Entity>)result[0];
			}

			return new List<Entity>();
		}
	}
}