// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "forge-std/Test.sol";
import "forge-std/console.sol";

contract TestDelegateCallValue is Test {
    A a;
    address sender = address(100);
    function setUp() public {
        a = new A();
        vm.deal(address(a), 5e18);
    }

    function testDelegateValue() public {
        vm.deal(sender, 1e18);
        vm.prank(sender);
        a.call{value: 1e18}();

        console.log("Balance A", address(a).balance);
    }
}
contract C {
    uint256 i;
    function call() external payable {
        console.log("Value: ", msg.value);

        i++;
        (bool success, ) = address(this).delegatecall(
            abi.encodeWithSignature("call()")
        );
        require(success, "Delegate Call Failed");
    }
    receive() external payable {}
}
contract A {
    uint256 i;
    function call() external payable {
        console.log("Value: ", msg.value);

        i++;
        (bool success, ) = address(this).delegatecall(
            abi.encodeWithSignature("call()")
        );
        require(success, "Delegate Call Failed");
    }
    receive() external payable {}
}
