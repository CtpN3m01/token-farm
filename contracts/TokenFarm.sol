// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./DAppToken.sol";
import "./LPToken.sol";

/**
* @title Proportional Token Farm
* @notice Staking contract with proportional reward distribution based on user stake
* @dev Implements checkpoint-based reward calculation to ensure accurate distribution
*/

contract TokenFarm {
    // State variables
    string public name = "Proportional Token Farm";
    address public owner;
    DAppToken public dappToken;
    LPToken public lpToken;


    // Reward configuration with min/max bounds
    uint256 public minRewardPerBlock;
    uint256 public maxRewardPerBlock;
    uint256 public rewardPerBlock;

    uint256 public totalStakingBalance; // Total LP tokens currently staked

    // Commission system (basis points: 10000 = 100%)
    uint16 public commissionRate; // Commission rate on reward claims
    uint256 public accumulatedCommission; // Total DAPP tokens collected as commission


    struct UserInfo {
        uint256 stakingBalance;
        uint256 checkpoint; // Last block number when rewards were calculated
        uint256 pendingRewards; // Accumulated DAPP rewards pending claim
        bool hasStaked;
        bool isStaking;
    }


    mapping(address => UserInfo) public users;
    address[] public stakers;

    // Events
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 payout, uint256 fee);
    event RewardsDistributed(address indexed user, uint256 amount);
    event RewardsDistributedAll(uint256 usersUpdated);


    event RewardRangeUpdated(uint256 minRewardPerBlock, uint256 maxRewardPerBlock);
    event RewardPerBlockUpdated(uint256 rewardPerBlock);
    event CommissionRateUpdated(uint16 commissionRate);
    event CommissionWithdrawn(address indexed to, uint256 amount);


    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    modifier onlyStaker() {
        require(users[msg.sender].isStaking, "Not staking");
        _;
    }

    // Constructor
    constructor(DAppToken _dappToken, LPToken _lpToken) {
        dappToken = _dappToken;
        lpToken = _lpToken;
        owner = msg.sender;
        // Default reward configuration: 1 DAPP token per block
        minRewardPerBlock = 1e18;
        maxRewardPerBlock = 1e18;
        rewardPerBlock = 1e18;
        commissionRate = 0; // No commission by default
    }

    // View functions
    function stakersLength() external view returns (uint256) { return stakers.length; }

    // Owner configuration functions
    function setRewardRange(uint256 _min, uint256 _max) external onlyOwner {
        require(_min <= _max, "min > max");
        minRewardPerBlock = _min;
        maxRewardPerBlock = _max;
        // Adjust current reward rate if it's outside the new range
        if (rewardPerBlock < _min) rewardPerBlock = _min;
        if (rewardPerBlock > _max) rewardPerBlock = _max;
        emit RewardRangeUpdated(_min, _max);
    }

    function setRewardPerBlock(uint256 _value) external onlyOwner {
        require(_value >= minRewardPerBlock && _value <= maxRewardPerBlock, "out of range");
        rewardPerBlock = _value;
        emit RewardPerBlockUpdated(_value);
    }

    function setCommissionRate(uint16 _bps) external onlyOwner {
        require(_bps <= 10_000, "bps > 100%");
        commissionRate = _bps;
        emit CommissionRateUpdated(_bps);
    }

    function withdrawCommission(address _to) external onlyOwner {
        uint256 amount = accumulatedCommission;
        require(amount > 0, "no commission");
        accumulatedCommission = 0;
        dappToken.mint(_to, amount);
        emit CommissionWithdrawn(_to, amount);
    }

    // User actions
    function deposit(uint256 _amount) external {
        require(_amount > 0, "amount = 0");
        // Update user rewards before modifying their balance
        _distributeRewards(msg.sender);

        // Transfer LP tokens to the contract
        lpToken.transferFrom(msg.sender, address(this), _amount);

        // Update balances and user state
        UserInfo storage u = users[msg.sender];
        u.stakingBalance += _amount;
        totalStakingBalance += _amount;
        if (!u.hasStaked) {
            stakers.push(msg.sender);
            u.hasStaked = true;
        }
        u.isStaking = true;
        u.checkpoint = block.number;
        emit Deposit(msg.sender, _amount);
    }

    function withdraw() external onlyStaker {
        UserInfo storage u = users[msg.sender];
        uint256 bal = u.stakingBalance;
        require(bal > 0, "no balance");


        // Update rewards before resetting balance
        _distributeRewards(msg.sender);

        // Reset user balance and staking status
        u.stakingBalance = 0;
        totalStakingBalance -= bal;
        u.isStaking = false;
        u.checkpoint = block.number;

        // Transfer LP tokens back to user
        lpToken.transfer(msg.sender, bal);
        emit Withdraw(msg.sender, bal);
    }

    function claimRewards() external {
        UserInfo storage u = users[msg.sender];
        uint256 pendingAmount = u.pendingRewards;
        require(pendingAmount > 0, "no rewards");

        // Reset pending rewards
        u.pendingRewards = 0;

        // Calculate commission and net payout
        uint256 fee = (pendingAmount * commissionRate) / 10_000;
        uint256 payout = pendingAmount - fee;
        if (fee > 0) {
        accumulatedCommission += fee;
        }

        // Mint DAPP tokens to user (contract must be token owner)
        dappToken.mint(msg.sender, payout);
        emit RewardsClaimed(msg.sender, payout, fee);
    }

    // Reward distribution functions
    function distributeRewardsAll() external onlyOwner {
        uint256 updated;
        for (uint256 i = 0; i < stakers.length; i++) {
            address s = stakers[i];
            UserInfo storage u = users[s];
            if (u.isStaking && u.stakingBalance > 0) {
                _distributeRewards(s);
                updated++;
            }
        }
        emit RewardsDistributedAll(updated);
    }

    /**
    * @dev Calculates and credits rewards for beneficiary based on blocks elapsed
    * and their proportion of total staked amount
    */
    function _distributeRewards(address beneficiary) internal {
        UserInfo storage u = users[beneficiary];
        // Initialize checkpoint for first-time users
        if (u.checkpoint == 0) {
            u.checkpoint = block.number;
            return;
        }
        if (block.number <= u.checkpoint) return;
        if (totalStakingBalance == 0 || u.stakingBalance == 0) {
            u.checkpoint = block.number;
            return;
        }
        uint256 blocksPassed = block.number - u.checkpoint;
        // Calculate proportional share with 18 decimal precision
        uint256 shareScaled = (u.stakingBalance * 1e18) / totalStakingBalance;
        uint256 reward = (rewardPerBlock * blocksPassed * shareScaled) / 1e18;
        if (reward > 0) {
            u.pendingRewards += reward;
            emit RewardsDistributed(beneficiary, reward);
        }
        u.checkpoint = block.number;
    }

}