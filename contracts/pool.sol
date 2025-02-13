/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./ERC20.sol";

contract Pool {
    address public token0;
    address public token1;
    address public factory;
    address public owner;
    
    uint256 public reserve0;
    uint256 public reserve1;
    uint256 public totalSupply;

    constructor() {
        factory = msg.sender;
    }

    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, "Only factory");
        token0 = _token0;
        token1 = _token1;
        owner = tx.origin;
    }

    function addLiquidity(uint256 amount0, uint256 amount1) external {
        IERC20(token0).transferFrom(msg.sender, address(this), amount0);
        IERC20(token1).transferFrom(msg.sender, address(this), amount1);
        
        uint256 liquidity;
        if (totalSupply == 0) {
            liquidity = sqrt(amount0 * amount1);
        } else {
            liquidity = min(
                (amount0 * totalSupply) / reserve0,
                (amount1 * totalSupply) / reserve1
            );
        }
        _updateReserves();
    }

    function removeLiquidity(uint256 liquidity) external {
        uint256 amount0 = (liquidity * reserve0) / totalSupply;
        uint256 amount1 = (liquidity * reserve1) / totalSupply;
    
        IERC20(token0).transfer(msg.sender, amount0);
        IERC20(token1).transfer(msg.sender, amount1);
        _updateReserves();
    }

    function swap(uint256 amountIn, address tokenIn) external {
        require(tokenIn == token0 || tokenIn == token1, "Invalid token");
        
        (uint256 reserveIn, uint256 reserveOut) = tokenIn == token0 
            ? (reserve0, reserve1) 
            : (reserve1, reserve0);
        
        uint256 amountOut = (reserveOut * amountIn) / (reserveIn + amountIn);
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        
        if (tokenIn == token0) {
            IERC20(token1).transfer(msg.sender, amountOut);
        } else {
            IERC20(token0).transfer(msg.sender, amountOut);
        }
        _updateReserves();
    }

    function _updateReserves() private {
        reserve0 = IERC20(token0).balanceOf(address(this));
        reserve1 = IERC20(token1).balanceOf(address(this));
    }

    function sqrt(uint256 x) private pure returns (uint256) {
        uint256 z = (x + 1) / 2;
        uint256 y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        return y;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}