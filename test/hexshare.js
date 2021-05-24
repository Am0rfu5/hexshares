const HEX = artifacts.require('HEX');
const Share = artifacts.require("Share");
const StakePool = artifacts.require("StakePool")

contract('Share', (accounts) => {

  it('should mint tokens to sender', async () => {
    const hex = await HEX.deployed();
    const shares = await Share.deployed();

    // get some HEX for account 0
    await hex.freeClaim(10000);

    // approve the hexshare contract to transfer HEX
    const balance = parseInt((await hex.balanceOf.call(accounts[0])).toString());
    const app = await hex.approve(shares.address, balance);

    // depsoit some HEX
    await shares.deposit(100);

    // attempt to enter a stake
    try {
      await shares.stake();
    } catch (e) {
      assert.equal(e.reason, "Not enough HEX to enter a stake.");
    }

    // depsoit some more HEX
    await shares.deposit(900);
    await shares.stake();


  });


  /*it('should mint tokens to sender', async () => {
    const hex = await HEX.deployed();
    const shares = await Share.deployed();
    const pool = await StakePool.deployed();

    // get some HEX for account 0
    await hex.freeClaim(10000);

    // approve the hexshare contract to transfer HEX
    const balance = parseInt((await hex.balanceOf.call(accounts[0])).toString());
    const app = await hex.approve(shares.address, balance);
    console.log('gas used to approve', app.receipt.gasUsed)

    // mint the shares
    const res = await shares.mint(balance);
    console.log('gas used to mint', res.receipt.gasUsed)

    // check the balances
    const myShares = await shares.balanceOf.call(accounts[0]);
    const myHex = await hex.balanceOf.call(accounts[0]);
    const contractHex = await hex.balanceOf.call(pool.address);

    assert.equal(myHex.toString(), '0', 'First account has HEX left over.');
    assert.equal(myShares.toString(), '555500000000000000000', 'First account has incorrect amount of Shares.');
    assert.equal(contractHex.toString(), '1000000000000', 'Pool has incorrect amount of HEX.')
  });
  */

});
