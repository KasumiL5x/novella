using System;

namespace nv {
    public enum Tangibility {
        Tangible,
        Intangible
    }

    public enum Functionality {
        Narrative,
        Mechanical
    }

    public enum Clarity {
        Explicit,
        Implicit
    }

    public enum Delivery {
        Active,
        Passive
    }

	public class Discoverable: Sequence {
        Tangibility _tangibility;
        public Tangibility Tangibility {
            get{ return _tangibility; }
            set{ _tangibility = value; }
        }

        Functionality _functionality;
        public Functionality Functionality {
            get{ return _functionality; }
            set{ _functionality = value; }
        }

        Clarity _clarity;
        public Clarity Clarity {
            get{ return _clarity; }
            set{ _clarity = value; }
        }

        Delivery _delivery;
        public Delivery Delivery {
            get{ return _delivery; }
            set{ _delivery = value; }
        }

		public Discoverable(Guid id, Story story): base(id, story) {
            this._tangibility = Tangibility.Tangible;
            this._functionality = Functionality.Narrative;
            this._clarity = Clarity.Explicit;
            this._delivery = Delivery.Active;
		}
	}
}