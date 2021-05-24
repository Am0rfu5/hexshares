pragma solidity ^0.8.4;

abstract contract StakeCalculator {
    uint256 internal constant HEARTS_PER_HEX = 100000000;

    /* Stake shares Longer Pays Better bonus constants used by _stakeStartBonusHearts() */
    uint256 private constant LPB_BONUS_PERCENT = 20;
    uint256 private constant LPB_BONUS_MAX_PERCENT = 200;
    uint256 internal constant LPB = (364 * 100) / LPB_BONUS_PERCENT;
    uint256 internal constant LPB_MAX_DAYS =
        (LPB * LPB_BONUS_MAX_PERCENT) / 100;

    /* Stake shares Bigger Pays Better bonus constants used by _stakeStartBonusHearts() */
    uint256 private constant BPB_BONUS_PERCENT = 10;
    uint256 private constant BPB_MAX_HEX = 150 * 1e6;
    uint256 internal constant BPB_MAX_HEARTS = BPB_MAX_HEX * HEARTS_PER_HEX;
    uint256 internal constant BPB = (BPB_MAX_HEARTS * 100) / BPB_BONUS_PERCENT;

    /* Share rate is scaled to increase precision */
    uint256 internal constant SHARE_RATE_SCALE = 1e5;

    function _calcStakeShares(
        uint256 _stakedHearts,
        uint256 _shareRate,
        uint256 _stakedDays
    ) internal pure returns (uint256) {
        uint256 bonusHearts = _calcBonusHearts(_stakedHearts, _stakedDays);
        return ((_stakedHearts + bonusHearts) * SHARE_RATE_SCALE) / _shareRate;
    }

    /**
     * @dev Calculate bonus Hearts for a new stake, if any
     * @param newStakedHearts Number of Hearts to stake
     * @param newStakedDays Number of days to stake
     */
    function _calcBonusHearts(uint256 newStakedHearts, uint256 newStakedDays)
        private
        pure
        returns (uint256 bonusHearts)
    {
        uint256 cappedExtraDays = 0;

        /* Must be more than 1 day for Longer-Pays-Better */
        if (newStakedDays > 1) {
            cappedExtraDays = newStakedDays <= LPB_MAX_DAYS
                ? newStakedDays - 1
                : LPB_MAX_DAYS;
        }

        uint256 cappedStakedHearts =
            newStakedHearts <= BPB_MAX_HEARTS
                ? newStakedHearts
                : BPB_MAX_HEARTS;

        bonusHearts = cappedExtraDays * BPB + cappedStakedHearts * LPB;
        bonusHearts = (newStakedHearts * bonusHearts) / (LPB * BPB);

        return bonusHearts;
    }
}
