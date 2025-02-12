<cffunction name="getNextTabIndex" access="public" returntype="numeric" output="false">
	<cfscript>
		var ev              = event ?: getRequestContext();
		var currentTabIndex = Val( ev.getValue( name="_currentTabIndex", defaultValue=0, private=true ) );

		ev.setValue( name="_currentTabIndex", value=++currentTabIndex, private=true );

		return currentTabIndex;
	</cfscript>
</cffunction>

<cffunction name="stripTags" access="public" returntype="string" output="false">
	<cfargument name="stringValue" type="string" required="true" />
	<cfreturn ReReplaceNoCase( stringValue , "<[^>]*>","", "all" ) />
</cffunction>

<cffunction name="hasTags" access="public" returntype="boolean" output="false">
	<cfargument name="stringValue" type="string" required="true" />
	<cfreturn IsTrue( ReFind(  "<[^>]*>",stringValue ) ) />
</cffunction>
