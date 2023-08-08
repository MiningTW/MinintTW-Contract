const { deploy } = require("truffle-contract/lib/execute");

const DaoFancy = artifacts.require("DaoFancy");
const DaoProxy = artifacts.require("DaoProxy");
const DaoManager = artifacts.require("DaoManager");

module.exports = async function (deployer) {
  
  await deployer.deploy(DaoFancy).then((instance)=> {
  });
  console.log('DaoFancy deploy succeed:', DaoFancy.address)

  let adminIns;
  await deployer.deploy(DaoManager).then((instance) => {
    adminIns = instance
  })

  let deployProxyIns = null;
  await deployer.deploy(DaoProxy, DaoFancy.address, "0x").then((instance) => {
    deployProxyIns = instance;
  })

  await deployProxyIns.changeAdmin(DaoManager.address).then(result => {
    console.log('update admin', result.tx, result.receipt.status)
  })

  await adminIns.configCall(DaoProxy.address, "0x8129fc1c").then(result => {
    console.log('initialize', result.tx, result.receipt.status)
  })

};