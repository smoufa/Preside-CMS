( function( $ ){

	$.fn.treeTable = function(){
		var openChildren, closeChildren, toggleRow;

		openChildren = function( $parent ){
			var $childRows = $parent.data( "children" );
			$childRows.show().each( function(){
				var $childRow = $( this );

				if ( $childRow.data( "children" ) && !$childRow.data( "closed" ) ) {
					openChildren( $childRow );
				}
			} );
		};

		closeChildren = function( $parent ){
			var $childRows = $parent.data( "children" );
			$childRows.hide().each( function(){
				var $childRow = $( this );

				if ( $childRow.data( "children" ) ) {
					closeChildren( $childRow );
				}
			} );
		};

		toggleRow = function( $row ){
			var $toggler = $row.data( "toggler" )
			  , closed   = $row.data( "closed" )


			$toggler.toggleClass( "fa-caret-right" );
			$toggler.toggleClass( "fa-caret-down" );

			closed ? openChildren( $row ) : closeChildren( $row );

			$row.data( "closed", !closed );
		}

		return this.each( function(){
			var $table      = $( this )
			  , $parentRows = $table.find( "tr[data-has-children='true']" )
			  , $selected   = $table.find( "tr.selected:first" );

			$parentRows.each( function(){
				var $parentRow = $( this )
				  , $children  = $table.find( "tr[data-parent='" + $parentRow.data( "id" ) + "']" )
				  , $toggler   = $( '<a class="fa fa-lg fa-fw fa-caret-right tree-toggler"></a>' );

				$toggler.insertBefore( $parentRow.find( '.page-type-icon' ) );
				$toggler.data( "parentRow", $parentRow );

				$parentRow.data( "toggler" , $toggler );
				$parentRow.data( "children", $children );
				$parentRow.data( "closed"  , true );

				$children.hide();
			} );

			$table.on( "click", ".tree-toggler", function( e ){
				e.preventDefault();

				var $toggler   = $( this )
				  , $parentRow = $toggler.data( "parentRow" )

				toggleRow( $parentRow );
			} );


			if ( $selected.length ) {
				var $parent = $table.find( "tr[data-id='" + ( $selected.data( "parent" ) || '' ) + "']"  );
				while( $parent.length ){
					toggleRow( $parent );

					$parent = $table.find( "tr[data-id='" + ( $parent.data( "parent" ) || '' ) + "']"  );
				}

			} else {
				toggleRow( $parentRows.first() );
			}

		} );
	};

	$( '.tree-table' ).treeTable();

} )( presideJQuery );