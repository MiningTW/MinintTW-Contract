const { deploy } = require("truffle-contract/lib/execute");

const DisYieldLogic = artifacts.require("DisYieldLogic");
const DisYieldManager = artifacts.require("DisYieldManager");

// DIS
let DeployedLogicContract = '0xb497cAf4B6139813498Ee84Ff80224866de82AaC'
let DeployedAdminContract = '0x5703Fca41771F04AFB64deE665E8A877B11186F8'
let DeployedProxyContract = '0x26bdaC451fE5A111a9D8a066c23BD0F099b9E563'

const needUpdate = true

module.exports = async function (deployer, network) {
  console.log(network, DeployedLogicContract, DeployedAdminContract, DeployedProxyContract)

  let deployedMinter = null;

  if(needUpdate) {
    console.log("deploying new contract")
    await deployer.deploy(DisYieldLogic).then((instance)=> {
      deployedMinter = instance;
    });
  } else {
    console.log("loading pre contract")
    await DisYieldLogic.at(DeployedLogicContract).then((instance) => {
      deployedMinter = instance
    })
  }
  console.log('DisYieldLogic match succeed:', DisYieldLogic.address)

  let adminContract = null;
  await DisYieldManager.at(DeployedAdminContract).then(adminIns => {
    adminContract = adminIns
  })

  await adminContract.upgrade(DeployedProxyContract, DisYieldLogic.address).then(v => {
    console.log('updated by admin', v)
  })
};