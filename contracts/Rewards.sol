// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {StarToken} from "./StarToken.sol";

/// @notice Stores rewards, stars required to redeem, and exchange process. Burn tokens, transfer rewards
contract Rewards {
    StarToken private _starToken;

    constructor(address starTokenAddress) {
        _starToken = StarToken(starTokenAddress);
    }

    // TODO: This should accept a rewardId which knows the starCount required
    function redeemStarsForReward(uint256 starCount) external {
        require(
            _starToken.balanceOf(msg.sender) >= starCount,
            "Not enough stars"
        );
        _starToken.burn(starCount);
        // TODO: What kind of reward are we giving them in exchange? An NFT? Just a string record of the prize?
    }
}
