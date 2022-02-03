// SPDX-License-Identifier: MIT
// FOR EDUCATIONAL AND INSPIRATIONAL PURPOSES ONLY.
// POWERED BY WWW.XLOOP.LINK

// File: contracts/LIB/XLTContext.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity 0.8.11;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract XLTContext {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// File: contracts/LIB/Address.sol

// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
// File: contracts/LIB/SafeMath.sol

pragma solidity 0.8.11;

/**
 *
 * @notice Math operations with safety checks that revert on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "MUL_ERROR");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "DIVIDING_ERROR");
        return a / b;
    }

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SUB_ERROR");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "ADD_ERROR");
        return c;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = x / 2 + 1;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}
// File: contracts/INTF/IXLoopPair.sol

pragma solidity 0.8.11;

interface IXLoopPair {
    function initialize(
        address P_TOKEN_A,
        address P_TOKEN_A_ROOT,
        address P_LK_TOKEN,
        uint256 P_LK_DIFFDEC,
        address P_PROVIDER,
        bool P_IS_REWARD
    ) external;

    function closeProject() external;

    function transferProvider(address P_NEW_PROVIDER) external;
}

// File: contracts/INTF/IXLT_IERC20.sol

// This is a file copied from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol

pragma solidity 0.8.11;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IXLT_IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function name() external view returns (string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

// File: contracts/LIB/SafeERC20.sol

pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IXLT_IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IXLT_IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IXLT_IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IXLT_IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IXLT_IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}
// File: contracts/INTF/IXLoopLK.sol

pragma solidity 0.8.11;

interface IXLoopLK is IXLT_IERC20 {
    function initialize(
        address p_pair,
        string memory p_name,
        string memory p_symbol,
        uint8 p_decimal,
        bool p_is_reward
    ) external;

    function mint(address user, uint256 value) external returns (bool);

    function burn(address user, uint256 value) external returns (bool);

    function balanceOf(address owner) external view returns (uint256);

    function totalSupply() external view returns (uint256);
}

// File: contracts/XloopPair.sol

pragma solidity 0.8.11;

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
        PAIR_INITIALIZED = false;
        IS_P_MINTED = false;
    }

    function factory() public view virtual returns (address) {
        return FACTORY;
    }

    function initialized() public view virtual returns (bool) {
        return PAIR_INITIALIZED;
    }

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
    event ProviderWithdraw(
        address indexed user,
        uint256 value,
        uint256 value_ab
    );
    event ReturnA(address indexed user, uint256 value);
    event ReturnB(address indexed user, uint256 value);

    event AB(uint256 a, uint256 b);
    event Init(address indexed contracts);
    event InitMinted(address indexed user, address indexed contracts);
    event CloseProject(
        address indexed user,
        address indexed contracts,
        uint256 value
    );
    event SetPFund(
        address indexed user,
        uint256 rate,
        uint256 limit_fund,
        uint256 max_ab_price
    );
    event ProviderTransferPrepared(
        address indexed previousOwner,
        address indexed newOwner
    );
    event ProviderTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function transferProvider(address P_NEW_PROVIDER) external {
        require(
            _msgSender() == PROVIDER || _msgSender() == FACTORY,
            "FORBIDDEN"
        );
        require(P_NEW_PROVIDER != address(0), "INVALID_OWNER");
        NEW_PROVIDER = P_NEW_PROVIDER;
        emit ProviderTransferPrepared(PROVIDER, P_NEW_PROVIDER);
    }

    function claimProvider() external {
        require(
            _msgSender() == NEW_PROVIDER && _msgSender() != address(0),
            "INVALID_CLAIM"
        );
        PROVIDER = NEW_PROVIDER;
        NEW_PROVIDER = address(0);
        emit ProviderTransferred(PROVIDER, NEW_PROVIDER);
    }

    function closeProject() external minted lock {
        require(IS_P_CLOSED == false, "IS_P_CLOSED");
        require(
            _msgSender() == PROVIDER || _msgSender() == FACTORY,
            "FORBIDDEN"
        );
        /** balance */
        uint256 return_amount = 0;
        if (PTOTAL_FUND > 0) {
            return_amount = (PTOTAL_FUND.sub(PTOTAL_FUND_WITHDRAW));
            if (return_amount > 0) {
                XLT_TOKEN_A = XLT_TOKEN_A.add(return_amount);
                PTOTAL_FUND = PTOTAL_FUND_WITHDRAW;
            }
        }
        // set state
        IS_P_CLOSED = true;
        emit CloseProject(_msgSender(), address(this), return_amount);
    }

    function setPFund(
        uint256 pershare,
        uint256 rate_fund,
        uint256 limit_fund,
        uint256 max_ab_price
    ) external minted lock {
        require(IS_P_CLOSED == false, "IS_P_CLOSED");
        require(_msgSender() == PROVIDER, "FORBIDDEN");
        require(
            (pershare > 0 && pershare < 1001) &&
                (PTOTAL_FUND <= limit_fund) &&
                (limit_fund >= PTOTAL_FUND_MINI) &&
                (rate_fund < 1001) &&
                (max_ab_price > 0),
            "PARAM_FAILED"
        );
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
    function initialize(
        address P_TOKEN_A,
        address P_TOKEN_A_ROOT,
        address P_LK_TOKEN,
        uint256 P_LK_DIFFDEC,
        address P_PROVIDER,
        bool P_IS_REWARD
    ) external lock {
        // sufficient check
        require(
            (_msgSender() == FACTORY) && (PAIR_INITIALIZED == false),
            "FORBIDDEN"
        );
        require(
            (P_TOKEN_A != address(0)) &&
                (P_LK_TOKEN != address(0)) &&
                (P_PROVIDER != address(0)),
            "ADDR_ZERO"
        );
        // set state
        TOKEN_A = P_TOKEN_A;
        TOKEN_A_ROOT = P_TOKEN_A_ROOT;
        LK_TOKEN = P_LK_TOKEN;
        PROVIDER = P_PROVIDER;
        IS_REWARD = P_IS_REWARD;
        if (P_LK_DIFFDEC > 1) {
            LK_DIFFDEC = (10**P_LK_DIFFDEC);
        } else {
            LK_DIFFDEC = 1;
        }
        /** set init */
        PAIR_INITIALIZED = true;
        emit Init(address(this));
        emit ProviderTransferred(address(0), PROVIDER);
    }

    function initialize_mint_token(
        uint256 max_ab_price,
        uint256 pershare,
        uint256 rate_fund,
        uint256 limit_fund,
        uint256 mini_fund,
        bool p_is_on_open,
        uint112 p_grant_id
    ) external lock {
        // sufficient check
        require(_msgSender() == PROVIDER, "FORBIDDEN");
        require(
            (IS_P_CLOSED == false) &&
                (IS_P_MINTED == false) &&
                (PAIR_INITIALIZED == true),
            "IS_P_CLOSED_MINTED_FAILED"
        );
        require(
            (pershare > 0 && pershare < 1001) &&
                (rate_fund < 1001) &&
                (limit_fund >= mini_fund) &&
                (max_ab_price > 0),
            "PARAM_FAILED"
        );
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
        require(
            (amount > 0) &&
                ((PTOTAL_FUND.sub(PTOTAL_FUND_WITHDRAW)) > 0) &&
                (PTOTAL_FUND > PTOTAL_FUND_MINI),
            "AMOUNT_EXCEEDED"
        );
        uint256 amount_token_a = amount.mul(LK_DIFFDEC);
        require(
            (amount_token_a > 0) &&
                ((PTOTAL_FUND.sub(PTOTAL_FUND_WITHDRAW)) >= amount_token_a),
            "AMOUNT_EXCEEDED"
        );
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
        uint256 amount_fund = 0;
        uint256 amount_token_a = amount.mul(LK_DIFFDEC);
        uint256 amount_token_b = amount_token_a;
        if (XLT_AB_PRICE < XLT_MAX_AB_PRICE) {
            if (PTOTAL_FUND < PTOTAL_FUND_LIMIT) {
                amount_fund = (amount_token_a.mul(PRATE)).div(1000);
            }
            amount_token_a = (amount_token_a).sub(amount_fund);
            amount_token_b = ((amount_token_a.mul(XLT_PERSHARE)).div(1000));
        }
        if (XLT_TOKEN_A > 0 && XLT_TOKEN_B > 0) {
            amount_token_b = (amount_token_b.mul(XLT_TOKEN_B)).div(XLT_TOKEN_A);
        }
        /** balance */
        require(
            (amount_token_a > 0) && (amount_token_b > 0),
            "AMOUNT_AB_ZERO_FAILED"
        );
        IXLT_IERC20(TOKEN_A).safeTransferFrom(
            _msgSender(),
            address(this),
            amount
        );
        XLT_TOKEN_A = XLT_TOKEN_A.add(amount_token_a);
        XLT_TOKEN_B = XLT_TOKEN_B.add(amount_token_b);
        _updatePriceAB();
        /** fund */
        if (amount_fund > 0) {
            PTOTAL_FUND = PTOTAL_FUND.add(amount_fund);
        }
        /** lk */
        bool success = IXLoopLK(LK_TOKEN).mint(_msgSender(), amount_token_b);
        require(success, "LK_NOT_SUCCESS");
        emit Deposite(_msgSender(), amount, amount_token_b);
        emit AB(XLT_TOKEN_A, XLT_TOKEN_B);
    }

    function getBalanceA() external view returns (uint256) {
        return IXLT_IERC20(TOKEN_A).balanceOf(address(this));
    }

    function getInfo()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            bool,
            bool
        )
    {
        return (
            XLT_MAX_AB_PRICE,
            XLT_TOKEN_A,
            XLT_TOKEN_B,
            XLT_PERSHARE,
            PRATE,
            PTOTAL_FUND,
            PTOTAL_FUND_WITHDRAW,
            PTOTAL_FUND_LIMIT,
            PTOTAL_FUND_MINI,
            IS_ON_OPEN,
            IS_P_CLOSED
        );
    }

    function withdraw(uint256 amount) external payable minted lock {
        require(
            (XLT_TOKEN_A > 0) && (XLT_TOKEN_B > 0),
            "AMOUNT_AB_ZERO_FAILED"
        );
        uint256 balance1 = IXLT_IERC20(LK_TOKEN).balanceOf(_msgSender());
        require((amount > 0) && (balance1 >= amount), "AMOUNT_EXCEEDED");
        /** calculator */
        uint256 amount_token_a = (amount.mul(XLT_TOKEN_A)).div(XLT_TOKEN_B);
        require(
            (amount_token_a > 0) && (amount_token_a <= XLT_TOKEN_A),
            "AMOUNT_A_EXCEEDED"
        );
        uint256 amount_token_a_trans = amount_token_a.div(LK_DIFFDEC);
        require((amount_token_a_trans > 0), "AMOUNT_A_EXCEEDED");
        /** lk */
        bool success = IXLoopLK(LK_TOKEN).burn(_msgSender(), amount);
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
        if (XLT_TOKEN_A > 0 && XLT_TOKEN_B > 0) {
            XLT_AB_PRICE = XLT_TOKEN_A.div(XLT_TOKEN_B);
        } else {
            XLT_AB_PRICE = 0;
        }
    }

    function returnA(uint256 amount) external payable minted lock {
        _return_a(_msgSender(), amount);
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
        _return_b(_msgSender(), amount);
    }

    function _return_b(address usr, uint256 amount) private {
        uint256 balance1 = IXLT_IERC20(LK_TOKEN).balanceOf(usr);
        require((amount > 0) && (balance1 >= amount), "AMOUNT_EXCEEDED");
        /** lk */
        bool success = IXLoopLK(LK_TOKEN).burn(usr, amount);
        require(success, "LK_NOT_SUCCESS");
        /** balance */
        XLT_TOKEN_B = XLT_TOKEN_B.sub(amount);
        _updatePriceAB();
        emit AB(XLT_TOKEN_A, XLT_TOKEN_B);
        emit ReturnB(usr, amount);
    }
}
