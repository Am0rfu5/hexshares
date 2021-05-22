const HEX = artifacts.require("HEX");
const HEXShare = artifacts.require("HEXShare");
const HEXStakePool = artifacts.require("HEXStakePool");

module.exports = function (deployer) {
    deployer.then(async () => {
        const { address: hexAddress } = await deployer.deploy(HEX);
        const { address: poolAddress } = await deployer.deploy(HEXStakePool, hexAddress);
        await deployer.deploy(HEXShare, hexAddress, poolAddress); 
    });
};
