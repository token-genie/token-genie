//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract Challenges is AccessControl {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");

    constructor(address _admin) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MANAGER_ROLE, msg.sender);
        _setupRole(MANAGER_ROLE, _admin);
        _setRoleAdmin(USER_ROLE, MANAGER_ROLE);
    }

    /*
    * @dev assigns the wallet that can claim the reward
    */
    function approveUser(address _user) public onlyRole(MANAGER_ROLE)  {
    }

    /*
    * @dev creates a quest and locks the Star token into the contract 
    */
    function createChallenge() payable onlyRole(MANAGER_ROLE) public {
    }

    /*
    * @dev makes the StarToken locked into the quest claimable by the user
    */
    function approveChallengeComplete(address _user, uint amount) public onlyRole(MANAGER_ROLE) {

    }
    /*
    * @dev allows the user to redeem the StarTokens locked into the Quest
    */
    function redeem() public onlyRole(USER_ROLE) {

    }
}
