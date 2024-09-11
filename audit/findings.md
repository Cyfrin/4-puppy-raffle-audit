### [H-#] Reentrancy at `PuppyRaffle::refund` allows a malicious contract to `re-refund` a user, eventually draining `Raffle` funds completely.

**Description:** Refund does not distinguishes between EOA or Smart Contract Addreses, in case of refund is called by malicious SmartContracts. Refund does remove `caller` before interaction, allowing `reentracy` by calling `contracts::fallback | receive` functions then calling `refund` again until no funds are left.

**Impact:** Reentracy will absolutely drain protocol's entire Funds.
**Proof of Concept**

```javascript
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

```

**Recommened Mitigation**

- Delete player before sending entranceFee at `PuppyRaffle:refund`:

```diff
+       players[playerIndex] = address(0);
        payable(msg.sender).sendValue(entranceFee);
-       players[playerIndex] = address(0);
        emit RaffleRefunded(playerAddress);
```

### [H-1] Duplicate players verification generates a DOS for larger list of players, causing `PuppyRaffle::enterRaffle` to be expensive, making it unavailable for incomming players

**Description:** duplicate players verification, is done by comparing a new player againts players through a nested loop, which is a heavy computation for larger arrays. the firsts transaction will be cheaper in comparison agains later transactions.

**Impact:** Makes the protocol unavailable for incoming players due to the extremly high gas cost.
**Proof of Concept**

```javascript
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
```

**Recommened Mitigation**

- Change the protocol so that it uses a `mapping (address => uint256)  playerToRaffleId` which can be used to verify duplicity in `constant` time.

### [H-1] `PuppyRuffle::totalFees` supports only a `max of uint64` beyond that it overflows and damages recauded fees.

**Description:** Player will normally join as long as raffle round is available but once `totalFees` reached its max value it will be re-started causing `max of uint64 * times` to be loss.

**Impact:** Overflow damages `n max of uint64 times` fees collecs, since no mechanis are included to withdraw contract's funds, but totalFee and prizepool, parts of fees will be locked.
**Proof of Concept:**

```javascript
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

```

**Recommened Mitigation:**

- use of wide `uint` variable type to support higher fees.
- use safeMath logic to handle overflows.
- use of new pragma version up from `0.8.0` to revert if overfloww occurs

### [H-2] Use of wide range of pragma version, cause the lack of newests security checks agains known vulnerabilities.

**Description:** PuppyRaffle uses a wide range of pragma versions `PuppyRaffle::pragma solidity ^0.7.6`.

**Impact:** Uncovered potential issues like overflows, pottentially causing misshandling ether for fees collection.
**Proof of Concept**

```javascript
totalFees = totalFees + uint64(fee);
```

**Recommened Mitigation:** usage of single version of pragma, any newest version up to `0.8.0` is recomended, securing operations for overflow automatic checks.

### [S-#] TITLE: ROOT : IMPACT

**Description:**
**Impact:**
**Proof of Concept**
**Recommened Mitigation**
