const { deploy } = require("truffle-contract/lib/execute");

const DisYieldLogic = artifacts.require("DisYieldLogic");
const DisYieldManager = artifacts.require("DisYieldManager");

// DIS
let DeployedLogicContract = '0x0Fd4a5e92Ff19B2c74A62a7435b4871326DCc69A'
let DeployedAdminContract = '0x39e793127Aeedb77F72fF5a179DB2ee642fa002A'
let DeployedProxyContract = '0xD135726adA1Bb395947a871909379d09Aa83d3b3'

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