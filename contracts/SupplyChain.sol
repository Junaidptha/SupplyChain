// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Roles.sol";

contract SupplyChain {
    Roles public rolesContract;

    enum SupplyStatus {
        Created,
        InTransit,
        Delivered
    }

    struct Product {
        uint256 batchId;
        address currentOwner;
        address[] ownershipTrail;
        SupplyStatus status;
    }

    mapping(uint256 => Product) public products; // batchId => Product

    event ProductRegistered(uint256 batchId, address indexed manufacturer);
    event OwnershipTransferred(
        uint256 batchId,
        address indexed from,
        address indexed to,
        SupplyStatus status
    );

    constructor(address _rolesContract) {
        rolesContract = Roles(_rolesContract);
    }

    modifier onlyRegisteredUser() {
        require(
            rolesContract.userRoles(msg.sender) != Roles.Role.None,
            "User not registered"
        );
        _;
    }

    function registerProduct(uint256 batchId) external onlyRegisteredUser {
        require(
            rolesContract.userRoles(msg.sender) == Roles.Role.Manufacturer,
            "Only manufacturer can register"
        );

        Product storage newProduct = products[batchId];
        newProduct.batchId = batchId;
        newProduct.currentOwner = msg.sender;
        newProduct.ownershipTrail.push(msg.sender);
        newProduct.status = SupplyStatus.Created;

        emit ProductRegistered(batchId, msg.sender);
    }

    function transferOwnership(
        uint256 batchId,
        address to
    ) external onlyRegisteredUser {
        Product storage product = products[batchId];
        require(
            product.currentOwner == msg.sender,
            "You do not own this product"
        );
        require(
            rolesContract.userRoles(to) != Roles.Role.None,
            "Receiver not registered"
        );

        product.currentOwner = to;
        product.ownershipTrail.push(to);
        product.status = SupplyStatus.InTransit;

        emit OwnershipTransferred(batchId, msg.sender, to, product.status);
    }

    function markDelivered(uint256 batchId) external onlyRegisteredUser {
        Product storage product = products[batchId];
        require(
            product.currentOwner == msg.sender,
            "Only owner can mark delivered"
        );
        product.status = SupplyStatus.Delivered;
    }

    function getOwnershipTrail(
        uint256 batchId
    ) external view returns (address[] memory) {
        return products[batchId].ownershipTrail;
    }

    function getProductStatus(
        uint256 batchId
    ) external view returns (SupplyStatus) {
        return products[batchId].status;
    }

    function getCurrentOwner(uint256 batchId) external view returns (address) {
        return products[batchId].currentOwner;
    }
}
