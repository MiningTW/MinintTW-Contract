// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Disupgrade {

    IERC20 public disToken; // = IERC20(0xe2EcC66E14eFa96E9c55945f79564f468882D24C);

    // uint256 public totalReward = 27397 ether;
    uint256 public perSecReward = 317097919837645865;
    uint256 public totalReward;

    uint256 public offBlockTs;

    mapping(address => mapping(uint256 => uint256)) public lockedMapping;   // address => timestamp => amount
    mapping(address => bool) public mapAddress;
    address[] public lockingAddresses;
    mapping(address => uint256[]) public lockingAddressTs;

    uint256 public totalWeight = 0;

    event ClaimLock(address _user, uint256 _time, uint256 _amount);

    modifier _cutoff {
        require(block.timestamp <= offBlockTs);
        _;
    }

    constructor(address _disToken, uint256 _deadline) {
        if(_disToken != address(0)) {
            disToken = IERC20(_disToken);
            disToken.approve(address(this), ~uint256(0));
        }
        offBlockTs = _deadline;
        totalReward = (offBlockTs - block.timestamp) * perSecReward;
    }

    function claimLock(uint256 _amount) external _cutoff payable {
        if(_chainId() == uint(56)) {
            require(_amount > 0 && disToken.allowance(msg.sender, address(this)) >= _amount, "insufficient allowance or zeor amount");
            require(disToken.transferFrom(msg.sender, address(this), _amount), "transfer token failed");
        } else if(_chainId() == uint(1)) {  // For EthereumFair
            require(msg.value == _amount);
        } else {
            revert("not correct chainid");
        }

        lockedMapping[msg.sender][block.timestamp] = _amount;
        if(!mapAddress[msg.sender]) {
            mapAddress[msg.sender] = true;
            lockingAddresses.push(msg.sender);
        }
        lockingAddressTs[msg.sender].push(block.timestamp);

        totalWeight += (offBlockTs - block.timestamp) * _amount;

        emit ClaimLock(msg.sender, block.timestamp, _amount);
    }

    function computeReward(address _user) view public returns(uint256) {
        if(lockingAddresses.length == 0) return 0;
        uint256 my = _singlePass(_user);
        return my * totalReward / totalWeight;
    }

    function _singlePass(address _user) view private returns(uint256) {
         uint256[] memory _stots = lockingAddressTs[_user];
         uint256 weight = 0;
         for(uint256 i=0; i<_stots.length; i++) {
            uint256 ts = _stots[i];
            uint256 tsAmount = lockedMapping[_user][ts];
            weight += (offBlockTs - ts) * tsAmount;
         }
         return weight;
    }

    function _chainId() internal view returns (uint id) {
        assembly { id := chainid() }
    }

    function readChainId() view external returns(uint) {
        return _chainId();
    }
}