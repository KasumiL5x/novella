using System;
using System.Collections.Generic;

namespace nv {
	public class Hub: Linkable {
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

		Condition _condition;
		public Condition Condition {
			get{ return _condition; }
			set{
				_condition = value;
				_condition?.setLocalVariable("caller", ID.toVariableName());
			}
		}

		Function _entryFunction;
		public Function EntryFunction {
			get{ return _entryFunction; }
			set{
				_entryFunction = value;
				_entryFunction?.setLocalVariable("caller", ID.toVariableName());
			}
		}

		Function _returnFunction;
		public Function ReturnFunction {
			get{ return _returnFunction; }
			set{
				_returnFunction = value;
				_returnFunction?.setLocalVariable("caller", ID.toVariableName());
			}
		}

		Function _exitFunction;
		public Function ExitFunction {
			get{ return _exitFunction; }
			set{
				_exitFunction = value;
				_exitFunction?.setLocalVariable("caller", ID.toVariableName());
			}
		}

		List<LinkableDelegate> _delegates;

		public Hub(Guid id) {
			this._id = id;
			this._label = "";
			this._activations = 0;
			this._active = false;
			this._condition = null;
			this._entryFunction = null;
			this._returnFunction = null;
			this._exitFunction = null;
			this._delegates = new List<LinkableDelegate>();
		}

		public bool canBeOrigin() {
			return true;
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

			// condition check only the first time
			if(_activations > 0 || null == _condition || _condition.evaluate()) {
				activate();
			}
		}

		public void activate() {
			if(!canActivate()) {
				return;
			}

			_activations += 1;
			_active = true;

			// run return function on each activation, but entry on first activate
			if(_activations > 1) {
				_returnFunction?.evaluate();
			} else {
				_entryFunction?.evaluate();
			}

			Console.WriteLine(String.Format("Activated Hub ({0}) {1}.", _label, _activations));
		}

		public void step() {
			if(!_active) {
				return;
			}

			// hub acts like a dummy container to just cause stalemate, so just deactivate instantly
			deactivate();
		}

		public void deactivate() {
			if(!_active) {
				return;
			}

			_exitFunction?.evaluate();

			_active = false;

			Console.WriteLine(String.Format("Deactivated Hub ({0}) {1}.", _label, _activations));

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