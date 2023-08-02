component extends="preside.system.base.AdminHandler" {

	property name="presideObjectService" inject="presideObjectService";
	property name="pageTypesService"     inject="pageTypesService";

	private string function preRenderListing( event, rc, prc, args={} ) {
		return '<p class="alert alert-warning">This listing is an alternate view of your sitetree.</p>';
	}

	private string function buildViewRecordLink( event, rc, prc, args={} ) {
		return buildEditRecordLink( argumentCollection=arguments );
	}

	private string function buildEditRecordLink( event, rc, prc, args={} ) {
		return event.buildAdminLink( linkTo="sitetree.editPage", querystring="id=#( args.recordId ?: "" )#" );
	}

	private void function preFetchRecordsForGridListing( event, rc, prc, args={} ) {
		args.extraFilters = args.extraFilters ?: [];
		args.extraFilters.append( { filter={ trashed = false } } );
	}

	private void function postDecorateRecordsForGridListing( event, rc, prc, args={} ) {
		var records         = args.records ?: queryNew( '' );
		var isSystemPageCol = arrayNew();

		var i = 1;
		for ( var record in records ) {
			querySetCell( records, "page_type", renderContent( "ObjectName", record.page_type, "admindatatable" ), i++ );

			var isPageType   = presideObjectService.isPageType( record.page_type );
			var isSystemPage = isPageType && pageTypesService.isSystemPageType( record.page_type );
			arrayAppend( isSystemPageCol, renderContent( "Boolean", isSystemPage, "admin" ) );
		}

		queryAddColumn( records, "_isSystemPage" , isSystemPageCol );
		arrayAppend( args.gridFields, "_isSystemPage" );
	}

}