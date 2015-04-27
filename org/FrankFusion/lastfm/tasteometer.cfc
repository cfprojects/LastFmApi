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

	<cffunction name="tasteCompare" access="public" returntype="struct" output="false" hint="Get a Tasteometer score from two inputs, along with a list of shared artists. If the input is a User or a Myspace URL, some additional information is returned. Function renamed due to conflict with coldfusion">
		<cfargument name="type1" type="string" required="true" hint="'user' | 'artists' | 'myspace'" />
		<cfargument name="type2" type="string" required="true" hint="'user' | 'artists' | 'myspace'" />
		<cfargument name="value1" type="string" required="true" hint="[Last.fm username] | [Comma-separated artist names] | [MySpace profile URL]" />
		<cfargument name="value2" type="string" required="true" hint="[Last.fm username] | [Comma-separated artist names] | [MySpace profile URL]" />
		<cfargument name="limit" type="numeric" required="false" default="5" hint="How many shared artists to display" />
		
		<cfscript>
			var args = StructNew();
			var result = "";
			var returnStruct = StructNew();
			var i = 0;
			
			args['type1'] = arguments.type1;
			args['type2'] = arguments.type2;
			args['value1'] = arguments.value1;
			args['value2'] = arguments.value2;
			args['limit'] = arguments.limit;
			
			result = super.callMethod('tasteometer.compare', args);
			if(IsDefined('result.comparison.result')){
				result = result.comparison.result;
				returnStruct['score'] = result.score;
				returnStruct['artists'] = QueryNew('name,url,smallImage,mediumImage,largeImage,extraLargeImage');
				returnStruct['matches'] = 0;
				
				if(IsDefined('result.artists.artist')){
					returnStruct['matches'] = result.artists.matches;
					result = super.ensureArray(result.artists.artist);
					
					for(i=1; i LTE ArrayLen(result); i=i+1){
						QueryAddRow(returnStruct.artists);
						QuerySetCell(returnStruct.artists,'name', result[i].name);
						QuerySetCell(returnStruct.artists,'url', result[i].url);
						
						if(StructKeyExists(result[i], 'image')){
							result[i].image = super.parseImages(result[i].image);
							QuerySetCell(returnStruct.artists,'smallImage', result[i].image.small);
							QuerySetCell(returnStruct.artists,'mediumImage', result[i].image.medium);
							QuerySetCell(returnStruct.artists,'largeImage', result[i].image.large);
							QuerySetCell(returnStruct.artists,'extraLargeImage', result[i].image.extraLarge);
						}
					}
				}
			}
			
			
			return returnStruct;
		</cfscript>
	</cffunction>

</cfcomponent>