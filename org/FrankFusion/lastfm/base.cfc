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

<cfcomponent output="false" hint="LastFmApi base component. There are so many areas of the api that I have decided to break out into child components for the various method areas.">

<!--- properties --->
	<cfset variables._key = "" />
	<cfset variables._secret = "" />	
	<cfset variables._apiUrl = "" />
	<cfset variables._authUrl = "" />
	<cfset variables._timeout = "" />
	<cfset variables._json = CreateObject('component', 'jsonUtil')>
	
<!--- constructor --->
	<cffunction name="init" access="public" returntype="base" output="false">
		<cfargument name="key" type="string" required="true" />
		<cfargument name="secret" type="string" required="true" />
		<cfargument name="timeout" type="numeric" required="false" default="30">
		<cfargument name="apiUrl" type="string" required="false" default="http://ws.audioscrobbler.com/2.0/" hint="Perhaps there will be various versions of the api with different urls. Hence the inclusion of this as an argument." />
		<cfargument name="authUrl" type="string" required="false" default="http://www.last.fm/api/auth/" hint="Url for authorizing users" />
		
		<cfscript>
			_key = arguments.key;
			_secret = arguments.secret;
			_apiUrl = arguments.apiUrl;
			_authUrl = arguments.authUrl;
			_timeout = arguments.timeout;
			
			return this;
		</cfscript>
	</cffunction>

<!--- generic / utility --->
	<cffunction name="callMethod" access="private" returntype="any" output="false">
		<cfargument name="methodName" type="string" required="true" />
		<cfargument name="args" type="struct" required="false" default="#StructNew()#" />
		<cfargument name="method" type="string" required="false" default="get" />
		<cfargument name="format" type="string" required="false" default="json" />
		
		<cfset var result = "" />
		<cfset var arg = "" />

		<cfhttp url="#_apiUrl#" method="#iif(method EQ 'post', DE('post'), DE('get'))#" charset="utf-8" result="result" timeout="#_timeout#">
			<cfhttpparam type="url" name="method" value="#arguments.methodName#" />
			<cfif arguments.format EQ 'json'><!--- this seems odd but passing 'xml' causes error - passing nothing gives you back xml --->
				<cfhttpparam type="url" name="format" value="#arguments.format#" />
			</cfif>
			<cfhttpparam type="url" name="api_key" value="#_key#" />
			<cfloop collection="#arguments.args#" item="arg">
				<cfhttpparam  type="url" name="#arg#" value="#arguments.args[arg]#" />
			</cfloop>
		</cfhttp>		
		
		<cfswitch expression="#arguments.format#">
			<cfcase value="json">
				<!--- deserialize result --->
				<cftry>
					<cfset result = _json.deserialize(result.filecontent) />
					<cfcatch>
						<cfdump var="#result#"/><cfabort/>
					</cfcatch>
				</cftry>
				
				<!--- throw any result errors ---> 
				<cfif StructKeyExists(result, 'error')>
					<cfparam name="result.message" default="" />
					<cfthrow type="org.FrankFusion.lastFm.lastFmApi" message="Error calling lastFm api" detail="#result.message#" errorcode="#Val(result.error)#" />
				</cfif>
				
				<!--- return our serialized result (should be a handy cf struct or array) --->
				<cfreturn result />
			</cfcase>
			
			<cfcase value="xml">
				<cftry>
					<cfset result = XmlParse(result.filecontent) />
					<cfcatch>
						<cfdump var="#result#"/><cfabort/>
					</cfcatch>
				</cftry>
				
				<!--- throw any result errors ---> 
				<cfif result.lfm.xmlAttributes.status EQ 'failed'>
					<cfthrow type="org.FrankFusion.lastFm.lastFmApi" message="Error calling lastFm api" detail="#result.lfm.error.xmlText#" errorcode="#Val(result.lfm.error.xmlAttributes.code)#" />
				</cfif>
				
				<!--- return xml object --->
				<cfreturn result />
			</cfcase>
		
			<cfdefaultcase>
				<!--- return requested file content --->
				<cfreturn result.filecontent />
			</cfdefaultcase>
		</cfswitch>
		
		
		
		
		
	</cffunction>
	
	<cffunction name="callAuthenticatedMethod" access="private" returntype="any" output="false">
		<cfargument name="methodName" type="string" required="true" />
		<cfargument name="args" type="struct" required="false" default="#StructNew()#" />
		<cfargument name="sessionKey" type="string" required="false" hint="We need to use this method to GET our session key. All other uses of the method require a session key">
		<cfargument name="format" type="string" required="false" default="json">
		

		<cfset arguments.args['api_sig'] = generateAuthHash(argumentCollection=arguments) />

		<cfreturn callMethod(arguments.methodName, arguments.args, 'post', arguments.format) />
	</cffunction>
	
	<cffunction name="generateAuthHash" access="private" returntype="string" output="false">
		<cfargument name="methodName" type="string" required="true" />
		<cfargument name="args" type="struct" required="false" default="#StructNew()#" />
		<cfargument name="sessionKey" type="string" required="false" hint="We need to use this method to GET our session key. All other uses of the method require a session key">
		
		<cfscript>
			var argArray = "";
			var str = "";
			var i = 0;
			
			arguments.args['api_key'] = _key;
			arguments.args['method'] = arguments.methodName;
			if(StructKeyExists(arguments, 'sessionKey')){
				arguments.args['sk'] = arguments.sessionKey;
			}
			
			argArray = StructKeyArray(args);
			ArraySort(argArray,'TextNoCase');
			
			for(i=1; i LTE ArrayLen(argArray); i=i+1){
				str = str & argArray[i] & args[argArray[i]];
			}
			
			return LCase(Hash( str & _secret ));
		</cfscript>
	</cffunction>
	
	<cffunction name="parseImages" access="private" returntype="struct" output="false" hint="Image sets come back in a funky array format from the api - this little utility method puts them in a consistent struct with small, medium, large and extraLarge keys">
		<cfargument name="images" type="any" required="true" />
		
		<cfscript>
			var returnStruct = StructNew();
			var i = 0;
			
			returnStruct['small'] = "";
			returnStruct['medium'] = "";
			returnStruct['large'] = "";
			returnStruct['extraLarge'] = "";
			
			for(i=1; i LTE ArrayLen(arguments.images); i=i+1){
				
				if(StructKeyExists(images[i], 'size') AND ListFind('small,medium,large,extralarge', images[i].size)){
					returnStruct[images[i].size] = images[i]['##text'];				
				} else if(StructKeyExists(images[i], 'xmlAttributes') AND StructKeyExists(images[i].xmlAttributes, 'size') AND ListFind('small,medium,large,extralarge', images[i].xmlAttributes.size)){
					returnStruct[images[i].xmlAttributes.size] = images[i].xmlText;	
				}
			}
			
			return returnStruct;
		</cfscript>
	</cffunction>

	<cffunction name="ensureArray" access="private" returntype="array" output="false" hint="In cases where there is only a single result, instead of an array object, we are passed back a struct. This method ensures we always have an array.">
		<cfargument name="data" type="any" required="true" />
		
		<cfscript>
			var arr = ArrayNew(1);
			
			if(IsArray(arguments.data)){
				return arguments.data;
			}
			
			ArrayAppend(arr, arguments.data);
				
			return arr;
		</cfscript>
	</cffunction>

	<cffunction name="encodeUnixTimestamp" access="private" returntype="numeric" output="false" hint="Utility function to encode a date as unix timestamp">
		<cfargument name="theDate" type="date" required="true" />
		
		<cfreturn DateDiff("s", CreateDate(1970,1,1), arguments.theDate)>
	</cffunction>
	
	<cffunction name="decodeUnixTimestamp" access="private" returntype="numeric" output="false" hint="Utility function to decode a unix timestamp as a cf date">
		<cfargument name="timestamp" type="numeric" required="true" />
		
		<cfreturn DateAdd("s", arguments.timestamp, CreateDate(1970,1,1)) />
	</cffunction>


</cfcomponent>