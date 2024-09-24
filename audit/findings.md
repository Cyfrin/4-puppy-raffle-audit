### [H-] Prizepool transfer by `PuppyRaffle::selectWinner` might fail, Ineficient and gas no worth gas consumption

**Description:** In case a winner is selected and in case its address is a contract that does not handles ether receives will fail.

**Impact:** I might make the Protocol unfair since it does not indicate a player address requirement.

**Proof of concept:**

1. a minimal of 4 players join
2. someones selects a winner
   1. caller will lose some gas due to `call(""): revert`
   2. winner is unfair ignored
   3. a next winner will be required

**Recommend Mitigation:**

1. For players require them to handle ether receives otherwise unfainess are not contemplated.
2. do not allow Smart contract as players
3. implement a machanism for winner to claim `prizePool` by them selves, having a mapping `mapping (winner => prizePool)` to keep traceability.

### [H-#] WithdrawFees uses unsecure balance check, not considering forced ether senta in the Protocol.

**Description:** `PuppyRaffle::withdrawFees` comparess `address(this).balance` in order to verify fees collection agains Protocol's balance, not considering forced ether sent such `selfDestruct`, disabling the `withdrawFees` mechanism forever.

**Impact:** Blocks Protocol's Fees forever.

```javascript
require(address(this).balance ==
  uint256(totalFees), "PuppyRaffle: There are currently players active!");
```

**Proof of Concept:**

<details>

```javascript
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

```

</details>

**Recommened Mitigation**

- modify protocol fees tracking way of trust.

### [H-1] Revert intentionally attack, no matter the secure way used for Random generation atackers can revert if winner is not favorable.

**Description:** `PuppeyRaffle::selectWinner` exposes the currentWinner after computing the random number (winner), which updates Protocol's state, enabling its read and compare against desired winner addresses, if disliked outer transtactions can revert and re-execute in their favor any times.

**Impact:** Raffle winner and Funds might end up in attackers favor.

**Proof of Concept:**

```javascript
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
```

**Recommened Mitigation**

- use a commit reveal schema and do not expose latest winner.

### [H-1] Weak random number generation, facilitates end user to call winner only if the are or if they like it.

**Description:** `PuppeyRaffle::selectWinner` weakly generates random number in order to pick up a winner, which is untrustly due to `block` built-in properties to be altered by miners, enabling the `selectWinner` to be called only by their preference.

**Impact:** Winners might be picked up in anyone else's favor.

**Proof of Concept:**
By altering block properties or awaiting a TX until favor conditions are meet to match up the random number generated will break the Protocol's trust.

```javascript
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
```

**Recommened Mitigation**

- Usage of verifiable or secured way of random number generation such Chainlink VRF.

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

# Low Vulnerabilities

### [L-1] `PuppyRuffle:getActivePlayerIndex` returns 0 if player is unactive, unclarifying first entered user if active or not.

**Description:** for activity checks the Protocol provides an idex to active players, player indexed after 1, are well responded but zero-Indexed users not, pushing the to run other Protocol features to verify their activity, resulting in bad gas usage.

**Impact:** Affects zero-indexed users by providing poor user-experience.

**Proof of concept:**

```javascript
    function getActivePlayerIndex(
        address player
    ) external view returns (uint256) {
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i] == player) {
                return i;
            }
        }
        //@audit-advice: User at index 0, might think not being active
        return 0;
    }

```

**Recomend Mitigation:**

- revert for inactive users
- return i256 meaning that -1 is returned for inactive users.

# Gas

### [G-1] Unchanged variables should be marked as constant or immutable

mark `raffleDuration` as immutable and `nft::uris` as constants for gas savings, knowing that storage read from `storage` of `immutable | constants` are cheaper.

### [G-4] Consider cahed size of storage arrays length

```diff
+ uint256 players= players.length;
+ for (uint256 i = 0; i < players - 1; i++) {
+    for (uint256 j = i + 1; j < players; j++) {
+        //doSomething()
+    }
+}
```

# Pragma

### [I-1] Dynamic pragma version

consider using a especific solidity version for example `0.8.0`

### [I-2] Ussage of outdated solidity version

Please use newest versions of solidity due to security implications and the take of advantage of new features such `0.8.0` or above, which includes:

- Unchecked Blocks
- Automatic overdlow checks
- etc.
-

### [I-3] Consider zero-address checks for fee claiming address

```diff
+ //check address(0)
  feeAddress = _feeAddress;
```

### [I-3] Consider using constant variables instead of hardcoded values

```diff
    uint256 prizePool = (totalAmountCollected * 80) / 100;
    uint256 fee = (totalAmountCollected * 20) / 100;
```

### [I-4] Consider removing unused functions

```javascript
    function _isActivePlayer() internal view returns (bool) {
        for (uint256 i = 0; i < players.length; i++) {
                return true;
            if (players[i] == msg.sender) {
            }
        }
        return false;
    }
```

### [I-4] Consider indexing events

```diff
+    event FeeAddressChanged(address indexed newFeeAddress);
-    event FeeAddressChanged(address newFeeAddress);

    function changeFeeAddress(address newFeeAddress) external onlyOwner {
        feeAddress = newFeeAddress;
        emit FeeAddressChanged(newFeeAddress);

    }
```

### [S-#] TITLE: ROOT : IMPACT

**Description:**
**Impact:**
**Proof of Concept**
**Recommened Mitigation**
