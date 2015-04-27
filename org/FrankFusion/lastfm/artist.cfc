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

<cfcomponent extends="base" output="false" hint="Extends the lastFmApiBase.cfc base component. See parent component for properties and constructor">
	
	<cffunction name="addTags" access="public" returntype="boolean" output="false" hint="Tag an artist using a list of user supplied tags. Returns true on success - throws the lastFM error on failure.">
		<cfargument name="artist" type="string" required="true" />
		<cfargument name="tags" type="string" required="true" />
		<cfargument name="sessionKey" type="string" required="true" hint="Obtained from auth.getSessionKey. See Authentication documentation on official last.fm documentation" />
		
		<cfscript>
			var args = StructNew();
			
			args['artist'] = arguments.artist;
			args['tags'] = arguments.tags;
			
			super.callAuthenticatedMethod('artist.addTags', args, arguments.sessionKey, 'xml');
			
			return true;
		</cfscript>
	</cffunction> 
	
	<cffunction name="getEvents" access="public" returntype="array" output="false" hint="Get a list of upcoming events for this artist. Easily integratable into calendars, using the ical standard">
		<cfargument name="artist" type="string" required="true" />
		
		<cfscript>
			var args = StructNew();
			var results = "";
			var i = 0;
			
			args['artist'] = arguments.artist;
			
			results = super.CallMethod('artist.getEvents', args);
			
			if(StructKeyExists(results, 'events') AND StructKeyExists(results.events, 'event')){
				results = super.ensureArray(results.events.event);
				for(i=1; i LTE ArrayLen(results); i=i+1){
					if(StructKeyExists(results[i], 'image')){
						results[i].image = super.parseImages(results[i].image);
					}
				}
				return results;
			} else {
				return ArrayNew(1);
			}
		</cfscript>
	</cffunction> 

	<cffunction name="getInfo" access="public" returntype="struct" output="false" hint="Get the metadata for an artist on Last.fm using the album name or a musicbrainz id. See playlist.fetch on how to get the album playlist.">
		<cfargument name="artist" type="string" required="false" />
		<cfargument name="mbid" type="string" required="false" hint="Musicbrainz id of the artist" />
		<cfargument name="lang" type="string" required="false" hint="The language to return the biography in, expressed as an ISO 639 alpha-2 code." />
		
		<cfscript>
			var args = StructNew();
			var result = "";
			var similar = "";
			var artists = "";
			var i = 0;
			
			if(StructKeyExists(arguments, 'artist')){
				args['artist'] = arguments.artist;
			}
			if(StructKeyExists(arguments, 'mbid')){
				args['mbid'] = arguments.mbid;
			}
			if(StructKeyExists(arguments, 'lang')){
				args['lang'] = arguments.lang;
			}
			
			result = super.CallMethod('artist.getInfo', args);
			if(not StructKeyExists(result, 'artist')){
				return StructNew();
			} else {
				result = result.artist;
			}
			
			if(StructKeyExists(result,'image')){
				result.image = super.parseImages(result.image);
			}
			if(StructKeyExists(result,'similar') AND StructKeyExists(result.similar, 'artist')){
				similar = QueryNew('name,url,smallImage,mediumImage,largeImage,extraLargeImage');
				artists = result.similar.artist;
				for(i=1; i LTE ArrayLen(artists); i=i+1){
					
					artists[i].image = super.parseImages(artists[i].image);
					
					QueryAddRow(similar);
					QuerySetCell(similar,'name', artists[i].name);
					QuerySetCell(similar,'url', artists[i].url);
					QuerySetCell(similar,'smallImage', artists[i].image.small);
					QuerySetCell(similar,'mediumImage', artists[i].image.medium);
					QuerySetCell(similar,'largeImage', artists[i].image.large);
					QuerySetCell(similar,'extraLargeImage', artists[i].image.extraLarge);
				}
				
				result.similar = similar;
			}
			
			return result;
		</cfscript>
	</cffunction> 
	
	<cffunction name="getShouts" access="public" returntype="query" output="false" hint="Get shouts for this artist.">
		<cfargument name="artist" type="string" required="true" />
		
		<cfscript>
			var args = StructNew();
			var returnQry = QueryNew('body,author,date');
			var results = "";
			var i = 0;
			
			args['artist'] = arguments.artist;
			results = super.CallMethod('artist.getShouts', args);
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
	
	<cffunction name="getSimilar" access="public" returntype="any" output="false" hint="Get all the artists similar to this artist.">
		<cfargument name="artist" type="string" required="true" />
		<cfargument name="limit" type="numeric" required="false" hint="Limit the number of similar artists returned" />
		
		<cfscript>
			var args = StructNew();
			var returnQry = QueryNew('name,mbid,match,url,smallImage,mediumImage,largeImage,extraLargeImage,streamable');
			var results = "";
			var images = "";
			var i = 0;
			
			args['artist'] = arguments.artist;
			if(StructKeyExists(arguments, 'limit')){
				args['limit'] = arguments.artist;
			}
			
			results = super.CallMethod('artist.getSimilar', args, 'get', 'xml'); // the getSimilar method doesn't work with json!
			
			if(IsDefined('results.lfm.similarartists.artist')){
				results = super.ensureArray(results.lfm.similarartists.artist);
				for(i=1; i lTE ArrayLen(results); i=i+1){
					
					QueryAddRow(returnQry);
					QuerySetCell(returnQry, 'name', results[i].name.xmlText);
					QuerySetCell(returnQry, 'mbid', results[i].mbid.xmlText);
					QuerySetCell(returnQry, 'match', results[i].match.xmlText);
					QuerySetCell(returnQry, 'url', results[i].url.xmlText);
					
					if(StructKeyExists(results[i], 'image')){
						images = super.parseImages(results[i].image);
						QuerySetCell(returnQry,'smallImage', images.small);
						QuerySetCell(returnQry,'mediumImage', images.medium);
						QuerySetCell(returnQry,'largeImage', images.large);
						QuerySetCell(returnQry,'extraLargeImage', images.extraLarge);
					}
				}
			}
			
			return returnQry;
		</cfscript>
	</cffunction>
	
	<cffunction name="getTags" access="public" returntype="query" output="false" hint="Get the tags applied by an individual user to an artist on Last.fm. ">
		<cfargument name="artist" type="string" required="true" />
		<cfargument name="sessionKey" type="string" required="true" hint="Obtained from auth.getSessionKey. See Authentication documentation on official last.fm documentation" />
		
		<cfscript>
			var args = StructNew();
			var returnQry = QueryNew('name,url');
			var results = "";
			var i = 0;
			
			args['artist'] = arguments.artist;
			
			results = super.callAuthenticatedMethod('artist.getTags', args, arguments.sessionKey);
			if(IsDefined('results.tags.tag')){
				results = super.ensureArray(results.tags.tag);
			
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnQry);
					QuerySetCell(returnQry,'name', results[i].name);
					QuerySetCell(returnQry,'url', results[i].url);
				}
			}
			
			return returnQry;
		</cfscript>
	</cffunction>
	
	<cffunction name="getTopAlbums" access="public" returntype="query" output="false" hint="Get the top albums for an artist on Last.fm, ordered by popularity.">
		<cfargument name="artist" type="string" required="true" />
		
		<cfscript>
			var args = StructNew();
			var returnQry = QueryNew('name,mbid,url,smallImage,mediumImage,largeImage,extraLargeImage');
			var results = "";
			var i = 0;
			
			args['artist'] = arguments.artist;
			
			results = super.CallMethod('artist.getTopAlbums', args);
			
			if(IsDefined('results.topalbums.album')){
				results = super.ensureArray(results.topalbums.album);
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnQry);
					QuerySetCell(returnQry,'name', results[i].name);
					QuerySetCell(returnQry,'mbid', results[i].mbid);			
					QuerySetCell(returnQry,'url', results[i].url);
					if(StructKeyExists(results[i], 'image')){
						results[i].image = super.parseImages(results[i].image);
						QuerySetCell(returnQry,'smallImage', results[i].image.small);
						QuerySetCell(returnQry,'mediumImage', results[i].image.medium);
						QuerySetCell(returnQry,'largeImage', results[i].image.large);
						QuerySetCell(returnQry,'extraLargeImage', results[i].image.extraLarge);
					}
				}
			}
			
			return returnQry;
			
		</cfscript>
	</cffunction>
	
	<cffunction name="getTopFans" access="public" returntype="query" output="false" hint="Get the top fans for an artist on Last.fm, based on listening data.">
		<cfargument name="artist" type="string" required="true" />
		
		<cfscript>
			var args = StructNew();
			var returnQry = QueryNew('name,url,smallImage,mediumImage,largeImage,extraLargeImage,weight');
			var results = "";
			var i = 0;
			
			args['artist'] = arguments.artist;
			
			results = super.CallMethod('artist.getTopFans', args);
			
			if(IsDefined('results.topfans.user')){
				results = super.ensureArray(results.topfans.user);
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnQry);
					QuerySetCell(returnQry,'name', results[i].name);
					QuerySetCell(returnQry,'url', results[i].url);
					if(StructKeyExists(results[i], 'image')){
						results[i].image = super.parseImages(results[i].image);
						QuerySetCell(returnQry,'smallImage', results[i].image.small);
						QuerySetCell(returnQry,'mediumImage', results[i].image.medium);
						QuerySetCell(returnQry,'largeImage', results[i].image.large);
						QuerySetCell(returnQry,'extraLargeImage', results[i].image.extraLarge);
					}
				}
			}
			
			return returnQry;
		</cfscript>
	</cffunction>
	
	<cffunction name="getTopTags" access="public" returntype="query" output="false" hint="Get the top tags for an artist on Last.fm, ordered by popularity.">
		<cfargument name="artist" type="string" required="true" />
		
		<cfscript>
			var args = StructNew();
			var returnQry = QueryNew('name,url');
			var results = "";
			var i = 0;
			
			args['artist'] = arguments.artist;
			
			results = super.CallMethod('artist.getTopTags', args);
			
			if(IsDefined('results.toptags.tag')){
				results = super.ensureArray(results.toptags.tag);
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnQry);
					QuerySetCell(returnQry,'name', results[i].name);
					QuerySetCell(returnQry,'url', results[i].url);
				}
			}
			return returnQry;
		</cfscript>
	</cffunction>
	
	<cffunction name="getTopTracks" access="public" returntype="query" output="false" hint="Get the top tracks by an artist on Last.fm, ordered by popularity">
		<cfargument name="artist" type="string" required="true" />
		
		<cfscript>
			var args = StructNew();
			var returnQry = QueryNew('name,mbid,playcount,url,smallImage,mediumImage,largeImage,extraLargeImage');
			var results = "";
			var i = 0;
			
			args['artist'] = arguments.artist;
			
			results = super.CallMethod('artist.getTopTracks', args);
			
			if(IsDefined('results.toptracks.track')){
				results = super.ensureArray(results.toptracks.track);
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnQry);
					QuerySetCell(returnQry,'name', results[i].name);
					QuerySetCell(returnQry,'mbid', results[i].mbid);
					QuerySetCell(returnQry,'playcount', results[i].playcount);		
					QuerySetCell(returnQry,'url', results[i].url);
					
					if(StructKeyExists(results[i], 'image')){
						results[i].image = super.parseImages(results[i].image);
						QuerySetCell(returnQry,'smallImage', results[i].image.small);
						QuerySetCell(returnQry,'mediumImage', results[i].image.medium);
						QuerySetCell(returnQry,'largeImage', results[i].image.large);
						QuerySetCell(returnQry,'extraLargeImage', results[i].image.extraLarge);
					}
				}
			}
			
			return returnQry;
		</cfscript>
	</cffunction>
	
	<cffunction name="removeTag" access="public" returntype="boolean" output="false" hint="Remove a user's tag from an artist. Returns true on success - throws the lastFM error on failure.">
		<cfargument name="artist" type="string" required="true" />
		<cfargument name="tag" type="string" required="true" />
		<cfargument name="sessionKey" type="string" required="true" hint="Obtained from auth.getSessionKey. See Authentication documentation on official last.fm documentation" />
		
		<cfscript>
			var args = StructNew();
			
			args['artist'] = arguments.artist;
			args['tag'] = arguments.tag;
			
			super.callAuthenticatedMethod('artist.removeTag', args, arguments.sessionKey, 'xml');
			
			return true;
		</cfscript>
	</cffunction>
	
	<cffunction name="search" access="public" returntype="struct" output="false" hint="Search for an artist by name. Returns artist matches sorted by relevance.">
		<cfargument name="artist" type="string" required="true" />
		<cfargument name="limit" type="numeric" required="false" hint="Limit the number of albums returned at one time. Default (maximum) is 30." />
		<cfargument name="page" type="numeric" required="false" hint="Scan into the results by specifying a page number. Defaults to first page." />
		
		<cfscript>
			var args = StructNew();
			var result = "";
			var returnStruct = StructNew();
			var results = "";
			var i = 0;
			
			args['artist'] = arguments.artist;
			
			if(StructKeyExists(arguments, 'limit')){
				args['limit'] = arguments.artist;
			}
			if(StructKeyExists(arguments, 'page')){
				args['page'] = arguments.artist;
			}
			
			result = super.CallMethod('artist.search', args);
			if(StructKeyExists(result, 'results')){
				result = result.results;
				
				returnStruct['itemsPerPage'] = result['opensearch:itemsPerPage'];
				returnStruct['startIndex'] = result['opensearch:startIndex'];
				returnStruct['totalResults'] = result['opensearch:totalResults'];
				returnStruct['results'] = QueryNew('mbid,name,streamable,url,smallImage,mediumImage,largeImage,extraLargeImage');
				
				if(IsDefined('result.artistMatches.artist')){
					results = super.ensureArray(result.artistMatches.artist);
					for(i=1; i LTE ArrayLen(results); i=i+1){
						QueryAddRow(returnStruct.results);
						QuerySetCell(returnStruct.results, 'mbid', results[i].mbid);
						QuerySetCell(returnStruct.results, 'name', results[i].name);
						QuerySetCell(returnStruct.results, 'streamable', results[i].streamable);
						QuerySetCell(returnStruct.results, 'url', results[i].url);
						
						if(StructKeyExists(results[i], 'image')){
							results[i].image = super.parseImages(results[i].image);
							QuerySetCell(returnStruct.results, 'smallImage', results[i].image.small);
							QuerySetCell(returnStruct.results, 'mediumImage', results[i].image.medium);
							QuerySetCell(returnStruct.results, 'largeImage', results[i].image.large);
							QuerySetCell(returnStruct.results, 'extraLargeImage', results[i].image.extraLarge);
						}
					}
				}
			}
			
			return returnStruct;
		</cfscript>
	</cffunction> 

</cfcomponent>