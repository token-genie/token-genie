//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract Challenges is AccessControl {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");

    event ChallengeCreated(address admin, uint balance);

    /*
    * @dev challenge struct to keep the admin, balance of the challenge, and users
    */
    struct Challenge {
        uint id;
        address admin;
        uint balance;
        address[] users;
        bool completed;
    }

    mapping (address => Challenge[]) public challenges;

    uint numberOfChallenges;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MANAGER_ROLE, msg.sender);
        _setRoleAdmin(USER_ROLE, MANAGER_ROLE);
    }

    /*
    * @dev assigns the wallet that can claim the reward
    */
    function approveUser(address _user, uint challengeId) public onlyRole(MANAGER_ROLE)  {
        _setupRole(MANAGER_ROLE, _user);
    }

    /*
    * @dev creates a quest and locks the Star token into the contract
    */
    function createChallenge() external payable onlyRole(MANAGER_ROLE) returns (uint challengeId)  {
        uint amount = msg.value;
        numberOfChallenges += 1;

        address[] memory users;
        Challenge memory myChallenge = Challenge(numberOfChallenges, msg.sender, amount, users, false);
        challenges[msg.sender].push(myChallenge);

        emit ChallengeCreated(msg.sender, amount);
        return numberOfChallenges;
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
