// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @custom:security-contact chenxuan@kaiyuanshe.org
contract KTokenV4 is ERC20, Ownable {
    string[] private reasons;

    constructor()
        ERC20("KToken", "KTN")
        Ownable()
    {
        _mint(msg.sender, 100000000 * 10 ** decimals());
        reasons.push("Translate");
    }

    function addReason(string memory newColor) public {
        reasons.push(newColor);
    }

    function getReason() public view returns (string[] memory) {
        return reasons;
    }

    function removeReason(uint index) public {
        require(index < reasons.length, "Index out of bounds");
        for (uint i = index; i < reasons.length - 1; i++) {
            reasons[i] = reasons[i + 1];
        }
        reasons.pop();
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

// Unfinished
