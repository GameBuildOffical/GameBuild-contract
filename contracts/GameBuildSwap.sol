// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract GameBuildSwap is Ownable, Pausable, ReentrancyGuard {

    event Swap(address indexed from, address indexed token, uint256 amount);

    ERC20 public tokenCRE;
    ERC20 public tokenSLG;
    ERC20 public tokenGameBuild;

    // swap ratio: ratioCRE CRE = ratioGameBuild GameBuild, ratioSLG SLG = ratioGameBuild GameBuild
    // so: 
    //    amountGameBuild = amoundCRE * ratioGameBuild / ratioCRE
    //    amountGAmeBuild = amountSLG * ratioGameBuild / ratioSLG;
    uint256 public ratioCRE;
    uint256 public ratioSLG;
    uint256 public ratioGameBuild;

    uint256 public swappedCRE;
    uint256 public swappedSLG;
    uint256 public maxSwappableCRE;
    uint256 public maxSwappableSLG;
    uint256 public deadline;

    constructor(address addressCRE, 
                address addressSLG, 
                address addressGameBuild, 
                uint256 _ratioCRE, 
                uint256 _ratioSLG,
                uint256 _ratioGameBuild) Ownable(msg.sender) {
        tokenCRE = ERC20(addressCRE);
        tokenSLG = ERC20(addressSLG);
        tokenGameBuild = ERC20(addressGameBuild);
        ratioCRE = _ratioCRE;
        ratioSLG = _ratioSLG;
        ratioGameBuild = _ratioGameBuild;
    }

    function swapCRE(uint256 amountCRE) public whenNotPaused nonReentrant returns (uint256) {
        require(deadline == 0 || block.timestamp < deadline, "exceed deadline");
        require(amountCRE > 0, "CRE amount should be greater than 0");
        require(tokenCRE.balanceOf(msg.sender) >= amountCRE, "do not have enough CRE");

        uint256 amountGameBuild = amountCRE * ratioGameBuild / ratioCRE;
        require(tokenGameBuild.balanceOf(address(this)) >= amountGameBuild, "contract has no enough GameBuild");

        swappedCRE = swappedCRE + amountCRE;
        if (maxSwappableCRE > 0) {
            require(swappedCRE <= maxSwappableCRE, "exceed max swappable amount");
        }
        tokenCRE.transferFrom(msg.sender, address(this), amountCRE);
        tokenGameBuild.transfer(msg.sender, amountGameBuild);
        emit Swap(msg.sender, address(tokenCRE), amountCRE);

        return amountGameBuild;
    }

    function swapSLG(uint256 amountSLG) public whenNotPaused nonReentrant returns (uint256) {
        require(deadline == 0 || block.timestamp < deadline, "exceed deadline");
        require(amountSLG > 0, "SLG amount should be greater than 0");
        require(tokenSLG.balanceOf(msg.sender) >= amountSLG, "do not have enough SLG");

        uint256 amountGameBuild = amountSLG * ratioGameBuild / ratioSLG;
        require(tokenGameBuild.balanceOf(address(this)) >= amountGameBuild, "contract has no enough GameBuild");

        swappedSLG = swappedSLG + amountSLG;
        if (maxSwappableSLG > 0) {
            require(swappedSLG <= maxSwappableSLG, "exceed max swappable amount");
        }
        tokenSLG.transferFrom(msg.sender, address(this), amountSLG);
        tokenGameBuild.transfer(msg.sender, amountGameBuild);
        emit Swap(msg.sender, address(tokenSLG), amountSLG);

        return amountGameBuild;
    }

    function withdrawToken(address token, address to) public onlyOwner {
        ERC20 erc20 = ERC20(token);
        erc20.transfer(to, erc20.balanceOf(address(this)));
    }

    function setRatioCRE(uint256 _ratioCRE) public onlyOwner {
        ratioCRE = _ratioCRE;
    }

    function setRatioSLG(uint256 _ratioSLG) public onlyOwner {
        ratioSLG = _ratioSLG;
    }

    function setRatioGameBuild(uint256 _ratioGameBuild) public onlyOwner {
        ratioGameBuild = _ratioGameBuild;
    }

    function setMaxSwappableCRE(uint256 _maxSwappableCRE) public onlyOwner {
        maxSwappableCRE = _maxSwappableCRE;
    }

    function setMaxSwappableSLG(uint256 _maxSwappableSLG) public onlyOwner {
        maxSwappableSLG = _maxSwappableSLG;
    }

    function setDeadline(uint256 _deadline) public onlyOwner {
        require(_deadline >= block.timestamp, "invalid deadline");
        deadline = _deadline;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}