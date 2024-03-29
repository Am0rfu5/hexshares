// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


import "./HEXProxy.sol";
import "./StakeCalculator.sol";

/**
 * @title GovernedStakePool
 * @dev GovernedStakePool is a simple staking pool that allows users to stake HEX for a fixed period of time.
 */
contract GovernedStakePool {
    uint256 internal constant STAKE_LENGTH = 7;
    uint256 internal constant MINIMUM_STAKED_HEX = 1000;
}

struct Stake {
    uint40 stakeId;
    uint72 stakedHearts;
    uint72 stakeShares;
    uint16 lockedDay;
    uint16 stakedDays;
    uint16 unlockedDay;
}

/**
 * @title StakePool
 * @dev StakePool is a simple staking pool that allows users to stake HEX for a fixed period of time.
 */
contract StakePool is GovernedStakePool, StakeCalculator {
    HEXProxy private _hex;

    Stake[] public stakes;

    uint256 internal constant MINIMUM_STAKED_HEARTS =
        MINIMUM_STAKED_HEX * HEARTS_PER_HEX;

    constructor(address hex_address) {
        _hex = HEXProxy(hex_address);
    }
    
    /**
     * @dev startStake allows a user to stake HEX for a fixed period of time.
     */
    function startStake() external {
        // determine the staking size and verify it.
        uint256 _stakedHearts = _hex.balanceOf(address(this));
        require(
            _stakedHearts > MINIMUM_STAKED_HEARTS,
            "There is not enough HEX to stake"
        );

        // calculate the shares
        uint256 _stakeShares =
            _calcStakeShares(_stakedHearts, shareRate(), STAKE_LENGTH);

        // begin the stake.
        uint256 lockDay = _hex.currentDay();
        _hex.stakeStart(_stakedHearts, STAKE_LENGTH);

        // store the stake for future retrieval
        stakes.push(
            Stake(
                uint40(lastStakeId()),
                uint72(_stakedHearts),
                uint72(_stakeShares),
                uint16(lockDay),
                uint16(STAKE_LENGTH),
                uint16(0)
            )
        );
    }
    
    /**
     * @dev endStake allows a user to end a stake before it's due.
     * @param index The index of the stake to end.
     */
    function endStake(uint256 index) external {
        // grab the relevant days
        uint256 currentDay = _hex.currentDay();

        // grab the stake
        require(stakes.length != 0, "HEX: Empty stake list");
        require(index < stakes.length, "HEX: stakeIndex invalid");
        Stake memory stake = stakes[index];

        // verify the stake.
        require(
            stake.unlockedDay == 0,
            "You cannot end a stake that is unstaked"
        );
        // stakes entered on day 0 lasting n days end after n + 2 days for a 1 day buffer on each side
        require(
            currentDay > stake.lockedDay + stake.stakedDays + 1,
            "You cannot end a stake before it's due"
        );

        // end the stake
        _hex.stakeEnd(index, stake.stakeId);
        stakes[index].unlockedDay = uint16(currentDay);

        // TODO: transfer HEX back to shares contract'
    }

    /**
     * @dev lastStakeId returns the last stakeId.
     */
    function lastStakeId() public view returns (uint256) {
        return _hex.globalInfo()[6];
    }
    
    /**
     * @dev shareRate returns the current share rate.
     */
    function shareRate() public view returns (uint256) {
        return _hex.globalInfo()[2];
    }

    /**
     * @dev currentStakeIndex returns the current stake index.
     */
    function currentStakeIndex() public view returns (uint256) {
        return stakes.length;
    }

    /**
     * @dev stakeId returns the stakeId for a given stake index.
     * @param stakeIndex The index of the stake.
     */
    function stakeShares(uint256 stakeIndex) public view returns (uint72) {
        return stakes[stakeIndex].stakeShares;
    }

    /**
     * @dev stakeId returns the stakeId for a given stake index.
     * @param stakeIndex The index of the stake.
     */
    function stakedHearts(uint256 stakeIndex) public view returns (uint72) {
        return stakes[stakeIndex].stakedHearts;
    }
}
