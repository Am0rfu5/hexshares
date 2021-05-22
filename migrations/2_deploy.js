const HEX = artifacts.require("HEX");
const HEXShare = artifacts.require("HEXShare");

module.exports = function (deployer) {
    deployer.then(async () => {
        const { address } = await deployer.deploy(HEX);
        await deployer.deploy(HEXShare, address); 
    });
};
