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

