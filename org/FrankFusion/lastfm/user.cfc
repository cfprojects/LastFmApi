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
	
	<cffunction name="getEvents" access="public" returntype="array" output="false" hint="Get a list of upcoming events that this user is attending. Easily integratable into calendars, using the ical standard (see 'more formats' section below).">
		<cfargument name="user" type="string" required="true" hint="The user to fetch the events for." />
		
		<cfscript>
			var args = StructNew();
			var results = "";
			var i = 0;
			
			args['user'] = arguments.user;
			
			results = super.CallMethod('user.getEvents', args);
			
			if(IsDefined('results.events.event')){
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
	
	<cffunction name="getFriends" access="public" returntype="query" output="false" hint="Get a list of the user's friends on Last.fm.">
		<cfargument name="user" type="string" required="true" hint="The last.fm username to fetch the friends of." />
		<cfargument name="recenttracks" type="boolean" required="false" default="false" hint="Whether or not to include information about friends' recent listening in the response." />
		<cfargument name="limit" type="numeric" required="false" hint="An integer used to limit the number of friends returned." />
		
		
		<cfscript>
			var args = StructNew();
			var results = "";
			var cols = 'name,realname,url,smallImage,mediumImage,largeImage,extraLargeImage#iif(arguments.recentTracks,DE(",lastTrack,lastTrackUrl,lastTrackMbid,lastTrackArtist,lastTrackArtistMbid,lastTrackArtistUrl"),DE(''))#';
			var returnQry = QueryNew(cols);
			
			var i = 0;
			
			args['user'] = arguments.user;
			if(StructKeyExists(arguments, 'limit')){
				args['limit'] = arguments.limit;
			}
			if(arguments.recenttracks){
				args['recenttracks'] = 'true';
			}
			
			results = super.CallMethod('user.getFriends', args);
			
			if(IsDefined('results.friends.user')){
				results = super.ensureArray(results.friends.user);
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnQry);
					QuerySetCell(returnQry,'name', results[i].name);
					QuerySetCell(returnQry,'realname', results[i].realname);			
					QuerySetCell(returnQry,'url', results[i].url);
					if(StructKeyExists(results[i], 'image')){
						results[i].image = super.parseImages(results[i].image);
						QuerySetCell(returnQry,'smallImage', results[i].image.small);
						QuerySetCell(returnQry,'mediumImage', results[i].image.medium);
						QuerySetCell(returnQry,'largeImage', results[i].image.large);
						QuerySetCell(returnQry,'extraLargeImage', results[i].image.extraLarge);
					}
					
					if(StructKeyExists(results[i], 'recenttrack')){
						QuerySetCell(returnQry,'lasttrack', results[i].recenttrack.name);
						QuerySetCell(returnQry,'lasttrackMbid', results[i].recenttrack.mbid);
						QuerySetCell(returnQry,'lasttrackUrl', results[i].recenttrack.url);
						QuerySetCell(returnQry,'lasttrackArtist', results[i].recenttrack.artist.name);
						QuerySetCell(returnQry,'lasttrackArtistMbid', results[i].recenttrack.artist.mbid);
						QuerySetCell(returnQry,'lasttrackArtistUrl', results[i].recenttrack.artist.url);
					}
				}
			}
			
			return returnQry;
		</cfscript>
	</cffunction> 

	<cffunction name="getInfo" access="public" returntype="struct" output="false" hint="Get information about a user profile.">
		<cfargument name="sessionKey" type="string" required="true" hint="Obtained from auth.getSessionKey. See Authentication documentation on official last.fm documentation" />
		
		<cfscript>
			var result = super.callAuthenticatedMethod('user.getInfo', StructNew(), arguments.sessionKey);
			
			if(IsDefined('result.user')){
				return result.user;
			}
			
			return StructNew();
		</cfscript>
	</cffunction> 

	<cffunction name="getLovedTracks" access="public" returntype="query" output="false" hint="Get the last 50 tracks loved by a user.">
		<cfargument name="user" type="string" required="true" hint="The user name to fetch the loved tracks for." />
		<cfscript>
			var args = StructNew();
			var returnQry = QueryNew('name,mbid,date,url,artist,artistMbid,artistUrl,smallImage,mediumImage,largeImage,extraLargeImage');
			var results = "";
			var i = 0;
			
			args['user'] = arguments.user;
			
			results = super.CallMethod('user.getLovedTracks', args);
			
			if(IsDefined('results.lovedtracks.track')){
				results = super.ensureArray(results.lovedtracks.track);
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnQry);
					QuerySetCell(returnQry,'name', results[i].name);
					QuerySetCell(returnQry,'mbid', results[i].mbid);
					QuerySetCell(returnQry,'date', super.decodeUnixTimestamp( results[i].date.uts ));		
					QuerySetCell(returnQry,'url', results[i].url);
					
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

	<cffunction name="getNeighbours" access="public" returntype="any" output="false" hint="Get a list of a user's neighbours on Last.fm. ">
		<cfargument name="user" type="string" required="true" hint="The last.fm username to fetch the neighbours  of." />
		<cfargument name="limit" type="numeric" required="false" hint="An integer used to limit the number of neighbours  returned." />
		
		<cfscript>
			var args = StructNew();
			var results = "";
			var returnQry = QueryNew('name,url,smallImage,mediumImage,largeImage,extraLargeImage,match');
			var image = "";
			var i = 0;
			
			args['user'] = arguments.user;
			if(StructKeyExists(arguments, 'limit')){
				args['limit'] = arguments.limit;
			}
			
			results = super.CallMethod('user.getNeighbours', args, 'get', 'xml'); // another method not working with json
			
			if(IsDefined('results.lfm.neighbours.user')){
				results = results.lfm.neighbours.user;
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnQry);
					QuerySetCell(returnQry,'name', results[i].name.xmlText);
					QuerySetCell(returnQry,'match', results[i].match.xmlText);			
					QuerySetCell(returnQry,'url', results[i].url.xmlText);
					
					if(StructKeyExists(results[i], 'image')){
						image = super.parseImages(results[i].image);
						QuerySetCell(returnQry,'smallImage', image.small);
						QuerySetCell(returnQry,'mediumImage', image.medium);
						QuerySetCell(returnQry,'largeImage', image.large);
						QuerySetCell(returnQry,'extraLargeImage', image.extraLarge);
					}
				}
			}
			
			return returnQry;
		</cfscript>
	</cffunction> 

	<cffunction name="getPastEvents" access="public" returntype="struct" output="false" hint="Get a paginated list of all events a user has attended in the past.">
		<cfargument name="user" type="string" required="true" hint="The user to fetch the events for." />
		<cfargument name="limit" type="numeric" required="false" default="50" hint="The number of events to return per page." />
		<cfargument name="page" type="numeric" required="false" default="1" hint="The page number to scan to." />
		
		<cfscript>
			var args = StructNew();
			var results = "";
			var i = 0;
			
			args['user'] = arguments.user;
			args['limit'] = arguments.limit;
			args['page'] = arguments.page;
			
			results = super.CallMethod('user.getPastEvents', args);
			
			if(IsDefined('results.events')){
				results = results.events;
				
				if(IsDefined('results.event')){
					results.event = super.ensureArray(results.event);
					for(i=1; i LTE ArrayLen(results.event); i=i+1){
						if(StructKeyExists(results.event[i], 'image')){
							results.event[i].image = super.parseImages(results.event[i].image);
						}
					}
				}
				return results;
			} 
			
			return StructNew();
		</cfscript>
	</cffunction> 

	<cffunction name="getPlaylists" access="public" returntype="query" output="false" hint="Get a list of a user's playlists on Last.fm.">
		<cfargument name="user" type="string" required="true" hint="The last.fm username to fetch the playlists of." />
		
		<cfscript>
			var args = StructNew();
			var results = "";
			var returnQry = QueryNew('id,title,description,date,size,duration,streamable,creator,url,smallImage,mediumImage,largeImage,extraLargeImage');
			var i = 0;
			
			args['user'] = arguments.user;

			results = super.CallMethod('user.getPlaylists', args);
			
			if(IsDefined('results.playlists.playlist')){
				results = super.ensureArray( results.playlists.playlist );
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnQry);
					QuerySetCell(returnQry,'id', results[i].id);
					QuerySetCell(returnQry,'title', results[i].title);			
					QuerySetCell(returnQry,'description', results[i].description);
					QuerySetCell(returnQry,'date', results[i].date);
					QuerySetCell(returnQry,'size', results[i].size);			
					QuerySetCell(returnQry,'duration', results[i].duration);
					QuerySetCell(returnQry,'streamable', results[i].streamable);
					QuerySetCell(returnQry,'creator', results[i].creator);			
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
	
	<cffunction name="getRecentTracks" access="public" returntype="query" output="false" hint="The last.fm username to fetch the recent tracks of.">
		<cfargument name="user" type="string" required="true" hint="The last.fm username to fetch the recent tracks of." />
		<cfargument name="limit" type="numeric" required="false" default="10" hint="An integer used to limit the number of tracks returned." />
		
		<cfscript>
			var args = StructNew();
			var results = "";
			var returnQry = QueryNew('name,mbid,url,artist,artistMbid,album,albumMbid,date,smallImage,mediumImage,largeImage,extraLargeImage');
			var i = 0;
			
			args['user'] = arguments.user;
			args['limit'] = arguments.limit;

			results = super.CallMethod('user.getRecentTracks', args);
			
			if(IsDefined('results.recenttracks.track')){
				results = super.ensureArray( results.recenttracks.track );
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnQry);
					QuerySetCell(returnQry,'name', results[i].name);
					QuerySetCell(returnQry,'mbid', results[i].mbid);			
					QuerySetCell(returnQry,'url', results[i].url);
					QuerySetCell(returnQry,'date', super.decodeUnixTimestamp( results[i].date.uts ));
					QuerySetCell(returnQry,'artist', results[i].artist['##text']);			
					QuerySetCell(returnQry,'artistMbid', results[i].artist.mbid);
					QuerySetCell(returnQry,'album', results[i].album['##text']);			
					QuerySetCell(returnQry,'albumMbid', results[i].album.mbid);
					
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

	<cffunction name="getRecommendedArtists" access="public" returntype="struct" output="false" hint="Get Last.fm artist recommendations for a user">
		<cfargument name="sessionKey" type="string" required="true" hint="Obtained from auth.getSessionKey. See Authentication documentation on official last.fm documentation" />
		<cfargument name="limit" type="numeric" required="false" default="50" hint="An integer used to limit the number of artists returned." />
		<cfargument name="page" type="numeric" required="false" default="1" hint="The page number to scan to." />

		<cfscript>
			var args = StructNew();
			var results = "";
			var returnStruct = StructNew();
			var i = 0;
			
			args['page'] = arguments.page;
			args['limit'] = arguments.limit;

			results = super.callAuthenticatedMethod('user.getRecommendedArtists', args, arguments.sessionKey);
			
			if(IsDefined('results.recommendations')){
				returnStruct['page'] = results.recommendations.page;
				returnStruct['perPage'] = results.recommendations.perPage;
				returnStruct['total'] = results.recommendations.total;
				returnStruct['totalPages'] = results.recommendations.totalPages;
				returnStruct['artists'] = QueryNew('name,mbid,url,streamable,smallImage,mediumImage,largeImage,extraLargeImage');
				
				if(IsDefined('results.recommendations.artist')){
					results = super.ensureArray( results.recommendations.artist );
				
					for(i=1; i LTE ArrayLen(results); i=i+1){
						QueryAddRow(returnStruct.artists);
						QuerySetCell(returnStruct.artists,'name', results[i].name);
						QuerySetCell(returnStruct.artists,'mbid', results[i].mbid);			
						QuerySetCell(returnStruct.artists,'url', results[i].url);
						QuerySetCell(returnStruct.artists,'streamable', results[i].streamable);
						
						if(StructKeyExists(results[i], 'image')){
							results[i].image = super.parseImages(results[i].image);
							QuerySetCell(returnStruct.artists,'smallImage', results[i].image.small);
							QuerySetCell(returnStruct.artists,'mediumImage', results[i].image.medium);
							QuerySetCell(returnStruct.artists,'largeImage', results[i].image.large);
							QuerySetCell(returnStruct.artists,'extraLargeImage', results[i].image.extraLarge);
						}
					}
				}
			}
			
			return returnStruct;
		</cfscript>
	</cffunction> 

	<cffunction name="getRecommendedEvents" access="public" returntype="struct" output="false" hint="Get a paginated list of all events recommended to a user by Last.fm, based on their listening profile.">
		<cfargument name="sessionKey" type="string" required="true" hint="Obtained from auth.getSessionKey. See Authentication documentation on official last.fm documentation" />
		<cfargument name="limit" type="numeric" required="false" default="10" hint="An integer used to limit the number of events returned." />
		<cfargument name="page" type="numeric" required="false" default="1" hint="The page number to scan to." />

		<cfscript>
			var args = StructNew();
			var results = "";
			var i = 0;
			
			args['page'] = arguments.page;
			args['limit'] = arguments.limit;

			results = super.callAuthenticatedMethod('user.getRecommendedEvents', args, arguments.sessionKey);
			
			if(IsDefined('results.events')){
				results = results.events;
				
				if(IsDefined('results.event')){
					results.event = super.ensureArray( results.event );
					for(i=1; i LTE ArrayLen(results.event); i=i+1){
						if( StructKeyExists(results.event[i], 'image') ){
							results.event[i].image = super.parseImages(results.event[i].image);
						}
					}
				}	
				
				return results;
			}
			
			return StructNew();
		</cfscript>
	</cffunction> 

	<cffunction name="getShouts" access="public" returntype="query" output="false" hint="Get shouts for this user. Also available as an rss feed.">
		<cfargument name="user" type="string" required="true" hint="The username to fetch shouts for" />
		
		<cfscript>
			var args = StructNew();
			var returnQry = QueryNew('body,author,date');
			var results = "";
			var i = 0;
			
			args['user'] = arguments.user;
			results = super.CallMethod('user.getShouts', args);
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

	<cffunction name="getTopAlbums" access="public" returntype="query" output="false" hint="Get the top albums listened to by a user. You can stipulate a time period. Sends the overall chart by default.">
		<cfargument name="user" type="string" required="true" hint="The user name to fetch top albums for." />
		<cfargument name="period" type="string" required="false" default="overall" hint="overall | 3month | 6month | 12month - The time period over which to retrieve top albums for." />
		
		<cfscript>
			var args = StructNew();
			var returnQry = QueryNew('name,mbid,url,playcount,artist,artistMbid,artistUrl,smallImage,mediumImage,largeImage,extraLargeImage');
			var results = "";
			var i = 0;
			
			args['user'] = arguments.user;
			args['period'] = arguments.period;
			
			results = super.CallMethod('user.getTopAlbums', args);
			
			if(IsDefined('results.topalbums.album')){
				results = super.ensureArray(results.topalbums.album);
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnQry);
					QuerySetCell(returnQry,'name', results[i].name);
					QuerySetCell(returnQry,'mbid', results[i].mbid);			
					QuerySetCell(returnQry,'url', results[i].url);
					QuerySetCell(returnQry,'playcount', results[i].playcount);
					
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

	<cffunction name="getTopArtists" access="public" returntype="any" output="false" hint="Get the most popular artists on Last.fm by country ">
		<cfargument name="user" type="string" required="true" hint="The user name to fetch top artists for." />
		<cfargument name="period" type="string" required="false" default="overall" hint="overall | 3month | 6month | 12month - The time period over which to retrieve top artists for." />
		
		<cfscript>
			var args = StructNew();
			var results = "";
			var i = 0;
			var returnQuery = QueryNew('mbid,name,streamable,url,playcount,rank,smallImage,mediumImage,largeImage,extraLargeImage');
			
			args['user'] = arguments.user;
			args['period'] = arguments.period;
			
			results = super.CallMethod('user.getTopArtists', args);
			
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

	<cffunction name="getTopTags" access="public" returntype="any" output="false" hint="Get the top tags used by this user.">
		<cfargument name="user" type="string" required="true" hint="The user name to fetch top tags for." />
		<cfargument name="limit" type="numeric" required="false" default="50" hint="Limit the number of tags returned" />
		
		<cfscript>
			var args = StructNew();
			var results = "";
			var i = 0;
			var returnQuery = QueryNew('name,count,url');
			
			args['user'] = arguments.user;
			//args['period'] = arguments.period;
			
			results = super.CallMethod('user.getTopTags', args);
			
			if(IsDefined('results.toptags.tag')){
				results = super.ensureArray(results.toptags.tag);
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnQuery);
					QuerySetCell(returnQuery, 'name', results[i].name);
					QuerySetCell(returnQuery, 'count', results[i].count);
					QuerySetCell(returnQuery, 'url', results[i].url);
				}
			}
			
			return returnQuery;
		</cfscript>
	</cffunction> 

	<cffunction name="getWeeklyAlbumChart" access="public" returntype="query" output="false" hint="Get an album chart for a user profile, for a given date range. If no date range is supplied, it will return the most recent album chart for this user. ">
		<cfargument name="user" type="string" required="true" hint="The last.fm username to fetch the charts of." />
		<cfargument name="from" type="date" required="false" hint="The date at which the chart should start from. See user.getWeeklyChartList for more." />
		<cfargument name="to" type="date" required="false" hint="The date at which the chart should end on. See user.getWeeklyChartList for more." />
		
		<cfscript>
			var args = StructNew();
			var results = "";
			var returnQry = QueryNew('artist,artistMbid,mbid,name,playcount,rank,url');
			var i = 0;
			
			args['user'] = arguments.user;
			if(StructKeyExists(arguments, 'from') ){
				args['from'] = super.encodeUnixTimestamp(arguments.from);
			}
			if(StructKeyExists(arguments, 'to') ){
				args['to'] = super.encodeUnixTimestamp(arguments.to);
			}
			
			results = super.callMethod('user.getWeeklyAlbumChart', args);
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
	
	<cffunction name="getWeeklyArtistChart" access="public" returntype="query" output="false" hint="Get an artist chart for a user, for a given date range. If no date range is supplied, it will return the most recent album chart for this group.">
		<cfargument name="user" type="string" required="true" hint="The last.fm username to fetch the charts of." />
		<cfargument name="from" type="date" required="false" hint="The date at which the chart should start from. See user.getWeeklyChartList for more." />
		<cfargument name="to" type="date" required="false" hint="The date at which the chart should end on. See user.getWeeklyChartList for more." />
		
		<cfscript>
			var args = StructNew();
			var results = "";
			var returnQry = QueryNew('mbid,name,playcount,rank,url');
			var i = 0;
			
			args['user'] = arguments.user;
			if(StructKeyExists(arguments, 'from') ){
				args['from'] = super.encodeUnixTimestamp(arguments.from);
			}
			if(StructKeyExists(arguments, 'to') ){
				args['to'] = super.encodeUnixTimestamp(arguments.to);
			}
			
			results = super.callMethod('user.getWeeklyArtistChart', args);
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
	
	<cffunction name="getWeeklyChartList" access="public" returntype="any" output="false" hint="Get a list of available charts for this user, expressed as date ranges which can be sent to the chart services.">
		<cfargument name="user" type="string" required="true" hint="The last.fm username to fetch the charts of." />
		
		<cfscript>
			var args = StructNew();
			var results = "";
			var returnQry = QueryNew('from,to');
			var i = 0;
			
			args['user'] = arguments.user;			
			results = super.callMethod('user.getWeeklyChartList', args);
			
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
	
	<cffunction name="getWeeklyTrackChart" access="public" returntype="query" output="false" hint="Get a track chart for a user, for a given date range. If no date range is supplied, it will return the most recent album chart for this group.">
		<cfargument name="user" type="string" required="true" hint="The last.fm username to fetch the charts of." />
		<cfargument name="from" type="date" required="false" hint="The date at which the chart should start from. See Group.getWeeklyChartList for more." />
		<cfargument name="to" type="date" required="false" hint="The date at which the chart should end on. See Group.getWeeklyChartList for more." />
		
		<cfscript>
			var args = StructNew();
			var results = "";
			var returnQry = QueryNew('artist,artistMbid,mbid,name,playcount,rank,url');
			var i = 0;
			
			args['user'] = arguments.user;
			if(StructKeyExists(arguments, 'from') ){
				args['from'] = super.encodeUnixTimestamp(arguments.from);
			}
			if(StructKeyExists(arguments, 'to') ){
				args['to'] = super.encodeUnixTimestamp(arguments.to);
			}
			
			results = super.callMethod('user.getWeeklyTrackChart', args);
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
