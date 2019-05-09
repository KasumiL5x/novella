using System;
using NLua;

namespace nv {
	public class LuaSession {
		private Lua _lua;
		public Lua Lua {
			get{ return _lua; }
		}

		public LuaSession() {
			_lua = new Lua();
		}

		public void loadCLR() {
			_lua.LoadCLRPackage();
		}

		public object[] doString(string chunk, string name="chunk") {
			return _lua.DoString(chunk, name);
		}

		public LuaFunction loadString(string chunk, string name) {
			LuaFunction result = null;
			try {
				result = _lua.LoadString(chunk, name);
			} catch (Exception ex) {
				var msg = "Failed to load Lua string (" + ex.Message + ").\n";
				msg += "Name: " + name + "\n";
				msg += chunk;
				Console.WriteLine(msg);
			}

			if(null == result) {
				var msg = "Failed to load Lua string.\n";
				msg += "Name: " + name + "\n";
				msg += chunk;
				Console.WriteLine(msg);
				return null;
			}

			return result;
		}

	}
}