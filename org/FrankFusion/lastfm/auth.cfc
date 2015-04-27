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

	<cffunction name="getSession" access="public" returntype="struct" hint="Fetch a session key for a user. The third step in the authentication process. See the authentication how-to for more information.">
		<cfargument name="token" type="string" required="true" />
		
		<cfscript>
			var args = StructNew();
			var result = "";
			args['token'] = arguments.token;
			
			result = super.callAuthenticatedMethod('auth.getSession', args);
			if(StructKeyExists(result, 'session')){
				return result.session;
			}
			
			return StructNew();
		</cfscript>
	</cffunction>
	
	<cffunction name="getAuthUrl" access="public" returntype="string" hint="Returns url to locate users for web authentication (this method is not in the api but a utility method for authorization)">
		<cfreturn "#_authUrl#?api_key=#_key#">
	</cffunction>
	
</cfcomponent>