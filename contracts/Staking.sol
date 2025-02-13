// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol"; // Импортируем основной контракт

contract Staking {
    IERC20 public token; 

    uint8 public rewardCof = 13;
    uint256 public totalStaked;
    uint256 public maximumStakingPeriod;
    uint256 public minimumStakingPeriod;

    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 endTime;
        uint256 lastRewardTime;
    }

    mapping(address => Stake[]) public staked;

    event Staked(address indexed user, uint256 amount, uint256 timestamp);
    event Unstaked(address indexed user, uint256 amount, uint256 timestamp);
    event RewardsClaimed(address indexed user, uint256 amount, uint256 timestamp);

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress); // Инициализация контракта token
    }
    
    function stake(uint256 amount, uint256 time) public returns (bool success) {
        require(amount > 0, "You can not stake zero tokens");
        require(time <= maximumStakingPeriod, "Time period bigger than limits");
        require(time >= minimumStakingPeriod, "Time is lesser than limit");

        // Переводим токены от пользователя в контракт стейкинга
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        staked[msg.sender].push(Stake({
            amount: amount,
            startTime: block.timestamp,
            endTime: block.timestamp + time,
            lastRewardTime: block.timestamp
        }));

        totalStaked += amount;
        emit Staked(msg.sender, amount, block.timestamp);
        return true;
    }

    function unstake(uint256 index) public {
        require(staked[msg.sender][index].amount > 0, "This stake does not exist");
        require(staked[msg.sender][index].endTime <= block.timestamp, "You can not unstake now");

        uint256 amount = staked[msg.sender][index].amount;
        totalStaked -= amount;

        // Возвращаем токены пользователю
        require(token.transfer(msg.sender, amount), "Transfer failed");

        emit Unstaked(msg.sender, amount, block.timestamp);

        delete staked[msg.sender][index];
    }

    function claimReward(uint256 index) public returns (bool success) {
        require(staked[msg.sender][index].amount > 0, "No staked amount found");
        uint256 totalReward = calculateReward(msg.sender, index);
        require(totalReward > 0, "No reward to claim");

        // Переводим вознаграждение пользователю
        require(token.transfer(msg.sender, totalReward), "Transfer failed");

        staked[msg.sender][index].lastRewardTime = block.timestamp;

        emit RewardsClaimed(msg.sender, totalReward, block.timestamp);
        return true;
    }

    function calculateReward(address user_address, uint256 index) public view returns (uint256 reward) {
        uint256 stakedAmount = staked[user_address][index].amount;
        uint256 lastTime = staked[user_address][index].lastRewardTime;
        uint256 stakingDuration = block.timestamp - lastTime;
        reward = stakedAmount * stakingDuration * rewardCof / (100 * 30 days);
        return reward;
    }

    function setMinimumStakingPeriod(uint256 newMinimumStakingPeriod) public {
        minimumStakingPeriod = newMinimumStakingPeriod;
    }

    function setMaximumStakingPeriod(uint256 newMaximumStakingPeriod) public {
        maximumStakingPeriod = newMaximumStakingPeriod;
    }
}