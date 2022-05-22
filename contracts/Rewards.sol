// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import {StarToken} from "./StarToken.sol";

/// @notice Stores rewards, stars required to redeem, and exchange process. Burn tokens, transfer rewards
contract Rewards {
    using Counters for Counters.Counter;
    Counters.Counter private _rewardIds;
    StarToken private _starToken;

    event RewardStaked(
        address indexed staker,
        uint256 amount,
        uint256 stars,
        uint256 id
    );
    event RewardUnstaked(
        address indexed staker,
        uint256 amount,
        uint256 stars,
        uint256 id
    );
    event RewardClaimed(
        address indexed staker,
        address indexed claimer,
        uint256 amount,
        uint256 stars,
        uint256 id
    );

    struct Reward {
        uint256 id;
        uint256 amount;
        uint256 starsRequired;
        address staker;
        address claimer;
    }

    //mapping(uint256 => Reward) public rewardById;
    // @dev We don't need a mapping because the ID == index
    Reward[] public rewards;

    constructor(address starTokenAddress) {
        _starToken = StarToken(starTokenAddress);
    }

    function stakeReward(uint256 starsRequired)
        external
        payable
        returns (uint256)
    {
        require(msg.value > 0, "zero reward");

        uint256 rewardId = _rewardIds.current();
        Reward memory reward = Reward(
            rewardId, // is it redundant to store this in struct?
            msg.value,
            starsRequired,
            msg.sender,
            address(0)
        );
        rewards.push(reward);
        _rewardIds.increment();

        emit RewardStaked(msg.sender, msg.value, starsRequired, rewardId);
        return rewardId;
    }

    // @notice Allow staker to unstake ETH by claiming reward
    function unstakeReward(uint256 rewardId) external {
        // Checks
        Reward memory reward = rewards[rewardId];
        require(reward.claimer != address(0), "already claimed");
        require(reward.staker == msg.sender, "not your ETH");

        // Effects
        reward.claimer = msg.sender;
        reward.amount = 0;

        // Interactions
        (bool sent, ) = payable(msg.sender).call{value: reward.amount}("");
        require(sent, "send failed");

        // Is this an effect that belongs above interactions?
        emit RewardUnstaked(
            msg.sender,
            reward.amount,
            reward.starsRequired,
            rewardId
        );
    }

    function claimRewardForStars(uint256 rewardId) external {
        // Checks
        // TODO: Check that the staker is the manager for this user (msg.sender)???
        Reward storage reward = rewards[rewardId];
        uint256 stars = reward.starsRequired;

        require(_starToken.balanceOf(msg.sender) >= stars, "Not enough stars");

        // Effects
        reward.claimer = msg.sender;

        // Interactions
        _starToken.burn(stars);
        (bool sent, ) = payable(msg.sender).call{value: reward.amount}("");
        require(sent, "send failed");

        // Effect?
        emit RewardClaimed(
            reward.staker,
            reward.claimer,
            reward.amount,
            reward.starsRequired,
            rewardId
        );
    }
}
