pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./HEXProxy.sol";
import "./StakePool.sol";

struct Deposit {
    uint256 stakeIndex;
    uint256 hearts;
}

contract SharePool is ERC20 {
    HEXProxy private _hex;
    StakePool private _pool;

    mapping(address => Deposit[]) internal _deposits;

    constructor(address hex_address, address pool_address)
        ERC20("SHAREDAY", "SHAREDAY")
    {
        _hex = HEXProxy(hex_address);
        _pool = StakePool(pool_address);
    }

    function deposit(uint256 hearts) public {
        require(hearts > 0, "Must deposit some hearts");

        _hex.transferFrom(msg.sender, address(_pool), hearts);
        _deposits[msg.sender].push(Deposit(_pool.currentStakeIndex(), hearts));
    }

    function mint(uint256 depositId, uint256 stakeIndex) public {
        // verify the stake and determine how large it is.
        uint72 stakeShares = _pool.stakeShares(stakeIndex);
        uint72 stakedHearts = _pool.stakedHearts(stakeIndex);
        require(
            stakeShares > 0 && stakedHearts > 0,
            "This stake is not ready."
        );

        // load the sender's deposit and calculate their share award.
        Deposit memory _deposit = _deposits[msg.sender][depositId];
        require(_deposit.stakeIndex == stakeIndex, "Invalid stake index");
        uint256 shares = (_deposit.hearts / stakedHearts) * stakeShares;

        // mint the sender their shares.
        _mint(msg.sender, shares);
    }

    function burn(uint256 shares) public {
        // verify this burn is valid.
        require(shares > 0, "You must burn at least some shares");
        require(
            balanceOf(msg.sender) >= shares,
            "You do not have enough shares to burn"
        );

        // determine how many hearts to transfer
        uint256 supply = _hex.balanceOf(address(this));
        uint256 hearts = (supply * shares) / totalSupply();

        // burn and transfer.
        _burn(msg.sender, shares);
        _hex.transfer(msg.sender, hearts);
    }
}
