// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWallet {

    function balanceOf(address user) external view returns (uint balance);
    function award(address user, uint amount) external;
    function use(address user, uint amount) external;

}
