// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import '@openzeppelin/contracts/utils/math/Math.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract DisUpgradeDynamic is Initializable, OwnableUpgradeable {

    using SafeMath for uint256;

    IERC20 public disToken; // = IERC20(0xe2EcC66E14eFa96E9c55945f79564f468882D24C);

    uint256 public onBlockTs;
    uint256 public offBlockTs;

    uint256 private _totalSupply;
    uint256 public rewardPerTokenStored;
    uint256 public lastUpdateTime = onBlockTs;
    uint256 public rewardPerSec;   //Init per token reward per second

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public receiveReward;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public lastStakeTime;
    mapping(address => uint256) private _balances;

    event StakeReward(address _user, uint256 _time, uint256 _amount);

    function initialize() public initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
        rewardPerSec = 317097919837645865;
    }

    modifier _cutoff() {
        require(onBlockTs != 0 || offBlockTs != 0 || block.timestamp < onBlockTs, 'not started');
        require(block.timestamp >= onBlockTs && block.timestamp <= offBlockTs, "ended");
        _;
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored.add(
            lastTimeRewardApplicable()
                .sub(lastUpdateTime)
                .mul(rewardPerSec)
                .mul(1e18)
                .div(totalSupply())
        );
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function earned(address account) public view returns (uint256) {
        return balanceOf(account).mul(rewardPerToken().sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
    }

    function stakeAndReward(uint256 _amount) external updateReward(msg.sender) _cutoff payable {
        require(_amount > 0, "zero amount");

         if(_chainId() == uint(56)) {
            require(disToken.allowance(msg.sender, address(this)) >= _amount, "insufficient allowance");
            require(disToken.transferFrom(msg.sender, address(this), _amount), "transfer token failed");
        } else if(_chainId() == uint(1)) {  // For EthereumFair
            require(msg.value == _amount);
        } else {
            revert("not correct chainid");
        }

        deposits[msg.sender] = deposits[msg.sender].add(_amount);
        _totalSupply = _totalSupply.add(_amount);
        _balances[msg.sender] = _balances[msg.sender].add(_amount);
        lastStakeTime[msg.sender] = block.timestamp;

        emit StakeReward(msg.sender, block.timestamp, _amount);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, offBlockTs);
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function _chainId() internal view returns (uint id) {
        assembly { id := chainid() }
    }

    function readChainId() view external returns(uint) {
        return _chainId();
    }

    function notifyRange(uint256 _start, uint256 _end, address _disToken) external onlyOwner {
        onBlockTs = _start;
        offBlockTs = _end;

        if(_disToken != address(0) && address(disToken) != address(0)) {    // assigned for once
            disToken = IERC20(_disToken);
            disToken.approve(address(this), ~uint256(0));
        }
    }

    function withdraw(uint256 _tOrC, address _receiver) external onlyOwner {
        if(_tOrC == 0) {
            payable(_receiver).transfer(address(this).balance);
        } else {
            if(address(disToken) != address(0)) {
                disToken.transferFrom(address(this), _receiver, disToken.balanceOf(address(this)));
            }
        }
    }
}