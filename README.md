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
