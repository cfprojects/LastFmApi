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
	
	<cffunction name="addTags" access="public" returntype="boolean" output="false" hint="Tag an album using a list of user supplied tags. Returns true on success - throws the lastFM error on failure.">
		<cfargument name="artist" type="string" required="true" />
		<cfargument name="album" type="string" required="true" />
		<cfargument name="tags" type="string" required="true" />
		<cfargument name="sessionKey" type="string" required="true" hint="Obtained from auth.getSessionKey. See Authentication documentation on official last.fm documentation" />
		
		<cfscript>
			var args = StructNew();
			
			args['artist'] = arguments.artist;
			args['album'] = arguments.album;
			args['tags'] = arguments.tags;
			
			super.callAuthenticatedMethod('album.addTags', args, arguments.sessionKey, 'xml');
			
			return true;
		</cfscript>
	</cffunction> 
	
	<cffunction name="getInfo" access="public" returntype="struct" output="false" hint="Get the metadata for an album on Last.fm using the album name or a musicbrainz id. See playlist.fetch on how to get the album playlist.">
		<cfargument name="artist" type="string" required="false" />
		<cfargument name="album" type="string" required="false" />
		<cfargument name="mbid" type="string" required="false" hint="Musicbrainz id of the album" />
		<cfargument name="lang" type="string" required="false" hint="The language to return the biography in, expressed as an ISO 639 alpha-2 code." />
		
		<cfscript>
			var args = StructNew();
			var result = "";
			
			if(StructKeyExists(arguments, 'artist')){
				args['artist'] = arguments.artist;
			}
			if(StructKeyExists(arguments, 'album')){
				args['album'] = arguments.album;
			}
			if(StructKeyExists(arguments, 'mbid')){
				args['mbid'] = arguments.mbid;
			}
			if(StructKeyExists(arguments, 'lang')){
				args['lang'] = arguments.lang;
			}
			
			result = super.CallMethod('album.getInfo', args);
			if(not StructKeyExists(result, 'album')){
				return StructNew();
			} else {
				result = result.album;
			}
			
			
			if(StructKeyExists(result, 'image')){
				result.image = super.parseImages(result.image);
			}
			
			return result;
		</cfscript>
	</cffunction> 
	
	<cffunction name="getTags" access="public" returntype="any" output="false" hint="Get the tags applied by an individual user to an album on Last.fm. ">
		<cfargument name="artist" type="string" required="true" />
		<cfargument name="album" type="string" required="true" />
		<cfargument name="sessionKey" type="string" required="true" hint="Obtained from auth.getSessionKey. See Authentication documentation on official last.fm documentation" />
		
		<cfscript>
			var args = StructNew();
			var returnQry = QueryNew('name,url');
			var results = "";
			var i = 0;
			
			args['artist'] = arguments.artist;
			args['album'] = arguments.album;
			
			results = super.callAuthenticatedMethod('album.getTags', args, arguments.sessionKey);
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
	
	<cffunction name="removeTag" access="public" returntype="boolean" output="false" hint="Remove a user's tag from an album. Returns true on success - throws the lastFM error on failure.">
		<cfargument name="artist" type="string" required="true" />
		<cfargument name="album" type="string" required="true" />
		<cfargument name="tag" type="string" required="true" />
		<cfargument name="sessionKey" type="string" required="true" hint="Obtained from auth.getSessionKey. See Authentication documentation on official last.fm documentation" />
		
		<cfscript>
			var args = StructNew();
			
			args['artist'] = arguments.artist;
			args['album'] = arguments.album;
			args['tag'] = arguments.tag;
			
			super.callAuthenticatedMethod('album.removeTag', args, arguments.sessionKey, 'xml');
			
			return true;
		</cfscript>
	</cffunction> 
	
	<cffunction name="search" access="public" returntype="struct" output="false" hint="Search for an album by name. Returns album matches sorted by relevance.">
		<cfargument name="album" type="string" required="true" />
		<cfargument name="limit" type="numeric" required="false" hint="Limit the number of albums returned at one time. Default (maximum) is 30." />
		<cfargument name="page" type="numeric" required="false" hint="Scan into the results by specifying a page number. Defaults to first page." />
		
		<cfscript>
			var args = StructNew();
			var result = "";
			var returnStruct = StructNew();
			var results = "";
			var i = 0;
			
			args['album'] = arguments.album;
			
			if(StructKeyExists(arguments, 'limit')){
				args['limit'] = arguments.limit;
			}
			if(StructKeyExists(arguments, 'page')){
				args['page'] = arguments.page;
			}
			
			result = super.CallMethod('album.search', args);
			if(not StructKeyExists(result, 'results')){
				return StructNew();
			} else {
				result = result.results;
			}
			
			returnStruct['itemsPerPage'] = result['opensearch:itemsPerPage'];
			returnStruct['startIndex'] = result['opensearch:startIndex'];
			returnStruct['totalResults'] = result['opensearch:totalResults'];
			returnStruct['results'] = QueryNew('id,artist,smallImage,mediumImage,largeImage,extraLargeImage,name,streamable,url');
			
			if(IsDefined('result.albumMatches.album')){
				results = super.ensureArray(result.albumMatches.album);
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnStruct.results);
					QuerySetCell(returnStruct.results, 'id', results[i].id);
					QuerySetCell(returnStruct.results, 'artist', results[i].artist);
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
			
			return returnStruct;
		</cfscript>
	</cffunction> 

</cfcomponent>