// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import '@openzeppelin/contracts/utils/math/Math.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract DisYieldLogic is Initializable, OwnableUpgradeable {

    using SafeMath for uint256;

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

    uint256 public frozenStakingTime;

    uint256 public onStartBlock;
    uint256 public reduceBlocks;
    uint256 public initRewardPerSec;

    event StakeReward(address indexed _user, uint256 _time, uint256 _amount);
    event Withdrawn(address indexed _user, uint256 _amount);
    event GetReward(address indexed _user, uint256 _amount);

    function initialize() public initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
        initRewardPerSec = 317097919837645865;  //The Initial Reward Amount
        rewardPerSec = 317097919837645865;
        offBlockTs = 4070880000;    //2099
        
        frozenStakingTime = 5 * 60; //frozen time is 5 mins

        // reduceBlocks = 30 * 24 * 60 * 4; // 
        reduceBlocks = 240;  // ten blocks will reduce

        onStartBlock = block.number + 10;
    }

    modifier _onStart() {
        require(block.number >= onStartBlock && onStartBlock > 0, "DIS Pledge Not Started.");
        _;
    }

    function computeRewardPerSec() internal {
        require(reduceBlocks > 0, "Reduce Blocks not Setting.");
        if(block.number >= onStartBlock) {
            uint256 n = (block.number - onStartBlock) / (reduceBlocks);
            if(n > 0) {
                rewardPerSec = initRewardPerSec.mul(99 ** n).div(100 ** n);
            }
        }
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored.add(
            compareTsRewardable().sub(lastUpdateTime).mul(rewardPerSec).mul(1e18).div(totalSupply())
        );
    }

    modifier updateReward(address account) {
        computeRewardPerSec();
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = compareTsRewardable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function earned(address account) public view returns (uint256) {
        return balanceOf(account).mul(rewardPerToken().sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
    }

    function stakeAndReward(uint256 _amount) external updateReward(msg.sender) _onStart payable {
        require(_amount > 0 && msg.value == _amount, "invalid stake amount");

        deposits[msg.sender] = deposits[msg.sender].add(_amount);
        _totalSupply = _totalSupply.add(_amount);
        _balances[msg.sender] = _balances[msg.sender].add(_amount);
        lastStakeTime[msg.sender] = block.timestamp;

        emit StakeReward(msg.sender, block.timestamp, _amount);
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) _onStart {
        require(amount > 0, 'DIS Pledge: Cannot withdraw 0');
        require(block.timestamp >= unfrozenStakeTime(msg.sender), "DIS Pledge: Cannot withdrawal during freezing");  //是否要有针对某个地址的冻结时间

        deposits[msg.sender] = deposits[msg.sender].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        payable(msg.sender).transfer(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function withdrawAll() external {
        withdraw(balanceOf(msg.sender));
        // getReward(); //这里需要放开，暂时不允许给奖励
    }

    function getReward() public updateReward(msg.sender) _onStart {
        require(address(this).balance > totalSupply(), "forbid to ");
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            require(address(this).balance > reward, "please check the reward and balance");
            rewards[msg.sender] = 0;
            receiveReward[msg.sender] = receiveReward[msg.sender].add(reward);
            payable(msg.sender).transfer(reward);
            emit GetReward(msg.sender, reward);
        }
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function compareTsRewardable() public view returns (uint256) {
        return Math.min(block.timestamp, offBlockTs);
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function unfrozenStakeTime(address account) public view returns (uint256) {
        return lastStakeTime[account] + frozenStakingTime;
    }

    function _chainId() internal view returns (uint id) {
        assembly { id := chainid() }
    }

    function readChainId() view external returns(uint) {
        return _chainId();
    }

    function notifyRange(uint256 _end) external onlyOwner {
        require(_end > onBlockTs, "invalid end time");
        offBlockTs = _end;
    }

    function resetStartBlock(uint256 _start) external onlyOwner {
        onStartBlock = _start;
    }
}