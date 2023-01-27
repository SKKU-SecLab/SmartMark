
pragma solidity ^0.4.11;

contract Erc20Token {

    mapping (address => uint256) balances;

    mapping(address => mapping (address => uint256)) allowed;

    address[] allTokenHolders;

    string public name;

    string public symbol;

    uint8 public decimals;

    uint256 totalSupplyAmount = 0;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function Erc20Token(string _name, string _symbol, uint8 _decimals) {

        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

     function transferFrom(address _from, address _to, uint256 _amount) returns (bool success) {

        if (balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount > 0 && balances[_to] + _amount > balances[_to]) {
            bool isNew = balances[_to] < 1;
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            if (isNew)
                tokenOwnerAdd(_to);
            if (balances[_from] < 1)
                tokenOwnerRemove(_from);
            Transfer(_from, _to, _amount);
            return true;
        }
        return false;
    }

    function approve(address _spender, uint256 _amount) returns (bool success) {

        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {

        return allowed[_owner][_spender];
    }

    function totalSupply() constant returns (uint256) {

        return totalSupplyAmount;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {

        return balances[_owner];
    }

    function transfer(address _to, uint256 _amount) returns (bool success) {

        if (balances[msg.sender] < _amount || balances[_to] + _amount < balances[_to])
            throw;

        bool isRecipientNew = balances[_to] < 1;

        balances[msg.sender] -= _amount;
        balances[_to] += _amount;

        if (isRecipientNew)
            tokenOwnerAdd(_to);
        if (balances[msg.sender] < 1)
            tokenOwnerRemove(msg.sender);

        Transfer(msg.sender, _to, _amount);
        success = true;
    }

    function tokenOwnerAdd(address _addr) internal {

        uint256 tokenHolderCount = allTokenHolders.length;
        for (uint256 i = 0; i < tokenHolderCount; i++)
            if (allTokenHolders[i] == _addr)
                return;

        allTokenHolders.length++;
        allTokenHolders[allTokenHolders.length - 1] = _addr;
    }

    function tokenOwnerRemove(address _addr) internal {

        uint256 tokenHolderCount = allTokenHolders.length;
        uint256 foundIndex = 0;
        bool found = false;
        uint256 i;
        for (i = 0; i < tokenHolderCount; i++)
            if (allTokenHolders[i] == _addr) {
                foundIndex = i;
                found = true;
                break;
            }

        if (!found)
            return;

        for (i = foundIndex; i < tokenHolderCount - 1; i++)
            allTokenHolders[i] = allTokenHolders[i + 1];
        allTokenHolders.length--;
    }
}

contract ImperialCredits is Erc20Token("Imperial Credits", "XIC", 0) {

    address owner;
    bool public isIco  = true;

    function icoWithdraw() {

      if (this.balance == 0 || msg.sender != owner)
        throw;
      if (!owner.send(this.balance))
        throw;
    }

    function icoClose() {

      if (msg.sender != owner || !isIco)
        throw;
      if (this.balance > 0)
        if (!owner.send(this.balance))
          throw;
      uint256 remaining = 1000000000 - totalSupplyAmount;
      if (remaining > 0) {
        balances[msg.sender] += remaining;
        totalSupplyAmount = 1000000000;
      }
      isIco = false;
    }

    function destroyCredits(uint256 amount) {

      if (balances[msg.sender] < amount)
        throw;
      balances[msg.sender] -= amount;
      totalSupplyAmount -= amount;
    }

    function ImperialCredits() {

      owner=msg.sender;
      balances[msg.sender] = 100000;
      totalSupplyAmount = 100000;
    }

    function () payable {
        if (totalSupplyAmount >= 1000000000 || !isIco)
          throw;
        uint256 mintAmount = msg.value / 100000000000000;
        uint256 maxMint = 1000000000 - totalSupplyAmount;
        if (mintAmount > maxMint)
          mintAmount = maxMint;
        uint256 change = msg.value - (100000000000000 * mintAmount);
        if (!msg.sender.send(change))
          throw;
        balances[msg.sender] += mintAmount;
        totalSupplyAmount += mintAmount;
    }
}