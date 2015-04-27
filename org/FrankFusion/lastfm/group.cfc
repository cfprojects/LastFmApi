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

	<cffunction name="getMembers" access="public" returntype="struct" output="false" hint="Get a list of members for this group.">
		<cfargument name="group" type="string" required="true" hint="The group name to fetch the members of." />
		<cfargument name="limit" type="numeric" required="false" default="50" hint="Limit the number of members returned at one time (undocumented)" />
		<cfargument name="page" type="numeric" required="false" default="1" hint="Page of results to fetch (undocumented)" />
		
		<cfscript>
			var args = StructNew();
			var results = "";
			var i = 0;
			
			args['group'] = arguments.group;
			args['limit'] = arguments.limit;
			args['page'] = arguments.page;
			
			results = super.CallMethod('group.getMembers', args);
			
			if(IsDefined('results.members')){
				
				results = results.members;
				
				if(IsDefined('results.user')){
					results.user = super.ensureArray(results.user);
					
					results.results = QueryNew('name,realname,url,smallImage,mediumImage,largeImage,extraLargeImage');
					for(i=1; i LTE ArrayLen(results.user); i=i+1){
						QueryAddRow(results.results);
						QuerySetCell(results.results,'name', results.user[i].name);
						QuerySetCell(results.results,'realname', results.user[i].realname);			
						QuerySetCell(results.results,'url', results.user[i].url);
						if(StructKeyExists(results.user[i], 'image')){
							results.user[i].image = super.parseImages(results.user[i].image);
							QuerySetCell(results.results,'smallImage', results.user[i].image.small);
							QuerySetCell(results.results,'mediumImage', results.user[i].image.medium);
							QuerySetCell(results.results,'largeImage', results.user[i].image.large);
							QuerySetCell(results.results,'extraLargeImage', results.user[i].image.extraLarge);
						}
					}
					
					StructDelete(results, 'user');
				}
			}
			
			return results;
			
		</cfscript>
	
	</cffunction>

	<cffunction name="getWeeklyAlbumChart" access="public" returntype="query" output="false" hint="Get an album chart for a group, for a given date range. If no date range is supplied, it will return the most recent album chart for this group.">
		<cfargument name="group" type="string" required="true" hint="The last.fm group name to fetch the charts of." />
		<cfargument name="from" type="date" required="false" hint="The date at which the chart should start from. See Group.getWeeklyChartList for more." />
		<cfargument name="to" type="date" required="false" hint="The date at which the chart should end on. See Group.getWeeklyChartList for more." />
		
		<cfscript>
			var args = StructNew();
			var results = "";
			var returnQry = QueryNew('artist,artistMbid,mbid,name,playcount,rank,url');
			var i = 0;
			
			args['group'] = arguments.group;
			if(StructKeyExists(arguments, 'from') ){
				args['from'] = super.encodeUnixTimestamp(arguments.from);
			}
			if(StructKeyExists(arguments, 'to') ){
				args['to'] = super.encodeUnixTimestamp(arguments.to);
			}
			
			results = super.callMethod('group.getWeeklyAlbumChart', args);
			if(IsDefined('results.weeklyalbumchart.album')){
				results = super.ensureArray( results.weeklyalbumchart.album );
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnQry);
					QuerySetCell(returnQry, 'artist', results[i].artist['##text']);
					QuerySetCell(returnQry, 'artistMbid', results[i].artist.mbid);
					QuerySetCell(returnQry, 'mbid', results[i].mbid);
					QuerySetCell(returnQry, 'name', results[i].name);
					QuerySetCell(returnQry, 'playcount', results[i].playcount);
					QuerySetCell(returnQry, 'rank', results[i].rank);
					QuerySetCell(returnQry, 'url', results[i].url);
				}
			}
			
			return returnQry;
		</cfscript>
		
	</cffunction>
	
	<cffunction name="getWeeklyArtistChart" access="public" returntype="query" output="false" hint="Get an artist chart for a group, for a given date range. If no date range is supplied, it will return the most recent album chart for this group.">
		<cfargument name="group" type="string" required="true" hint="The last.fm group name to fetch the charts of." />
		<cfargument name="from" type="date" required="false" hint="The date at which the chart should start from. See Group.getWeeklyChartList for more." />
		<cfargument name="to" type="date" required="false" hint="The date at which the chart should end on. See Group.getWeeklyChartList for more." />
		
		<cfscript>
			var args = StructNew();
			var results = "";
			var returnQry = QueryNew('mbid,name,playcount,rank,url');
			var i = 0;
			
			args['group'] = arguments.group;
			if(StructKeyExists(arguments, 'from') ){
				args['from'] = super.encodeUnixTimestamp(arguments.from);
			}
			if(StructKeyExists(arguments, 'to') ){
				args['to'] = super.encodeUnixTimestamp(arguments.to);
			}
			
			results = super.callMethod('group.getWeeklyArtistChart', args);
			if(IsDefined('results.weeklyartistchart.artist')){
				results = super.ensureArray( results.weeklyartistchart.artist );
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnQry);
					QuerySetCell(returnQry, 'mbid', results[i].mbid);
					QuerySetCell(returnQry, 'name', results[i].name);
					QuerySetCell(returnQry, 'playcount', results[i].playcount);
					QuerySetCell(returnQry, 'rank', results[i].rank);
					QuerySetCell(returnQry, 'url', results[i].url);
				}
			}
			
			return returnQry;
		</cfscript>
		
	</cffunction>
	
	<cffunction name="getWeeklyChartList" access="public" returntype="any" output="false" hint="Get a list of available charts for this group, expressed as date ranges which can be sent to the chart services.">
		<cfargument name="group" type="string" required="true" hint="The last.fm group name to fetch the charts of." />
		
		<cfscript>
			var args = StructNew();
			var results = "";
			var returnQry = QueryNew('from,to');
			var i = 0;
			
			args['group'] = arguments.group;			
			results = super.callMethod('group.getWeeklyChartList', args);
			
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
	
	<cffunction name="getWeeklyTrackChart" access="public" returntype="query" output="false" hint="Get a track chart for a group, for a given date range. If no date range is supplied, it will return the most recent album chart for this group.">
		<cfargument name="group" type="string" required="true" hint="The last.fm group name to fetch the charts of." />
		<cfargument name="from" type="date" required="false" hint="The date at which the chart should start from. See Group.getWeeklyChartList for more." />
		<cfargument name="to" type="date" required="false" hint="The date at which the chart should end on. See Group.getWeeklyChartList for more." />
		
		<cfscript>
			var args = StructNew();
			var results = "";
			var returnQry = QueryNew('artist,artistMbid,mbid,name,playcount,rank,url');
			var i = 0;
			
			args['group'] = arguments.group;
			if(StructKeyExists(arguments, 'from') ){
				args['from'] = super.encodeUnixTimestamp(arguments.from);
			}
			if(StructKeyExists(arguments, 'to') ){
				args['to'] = super.encodeUnixTimestamp(arguments.to);
			}
			
			results = super.callMethod('group.getWeeklyTrackChart', args);
			if(IsDefined('results.weeklytrackchart.track')){
				results = super.ensureArray( results.weeklytrackchart.track );
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnQry);
					QuerySetCell(returnQry, 'mbid', results[i].mbid);
					QuerySetCell(returnQry, 'artist', results[i].artist['##text']);
					QuerySetCell(returnQry, 'artistMbid', results[i].artist.mbid);
					QuerySetCell(returnQry, 'name', results[i].name);
					QuerySetCell(returnQry, 'playcount', results[i].playcount);
					QuerySetCell(returnQry, 'rank', results[i].rank);
					QuerySetCell(returnQry, 'url', results[i].url);
				}
			}
			
			return returnQry;
		</cfscript>
		
	</cffunction>

</cfcomponent>