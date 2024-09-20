// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "forge-std/Test.sol";

contract DexTest is Test {
    SwappableToken token1;
    SwappableToken token2;
    Dex dex;
    address anyone = address(256);
    function setUp() public {
        dex = new Dex();
        token1 = new SwappableToken(address(dex), "DAI", "DAI", 1e24);
        token2 = new SwappableToken(address(dex), "MKR", "MKR", 1e24);

        dex.setTokens(address(token1), address(token2));
        token1.transfer(address(dex), 1000e18);
        token2.transfer(address(dex), 1000e18);
        token1.transfer(anyone, 10e18);
        token2.transfer(anyone, 10e18);

        uint256 dexToken1 = token1.balanceOf(address(dex));
        uint256 dexToken2 = token2.balanceOf(address(dex));
        uint256 anyoneToken1 = token1.balanceOf(anyone);
        uint256 anyoneToken2 = token2.balanceOf(anyone);
        console.log("Token1: ", dexToken1, dexToken2);
        console.log("Token2: ", anyoneToken1, anyoneToken2);
    }

    function testInitalState() public {
        vm.startPrank(anyone);
        uint256 i;
        while (26 > i) {
            uint256 anyoneToken1 = token1.balanceOf(anyone);
            uint256 dexToken2Reserves = token2.balanceOf(address(dex));
            uint256 swapAmount1 = dex.getSwapPrice(
                address(token1),
                address(token2),
                anyoneToken1
            );
            console.log("SWAP 1 2", dexToken2Reserves, swapAmount1);
            if (dexToken2Reserves >= swapAmount1) {
                IERC20(address(token1)).approve(address(dex), anyoneToken1);
                dex.swap(address(token1), address(token2), anyoneToken1);
            } else {
                uint256 amountIn = _getAmountIn(
                    address(token1),
                    address(token2),
                    dexToken2Reserves
                );
                console.log("SWAP 1 2 << ", dexToken2Reserves, amountIn);
                IERC20(address(token1)).approve(address(dex), amountIn);
                dex.swap(address(token1), address(token2), amountIn);
            }

            uint256 anyoneToken2 = token2.balanceOf(anyone);

            uint256 dexToken1Reserves = token1.balanceOf(address(dex));
            dexToken2Reserves = token2.balanceOf(address(dex));

            if (dexToken2Reserves == 0) {
                i++;
                continue;
            }

            uint256 swapAmount = dex.getSwapPrice(
                address(token2),
                address(token1),
                anyoneToken2
            );
            console.log("SWAP 2 1", dexToken1Reserves, swapAmount);
            if (dexToken1Reserves >= swapAmount) {
                IERC20(address(token2)).approve(address(dex), anyoneToken2);
                dex.swap(address(token2), address(token1), anyoneToken2);
            } else {
                uint256 amountIn = _getAmountIn(
                    address(token1),
                    address(token2),
                    dexToken1Reserves
                );
                IERC20(address(token2)).approve(address(dex), amountIn);
                dex.swap(address(token2), address(token1), amountIn);
            }
            i++;
        }
        vm.stopPrank();
        uint256 dexToken1 = token1.balanceOf(address(dex));
        uint256 dexToken2 = token2.balanceOf(address(dex));
        uint256 anyoneToken1 = token1.balanceOf(anyone);
        uint256 anyoneToken2 = token2.balanceOf(anyone);

        console.log("Token1: ", dexToken1, dexToken2);
        console.log("Token2: ", anyoneToken1, anyoneToken2);
    }

    function _getAmountIn(
        address token0,
        address token1,
        uint256 amountOut
    ) internal view returns (uint256) {
        uint256 reserves0 = IERC20(token0).balanceOf(address(dex));
        uint256 reserves1 = IERC20(token1).balanceOf(address(dex));

        uint256 numerator = reserves0 * amountOut;
        uint256 denominator = reserves1;
        return numerator / denominator;
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
            (from == token1 && to == token2) ||
                (from == token2 && to == token1),
            "Invalid tokens"
        );
        require(
            IERC20(from).balanceOf(msg.sender) >= amount,
            "Not enough to swap"
        );
        uint256 swapAmount = getSwapPrice(from, to, amount);
        IERC20(from).transferFrom(msg.sender, address(this), amount);
        IERC20(to).approve(address(this), swapAmount);
        console.log("SwapAmount", IERC20(to).balanceOf(address(this)));
        IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
        //1010000000000000000000
        //2019999999999999919393
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
}
