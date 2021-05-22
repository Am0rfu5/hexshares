pragma solidity ^0.8.4;

contract HEXProxy {
    function globalInfo() external view returns (uint256[13] memory) {}
    function approve(address spender, uint256 amount) public virtual returns (bool) {}
    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {}
    function stakeStart(uint256 newStakedHearts, uint256 newStakedDays) external {}
    function stakeEnd(uint256 stakeIndex, uint40 stakeIdParam) external {}
    function currentDay() external view returns (uint256) {}
}