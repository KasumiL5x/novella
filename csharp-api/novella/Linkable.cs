namespace nv {
	public interface Linkable: Identifiable {
		bool canBeOrigin();

		// SIMULATION
		//
		bool canActivate();
		bool isActive();
		void tryActivate(); // respects condition
		void activate(); // forcefully activates
		void step();
		void deactivate();
		void addDelegate(LinkableDelegate del);
		void removeDelegate(LinkableDelegate del);
	}
}