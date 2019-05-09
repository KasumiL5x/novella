using System;
using System.Linq;
using System.Collections.Generic;
using NLua;

namespace nv {
    public class Story {
        private LuaSession _luaSession;
        public LuaSession Lua {
            get{ return _luaSession; }
        }
        LuaHelper _luaHelper;

        List<Identifiable> _identifiables;
        public List<Group> Groups {
            get{ return _identifiables.OfType<Group>().ToList(); }
        }
        public List<Sequence> Sequences {
            get{ return _identifiables.OfType<Sequence>().ToList(); }
        }
        public List<Discoverable> Discoverables {
            get{ return _identifiables.OfType<Discoverable>().ToList(); }
        }
        public List<Event> Events {
            get{ return _identifiables.OfType<Event>().ToList(); }
        }
        public List<Function> Functions {
            get{ return _identifiables.OfType<Function>().ToList(); }
        }
        public List<Condition> Conditions  {
            get{ return _identifiables.OfType<Condition>().ToList(); }
        }
        public List<Selector> Selectors  {
            get{ return _identifiables.OfType<Selector>().ToList(); }
        }
        public List<Link> Links  {
            get{ return _identifiables.OfType<Link>().ToList(); }
        }
        public List<Variable> Variables  {
            get{ return _identifiables.OfType<Variable>().ToList(); }
        }
        public List<Hub> Hubs  {
            get{ return _identifiables.OfType<Hub>().ToList(); }
        }
        public List<Return> Returns  {
            get{ return _identifiables.OfType<Return>().ToList(); }
        }
        public List<Entity> Entities {
            get{ return _identifiables.OfType<Entity>().ToList(); }
        }

        Group _mainGroup;
        public Group MainGroup {
            get{ return _mainGroup; }
        }

        List<StoryDelgate> _delegates;
        public List<StoryDelgate> Delegates {
            get{ return _delegates; }
        }

        public Story() {
            this._luaSession = new LuaSession();
            this._luaHelper = new LuaHelper(this);
            //
            this._identifiables = new List<Identifiable>();
            this._delegates = new List<StoryDelgate>();
            //
            this._mainGroup = makeGroup();
            this._mainGroup.Label = "MainGroup";
            this._mainGroup.MaxActivations = 0;

            this._luaHelper.setup(this._luaSession);
            this._luaSession.loadCLR();
            // _luaSession.Lua.RegisterFunction("test", _luaHelper, _luaHelper.GetType().GetMethod("test"));

            // _lua.RegisterFunction("outputString", this, this.GetType().GetMethod("outputString"));
            // _lua.DoString("outputString(\"Hello, world!\")");

            Console.WriteLine("Novella initialized.");
        }

        public void addDelegate(StoryDelgate del) {
            _delegates.Add(del);
        }
        public void removeDelegate(StoryDelgate del) {
            _delegates.Remove(del);
        }

        public bool isVariableNameTaken(string name) {
            return Variables.Where(v => v.Name == name).Count() != 0;
        }

        public List<Link> getValidOutputsFor(Linkable obj) {
            var result = new List<Link>();

            foreach(var link in Links) {
                if(link.Origin == obj) {
                    if(null == link.Condition || link.Condition.evaluate()) {
                        result.Add(link);
                    }
                }
            }

            return result;
        }

        // SIMULATION
        public void start() {
            _mainGroup.activate();
        }

        public void step() {
            _mainGroup.step();
        }

        public void stop() {
            _mainGroup.deactivate();
        }

        void reset() {
        }

        // CREATION
        public Group makeGroup(Guid? id=null) {
            var group = new Group(id.HasValue ? id.Value : Guid.NewGuid(), this);
            _identifiables.Add(group);

            Lua.Lua[group.ID.toVariableName()] = group;
            
            // Console.WriteLine(String.Format("Created Group ({0}).", group.ID.ToString()));
            return group;
        }

        public Sequence makeSequence(Guid? id=null) {
            var sequence = new Sequence(id.HasValue ? id.Value : Guid.NewGuid(), this);
            _identifiables.Add(sequence);

            Lua.Lua[sequence.ID.toVariableName()] = sequence;

            // Console.WriteLine(String.Format("Created Sequence ({0}).", sequence.ID.ToString()));
            return sequence;
        }

        public Discoverable makeDiscoverable(Guid? id=null) {
            var discoverable = new Discoverable(id.HasValue ? id.Value : Guid.NewGuid(), this);
            _identifiables.Add(discoverable);

            Lua.Lua[discoverable.ID.toVariableName()] = discoverable;

            // Console.WriteLine(String.Format("Created Discoverable ({0}).", discoverable.ID.ToString()));
            return discoverable;
        }

        public Event makeEvent(Guid? id=null) {
            var evt = new Event(id.HasValue ? id.Value : Guid.NewGuid(), this);
            _identifiables.Add(evt);

            Lua.Lua[evt.ID.toVariableName()] = evt;

            // Console.WriteLine(String.Format("Created Event ({0}).", evt.ID.ToString()));
            return evt;
        }

        public Function makeFunction(Guid? id=null) {
            var function = new Function(id.HasValue ? id.Value : Guid.NewGuid(), _luaSession);
            _identifiables.Add(function);

            // Console.WriteLine(String.Format("Created Function ({0}).", function.ID.ToString()));
            return function;
        }

        public Condition makeCondition(Guid? id=null) {
            var condition = new Condition(id.HasValue ? id.Value : Guid.NewGuid(), _luaSession);
            _identifiables.Add(condition);

            // Console.WriteLine(String.Format("Created Condition ({0}).", condition.ID.ToString()));
            return condition;
        }

        public Selector makeSelector(Guid? id=null) {
            var selector = new Selector(id.HasValue ? id.Value : Guid.NewGuid(), _luaSession);
            _identifiables.Add(selector);

            // Console.WriteLine(String.Format("Created Selector ({0}).", selector.ID.ToString()));
            return selector;
        }

        public Link makeLink(Linkable origin, Linkable destination, Guid? id=null) {
            var link = new Link(id.HasValue ? id.Value : Guid.NewGuid(), origin, destination);
            _identifiables.Add(link);

            // Console.WriteLine(String.Format("Created Link ({0}).", link.ID.ToString()));
            return link;
        }

        public Entity makeEntity(Guid? id=null) {
            var entity = new Entity(id.HasValue ? id.Value : Guid.NewGuid());
            _identifiables.Add(entity);

            Lua.Lua[entity.ID.toVariableName()] = entity;

            // Console.WriteLine(String.Format("Created Entity ({0}).", entity.ID.ToString()));
            return entity;
        }

        public Variable makeVariable(Guid? id=null) {
            var variable = new Variable(id.HasValue ? id.Value : Guid.NewGuid(), this);
            _identifiables.Add(variable);

            Lua.Lua[variable.ID.toVariableName()] = variable;

            // Console.WriteLine(String.Format("Created Variable ({0}).", variable.ID.ToString()));
            return variable;
        }

        public Hub makeHub(Guid? id=null) {
            var hub = new Hub(id.HasValue ? id.Value : Guid.NewGuid());
            _identifiables.Add(hub);

            // Console.WriteLine(String.Format("Created Hub ({0}).", hub.ID.ToString()));
            return hub;
        }

        public Return makeReturn(Guid? id=null) {
            var rtrn = new Return(id.HasValue ? id.Value : Guid.NewGuid());
            _identifiables.Add(rtrn);

            // Console.WriteLine(String.Format("Created Return ({0}).", rtrn.ID.ToString()));
            return rtrn;
        }
    }
}