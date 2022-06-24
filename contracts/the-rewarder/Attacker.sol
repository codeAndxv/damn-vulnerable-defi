// SPDX-License-Identifier: GPL-2.0+
pragma solidity ^0.8.3;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";
import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";

contract Attacker is Ownable, ReentrancyGuard {
    FlashLoanerPool public immutable loanerPool;
    DamnValuableToken public immutable liquidityToken;
    TheRewarderPool public immutable rewarderPool;
    constructor(address loanerPoolAddress, address liquidityTokenAddress, address rewarderPoolAddress) Ownable() {
        loanerPool = FlashLoanerPool(loanerPoolAddress);
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
        rewarderPool = TheRewarderPool(rewarderPoolAddress);
    }


    function start() public {
        console.log("xx");
    }
}
