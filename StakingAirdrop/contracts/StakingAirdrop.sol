// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// Import OpenZeppelin contracts for safe ERC20 operations and security

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title StakingAirdrop
 * @dev This contract implements a staking-based airdrop system. Users can stake ERC20 tokens, 
 * earn rewards based on the staking duration, and get premium access if they stake above a threshold.
 */
contract StakingAirdrop is ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @notice ERC20 token used for staking
    IERC20 public stakingToken;

    /// @notice ERC20 token used for rewards
    IERC20 public rewardToken;

    /// @notice Total amount of rewards available in the pool
    uint256 public totalReward;

    /// @notice Available rewards remaining in the pool
    uint256 public availableReward;

    /// @notice Minimum amount of tokens required for premium access
    uint256 public constant PREMIUM_THRESHOLD = 1000 * 1e18; // Adjust decimals if necessary

    /// @notice Struct to store information about individual stakers
    struct Staker {
        uint256 amountStaked;
        uint256 stakingPeriod;
        uint256 startTime;
        bool hasPremiumAccess;
    }

    /// @notice Mapping from user address to staker information
    mapping(address => Staker) public stakers;

    /// @notice Event emitted when a user stakes tokens
    /// @param user The address of the user staking tokens
    /// @param amount The amount of tokens staked
    /// @param stakingPeriod The duration for which tokens are staked
    event Stake(address indexed user, uint256 amount, uint256 stakingPeriod);

    /// @notice Event emitted when a user unstakes tokens and claims rewards
    /// @param user The address of the user unstaking tokens
    /// @param amount The amount of tokens unstaked
    /// @param reward The reward tokens claimed by the user
    event Unstake(address indexed user, uint256 amount, uint256 reward);

    /**
     * @dev Constructor to initialize staking and reward tokens
     * @param _stakingToken The ERC20 token used for staking
     * @param _rewardToken The ERC20 token used for rewards
     */
    constructor(IERC20 _stakingToken, IERC20 _rewardToken) {
        stakingToken = _stakingToken;
        rewardToken = _rewardToken;
    }

    /**
     * @notice Fund the reward pool with reward tokens
     * @param _amount The amount of reward tokens to add to the pool
     */
    function fundRewardPool(uint256 _amount) external {
        totalReward += _amount;
        availableReward += _amount;

        // Transfer reward tokens from the funder to the contract
        rewardToken.safeTransferFrom(msg.sender, address(this), _amount);
    }

    /**
     * @notice Stake tokens into the staking pool
     * @param _amount The amount of tokens to stake
     * @param _stakingPeriod The duration (in seconds) for which tokens are staked
     */
    function stakeTokens(uint256 _amount, uint256 _stakingPeriod) external nonReentrant {
        Staker storage staker = stakers[msg.sender];

        // Ensure the user isn't already staking
        require(staker.amountStaked == 0, "Already staked");

        // Update staker information
        staker.amountStaked = _amount;
        staker.stakingPeriod = _stakingPeriod;
        staker.startTime = block.timestamp;
        staker.hasPremiumAccess = _amount >= PREMIUM_THRESHOLD;

        // Transfer staked tokens from user to contract
        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);

        // Emit an event to log the staking action
        emit Stake(msg.sender, _amount, _stakingPeriod);
    }

    /**
     * @notice Unstake tokens and claim rewards after the staking period ends
     */
    function unstakeAndClaim() external nonReentrant {
        Staker storage staker = stakers[msg.sender];

        // Ensure the user has tokens staked
        require(staker.amountStaked > 0, "No tokens staked");

        // Ensure the staking period is complete
        require(
            block.timestamp >= staker.startTime + staker.stakingPeriod,
            "Staking period not complete"
        );

        // Calculate reward based on staking period and amount
        uint256 reward = calculateReward(
            staker.amountStaked,
            block.timestamp - staker.startTime
        );

        // Ensure the pool has enough rewards left
        require(availableReward >= reward, "Insufficient reward pool");

        // Transfer staked tokens back to user
        stakingToken.safeTransfer(msg.sender, staker.amountStaked);

        // Transfer reward tokens to user
        rewardToken.safeTransfer(msg.sender, reward);

        // Reduce available reward in the pool
        availableReward -= reward;

        // Emit an event to log the unstaking action
        emit Unstake(msg.sender, staker.amountStaked, reward);

        // Reset staker information
        staker.amountStaked = 0;
        staker.hasPremiumAccess = false;
    }

    /**
     * @notice Internal function to calculate rewards based on staked amount and time
     * @param _amountStaked The amount of tokens staked
     * @param _elapsedTime The time (in seconds) the tokens have been staked
     * @return The reward calculated based on the staked amount and time
     */
    function calculateReward(uint256 _amountStaked, uint256 _elapsedTime)
        internal
        view
        returns (uint256)
    {
        // Linear reward calculation as an example
        // Rewards are proportional to the amount staked and the staking duration
        uint256 reward = (_amountStaked * _elapsedTime) / 30 days;

        // Ensure reward doesn't exceed available pool
        if (reward > availableReward) {
            reward = availableReward;
        }

        return reward;
    }

    /**
     * @notice Check if a user has premium access based on their staked amount
     * @param _user The address of the user
     * @return True if the user has premium access, false otherwise
     */
    function hasPremiumAccess(address _user) external view returns (bool) {
        return stakers[_user].hasPremiumAccess;
    }

    /**
     * @notice Get staker information for a specific user
     * @param _user The address of the user
     * @return amountStaked The amount of tokens staked by the user
     * @return stakingPeriod The duration for which the user staked tokens
     * @return startTime The time when the staking began
     * @return hasPremium True if the user has premium access, false otherwise
     */
    function getStakerInfo(address _user)
        external
        view
        returns (
            uint256 amountStaked,
            uint256 stakingPeriod,
            uint256 startTime,
            bool hasPremium
        )
    {
        Staker memory staker = stakers[_user];
        return (
            staker.amountStaked,
            staker.stakingPeriod,
            staker.startTime,
            staker.hasPremiumAccess
        );
    }
}
