pragma solidity ^0.8.4;

import "./HEXProxy.sol";

contract HEXStakePool {
    HEXProxy private _hex;
    uint256 internal constant STAKE_LENGTH = 5555;

    constructor(address hex_address) {
        _hex = HEXProxy(hex_address);
    }

    function lastStakeId() public view returns (uint256) {
        return _hex.globalInfo()[6];
    }
}