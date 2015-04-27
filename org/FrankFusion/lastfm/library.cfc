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

	<cffunction name="addAlbum" access="public" returntype="boolean" output="false" hint="Add an album to a user's Last.fm library">
		<cfargument name="artist" type="string" required="true" hint="The artist that composed the album" />
		<cfargument name="album" type="string" required="true" hint="The album name you wish to add" />
		<cfargument name="sessionKey" type="string" required="true" hint="Obtained from auth.getSessionKey. See Authentication documentation on official last.fm documentation" />
		
		<cfscript>
			var args = StructNew();
			
			args['artist'] = arguments.artist;
			args['album'] = arguments.album;
			
			super.callAuthenticatedMethod('library.addAlbum', args, arguments.sessionKey, 'xml');
			
			return true;
		</cfscript>
	</cffunction> 
	
	<cffunction name="addArtist" access="public" returntype="boolean" output="false" hint="Add an artist to a user's Last.fm library">
		<cfargument name="artist" type="string" required="true" hint="The artist" />
		<cfargument name="sessionKey" type="string" required="true" hint="Obtained from auth.getSessionKey. See Authentication documentation on official last.fm documentation" />
		
		<cfscript>
			var args = StructNew();
			
			args['artist'] = arguments.artist;
			
			super.callAuthenticatedMethod('library.addArtist', args, arguments.sessionKey, 'xml');
			
			return true;
		</cfscript>
	</cffunction> 
	
	<cffunction name="addTrack" access="public" returntype="boolean" output="false" hint="Add a track to a user's Last.fm library">
		<cfargument name="artist" type="string" required="true" hint="The artist that composed the track" />
		<cfargument name="track" type="string" required="true" hint="The track name you wish to add" />
		<cfargument name="sessionKey" type="string" required="true" hint="Obtained from auth.getSessionKey. See Authentication documentation on official last.fm documentation" />
		
		<cfscript>
			var args = StructNew();
			
			args['artist'] = arguments.artist;
			args['track'] = arguments.track;
			
			super.callAuthenticatedMethod('library.addTrack', args, arguments.sessionKey, 'xml');
			
			return true;
		</cfscript>
	</cffunction> 
	
	<cffunction name="getAlbums" access="public" returntype="any" output="false" hint="A paginated list of all the albums in a user's library, with play counts and tag counts.">
		<cfargument name="user" type="string" required="true" hint="The user whose library you want to fetch." />
		<cfargument name="limit" type="numeric" required="false" default="20" hint="Limit the number of albums returned at one time. Default (maximum) is 50." />
		<cfargument name="page" type="numeric" required="false" default="1" hint="Scan into the results by specifying a page number. Defaults to first page." />

		<cfscript>
			var args = StructNew();
			var returnStruct = StructNew();
			var results = "";
			var i = 0;
			
			args['user'] = arguments.user;
			args['limit'] = arguments.limit;
			args['page'] = arguments.page;
			
			results = super.callMethod('library.getAlbums', args).albums;
			
			returnStruct['page'] = results.page;
			returnStruct['perPage'] = results.perPage;
			returnStruct['totalPages'] = results.totalPages;
			
			if(IsDefined('results.album')){
				results = super.ensureArray(results.album);
				returnStruct['results'] = QueryNew('artist,artistMbid,artistUrl,name,mbid,url,playcount,tagcount,smallImage,mediumImage,largeImage,extraLargeImage');

				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnStruct.results);
					QuerySetCell(returnStruct.results, 'artist', results[i].artist.name);
					QuerySetCell(returnStruct.results, 'artistMbid', results[i].artist.mbid);
					QuerySetCell(returnStruct.results, 'artistUrl', results[i].artist.url);
					QuerySetCell(returnStruct.results, 'name', results[i].name);
					QuerySetCell(returnStruct.results, 'mbid', results[i].mbid);
					QuerySetCell(returnStruct.results, 'url', results[i].url);
					QuerySetCell(returnStruct.results, 'playcount', results[i].playcount);
					QuerySetCell(returnStruct.results, 'tagcount', results[i].tagcount);
					
					if(StructKeyExists(results[i], 'image')){
						results[i].image = super.parseImages(results[i].image);
						QuerySetCell(returnStruct.results,'smallImage', results[i].image.small);
						QuerySetCell(returnStruct.results,'mediumImage', results[i].image.medium);
						QuerySetCell(returnStruct.results,'largeImage', results[i].image.large);
						QuerySetCell(returnStruct.results,'extraLargeImage', results[i].image.extraLarge);
					}
				}
			}
			
			return returnStruct;
		</cfscript>
	</cffunction> 
	
	<cffunction name="getArtists" access="public" returntype="any" output="false" hint="A paginated list of all the artists in a user's library, with play counts and tag counts.">
		<cfargument name="user" type="string" required="true" hint="The user whose library you want to fetch." />
		<cfargument name="limit" type="numeric" required="false" default="20" hint="Limit the number of albums returned at one time. Default (maximum) is 50." />
		<cfargument name="page" type="numeric" required="false" default="1" hint="Scan into the results by specifying a page number. Defaults to first page." />

		<cfscript>
			var args = StructNew();
			var returnStruct = StructNew();
			var results = "";
			var i = 0;
			
			args['user'] = arguments.user;
			args['limit'] = arguments.limit;
			args['page'] = arguments.page;
			
			results = super.callMethod('library.getArtists', args).artists;
			
			returnStruct['page'] = results.page;
			returnStruct['perPage'] = results.perPage;
			returnStruct['totalPages'] = results.totalPages;
			
			if(IsDefined('results.artist')){
				results = super.ensureArray(results.artist);
				returnStruct['results'] = QueryNew('name,playcount,tagcount,mbid,url,streamable,smallImage,mediumImage,largeImage,extraLargeImage');

				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnStruct.results);
					QuerySetCell(returnStruct.results, 'name', results[i].name);
					QuerySetCell(returnStruct.results, 'mbid', results[i].mbid);
					QuerySetCell(returnStruct.results, 'url', results[i].url);
					QuerySetCell(returnStruct.results, 'playcount', results[i].playcount);
					QuerySetCell(returnStruct.results, 'tagcount', results[i].tagcount);
					QuerySetCell(returnStruct.results, 'streamable', results[i].streamable);
					
					if(StructKeyExists(results[i], 'image')){
						results[i].image = super.parseImages(results[i].image);
						QuerySetCell(returnStruct.results,'smallImage', results[i].image.small);
						QuerySetCell(returnStruct.results,'mediumImage', results[i].image.medium);
						QuerySetCell(returnStruct.results,'largeImage', results[i].image.large);
						QuerySetCell(returnStruct.results,'extraLargeImage', results[i].image.extraLarge);
					}
				}
			}
			
			return returnStruct;
		</cfscript>
	</cffunction>
	
	<cffunction name="getTracks" access="public" returntype="any" output="false" hint="A paginated list of all the tracks in a user's library, with play counts and tag counts.">
		<cfargument name="user" type="string" required="true" hint="The user whose library you want to fetch." />
		<cfargument name="limit" type="numeric" required="false" default="20" hint="Limit the number of albums returned at one time. Default (maximum) is 50." />
		<cfargument name="page" type="numeric" required="false" default="1" hint="Scan into the results by specifying a page number. Defaults to first page." />

		<cfscript>
			var args = StructNew();
			var returnStruct = StructNew();
			var results = "";
			var i = 0;
			
			args['user'] = arguments.user;
			args['limit'] = arguments.limit;
			args['page'] = arguments.page;
			
			results = super.callMethod('library.getTracks', args).tracks;
			
			returnStruct['page'] = results.page;
			returnStruct['perPage'] = results.perPage;
			returnStruct['totalPages'] = results.totalPages;
			
			if(IsDefined('results.track')){
				results = super.ensureArray(results.track);
				returnStruct['results'] = QueryNew('artist,artistMbid,artistUrl,name,mbid,url,playcount,tagcount,streamable,smallImage,mediumImage,largeImage,extraLargeImage');

				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnStruct.results);
					QuerySetCell(returnStruct.results, 'artist', results[i].artist.name);
					QuerySetCell(returnStruct.results, 'artistMbid', results[i].artist.mbid);
					QuerySetCell(returnStruct.results, 'artistUrl', results[i].artist.url);
					QuerySetCell(returnStruct.results, 'name', results[i].name);
					QuerySetCell(returnStruct.results, 'mbid', results[i].mbid);
					QuerySetCell(returnStruct.results, 'url', results[i].url);
					QuerySetCell(returnStruct.results, 'playcount', results[i].playcount);
					QuerySetCell(returnStruct.results, 'tagcount', results[i].tagcount);
					QuerySetCell(returnStruct.results, 'streamable', results[i].streamable['##text']);
					
					if(StructKeyExists(results[i], 'image')){
						results[i].image = super.parseImages(results[i].image);
						QuerySetCell(returnStruct.results,'smallImage', results[i].image.small);
						QuerySetCell(returnStruct.results,'mediumImage', results[i].image.medium);
						QuerySetCell(returnStruct.results,'largeImage', results[i].image.large);
						QuerySetCell(returnStruct.results,'extraLargeImage', results[i].image.extraLarge);
					}
				}
			}
			
			return returnStruct;
		</cfscript>
	</cffunction> 
	
</cfcomponent>