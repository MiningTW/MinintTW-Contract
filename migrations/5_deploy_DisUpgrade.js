const { deploy } = require("truffle-contract/lib/execute");

const DisUpgradeDynamic = artifacts.require("DisUpgradeDynamic");
const DisUpgradeProxy = artifacts.require("DisUpgradeProxy");
const DisUpgradeManager = artifacts.require("DisUpgradeManager");

module.exports = async function (deployer, network) {
  
  let logicIns
  await deployer.deploy(DisUpgradeDynamic).then((instance)=> {
    logicIns = instance
  });
  console.log('DisUpgradeDynamic deploy succeed:', DisUpgradeDynamic.address)

  let adminIns;
  await deployer.deploy(DisUpgradeManager).then((instance) => {
    adminIns = instance
  })

  let deployProxyIns = null;
  await deployer.deploy(DisUpgradeProxy, DisUpgradeDynamic.address, "0x").then((instance) => {
    deployProxyIns = instance;
  })

  await deployProxyIns.changeAdmin(DisUpgradeManager.address).then(result => {
    console.log('update admin', result.tx, result.receipt.status)
  })

  let tokenAddr = '0x0000000000000000000000000000000000000000'

  if(network=='bsc_mainnet') {
    tokenAddr = '0xe2EcC66E14eFa96E9c55945f79564f468882D24C'
  }

  await adminIns.configCall(DisUpgradeProxy.address, "0x8129fc1c").then(result => {
    console.log('initialize', result.tx, result.receipt.status)
  })

};
