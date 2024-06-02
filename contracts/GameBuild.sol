// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";


contract GameBuild is ERC20, ERC20Burnable, Pausable, Ownable {

    mapping(address => bool) public blacklist;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) Ownable(msg.sender) {
        _mint(msg.sender, 21419639400 ether);
    }

    function _update(address from, address to, uint256 value) internal virtual override whenNotPaused {
        super._update(from, to, value);
        require(!blacklist[from], "address is locked");
    }

    function lockAddress(address hacker) public onlyOwner {
        blacklist[hacker] = true;
    }

    function unLockAddress(address hacker) public onlyOwner {
        blacklist[hacker] = false;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}