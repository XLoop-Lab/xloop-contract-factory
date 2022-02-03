// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "./LIB/Ownable.sol";

contract XloopTokenTmp is ERC20, Ownable {
    constructor() ERC20("XloopTokenTmp", "XLOOPTMP")  {}
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}