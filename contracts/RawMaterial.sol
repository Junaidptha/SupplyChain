// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Roles.sol";

contract RawMaterial {
    Roles public rolesContract;
    uint256 public rawMaterialCounter;

    struct RawMaterialInfo {
        uint256 id;
        string name;
        uint256 quantity;
        string origin;
        address manufacturer;
        uint256 timestamp;
    }

    mapping(uint256 => RawMaterialInfo) public rawMaterials;

    event RawMaterialCreated(
        uint256 id,
        string name,
        uint256 quantity,
        string origin,
        address indexed manufacturer,
        uint256 timestamp
    );

    constructor(address _rolesContract) {
        rolesContract = Roles(_rolesContract);
    }

    modifier onlyManufacturer() {
        require(
            rolesContract.userRoles(msg.sender) == Roles.Role.Manufacturer,
            "Only manufacturers allowed"
        );
        _;
    }

    function createRawMaterial(
        string memory name,
        uint256 quantity,
        string memory origin
    ) external onlyManufacturer {
        rawMaterialCounter++;
        rawMaterials[rawMaterialCounter] = RawMaterialInfo({
            id: rawMaterialCounter,
            name: name,
            quantity: quantity,
            origin: origin,
            manufacturer: msg.sender,
            timestamp: block.timestamp
        });

        emit RawMaterialCreated(
            rawMaterialCounter,
            name,
            quantity,
            origin,
            msg.sender,
            block.timestamp
        );
    }

    function getRawMaterial(
        uint256 id
    ) external view returns (RawMaterialInfo memory) {
        return rawMaterials[id];
    }
}
