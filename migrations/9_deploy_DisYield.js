const { deploy } = require("truffle-contract/lib/execute");

const DisYieldLogic = artifacts.require("DisYieldLogic");
const DisYieldProxy = artifacts.require("DisYieldProxy");
const DisYieldManager = artifacts.require("DisYieldManager");

module.exports = async function (deployer, network) {
  
  let logicIns
  await deployer.deploy(DisYieldLogic).then((instance)=> {
    logicIns = instance
  });
  console.log('DisYieldLogic deploy succeed:', DisYieldLogic.address)

  let adminIns;
  await deployer.deploy(DisYieldManager).then((instance) => {
    adminIns = instance
  })

  let deployProxyIns = null;
  await deployer.deploy(DisYieldProxy, DisYieldLogic.address, "0x").then((instance) => {
    deployProxyIns = instance;
  })

  await deployProxyIns.changeAdmin(DisYieldManager.address).then(result => {
    console.log('update admin', result.tx, result.receipt.status)
  })

  await adminIns.configCall(DisYieldProxy.address, "0x8129fc1c").then(result => {
    console.log('initialize', result.tx, result.receipt.status)
  })

};
