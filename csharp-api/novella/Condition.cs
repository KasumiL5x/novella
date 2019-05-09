using System;
using System.Collections.Generic;

namespace nv {
	public class Condition : Identifiable {
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

		Dictionary<string, string> _localVariables;

		public Condition(Guid id, LuaSession luaSession) {
			this._id = id;
			this._luaSession = luaSession;
			this._code = "return false";
			this._localVariables = new Dictionary<string, string>();
		}

		public void setLocalVariable(string localName, string globalName) {
			_localVariables[localName] = globalName;
		}

		public bool evaluate() {
			// build unique function name based on GUID
			string funcName = "_" + _id.ToString().Replace("-", "");
			// wrap user code in a function
			string funcCode = "function " + funcName + "()\n";

			// add all local variables
			foreach(var kv in _localVariables) {
				funcCode += String.Format("local {0} = {1}\n", kv.Key, kv.Value);
			}

			funcCode += _code;
			funcCode += "\nend\n";
			funcCode += "return " + funcName + "()"; // call and return the actual function

			// load function into lua and call it
			var luaFunc = _luaSession.loadString(funcCode, funcName);
			if(null == luaFunc) {
				return false;
			}
			var result = luaFunc.Call();

			// no data returned
			if(0 == result.Length) {
				return false;
			}

			// attempt cast
			var asBool = result[0] as bool?;
			if(!asBool.HasValue) {
				Console.WriteLine("Condition (" + _id + ") returned a non-boolean type.\n" + _code);
				return false;
			}
			return asBool.Value;
		}
	}
}