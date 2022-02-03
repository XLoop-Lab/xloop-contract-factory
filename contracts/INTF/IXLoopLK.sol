// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import './IXLT_IERC20.sol';

interface IXLoopLK is IXLT_IERC20 {
    function initialize(address p_pair, string memory p_name, string memory p_symbol, uint8 p_decimal, bool p_is_reward) external;
    function mint(address user, uint256 value) external returns (bool);
    function burn(address user, uint256 value) external  returns (bool);
    function balanceOf(address owner) external view returns (uint256);
    function totalSupply() external view returns (uint256);
}
