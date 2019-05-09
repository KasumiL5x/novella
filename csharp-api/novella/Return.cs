using System;
using System.Collections.Generic;

namespace nv {
	public class Return: Linkable {
		Guid _id;
		public Guid ID {
			get{ return _id; }
		}

		string _label;
		public string Label {
			get{ return _label; }
			set{ _label = value; }
		}

		int _activations;
		public int Activations {
			get{ return _activations; }
		}

		bool _active;

		Function _exitFunction;
		public Function ExitFunction {
			get{ return _exitFunction; }
			set{
				_exitFunction = value;
				_exitFunction?.setLocalVariable("caller", ID.toVariableName());
			}
		}

		List<LinkableDelegate> _delegates;

		public Return(Guid id) {
			this._id = id;
			this._label = "";
			this._activations = 0;
			this._active = false;
			this._exitFunction = null;
			this._delegates = new List<LinkableDelegate>();
		}

		public bool canBeOrigin() {
			return false;
		}

		public bool canActivate() {
			return !_active; // has no activation limit
		}

		public bool isActive() {
			return _active;
		}

		public void tryActivate() {
			// already active
			if(_active) {
				return;
			}

			// cannot activate
			if(!canActivate()) {
				// note: basically the same as above, but separated out in case i add other checking logic as in the other elements
				return;
			}

			activate();
		}

		public void activate() {
			if(!canActivate()) {
				return;
			}

			_activations += 1;
			_active = true;

			Console.WriteLine(String.Format("Activated Return ({0}) {1}.", _label, _activations));
		}

		public void step() {
			if(!_active) {
				return;
			}

			// return acts like a dummy container to just return to the previously encountered hub, so just deactivate
			deactivate();
		}

		public void deactivate() {
			if(!_active) {
				return;
			}

			_exitFunction?.evaluate();

			_active = false;

			Console.WriteLine(String.Format("Deactivated Return ({0}) {1}.", _label, _activations));

			// not a regular .ForEach as the array is modified during this loop
			foreach(var del in new List<LinkableDelegate>(_delegates)) {
				del.linkableDidDeactivate();
			}
		}

		public void addDelegate(LinkableDelegate del) {
			_delegates.Add(del);
		}

		public void removeDelegate(LinkableDelegate del) {
			_delegates.Remove(del);
		}
	}
}