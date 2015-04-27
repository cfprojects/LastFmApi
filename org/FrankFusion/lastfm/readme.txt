1. License
=================================================================================================================================

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
	

2. Contents
=================================================================================================================================

	1. License
	2. Contents
	3. Introduction (the last.fm api)
	4. Quick start guide
	5. Feedback


3. Intoduction (the Last.fm api)
=================================================================================================================================

	This set of components is a handy ColdFusion wrapper to the last.fm api. Full details of the api can
	found at:
	
	http://www.last.fm/api
	
	You will notice that there are quite a few components in this package but do not let that put you off!
	You only need to use one, lastFmApi.cfc. The reasons for this are two fold:
	
		1. 	There is a large number of api methods. I find that having cfcs with a small number of methods
			makes for more manageable code.
			
		2.	The method names that last.fm use take the form [class].[method], eg. artist.getTopAlbums(). By
			having a seperate cfc for each 'class', I can stick to their naming conventions*. So, with an 
			instance of the lastFmApi.cfc component called 'lastFm', we can do:
			
			<cfset albums = lastFm.artist.getTopAlbums('Bananarama') />

			This could be done using one component but doing so would obfuscate matters somewhat.
			
	
	* 	I had to break from their naming conventions for one method only, tasteometer.compare() because compare()
		is a ColdFusion function. I renamed it to tasteometer.tasteCompare().

4. Quick Start Guide
=================================================================================================================================
	
	1. 	Creating an instance of the component in application scope / coldspring
		-----------------------------------------------------------------------
	
		NOTE: 	the below examples are rough guides and intended for illustration purposes only. Also,
				while it is not strictly neccessary to load the component into your application scope,
				it is highly recommended that you do so to reduce the needless overhead of constantly
				instantiating the object.
	
		// ColdSpring config example
		<bean id="lastFm" class="org.FrankFusion.lastFm.lastFmApi">
			<constructor-arg name="key"><value>[your api key here]</value></constructor-arg>
			<constructor-arg name="secret"><value>[your api secret here]</value></constructor-arg>
		</bean>
		
		// Application.cfc example
		<cffunction name="onApplicationStart">
			<cfset var apiKey = '[your api key here]' />
			<cfset var apiSecret = '[your api secret here]' />
			
			<cfset application.lastFm = CreateObject('component', 'org.FrankFusion.lastFm.lastFmApi').init(apiKey, apiSecret) />
		</cffunction>
		
		// Application.cfm example 
		<cfif not StructKeyExists('application', 'lastFm')>
			<cfset variables.apiKey = '[your api key here]' />
			<cfset variables.apiSecret = '[your api secret here]' />
			
			<cfset application.lastFm = CreateObject('component', 'org.FrankFusion.lastFm.lastFmApi').init(apiKey, apiSecret) />
		</cfif>
	
	2.	Using the instance to call the api
		----------------------------------
		
		// application.cfc / application.cfm example (ie. loaded into the application scope as above)
		<cfset qAlbums = application.lastFm.user.getWeeklyAlbumChart('DomOfLondon') />
		
		// coldspring example
		<cfset qAlbums = coldspring.getBean('lastFm').user.getWeeklyAlbumChart('DomOfLondon') />
	
	
	3.	Authentication
		--------------
	
		To use any of the methods that require authentication, ie. playlist.create(), you will need a 
		lastFm session key for your user. Session keys are set to never expire until the user cancels your
		application's permission to access their profile - so you should only need to get a session key once, 
		and then store it somewhere appropriate, ie. your db.
		
		To get a session key for a user:
		
	`	a. 	Ensure you have the correct callback url setup in your lastFm api account, eg. http://myserver.com/?action=lastfm.authenticate
		
		b. 	Send the user to the url retrieved by the auth.getAuthUrl() method, ie. 
			
			<cflocation url="#application.lastFm.auth.getAuthUrl()#" addtoken="false" />
			
			This will send them to a confirmation page on the last.fm website. When the user completes 
			the authorization confirmation on the lastFm site, they will be	redirected to your callback url.
		
		c. 	If the user has granted your application access, a url variable, 'token', will be
			passed to your callback page. You can then use this token to generate the session
			key as follows:
			
			<cfset sessionKey = application.lastFm.auth.getSession(url.token) />
		
		d.	Store the session key and you are then free to use the methods that interact with
			the user's account, ie.
			
			<cfset newPlaylist = application.lastFm.playlist.create('Cool stuff','Songs at -3 degrees', sessionKey) />

5. Feedback
=================================================================================================================================

	If you have any feedback for the component, please direct it to the riaforge project page:
	
	http://lastfmapi.riaforge.org
	
	Enjoy!
	
	Dominic