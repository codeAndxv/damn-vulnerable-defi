// SPDX-License-Identifier: GPL-2.0+
pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ClimberVaultV2  is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    constructor() initializer {

    }

    function initialize() initializer external {
        // Initialize inheritance chain
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function sweepFunds(address tokenAddress) external onlyOwner{
        IERC20 token = IERC20(tokenAddress);
        require(token.transfer(owner(), token.balanceOf(address(this))), "Transfer failed");
    }

    // By marking this internal function with `onlyOwner`, we only allow the owner account to authorize an upgrade
    function _authorizeUpgrade(address newImplementation) internal onlyOwner override {}
}
