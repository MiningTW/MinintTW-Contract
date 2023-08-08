
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

//0x169C06b4cfB09bFD73A81e6f2Bb1eB514D75bB19   LeetSwapV2Factory on Base Chain
//0xfCD3842f85ed87ba2889b4D35893403796e67FF1   LeetSwapV2Router  on Base Chain

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Base  is ERC20{

    constructor() ERC20("Base", "Base") {
        _mint(0xe38533e11B680eAf4C9519Ea99B633BD3ef5c2F8, 10000000 ether);
    }

    

}