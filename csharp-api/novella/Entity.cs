using System;
using System.Collections.Generic;

namespace nv {
	public class Entity: Identifiable {
		Guid _id;
		public Guid ID {
			get{ return _id; }
		}

		string _label;
		public string Label {
			get{ return _label; }
			set{ _label = value; }
		}

		string _description;
		public string Description {
			get{ return _description; }
			set{ _description = value; }
		}

		HashSet<string> _tags;
		public HashSet<string> Tags {
			get{ return _tags; }
		}

		public Entity(Guid id) {
			this._id = id;
			this._tags = new HashSet<string>();
		}

		public void addTag(string tag) {
			_tags.Add(tag);
		}
		public void removeTag(string tag) {
			_tags.Remove(tag);
		}
	}
}