//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {StarToken} from "./StarToken.sol";


contract Challenges is AccessControl {
    using SafeMath for uint256;

    // TODO: Gatekeeping for future
    /*
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    */

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
        string description; 
        uint256 starsToEarn;
        mapping (address => bool) usersParticipating;
        mapping (address => bool) usersCompleted; 
    }

    mapping (address => uint[]) challengeOwners; // address to challenge id
    mapping (uint => Challenge) challenges; // id to challenge
    mapping (address => uint[]) challengeParticipants; // address to challenge id (participants)


    uint256 numberOfChallenges;

    StarToken private _starToken;

    constructor(address starTokenAddress) {
        // _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        // _setupRole(MANAGER_ROLE, msg.sender);
        // _setupRole(MINTER_ROLE, msg.sender);
        // _setRoleAdmin(USER_ROLE, MANAGER_ROLE);
        _starToken = StarToken(starTokenAddress);
    }

    /*
    * @dev assigns the wallet that can claim the reward
    */
    function approveUser(address _user, uint id) public {
        // TODO: Additional tests that challenge exists and owned by the manager
        challenges[id].usersParticipating[_user] = true;
        challengeParticipants[_user].push(id); 
        emit UserApproved(id, challenges[id].usersParticipating[_user]);
    }

    /*
    * @dev creates a quest and locks the Star token into the contract
    */
    // OpenZeppelin counter to increase
    function createChallenge(uint _starsToEarn, string memory _description) external {
        Challenge storage myChallenge = challenges[numberOfChallenges];
        myChallenge.id = numberOfChallenges;
        myChallenge.admin = msg.sender;
        myChallenge.description = _description;
        myChallenge.starsToEarn = _starsToEarn;
        challengeOwners[msg.sender].push(numberOfChallenges);
        numberOfChallenges = numberOfChallenges.add(1);
        emit ChallengeCreated(msg.sender, _starsToEarn, numberOfChallenges);
    }

    /*
    * @dev user approves that they finished a challenge
    */
    function challengeComplete(uint id) external  {
        mapping (address => bool) storage _usersParticipating = challenges[id].usersParticipating;
        mapping (address => bool) storage _usersCompleted = challenges[id].usersCompleted;
        require(_usersParticipating[msg.sender] == true, "could not find the dedicated user in the array");
        _usersCompleted[msg.sender] = true;
        emit ChallengeCompleted(id, challenges[id].usersCompleted[msg.sender]);
    }

    /*
    * @dev this code is not optimized
    */
    function approveChallengeComplete(address _user, uint id) public {
        // TODO: Optimizations if have time
        mapping (address => bool) storage _usersParticipating = challenges[id].usersParticipating;
        mapping (address => bool) storage _usersCompleted = challenges[id].usersCompleted;

        require(_usersParticipating[_user] == true, "could not find the dedicated user in the array");
        require(_usersCompleted[_user] == true, "user has not completed the challenge");

        _usersParticipating[_user] = false;
        _usersCompleted[_user] = false;

        // mints money to the user
        // TODO: Write tests for this
        _starToken.mint(_user, challenges[id].starsToEarn);

        emit ChallengeApproved(id, challenges[id].usersParticipating[_user], challenges[id].starsToEarn);
    }

    /* 
    * @dev set of getters to use to get the challenges
    */
    function getMyChallenges() public view  returns (uint[] memory) {
        return challengeOwners[msg.sender];
    }

    function getChallenge(uint _id) public view returns (uint id, address admin, string memory description, uint starsToEarn, bool participating, bool completed) {
        return (challenges[_id].id, challenges[_id].admin, challenges[_id].starsToEarn, 
        challenges[_id].description, challenges[_id].usersParticipating[msg.sender], challenges[_id].usersCompleted[msg.sender]);
    }

    function getParticipatingChallenges() public view returns (uint[] memory) {
        return challengeParticipants[msg.sender];
    }

}
