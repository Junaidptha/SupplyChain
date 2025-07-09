// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../contracts/Roles.sol";
import "../contracts/SupplyChain.sol";

contract SupplyChainTest is Test {
    Roles roles;
    SupplyChain supplyChain;

    address manufacturer = address(0x1);
    address distributor = address(0x2);
    address wholesaler = address(0x3);
    address pharmacy = address(0x4);
    address randomUser = address(0x5);

    uint256 batchId = 1;

    function setUp() public {
        roles = new Roles();
        supplyChain = new SupplyChain(address(roles));

        // Assign roles
        roles.assignRole(manufacturer, Roles.Role.Manufacturer);
        roles.assignRole(distributor, Roles.Role.Distributor);
        roles.assignRole(wholesaler, Roles.Role.Wholesaler);
        roles.assignRole(pharmacy, Roles.Role.Pharmacy);
    }

    function testRegisterProductSuccess() public {
        vm.prank(manufacturer);
        supplyChain.registerProduct(batchId);

        address currentOwner = supplyChain.getCurrentOwner(batchId);
        assertEq(currentOwner, manufacturer);

        SupplyChain.SupplyStatus status = supplyChain.getProductStatus(batchId);
        assertEq(uint(status), uint(SupplyChain.SupplyStatus.Created));
    }

    function testRegisterProductFailNonManufacturer() public {
        vm.prank(distributor);
        vm.expectRevert("Only manufacturer can register");
        supplyChain.registerProduct(batchId);
    }

    function testTransferOwnershipSuccess() public {
        // Manufacturer registers product first
        vm.prank(manufacturer);
        supplyChain.registerProduct(batchId);

        // Transfer to distributor
        vm.prank(manufacturer);
        supplyChain.transferOwnership(batchId, distributor);

        address currentOwner = supplyChain.getCurrentOwner(batchId);
        assertEq(currentOwner, distributor);

        // Transfer to wholesaler
        vm.prank(distributor);
        supplyChain.transferOwnership(batchId, wholesaler);

        currentOwner = supplyChain.getCurrentOwner(batchId);
        assertEq(currentOwner, wholesaler);
    }

    // function testTransferOwnershipFailNotOwner() public {
    //     vm.prank(manufacturer);
    //     supplyChain.registerProduct(batchId);

    //     // Random user tries to transfer
    //     vm.prank(randomUser);
    //     vm.expectRevert(bytes("You do not own this product"));

    //     supplyChain.transferOwnership(batchId, distributor);
    // }
    function testTransferOwnershipFailNotOwner() public {
        uint256 testBatchId = 1;

        // Rename manufacturer variable
        address testManufacturer = address(0x123);

        roles.assignRole(address(this), Roles.Role.Distributor);
        roles.assignRole(testManufacturer, Roles.Role.Manufacturer);

        vm.prank(testManufacturer);
        supplyChain.registerProduct(testBatchId);

        vm.expectRevert(bytes("You do not own this product"));
        supplyChain.transferOwnership(testBatchId, address(0x456));
    }

    function testMarkDeliveredSuccess() public {
        vm.prank(manufacturer);
        supplyChain.registerProduct(batchId);

        vm.prank(manufacturer);
        supplyChain.transferOwnership(batchId, distributor);

        vm.prank(distributor);
        supplyChain.markDelivered(batchId);

        SupplyChain.SupplyStatus status = supplyChain.getProductStatus(batchId);
        assertEq(uint(status), uint(SupplyChain.SupplyStatus.Delivered));
    }

    function testGetOwnershipTrail() public {
        vm.prank(manufacturer);
        supplyChain.registerProduct(batchId);

        vm.prank(manufacturer);
        supplyChain.transferOwnership(batchId, distributor);

        vm.prank(distributor);
        supplyChain.transferOwnership(batchId, wholesaler);

        address[] memory trail = supplyChain.getOwnershipTrail(batchId);

        assertEq(trail.length, 3);
        assertEq(trail[0], manufacturer);
        assertEq(trail[1], distributor);
        assertEq(trail[2], wholesaler);
    }
}
