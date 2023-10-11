const { deploy } = require("truffle-contract/lib/execute");

const DisUpgradeDynamic = artifacts.require("DisUpgradeDynamic");
const DisUpgradeManager = artifacts.require("DisUpgradeManager");

const DeployedLogicContract = '0xA3D9DC4Fcd34bDDcA7E5F8cD6e98D3de7F46C01f'
const DeployedAdminContract = '0x1d83E88F808B68372Ad5439ba5922a0e74af49C0'
const DeployedProxyContract = '0xe218A4F06677742E62b2b4Ee6d83f7eCA11A2787'



const needUpdate = true

module.exports = async function (deployer) {
  let deployedMinter = null;

  if(needUpdate) {
    console.log("deploying new contract")
    await deployer.deploy(DisUpgradeDynamic).then((instance)=> {
      deployedMinter = instance;
    });
  } else {
    console.log("loading pre contract")
    await DisUpgradeDynamic.at(DeployedLogicContract).then((instance) => {
      deployedMinter = instance
    })
  }
  console.log('DisUpgradeDynamic match succeed:', DisUpgradeDynamic.address)

  let adminContract = null;
  await DisUpgradeManager.at(DeployedAdminContract).then(adminIns => {
    adminContract = adminIns
  })

  await adminContract.upgrade(DeployedProxyContract, DisUpgradeDynamic.address).then(v => {
    console.log('updated by admin', v)
  })
};