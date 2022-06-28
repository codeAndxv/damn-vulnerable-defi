// SPDX-License-Identifier: GPL-2.0+
pragma solidity ^0.8.3;
import "@openzeppelin/contracts/access/Ownable.sol";

contract BackdoorAttack is Ownable{
    constructor() Ownable(){

    }

    function start() public onlyOwner {

    }
}
