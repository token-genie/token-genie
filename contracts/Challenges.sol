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
    event UserApproved(uint id, bool approved);
    event ChallengeApproved(uint id, bool approved, uint starsToEarn);
    event ChallengeCompleted(uint id, bool completed);


    /*
    * @dev challenge struct to keep the admin, balance of the challenge, and users
    */

    struct Challenge {
        uint id;
        address admin;
        uint256 starsToEarn;
        mapping (address => bool) usersParticipating;
        mapping (address => bool) usersCompeting;
    }

    mapping (address => uint[]) challengeOwners; // address to challenge id
    mapping (uint => Challenge) challenges; // id to challenge
    mapping (address => uint[]) challengeParticipants; // address to challenge id (participants)


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
        challenges[id].usersParticipating[_user] = true;
        emit UserApproved(id, challenges[id].usersParticipating[_user]);
    }

    /*
    * @dev creates a quest and locks the Star token into the contract
    */
    // OpenZeppelin counter to increase
    function createChallenge(uint _starsToEarn) external onlyRole(MANAGER_ROLE) {
        Challenge storage myChallenge = challenges[numberOfChallenges];
        myChallenge.id = numberOfChallenges;
        myChallenge.admin = msg.sender;
        myChallenge.starsToEarn = _starsToEarn;
        challengeOwners[msg.sender].push(numberOfChallenges);
        numberOfChallenges = numberOfChallenges.add(1);
        emit ChallengeCreated(msg.sender, _starsToEarn, numberOfChallenges);
    }

    /*
    * @dev user approves that they finished a challenge
    */
    function challengeComplete(uint id) external onlyRole(USER_ROLE) {
        mapping (address => bool) storage _usersParticipating = challenges[id].usersParticipating;
        mapping (address => bool) storage _usersCompeting = challenges[id].usersCompeting;
        require(_usersParticipating[msg.sender] == true, "could not find the dedicated user in the array");
        _usersCompeting[msg.sender] = true;
        emit ChallengeCompleted(id, challenges[id].usersCompeting[msg.sender]);
    }

    /*
    * @dev this code is not optimized
    */
    function approveChallengeComplete(address _user, uint id) public onlyRole(MANAGER_ROLE) {
        // TODO: Optimizations if have time
        mapping (address => bool) storage _usersParticipating = challenges[id].usersParticipating;
        mapping (address => bool) storage _usersCompeting = challenges[id].usersCompeting;

        require(_usersParticipating[_user] == true, "could not find the dedicated user in the array");
        require(_usersCompeting[_user] == true, "user has not completed the challenge");

        _usersParticipating[_user] = false;
        _usersCompeting[_user] = false;

        // mints money to the user
        // TODO: Write tests for this
        _starToken.mint(_user, challenges[id].starsToEarn);

        emit ChallengeApproved(id, challenges[id].usersParticipating[_user], challenges[id].starsToEarn);
    }

    /* 
    * @dev set of getters to use to get the challenges
    * /
    function getMyChallenges() public view onlyRole(MANAGER_ROLE)  returns (uint[] memory) {
        return challengeOwners[msg.sender];
    }

    function getChallenge(uint _id) public view returns (uint id, address admin, uint starsToEarn, bool participating, bool completed) {
        return (challenges[_id].id, challenges[_id].admin, challenges[_id].starsToEarn, 
        challenges[_id].usersParticipating[msg.sender], challenges[_id].usersCompeting[msg.sender]);
    }

    function getOwnChallenges() public view onlyRole(USER_ROLE) returns (uint[] memory) {
        return challengeParticipants[msg.sender];
    }

}
