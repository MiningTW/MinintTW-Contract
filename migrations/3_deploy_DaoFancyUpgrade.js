const { deploy } = require("truffle-contract/lib/execute");

const DaoManager = artifacts.require("DaoManager");
const DaoFancy = artifacts.require("DaoFancy");

const DeployedLogicContract = '0x4e38890FcF0dD8e9bc2B1D382A9102E55b427781'
const DeployedAdminContract = '0x8395283784a83d4b39F98490e8894454191BB481'
const DeployedProxyContract = '0x787B2DC9F5ad0b4867CC199D24024CAe9fB24046'



const needUpdate = true

module.exports = async function (deployer) {
  let deployedMinter = null;

  if(needUpdate) {
    console.log("deploying new contract")
    await deployer.deploy(DaoFancy).then((instance)=> {
      deployedMinter = instance;
    });
  } else {
    console.log("loading pre contract")
    await DaoFancy.at(DeployedLogicContract).then((instance) => {
      deployedMinter = instance
    })
  }
  console.log('DaoFancy match succeed:', DaoFancy.address)

  let adminContract = null;
  await DaoManager.at(DeployedAdminContract).then(adminIns => {
    adminContract = adminIns
  })

  await adminContract.upgrade(DeployedProxyContract, DaoFancy.address).then(v => {
    console.log('updated by admin', v)
  })
};