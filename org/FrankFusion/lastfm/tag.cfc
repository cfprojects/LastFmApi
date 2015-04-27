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

	<cffunction name="getSimilar" access="public" returntype="query" output="false" hint="Search for tags similar to this one. Returns tags ranked by similarity, based on listening data.">
		<cfargument name="tag" type="string" required="true" hint="The tag name in question" />
		
		<cfscript>
			var args = StructNew();
			var returnQry = QueryNew('name,url,streamable');
			var results = "";
			var i = 0;
			
			args['tag'] = arguments.tag;
			
			results = super.callMethod('tag.getSimilar', args, 'get', 'xml'); // another method that doesn't work with json
			if(IsDefined('results.lfm.similartags.tag')){
				results = results.lfm.similartags.tag;
				
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnQry);
					QuerySetCell(returnQry,'name', results[i].name.xmlText);
					QuerySetCell(returnQry,'url', results[i].url.xmlText);
					QuerySetCell(returnQry,'streamable', results[i].streamable.xmlText);
				}
			}
			
			return returnQry;
		</cfscript>
	</cffunction>

	<cffunction name="getTopAlbums" access="public" returntype="query" output="false" hint="Get the top albums tagged by this tag, ordered by tag count.">
		<cfargument name="tag" type="string" required="true" hint="The tag name in question" />
		
		<cfscript>
			var args = StructNew();
			var returnQry = QueryNew('name,mbid,url,tagCount,artist,artistMbid,artistUrl,smallImage,mediumImage,largeImage,extraLargeImage');
			var results = "";
			var i = 0;
			
			args['tag'] = arguments.tag;
			
			results = super.CallMethod('tag.getTopAlbums', args);
			
			if(IsDefined('results.topalbums.album')){
				results = super.ensureArray(results.topalbums.album);
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnQry);
					QuerySetCell(returnQry,'name', results[i].name);
					QuerySetCell(returnQry,'mbid', results[i].mbid);			
					QuerySetCell(returnQry,'url', results[i].url);
					QuerySetCell(returnQry,'tagCount', results[i].tagCount);
					QuerySetCell(returnQry,'artist', results[i].artist.name);
					QuerySetCell(returnQry,'artistMbid', results[i].artist.mbid);
					QuerySetCell(returnQry,'artistUrl', results[i].artist.url);
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

	<cffunction name="getTopArtists" access="public" returntype="query" output="false" hint="Get the top artists tagged by this tag, ordered by tag count.">
		<cfargument name="tag" type="string" required="true" hint="The tag name in question" />
		
		<cfscript>
			var args = StructNew();
			var returnQry = QueryNew('name,mbid,url,rank,tagCount,streamable,smallImage,mediumImage,largeImage,extraLargeImage');
			var results = "";
			var i = 0;
			
			args['tag'] = arguments.tag;
			
			results = super.CallMethod('tag.getTopArtists', args);
			
			if(IsDefined('results.topartists.artist')){
				results = super.ensureArray(results.topartists.artist);
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnQry);
					QuerySetCell(returnQry,'name', results[i].name);
					QuerySetCell(returnQry,'mbid', results[i].mbid);			
					QuerySetCell(returnQry,'url', results[i].url);
					QuerySetCell(returnQry,'tagCount', results[i].tagCount);
					QuerySetCell(returnQry,'rank', results[i].rank);
					QuerySetCell(returnQry,'streamable', results[i].streamable);
					
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

	<cffunction name="getTopTracks" access="public" returntype="query" output="false" hint="Get the top tracks tagged by this tag, ordered by tag count.">
		<cfargument name="tag" type="string" required="true" hint="The tag name in question" />
		
		<cfscript>
			var args = StructNew();
			var returnQry = QueryNew('name,mbid,url,tagCount,artist,artistMbid,artistUrl,smallImage,mediumImage,largeImage,extraLargeImage');
			var results = "";
			var i = 0;
			
			args['tag'] = arguments.tag;
			
			results = super.CallMethod('tag.getTopTracks', args);
			
			if(IsDefined('results.toptracks.track')){
				results = super.ensureArray(results.toptracks.track);
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnQry);
					QuerySetCell(returnQry,'name', results[i].name);
					QuerySetCell(returnQry,'mbid', results[i].mbid);			
					QuerySetCell(returnQry,'url', results[i].url);
					QuerySetCell(returnQry,'tagCount', results[i].tagCount);
					QuerySetCell(returnQry,'artist', results[i].artist.name);
					QuerySetCell(returnQry,'artistMbid', results[i].artist.mbid);
					QuerySetCell(returnQry,'artistUrl', results[i].artist.url);
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

	<cffunction name="getWeeklyArtistChart" access="public" returntype="query" output="false" hint="Get an artist chart for a tag, for a given date range. If no date range is supplied, it will return the most recent artist chart for this tag.">
		<cfargument name="tag" type="string" required="true" hint="The tag name in question" />
		<cfargument name="from" type="date" required="false" hint="The date at which the chart should start from. See Group.getWeeklyChartList for more." />
		<cfargument name="to" type="date" required="false" hint="The date at which the chart should end on. See Group.getWeeklyChartList for more." />
		<cfargument name="limit" type="numeric" required="false" default="50" hint="Limit the number of artist returned at one time. Default (maximum) is 30." />
		
		<cfscript>
			var args = StructNew();
			var results = "";
			var returnQry = QueryNew('mbid,name,weight,rank,url');
			var i = 0;
			
			args['tag'] = arguments.tag;
			args['limit'] = arguments.limit;
			if(StructKeyExists(arguments, 'from') ){
				args['from'] = super.encodeUnixTimestamp(arguments.from);
			}
			if(StructKeyExists(arguments, 'to') ){
				args['to'] = super.encodeUnixTimestamp(arguments.to);
			}
			
			results = super.callMethod('tag.getWeeklyArtistChart', args);
			if(IsDefined('results.weeklyartistchart.artist')){
				results = super.ensureArray( results.weeklyartistchart.artist );
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnQry);
					QuerySetCell(returnQry, 'mbid', results[i].mbid);
					QuerySetCell(returnQry, 'name', results[i].name);
					QuerySetCell(returnQry, 'weight', results[i].weight);
					QuerySetCell(returnQry, 'rank', results[i].rank);
					QuerySetCell(returnQry, 'url', results[i].url);
				}
			}
			
			return returnQry;
		</cfscript>
		
	</cffunction>

	<cffunction name="getWeeklyChartList" access="public" returntype="any" output="false" hint="Get a list of available charts for this tag, expressed as date ranges which can be sent to the chart services.">
		<cfargument name="tag" type="string" required="true" hint="The tag name in question" />
		
		<cfscript>
			var args = StructNew();
			var results = "";
			var returnQry = QueryNew('from,to');
			var i = 0;
			
			args['tag'] = arguments.tag;		
			results = super.callMethod('tag.getWeeklyChartList', args);
			
			if(IsDefined('results.weeklychartlist.chart')){
				results = super.ensureArray( results.weeklychartlist.chart );
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnQry);
					QuerySetCell(returnQry, 'from', super.decodeUnixTimestamp(results[i].from));
					QuerySetCell(returnQry, 'to', super.decodeUnixTimestamp(results[i].to));
				}
			}
						
			return returnQry;
		</cfscript>
		
	</cffunction>

	<cffunction name="search" access="public" returntype="any" output="false" hint="Search for a tag by name. Returns matches sorted by relevance.">
		<cfargument name="tag" type="string" required="true" hint="The tag name in question" />
		<cfargument name="limit" type="numeric" required="false" hint="Limit the number of albums returned at one time. Default (maximum) is 30." />
		<cfargument name="page" type="numeric" required="false" hint="Scan into the results by specifying a page number. Defaults to first page." />
		
		<cfscript>
			var args = StructNew();
			var result = "";
			var returnStruct = StructNew();
			var results = "";
			var i = 0;
			
			args['tag'] = arguments.tag;
			
			if(StructKeyExists(arguments, 'limit')){
				args['limit'] = arguments.limit;
			}
			if(StructKeyExists(arguments, 'page')){
				args['page'] = arguments.page;
			}
			
			result = super.CallMethod('tag.search', args);
			if(not StructKeyExists(result, 'results')){
				return StructNew();
			} else {
				result = result.results;
			}
			
			returnStruct['itemsPerPage'] = result['opensearch:itemsPerPage'];
			returnStruct['startIndex'] = result['opensearch:startIndex'];
			returnStruct['totalResults'] = result['opensearch:totalResults'];
			returnStruct['results'] = QueryNew('name,count,url');
			
			if(IsDefined('result.tagMatches.tag')){
				results = super.ensureArray(result.tagMatches.tag);
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnStruct.results);
					QuerySetCell(returnStruct.results, 'name', results[i].name);
					QuerySetCell(returnStruct.results, 'count', results[i].count);
					QuerySetCell(returnStruct.results, 'url', results[i].url);
				}
			}
			
			return returnStruct;
		</cfscript>
	</cffunction> 

</cfcomponent>