// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "./XloopPair.sol";
import "./XloopLK.sol";

import "./INTF/IXLoopToken.sol";
import "./INTF/IXLoopLK.sol";
import "./INTF/IXLoopPair.sol";

import "./LIB/Ownable.sol";
import "./LIB/CloneFactory.sol";
import "./LIB/XLTContext.sol";

contract XloopFactory is CloneFactory, XLTContext, Ownable {

    address private immutable XloopPairTemp;
    address private immutable XloopLKTemp;
    address private Xloop;

    uint256 private RewardRate;
    uint112 private AllPairsCounter;
    mapping(address => address) private AllPairs;
    mapping(address => address) private AllLK;

    bool private CheckWhiteList;
    mapping(address => bool) private WhiteList;
    mapping(address => bool) private XloopGATEList;
    mapping(address => bool) private XloopMINTERList;

    event EventPairCreated(address indexed P_TOKEN_A, address indexed pair, address indexed lk, address provider, uint112 counter);
    event EventHardPairLKCreated(address indexed P_TOKEN_A, address indexed pair, address indexed lk, address provider, uint112 counter);
    event EventWhiteList(address indexed P_TOKEN_A, bool IS_ON);
    event EventXloopGATEList(address indexed P_TOKEN_A, bool IS_ON);
    event EventXloopMINTERList(address indexed pair, bool IS_ON);
    event EventCheckWhiteList(bool IS_ON);
    event EventSetRewardRate(uint256 rate);

    constructor() {
        require(_msgSender() != address(0), "ADDR_ZERO");
        RewardRate = 250; CheckWhiteList = true;
        /* Xloop = address(new XloopToken(_msgSender())); */
        XloopPairTemp = address(new XloopPair());
        XloopLKTemp = address(new XloopLK());
    }

    function xloopPairTemp() external view returns (address) { return XloopPairTemp; }
    function xloopLKTemp() external view returns (address) { return XloopLKTemp; }
    function xloop() external view returns (address) { return Xloop; }
    function pairsCounter() external view returns (uint112) { return AllPairsCounter; }
    function rewardRate() external view returns (uint256) { return RewardRate; }

    bool private _ENTERED_;
    modifier lock() {
        require(!_ENTERED_, "REENTRANT");
        _ENTERED_ = true;
        _;
        _ENTERED_ = false;
    }
    
    /* onlyOwner */
    function setFactory(address P_XloopToken) external onlyOwner lock {
        require(P_XloopToken != address(0), "ADDR_ZERO");
        Xloop = P_XloopToken;
    }

    function _createPair() private returns (address, address) {
        /** create pair */
        address pair = this.clone(XloopPairTemp);
        address lk = this.clone(XloopLKTemp);
        return (pair, lk);
    }

    function createPair(address P_TOKEN_A, string memory _name, string memory _symbol, uint8 _decimal, uint8 _diffdec) external lock returns (address, address) {
        require(((_msgSender() != address(0)) && (P_TOKEN_A != address(0)) && (P_TOKEN_A != XloopPairTemp) && (P_TOKEN_A != XloopLKTemp)), "IDENTICAL_ADDRESSES");
        address P_TOKEN_A_ROOT = P_TOKEN_A;
        if(AllLK[P_TOKEN_A] != address(0)){ 
            P_TOKEN_A_ROOT = AllLK[P_TOKEN_A]; 
        } else { 
            if(CheckWhiteList == true && _msgSender() != owner()){ require(WhiteList[P_TOKEN_A_ROOT] == true, "TOKEN_INVALID"); } 
        }
        require(_diffdec > 0 && _diffdec <= 36 && _decimal <= 36, "DECIMAL_ERROR");
        /** create pair */
        (address _PAIR, address _LK) = _createPair();
        require((_PAIR != address(0)) && (_LK != address(0)) && (_PAIR != XloopPairTemp) && (_LK != XloopLKTemp), "PAIR_ERROR");
        bool _is_reward = false; if(P_TOKEN_A_ROOT == Xloop || XloopGATEList[P_TOKEN_A_ROOT] == true){ _is_reward = true; }
        IXLoopLK(_LK).initialize(_PAIR, _name, _symbol, _decimal, _is_reward);
        IXLoopPair(_PAIR).initialize(P_TOKEN_A, P_TOKEN_A_ROOT, _LK, _diffdec, _msgSender(), _is_reward);
        /** set state */
        AllLK[_LK] = P_TOKEN_A_ROOT; 
        AllPairs[_PAIR] = _msgSender();
        AllPairsCounter = AllPairsCounter + 1;
        emit EventPairCreated(P_TOKEN_A, _PAIR, _LK, _msgSender(), AllPairsCounter);
        return (_PAIR, _LK);
    }

    function reward(address usr) external {
        require(_msgSender() != address(0), "ADDR_ZERO");
        if(AllLK[_msgSender()] != address(0) && (RewardRate > 0)){
            IXLoopToken(Xloop).mint(usr, RewardRate);
        }
    }

    function minter(address usr, uint256 rate) external {
        require(_msgSender() != address(0), "ADDR_ZERO");
        if( XloopMINTERList[_msgSender()] == true && (rate > 0)){
            IXLoopToken(Xloop).mint(usr, rate);
        }
    }

    function verifyProvider(address pair) external view returns (address) { 
        return AllPairs[pair];
    }

    function verifyPair(address pair) external view returns (address) {
        return AllPairs[pair];
    }

    function verifyWhiteList(address pair) external view returns (bool) { 
        return WhiteList[pair];
    }

    function verifyXloopGATE(address pair) external view returns (bool) { 
        return XloopGATEList[pair];
    }

    function verifyXloopMINTER(address pair) external view returns (bool) { 
        return XloopMINTERList[pair];
    }

    /* onlyOwner */
    function hardPair(address P_TOKEN_A, address P_TOKEN_A_ROOT, address _PAIR, address P_PROVIDER, address _LK) external onlyOwner lock {
        require(P_TOKEN_A != address(0) && P_TOKEN_A_ROOT != address(0) && (P_PROVIDER != address(0)) && _LK != address(0), "PAIR_ERROR");
        AllLK[_LK] = P_TOKEN_A_ROOT; 
        AllPairs[_PAIR] = P_PROVIDER;
        AllPairsCounter = AllPairsCounter + 1;
        emit EventHardPairLKCreated(P_TOKEN_A, _PAIR, _LK, P_PROVIDER, AllPairsCounter);
    }
    /* onlyOwner */
    function setWhiteList(address P_TOKEN_A, bool P_IS_ON) external onlyOwner lock {
        require(P_TOKEN_A != address(0), "ADDR_ZERO");
        WhiteList[P_TOKEN_A] = P_IS_ON; 
        emit EventWhiteList(P_TOKEN_A, P_IS_ON);
    }
    /* onlyOwner */
    function setCheckWhiteList(bool P_IS_ON) external onlyOwner lock {
        CheckWhiteList = P_IS_ON; 
        emit EventCheckWhiteList(P_IS_ON);
    }
    /* onlyOwner */
    function setRewardRate(uint256 rate) external onlyOwner lock {
        RewardRate = rate; 
        emit EventSetRewardRate(rate);
    }
    /* onlyOwner */
    function setXloopGATE(address P_TOKEN_A, bool P_IS_ON) external onlyOwner lock {
        require(P_TOKEN_A != address(0), "ADDR_ZERO");
        XloopGATEList[P_TOKEN_A] = P_IS_ON; 
        emit EventXloopGATEList(P_TOKEN_A, P_IS_ON);
    }
    /* onlyOwner */
    function setXloopMINTER(address pair, bool IS_ON) external onlyOwner lock {
        require(pair != address(0), "ADDR_ZERO");
        XloopMINTERList[pair] = IS_ON; 
        emit EventXloopMINTERList(pair, IS_ON);
    }

    /* Project Management onlyOwner */
    function closeProject(address _PAIR) external onlyOwner {
        IXLoopPair(_PAIR).closeProject();
    }
    /* Project Management onlyOwner */
    function transferProvider(address _PAIR, address newOwner) external onlyOwner {
        require(newOwner != address(0), "INVALID_OWNER");
        IXLoopPair(_PAIR).transferProvider(newOwner);
    }
}
