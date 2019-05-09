using System;

namespace nv {
	public class Variable: Identifiable {
		Guid _id;
		public Guid ID {
			get{ return _id; }
		}

		string _name;
		public string Name {
			get{ return _name; }
		}

		bool _constant;
		public bool Constant {
			get{ return _constant; }
		}

		dynamic _value; // default value

		private Story _story;

		public Variable(Guid id, Story story) {
			this._id = id;
			this._story = story;
		}

		public void setName(string name) {
			if(_story.isVariableNameTaken(name)) {
				Console.WriteLine(String.Format("Failed to rename Variable ({0} -> {1}) as the name was taken.", this._name, name));
				return;
			}
			this._name = name;
		}

		public void setConstant(bool constant) {
			this._constant = constant;
		}

		public int asInt() {
			return (_value is int) ? (int)_value : 0;
		}

		public float asFloat() {
			return (_value is float) ? (float)_value : 0.0f;
		}

		public bool asBool() {
			return (_value is bool) ? (bool)_value : false;
		}

		public void set(dynamic value) {
			if(_constant) {
				Console.WriteLine(String.Format("Tried to set Variable ({0}) value but it is constant.", _name));
				return;
			}
			Console.WriteLine(String.Format("Variable ({0}) value changed ({1} -> {2}).", _name, this._value, value));
			this._value = value;
		}
	}
}