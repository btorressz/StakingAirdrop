# StakingAirdrop

This smart contract implements a staking-based airdrop system on the Ethereum blockchain. Users can stake ERC20 tokens to earn rewards and gain premium access based on the amount staked. The system encourages long-term staking by aligning user incentives with reward distribution over time. 
I also made a Solana based staking airdrop as well(https://github.com/btorressz/staking_airdrop) 

## Features

- **Token Staking**: Users can stake tokens for a defined period and earn rewards.
- **Premium Access**: Users who stake a minimum amount of tokens (threshold) will gain premium access to platform features.
- **Reward Distribution**: Rewards are calculated based on the amount staked and the duration for which the tokens were staked.
- **Unstaking & Claiming Rewards**: After the staking period, users can unstake their tokens and claim rewards.

## Contracts

- `StakingAirdrop`: Main contract that handles staking, reward distribution, and premium access.

  ## Contract Details

### Staker Struct

The `Staker` struct keeps track of each user's staking information:

- `amountStaked`: The total amount of tokens staked by the user.
- `stakingPeriod`: The time (in seconds) for which the tokens are staked.
- `startTime`: The timestamp when staking began.
- `hasPremiumAccess`: Whether the user has access to premium features based on their staking amount.

### Premium Access

Users who stake an amount greater than or equal to `1000 * 10^18` tokens (assuming 18 decimals for ERC20) will receive premium access for the staking period.

## Functions

### `fundRewardPool(uint256 _amount)`
- **Purpose**: Adds reward tokens to the staking contract’s reward pool.
- **Parameters**:
  - `_amount`: The number of tokens to add to the reward pool.
- **Usage**: Ensure that you approve the contract to transfer reward tokens before calling this function.

### `stakeTokens(uint256 _amount, uint256 _stakingPeriod)`
- **Purpose**: Allows users to stake tokens for a specific period.
- **Parameters**:
  - `_amount`: The amount of tokens to stake.
  - `_stakingPeriod`: The duration (in seconds) the tokens will be locked for.
- **Emits**: `Stake` event.

### `unstakeAndClaim()`
- **Purpose**: Unstake tokens and claim the rewards after the staking period.
- **Emits**: `Unstake` event.

### `calculateReward(uint256 _amountStaked, uint256 _elapsedTime)`
- **Purpose**: Internal function that calculates the reward based on the amount of tokens staked and the time staked.

### `hasPremiumAccess(address _user)`
- **Purpose**: Checks if a user has premium access.
- **Parameters**:
  - `_user`: The address of the user.
- **Returns**: `true` if the user has premium access, `false` otherwise.

### `getStakerInfo(address _user)`
- **Purpose**: Returns detailed staking information for a user.
- **Parameters**:
  - `_user`: The address of the user.
- **Returns**: Staking details such as `amountStaked`, `stakingPeriod`, `startTime`, and `hasPremiumAccess`.

## Testing

To test the functionality of the `StakingAirdrop` contract, you can use the provided `test.js` script in Remix. This test script covers key contract functions such as staking, reward distribution, and unstaking.

### Running the Test

1. In the **Remix IDE**, create a file named `test.js` in the **File Explorer**.
2. Copy the test code into `test.js`.
3. Run the test by clicking the **Run** button in Remix.

### Test Scenarios Covered

- **Funding the Reward Pool**: Tests that the reward pool can be funded with tokens.
- **Staking Tokens**: Tests that users can stake tokens and that premium access is granted if they stake more than the threshold.
- **Unstaking and Claiming Rewards**: Tests that users can unstake their tokens and claim rewards after the staking period ends.
- **Simulating Time**: The test script includes time-traveling functionality to simulate the passage of time for testing the staking period.
