// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./INTF/IXLT_IERC20.sol";
import "./INTF/IXLoopPair.sol";
import "./INTF/IXLoopLK.sol";

import "./LIB/SafeMath.sol";
import "./LIB/SafeERC20.sol";
import "./LIB/XLTContext.sol";

contract XloopPair is IXLoopPair, XLTContext {
    using SafeMath for uint256;
    using SafeERC20 for IXLT_IERC20;

    address private immutable FACTORY;
    bool private PAIR_INITIALIZED = false;

    address public LK_TOKEN;
    uint256 public LK_DIFFDEC;
    address public TOKEN_A;
    address public TOKEN_A_ROOT;
    uint256 public XLT_TOKEN_A;
    uint256 public XLT_TOKEN_B;

    uint256 public XLT_AB_PRICE;
    uint256 public XLT_MAX_AB_PRICE;
    uint256 public XLT_PERSHARE;
    
    uint256 public PRATE;
    address public PROVIDER;
    address public NEW_PROVIDER;
    uint256 public PTOTAL_FUND;
    uint256 public PTOTAL_FUND_LIMIT;
    uint256 public PTOTAL_FUND_MINI;
    uint256 public PTOTAL_FUND_WITHDRAW;
    
    bool public IS_REWARD;
    bool public IS_ON_OPEN;
    bool public IS_P_CLOSED;
    bool public IS_P_MINTED;

    uint112 public GRANT_ID;

    constructor() {
        require(_msgSender() != address(0), "ADDR_ZERO");
        FACTORY = _msgSender();
        PAIR_INITIALIZED = false; IS_P_MINTED = false;
    }

    function factory() public view virtual returns (address) { return FACTORY; }
    function initialized() public view virtual returns (bool) { return PAIR_INITIALIZED; }

    bool private _ENTERED_;
    modifier lock() {
        require(!_ENTERED_, "REENTRANT");
        _ENTERED_ = true;
        _;
        _ENTERED_ = false;
    }
    
    modifier minted() {
        require(IS_P_MINTED == true, "NOT_MINTED");
        _;
    }

    event Deposite(address indexed user, uint256 value, uint256 value_ab);
    event Withdraw(address indexed user, uint256 value, uint256 value_ab);
    event ProviderWithdraw(address indexed user, uint256 value, uint256 value_ab);
    event ReturnA(address indexed user, uint256 value);
    event ReturnB(address indexed user, uint256 value);

    event AB(uint256 a , uint256 b);
    event Init(address indexed contracts);
    event InitMinted(address indexed user, address indexed contracts);
    event CloseProject(address indexed user, address indexed contracts, uint256 value);
    event SetPFund(address indexed user, uint256 rate , uint256 limit_fund, uint256 max_ab_price);
    event ProviderTransferPrepared(address indexed previousOwner, address indexed newOwner);
    event ProviderTransferred(address indexed previousOwner, address indexed newOwner);

    function transferProvider(address P_NEW_PROVIDER) external {
        require(_msgSender() == PROVIDER || _msgSender() == FACTORY, "FORBIDDEN");
        require(P_NEW_PROVIDER != address(0), "INVALID_OWNER");
        NEW_PROVIDER = P_NEW_PROVIDER;
        emit ProviderTransferPrepared(PROVIDER, P_NEW_PROVIDER);
    }

    function claimProvider() external {
        require(_msgSender() == NEW_PROVIDER && _msgSender() != address(0), "INVALID_CLAIM");
        PROVIDER = NEW_PROVIDER;
        NEW_PROVIDER = address(0);
        emit ProviderTransferred(PROVIDER, NEW_PROVIDER);
    }

    function closeProject() external minted lock {
        require(IS_P_CLOSED == false, "IS_P_CLOSED");
        require(_msgSender() == PROVIDER || _msgSender() == FACTORY, "FORBIDDEN");
        /** balance */
        uint256 return_amount = 0; 
        if(PTOTAL_FUND > 0){
            return_amount = (PTOTAL_FUND.sub(PTOTAL_FUND_WITHDRAW));
            if(return_amount > 0){ 
                XLT_TOKEN_A = XLT_TOKEN_A.add(return_amount); 
                PTOTAL_FUND = PTOTAL_FUND_WITHDRAW;
            }
        }
        // set state
        IS_P_CLOSED = true;
        emit CloseProject(_msgSender(), address(this), return_amount);
    }

    function setPFund(uint256 pershare, uint256 rate_fund, uint256 limit_fund, uint256 max_ab_price) external minted lock {
        require(IS_P_CLOSED == false, "IS_P_CLOSED");
        require(_msgSender() == PROVIDER, "FORBIDDEN");
        require((pershare > 0 && pershare < 1001) &&(PTOTAL_FUND <= limit_fund) && (limit_fund >= PTOTAL_FUND_MINI) && (rate_fund < 1001) && (max_ab_price > 0), "PARAM_FAILED");
        require((max_ab_price >= XLT_AB_PRICE), "PARAM_FAILED");
        XLT_PERSHARE = pershare; // Max : (1000/1000)
        PRATE = rate_fund; // Max : (1000/1000)
        PTOTAL_FUND_LIMIT = limit_fund;
        XLT_MAX_AB_PRICE = max_ab_price;
        emit SetPFund(_msgSender(), rate_fund, limit_fund, max_ab_price);
    }

    function setIsOnProviderOpen(bool _IS_ON) external minted lock {
        require(IS_P_CLOSED == false, "IS_P_CLOSED");
        require(_msgSender() == PROVIDER, "FORBIDDEN"); 
        IS_ON_OPEN = _IS_ON;
    }

    function setGrant(uint112 p_grant_id) external minted lock {
        require(_msgSender() == PROVIDER, "FORBIDDEN");
        GRANT_ID = p_grant_id;
    }

    // called once by the factory at time of deployment
    function initialize(address P_TOKEN_A, address P_TOKEN_A_ROOT, address P_LK_TOKEN, uint256 P_LK_DIFFDEC, address P_PROVIDER, bool P_IS_REWARD) external lock {
        // sufficient check
        require((_msgSender() == FACTORY) && (PAIR_INITIALIZED == false), "FORBIDDEN");
        require((P_TOKEN_A != address(0)) && (P_LK_TOKEN != address(0)) && (P_PROVIDER != address(0)), "ADDR_ZERO");
        // set state
        TOKEN_A = P_TOKEN_A;
        TOKEN_A_ROOT = P_TOKEN_A_ROOT;
        LK_TOKEN = P_LK_TOKEN;
        PROVIDER = P_PROVIDER;
        IS_REWARD = P_IS_REWARD;
        if(P_LK_DIFFDEC > 1){LK_DIFFDEC = (10**P_LK_DIFFDEC);}else{LK_DIFFDEC = 1;}
        /** set init */
        PAIR_INITIALIZED = true;
        emit Init(address(this));
        emit ProviderTransferred(address(0), PROVIDER);
    }

    function initialize_mint_token(uint256 max_ab_price, uint256 pershare, uint256 rate_fund, uint256 limit_fund, uint256 mini_fund, bool p_is_on_open, uint112 p_grant_id) external lock {
        // sufficient check
        require(_msgSender() == PROVIDER, "FORBIDDEN");
        require((IS_P_CLOSED == false) && (IS_P_MINTED == false) && (PAIR_INITIALIZED == true), "IS_P_CLOSED_MINTED_FAILED");
        require((pershare > 0 && pershare < 1001) && (rate_fund < 1001) && (limit_fund >= mini_fund) && (max_ab_price > 0), "PARAM_FAILED");
        // set info
        XLT_PERSHARE = pershare; // Max : (1000/1000)
        PRATE = rate_fund; // Max : (1000/1000)
        PTOTAL_FUND_LIMIT = limit_fund; // limit_fund.mul(LK_DIFFDEC);
        PTOTAL_FUND_MINI = mini_fund; // mini_fund.mul(LK_DIFFDEC);
        XLT_MAX_AB_PRICE = max_ab_price; // max_ab_price.mul(LK_DIFFDEC);
        // set state
        IS_ON_OPEN = p_is_on_open;
        GRANT_ID = p_grant_id;
        IS_P_MINTED = true;
        emit InitMinted(_msgSender(), address(this));
    }

    function providerTransferOut(uint256 amount) external minted lock {
        require(IS_P_CLOSED == false, "IS_P_CLOSED");
        require(_msgSender() == PROVIDER, "FORBIDDEN");
        require((amount > 0) && ((PTOTAL_FUND.sub(PTOTAL_FUND_WITHDRAW)) > 0) && (PTOTAL_FUND > PTOTAL_FUND_MINI), "AMOUNT_EXCEEDED");
        uint256 amount_token_a = amount.mul(LK_DIFFDEC);
        require((amount_token_a > 0) && ((PTOTAL_FUND.sub(PTOTAL_FUND_WITHDRAW)) >= amount_token_a), "AMOUNT_EXCEEDED");
        uint256 amount_token_a_trans = amount_token_a.div(LK_DIFFDEC);
        require((amount_token_a_trans > 0), "AMOUNT_A_EXCEEDED");
        /** balance */
        IXLT_IERC20(TOKEN_A).safeTransfer(_msgSender(), amount_token_a_trans);
        PTOTAL_FUND_WITHDRAW = PTOTAL_FUND_WITHDRAW.add(amount_token_a);
        emit ProviderWithdraw(_msgSender(), amount, amount_token_a);
    }

    function deposit(uint256 amount) external payable minted lock {
        require((IS_P_CLOSED == false) && (IS_ON_OPEN), "IS_P_CLOSED_OFF");
        uint256 balance1 = IXLT_IERC20(TOKEN_A).balanceOf(_msgSender());
        require((amount > 0) && (balance1 >= amount), "AMOUNT_EXCEEDED");
        /** calculator token */
        uint256 amount_fund = 0; uint256 amount_token_a = amount.mul(LK_DIFFDEC); uint256 amount_token_b = amount_token_a;
        if(XLT_AB_PRICE < XLT_MAX_AB_PRICE){
            if(PTOTAL_FUND < PTOTAL_FUND_LIMIT){ amount_fund = (amount_token_a.mul(PRATE)).div(1000); }
            amount_token_a = (amount_token_a).sub(amount_fund);
            amount_token_b = ((amount_token_a.mul(XLT_PERSHARE)).div(1000));
        }
        if(XLT_TOKEN_A > 0 && XLT_TOKEN_B > 0){ amount_token_b = (amount_token_b.mul(XLT_TOKEN_B)).div(XLT_TOKEN_A); }
        /** balance */
        require((amount_token_a > 0) && (amount_token_b > 0), "AMOUNT_AB_ZERO_FAILED");
        IXLT_IERC20(TOKEN_A).safeTransferFrom(_msgSender(), address(this), amount);
        XLT_TOKEN_A = XLT_TOKEN_A.add(amount_token_a);
        XLT_TOKEN_B = XLT_TOKEN_B.add(amount_token_b);
        _updatePriceAB();
        /** fund */
        if(amount_fund > 0){ PTOTAL_FUND = PTOTAL_FUND.add(amount_fund); }
        /** lk */
        (bool success) = IXLoopLK(LK_TOKEN).mint(_msgSender(), amount_token_b);
        require(success, "LK_NOT_SUCCESS");
        emit Deposite(_msgSender(), amount, amount_token_b);
        emit AB(XLT_TOKEN_A, XLT_TOKEN_B);
    }

    function getBalanceA() external view returns (uint256) { return IXLT_IERC20(TOKEN_A).balanceOf(address(this)); }
    
    function getInfo() external view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, bool, bool) {
        return (XLT_MAX_AB_PRICE, XLT_TOKEN_A, XLT_TOKEN_B, XLT_PERSHARE, PRATE, PTOTAL_FUND, PTOTAL_FUND_WITHDRAW, PTOTAL_FUND_LIMIT, PTOTAL_FUND_MINI, IS_ON_OPEN, IS_P_CLOSED);
    }

    function withdraw(uint256 amount) external payable minted lock {
        require((XLT_TOKEN_A > 0) && (XLT_TOKEN_B > 0), "AMOUNT_AB_ZERO_FAILED");
        uint256 balance1 = IXLT_IERC20(LK_TOKEN).balanceOf(_msgSender());
        require((amount > 0) && (balance1 >= amount), "AMOUNT_EXCEEDED");
        /** calculator */
        uint256 amount_token_a = (amount.mul(XLT_TOKEN_A)).div(XLT_TOKEN_B);
        require((amount_token_a > 0) && (amount_token_a <= XLT_TOKEN_A), "AMOUNT_A_EXCEEDED");
        uint256 amount_token_a_trans = amount_token_a.div(LK_DIFFDEC);
        require((amount_token_a_trans > 0), "AMOUNT_A_EXCEEDED");
        /** lk */
        (bool success) = IXLoopLK(LK_TOKEN).burn(_msgSender(), amount);
        require(success, "LK_NOT_SUCCESS");
        /** balance */
        IXLT_IERC20(TOKEN_A).safeTransfer(_msgSender(), amount_token_a_trans);
        XLT_TOKEN_A = XLT_TOKEN_A.sub(amount_token_a);
        XLT_TOKEN_B = XLT_TOKEN_B.sub(amount);
        _updatePriceAB();
        emit Withdraw(_msgSender(), amount, amount_token_a_trans);
        emit AB(XLT_TOKEN_A, XLT_TOKEN_B);
    }

    function _updatePriceAB() private {
        if(XLT_TOKEN_A > 0 && XLT_TOKEN_B > 0){ XLT_AB_PRICE = XLT_TOKEN_A.div(XLT_TOKEN_B); }else{  XLT_AB_PRICE = 0; }
    }

    function returnA(uint256 amount) external payable minted lock {
        _return_a(_msgSender() , amount);
    }

    function _return_a(address usr, uint256 amount) private {
        uint256 balance1 = IXLT_IERC20(TOKEN_A).balanceOf(usr);
        require((amount > 0) && (balance1 >= amount), "AMOUNT_EXCEEDED");
        /** calculator */
        IXLT_IERC20(TOKEN_A).safeTransferFrom(usr, address(this), amount);
        uint256 amount_token_a = amount.mul(LK_DIFFDEC);
        /** balance */
        XLT_TOKEN_A = XLT_TOKEN_A.add(amount_token_a);
        _updatePriceAB();
        emit AB(XLT_TOKEN_A, XLT_TOKEN_B);
        emit ReturnA(usr, amount);
    }

    function returnB(uint256 amount) external payable minted lock {
        _return_b(_msgSender() , amount);
    }

    function _return_b(address usr, uint256 amount) private {
        uint256 balance1 = IXLT_IERC20(LK_TOKEN).balanceOf(usr);
        require((amount > 0) && (balance1 >= amount), "AMOUNT_EXCEEDED");
        /** lk */
        (bool success) = IXLoopLK(LK_TOKEN).burn(usr, amount);
        require(success, "LK_NOT_SUCCESS");
        /** balance */
        XLT_TOKEN_B = XLT_TOKEN_B.sub(amount);
        _updatePriceAB();
        emit AB(XLT_TOKEN_A, XLT_TOKEN_B);
        emit ReturnB(usr, amount);
    }
}
