// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../contracts/Roles.sol";
import "../contracts/RawMaterial.sol";
import "../contracts/Medicine.sol";
import "../contracts/SupplyChain.sol";

contract DeployScript is Script {
    function run() public {
        vm.startBroadcast();

        Roles roles = new Roles();
        RawMaterial rawMaterial = new RawMaterial(address(roles));
        Medicine medicine = new Medicine(address(roles));
        SupplyChain supplyChain = new SupplyChain(address(roles));

        vm.stopBroadcast();

        // Log deployed addresses for frontend config
        console.log("Roles deployed at:", address(roles));
        console.log("RawMaterial deployed at:", address(rawMaterial));
        console.log("Medicine deployed at:", address(medicine));
        console.log("SupplyChain deployed at:", address(supplyChain));
    }
}
