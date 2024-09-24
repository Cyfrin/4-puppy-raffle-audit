//SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "forge-std/interfaces/IERC20.sol";

contract Transfer is Script {
    function run() public {
        uint256 pk = vm.envUint("PK");
        address me = vm.addr(pk);

        address recipient = 0x417BE21941f6Abc9752C8d2d78B31685E045eD8d;

        IERC20 token0 = IERC20(0xDB64c706913203d4eB86925c8a2A9b47Bfb0eadB);
        IERC20 token1 = IERC20(0xE38D2533E4c3E1ECD5116dE90E4012f1323511dF);

        vm.startBroadcast(pk);

        uint256 balance0 = token0.balanceOf(me);
        uint256 balance1 = token1.balanceOf(me);

        bool transact0 = token0.transfer(recipient, balance0);
        bool transact1 = token1.transfer(recipient, balance1);

        require(transact0 && transact1, "Transfer Token0 and Token1 Failed");

        uint256 dex0 = token0.balanceOf(recipient);
        uint256 dex1 = token1.balanceOf(recipient);
        vm.stopBroadcast();

        console.log("DEX Token0 Token1: ", dex0, dex1);
    }
}
