// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AnyLpLock {
    struct LockInfo {
        uint256 startTs;
        uint256 periodTs;
        uint256 amount;
    }
    uint256 public constant MAX_LOCK_COUNT_PER_WALLET = 10;

    mapping(address => mapping(address => LockInfo)) public lockPairs;
    mapping(address => address[]) public userLockings;

    event LockLP(address indexed user, address indexed lp, uint256 period, uint256 amount);
    event AddLockAmount(address indexed user, address indexed lp, uint256 amount);
    event UnlockLp(address indexed user, address indexed lp, uint256 amount);

    modifier checkLockLen(address user) {
        require(userLockings[_msgSender()].length < MAX_LOCK_COUNT_PER_WALLET, "exceed max lp lock count");
        _;
    }

    function lock(address _lp, uint256 _periodTs, uint256 _lockAmount) checkLockLen(_msgSender()) external {
        require(_lp != address(0) && _periodTs > 0 && _lockAmount > 0, "params error");
        require(lockPairs[_msgSender()][_lp].startTs == 0, "already locking");

        IERC20 lpToken = IERC20(_lp);
        require(lpToken.balanceOf(_msgSender()) > _lockAmount, "not enough balance");

        require(lpToken.transferFrom(_msgSender(), address(this), _lockAmount), "Transfer LP Failed");

        // lpToken.approve(address(this), _lockAmount);

        lockPairs[_msgSender()][_lp] = LockInfo({
            startTs: block.timestamp,
            periodTs: _periodTs,
            amount: _lockAmount
        });
        userLockings[_msgSender()].push(_lp);

        emit LockLP(_msgSender(), _lp, _periodTs, _lockAmount);
    }

    function addLock(address _lp, uint256 _lockAmount) external {
        require(_lp != address(0) && _lockAmount > 0, "params error");
        require(lockPairs[_msgSender()][_lp].startTs + lockPairs[_msgSender()][_lp].periodTs > block.timestamp, 
            "AddLock Failed: already expired");
        
        IERC20 lpToken = IERC20(_lp);
        require(lpToken.balanceOf(_msgSender()) > _lockAmount, "not enough balance");

        require(lpToken.transferFrom(_msgSender(), address(this), _lockAmount), "Transfer LP Failed");
        lockPairs[_msgSender()][_lp].amount += _lockAmount;

        emit AddLockAmount(_msgSender(), _lp, _lockAmount);
    }

    function unlock(address _lp) external {
        require(_lp != address(0), "params error");
        require(lockPairs[_msgSender()][_lp].startTs > 0, "unable to find locking info");
        require(lockPairs[_msgSender()][_lp].startTs + lockPairs[_msgSender()][_lp].periodTs < block.timestamp, 
            "Unlock Failed: still in locking period");
        
        IERC20 lpToken = IERC20(_lp);

        LockInfo memory lockInfo = lockPairs[_msgSender()][_lp];
        delete lockPairs[_msgSender()][_lp];

        uint256 _len = userLockings[_msgSender()].length;

        if(_len == 1) {
            delete userLockings[_msgSender()];
        } else {
            for(uint i=0; i<_len; i++) {
                if(userLockings[_msgSender()][i] == _lp) {
                    userLockings[_msgSender()][i] = userLockings[_msgSender()][_len - 1];
                    userLockings[_msgSender()].pop();
                    break;
                }
            }
        }

        require(lpToken.transfer(_msgSender(), lockInfo.amount), "Retrive LP Failed");

        emit UnlockLp(_msgSender(), _lp, lockInfo.amount);
    }

    function balanceOf(address _lp) external view returns(uint256) {
        return IERC20(_lp).balanceOf(address(this));
    }

    function getUserLockingLength(address _user) external view returns(uint256) {
        return userLockings[_user].length;
    }

    function getUserLockings(address _user) external view returns(address[] memory) {
        return userLockings[_user];
    }

    function _msgSender() internal view returns(address) {
        return msg.sender;
    }
}