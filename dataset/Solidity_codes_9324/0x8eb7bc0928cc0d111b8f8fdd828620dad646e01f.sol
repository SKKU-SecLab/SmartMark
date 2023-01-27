
pragma solidity 0.4.25;


interface ITradingClasses {

    function getInfo(uint256 _id) external view returns (uint256, uint256, uint256);


    function getActionRole(uint256 _id) external view returns (uint256);


    function getSellLimit(uint256 _id) external view returns (uint256);


    function getBuyLimit(uint256 _id) external view returns (uint256);

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



contract TradingClasses is ITradingClasses, Claimable {

    string public constant VERSION = "2.0.0";

    uint256[] public array;

    struct Info {
        uint256 actionRole;
        uint256 buyLimit;
        uint256 sellLimit;
        uint256 index;
    }

    mapping(uint256 => Info) public table;

    enum Action {None, Insert, Update, Remove}

    event ActionCompleted(uint256 _id, uint256 _actionRole, uint256 _buyLimit, uint256 _sellLimit, Action _action);

    function getInfo(uint256 _id) external view returns (uint256, uint256, uint256) {

        Info memory info = table[_id];
        return (info.buyLimit, info.sellLimit, info.actionRole);
    }


    function getActionRole(uint256 _id) external view returns (uint256) {

        return table[_id].actionRole;
    }

    function getSellLimit(uint256 _id) external view returns (uint256) {

        return table[_id].sellLimit;
    }

    function getBuyLimit(uint256 _id) external view returns (uint256) {

        return table[_id].buyLimit;
    }

    function set(uint256 _id, uint256 _actionRole, uint256 _buyLimit, uint256 _sellLimit) external onlyOwner {

        Info storage info = table[_id];
        Action action = getAction(info, _actionRole, _buyLimit, _sellLimit);
        if (action == Action.Insert) {
            info.index = array.length;
            info.actionRole = _actionRole;
            info.buyLimit = _buyLimit;
            info.sellLimit = _sellLimit;
            array.push(_id);
        }
        else if (action == Action.Update) {
            info.actionRole = _actionRole;
            info.buyLimit = _buyLimit;
            info.sellLimit = _sellLimit;
        }
        else if (action == Action.Remove) {
            uint256 last = array[array.length - 1];
            table[last].index = info.index;
            array[info.index] = last;
            array.length -= 1;
            delete table[_id];
        }
        emit ActionCompleted(_id, _actionRole, _buyLimit, _sellLimit, action);
    }



    function getArray() external view returns (uint256[] memory) {

        return array;
    }

    function getCount() external view returns (uint256) {

        return array.length;
    }

    function getAction(Info _currentInfo, uint256 _newActionRole, uint256 _newBuyLimit, uint256 _newSellLimit) private pure returns (Action) {

        bool currentExists = _currentInfo.buyLimit != 0 || _currentInfo.sellLimit != 0 || _currentInfo.actionRole != 0;
        bool isRemoveRequired = _newActionRole == 0 && _newBuyLimit == 0 && _newSellLimit == 0;
        bool isUpdateRequired = _currentInfo.actionRole != _newActionRole || _currentInfo.buyLimit != _newBuyLimit || _currentInfo.sellLimit != _newSellLimit;
        if (!currentExists && !isRemoveRequired)
            return Action.Insert;
        if (currentExists && isRemoveRequired)
            return Action.Remove;
        if (isUpdateRequired)
            return Action.Update;
        return Action.None;
    }
}