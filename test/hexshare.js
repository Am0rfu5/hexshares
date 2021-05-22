const HEX = artifacts.require('HEX');
const HEXShare = artifacts.require("HEXShare");

contract('HEXShare', (accounts) => {
  it('should mint tokens to sender', async () => {
    const hex = await HEX.deployed();
    const shares = await HEXShare.deployed();

    // get some HEX for account 0
    await hex.freeClaim(10000);

    // approve the hexshare contract to transfer HEX
    const balance = parseInt((await hex.balanceOf.call(accounts[0])).toString());
    await hex.approve(shares.address, balance);

    // mint the shares
    await shares.mint(balance);

    // check the balances
    const myShares = await shares.balanceOf.call(accounts[0]);
    const myHex = await hex.balanceOf.call(accounts[0]);
    const contractHex = await hex.balanceOf.call(shares.address);

    assert.equal(myHex.toString(), '0', 'HEX is left over in the first account.');
    assert.equal(myShares.toString(), '555500000000000000000', 'First account has incorrect amount of Shares.');
    assert.equal(contractHex.toString(), '1000000000000', 'Contract has incorrect amount of HEX.')
  });

});
