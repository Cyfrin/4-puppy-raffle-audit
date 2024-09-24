// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "forge-std/Test.sol";
import "forge-std/StdInvariant.sol";

import "./../mocks/MockUSDC.sol";
import "./../mocks/YeildERC20.sol";
import "./Handler.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./../../src/ERC20Router.sol";
contract FuzzTestRouter is StdInvariant, Test {
    address owner = makeAddr("owner");
    uint256 initialSupply;
    ERC20Router router;
    Handler handler;
    MockUSDC usdc;
    YeildERC20 yeild;
    IERC20[] public supportedTokens;

    function setUp() public {
        vm.startPrank(owner);
        usdc = new MockUSDC();
        yeild = new YeildERC20();

        initialSupply = yeild.INITIAL_SUPPLY();
        usdc.mint(owner, initialSupply);

        supportedTokens.push(usdc);
        supportedTokens.push(yeild);
        router = new ERC20Router(supportedTokens);
        handler = new Handler(router, yeild, usdc);
        vm.stopPrank();

        bytes4[] memory selectors = new bytes4[](3);
        selectors[0] = handler.depositYeild.selector;
        selectors[1] = handler.withdrawUSDC.selector;
        selectors[2] = handler.withdrawYeild.selector;

        targetSelector(
            FuzzSelector({addr: address(handler), selectors: selectors})
        );
        targetContract(address(handler));
    }

    function statefulFuzz_testInvariantRouter() public {
        vm.startPrank(owner);
        router.withdrawToken(usdc);
        router.withdrawToken(yeild);
        vm.stopPrank();

        assert(usdc.balanceOf(address(router)) == 0);
        assert(yeild.balanceOf(address(yeild)) == 0);
        assert(usdc.balanceOf(owner) == initialSupply);
        assert(yeild.balanceOf(owner) == initialSupply);
    }
}
