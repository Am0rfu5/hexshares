pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./HEXProxy.sol";
import "./StakePool.sol";

contract Share is ERC20 {
    HEXProxy private _hex;
    StakePool private _pool;

    constructor(address hex_address, address pool_address)
        ERC20("SHAREDAY", "SHAREDAY")
    {
        _hex = HEXProxy(hex_address);
        _pool = StakePool(pool_address);
    }

    function mint(uint256 amount) public {
        _hex.transferFrom(msg.sender, address(_pool), amount);

        uint256 shareRate = getShareRate();
        uint256 shares = amount * shareRate * 5555;

        _mint(msg.sender, shares);
    }

    function getShareRate() public view returns (uint256) {
        return _hex.globalInfo()[2];
    }
}