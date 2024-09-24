// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StakeTest is Test {
    //RPC: https://eth-sepolia.g.alchemy.com/v2/_dyJqMsprqMSfqUrxUGSGdWE3BRXRoE7
    Stake stake;
    address sender = address(1);
    WETHERC20 weth;
    function setUp() public {
        weth = new WETHERC20();
        stake = new Stake(address(weth));
    }

    // Stake is safe for staking native ETH and ERC20 WETH, considering the same 1:1 value of the tokens. Can you drain the contract?

    // To complete this level, the contract state must meet the following conditions:

    // The Stake contract's ETH balance has to be greater than 0.
    // totalStaked must be greater than the Stake contract's ETH balance.
    // You must be a staker.
    // Your staked balance must be 0.

    function testStake() public view {
        uint256 balance = address(stake).balance;
        uint256 totalStaked = stake.totalStaked();
        console.log("Balance, totalStaked", balance, totalStaked);
    }
}

contract WETHERC20 is ERC20 {
    constructor() ERC20("WETH", "WETH") {}
}

contract Stake {
    uint256 public totalStaked;
    mapping(address => uint256) public UserStake;
    mapping(address => bool) public Stakers;
    address public WETH;

    constructor(address _weth) payable {
        totalStaked += msg.value;
        WETH = _weth;
    }

    function StakeETH() public payable {
        require(msg.value > 0.001 ether, "Don't be cheap");
        totalStaked += msg.value;
        UserStake[msg.sender] += msg.value;
        Stakers[msg.sender] = true;
    }
    function StakeWETH(uint256 amount) public returns (bool) {
        require(amount > 0.001 ether, "Don't be cheap");
        (, bytes memory allowance) = WETH.call(
            abi.encodeWithSelector(0xdd62ed3e, msg.sender, address(this))
        );
        require(
            bytesToUint(allowance) >= amount,
            "How am I moving the funds honey?"
        );
        totalStaked += amount;
        UserStake[msg.sender] += amount;
        (bool transfered, ) = WETH.call(
            abi.encodeWithSelector(
                0x23b872dd,
                msg.sender,
                address(this),
                amount
            )
        );
        Stakers[msg.sender] = true;
        return transfered;
    }

    function Unstake(uint256 amount) public returns (bool) {
        require(UserStake[msg.sender] >= amount, "Don't be greedy");
        UserStake[msg.sender] -= amount;
        totalStaked -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        return success;
    }
    function bytesToUint(bytes memory data) internal pure returns (uint256) {
        require(data.length >= 32, "Data length must be at least 32 bytes");
        uint256 result;
        assembly {
            result := mload(add(data, 0x20))
        }
        return result;
    }
}
