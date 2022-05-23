//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {StarToken} from "./StarToken.sol";


contract Challenges is AccessControl {
    using SafeMath for uint256;

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    event ChallengeCreated(address admin, uint balance, uint id);
    event UserApproved(uint id, address[] users);
    event ChallengeApproved(uint id, address[] users, uint starsToEarn);
    event ChallengeCompleted(uint id, bool[] completed);


    /*
    * @dev challenge struct to keep the admin, balance of the challenge, and users
    */

    struct Challenge {
        uint id;
        address admin;
        uint256 starsToEarn;
        address[] users;
        bool[] completed; // 1-to-1 mapping to users, so that we know who
    }

    mapping (uint => address) challengeOwners;
    mapping (uint => Challenge) challenges; // id to challenge

    uint256 numberOfChallenges;

    StarToken private _starToken;

    constructor(address starTokenAddress) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MANAGER_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        _setRoleAdmin(USER_ROLE, MANAGER_ROLE);
        _starToken = StarToken(starTokenAddress);
    }

    /*
    * @dev assigns the wallet that can claim the reward
    */
    function approveUser(address _user, uint id) public onlyRole(MANAGER_ROLE) {
        // TODO: Additional tests that challenge exists and owned by the manager
        _setupRole(USER_ROLE, _user);
        challenges[id].users.push(_user);
        challenges[id].completed.push(false);
        emit UserApproved(id, challenges[id].users);
    }

    /*
    * @dev creates a quest and locks the Star token into the contract
    */
    // OpenZeppelin counter to increase
    function createChallenge(uint _starsToEarn) external onlyRole(MANAGER_ROLE) {
        address[] memory users;
        bool[] memory completed;
        challengeOwners[numberOfChallenges] = msg.sender;
        challenges[numberOfChallenges] = Challenge(numberOfChallenges, msg.sender, _starsToEarn, users, completed);
        numberOfChallenges = numberOfChallenges.add(1);
        emit ChallengeCreated(msg.sender, _starsToEarn, numberOfChallenges);
    }

    /*
    * @dev user approves that they finished a challenge
    */
    function challengeComplete(uint id) external onlyRole(USER_ROLE) {
        address[] storage users = challenges[id].users;
        // Finds the user to delete from the array
        uint index;
        bool found = false;
        for (uint i = 0; i < users.length; i++) {
            if (users[i] == msg.sender){
                index = i;
                found = true;
            }
        }
        require(found == true, "could not find the dedicated user in the array");
        challenges[id].completed[index] = true;
        emit ChallengeCompleted(id, challenges[id].completed);
    }

    /*
    * @dev this code is not optimized
    */
    function approveChallengeComplete(address _user, uint id) public onlyRole(MANAGER_ROLE) {
        // TODO: Optimizations if have time
        address[] storage users = challenges[id].users;
        bool[] storage completed = challenges[id].completed;

        // Finds the user to delete from the array
        uint index;
        bool found = false;
        for (uint i = 0; i < users.length; i++) {
            if (users[i] == _user){
                index = i;
                found = true;
            }
        }

        require(found == true, "could not find the dedicated user in the array");
        require(completed[index] == true, "user has not completed the challenge");
        // Deletes the user from the array
        users[index] = users[users.length - 1];
        users.pop();

        // Updates the rest
        challenges[id].users = users;

        // Deletes the completed from the array
        completed[index] = completed[completed.length - 1];
        completed.pop();

        // Updates the rest
        challenges[id].completed = completed;

        // mints money to the user
        // TODO: Write tests for this
        _starToken.mint(_user, challenges[id].starsToEarn);

        emit ChallengeApproved(id, challenges[id].users, challenges[id].starsToEarn);
    }
}
