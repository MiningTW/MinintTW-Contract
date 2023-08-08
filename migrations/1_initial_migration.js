const MTW = artifacts.require("MTW");

// token address: 0x07946259C40f8dA5270d7657A56f7628A88a6613
// pair: 0xc699266c2119f81a91812f5caacf3b7986089952
module.exports = function (deployer) {
  let name = "VTS"
  let symbol = "VTS"
  let admin = "0xDC6F036a6FE27c8e70F4cf3b2f87Bd97a6b29a2f"
  let daoFundAddr = "0x787B2DC9F5ad0b4867CC199D24024CAe9fB24046"
  let _swapRouter = "0x74f743b803080Dd6Ed85eEf9D58826f35317FbA4"  //oriswap
  let _wethTarget = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"

  deployer.deploy(MTW, name, symbol, admin, daoFundAddr, _swapRouter, _wethTarget);
};
