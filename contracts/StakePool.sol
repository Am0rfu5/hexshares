pragma solidity ^0.8.4;

import "./HEXProxy.sol";

contract GovernedStakePool {
    uint256 internal constant STAKE_LENGTH = 7;
    uint256 internal constant MINIMUM_STAKED_HEX = 1000;
}

contract StakePool is GovernedStakePool {
    HEXProxy private _hex;

    uint256 internal constant HEARTS_PER_HEX = 100000000;
    uint256 internal constant MINIMUM_STAKED_HEARTS =
        MINIMUM_STAKED_HEX * HEARTS_PER_HEX;

    struct Stake {
        uint40 stakeId;
        uint72 stakedHearts;
        uint256 startDay;
        uint256 endDay;
        bool unstaked;
    }

    mapping(uint256 => uint256) public stakingDays; // day to stake index- .
    Stake[] public stakes;

    constructor(address hex_address) {
        _hex = HEXProxy(hex_address);
    }

    function startStake() external {
        // verify that we haven't staked yet today
        uint256 startDay = _hex.currentDay();
        require(
            stakes.length == 0 ||
                (stakingDays[startDay] == uint256(0) && startDay != 0),
            "HEX has already been staked today"
        );

        // determine the staking size and verify it.
        uint256 newStakedHearts = _hex.balanceOf(address(this));
        require(
            newStakedHearts > MINIMUM_STAKED_HEARTS,
            "There is not enough HEX to stake"
        );

        // begin the stake.
        _hex.stakeStart(newStakedHearts, STAKE_LENGTH);

        // store the stake for future retrieval
        stakingDays[startDay] = stakes.length;
        stakes.push(
            Stake(
                uint40(lastStakeId()),
                uint72(newStakedHearts),
                startDay,
                startDay + STAKE_LENGTH,
                false
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
        require(!stake.unstaked, "You cannot end a stake that is unstaked");
        // stakes entered on day 0 lasting n days end after n + 2 days for a 1 day buffer on each side
        require(
            currentDay > stake.endDay + 1,
            "You cannot end a stake before it's due"
        );

        // end the stake
        _hex.stakeEnd(index, stake.stakeId);
        stakes[index].unstaked = true;

        // TODO: transfer HEX back to shares
    }

    function lastStakeId() public view returns (uint256) {
        return _hex.globalInfo()[6];
    }
}
