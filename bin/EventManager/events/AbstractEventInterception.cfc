<!--- /*		
Project:     Cf Event Manager  http://code.google.com/p/cfeventmanager/
Author:      Andrea Campolonghi <andrea@getrailo.org>
Version:     1.0.1
Build Date:  sabato dic 19, 2009
Build:		 111

Copyright 2009 Andrea Campolonghi

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.	
			
*/--->

<cfcomponent implements="EventManager.util.IObserver" output="false">
	
	<cfset variables.instance = {}/>
	<cfset variables.instance.actions = createObject('java','java.util.ArrayList').init()/>

	<!---init--->
    <cffunction name="init" output="false" returntype="EventManager.events.AbstractEventInterception">
    	<cfargument name="eventManager" required="true" type="EventManager.eventManager"/>
    	<cfargument name="point" required="true" type="string"/>
		<cfargument name="conditions" required="false" type="string" default="true"/>
		
		<cfset setEventManager(arguments.eventManager)/>
		<cfset setpoint(arguments.point) />
		<cfset setCondition(arguments.conditions)/>
		
		<cfreturn this />
    </cffunction>

	<!--- PUBLIC ------------------------------------------------------------------------------------------->
	
	<!---addAction--->
    <cffunction name="addAction" output="false" access="public" returntype="void">
    	<cfargument name="action" required="true" type="EventManager.events.actions.AbstractAction" />
    	<cfset variables.instance.actions.add(action) />
    </cffunction>

	<!---runActions--->
    <cffunction name="runActions" output="false" access="public" returntype="void">
    	<cfargument name="event" type="EventManager.events.AbstractEvent" required="true" />
    	<cfset var iterator = variables.instance.actions.iterator() />
		<cfset var debug = getEventManager().getDebug() />
		<cfset var tracer = getEventManager().getTracer() />
		<cfset var action = "" />
    	<cfloop condition="#iterator.hasNext()#">
    		<cfset action = iterator.next() />
 			<cfif debug>
				<cfset tracer.trace('Running Action','<ul><li>Action #action.getName()#</li><li>Event : #arguments.event.getname()#</li>',arguments.event) />
			</cfif>       
			<cfset action.execute(arguments.event) />
		</cfloop>
    </cffunction>
		
    <!---   EventManager   --->
	<cffunction name="getEventManager" access="public" output="false" returntype="EventManager.EventManager">
		<cfreturn variables.instance.EventManager/>
	</cffunction>
	<cffunction name="setEventManager" access="public" output="false" returntype="void">
		<cfargument name="EventManager" type="EventManager.EventManager" required="true"/>
		<cfset variables.instance.EventManager = arguments.EventManager/>
	</cffunction>

    <!---   point   --->
	<cffunction name="getpoint" access="public" output="false" returntype="string">
		<cfreturn variables.instance.point/>
	</cffunction>
	<cffunction name="setpoint" access="public" output="false" returntype="void">
		<cfargument name="point" type="string" required="true"/>
		<cfif listFind(getEventManager().getConfig('eventInterceptionsPoints'),arguments.point) eq 0>
			<cfthrow type="EventManager.IllegalInterceptionPoint" message="point [#arguments.point#] is not valid. Add it to config xml file.">
		</cfif>
		<cfset variables.instance.point = arguments.point/>
	</cffunction>	
	
    <!---   condition   --->
	<cffunction name="getcondition" access="public" output="false" returntype="string">
		<cfreturn variables.instance.condition/>
	</cffunction>
	<cffunction name="setcondition" access="public" output="false" returntype="void">
		<cfargument name="condition" type="string" required="true"/>
		<cfset variables.instance.condition = arguments.condition/>
	</cffunction>

	<!--- ABSTRACT UPDATE METHOD --->
	<cffunction name="update" access="public" returntype="void">
		<cfargument name="event" type="EventManager.events.AbstractEvent" required="yes" />
		<cfthrow type="EventManager.AbstractMethodException" message="Abstract method [update] has not been implemented" />
	</cffunction>

	<!--- PRIVATE ------------------------------------------------------------------------------------------->

	<!---	isConditionTrue	--->
    <cffunction name="isConditionTrue" output="false" returntype="boolean" access="private">
    	<cfargument name="event" required="true" type="EventManager.events.Event" />
		<cfset var result = "" />
		<cfset var debug = getEventManager().getDebug() />
		<cfset var tracer = getEventManager().getTracer() />
		<cftry>
			<cfset result = evaluate(getCondition()) />
			<cfcatch type="any">            
				<cfthrow type="EventManager.ConditionEvaluationError" message="#cfcatch.message#" />
			</cfcatch>
		</cftry>
		<cfif debug>
			<cfset tracer.trace('Condition','<ul><li>Evaluated : #getCondition()#</li><li>Result : #result#</li></ul>',arguments.event) />
		</cfif>
	   	<cfreturn result />
    </cffunction>
		
</cfcomponent>