<cfscript>
	recordId = rc.id      ?: "";
	version  = rc.version ?: "";
</cfscript>

<cfoutput>
	#renderViewlet( event='admin.datamanager.versionNavigator', args={
		  object         = "email_blueprint"
		, id             = recordId
		, version        = version
		, isDraft        = IsTrue( prc.record._version_is_draft ?: "" )
		, baseUrl        = event.buildAdminLink( linkto="emailCenter.Blueprints.edit", queryString="id=#recordId#&version=" )
		, allVersionsUrl = event.buildAdminLink( linkto="emailCenter.Blueprints.versionHistory", queryString="id=#recordId#" )
	} )#

	#renderView( view="/admin/datamanager/_editRecordForm", args={
		  object           = "email_blueprint"
		, id               = rc.id      ?: ""
		, record           = prc.record ?: {}
		, editRecordAction = event.buildAdminLink( linkTo='emailCenter.Blueprints.editAction' )
		, cancelAction     = event.buildAdminLink( linkTo='emailCenter.Blueprints' )
		, useVersioning    = true
		, draftsEnabled    = true
		, canPublish       = IsTrue( prc.canSaveDraft ?: "" )
		, canSaveDraft     = IsTrue( prc.canPublish   ?: "" )
	} )#
</cfoutput>