<!---
	Copyright 2009 Dominic Watson
	
	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
	http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
	
	http://lastfmapi.riaforge.org 
--->

<cfcomponent extends="base" output="false">

	<cffunction name="attend" access="public" returntype="boolean" output="false" hint="Set a user's attendance status for an event.">
		<cfargument name="event" type="numeric" required="true" hint="The numeric last.fm event id"/>
		<cfargument name="status" type="numeric" required="true" hint="The attendance status (0=Attending, 1=Maybe attending, 2=Not attending)" />
		<cfargument name="sessionKey" type="string" required="true" hint="Obtained from auth.getSessionKey. See Authentication documentation on official last.fm documentation" />
		
		<cfscript>
			var args = StructNew();
			
			args['event'] = arguments.event;
			args['status'] = arguments.status;
			
			super.callAuthenticatedMethod('event.attend', args, arguments.sessionKey, 'xml');
			
			return true;
		</cfscript>
	</cffunction> 
	
	<cffunction name="getInfo" access="public" returntype="struct" output="false" hint="Get the metadata for an event on Last.fm. Includes attendance and lineup information.">
		<cfargument name="event" type="numeric" required="true" hint="The numeric last.fm event id"/>
		
		<cfscript>
			var args = StructNew();
			var result = "";
			
			args['event'] = arguments.event;
			
			result = super.callMethod('event.getInfo', args);
			
			if(StructKeyExists(result, 'event')){
				if(StructKeyExists(result.event, 'image')){
					result.event.image = super.parseImages(result.event.image);
				}
				return result.event;
			} else {
				return StructNew();	
			}			
			
		</cfscript>
	</cffunction> 
	
	<cffunction name="getShouts" access="public" returntype="query" output="false" hint="Get shouts for this event. Also available as an rss feed.">
		<cfargument name="event" type="numeric" required="true" hint="The numeric last.fm event id"/>
		
		<cfscript>
			var args = StructNew();
			var returnQry = QueryNew('body,author,date');
			var results = "";
			var i = 0;
			
			args['event'] = arguments.event;
			results = super.CallMethod('event.getShouts', args);
			if(IsDefined('results.shouts.shout')){
				results = super.ensureArray(results.shouts.shout);
				for(i=1; i lTE ArrayLen(results); i=i+1){
					QueryAddRow(returnQry);
					QuerySetCell(returnQry, 'body', results[i].body);
					QuerySetCell(returnQry, 'author', results[i].author);
					QuerySetCell(returnQry, 'date', results[i].date);
				}
			}
			
			return returnQry;
		</cfscript>
	</cffunction>
		
	<cffunction name="share" access="public" returntype="boolean" output="false" hint="Share an event with one or more Last.fm users or other friends.">
		<cfargument name="event" type="numeric" required="true" hint="The numeric last.fm event id"/>
		<cfargument name="recipient" type="string" required="true" hint="Email Address | Last.fm Username - A comma delimited list of email addresses or Last.fm usernames. Maximum is 10." />
		<cfargument name="message" type="string" required="false" hint="An optional message to send with the recommendation. If not supplied a default message will be used." />
		<cfargument name="sessionKey" type="string" required="true" hint="Obtained from auth.getSessionKey. See Authentication documentation on official last.fm documentation" />
		
		<cfscript>
			var args = StructNew();
			
			args['event'] = arguments.event;
			args['recipient'] = arguments.recipient;
			if(StructKeyExists(arguments, 'message')){
				args['message'] = arguments.message;
			}
			
			super.callAuthenticatedMethod('event.share', args, arguments.sessionKey, 'xml');
			
			return true;
		</cfscript>
	</cffunction> 
</cfcomponent>