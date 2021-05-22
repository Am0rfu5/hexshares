pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

struct GlobalsStore {
    // 1
    uint72 lockedHeartsTotal;
    uint72 nextStakeSharesTotal;
    uint40 shareRate;
    uint72 stakePenaltyTotal;
    // 2
    uint16 dailyDataCount;
    uint72 stakeSharesTotal;
    uint40 latestStakeId;
    uint128 claimStats;
}

contract HEXProxy {
    function globalInfo() external view returns (uint256[13] memory) {}
    function approve(address spender, uint256 amount) public virtual returns (bool) {}
    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {}
}

contract StakePool {

}

contract HEXShare is ERC20 {
    HEXProxy private _hex;

    constructor(address hex_address) ERC20("HEXSHARE", "HEXSHARE") {
        _hex = HEXProxy(hex_address);
    }

    function mint(uint256 amount) public {
        _hex.transferFrom(msg.sender, address(this), amount);

        uint256 shareRate = getShareRate();
        uint256 shares = amount * shareRate * 5555;

        _mint(msg.sender, shares);
    }

    function getShareRate() public view returns (uint256) {
        return  _hex.globalInfo()[2];
    }
}