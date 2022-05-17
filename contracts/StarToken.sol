// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @notice Star tokens can be minted upon completing a quest. They will be burned when redeeming for reward.
contract StarToken is ERC20 {
    constructor() ERC20("Token Genie Star", "STAR") {
        //_mint(msg.sender, initialSupply);
    }
}
