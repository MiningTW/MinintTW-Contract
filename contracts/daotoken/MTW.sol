
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

//0x169C06b4cfB09bFD73A81e6f2Bb1eB514D75bB19   LeetSwapV2Factory on Base Chain
//0xfCD3842f85ed87ba2889b4D35893403796e67FF1   LeetSwapV2Router  on Base Chain

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./ILeetSwap.sol";

contract MTW  is ERC20{
    uint256 public constant FIXED_TRADE_FEE = 1;

    using SafeMath for uint256;

    uint256 private _totalSupply;
    ISwapRouter private uniswapV2Router;
    address public uniswapV2Pair;
    address public daoFund;

    event PairCreated(address pairAddr);

    constructor(string memory _name, string memory _symbol, 
        address _admin, address _fund,
        address _swapRouter, address _targetToken) ERC20(_name, _symbol) {
        _totalSupply = 10_000_000 * 10**decimals();
        daoFund = _fund;
        initPair(_swapRouter, _targetToken);
        super._mint(_admin, _totalSupply / 100 * 50);
        super._mint(_fund, _totalSupply / 100 * 50);
    }

    function decimals() public view virtual override returns (uint8) {
        return 8;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(amount > 0, "amount must gt 0");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if(from != uniswapV2Pair && to != uniswapV2Pair) {
            super._transfer(from, to, amount);
            return;
        }

        // if(from == uniswapV2Pair) {
        //     // buy MTW
        //     require(startTradeBlock>0, "not open");
        //     super._transfer(from, address(this), amount.mul(1).div(100));
        //     fundCount+=amount.mul(1).div(100);
        //     super._transfer(from, to, amount.mul(99).div(100));
        //     return;
        // }
        if(to == uniswapV2Pair) {
            // sell MTW
            super._transfer(from, to, amount.mul(100 - FIXED_TRADE_FEE).div(100));
            super._transfer(from, address(daoFund), amount.mul(FIXED_TRADE_FEE).div(100));
            return;
        }
    }

    function initPair(address _swap, address _targetToken) private {
        uniswapV2Router = ISwapRouter(_swap);
        uniswapV2Pair = ISwapFactory(uniswapV2Router.factory()).createPair(address(this), _targetToken);
        ERC20(_targetToken).approve(address(uniswapV2Router), type(uint256).max);
        _approve(address(this), address(uniswapV2Router),type(uint256).max);

        _approve(address(this), address(this),type(uint256).max);
        emit PairCreated(uniswapV2Pair);
    }

}