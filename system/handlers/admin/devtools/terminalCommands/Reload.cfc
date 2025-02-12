component hint="Reload all or part of your preside application" {

	property name="jsonRpc2Plugin"           inject="JsonRpc2";
	property name="applicationReloadService" inject="applicationReloadService";
	property name="disableMajorReloads"      inject="coldbox:setting:disableMajorReloads";

	private function index( event, rc, prc ) {
		var params       = jsonRpc2Plugin.getRequestParams();
		var environment  = controller.getConfigSettings().environment;
		var targetName   = "";
		var target       = "";
		var validTargets = {
			  all       = { reloadMethod="reloadAll"           , flagRequiredInProduction=true,  isMajorReload=true , description="Reloads the entire application"                           , successMessage="Application cleared, please refresh the page to complete the reload" }
			, db        = { reloadMethod="dbSync"              , flagRequiredInProduction=true,  isMajorReload=true,  description="Synchronises the database with Preside Object definitions", successMessage="Database objects synchronized" }
			, caches    = { reloadMethod="clearCaches"         , flagRequiredInProduction=false, isMajorReload=false, description="Flushes all caches"                                       , successMessage="Caches cleared" }
			, forms     = { reloadMethod="reloadForms"         , flagRequiredInProduction=false, isMajorReload=false, description="Reloads the form definitions"                             , successMessage="Form definitions reloaded" }
			, i18n      = { reloadMethod="reloadI18n"          , flagRequiredInProduction=false, isMajorReload=false, description="Reloads the i18n resource bundles"                        , successMessage="Resource bundles reloaded" }
			, objects   = { reloadMethod="reloadPresideObjects", flagRequiredInProduction=false, isMajorReload=true,  description="Reloads the preside object definitions"                   , successMessage="Preside object definitions reloaded" }
			, widgets   = { reloadMethod="reloadWidgets"       , flagRequiredInProduction=false, isMajorReload=false, description="Reloads the widget definitions"                           , successMessage="Widget definitions reloaded" }
			, pageTypes = { reloadMethod="reloadPageTypes"     , flagRequiredInProduction=false, isMajorReload=true,  description="Reloads the page type definitions"                        , successMessage="Page type definitions reloaded" }
			, static    = { reloadMethod="reloadStatic"        , flagRequiredInProduction=false, isMajorReload=false, description="Rescans and compiles JS and CSS"                          , successMessage="Static assets rescanned and recompiled" }
		};

		params = IsArray( params.commandLineArgs ?: "" ) ? params.commandLineArgs : [];

		if ( !params.len() || !StructKeyExists( validTargets, params[1] ) ) {
			var usageMessage = Chr(10) & "[[b;white;]Usage:] reload [#StructKeyList( validTargets, '|' )#]" & Chr(10) & Chr(10)
			                           & "Reload types:" & Chr(10) & Chr(10);

			for( var target in validTargets ) {
				usageMessage &= "    [[b;white;]#target#]#RepeatString( ' ', 12-Len(target) )#: #validTargets[ target ].description#" & Chr(10);
			}

			return usageMessage;
		}

		target        = validTargets[ params[1] ];
		var forceFlag = ( params[2] ?: "" ) == "--force";

		if ( environment == "production" && ( target.flagRequiredInProduction ?: false ) && !forceFlag ) {
			return Chr(10) & "[[b;red;]--force flag is required to perform this action in a production environment]" & Chr(10);
		}

		if ( target.isMajorReload && isBoolean( disableMajorReloads ) && disableMajorReloads ) {
			return Chr(10) & "[[b;red;]Major reloads are disallowed]" & Chr(10);
		}

		var start = GetTickCount();
		applicationReloadService[ target.reloadMethod ]();
		var timeTaken = GetTickCount() - start;

		return Chr(10) & "[[b;white;]Reload completed with message: ]" & target.successMessage & Chr(10)
		               & "[[b;white;]Time taken:] #NumberFormat( timeTaken )# ms" & Chr( 10 );
	}
}