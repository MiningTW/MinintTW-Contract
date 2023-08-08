// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DaoFancy is Initializable, OwnableUpgradeable {

    uint256 public constant FIXED_INIT_RATIO = 50;

    IERC20 public daoToken;
    address[] public members;

    function initialize() public initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function setToken(address _tokenAddr) external onlyOwner {
        daoToken = IERC20(_tokenAddr);
        daoToken.approve(address(this), ~uint256(0));
    }
    
    function addMembers(address[] calldata _wallets) external onlyOwner {
        require(_wallets.length > 0 && _wallets.length <=10, "length invalid");
        for(uint256 i=0; i<_wallets.length; i++) {
            members.push(_wallets[i]);
        }
    }

    function delMember(address _wallet) external onlyOwner {
        int256 index = -1;
        for(uint256 i=0; i<members.length; i++) {
            if(members[i] == _wallet) {
                index = int256(i);
                break;
            }
        }
        if(index > 0) {
            if(uint256(index)==members.length - 1) {
                members.pop();
            } else {
                members[uint256(index)] = members[members.length - 1];
                members.pop();
            }
        }
    }
}