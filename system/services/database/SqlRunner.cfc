component singleton=true {

// CONSTRUCTOR
	/**
	 * @logger.inject defaultLogger
	 */
	public any function init( required any logger ) output=false {
		_setLogger( arguments.logger );

		return this;
	}

// PUBLIC API METHODS
	public any function runSql(
		  required string sql
		, required string dsn
		,          array  params
		,          string returntype="recordset"
	) output=false {
		var result = "";
		var params = {};
		var options = { datasource=arguments.dsn, name="result" };

		arguments.sql = _deObfuscate( arguments.sql );

		_getLogger().debug( arguments.sql );

		if ( arguments.returntype == "info" ) {
			var info = "";
			options.result = "info";
		}

		if ( StructKeyExists( arguments, "params" ) ) {
			for( var param in arguments.params ){
				param.value = param.value ?: "";

				if ( !IsSimpleValue( param.value ) ) {
					throw(
						  type = "SqlRunner.BadParam"
						, message = "SQL Param values must be simple values"
						, detail = "The value of the param, [#param.name#], was not of a simple type"
					);
				}

				if ( param.type == 'cf_sql_bit' && !IsNumeric( param.value ) ) {
					param.value = IsBoolean( param.value ) && param.value ? 'true' : 'false';
				}

				if ( !Len( Trim( param.value ) ) ) {
					param.null    = true;
					param.nulls   = true; // patch bug with various versions of Lucee
					param.list    = false;
					arguments.sql = _transformNullClauses( arguments.sql, param.name );
				}

				param.cfsqltype = param.type; // mistakenly had thought we could do param.type - alas no, so need to fix it to the correct argument name here

				if ( StructKeyExists( param, "name" ) ) {
					params[ param.name ] = param;
					params[ param.name ].delete( "name" );
				} else {
					if ( !IsArray( params ) ) {
						params = [];
					}
					params.append( param );
				}
			}
		}

		result = QueryExecute( sql=arguments.sql, params=params, options=options );

		if ( arguments.returntype eq "info" ) {
			return info;
		} else {
			return result;
		}
	}

// PRIVATE UTILITY
	private string function _transformNullClauses( required string sql, required string paramName ) {
		var hasClause = arguments.sql.reFindNoCase( "\swhere\s" );

		if ( !hasClause ) {
			return arguments.sql;
		}

		var preClause  = arguments.sql.reReplaceNoCase( "^(.*?\swhere)\s.*$", "\1" );
		var postClause = arguments.sql.reReplaceNoCase( "^.*?\swhere\s", " " );

		postClause = postClause.reReplaceNoCase("\s!= :#arguments.paramName#", " is not null", "all" );
		postClause = postClause.reReplaceNoCase("\s= :#arguments.paramName#", " is null", "all" );

		return preClause & postClause
	}

	private string function _deObfuscate( required string sql ) {
		var matched = {};

		do {
			matched = _findNextObfuscation( arguments.sql );

			if ( Len( Trim( matched.pattern ?: "" ) ) && Len( Trim( matched.decoded ?: "" ) ) ) {
				arguments.sql = Replace( arguments.sql, matched.pattern, matched.decoded, "all" );
			}

		} while ( StructCount( matched ) );

		return arguments.sql;
	}

	private struct function _findNextObfuscation( required string sql ) {
		var obfsPattern = "{{base64:([A-Za-z0-9\+\/=]+)}}";
		var match       = ReFindNoCase( obfsPattern, arguments.sql, 1, true );
		var matched     = {};

		if ( ArrayLen( match.len ) eq 2 and match.len[1] and match.len[2] ) {
			matched.pattern = Mid( arguments.sql, match.pos[1], match.len[1] );
			matched.decoded = ToString( ToBinary( ReReplace( matched.pattern, obfsPattern, "\1" ) ) );
		}

		return matched;
	}

// GETTERS AND SETTERS
	private any function _getLogger() output=false {
		return _logger;
	}
	private void function _setLogger( required any logger ) output=false {
		_logger = arguments.logger;
	}
}