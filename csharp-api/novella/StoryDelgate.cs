using System.Collections.Generic;

namespace nv {
	public interface StoryDelgate {
		void storyEventNeedsDisabling(Story story, Event evt);
		void storyChainNeedsResolving(Story story, Chain chain, List<Link> links);
	}
}