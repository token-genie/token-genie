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
    event ChallengeCompleted(uint id, address[] users, uint starsToEarn);


    /*
    * @dev challenge struct to keep the admin, balance of the challenge, and users
    */
    struct Challenge {
        uint id;
        address admin;
        uint256 starsToEarn;
        address[] users;
    }

    mapping (uint => address) challengeOwners;
    mapping (uint => Challenge) challenges;

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
        emit UserApproved(id, challenges[id].users);
    }

    /*
    * @dev creates a quest and locks the Star token into the contract
    */
    // OpenZeppelin counter to increase
    function createChallenge(uint _starsToEarn) external onlyRole(MANAGER_ROLE) {
        address[] memory users;
        challengeOwners[numberOfChallenges] = msg.sender;
        challenges[numberOfChallenges] = Challenge(numberOfChallenges, msg.sender, _starsToEarn, users);
        numberOfChallenges = numberOfChallenges.add(1);
        emit ChallengeCreated(msg.sender, _starsToEarn, numberOfChallenges);
    }

    // TODO: Users need to show that they have finished their quest
    
    /*
    * @dev this code is not optimized
    */
    function approveChallengeComplete(address _user, uint id) public onlyRole(MANAGER_ROLE) {
        // TODO: Optimizations if have time
        address[] storage users = challenges[id].users;

        // Finds the user to delete from the array
        uint index;
        for (uint i = 0; i < users.length; i++) {
            if (users[i] == _user){
                index = i;
            }
        }

        // Deletes the user from the array
        users[index] = users[users.length - 1];
        users.pop();

        // Updates the rest
        challenges[id].users = users;

        // mints money to the user
        // TODO: writes test for it
        // Issues around minting role 
        // _starToken.mint(_user, challenges[id].starsToEarn);

        emit ChallengeCompleted(id, challenges[id].users, challenges[id].starsToEarn);
    }
}
