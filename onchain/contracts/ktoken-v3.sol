// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @custom:security-contact chenxuan@kaiyuanshe.org
contract KTokenV3 is ERC20, Ownable {
    constructor()
        ERC20("KToken", "KTN")
        Ownable()
    {
        _mint(msg.sender, 100000000 * 10 ** decimals());
    }

    // transfer disabled
    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20)
    {
        require(from == address(0) || from == owner(), "Token transfer disabled!");
        super._beforeTokenTransfer(from, to, amount);
    }
}