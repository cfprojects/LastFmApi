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
	
	<cffunction name="getEvents" access="public" returntype="array" output="false" hint="Get all events in a specific location by country or city name.">
		<cfargument name="location" type="string" required="false" hint="Specifies a location to retrieve events for (service returns nearby events by default)" />
		<cfargument name="lat" type="numeric" required="false" hint="Specifies a latitude value to retrieve events for (service returns nearby events by default)" />
		<cfargument name="long" type="numeric" required="false" hint="Specifies a longitude value to retrieve events for (service returns nearby events by default)" />
		<cfargument name="page" type="numeric" required="false" hint="Display more results by pagination" />
		<cfargument name="distance" type="numeric" required="false" hint="Find events within a specified distance" />
				
		<cfscript>
			var args = StructNew();
			var results = "";
			var i = 0;
			
			if(StructKeyExists(arguments, 'location')){
				args['location'] = arguments.location;
			}
			if(StructKeyExists(arguments, 'lat')){
				args['lat'] = arguments.lat;
			}
			if(StructKeyExists(arguments, 'long')){
				args['long'] = arguments.long;
			}
			if(StructKeyExists(arguments, 'page')){
				args['page'] = arguments.location;
			}
			if(StructKeyExists(arguments, 'distance')){
				args['distance'] = arguments.location;
			}
			
			results = super.CallMethod('geo.getEvents', args);
			
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
	
	<cffunction name="getTopArtists" access="public" returntype="any" output="false" hint="Get the most popular artists on Last.fm by country ">
		<cfargument name="country" type="string" required="true" hint="A country name, as defined by the ISO 3166-1 country names standard" />
		<cfargument name="location" type="string" required="false" hint="A metro name, to fetch the charts for (must be within the country specified)" />
		
		<cfscript>
			var args = StructNew();
			var results = "";
			var i = 0;
			var returnQuery = QueryNew('mbid,name,streamable,url,playcount,rank,smallImage,mediumImage,largeImage,extraLargeImage');
			
			args['country'] = arguments.country;
			if(StructKeyExists(arguments, 'location')){
				args['location'] = arguments.location;
			}
			
			results = super.CallMethod('geo.getTopArtists', args);
			
			if(IsDefined('results.topartists.artist')){
				results = super.ensureArray(results.topartists.artist);
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnQuery);
					QuerySetCell(returnQuery, 'mbid', results[i].mbid);
					QuerySetCell(returnQuery, 'name', results[i].name);
					QuerySetCell(returnQuery, 'streamable', results[i].streamable);
					QuerySetCell(returnQuery, 'url', results[i].url);
					QuerySetCell(returnQuery, 'playcount', results[i].playcount);
					QuerySetCell(returnQuery, 'rank', results[i].rank);
					
					if(StructKeyExists(results[i], 'image')){
						results[i].image = super.parseImages(results[i].image);
						QuerySetCell(returnQuery, 'smallImage', results[i].image.small);
						QuerySetCell(returnQuery, 'mediumImage', results[i].image.medium);
						QuerySetCell(returnQuery, 'largeImage', results[i].image.large);
						QuerySetCell(returnQuery, 'extraLargeImage', results[i].image.extraLarge);
					}
				}
			}
			
			return returnQuery;
		</cfscript>
	</cffunction> 
	
	<cffunction name="getTopTracks" access="public" returntype="any" output="false" hint="Get the most popular tracks on Last.fm last week by country">
		<cfargument name="country" type="string" required="true" hint="A country name, as defined by the ISO 3166-1 country names standard" />
		<cfargument name="location" type="string" required="false" hint="A metro name, to fetch the charts for (must be within the country specified)" />
			
		<cfscript>
			var args = StructNew();
			var results = "";
			var i = 0;
			var returnQuery = QueryNew('mbid,name,streamable,url,playcount,artist,artistMbid,artistUrl,smallImage,mediumImage,largeImage,extraLargeImage');
			
			args['country'] = arguments.country;
			if(StructKeyExists(arguments, 'location')){
				args['location'] = arguments.location;
			}
			
			results = super.CallMethod('geo.getTopTracks', args);
			
			if(IsDefined('results.toptracks.track')){
				results = super.ensureArray(results.toptracks.track);
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnQuery);
					QuerySetCell(returnQuery, 'mbid', results[i].mbid);
					QuerySetCell(returnQuery, 'name', results[i].name);
					QuerySetCell(returnQuery, 'streamable', results[i].streamable['##text']);
					QuerySetCell(returnQuery, 'url', results[i].url);
					QuerySetCell(returnQuery, 'playcount', results[i].playcount);
					QuerySetCell(returnQuery, 'artist', results[i].artist.name);
					QuerySetCell(returnQuery, 'artistMbid', results[i].artist.Mbid);
					QuerySetCell(returnQuery, 'artistUrl', results[i].artist.url);
					
					if(StructKeyExists(results[i], 'image')){
						results[i].image = super.parseImages(results[i].image);
						QuerySetCell(returnQuery, 'smallImage', results[i].image.small);
						QuerySetCell(returnQuery, 'mediumImage', results[i].image.medium);
						QuerySetCell(returnQuery, 'largeImage', results[i].image.large);
						QuerySetCell(returnQuery, 'extraLargeImage', results[i].image.extraLarge);
					}
				}
			}
			
			return returnQuery;
		</cfscript>
	</cffunction> 

</cfcomponent>