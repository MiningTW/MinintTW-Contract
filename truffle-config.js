const HDWalletProvider = require('@truffle/hdwallet-provider')
const dotenv = require("dotenv")

dotenv.config()
const infuraKey = process.env.INFURA_KEY || ''
const infuraSecret = process.env.INFURA_SECRET || ''
const liveNetworkPK = process.env.LIVE_PK || ''
const privateKey = [ liveNetworkPK ]
const privateAddress = process.env.LIVE_ADDRESS
const etherscanApiKey = process.env.ETHERS_SCAN_API_KEY || ''
const polygonApiKey = process.env.POLYGON_SCAN_API_KEY || ''
const bscApiKey = process.env.BSC_SCAN_API_KEY || ''

const liveNetworkPKBase = process.env.BASE_PK || ''
const privateKeyBase = [ liveNetworkPKBase ]
const privateAddressBase = process.env.BASE_ADDRESS


module.exports = {
  networks: {
    ganache: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "5777",
      websocket: true
    },
    goerli: {
      provider: () => new HDWalletProvider({
        privateKeys: privateKey,
        //providerOrUrl: `https://:${infuraSecret}@goerli.infura.io/v3/${infuraKey}`,
        providerOrUrl: `wss://:${infuraSecret}@goerli.infura.io/ws/v3/${infuraKey}`,
        pollingInterval: 56000
      }),
      network_id: 5,
      confirmations: 2,
      timeoutBlocks: 100,
      skipDryRun: true,
      from: privateAddress,
      networkCheckTimeout: 999999
    },
    bsc_testnet: {
      provider: () => new HDWalletProvider({
        privateKeys: privateKey,
        providerOrUrl: `https://data-seed-prebsc-1-s1.binance.org:8545`,
        pollingInterval: 56000
      }),
      network_id: 97,
      confirmations: 2,
      timeoutBlocks: 100,
      from: privateAddress,
      skipDryRun: true,
      networkCheckTimeout: 999999
    },
    ethf_mainnet: {
      provider: () => new HDWalletProvider({
        privateKeys: privateKey,
        providerOrUrl: `https://rpc.etherfair.org`,
        pollingInterval: 56000
      }),
      network_id: 513100,
      confirmations: 2,
      timeoutBlocks: 100,
      skipDryRun: true,
      from: privateAddress,
      networkCheckTimeout: 99999999
    },
    bsc_mainnet: {
      provider: () => new HDWalletProvider({
        privateKeys: privateKey,
        providerOrUrl: `https://bsc-dataseed1.ninicoin.io`,
        pollingInterval: 56000
      }),
      network_id: 56,
      confirmations: 2,
      timeoutBlocks: 100,
      skipDryRun: true,
      from: privateAddress,
      networkCheckTimeout: 999999,
      gasPrice: 3000000000
    },
    base_mainnet: {
      provider: () => new HDWalletProvider({
        privateKeys: privateKeyBase,
        providerOrUrl: `https://mainnet.base.org`,
        pollingInterval: 56000
      }),
      network_id: 8453,
      confirmations: 2,
      timeoutBlocks: 100,
      skipDryRun: true,
      from: privateAddressBase,
      networkCheckTimeout: 999999
    }
  },
  mocha: {
    timeout: 100_000
  },
  compilers: {
    solc: {
      version: "0.8.17",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        },
        evmVersion: "london"
      }
    }
  },
  db: {
    enabled: false
  },
  plugins: ['truffle-plugin-verify'],
  api_keys: {
    etherscan: etherscanApiKey,
    bscscan: bscApiKey,
    polygonscan: polygonApiKey
  }
};
