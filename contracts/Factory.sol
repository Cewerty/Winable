// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.28;

import "./Pool.sol";

contract Factory {
    mapping(address => mapping(address => address)) public pools;
    address[] public allPools;

    function createPool(address tokenA, address tokenB) external {
        require(tokenA != tokenB, "Identical tokens");
        (address token0, address token1) = tokenA < tokenB 
            ? (tokenA, tokenB) 
            : (tokenB, tokenA);
        
        require(pools[token0][token1] == address(0), "Pool exists");
        
        Pool pool = new Pool();
        pool.initialize(token0, token1);
        pools[token0][token1] = address(pool);
        allPools.push(address(pool));
    }

    function getPool(address tokenA, address tokenB) external view returns (address) {
        (address token0, address token1) = tokenA < tokenB 
            ? (tokenA, tokenB) 
            : (tokenB, tokenA);
        return pools[token0][token1];
    }
}
