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

	<cffunction name="getEvents" access="public" returntype="array" output="false" hint="Get a list of upcoming events at this venue.">
		<cfargument name="venue" type="numeric" required="true" hint="The venue id to fetch the events for." />
		
		<cfscript>
			var args = StructNew();
			var results = "";
			var i = 0;
			
			args['venue'] = arguments.venue;
			results = super.CallMethod('venue.getEvents', args);
			
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
	
	<cffunction name="getPastEvents" access="public" returntype="struct" output="false" hint="Get a paginated list of all events a user has attended in the past.">
		<cfargument name="venue" type="numeric" required="true" hint="The id for the venue you would like to fetch event listings for." />
		<cfargument name="limit" type="numeric" required="false" default="50" hint="The number of events to return per page." />
		<cfargument name="page" type="numeric" required="false" default="1" hint="The page number to scan to." />
		
		<cfscript>
			var args = StructNew();
			var results = "";
			var i = 0;
			
			args['venue'] = arguments.venue;
			args['limit'] = arguments.limit;
			args['page'] = arguments.page;
			
			results = super.CallMethod('venue.getPastEvents', args);
			
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

	<cffunction name="search" access="public" returntype="struct" output="false" hint="Search for a venue by venue name">
		<cfargument name="venue" type="string" required="true" hint="The venue name you would like to search for." />
		<cfargument name="country" type="string" required="false" hint="Filter your results by country. Expressed as an ISO 3166-2 code." />
		<cfargument name="limit" type="numeric" required="false" default="20" hint="The number of results to fetch per page. Defaults to 20." />
		<cfargument name="page" type="numeric" required="false" default="1" hint="The results page you would like to fetch" />
		
		
		<cfscript>
			var args = StructNew();
			var result = "";
			var returnStruct = StructNew();
			var results = "";
			var i = 0;
			
			args['venue'] = arguments.venue;
			args['limit'] = arguments.limit;
			args['page'] = arguments.page;
			if(StructKeyExists(arguments, 'country')){
				args['country'] = arguments.country;
			}
			
			result = super.CallMethod('venue.search', args);
			if(StructKeyExists(result, 'results')){
				result = result.results;
				
				returnStruct['itemsPerPage'] = result['opensearch:itemsPerPage'];
				returnStruct['startIndex'] = result['opensearch:startIndex'];
				returnStruct['totalResults'] = result['opensearch:totalResults'];
				returnStruct['results'] = QueryNew('id,name,url,city,country,street,postalcode,lat,long');
				
				if(IsDefined('result.venueMatches.venue')){
					results = super.ensureArray(result.venueMatches.venue);
					for(i=1; i LTE ArrayLen(results); i=i+1){
						QueryAddRow(returnStruct.results);
						QuerySetCell(returnStruct.results, 'id', results[i].id);
						QuerySetCell(returnStruct.results, 'name', results[i].name);
						QuerySetCell(returnStruct.results, 'url', results[i].url);
						QuerySetCell(returnStruct.results, 'city', results[i].location.city);
						QuerySetCell(returnStruct.results, 'country', results[i].location.country);
						QuerySetCell(returnStruct.results, 'street', results[i].location.street);
						QuerySetCell(returnStruct.results, 'postalcode', results[i].location.postalcode);
						QuerySetCell(returnStruct.results, 'lat', results[i].location['geo:point']['geo:lat']);
						QuerySetCell(returnStruct.results, 'long', results[i].location['geo:point']['geo:long']);						
					}
				}
				
			} 
			
			return returnStruct;			
		</cfscript>

	</cffunction>

</cfcomponent>