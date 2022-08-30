// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//import "./ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract TahaPashaCoin is ERC20, ERC20Burnable, Pausable, Ownable {
    constructor() ERC20("Taha Pasha Coin", "TPC") {
        _mint(msg.sender, 10000000 * 10 ** decimals());
    }

    mapping(address => bool)private expelleds;

    // uint transFee = 0.001 ether;  //BLOCKHAIN WAY
    
    /*
    function chgTransFee(uint newPrice) public onlyOwner{
        transFee = newPrice;
    }
    */
    //uint256 charge = gasleft() / 10;   

    //uint256 totalTransFee = 0;

    modifier notExpell(address sendAdd) {
    require(expelleds(sendAdd) == false);
    _;
  }


    function _transfer(address from,address to,uint256 amount) internal payable virtual override{
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        uint256 charge = gasleft() / 10;    // OUR DYNAMIC TRANS FEE
        uint256 tip =  msg.value;       // Priorirty fee
        require(fromBalance >= amount + charge + tip, "ERC20: transfer amount exceeds balance"); //transfee
        unchecked {
            _balances[from] = fromBalance - amount - charge - tip;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
            
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }





    function transfer(address to, uint256 amount) public payable virtual override notExpell(msg.sender) notExpell(to) returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }



    //Burn fee

    function _burn(address account, uint256 amount) internal virtual override{
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        uint256 burnFee =0;         //our burn fee
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            burnFee = amount/10;        //our burn fee percentage
            amount = amount-burnFee;
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }


    ////////////////////////////////// ONLY ADDING MODIFIERS //////////////////////////////////


    function balanceOf(address account) public view virtual override notExpell(msg.sender) returns (uint256) {
        return _balances[account];
    }
    function allowance(address owner, address spender) public view virtual override notExpell(msg.sender) returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override notExpell(msg.sender) returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public virtual override notExpell(msg.sender) notExpell(spender) returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual notExpell(msg.sender) notExpell(spender) returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual notExpell(msg.sender) notExpell(spender) returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    ////////////////////////////////// ONLY ADDING MODIFIERS //////////////////////////////////
    
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function expell(address excom) public onlyOwner{
        expelleds[excom] = true;
    }

    function deExpell(address excom) public onlyOwner{
        expelleds[excom] = false;
    }


    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}