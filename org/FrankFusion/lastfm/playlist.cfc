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

	<cffunction name="addTrack" access="public" returntype="boolean" output="false" hint="Add a track to a Last.fm user's playlist">
		<cfargument name="playlistId" type="numeric" required="true" hint="The ID of the playlist - this is available in user.getPlaylists." />
		<cfargument name="track" type="string" required="true" hint="The track name to add to the playlist." />
		<cfargument name="artist" type="string" required="true" hint="The artist name that corresponds to the track to be added." />		
		<cfargument name="sessionKey" type="string" required="true" hint="Obtained from auth.getSessionKey. See Authentication documentation on official last.fm documentation" />
		
		<cfscript>
			var args = StructNew();
			
			args['playlistID'] = arguments.playlistId;
			args['track'] = arguments.track;
			args['artist'] = arguments.artist;
			
			super.callAuthenticatedMethod('playlist.addTrack', args, arguments.sessionKey, 'xml');
			
			return true;
		</cfscript>
	</cffunction>
	
	<cffunction name="create" access="public" returntype="struct" output="false" hint="Create a Last.fm playlist on behalf of a user">
		<cfargument name="title" type="string" required="true" hint="Title for the playlist" />
		<cfargument name="description" type="string" required="true" hint="Description for the playlist" />		
		<cfargument name="sessionKey" type="string" required="true" hint="Obtained from auth.getSessionKey. See Authentication documentation on official last.fm documentation" />
		
		<cfscript>
			var args = StructNew();
			var result = "";
			var returnStruct = StructNew();
			
			args['title'] = arguments.title;
			args['description'] = arguments.description;
			
			result = super.callAuthenticatedMethod('playlist.create', args, arguments.sessionKey);
			
			if(IsDefined('result.playlists.playlist')){
				result = result.playlists.playlist;
				returnStruct['id'] = result.id;
				returnStruct['creator'] = result.creator;
				returnStruct['date'] = result.date;
				returnStruct['description'] = result.description;
				returnStruct['title'] = result.title;
				returnStruct['url'] = result.url; 
			}
			
			return returnStruct;
		</cfscript>
	</cffunction>
	
	<cffunction name="fetch" access="public" returntype="struct" output="false" hint="Fetch XSPF playlists using a lastfm playlist url">
		<cfargument name="playlistURL" type="string" required="true" hint="A lastfm protocol playlist url ('lastfm://playlist/...') . See 'playlists' section for more information." />
		
		<cfscript>
			var args = StructNew();
			var returnStruct = StructNew();
			var results = "";
			var i = 0;
			
			args['playlistURL'] = arguments.playlistURL;
			
			results = super.callMethod('playlist.fetch', args).playlist;
			
			returnStruct['title'] = results[':title'];
			returnStruct['annotation'] = results[':annotation'];
			returnStruct['creator'] = results[':creator'];
			returnStruct['date'] = results[':date'];
			
			if(StructKeyExists(results, ':trackList') AND StructKeyExists(results[':trackList'], ':track')){
				results = super.ensureArray(results[':trackList'][':track']);
				returnStruct['tracks'] = QueryNew('album,creator,duration,identifier,image,info,title');
				
				for(i=1; i LTE ArrayLen(results); i=i+1){
					QueryAddRow(returnStruct.tracks);
					QuerySetCell(returnStruct.tracks, 'album', results[i].album);
					QuerySetCell(returnStruct.tracks, 'creator', results[i].creator);
					QuerySetCell(returnStruct.tracks, 'duration', results[i].duration);
					QuerySetCell(returnStruct.tracks, 'identifier', results[i].identifier);
					QuerySetCell(returnStruct.tracks, 'image', results[i].image);
					QuerySetCell(returnStruct.tracks, 'info', results[i].info);
					QuerySetCell(returnStruct.tracks, 'title', results[i].title);
				}
			}
			
			return returnStruct;
		</cfscript>
	</cffunction>
	
</cfcomponent>