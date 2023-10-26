# Table of Contents

- [Medium Issues](#medium-issues)
  - [M-1: Centralization Risk for trusted owners](#M-1)
- [Low Issues](#low-issues)
  - [L-1: `abi.encodePacked()` should not be used with dynamic types when passing the result to a hash function such as `keccak256()`](#L-1)
  - [L-2: Solidity pragma should be specific, not wide](#L-2)
- [NC Issues](#nc-issues)
  - [NC-1: Missing checks for `address(0)` when assigning values to address state variables](#NC-1)
  - [NC-2: Functions not used internally could be marked external](#NC-2)
  - [NC-3: Constants should be defined and used instead of literals](#NC-3)
  - [NC-4: Event is missing `indexed` fields](#NC-4)


# Medium Issues

<a name="M-1"></a>
## M-1: Centralization Risk for trusted owners

Contracts have owners with privileged rights to perform admin tasks and need to be trusted to not perform malicious updates or drain funds.

- Found in src/PuppyRaffle.sol: unknown
- Found in src/PuppyRaffle.sol: 7780:9:35


# Low Issues

<a name="L-1"></a>
## L-1: `abi.encodePacked()` should not be used with dynamic types when passing the result to a hash function such as `keccak256()`

Use `abi.encode()` instead which will pad items to 32 bytes, which will [prevent hash collisions](https://docs.soliditylang.org/en/v0.8.13/abi-spec.html#non-standard-packed-mode) (e.g. `abi.encodePacked(0x123,0x456)` => `0x123456` => `abi.encodePacked(0x1,0x23456)`, but `abi.encode(0x123,0x456)` => `0x0...1230...456`). Unless there is a compelling reason, `abi.encode` should be preferred. If there is only one argument to `abi.encodePacked()` it can often be cast to `bytes()` or `bytes32()` [instead](https://ethereum.stackexchange.com/questions/30912/how-to-compare-strings-in-solidity#answer-82739).
If all arguments are strings and or bytes, `bytes.concat()` should be used instead.

- Found in src/PuppyRaffle.sol: 8858:16:35
- Found in src/PuppyRaffle.sol: 8986:16:35


<a name="L-2"></a>
## L-2: Solidity pragma should be specific, not wide

Consider using a specific version of Solidity in your contracts instead of a wide version. For example, instead of `pragma solidity ^0.8.0;`, use `pragma solidity 0.8.0;`

- Found in src/PuppyRaffle.sol: 32:23:35


# NC Issues

<a name="NC-1"></a>
## NC-1: Missing checks for `address(0)` when assigning values to address state variables

Assigning values to address state variables without checking for `address(0)`.

- Found in src/PuppyRaffle.sol: 7800:26:35
- Found in src/PuppyRaffle.sol: 6943:23:35
- Found in src/PuppyRaffle.sol: 2876:24:35


<a name="NC-2"></a>
## NC-2: Functions not used internally could be marked external



- Found in src/PuppyRaffle.sol: 4343:439:35
- Found in src/PuppyRaffle.sol: 3545:594:35
- Found in src/PuppyRaffle.sol: 2721:574:35
- Found in src/PuppyRaffle.sol: 8488:995:35


<a name="NC-3"></a>
## NC-3: Constants should be defined and used instead of literals



- Found in src/PuppyRaffle.sol: 3915:1:35
- Found in src/PuppyRaffle.sol: 3958:1:35
- Found in src/PuppyRaffle.sol: 5882:1:35
- Found in src/PuppyRaffle.sol: 6238:2:35
- Found in src/PuppyRaffle.sol: 6244:3:35
- Found in src/PuppyRaffle.sol: 6295:2:35
- Found in src/PuppyRaffle.sol: 6301:3:35
- Found in src/PuppyRaffle.sol: 6573:3:35


<a name="NC-4"></a>
## NC-4: Event is missing `indexed` fields

Index event fields make the field more quickly accessible to off-chain tools that parse events. However, note that each index field costs extra gas during emission, so it's not necessarily best to index the maximum allowed per event (three fields). Each event should use three indexed fields if there are three or more fields, and gas usage is not particularly of concern for the events in question. If there are fewer than three fields, all of the fields should be indexed.

- Found in src/PuppyRaffle.sol: 2389:40:35
- Found in src/PuppyRaffle.sol: 2476:47:35
- Found in src/PuppyRaffle.sol: 2434:37:35


