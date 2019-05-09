using System;
using System.Collections.Generic;

namespace nv {
	public class Event: Linkable {
		Guid _id;
		public Guid ID {
			get{ return _id; }
		}

		Story _story;

		string _label;
		public string Label {
			get{ return _label; }
			set{ _label = value; }
		}

		bool _parallel;
		public bool Parallel {
			get{ return _parallel; }
			set{ _parallel = value; }
		}

		bool _topmost;
		public bool Topmost {
			get{ return _topmost; }
			set{ _topmost = value; }
		}

		int _maxActivations;
		public int MaxActivations {
			get{ return _maxActivations; }
			set{ _maxActivations = value < 0 ? 0 : value; }
		}

		int _activations;
		public int Activations {
			get{ return _activations; }
		}

		bool _active;

		bool _keepAlive;
		public bool KeepAlive {
			get{ return _keepAlive; }
			set{ _keepAlive = value; }
		}

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

		Function _doFunction;
		public Function DoFunction {
			get{ return _doFunction; }
			set{
				_doFunction = value;
				_doFunction?.setLocalVariable("caller", ID.toVariableName());
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

		Selector _instigators;
		public Selector Instigators {
			get{ return _instigators; }
			set{ _instigators = value; }
		}

		Selector _targets;
		public Selector Targets {
			get{ return _targets; }
			set{ _targets = value; }
		}

		List<LinkableDelegate> _delegates;

		public Event(Guid id, Story story) {
			this._id = id;
			this._story = story;
			this._parallel = false;
			this._label = "";
			this._topmost = false;
			this._maxActivations = 1;
			this._activations = 0;
			this._active = false;
			this._keepAlive = false;
			this._condition = null;
			this._entryFunction = null;
			this._doFunction = null;
			this._exitFunction = null;
			this._instigators = null;
			this._targets = null;
			this._delegates = new List<LinkableDelegate>();
		}

		public bool canBeOrigin() {
			return true;
		}

		public bool canActivate() {
			// inactive && (infinite activations || has activations left)
			return (!_active) && ((0 == _maxActivations) || (_activations < _maxActivations));
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
				return;
			}

			// condition check
			if(null == _condition || _condition.evaluate()) {
				activate();
			}
		}

		public void activate() {
			if(!canActivate()) {
				return;
			}

			_activations += 1;
			_active = true;

			_entryFunction?.evaluate();

			Console.WriteLine(String.Format("Activated Event ({0}) {1}/{2}.", _label, _activations, _maxActivations));
		}

		public void step() {
			if(!_active) {
				return;
			}

			_doFunction?.evaluate();

			// TODO!: I want to figure out how I can have this deactivate delayed until the implementation considers the event complete.
			// I could perhaps have a "begin do" function that goes and does its thing, then an "end do" function that the user must call to determine when the event is 'done' with one shot?
			// need to think about this.
			// deactivate();
			_story.Delegates.ForEach(del => del.storyEventNeedsDisabling(_story, this));
		}

		public void deactivate() {
			if(!_active) {
				return;
			}

			_exitFunction?.evaluate();

			_active = false;

			Console.WriteLine(String.Format("Deactivated Event ({0}) {1}/{2}.", _label, _activations, _maxActivations));

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