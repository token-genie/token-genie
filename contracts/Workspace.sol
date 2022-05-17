//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract Workspace is AccessControl {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");

    constructor(address _admin) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MANAGER_ROLE, msg.sender);
        _setupRole(MANAGER_ROLE, _admin);
        _setRoleAdmin(USER_ROLE, MANAGER_ROLE);
    }

    function approveQuestComplete() public onlyRole(MANAGER_ROLE) {}

    function redeemReward() public onlyRole(USER_ROLE) {}
}
