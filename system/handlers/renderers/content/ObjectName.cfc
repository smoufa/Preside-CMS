component {

	property name="presideObjectService" inject="presideObjectService";
	property name="pageTypesService"     inject="pageTypesService";

	private string function default( event, rc, prc, args={} ){
		var objectId = args.data ?: "";

		if ( presideObjectService.objectExists( objectId ) ) {
			var uriRoot    = presideObjectService.getResourceBundleUriRoot( objectId );
			var isPageType = presideObjectService.isPageType( objectId );
			var fullUri    = uriRoot & ( isPageType ? "name" : "title.singular" );

			return translateResource( uri=fullUri, defaultValue=objectId );
		}

		return "";
	}

	private string function admindatatable( event, rc, prc, args={} ){
		var objectId = args.data ?: "";

		if ( presideObjectService.objectExists( objectId ) ) {
			var uriRoot      = presideObjectService.getResourceBundleUriRoot( objectId );
			var isPageType   = presideObjectService.isPageType( objectId );
			var isSystemPage = isPageType && pageTypesService.isSystemPageType( objectId );
			var fullUri      = uriRoot & ( isPageType ? "name" : "title.singular" );
			var objectLabel  = translateResource( uri=fullUri, defaultValue=objectId );
			var defaultIcon  = isSystemPage ? "fa-cog" : "fa-database";
			var objectIcon   = translateResource( uri=uriRoot & "iconClass", defaultValue=defaultIcon );
			return '<i class="fa fa-fw #objectIcon#"></i> ' & objectLabel;
		}

		return "";
	}

}