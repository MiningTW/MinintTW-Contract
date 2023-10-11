const { deploy } = require("truffle-contract/lib/execute");

const DisUpgradeDynamic = artifacts.require("DisUpgradeDynamic");
const DisUpgradeManager = artifacts.require("DisUpgradeManager");

// ETHF
let DeployedLogicContract = '0x5aeBD11d99f3e8291FBFFa0bd1bc1450BF6df75E'
let DeployedAdminContract = '0xCB39a59CAe86A1E221beD165937549E815FcF72B'
let DeployedProxyContract = '0xFbed0dF745E55dD6B9A4F6E76aE04907E607f322'

const needUpdate = true

module.exports = async function (deployer, network) {
  if(network=='bsc_mainnet') {
    DeployedLogicContract = '0x88365fFE69d13eC2e387A38F7Cd924eE32147D75'
    DeployedAdminContract = '0xcD3F3a2c7C58Ae3de0ABAE1e40b9Fe0F5B7A00Dd'
    DeployedProxyContract = '0x3433Dd268D59a120Ed69824065cf6bE506c08262'
  }
  console.log(network, DeployedLogicContract, DeployedAdminContract, DeployedProxyContract)

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