<cfcomponent name="Dispatcher">

	<!--- Constructor --->
	<cffunction name="init" output="false" returntype="com.andreacfm.cfem.dispatch.Dispatcher">
		<cfargument name="EventManager" type="com.andreacfm.cfem.EventManager" required="true" />
		<cfargument name="event" type="com.andreacfm.cfem.events.AbstractEvent" required="true"/>
		<cfscript>
		setEventManager(arguments.EventManager);
		setEvent(arguments.event);
		</cfscript>
		<cfreturn this />
	</cffunction>
	
	<!--- Dispatch --->
	<cffunction name="dispatch" returntype="void" output="false">
		<cfscript>
		var i = 0;
		var local = {};		
		local.event = getEvent();
		local.em = getEventManager();
		local.listeners = local.em.getListeners(local.event.getName());
		local.debug = local.em.getDebug();
		local.tracer = local.em.getTracer();

		for(i=1; i lte arraylen(local.listeners); i++){
			if(local.event.isActive()){
				
				/* lazy autowiring if needed*/
				if(local.listeners[i].getAutowire()){
					if(not local.listeners[i].isautowired()){
						local.em.getBeanFactory().getBean('beanInjector').autowire(local.listeners[i].listener);
					}
					local.listeners[i].setAutowired(true);
				}
				
				if(i==1){
					local.event.updatePoint('before');
				}
				if(local.debug){
					local.tracer.trace("Interception","<ul><li>Point : Before</li><li>Event : #local.event.getname()#</li></ul>",local.event);
				}		
				
				// call the listener
				local.listeners[i].execute(local.event);
				
				local.event.updatePoint('each');
				if(local.em.getDebug()){
					local.em.getTracer().trace('Interception',"<ul><li>Point : Each</li><li>Event : #local.event.getname()#</li></ul>",local.event);
					if(local.debug){
						local.tracer.trace('Invoke Listener','Listener #local.listObj.getClass()#',local.event);
					}		
				}		
				if(i==arraylen(local.listeners)){
					local.event.updatePoint('after');
					if(local.debug){
						local.tracer.trace('Interception','<ul><li>Point : After</li><li>Event : #local.event.getname()#</li></ul>',local.event);
					}		
				}
			}
		}
		</cfscript>				
	</cffunction>
   
    <!---   event   --->
	<cffunction name="getevent" access="public" output="false" returntype="com.andreacfm.cfem.events.AbstractEvent">
		<cfreturn variables.instance.event/>
	</cffunction>
	<cffunction name="setevent" access="public" output="false" returntype="void">
		<cfargument name="event" type="com.andreacfm.cfem.events.AbstractEvent" required="true"/>
		<cfset variables.instance.event = arguments.event/>
	</cffunction>

    <!---   EventManager   --->
	<cffunction name="getEventManager" access="public" output="false" returntype="com.andreacfm.cfem.EventManager">
		<cfreturn variables.instance.EventManager/>
	</cffunction>
	<cffunction name="setEventManager" access="public" output="false" returntype="void">
		<cfargument name="EventManager" type="com.andreacfm.cfem.EventManager" required="true"/>
		<cfset variables.instance.EventManager = arguments.EventManager/>
	</cffunction>


</cfcomponent>
