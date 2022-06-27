// SPDX-License-Identifier: GPL-2.0+
pragma solidity ^0.8.3;
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import "./Exchange.sol";
contract CompromisedAttack is Ownable{
    Exchange private exchange;
    constructor(address exchangeAddress) Ownable(){
        exchange = Exchange(payable(exchangeAddress));
    }

    function start() public payable onlyOwner{
        exchange.buyOne{value: msg.value}();
    }

    receive() external payable {}

}
