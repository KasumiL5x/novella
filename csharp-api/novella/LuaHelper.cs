using System;
using System.Linq;
using System.Collections.Generic;

namespace nv {
	public class LuaHelper {
		Story _story;

		public LuaHelper(Story story) {
			this._story = story;
		}

		public void setup(LuaSession session) {
			var lua = session.Lua;

			lua.RegisterFunction("nvprint", this, this.GetType().GetMethod("nvprint"));

			lua.RegisterFunction("variable", this, this.GetType().GetMethod("variable"));
			lua.RegisterFunction("setint", this, this.GetType().GetMethod("setInt"));
			lua.RegisterFunction("setfloat", this, this.GetType().GetMethod("setFloat"));
			lua.RegisterFunction("setbool", this, this.GetType().GetMethod("setBool"));
			lua.RegisterFunction("getint", this, this.GetType().GetMethod("getInt"));
			lua.RegisterFunction("getfloat", this, this.GetType().GetMethod("getFloat"));
			lua.RegisterFunction("getbool", this, this.GetType().GetMethod("getBool"));

			lua.RegisterFunction("entity", this, this.GetType().GetMethod("entity"));
			lua.RegisterFunction("entities", this, this.GetType().GetMethod("entities"));
			lua.RegisterFunction("addtag", this, this.GetType().GetMethod("addTag"));
			lua.RegisterFunction("deltag", this, this.GetType().GetMethod("delTag"));
		}

		public void nvprint(string name) {
			Console.WriteLine(name);
		}

		// VARIABLES
		public Variable variable(string name) {
			return _story.Variables.FirstOrDefault(variable => variable.Name == name);
		}
		public void setInt(Variable variable, int value) {
			variable.set(value);
		}
		public void setFloat(Variable variable, float value) {
			variable.set(value);
		}
		public void setBool(Variable variable, bool value) {
			variable.set(value);
		}
		public int getInt(Variable variable) {
			return variable.asInt();
		}
		public float getFloat(Variable variable) {
			return variable.asFloat();
		}
		public bool getBool(Variable variable) {
			return variable.asBool();
		}

		// ENTITIES
		public Entity entity(string label) {
			return _story.Entities.FirstOrDefault(ent => ent.Label == label);
		}
		public List<Entity> entities(List<string> withTags) {
			List<Entity> result = new List<Entity>();
			foreach(var ent in _story.Entities) {
				foreach(var tag in withTags) {
					if(ent.Tags.Contains(tag)) {
						result.Add(ent);
						break; // stop checking tags
					}
				}
			}
			return result;
		}
		public void addTag(Entity ent, string tag) {
			ent.addTag(tag);
		}
		public void delTag(Entity ent, string tag) {
			ent.removeTag(tag);
		}

		// COMPONENTS
		// public void triggerGroup(Group group) {
		// 	Console.WriteLine("TODO: triggerGroup");
		// }
		// public void triggerGroupDelay(Group group, int ms) {
		// 	Console.WriteLine("TODO: triggerGroupDelay");
		// }
		// etc...
	}
}