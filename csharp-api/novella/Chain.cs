using System;
using System.Collections.Generic;

namespace nv {

	public class Chain: LinkableDelegate {
		Story _story;

		bool _stalemate;
		public bool Stalemate {
			get{ return _stalemate; }
		}

		bool _finished;
		public bool Finished {
			get{ return _finished; }
		}

		List<Linkable> _items;
		public List<Linkable> Items {
			get{ return _items; }
		}

		List<Link> _activeItemValidOutputs;

		Hub _previousHub;

		public Chain(Story story, Linkable start) {
			this._story = story;
			this._stalemate = false;
			this._finished = false;
			this._items = new List<Linkable>();
			this._activeItemValidOutputs = new List<Link>();
			this._previousHub = null;

			this._items.Add(start);
			start.addDelegate(this);
			start.tryActivate();
		}

		public void step() {
			if(_stalemate || _finished) {
				return;
			}

			var activeItem = _items[_items.Count-1];
			if(!activeItem.isActive()) {
				activeItem.tryActivate();
			}
			activeItem.step();
		}

		public void linkableDidDeactivate() {
			var activeItem = _items[_items.Count-1];
			activeItem.removeDelegate(this);
			_activeItemValidOutputs = _story.getValidOutputsFor(activeItem);

			// special case for returns (they have no outputs and go back to the previous hub)
			if(activeItem is Return) {
				// if there's no past hub, fail and finish
				if(null == _previousHub) {
					_finished = true;
					return;
				}

				// add as normal like below (hub will be added 2+ times in this case, as may be return)
				_items.Add(_previousHub);
				_previousHub.addDelegate(this);
				_previousHub.tryActivate();
				_activeItemValidOutputs = new List<Link>();
				return;
			}

			// if no valid links exist, deadlock
			if(0 == _activeItemValidOutputs.Count) {
				_finished = true;
				return;
			}

			// just one link, follow it
			if(1 == _activeItemValidOutputs.Count) {
				var link = _activeItemValidOutputs[0];
				// deadlock if no valid destination
				if(null == link.Destination) {
					_finished = true;
					return;
				}

				// handle hub destination
				if(link.Destination is Hub) {
					_previousHub = link.Destination as Hub;
				}

				_items.Add(link.Destination); // new active item
				link.Destination.addDelegate(this);
				link.Destination.tryActivate(); // activate new item
				_activeItemValidOutputs = new List<Link>(); // reset
				return;
			}

			// enter stalemate and defer the resolution (fixed by using the public resolve function)
			_stalemate = true;
			_story.Delegates.ForEach(del => del.storyChainNeedsResolving(_story, this, _activeItemValidOutputs));
		}

		public bool resolve(Link link) {
			if(!_stalemate) {
				return false; // must be in stalemate
			}

			if(!_activeItemValidOutputs.Contains(link)) {
				return false; // must contain link in our list of valid links
			}

			// destination must be valid, otherwise deadlock
			if(null == link.Destination) {
				_finished = true;
				return false;
			}

			_stalemate = false;

			// handle hub destination
			if(link.Destination is Hub) {
				_previousHub = link.Destination as Hub;
			}

			_items.Add(link.Destination);
			link.Destination.addDelegate(this);
			link.Destination.tryActivate();
			_activeItemValidOutputs = new List<Link>();

			return true;
		}
	}
}