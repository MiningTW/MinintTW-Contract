const { deploy } = require("truffle-contract/lib/execute");

const DisPledgeLogic = artifacts.require("DisPledgeLogic");
const DisPledgeProxy = artifacts.require("DisPledgeProxy");
const DisPledgeManager = artifacts.require("DisPledgeManager");

module.exports = async function (deployer, network) {
  
  let logicIns
  await deployer.deploy(DisPledgeLogic).then((instance)=> {
    logicIns = instance
  });
  console.log('DisPledgeLogic deploy succeed:', DisPledgeLogic.address)

  let adminIns;
  await deployer.deploy(DisPledgeManager).then((instance) => {
    adminIns = instance
  })

  let deployProxyIns = null;
  await deployer.deploy(DisPledgeProxy, DisPledgeLogic.address, "0x").then((instance) => {
    deployProxyIns = instance;
  })

  await deployProxyIns.changeAdmin(DisPledgeManager.address).then(result => {
    console.log('update admin', result.tx, result.receipt.status)
  })

  await adminIns.configCall(DisPledgeProxy.address, "0x8129fc1c").then(result => {
    console.log('initialize', result.tx, result.receipt.status)
  })

};
