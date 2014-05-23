component output="false" extends="tests.resources.HelperObjects.PresideTestCase" {

// SETUP, etc
	function setup() {
		super.setup();

		testPerms = {
			  cms          = [ "login" ]
			, sitetree     = [ "navigate", "read", "add", "edit", "delete" ]
			, assetmanager = {
				  folders = [ "navigate", "read", "add", "edit", "delete" ]
				, assets  = [ "navigate", "read", "add", "edit", "delete" ]
				, blah    = {
					  test = [ "meh", "doh", "blah" ]
					, test2 = [ "tehee" ]
				}
			 }
			, groupmanager = [ "navigate", "read", "add", "edit", "delete" ]
		};

		testRoles = {
			  administrator = [ "*" ]
			, tester        = [ "*.delete", "assetmanager.*.read", "sitetree.*", "!groupmanager.delete", "groupmanager.edit", "!*.add" ]
			, user          = [ "cms.login", "assetmanager.blah.test.*", "sitetree.navigate" ]
		};
	}

// TESTS
	function test01_listRoles_shouldReturnEmptyArray_whenNoRolesRegistered(){
		super.assertEquals( [], _getPermissionService().listRoles() );
	}

	function test02_listRoles_shouldReturnArrayOfConfiguredRoles(){
		var expected = [ "administrator", "tester", "user" ];
		var actual   = _getPermissionService( roles=testRoles ).listRoles();

		actual.sort( "textnocase" );

		super.assertEquals( expected, actual );
	}

	function test03_listPermissionKeys_shouldReturnEmptyArrayWhenNoPermissionsSet(){
		var expected = [ ];
		var actual   = _getPermissionService( roles=testRoles ).listPermissionKeys();

		super.assertEquals( expected, actual );
	}

	function test04_listPermissionKeys_shouldReturnArrayOfFlattendPermissionKeys(){
		var expected = [
			  "cms.login"
			, "sitetree.navigate"
			, "sitetree.read"
			, "sitetree.add"
			, "sitetree.edit"
			, "sitetree.delete"
			, "assetmanager.folders.navigate"
			, "assetmanager.folders.read"
			, "assetmanager.folders.add"
			, "assetmanager.folders.edit"
			, "assetmanager.folders.delete"
			, "assetmanager.assets.navigate"
			, "assetmanager.assets.read"
			, "assetmanager.assets.add"
			, "assetmanager.assets.edit"
			, "assetmanager.assets.delete"
			, "assetmanager.blah.test.meh"
			, "assetmanager.blah.test.doh"
			, "assetmanager.blah.test.blah"
			, "assetmanager.blah.test2.tehee"
			, "groupmanager.navigate"
			, "groupmanager.read"
			, "groupmanager.add"
			, "groupmanager.edit"
			, "groupmanager.delete"
		];
		var actual = _getPermissionService( permissions=testPerms ).listPermissionKeys();

		expected.sort( "textnocase" );
		actual.sort( "textnocase" );

		super.assertEquals( expected, actual );
	}

	function test05_listPermissionKeys_shouldReturnPermissionsThatHaveBeenExplicitlyConfiguredOnPassedRole(){
		var expected = [
			  "assetmanager.blah.test.blah"
			, "assetmanager.blah.test.doh"
			, "assetmanager.blah.test.meh"
			, "cms.login"
			, "sitetree.navigate"
		];
		var actual   = _getPermissionService( permissions=testPerms, roles=testRoles ).listPermissionKeys( role="user" );

		super.assertEquals( expected, actual.sort( "textnocase" ) );
	}

	function test06_listPermissionKeys_shouldReturnExpandedPermissions_whereSuppliedRoleHasPermissionsConfiguredWithWildCardsAndExclusions(){
		var expected = [
			  "sitetree.navigate"
			, "sitetree.read"
			, "sitetree.edit"
			, "sitetree.delete"
			, "assetmanager.folders.read"
			, "assetmanager.assets.read"
			, "assetmanager.folders.delete"
			, "assetmanager.assets.delete"
			, "groupmanager.edit"
		];

		var actual   = _getPermissionService( permissions=testPerms, roles=testRoles ).listPermissionKeys( role="tester" );

		super.assertEquals( expected.sort( "textnocase" ), actual.sort( "textnocase" ) );
	}

	function test07_listPermissionKeys_shouldReturnEmptyArray_whenPassedGroupDoesNotExist(){
		var actual   = "";
		var permsService = _getPermissionService( permissions=testPerms, roles=testRoles );
		var expected = [];

		mockPresideObjectService.$( "selectData" )
			.$args( objectName="security_group", selectFields=["roles"], id="testgroup" )
			.$results( QueryNew('roles' ) );

		actual = permsService.listPermissionKeys( group="testgroup" );

		super.assertEquals( expected.sort( "textnocase" ), actual.sort( "textnocase" ) );
	}

	function test08_listPermissionKeys_shouldReturnPermissionsForGivenGroup_basedOnTheGroupsAssociatedRoles(){
		var actual   = "";
		var permsService = _getPermissionService( permissions=testPerms, roles=testRoles );
		var expected = [
			  "sitetree.navigate"
			, "sitetree.read"
			, "sitetree.edit"
			, "sitetree.delete"
			, "assetmanager.folders.read"
			, "assetmanager.assets.read"
			, "assetmanager.folders.delete"
			, "assetmanager.assets.delete"
			, "groupmanager.edit"
			, "cms.login"
			, "assetmanager.blah.test.meh"
			, "assetmanager.blah.test.doh"
			, "assetmanager.blah.test.blah"
		];

		mockPresideObjectService.$( "selectData" )
			.$args( objectName="security_group", selectFields=["roles"], id="testgroup" )
			.$results( QueryNew('roles', 'varchar', ['tester,user'] ) );

		actual = permsService.listPermissionKeys( group="testgroup" );

		super.assertEquals( expected.sort( "textnocase" ), actual.sort( "textnocase" ) );
	}

	function test09_listPermissionKeys_shouldReturnEmptyArray_whenPassedUserDoesHasNoGroups(){
		var actual   = "";
		var permsService = _getPermissionService( permissions=testPerms, roles=testRoles );
		var expected = [];

		mockPresideObjectService.$( "selectManyToManyData" )
			.$args( objectName="security_user", selectFields=["security_group"], propertyName="groups", id="testuser" )
			.$results( QueryNew('security_group' ) );

		actual = permsService.listPermissionKeys( user="testuser" );

		super.assertEquals( expected.sort( "textnocase" ), actual.sort( "textnocase" ) );
	}

	function test10_listPermissionKeys_shouldReturnPermissionKeysForAllGroupsAssociatedWithPassedUser(){
		var actual   = "";
		var permsService = _getPermissionService( permissions=testPerms, roles=testRoles );
		var expected = [
			  "sitetree.navigate"
			, "sitetree.read"
			, "sitetree.edit"
			, "sitetree.delete"
			, "assetmanager.folders.read"
			, "assetmanager.assets.read"
			, "assetmanager.folders.delete"
			, "assetmanager.assets.delete"
			, "groupmanager.edit"
			, "cms.login"
			, "assetmanager.blah.test.meh"
			, "assetmanager.blah.test.doh"
			, "assetmanager.blah.test.blah"
		];

		mockPresideObjectService.$( "selectManyToManyData" )
			.$args( objectName="security_user", selectFields=["security_group"], propertyName="groups", id="me" )
			.$results( QueryNew('security_group', 'varchar', [['testgroup'],['testgroup2']] ) );

		mockPresideObjectService.$( "selectData" )
			.$args( objectName="security_group", selectFields=["roles"], id="testgroup" )
			.$results( QueryNew('roles', 'varchar', ['tester'] ) );

		mockPresideObjectService.$( "selectData" )
			.$args( objectName="security_group", selectFields=["roles"], id="testgroup2" )
			.$results( QueryNew('roles', 'varchar', ['user'] ) );

		actual = permsService.listPermissionKeys( user="me" );

		super.assertEquals( expected.sort( "textnocase" ), actual.sort( "textnocase" ) );
	}

	function test11_hasPermission_shouldReturnTrue_whenLoggedInUserIsSystemUser(){
		var permsService = _getPermissionService( permissions=testPerms, roles=testRoles );

		mockLoginService.$( "getLoggedInUserId", "me" );
		mockLoginService.$( "isSystemUser", true );

		super.assert( permsService.hasPermission( permissionKey="some.key" ), "A system user should always have permission, yet method said no!" );
	}

	function test12_hasPermission_shouldReturnFalse_whenLoggedInUserIsNotSystemUserAndDoesNotHaveAccessToSuppliedPermissionKey(){
		var permsService = _getPermissionService( permissions=testPerms, roles=testRoles );

		mockLoginService.$( "getLoggedInUserId", "me" );
		mockLoginService.$( "isSystemUser", false );

		permsService.$( "listPermissionKeys" ).$args( user="me" ).$results( [ "some.key", "another.key" ] );

		super.assertFalse( permsService.hasPermission( permissionKey="key.i.do.not.have" ), "Shouldn't have permission, yet returned that I do" );
	}

	function test13_hasPermission_shoultReturnTrue_whenLoggedInUserIsNotSystemUserButHasAccessToSuppliedPermissionKey(){
		var permsService = _getPermissionService( permissions=testPerms, roles=testRoles );

		mockLoginService.$( "getLoggedInUserId", "me" );
		mockLoginService.$( "isSystemUser", false );

		permsService.$( "listPermissionKeys" ).$args( user="me" ).$results( [ "some.key", "another.key" ] );

		super.assert( permsService.hasPermission( permissionKey="another.key" ), "Should have permission, yet returned that I don't :(" );
	}

	function test14_hasPermission_shouldReturnTrue_whenPassedUserIsSystemUser(){
		var permsService = _getPermissionService( permissions=testPerms, roles=testRoles );

		mockLoginService.$( "getLoggedInUserId", "me" );
		mockLoginService.$( "isSystemUser", true );

		super.assert( permsService.hasPermission( permissionKey="some.key", userId="me" ), "A system user should always have permission, yet method said no!" );
	}

	function test15_hasPermission_shouldReturnFalse_whenPassedUserIsNotSystemUserAndDoesNotHaveAccessToSuppliedPermissionKey(){
		var permsService = _getPermissionService( permissions=testPerms, roles=testRoles );

		mockLoginService.$( "getLoggedInUserId", "me" );

		permsService.$( "listPermissionKeys" ).$args( user="someoneelse" ).$results( [ "some.key", "another.key" ] );

		super.assertFalse( permsService.hasPermission( permissionKey="key.i.do.not.have", userId="someoneelse" ), "Shouldn't have permission, yet returned that I do" );
	}

	function test16_hasPermission_shoultReturnTrue_whenPassedUserIsNotSystemUserButHasAccessToSuppliedPermissionKey(){
		var permsService = _getPermissionService( permissions=testPerms, roles=testRoles );

		mockLoginService.$( "getLoggedInUserId", "me" );

		permsService.$( "listPermissionKeys" ).$args( user="anotherUserThatIsNotMe" ).$results( [ "some.key", "another.key" ] );

		super.assert( permsService.hasPermission( permissionKey="another.key", userId="anotherUserThatIsNotMe" ), "Should have permission, yet returned that I don't :(" );
	}

	function test17_hasPermission_shouldReturnTrue_whenPassedInUserDoesNotHaveRolePermissionBUTdoesHaveContextPermissionForGivenContextAndKey(){
		var permsService = _getPermissionService( permissions=testPerms, roles=testRoles );
		var hasPerm      = "";

		mockLoginService.$( "getLoggedInUserId", "me" );
		mockLoginService.$( "isSystemUser", false );

		permsService.$( "listPermissionKeys" ).$args( user="me" ).$results( [ "some.key", "another.key" ] );
		mockPresideObjectService.$( "selectData" ).$args(
			  objectName = "security_user"
			, selectFields = [ "security_context_permission.granted", "security_context_permission.context_key" ]
			, forceJoins   = "inner"
			, filter       = {
				  "security_user.id"                          = "me"
				, "security_context_permision.permission_key" = "a.new.key"
				, "security_context_permission.context"       = "someContext"
				, "security_context_permission.context_key"   = [ "somekey" ]
			}
		).$results( QueryNew( 'granted', 'bit', [1] ) );

		hasPerm = permsService.hasPermission( permissionKey="a.new.key", context="someContext", contextKeys=[ "somekey" ] );

		super.assert( hasPerm, "Should have permission, yet returned that I don't :(" );
	}

	function test18_hasPermission_shouldReturnFalse_whenPassedInUserHasRolePermissionBUThasExplictContextPermissionDenialForGivenContextAndKey(){
		var permsService = _getPermissionService( permissions=testPerms, roles=testRoles );
		var hasPerm      = "";

		mockLoginService.$( "getLoggedInUserId", "me" );
		mockLoginService.$( "isSystemUser", false );

		permsService.$( "listPermissionKeys" ).$args( user="me" ).$results( [ "some.key", "another.key" ] );
		mockPresideObjectService.$( "selectData" ).$args(
			  objectName = "security_user"
			, selectFields = [ "security_context_permission.granted", "security_context_permission.context_key" ]
			, forceJoins   = "inner"
			, filter       = {
				  "security_user.id"                          = "me"
				, "security_context_permision.permission_key" = "some.key"
				, "security_context_permission.context"       = "anotherContext"
				, "security_context_permission.context_key"   = [ "anotherkey" ]
			}
		).$results( QueryNew( 'granted', 'bit', [0] ) );

		hasPerm = permsService.hasPermission( permissionKey="some.key", context="anotherContext", contextKeys=[ "anotherkey" ] );

		super.assertFalse( hasPerm, "Should not have permission, yet returned that I do :(" );
	}

	function test19_hasPermission_shouldReturnTrue_whenPassedInUserHasRolePermissionANDhasNoExplictContextPermissionSetForGivenContext(){
		var permsService = _getPermissionService( permissions=testPerms, roles=testRoles );
		var hasPerm      = "";

		mockLoginService.$( "getLoggedInUserId", "me" );
		mockLoginService.$( "isSystemUser", false );

		permsService.$( "listPermissionKeys" ).$args( user="me" ).$results( [ "some.key", "another.key" ] );
		mockPresideObjectService.$( "selectData" ).$args(
			  objectName = "security_user"
			, selectFields = [ "security_context_permission.granted", "security_context_permission.context_key" ]
			, forceJoins   = "inner"
			, filter       = {
				  "security_user.id"                          = "me"
				, "security_context_permision.permission_key" = "some.key"
				, "security_context_permission.context"       = "anotherContext"
				, "security_context_permission.context_key"   = [ "anotherkey" ]
			}
		).$results( QueryNew( 'granted' ) );

		hasPerm = permsService.hasPermission( permissionKey="some.key", context="anotherContext", contextKeys=[ "anotherkey" ] );

		super.assert( hasPerm, "Should have permission, yet returned that I do not :(" );
	}

	function test20_hasPermission_shouldReturnFirstGrantOrDenial_whenMultipleContextKeysAreSuppliedThatHaveMatches(){
		var permsService = _getPermissionService( permissions=testPerms, roles=testRoles );
		var hasPerm      = "";

		mockLoginService.$( "getLoggedInUserId", "me" );
		mockLoginService.$( "isSystemUser", false );

		permsService.$( "listPermissionKeys" ).$args( user="me" ).$results( [ "some.key", "another.key" ] );
		mockPresideObjectService.$( "selectData" ).$args(
			  objectName = "security_user"
			, selectFields = [ "security_context_permission.granted", "security_context_permission.context_key" ]
			, forceJoins   = "inner"
			, filter       = {
				  "security_user.id"                          = "me"
				, "security_context_permision.permission_key" = "some.key"
				, "security_context_permission.context"       = "anotherContext"
				, "security_context_permission.context_key"   = [ "keyX", "key2", "key3", "keyA" ]
			}
		).$results( QueryNew( 'granted,context_key', "bit,varchar", [[0,"keyA"],[0,"key2"],[1,"keyX"],[0,"key3"]] ) );

		hasPerm = permsService.hasPermission( permissionKey="some.key", context="anotherContext", contextKeys=[ "keyX", "key2", "key3", "keyA" ] );

		super.assert( hasPerm, "Should have permission, yet returned that I do not :(" );
	}

// PRIVATE HELPERS
	private any function _getPermissionService( struct roles={}, struct permissions={} ) output=false {
		mockPresideObjectService = getMockBox().createEmptyMock( "preside.system.api.presideObjects.PresideObjectService" );
		mockLoginService         = getMockBox().createEmptyMock( "preside.system.api.admin.LoginService" );

		return getMockBox().createMock( object=new preside.system.api.security.PermissionService(
			  presideObjectService = mockPresideObjectService
			, loginService         = mockLoginService
			, logger               = _getTestLogger()
			, rolesConfig          = arguments.roles
			, permissionsConfig    = arguments.permissions
		) );
	}
}