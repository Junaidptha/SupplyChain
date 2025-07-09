// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../contracts/Roles.sol";
import "../contracts/RawMaterial.sol";

contract RawMaterialTest is Test {
    Roles roles;
    RawMaterial rawMaterial;

    address manufacturer = address(0x123);
    address otherUser = address(0x456);

    function setUp() public {
        roles = new Roles();
        rawMaterial = new RawMaterial(address(roles));
        roles.assignRole(manufacturer, Roles.Role.Manufacturer);
    }

    // function testCreateRawMaterialSuccess() public {
    //     vm.prank(manufacturer);
    //     rawMaterial.createRawMaterial("Sugar", "100kg", "Nepal");

    //     (string memory name, , ) = rawMaterial.getRawMaterial(1);
    //     assertEq(name, "Sugar");
    // }
    function testCreateRawMaterialSuccess() public {
        vm.prank(manufacturer);
        rawMaterial.createRawMaterial("Sugar", 100, "Nepal"); // quantity as uint

        RawMaterial.RawMaterialInfo memory info = rawMaterial.getRawMaterial(1);
        assertEq(info.name, "Sugar");
        assertEq(info.quantity, 100);
        assertEq(info.origin, "Nepal");
    }

    function testCreateRawMaterialFailNonManufacturer() public {
        vm.prank(otherUser);
        vm.expectRevert("Only manufacturers allowed");
        rawMaterial.createRawMaterial("Salt", 50, "India");
    }
}
