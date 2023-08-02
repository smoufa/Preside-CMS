<cfscript>
	site = event.getSite();
	activeTab      = rc.tab ?: "sitetree";

	prc.pageIcon   = activeTab == "page" ? "database" : "sitemap";
	prc.pageTitle  = site.name ?: translateResource( "cms:sitetree" );

	activeTree          = prc.activeTree ?: [];
	trashCount          = prc.trashCount ?: 0;
</cfscript>

<cfoutput>
	<div class="tabbable">
		<ul class="nav nav-tabs">
			<li<cfif activeTab=="sitetree"> class="active"</cfif>>
				<a href="##tab-sitetree" data-toggle="tab" >
					<i class="fa fa-fw fa-sitemap" title="#HtmlEditFormat( prc.pageTitle )#"></i>&nbsp;

					<span class="hidden-xs">
						#prc.pageTitle#
					</span>
				</a>
			</li>
			<li<cfif activeTab=="page"> class="active"</cfif>>
				<a href="##tab-page" data-toggle="tab" >
					<i class="fa fa-fw fa-database" title="#HtmlEditFormat( translateResource( "cms:sitetree.tab.page.title" ) )#"></i>&nbsp;

					<span class="hidden-xs">
						#translateResource( "cms:sitetree.tab.page.title" )#
					</span>
				</a>
			</li>
		</ul>
		<div class="tab-content">
			<div class="tab-pane<cfif activeTab=="sitetree"> active</cfif>" id="tab-sitetree">
				#renderView( view="/admin/sitetree/index", args=args )#
			</div>
			<div class="tab-pane<cfif activeTab=="page"> active</cfif>" id="tab-page">
				#renderView( view="/admin/sitetree/_pageObjectTab", args=args )#
			</div>
		</div>
	</div>
</cfoutput>
