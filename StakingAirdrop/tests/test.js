// Test file for StakingAirdrop.sol
// SPDX-License-Identifier: MIT

/**
 * @title StakingAirdrop Test
 * @notice This script tests the main functionalities of the StakingAirdrop contract, including token staking, reward pool funding, 
 * and unstaking & claiming rewards.
 * @dev Ensure that you are using Remix's JavaScript VM to run these tests. No external dependencies are required beyond those in Remix.
 */
async function runTests() {
    console.log("Starting tests for StakingAirdrop");

    // Deploy the staking and reward tokens
    const StakingToken = await deployContract("ERC20", ["Staking Token", "STK"]);
    const RewardToken = await deployContract("ERC20", ["Reward Token", "RWD"]);

    // Deploy the StakingAirdrop contract
    const stakingAirdrop = await deployContract("StakingAirdrop", [StakingToken.address, RewardToken.address]);

    // Fund the reward pool with some reward tokens
    await RewardToken.methods.mint(stakingAirdrop.address, web3.utils.toWei('1000')).send({from: accounts[0]});
    console.log("Funded reward pool with 1000 reward tokens");

    // Approve and stake some tokens
    await StakingToken.methods.approve(stakingAirdrop.address, web3.utils.toWei('500')).send({from: accounts[1]});
    await stakingAirdrop.methods.stakeTokens(web3.utils.toWei('500'), 60).send({from: accounts[1]});
    console.log("Account 1 staked 500 tokens");

    // Check if premium access is granted
    const hasPremium = await stakingAirdrop.methods.hasPremiumAccess(accounts[1]).call();
    console.log("Account 1 has premium access:", hasPremium);

    // Fast forward time and unstake
    console.log("Simulating passage of time...");
    await timeTravel(60); // Simulate 60 seconds

    await stakingAirdrop.methods.unstakeAndClaim().send({from: accounts[1]});
    console.log("Account 1 unstaked and claimed rewards");
}

/**
 * @notice Deploys a contract with the specified name and arguments
 * @dev Uses Remix's artifacts to deploy the contract
 * @param contractName The name of the contract to deploy
 * @param args The constructor arguments for the contract
 * @return The deployed contract instance
 */
async function deployContract(contractName, args = []) {
    const contract = await artifacts.require(contractName).new(...args);
    console.log(`Deployed ${contractName} at address:`, contract.address);
    return contract;
}

/**
 * @notice Simulates the passage of time in the JavaScript VM
 * @dev This function uses the evm_increaseTime and evm_mine methods provided by the web3 provider
 * @param seconds The number of seconds to fast forward
 */
async function timeTravel(seconds) {
    await web3.currentProvider.send({
        jsonrpc: '2.0',
        method: 'evm_increaseTime',
        params: [seconds],
        id: new Date().getTime()
    });
    await web3.currentProvider.send({
        jsonrpc: '2.0',
        method: 'evm_mine',
        id: new Date().getTime()
    });
}

// Run the tests
runTests().catch((err) => console.error(err));
