// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import {SafeMath} from "./LIB/SafeMath.sol";
import "./LIB/XLTContext.sol";

contract XloopToken is XLTContext {
    using SafeMath for uint256;
    
    uint8 private _decimals;
    string private _symbol;
    string private _name;
    uint256 private _totalSupply;
    uint256 private _max_mint = (2**256) - (1000000000000000);
    address private immutable _pair;

    constructor(address provider, address p_pair) {
        require(_msgSender() != address(0) && provider != address(0), "ADDR_ZERO");
        _pair = p_pair;
        _decimals = 4;
        _symbol = "XLOOP";
        _name = "Xloop Token";
        /** mint to provider */
        _totalSupply = 1000000 * (100000) * (10**_decimals);
        _balances[provider] = _totalSupply;
        emit Transfer(address(0), provider, _totalSupply);
    }

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function name() public view returns (string memory) { return _name; }
    function symbol() public view returns (string memory) { return _symbol; }
    function decimals() public view returns (uint8) { return _decimals; }
    function totalSupply() external view returns (uint256) { return _totalSupply; }
    function pair() external view returns (address) { return _pair; }

    modifier onlyPair() {
        require(_msgSender() == _pair, "NOT_PAIR_OWNER");
        _;
    }

    /**
     * @dev transfer token for a specified address
     * @param to The address to transfer to.
     * @param amount The amount to be transferred.
     */
    function transfer(address to, uint256 amount) public returns (bool) {
        require(amount <= _balances[_msgSender()], "BALANCE_NOT_ENOUGH");
        _balances[_msgSender()] = _balances[_msgSender()].sub(amount);
        _balances[to] = _balances[to].add(amount);
        emit Transfer(_msgSender(), to, amount);
        return true;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the the balance of.
     * @return balance An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) external view returns (uint256 balance) {
        return _balances[owner];
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param amount uint256 the amount of tokens to be transferred
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(amount <= _balances[from], "BALANCE_NOT_ENOUGH");
        require(amount <= _allowances[from][_msgSender()], "ALLOWANCE_NOT_ENOUGH");
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);
        _allowances[from][_msgSender()] = _allowances[from][_msgSender()].sub(amount);
        emit Transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of _msgSender().
     * @param spender The address which will spend the funds.
     * @param amount The amount of tokens to be spent.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _allowances[_msgSender()][spender] = amount;
        emit Approval(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner _allowances to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function _mint(address user, uint256 amount) private {
        if(_totalSupply.add(amount) < _max_mint) {
            _balances[user] = _balances[user].add((amount));
            _totalSupply = _totalSupply.add(amount);
            emit Transfer(address(0), user, amount);
        }
    }

    function mint(address user, uint256 amount) external onlyPair {
        _mint(user, amount);
    }

    function burn(uint256 amount) external {
        require(amount > 0 && amount <= _balances[_msgSender()], "BALANCE_NOT_ENOUGH");
        _balances[_msgSender()] = _balances[_msgSender()].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(_msgSender(), address(0), amount);
    }
}