component extends="coldbox.system.Interceptor" {

	property name="tenancyService" inject="delayedInjector:tenancyService";

// PUBLIC
	public void function configure() {}

	public void function postReadPresideObject( event, interceptData ) {
		tenancyService.get().injectObjectTenancyProperties(
			  objectMeta = interceptData.objectMeta ?: {}
			, objectName = ListLast( interceptData.objectMeta.name ?: "", "." )
		);
	}

	public void function prePrepareObjectFilter( event, interceptData ) {
		var filter = tenancyService.get().getTenancyFilter( argumentCollection=interceptData );
		if ( filter.count() ) {
			interceptData.extraFilters = interceptData.extraFilters ?: [];
			interceptData.extraFilters.append( filter );
		}
	}

	public void function onCreateSelectDataCacheKey( event, interceptData ) {
		var tenancyCacheKey = tenancyService.get().getTenancyCacheKey( argumentCollection=interceptData );
		if ( tenancyCacheKey.len() ) {
			interceptData.cacheKey = interceptData.cacheKey ?: "";
			interceptData.cacheKey &= tenancyCacheKey;
		}
	}

	public void function preInsertObjectData( event, interceptData ) {
		var tenancyData = tenancyService.get().getTenancyFieldsForInsertOrUpdateData( argumentCollection=interceptData );
		if ( tenancyData.count() ) {
			interceptData.data = interceptData.data ?: {};
			interceptData.data.append( tenancyData );
		}
	}

	public void function preValidateForm( event, interceptData ) {
		if ( Len( interceptData.objectName ?: "" ) ) {
			var tenancyData = tenancyService.get().getTenancyFieldsForInsertOrUpdateData( argumentCollection=interceptData );
			if ( tenancyData.count() ) {
				interceptData.data = interceptData.data ?: {};
				interceptData.data.append( tenancyData );
			}
		}
	}
}