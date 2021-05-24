pragma solidity ^0.8.4;

import "./HEXProxy.sol";
import "./StakeCalculator.sol";

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

contract StakePool is GovernedStakePool, StakeCalculator {
    HEXProxy private _hex;

    mapping(uint256 => uint256) public stakingDays; // day to stake index
    Stake[] public stakes;

    uint256 internal constant MINIMUM_STAKED_HEARTS =
        MINIMUM_STAKED_HEX * HEARTS_PER_HEX;

    constructor(address hex_address) {
        _hex = HEXProxy(hex_address);
    }

    function startStake() external {
        // verify that we haven't staked yet today
        uint256 lockDay = _hex.currentDay();
        require(
            stakes.length == 0 ||
                (stakingDays[lockDay] == uint256(0) && lockDay != 0),
            "HEX has already been staked today"
        );

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
        _hex.stakeStart(_stakedHearts, STAKE_LENGTH);

        // store the stake for future retrieval
        stakingDays[lockDay] = stakes.length;
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

    function lastStakeId() public view returns (uint256) {
        return _hex.globalInfo()[6];
    }

    function shareRate() public view returns (uint256) {
        return _hex.globalInfo()[2];
    }

    function currentStakeIndex() public view returns (uint256) {
        return stakes.length;
    }

    function stakeShares(uint256 stakeIndex) public view returns (uint72) {
        return stakes[stakeIndex].stakeShares;
    }

    function stakedHearts(uint256 stakeIndex) public view returns (uint72) {
        return stakes[stakeIndex].stakedHearts;
    }
}
