// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../contracts/Roles.sol";

contract RolesTest is Test {
    Roles roles;

    address user1 = address(0x123);
    address user2 = address(0x456);

    function setUp() public {
        roles = new Roles();
    }

    function testAssignAndCheckRole() public {
        roles.assignRole(user1, Roles.Role.Manufacturer);
        Roles.Role role = roles.userRoles(user1);
        assertEq(uint(role), uint(Roles.Role.Manufacturer));
    }

    function testAssignRoleOverwrite() public {
        roles.assignRole(user1, Roles.Role.Manufacturer);
        roles.assignRole(user1, Roles.Role.Distributor);
        assertEq(uint(roles.userRoles(user1)), uint(Roles.Role.Distributor));
    }

    function testAssignRoleToZeroAddress() public {
        vm.expectRevert(bytes("Invalid address"));
        roles.assignRole(address(0), Roles.Role.Manufacturer);
    }
}
