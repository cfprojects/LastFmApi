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

	<cffunction name="addTags" access="public" returntype="boolean" output="false" hint="Tag an album using a list of user supplied tags.">
		<cfargument name="artist" type="string" required="true" />
		<cfargument name="track" type="string" required="true" />
		<cfargument name="tags" type="string" required="true" />
		<cfargument name="sessionKey" type="string" required="true" hint="Obtained from auth.getSessionKey. See Authentication documentation on official last.fm documentation" />
		
		<cfscript>
			var args = StructNew();
			
			args['artist'] = arguments.artist;
			args['track'] = arguments.track;
			args['tags'] = arguments.tags;
			
			super.callAuthenticatedMethod('track.addTags', args, arguments.sessionKey, 'xml');
			
			return true;
		</cfscript>
	</cffunction>
	
	<cffunction name="ban" access="public" returntype="boolean" output="false" hint="Ban a track for a given user profile. This needs to be supplemented with a scrobbling submission containing the 'ban' rating (see the audioscrobbler API).">
		<cfargument name="artist" type="string" required="true" />
		<cfargument name="track" type="string" required="true" />
		<cfargument name="sessionKey" type="string" required="true" hint="Obtained from auth.getSessionKey. See Authentication documentation on official last.fm documentation" />
		
		<cfscript>
			var args = StructNew();
			
			args['artist'] = arguments.artist;
			args['track'] = arguments.track;
			
			super.callAuthenticatedMethod('track.ban', args, arguments.sessionKey, 'xml');
			
			return true;
		</cfscript>
	</cffunction> 

	<cffunction name="getInfo" access="public" returntype="struct" output="false" hint="Get the metadata for a track on Last.fm using the artist/track name or a musicbrainz id.">
		<cfargument name="artist" type="string" required="false" />
		<cfargument name="track" type="string" required="false" />
		<cfargument name="mbid" type="string" required="false" hint="The musicbrainz id for the track" />
		
		<cfscript>
			var args = StructNew();
			var result = "";
			
			if(StructKeyExists(arguments, 'artist')){
				args['artist'] = arguments.artist;
			}
			if(StructKeyExists(arguments, 'track')){
				args['track'] = arguments.track;
			}
			if(StructKeyExists(arguments, 'mbid')){
				args['mbid'] = arguments.mbid;
			}
			
			result = super.CallMethod('track.getInfo', args);
			if(not StructKeyExists(result, 'track')){
				return StructNew();
			} else {
				result = result.track;
			}
			
			
			if(IsDefined('result.album.image')){
				result.album.image = super.parseImages(result.album.image);
			}
			
			return result;
		</cfscript>
	</cffunction> 

	<cffunction name="getSimilar" access="public" returntype="any" output="false" hint="Get all the tracks similar to this track.">
		<cfargument name="artist" type="string" required="false" />
		<cfargument name="track" type="string" required="false" />
		<cfargument name="mbid" type="string" required="false" hint="The musicbrainz id for the track" />
		
		<cfscript>
			var args = StructNew();
			var returnQry = QueryNew('name,mbid,match,url,smallImage,mediumImage,largeImage,extraLargeImage,streamable,artist,artistMbid,artistUrl');
			var results = "";
			var images = "";
			var i = 0;
			
			if(StructKeyExists(arguments, 'artist')){
				args['artist'] = arguments.artist;
			}
			if(StructKeyExists(arguments, 'track')){
				args['track'] = arguments.track;
			}
			if(StructKeyExists(arguments, 'mbid')){
				args['mbid'] = arguments.mbid;
			}
			
			results = super.CallMethod('track.getSimilar', args, 'get', 'xml'); // the getSimilar method doesn't work with json!
			
			if(IsDefined('results.lfm.similartracks.track')){
				results = super.ensureArray(results.lfm.similartracks.track);
				for(i=1; i lTE ArrayLen(results); i=i+1){
					
					QueryAddRow(returnQry);
					QuerySetCell(returnQry, 'name', results[i].name.xmlText);
					QuerySetCell(returnQry, 'mbid', results[i].mbid.xmlText);
					QuerySetCell(returnQry, 'match', results[i].match.xmlText);
					QuerySetCell(returnQry, 'url', results[i].url.xmlText);
					QuerySetCell(returnQry, 'streamable', results[i].streamable.xmlText);
					QuerySetCell(returnQry, 'artist', results[i].artist.name.xmlText);
					QuerySetCell(returnQry, 'artistMbid', results[i].artist.mbid.xmlText);
					QuerySetCell(returnQry, 'artistUrl', results[i].artist.url.xmlText);
					
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

	<cffunction name="getTags" access="public" returntype="query" output="false" hint="Get the tags applied by an individual user to a track on Last.fm. ">
		<cfargument name="artist" type="string" required="true" />
		<cfargument name="track" type="string" required="true" />
		<cfargument name="sessionKey" type="string" required="true" hint="Obtained from auth.getSessionKey. See Authentication documentation on official last.fm documentation" />
		
		<cfscript>
			var args = StructNew();
			var returnQry = QueryNew('name,url');
			var results = "";
			var i = 0;
			
			args['artist'] = arguments.artist;
			args['track'] = arguments.track;
			
			results = super.callAuthenticatedMethod('track.getTags', args, arguments.sessionKey);
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

	<cffunction name="getTopFans" access="public" returntype="query" output="false" hint="Get the top fans for this track on Last.fm, based on listening data. Supply either track & artist name or musicbrainz id. ">
		<cfargument name="artist" type="string" required="false" />
		<cfargument name="track" type="string" required="false" />
		<cfargument name="mbid" type="string" required="false" hint="The musicbrainz id for the track" />
		
		<cfscript>
			var args = StructNew();
			var returnQry = QueryNew('name,url,smallImage,mediumImage,largeImage,extraLargeImage,weight');
			var results = "";
			var i = 0;
			
			if(StructKeyExists(arguments, 'artist')){
				args['artist'] = arguments.artist;
			}
			if(StructKeyExists(arguments, 'track')){
				args['track'] = arguments.track;
			}
			if(StructKeyExists(arguments, 'mbid')){
				args['mbid'] = arguments.mbid;
			}
			
			results = super.CallMethod('track.getTopFans', args);
			
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

	<cffunction name="getTopTags" access="public" returntype="query" output="false" hint="Get the top tags for this track on Last.fm, ordered by tag count. Supply either track & artist name or mbid.">
		<cfargument name="artist" type="string" required="false" />
		<cfargument name="track" type="string" required="false" />
		<cfargument name="mbid" type="string" required="false" hint="The musicbrainz id for the track" />
		
		<cfscript>
			var args = StructNew();
			var returnQry = QueryNew('name,url');
			var results = "";
			var i = 0;
			
			if(StructKeyExists(arguments, 'artist')){
				args['artist'] = arguments.artist;
			}
			if(StructKeyExists(arguments, 'track')){
				args['track'] = arguments.track;
			}
			if(StructKeyExists(arguments, 'mbid')){
				args['mbid'] = arguments.mbid;
			}
			
			results = super.CallMethod('track.getTopTags', args);
			
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

	<cffunction name="love" access="public" returntype="boolean" output="false" hint="Love a track for a user profile. This needs to be supplemented with a scrobbling submission containing the 'love' rating (see the audioscrobbler API).">
		<cfargument name="artist" type="string" required="true" />
		<cfargument name="track" type="string" required="true" />
		<cfargument name="sessionKey" type="string" required="true" hint="Obtained from auth.getSessionKey. See Authentication documentation on official last.fm documentation" />
		
		<cfscript>
			var args = StructNew();
			
			args['artist'] = arguments.artist;
			args['track'] = arguments.track;
			
			super.callAuthenticatedMethod('track.love', args, arguments.sessionKey, 'xml');
			
			return true;
		</cfscript>
	</cffunction> 

	<cffunction name="removeTag" access="public" returntype="boolean" output="false" hint="Remove a user's tag from a track. ">
		<cfargument name="artist" type="string" required="true" />
		<cfargument name="track" type="string" required="true" />
		<cfargument name="tag" type="string" required="true" />
		<cfargument name="sessionKey" type="string" required="true" hint="Obtained from auth.getSessionKey. See Authentication documentation on official last.fm documentation" />
		
		<cfscript>
			var args = StructNew();
			
			args['artist'] = arguments.artist;
			args['track'] = arguments.artist;
			args['tag'] = arguments.tag;
			
			super.callAuthenticatedMethod('track.removeTag', args, arguments.sessionKey, 'xml');
			
			return true;
		</cfscript>
	</cffunction>

	<cffunction name="search" access="public" returntype="any" output="false" hint="Search for a track by track name. Returns track matches sorted by relevance.">
		<cfargument name="track" type="string" required="true" />
		<cfargument name="artist" type="string" required="false" />
		<cfargument name="limit" type="numeric" required="false" hint="Limit the number of tracks returned at one time. Default (maximum) is 30." />
		<cfargument name="page" type="numeric" required="false" hint="Scan into the results by specifying a page number. Defaults to first page." />
		
		<cfscript>
			var args = StructNew();
			var result = "";
			var returnStruct = StructNew();
			var results = "";
			var i = 0;
			
			args['track'] = arguments.track;
			if(StructKeyExists(arguments, 'artist')){
				args['artist'] = arguments.artist;
			}			
			if(StructKeyExists(arguments, 'limit')){
				args['limit'] = arguments.artist;
			}
			if(StructKeyExists(arguments, 'page')){
				args['page'] = arguments.artist;
			}
			
			result = super.CallMethod('track.search', args);
			if(not StructKeyExists(result, 'results')){
				return StructNew();
			} else {
				result = result.results;
			}
			
			returnStruct['itemsPerPage'] = result['opensearch:itemsPerPage'];
			returnStruct['startIndex'] = result['opensearch:startIndex'];
			returnStruct['totalResults'] = result['opensearch:totalResults'];
			returnStruct['results'] = QueryNew('artist,listeners,name,streamable,url,smallImage,mediumImage,largeImage,extraLargeImage');
			
			if(IsDefined('result.trackmatches.track')){
				results = super.ensureArray(result.trackmatches.track);
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnStruct.results);
					QuerySetCell(returnStruct.results, 'artist', results[i].artist);
					QuerySetCell(returnStruct.results, 'name', results[i].name);
					QuerySetCell(returnStruct.results, 'streamable', results[i].streamable['##text']);
					QuerySetCell(returnStruct.results, 'listeners', results[i].listeners);
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
			
			return returnStruct;
		</cfscript>
	</cffunction> 

	<cffunction name="share" access="public" returntype="boolean" output="false" hint="Share a track twith one or more Last.fm users or other friends.">
		<cfargument name="artist" type="string" required="true" />
		<cfargument name="track" type="string" required="true" />
		<cfargument name="recipient" type="string" required="true" hint="Email Address | Last.fm Username - A comma delimited list of email addresses or Last.fm usernames. Maximum is 10." />
		<cfargument name="message" type="string" required="false" hint="An optional message to send with the recommendation. If not supplied a default message will be used." />
		<cfargument name="sessionKey" type="string" required="true" hint="Obtained from auth.getSessionKey. See Authentication documentation on official last.fm documentation" />
		
		<cfscript>
			var args = StructNew();
			
			args['artist'] = arguments.artist;
			args['track'] = arguments.track;
			args['recipient'] = arguments.recipient;
			if(StructKeyExists(arguments, 'message')){
				args['message'] = arguments.message;
			}
			
			super.callAuthenticatedMethod('track.share', args, arguments.sessionKey, 'xml');
			
			return true;
		</cfscript>
	</cffunction> 
</cfcomponent>