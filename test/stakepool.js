const HEX = artifacts.require('HEX');
const StakePool = artifacts.require("StakePool")

contract('StakePool', (accounts) => {
    it('should start stake', async () => {
        const hex = await HEX.deployed();
        const pool = await StakePool.deployed();

        const HEARTS_PER_HEX = 100000000

        // get some HEX for account 0
        await hex.freeClaim(5000 * HEARTS_PER_HEX);
        await hex.transfer(pool.address, 500 * HEARTS_PER_HEX);

        // try to begin a stake without enough hex.
        try {
            await pool.startStake();
        } catch (e) {
            assert.equal(e.reason, 'There is not enough HEX to stake', 'Staked HEX when there wasn\'t enough.');
        }

        // transfer some more hex
        await hex.transfer(pool.address, 1500 * HEARTS_PER_HEX);

        // start the stake
        await pool.startStake();

        // try to begin a stake when we've already staked today.
        try {
            await pool.startStake();
        } catch (e) {
            assert.equal(e.reason, 'HEX has already been staked today', 'Attempted to stake twice in one day.');
        }

        // advance the day and transfer some more hex
        await hex.setDay(1);
        await hex.transfer(pool.address, 1500 * HEARTS_PER_HEX);

        // start the stake
        await pool.startStake();

        // try to begin a stake when we've already staked today.
        try {
            await pool.startStake();
        } catch (e) {
            assert.equal(e.reason, 'HEX has already been staked today', 'Attempted to stake twice in one day.');
        }
    });

    it('should end stake', async () => {
        const hex = await HEX.deployed();
        const pool = await StakePool.deployed();

        // try to end a stake early
        try {
            await pool.endStake(0);
        } catch (e) {
            assert.equal(e.reason, 'You cannot end a stake before it\'s due');
        }

        // advance the days and end the stake
        await hex.setDay(9);
        await pool.endStake(0);

        try {
            await pool.endStake(1);
        } catch (e) {
            assert.equal(e.reason, 'You cannot end a stake before it\'s due');
        }

        // end a non existant stake
        try {
            await pool.endStake(2);
        } catch (e) {
            assert.equal(e.reason, 'HEX: stakeIndex invalid');
        }

    });
});
