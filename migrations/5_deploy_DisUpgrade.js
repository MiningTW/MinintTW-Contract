const { deploy } = require("truffle-contract/lib/execute");

// const MTW = artifacts.require("DisUpgradeDynamic");

// module.exports = async function (deployer, network) {

//   let gasPrice = 1000000000; // 1 Gwei
//   let tokenAddr = '0x0000000000000000000000000000000000000000'

//   if(network=='ethf_mainnet') {
//     bidValue = web3.utils.toWei('1', 'ether');
//     gasPrice = 14000000000; // 1 Gwei
//   } else if(network=='bsc_mainnet') {
//     gasPrice = 3000000000; // 1 Gwei
//     tokenAddr = '0xe2EcC66E14eFa96E9c55945f79564f468882D24C'
//   }

//   await deployer.deploy(MTW, tokenAddr, 1695626139, 1698202853, { gasPrice: gasPrice });

//   console.log('New Contract deploy succeed:', MTW.address)
// };

const DisUpgradeDynamic = artifacts.require("DisUpgradeDynamic");
const DisUpgradeProxy = artifacts.require("DisUpgradeProxy");
const DisUpgradeManager = artifacts.require("DisUpgradeManager");

module.exports = async function (deployer, network) {
  
  await deployer.deploy(DisUpgradeDynamic).then((instance)=> {
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

  let initializeParams = "0x8129fc1c" + tokenAddr.slice(2)

  await adminIns.configCall(DisUpgradeProxy.address, initializeParams).then(result => {
    console.log('initialize', result.tx, result.receipt.status)
  })

};
