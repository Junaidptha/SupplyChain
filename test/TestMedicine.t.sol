// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../contracts/Roles.sol";
import "../contracts/Medicine.sol";

contract MedicineTest is Test {
    Roles roles;
    Medicine medicine;

    address manufacturer = address(0x123);
    address otherUser = address(0x456);

    function setUp() public {
        roles = new Roles();
        medicine = new Medicine(address(roles));
        roles.assignRole(manufacturer, Roles.Role.Manufacturer);
    }

    // function testCreateMedicineBatchSuccess() public {
    //     vm.prank(manufacturer);
    //     medicine.createMedicineBatch(
    //         "Paracetamol",
    //         1,
    //         block.timestamp + 30 days,
    //         "Nepal"
    //     );

    // (uint batchId, string memory name, , , ) = medicine.getMedicineBatch(1);
    // assertEq(name, "Paracetamol");
    // assertEq(batchId, 1);
    // }
    function testCreateMedicineBatchSuccess() public {
        vm.prank(manufacturer);
        medicine.createMedicineBatch(
            "Paracetamol",
            1,
            block.timestamp + 30 days,
            "Nepal"
        );

        Medicine.MedicineBatch memory batch = medicine.getMedicineBatch(1);
        assertEq(batch.name, "Paracetamol");
        assertEq(batch.batchId, 1);
    }

    function testCreateMedicineBatchFailNonManufacturer() public {
        vm.prank(otherUser);
        vm.expectRevert("Only manufacturers allowed");
        medicine.createMedicineBatch(
            "Ibuprofen",
            1,
            block.timestamp + 30 days,
            "Nepal"
        );
    }
}
