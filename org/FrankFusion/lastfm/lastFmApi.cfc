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

<cfcomponent output="false" hint="Container component of all the sub last fm components. Could easily be tweaked to contain only the components that you use">
	
	<cffunction name="init" access="public" returntype="lastFmApi" output="false">
		<cfargument name="key" type="string" required="true" />
		<cfargument name="secret" type="string" required="true" />
		<cfargument name="timeout" type="numeric" required="false" default="30">
		<cfargument name="apiUrl" type="string" required="false" default="http://ws.audioscrobbler.com/2.0/" hint="Perhaps there will be various versions of the api with different urls. Hence the inclusion of this as an argument." />
		<cfargument name="authUrl" type="string" required="false" default="http://www.last.fm/api/auth/" hint="Url for authorizing users" />
		
		<cfscript>
			// deliberate use of the this scope. Allows for the use of the same syntax as last.fm's api
			// eg: album = lastFm.album.getInfo(albumname);
			
			this.album = CreateObject('component', 'album').init( arguments.key, arguments.secret, arguments.timeout, arguments.apiUrl, arguments.authUrl );
			this.artist = CreateObject('component', 'artist').init( arguments.key, arguments.secret, arguments.timeout, arguments.apiUrl, arguments.authUrl );
			this.auth = CreateObject('component', 'auth').init( arguments.key, arguments.secret, arguments.timeout, arguments.apiUrl, arguments.authUrl );
			this.event = CreateObject('component', 'event').init( arguments.key, arguments.secret, arguments.timeout, arguments.apiUrl, arguments.authUrl );
			this.geo = CreateObject('component', 'geo').init( arguments.key, arguments.secret, arguments.timeout, arguments.apiUrl, arguments.authUrl );
			this.group = CreateObject('component', 'group').init( arguments.key, arguments.secret, arguments.timeout, arguments.apiUrl, arguments.authUrl );
			this.library = CreateObject('component', 'library').init( arguments.key, arguments.secret, arguments.timeout, arguments.apiUrl, arguments.authUrl );
			this.playlist = CreateObject('component', 'playlist').init( arguments.key, arguments.secret, arguments.timeout, arguments.apiUrl, arguments.authUrl );
			this.tag = CreateObject('component', 'tag').init( arguments.key, arguments.secret, arguments.timeout, arguments.apiUrl, arguments.authUrl );
			this.tasteometer = CreateObject('component', 'tasteometer').init( arguments.key, arguments.secret, arguments.timeout, arguments.apiUrl, arguments.authUrl );
			this.track = CreateObject('component', 'track').init( arguments.key, arguments.secret, arguments.timeout, arguments.apiUrl, arguments.authUrl );
			this.user = CreateObject('component', 'user').init( arguments.key, arguments.secret, arguments.timeout, arguments.apiUrl, arguments.authUrl );
			this.venue = CreateObject('component', 'venue').init( arguments.key, arguments.secret, arguments.timeout, arguments.apiUrl, arguments.authUrl );
			
			return this;
		</cfscript>
	</cffunction>
		
</cfcomponent>