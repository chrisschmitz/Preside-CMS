component extends="preside.system.base.AdminHandler" {

	property name="dao"        inject="presidecms:object:email_blueprint";
	property name="messageBox" inject="coldbox:plugin:messageBox";

	function prehandler( event, rc, prc ) {
		super.preHandler( argumentCollection = arguments );

		_checkPermissions( event=event, key="read" );

		event.addAdminBreadCrumb(
			  title = translateResource( "cms:emailcenter.blueprints.breadcrumb" )
			, link  = event.buildAdminLink( linkTo="emailCenter.Blueprints" )
		);

		prc.pageIcon = "envelope";
	}

	function index( event, rc, prc ) {
		prc.pageTitle    = translateResource( "cms:emailcenter.blueprints.page.title" );
		prc.pageSubtitle = translateResource( "cms:emailcenter.blueprints.page.subtitle" );

		prc.canAdd    = hasCmsPermission( "emailCenter.blueprints.add"    );
		prc.canDelete = hasCmsPermission( "emailCenter.blueprints.delete" );
	}

	function add( event, rc, prc ) {
		_checkPermissions( event=event, key="add" );

		prc.pageTitle    = translateResource( "cms:emailcenter.blueprints.add.page.title" );
		prc.pageSubtitle = translateResource( "cms:emailcenter.blueprints.add.page.subtitle" );

		prc.canPublish   = hasCmsPermission( "emailCenter.blueprints.saveDraft" );
		prc.canSaveDraft = hasCmsPermission( "emailCenter.blueprints.publish"   );

		if ( !prc.canPublish && !prc.canSaveDraft ) {
			event.adminAccessDenied();
		}

		event.addAdminBreadCrumb(
			  title = translateResource( "cms:emailcenter.blueprints.add.page.breadcrumb" )
			, link  = event.buildAdminLink( linkTo="emailCenter.Blueprints.add" )
		);
	}
	function addAction( event, rc, prc ) {
		_checkPermissions( event=event, key="add" );

		var saveAction = ( rc._saveAction ?: "savedraft" ) == "publish" ? "publish" : "savedraft";
		_checkPermissions( event=event, key=saveAction );

		prc.canPublish   = hasCmsPermission( "emailCenter.blueprints.saveDraft" );
		prc.canSaveDraft = hasCmsPermission( "emailCenter.blueprints.publish"   );

		runEvent(
			  event          = "admin.DataManager._addRecordAction"
			, prePostExempt  = true
			, private        = true
			, eventArguments = {
				  object            = "email_blueprint"
				, errorAction       = "emailCenter.Blueprints.add"
				, addAnotherAction  = "emailCenter.Blueprints.add"
				, successAction     = "emailCenter.Blueprints"
				, redirectOnSuccess = true
				, audit             = true
				, auditType         = "emailblueprints"
				, auditAction       = saveAction == "publish" ? "add_record" : "add_draft_record"
				, draftsEnabled     = true
				, canPublish        = prc.canPublish
				, canSaveDraft      = prc.canSaveDraft
			}
		);
	}

	function edit( event, rc, prc ) {
		_checkPermissions( event=event, key="edit" );
		prc.canSaveDraft = hasCmsPermission( "emailCenter.blueprints.saveDraft" );
		prc.canPublish   = hasCmsPermission( "emailCenter.blueprints.publish"   );
		if ( !prc.canSaveDraft && !prc.canPublish ) {
			event.adminAccessDenied()
		}

		var id      = rc.id ?: "";
		var version = Val( rc.version ?: "" );

		prc.record = dao.selectData(
			  filter             = { id=id }
			, fromVersionTable   = true
			, allowDraftVersions = true
			, specificVersion    = version
		);

		if ( !prc.record.recordCount ) {
			messageBox.error( translateResource( uri="cms:emailcenter.blueprints.record.not.found.error" ) );
			setNextEvent( url=event.buildAdminLink( linkTo="emailCenter.Blueprints" ) );
		}
		prc.record = queryRowToStruct( prc.record );

		prc.pageTitle    = translateResource( uri="cms:emailcenter.blueprints.edit.page.title", data=[ prc.record.name ] );
		prc.pageSubtitle = translateResource( uri="cms:emailcenter.blueprints.edit.page.subtitle", data=[ prc.record.name ] );

		event.addAdminBreadCrumb(
			  title = translateResource( uri="cms:emailcenter.blueprints.edit.page.breadcrumb", data=[ prc.record.name ] )
			, link  = event.buildAdminLink( linkTo="emailCenter.Blueprints.edit", queryString="id=#id#" )
		);
	}
	function editAction( event, rc, prc ) {
		_checkPermissions( event=event, key="edit" );

		var id = rc.id ?: "";
		var saveAction = ( rc._saveAction ?: "savedraft" ) == "publish" ? "publish" : "savedraft";
		_checkPermissions( event=event, key=saveAction );

		prc.record = dao.selectData( filter={ id=id } );

		if ( !prc.record.recordCount ) {
			messageBox.error( translateResource( uri="cms:emailcenter.blueprints.record.not.found.error" ) );
			setNextEvent( url=event.buildAdminLink( linkTo="emailCenter.Blueprints" ) );
		}

		runEvent(
			  event          = "admin.DataManager._editRecordAction"
			, private        = true
			, prePostExempt  = true
			, eventArguments = {
				  object            = "email_blueprint"
				, errorAction       = "emailCenter.Blueprints.edit"
				, successUrl        = event.buildAdminLink( linkto="emailCenter.Blueprints" )
				, redirectOnSuccess = true
				, audit             = true
				, auditType         = "emailblueprints"
				, auditAction       = ( saveAction == "publish" ? "publish_record" : "save_draft" )
				, draftsEnabled     = true
				, canPublish        = hasCmsPermission( "emailCenter.blueprints.saveDraft" )
				, canSaveDraft      = hasCmsPermission( "emailCenter.blueprints.publish"   )
			}
		);
	}

	function deleteAction( event, rc, prc ) {
		_checkPermissions( event=event, key="delete" );

		runEvent(
			  event          = "admin.DataManager._deleteRecordAction"
			, private        = true
			, prePostExempt  = true
			, eventArguments = {
				  object       = "email_blueprint"
				, postAction   = "emailCenter.Blueprints"
				, audit        = true
				, auditType    = "emailblueprints"
				, auditAction  = "delete_record"
			}
		);
	}

	public void function versionHistory( event, rc, prc ) {
		var id = rc.id ?: "";

		prc.record = dao.selectData( id=id, selectFields=[ "name" ] );
		if ( !prc.record.recordCount ) {
			messageBox.error( translateResource( uri="cms:emailcenter.blueprints.record.not.found.error" ) );
			setNextEvent( url=event.buildAdminLink( linkTo="emailCenter.Blueprints" ) );
		}
		prc.pageTitle    = translateResource( uri="cms:emailcenter.blueprints.versionHistory.page.title"   , data=[ prc.record.name ] );
		prc.pageSubTitle = translateResource( uri="cms:emailcenter.blueprints.versionHistory.page.subTitle", data=[ prc.record.name ] );

		event.addAdminBreadCrumb(
			  title = translateResource( uri="cms:emailcenter.blueprints.versionHistory.breadcrumb"  , data=[ prc.record.name ] )
			, link  = event.buildAdminLink( linkTo="emailCenter.Blueprints.versionHistory", queryString="id=" & id )
		);
	}

	public void function getRecordsForAjaxDataTables( event, rc, prc ) {
		_checkPermissions( event=event, key="read" );

		runEvent(
			  event          = "admin.DataManager._getObjectRecordsForAjaxDataTables"
			, prePostExempt  = true
			, private        = true
			, eventArguments = {
				  object        = "email_blueprint"
				, gridFields    = "name"
				, actionsView   = "admin.emailCenter/Blueprints._gridActions"
				, draftsEnabled = true
			}
		);
	}

	private string function _gridActions( event, rc, prc, args={} ) {
		args.id                = args.id ?: "";
		args.deleteRecordLink  = event.buildAdminLink( linkTo="emailCenter.Blueprints.deleteAction"  , queryString="id=" & args.id );
		args.editRecordLink    = event.buildAdminLink( linkTo="emailCenter.Blueprints.edit"          , queryString="id=" & args.id );
		args.viewHistoryLink   = event.buildAdminLink( linkTo="emailCenter.Blueprints.versionHistory", queryString="id=" & args.id );
		args.deleteRecordTitle = translateResource( "cms:emailcenter.blueprints.delete.record.link.title" );
		args.objectName        = "email_blueprint";
		args.canEdit           = hasCmsPermission( "emailCenter.blueprints.edit"   );
		args.canDelete         = hasCmsPermission( "emailCenter.blueprints.delete" );
		args.canViewHistory    = hasCmsPermission( "emailCenter.blueprints.view"   );

		return renderView( view="/admin/emailCenter/Blueprints/_gridActions", args=args );
	}

	public void function getHistoryForAjaxDatatables( event, rc, prc ) {
		var id = rc.id ?: "";

		prc.record = dao.selectData( id=id, selectFields=[ "name as label" ] );
		if ( !prc.record.recordCount ) {
			event.notFound();
		}

		runEvent(
			  event          = "admin.DataManager._getRecordHistoryForAjaxDataTables"
			, prePostExempt  = true
			, private        = true
			, eventArguments = {
				  object     = "email_blueprint"
				, recordId   = id
				, actionsView = "admin/emailCenter/Blueprints/_historyActions"
			}
		);
	}

// private utility
	private void function _checkPermissions( required any event, required string key ) {
		if ( !hasCmsPermission( "emailCenter.blueprints." & arguments.key ) ) {
			event.adminAccessDenied();
		}
	}

}