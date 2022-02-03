// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import './IXLT_IERC20.sol';

interface IXLoopToken is IXLT_IERC20 {
    function mint(address user, uint256 value) external;
    function burn(uint256 amount) external;
}
