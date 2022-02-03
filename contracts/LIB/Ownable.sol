// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

contract Ownable {
    address private _OWNER_;
    address private _NEW_OWNER_;

    event OwnershipTransferPrepared(
        address indexed previousOwner,
        address indexed newOwner
    );

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function _omsgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function owner() public view virtual returns (address) {
        return _OWNER_;
    }

    function newOwner() public view virtual returns (address) {
        return _NEW_OWNER_;
    }

    modifier onlyOwner() {
        require(_omsgSender() == _OWNER_, "NOT_OWNER");
        _;
    }

    constructor() {
        _OWNER_ = _omsgSender();
        emit OwnershipTransferred(address(0), _OWNER_);
    }

    function transferOwnership(address user) external onlyOwner {
        require(user != address(0), "INVALID_OWNER");
        emit OwnershipTransferPrepared(_OWNER_, user);
        _NEW_OWNER_ = user;
    }

    function claimOwnership() external {
        require(
            _omsgSender() == _NEW_OWNER_ && _omsgSender() != address(0),
            "INVALID_CLAIM"
        );
        emit OwnershipTransferred(_OWNER_, _NEW_OWNER_);
        _OWNER_ = _NEW_OWNER_;
        _NEW_OWNER_ = address(0);
    }
}
