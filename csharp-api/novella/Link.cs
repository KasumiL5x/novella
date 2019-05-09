using System;

namespace nv {
	public class Link: Identifiable {
		Guid _id;
		public Guid ID {
			get{ return _id; }
		}

		private Linkable _origin;
		public Linkable Origin {
			get{ return _origin; }
		}

		private Linkable _destination;
		public Linkable Destination {
			get{ return _destination; }
		}

		private Function _function;
		public Function Function {
			get{ return _function; }
		}

		private Condition _condition;
		public Condition Condition {
			get{ return _condition; }
		}

		public Link(Guid id, Linkable origin, Linkable destination) {
			this._id = id;
			this._origin = origin;

			if(null == origin || !origin.canBeOrigin()) {
				var originID = (null == origin) ? "null" : origin.ID.ToString();
				Console.WriteLine(String.Format("ERROR: Link ({0}) has invalid origin ({1})!", id.ToString(), originID));
				this._origin = null;
			}

			setDestination(destination);
		}

		public void setDestination(Linkable dest) {
			if(dest != null && dest == _origin) {
				Console.WriteLine(String.Format("ERROR: Tried to set Link ({0}) destination to its origin ({1}).", _id.ToString(), dest.ID));
				return;
			}
			var prevID = (null == _destination) ? "null" : _destination.ID.ToString();
			var newID = (null == dest) ? "null" : dest.ID.ToString();
			// Console.WriteLine(String.Format("Link ({0}) destination changed ({1} -> {2}).", _id.ToString(), prevID, newID));
			_destination = dest;
		}

		public void setFunction(Function func) {
			var prevID = (null == _function) ? "null" : _function.ID.ToString();
			var newID = (null == func) ? "null" : func.ID.ToString();
			// Console.WriteLine(String.Format("Link ({0}) Function changed ({1} -> {2}).", _id.ToString(), prevID, newID));
			this._function = func;
		}

		public void setCondition(Condition cond) {
			var prevID = (null == _condition) ? "null" : _condition.ID.ToString();
			var newID = (null == cond) ? "null" : cond.ID.ToString();
			// Console.WriteLine(String.Format("Link ({0}) Condition changed ({1} -> {2}).", _id.ToString(), prevID, newID));
			this._condition = cond;
		}
	}
}