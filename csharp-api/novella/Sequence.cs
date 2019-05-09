using System;
using System.Linq;
using System.Collections.Generic;

namespace nv {
	public class Sequence: Linkable {
		Guid _id;
		public Guid ID {
			get{ return _id; }
		}

		Story _story;

		Group _parent;

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
	
		Function _exitFunction;
		public Function ExitFunction {
			get{ return _exitFunction; }
			set{
				_exitFunction = value;
				_exitFunction?.setLocalVariable("caller", ID.toVariableName());
			}
		}

		Event _entry;
		public Event Entry {
			get{ return _entry; }
			set{
				if(value != null && !contains(value)) {
					Console.WriteLine(String.Format("ERROR: Tried to set Sequence ({0}) entry to a non-contained Event ({1}).", _id.ToString(), value.ID.ToString()));
					_entry = null;
					return;
				}
				_entry = value;
			}
		}

		List<Event> _events;
		List<Link> _links;
		List<Hub> _hubs;
		List<Return> _returns;

		List<LinkableDelegate> _delegates;

		List<Chain> _chains;

		public Sequence(Guid id, Story story) {
			this._id = id;
			this._story = story;
			this._parent = null;
			this._parallel = false;
			this._label = "";
			this._topmost = false;
			this._maxActivations = 1;
			this._activations = 0;
			this._active = false;
			this._keepAlive = false;
			this._condition = null;
			this._entryFunction = null;
			this._exitFunction = null;
			this._entry = null;
			this._events = new List<Event>();
			this._links = new List<Link>();
			this._hubs = new List<Hub>();
			this._returns = new List<Return>();
			this._delegates = new List<LinkableDelegate>();
			this._chains = new List<Chain>();
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
			Console.WriteLine(String.Format("Activated Sequence ({0}) {1}/{2}.", _label, _activations, _maxActivations));

			_entryFunction?.evaluate();

			if(_entry != null) {
				_chains.Add(new Chain(_story, _entry));
			}
		}

		public void step() {
			if(!_active) {
				return;
			}

			// activate all inactive parallel events whose condition is met
			foreach(var evt in _events) {
				// if it's not parallel or cannot be activated, skip
				if(!evt.Parallel || !evt.canActivate()) {
					continue;
				}

				_chains.Add(new Chain(_story, evt));
			}

			// step all chains
			_chains.ForEach(ch => ch.step());

			// check for deactivation case if keep alive isn't set
			if(!KeepAlive) {
				var activeChainCount = _chains.Where(ch => !ch.Finished).Count();
				var activeParallelEventCount = _events.Where(evt => evt.Parallel && (evt.isActive() || evt.canActivate())).Count();
				// (events that are active or can activate) > 0 means it should stay active
				if((activeChainCount + activeParallelEventCount) == 0) {
					deactivate();
				}
			}
		}

		public void deactivate() {
			if(!_active) {
				return;
			}

			_events.ForEach(evt => evt.deactivate());

			_exitFunction?.evaluate();

			_active = false;

			Console.WriteLine(String.Format("Deactivated Sequence ({0}) {1}/{2}.", _label, _activations, _maxActivations));

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

		public void setParent(Group parent) {
			this._parent = parent;
		}

		public bool contains(Event evt) {
			return _events.Contains(evt);
		}
		public void add(Event evt) {
			if(contains(evt)) {
				return;
			}
			_events.Add(evt);
		}
		public void remove(Event evt) {
			_events.Remove(evt);
		}

		public bool contains(Link link) {
			return _links.Contains(link);
		}
		public void add(Link link) {
			if(contains(link)) {
				return;
			}
			_links.Add(link);
		}
		public void remove(Link link) {
			_links.Remove(link);
		}
		
		public bool contains(Hub hub) {
			return _hubs.Contains(hub);
		}
		public void add(Hub hub) {
			if(contains(hub)) {
				return;
			}
			_hubs.Add(hub);
		}
		public void remove(Hub hub) {
			_hubs.Remove(hub);
		}

		public bool contains(Return rtrn) {
			return _returns.Contains(rtrn);
		}
		public void add(Return rtrn) {
			if(contains(rtrn)) {
				return;
			}
			_returns.Add(rtrn);
		}
		public void remove(Return rtrn) {
			_returns.Remove(rtrn);
		}
	}
}