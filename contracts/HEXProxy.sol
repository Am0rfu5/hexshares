pragma solidity ^0.8.4;

contract HEXProxy {
    // HEX specific
    function globalInfo() external view returns (uint256[13] memory) {}

    function stakeStart(uint256 newStakedHearts, uint256 newStakedDays)
        external
    {}

    function stakeEnd(uint256 stakeIndex, uint40 stakeIdParam) external {}

    function currentDay() external view returns (uint256) {}

    // ERC20
    function approve(address spender, uint256 amount)
        public
        virtual
        returns (bool)
    {}

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual returns (bool) {}

    function balanceOf(address account) public view virtual returns (uint256) {}
}
