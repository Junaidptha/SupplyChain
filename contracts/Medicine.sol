// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Roles.sol";

contract Medicine {
    Roles public rolesContract;
    uint256 public batchCounter;

    struct MedicineBatch {
        uint256 batchId;
        string name;
        uint256 rawMaterialId;
        uint256 manufactureDate;
        uint256 expiryDate;
        address manufacturer;
        string origin;
        bool isDispatched;
    }

    mapping(uint256 => MedicineBatch) public medicineBatches;

    event MedicineCreated(
        uint256 batchId,
        string name,
        uint256 rawMaterialId,
        uint256 manufactureDate,
        uint256 expiryDate,
        address manufacturer,
        string origin
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

    function createMedicineBatch(
        string memory name,
        uint256 rawMaterialId,
        uint256 expiryDate,
        string calldata origin
    ) external onlyManufacturer {
        batchCounter++;
        medicineBatches[batchCounter] = MedicineBatch({
            batchId: batchCounter,
            name: name,
            rawMaterialId: rawMaterialId,
            manufactureDate: block.timestamp,
            expiryDate: expiryDate,
            manufacturer: msg.sender,
            origin: origin,
            isDispatched: false
        });

        emit MedicineCreated(
            batchCounter,
            name,
            rawMaterialId,
            block.timestamp,
            expiryDate,
            msg.sender,
            origin
        );
    }

    function getMedicineBatch(
        uint256 batchId
    ) external view returns (MedicineBatch memory) {
        return medicineBatches[batchId];
    }

    function markDispatched(uint256 batchId) external onlyManufacturer {
        medicineBatches[batchId].isDispatched = true;
    }
}
