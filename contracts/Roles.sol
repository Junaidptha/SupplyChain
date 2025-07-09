// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @title Role-based access control for the supply chain
contract Roles {
    address public admin;

    enum Role {
        None,
        Manufacturer,
        Distributor,
        Wholesaler,
        Transporter,
        Pharmacy
    }

    mapping(address => Role) public userRoles;

    /// @notice Set deployer as admin
    constructor() {
        admin = msg.sender;
        userRoles[admin] = Role.None;
    }

    /// @notice Assign a role to a user (only Admin)
    function assignRole(address user, Role role) external onlyAdmin {
        require(user != address(0), "Invalid address");
        require(role != Role.None, "Invalid role");
        userRoles[user] = role;
    }

    /// @notice Get role of a user
    function getRole(address user) external view returns (Role) {
        return userRoles[user];
    }

    /// @notice Modifier: only Admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this");
        _;
    }

    /// @notice Modifier: only specific role
    modifier onlyRole(Role role) {
        require(userRoles[msg.sender] == role, "Unauthorized role");
        _;
    }

    /// @notice Modifier: only registered roles (not None)
    modifier onlyRegisteredUser() {
        require(userRoles[msg.sender] != Role.None, "Not registered");
        _;
    }
}
