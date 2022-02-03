// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IXLoopPair {
    function initialize(address P_TOKEN_A, address P_TOKEN_A_ROOT, address P_LK_TOKEN, uint256 P_LK_DIFFDEC, address P_PROVIDER, bool P_IS_REWARD) external;
    function closeProject() external;
    function transferProvider(address P_NEW_PROVIDER) external;
}
