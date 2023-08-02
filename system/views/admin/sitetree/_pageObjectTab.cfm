<cfscript>
	args  = args ?: {};
	rc.id = "page";
</cfscript>
<cfoutput>
	#renderViewlet( event="admin.datamanager.object", cache=false, private=false, prePostExempt=false, args=args )#
	#prc.listingView#
</cfoutput>