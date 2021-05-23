const HEX = artifacts.require("HEX");
const Share = artifacts.require("Share");
const StakePool = artifacts.require("StakePool");

module.exports = function (deployer) {
    deployer.then(async () => {
        const { address: hexAddress } = await deployer.deploy(HEX);
        const { address: poolAddress } = await deployer.deploy(StakePool, hexAddress);
        await deployer.deploy(Share, hexAddress, poolAddress);
    });
};
