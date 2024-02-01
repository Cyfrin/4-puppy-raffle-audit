### [M-#] Array in `PuffyRaffle::enterRaffle` is a potencial denial of service (DoS) attack, incrementing gas costs dor future participants

**Description:** 

The `PuppyRaffle::enterRaffle` function loops through the `players` array to check for duplicates. The longer the `PuppyRaffle::players` array is, the more checks a new player will have to make. This will cause the gas costs to increase over time. First players will have advantage on joining the raffle first.

```javascript
//@audit DoS Attack
@>        for (uint256 i = 0; i < players.length - 1; i++) {
            for (uint256 j = i + 1; j < players.length; j++) {
                require(players[i] != players[j], "PuppyRaffle: Duplicate player");
            }
        }
```


**Impact:**

 The gas costs for raffle players will increase as more players join. This discourages later users from entering to a new position.

An attacker might fill up the `PuppyRaffle::players` array so no one else enters, guarenteeing themselves the win.

**Proof of Concept:**

If we have 2 sets of 100 players entering the raffle, the gas costs will be as such:

  Gas cost for the first 100 players: 6252048
  Gas cost for the second 100 players: 18068138

<details>
<summary>PoC</summary>
Place the following test into `PuppyRaffleTest.t.sol`. 

```javascript
    function test_DenialOfService() public {

        vm.txGasPrice(1);

        // First 100 players entering the raffle
        uint256 numPlayers = 100;
        address[] memory players = new address[](numPlayers);
        for(uint256 i = 0; i < numPlayers; i++) {
            players[i] = address(i);
        }

        // Check gas costs
        uint256 initialGas = gasleft();
        puppyRaffle.enterRaffle {value: entranceFee * players.length}(players);
        uint256 finalGas = gasleft();
        uint256 gasUsedFirstPlayers = (initialGas - finalGas) * tx.gasprice;
        console.log("Gas cost for the first 100 players", gasUsedFirstPlayers);

        // Second 100 players entering the raffle
        address[] memory players2 = new address[](numPlayers);
        for(uint256 i = 0; i < numPlayers; i++) {
            players2[i] = address(i + numPlayers);
        }

        // Check gas costs
        uint256 secondInitialGas = gasleft();
        puppyRaffle.enterRaffle {value: entranceFee * players.length}(players2);
        uint256 secondFinalGas = gasleft();
        uint256 gasUsedSecondPlayers = (secondInitialGas - secondFinalGas) * tx.gasprice;
        console.log("Gas cost for the second 100 players", gasUsedSecondPlayers);        
    }
```
</details>


**Recommended Mitigation:** There are a few recomendations.

1. Consider allowing duplicates. Users can still make new addresses and join the raffle. Duplicate check doesn't prevent the same person from entering multiple times, only the same wallet address. 

2.  Consider using a mapping for duplicates. This would allow constant time lookup of wheter a user has already entered.



