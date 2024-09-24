// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "forge-std/Test.sol";

import "./../../src/ERC20Router.sol";
import "./../mocks/YeildERC20.sol";
import "./../mocks/MockUSDC.sol";

contract Handler is Test {
    ERC20Router router;
    YeildERC20 yeild;
    MockUSDC usdc;
    address owner;
    constructor(ERC20Router _router, YeildERC20 _yeild, MockUSDC _usdc) {
        router = _router;
        yeild = _yeild;
        usdc = _usdc;
        owner = yeild.owner();
    }

    function depositUSDC(uint256 _amount) public {
        uint256 amount = bound(_amount, 0, usdc.balanceOf(owner));
        vm.startPrank(owner);
        usdc.approve(address(router), amount);
        router.depositToken(usdc, amount);
        vm.stopPrank();
    }
    function depositYeild(uint256 _amount) public {
        uint256 amount = bound(_amount, 0, usdc.balanceOf(owner));
        vm.startPrank(owner);
        yeild.approve(address(router), amount);
        router.depositToken(yeild, amount);
        vm.stopPrank();
    }

    function withdrawUSDC() public {
        vm.startPrank(owner);
        router.withdrawToken(usdc);
        vm.stopPrank();
    }

    function withdrawYeild() public {
        vm.startPrank(owner);
        router.withdrawToken(yeild);
        vm.stopPrank();
    }
}
