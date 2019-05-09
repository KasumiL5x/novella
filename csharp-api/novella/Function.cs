using System;
using System.Collections.Generic;

namespace nv {
	public class Function: Identifiable {
		Guid _id;
		public Guid ID {
			get{ return _id; }
		}

		LuaSession _luaSession;

		string _code;
		public string Code {
			get{ return _code; }
			set{ _code = value; }
		}

		Dictionary<string, string> _localVariables;

		public Function(Guid id, LuaSession luaSession) {
			this._id = id;
			this._luaSession = luaSession;
			this._code = "";
			this._localVariables = new Dictionary<string, string>();
		}

		public void setLocalVariable(string localName, string globalName) {
			_localVariables[localName] = globalName;
		}

		public void evaluate() {
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
			funcCode += funcName + "()"; // call the actual function

			// load function into lua and call it
			var luaFunc = _luaSession.loadString(funcCode, funcName);
			if(null == luaFunc) {
				return;
			}
			luaFunc.Call();
		}
	}
}