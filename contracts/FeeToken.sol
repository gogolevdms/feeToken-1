// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import '@openzeppelin/contracts/access/Ownable.sol';

/**
 * @title FeeToken.
 * @author bright lynx team.
 * @dev This contract is an augmented implementation of the erc-20 token in its classic form. 
 * Users can use standart erc-20 functions, but they have to pay a tax charged for using the transfer function.
 * The tax in the form of tokens goes to the wallet specified by the owner.
 */

contract FeeToken is IERC20, IERC20Metadata, Context, Ownable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply = 12884901889;
    uint256 public taxFee = 25;
    uint256 private _denom = 10000;

    address public wallet;

    string private _name;
    string private _symbol;

    event setFee(uint _oldFee, uint _newFee);
    event setWallet(address _oldWallet, address _newWallet);

    constructor(string memory name_, string memory symbol_) {
        _balances[msg.sender] = _totalSupply;
        _name = name_;
        _symbol = symbol_;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() 
        public 
        view 
        virtual 
        returns (string memory) 
    {
        return _name;
    }

    function symbol() 
        public 
        view 
        virtual 
        returns (string memory) 
    {
        return _symbol;
    }

    function decimals() 
        public 
        view 
        virtual 
        returns (uint8) 
    {
        return 18;
    }

    function totalSupply() 
        public 
        view 
        virtual 
        returns (uint256) 
    {
        return _totalSupply;
    }

    function balanceOf(address account) 
        public 
        view 
        virtual 
        returns (uint256) 
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) 
        external 
        returns (bool) 
    {
        _transfer(_msgSender(), recipient, amount);

        return true;
    }

    /// @notice The function sets the new tax amount.
    /// @dev Stores the unsigned int value in the state variable 'taxFee'.
    /// @param _taxFee The new value to store.
    /// @return The bool value.

    function _setFee(uint256 _taxFee) 
        external 
        onlyOwner 
        returns (bool) 
    {
        emit setFee(taxFee, _taxFee);

        taxFee = _taxFee;

        return true;
    }

    /// @notice The function sets a new wallet.
    /// @dev Stores the address value in the state variable 'wallet'.
    /// @param _wallet The new value to store.
    /// @return The bool value.

    function _setWallet(address _wallet) 
        external 
        onlyOwner 
        returns (bool)
    {
        emit setWallet(wallet, _wallet);

        wallet = _wallet;

        return true;
    }

    function allowance(address owner, address spender) 
        public 
        view 
        virtual 
        returns (uint256) 
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) 
        public 
        virtual 
        returns (bool) 
    {
        _approve(_msgSender(), spender, amount);

        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) 
        public 
        virtual 
        returns (bool) 
    {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);

        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) 
        public 
        virtual 
        returns (bool) 
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /// @notice The function transfers tokens.
    /** 
    * @dev The function moves `amount` of tokens from `sender` to `recipient`.
    *
    * Requirements:
    *
    * - `sender` cannot be the zero address.
    * - `recipient` cannot be the zero address.
    * - `sender` must have a balance of at least `amount`.
    */
    /// @param sender The address of the token sender.
    /// @param recipient Address of the token recipient.
    /// @param amount Number of tokens to transfer.

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }

        uint256 fee = (amount * taxFee) / _denom;
        uint256 net = amount - fee;

        _balances[wallet] += fee;
        _balances[sender] -= amount;
        _balances[recipient] += net;

        emit Transfer(sender, wallet, fee);
        emit Transfer(sender, recipient, net);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}