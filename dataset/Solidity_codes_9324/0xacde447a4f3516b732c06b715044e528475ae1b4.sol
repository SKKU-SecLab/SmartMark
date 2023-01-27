
pragma solidity 0.4.25;


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


contract Adminable is Claimable {

    address[] public adminArray;

    struct AdminInfo {
        bool valid;
        uint256 index;
    }

    mapping(address => AdminInfo) public adminTable;

    event AdminAccepted(address indexed _admin);
    event AdminRejected(address indexed _admin);

    modifier onlyAdmin() {

        require(adminTable[msg.sender].valid, "caller is illegal");
        _;
    }

    function accept(address _admin) external onlyOwner {

        require(_admin != address(0), "administrator is illegal");
        AdminInfo storage adminInfo = adminTable[_admin];
        require(!adminInfo.valid, "administrator is already accepted");
        adminInfo.valid = true;
        adminInfo.index = adminArray.length;
        adminArray.push(_admin);
        emit AdminAccepted(_admin);
    }

    function reject(address _admin) external onlyOwner {

        AdminInfo storage adminInfo = adminTable[_admin];
        require(adminArray.length > adminInfo.index, "administrator is already rejected");
        require(_admin == adminArray[adminInfo.index], "administrator is already rejected");
        address lastAdmin = adminArray[adminArray.length - 1]; // will never underflow
        adminTable[lastAdmin].index = adminInfo.index;
        adminArray[adminInfo.index] = lastAdmin;
        adminArray.length -= 1; // will never underflow
        delete adminTable[_admin];
        emit AdminRejected(_admin);
    }

    function getAdminArray() external view returns (address[] memory) {

        return adminArray;
    }

    function getAdminCount() external view returns (uint256) {

        return adminArray.length;
    }
}


interface IAuthorizationDataSource {

    function getAuthorizedActionRole(address _wallet) external view returns (bool, uint256);


    function getAuthorizedActionRoleAndClass(address _wallet) external view returns (bool, uint256, uint256);


    function getTradeLimitsAndClass(address _wallet) external view returns (uint256, uint256, uint256);



    function getBuyTradeLimitAndClass(address _wallet) external view returns (uint256, uint256);


    function getSellTradeLimitAndClass(address _wallet) external view returns (uint256, uint256);

}



contract AuthorizationDataSource is IAuthorizationDataSource, Adminable {

    string public constant VERSION = "2.0.0";

    uint256 public walletCount;

    struct WalletInfo {
        uint256 sequenceNum;
        bool isWhitelisted;
        uint256 actionRole;
        uint256 buyLimit;
        uint256 sellLimit;
        uint256 tradeClass;
    }

    mapping(address => WalletInfo) public walletTable;

    event WalletSaved(address indexed _wallet);
    event WalletDeleted(address indexed _wallet);
    event WalletNotSaved(address indexed _wallet);
    event WalletNotDeleted(address indexed _wallet);

    function getAuthorizedActionRole(address _wallet) external view returns (bool, uint256) {

        WalletInfo storage walletInfo = walletTable[_wallet];
        return (walletInfo.isWhitelisted, walletInfo.actionRole);
    }

    function getAuthorizedActionRoleAndClass(address _wallet) external view returns (bool, uint256, uint256) {

        WalletInfo storage walletInfo = walletTable[_wallet];
        return (walletInfo.isWhitelisted, walletInfo.actionRole, walletInfo.tradeClass);
    }

    function getTradeLimitsAndClass(address _wallet) external view returns (uint256, uint256, uint256) {

        WalletInfo storage walletInfo = walletTable[_wallet];
        return (walletInfo.buyLimit, walletInfo.sellLimit, walletInfo.tradeClass);
    }

    function getBuyTradeLimitAndClass(address _wallet) external view returns (uint256, uint256) {

        WalletInfo storage walletInfo = walletTable[_wallet];
        return (walletInfo.buyLimit, walletInfo.tradeClass);
    }

    function getSellTradeLimitAndClass(address _wallet) external view returns (uint256, uint256) {

        WalletInfo storage walletInfo = walletTable[_wallet];
        return (walletInfo.sellLimit, walletInfo.tradeClass);
    }

    function upsertOne(address _wallet, uint256 _sequenceNum, bool _isWhitelisted, uint256 _actionRole, uint256 _buyLimit, uint256 _sellLimit, uint256 _tradeClass) external onlyAdmin {

        _upsert(_wallet, _sequenceNum, _isWhitelisted, _actionRole, _buyLimit, _sellLimit, _tradeClass);
    }

    function removeOne(address _wallet) external onlyAdmin {

        _remove(_wallet);
    }

    function upsertAll(address[] _wallets, uint256 _sequenceNum, bool _isWhitelisted, uint256 _actionRole, uint256 _buyLimit, uint256 _sellLimit, uint256 _tradeClass) external onlyAdmin {

        for (uint256 i = 0; i < _wallets.length; i++)
            _upsert(_wallets[i], _sequenceNum, _isWhitelisted, _actionRole, _buyLimit, _sellLimit, _tradeClass);
    }

    function removeAll(address[] _wallets) external onlyAdmin {

        for (uint256 i = 0; i < _wallets.length; i++)
            _remove(_wallets[i]);
    }

    function _upsert(address _wallet, uint256 _sequenceNum, bool _isWhitelisted, uint256 _actionRole, uint256 _buyLimit, uint256 _sellLimit, uint256 _tradeClass) private {

        require(_wallet != address(0), "wallet is illegal");
        WalletInfo storage walletInfo = walletTable[_wallet];
        if (walletInfo.sequenceNum < _sequenceNum) {
            if (walletInfo.sequenceNum == 0) // increment the wallet-count only when a new wallet is inserted
                walletCount += 1; // will never overflow because the number of different wallets = 2^160 < 2^256
            walletInfo.sequenceNum = _sequenceNum;
            walletInfo.isWhitelisted = _isWhitelisted;
            walletInfo.actionRole = _actionRole;
            walletInfo.buyLimit = _buyLimit;
            walletInfo.sellLimit = _sellLimit;
            walletInfo.tradeClass = _tradeClass;
            emit WalletSaved(_wallet);
        }
        else {
            emit WalletNotSaved(_wallet);
        }
    }

    function _remove(address _wallet) private {

        require(_wallet != address(0), "wallet is illegal");
        WalletInfo storage walletInfo = walletTable[_wallet];
        if (walletInfo.sequenceNum > 0) { // decrement the wallet-count only when an existing wallet is removed
            walletCount -= 1; // will never underflow because every decrement follows a corresponding increment
            delete walletTable[_wallet];
            emit WalletDeleted(_wallet);
        }
        else {
            emit WalletNotDeleted(_wallet);
        }
    }
}