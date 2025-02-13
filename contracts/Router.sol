// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.28;

import "./Factory.sol";
import "./ERC20.sol";
import "./Pool.sol";


contract Router {
    Factory public factory;

    constructor(address _factory) {
        factory = Factory(_factory);
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired
    ) external {
        address pool = factory.getPool(tokenA, tokenB);
        if (pool == address(0)) {
            factory.createPool(tokenA, tokenB);
            pool = factory.getPool(tokenA, tokenB);
        }
        
        require(IERC20(tokenA).transferFrom(msg.sender, pool, amountADesired));
        require(IERC20(tokenB).transferFrom(msg.sender, pool, amountBDesired));
        Pool(pool).addLiquidity(amountADesired, amountBDesired);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidityToRemove
    ) external {
        address pool = factory.getPool(tokenA, tokenB);
        require(pool != address(0), "Pool not exists");

        Pool(pool).removeLiquidity(liquidityToRemove);
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        address tokenIn,
        address tokenOut
    ) external {
        address pool = factory.getPool(tokenIn, tokenOut);
        require(pool != address(0), "Pool not exists");
        
        IERC20(tokenIn).transferFrom(msg.sender, pool, amountIn);
        Pool(pool).swap(amountIn, tokenIn);
    }
}