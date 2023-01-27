
pragma solidity ^0.4.24;

library SafeMath {


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    return _a / _b;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);
    return _a - _b;
  }

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

contract Ownable {

  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

contract Withdrawable is Ownable {

    event ReceiveEther(address _from, uint256 _value);
    event WithdrawEther(address _to, uint256 _value);
    event WithdrawToken(address _token, address _to, uint256 _value);

    function () payable public {
        emit ReceiveEther(msg.sender, msg.value);
    }

    function withdraw(address _to, uint _amount) public onlyOwner returns (bool) {

        require(_to != address(0));
        _to.transfer(_amount);
        emit WithdrawEther(_to, _amount);

        return true;
    }

    function withdrawToken(address _token, address _to, uint256 _value) public onlyOwner returns (bool) {

        require(_to != address(0));
        require(_token != address(0));

        ERC20 tk = ERC20(_token);
        tk.transfer(_to, _value);
        emit WithdrawToken(_token, _to, _value);

        return true;
    }



}

contract Claimable is Ownable {

  address public pendingOwner;

  modifier onlyPendingOwner() {

    require(msg.sender == pendingOwner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {

    pendingOwner = newOwner;
  }

  function claimOwnership() public onlyPendingOwner {

    emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}

contract DRCWalletStorage is Withdrawable, Claimable {

    using SafeMath for uint256;

    struct WithdrawWallet {
        bytes32 name;
        address walletAddr;
    }

    struct DepositRepository {
        int256 balance; // can be negative
        uint256 frozen;
        WithdrawWallet[] withdrawWallets;
    }

    mapping (address => DepositRepository) depositRepos;
    mapping (address => address) public walletDeposits;
    mapping (address => bool) public frozenDeposits;
    address[] depositAddresses;
    uint256 public size;


    function addDeposit(address _wallet, address _depositAddr) onlyOwner public returns (bool) {

        require(_wallet != address(0));
        require(_depositAddr != address(0));

        walletDeposits[_wallet] = _depositAddr;
        WithdrawWallet[] storage withdrawWalletList = depositRepos[_depositAddr].withdrawWallets;
        withdrawWalletList.push(WithdrawWallet("default wallet", _wallet));
        depositRepos[_depositAddr].balance = 0;
        depositRepos[_depositAddr].frozen = 0;
        depositAddresses.push(_depositAddr);

        size = size.add(1);
        return true;
    }

    function removeDepositAddress(address _deposit) internal returns (bool) {

        uint i = 0;
        for (;i < depositAddresses.length; i = i.add(1)) {
            if (depositAddresses[i] == _deposit) {
                break;
            }
        }

        if (i >= depositAddresses.length) {
            return false;
        }

        while (i < depositAddresses.length.sub(1)) {
            depositAddresses[i] = depositAddresses[i.add(1)];
            i = i.add(1);
        }

        delete depositAddresses[depositAddresses.length.sub(1)];
        depositAddresses.length = depositAddresses.length.sub(1);
        return true;
    }

    function removeDeposit(address _depositAddr) onlyOwner public returns (bool) {

        require(isExisted(_depositAddr));

        WithdrawWallet memory withdraw = depositRepos[_depositAddr].withdrawWallets[0];
        delete walletDeposits[withdraw.walletAddr];
        delete depositRepos[_depositAddr];
        delete frozenDeposits[_depositAddr];
        removeDepositAddress(_depositAddr);

        size = size.sub(1);
        return true;
    }

    function addWithdraw(address _deposit, bytes32 _name, address _withdraw) onlyOwner public returns (bool) {

        require(_deposit != address(0));

        WithdrawWallet[] storage withdrawWalletList = depositRepos[_deposit].withdrawWallets;
        withdrawWalletList.push(WithdrawWallet(_name, _withdraw));
        return true;
    }

    function increaseBalance(address _deposit, uint256 _value) onlyOwner public returns (bool) {

        require (walletsNumber(_deposit) > 0);
        int256 _balance = depositRepos[_deposit].balance;
        depositRepos[_deposit].balance = _balance + int256(_value);
        return true;
    }

    function decreaseBalance(address _deposit, uint256 _value) onlyOwner public returns (bool) {

        require (walletsNumber(_deposit) > 0);
        int256 _balance = depositRepos[_deposit].balance;
        depositRepos[_deposit].balance = _balance - int256(_value);
        return true;
    }

    function changeDefaultWallet(address _oldWallet, address _newWallet) onlyOwner public returns (bool) {

        require(_oldWallet != address(0));
        require(_newWallet != address(0));

        address _deposit = walletDeposits[_oldWallet];
        WithdrawWallet[] storage withdrawWalletList = depositRepos[_deposit].withdrawWallets;
        withdrawWalletList[0].walletAddr = _newWallet;
        walletDeposits[_newWallet] = _deposit;
        delete walletDeposits[_oldWallet];

        return true;
    }

    function changeWalletName(address _deposit, bytes32 _newName, address _wallet) onlyOwner public returns (bool) {

        require(_deposit != address(0));
        require(_wallet != address(0));

        uint len = walletsNumber(_deposit);
        for (uint i = 1; i < len; i = i.add(1)) {
            WithdrawWallet storage wallet = depositRepos[_deposit].withdrawWallets[i];
            if (_wallet == wallet.walletAddr) {
                wallet.name = _newName;
                return true;
            }
        }

        return false;
    }

    function freezeTokens(address _deposit, bool _freeze, uint256 _value) onlyOwner public returns (bool) {

        require(_deposit != address(0));

        frozenDeposits[_deposit] = _freeze;
        uint256 _frozen = depositRepos[_deposit].frozen;
        int256 _balance = depositRepos[_deposit].balance;
        int256 freezeAble = _balance - int256(_frozen);
        freezeAble = freezeAble < 0 ? 0 : freezeAble;
        if (_freeze) {
            if (_value > uint256(freezeAble)) {
                _value = uint256(freezeAble);
            }
            depositRepos[_deposit].frozen = _frozen.add(_value);
        } else {
            if (_value > _frozen) {
                _value = _frozen;
            }
            depositRepos[_deposit].frozen = _frozen.sub(_value);
        }

        return true;
    }

    function wallet(address _deposit, uint256 _ind) public view returns (address) {

        require(_deposit != address(0));

        WithdrawWallet[] storage withdrawWalletList = depositRepos[_deposit].withdrawWallets;
        return withdrawWalletList[_ind].walletAddr;
    }

    function walletName(address _deposit, uint256 _ind) public view returns (bytes32) {

        require(_deposit != address(0));

        WithdrawWallet[] storage withdrawWalletList = depositRepos[_deposit].withdrawWallets;
        return withdrawWalletList[_ind].name;
    }

    function walletsNumber(address _deposit) public view returns (uint256) {

        require(_deposit != address(0));

        WithdrawWallet[] storage withdrawWalletList = depositRepos[_deposit].withdrawWallets;
        return withdrawWalletList.length;
    }

    function isExisted(address _deposit) public view returns (bool) {

        return (walletsNumber(_deposit) > 0);
    }

    function balanceOf(address _deposit) public view returns (int256) {

        require(_deposit != address(0));
        return depositRepos[_deposit].balance;
    }

    function frozenAmount(address _deposit) public view returns (uint256) {

        require(_deposit != address(0));
        return depositRepos[_deposit].frozen;
    }

    function depositAddressByIndex(uint256 _ind) public view returns (address) {

        return depositAddresses[_ind];
    }
}

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)
    public view returns (uint256);


  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);


  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}