const { deploy } = require("truffle-contract/lib/execute");

const DisPledgeLogic = artifacts.require("DisPledgeLogic");
const DisPledgeManager = artifacts.require("DisPledgeManager");

// DIS
let DeployedLogicContract = '0x6C36831289858e25664B2e04E3805baBE2C08735'
let DeployedAdminContract = '0xCC5c38F6DBee64b72c4e7487E2fabE63B6c21051'
let DeployedProxyContract = '0xB0CA66Dd744b640a44AA690749BC3c3fC3ECa43A'

const needUpdate = true

module.exports = async function (deployer, network) {
  console.log(network, DeployedLogicContract, DeployedAdminContract, DeployedProxyContract)

  let deployedMinter = null;

  if(needUpdate) {
    console.log("deploying new contract")
    await deployer.deploy(DisPledgeLogic).then((instance)=> {
      deployedMinter = instance;
    });
  } else {
    console.log("loading pre contract")
    await DisPledgeLogic.at(DeployedLogicContract).then((instance) => {
      deployedMinter = instance
    })
  }
  console.log('DisPledgeLogic match succeed:', DisPledgeLogic.address)

  let adminContract = null;
  await DisPledgeManager.at(DeployedAdminContract).then(adminIns => {
    adminContract = adminIns
  })

  await adminContract.upgrade(DeployedProxyContract, DisPledgeLogic.address).then(v => {
    console.log('updated by admin', v)
  })
};