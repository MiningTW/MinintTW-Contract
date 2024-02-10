const { deploy } = require("truffle-contract/lib/execute");

const AnyLpLock = artifacts.require("AnyLpLock");

module.exports = async function (deployer, network) {
  
  let logicIns
  await deployer.deploy(AnyLpLock).then((instance)=> {
    logicIns = instance
  });
  console.log('AnyLpLock deploy succeed:', AnyLpLock.address)

};
