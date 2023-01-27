
pragma solidity ^0.4.24;


interface IPermissionManager {


    function checkPermission(address _delegate, address _module, bytes32 _perm) external view returns(bool);


    function addDelegate(address _delegate, bytes32 _details) external;


    function deleteDelegate(address _delegate) external;


    function checkDelegate(address _potentialDelegate) external view returns(bool);


    function changePermission(
        address _delegate,
        address _module,
        bytes32 _perm,
        bool _valid
    )
    external;


    function changePermissionMulti(
        address _delegate,
        address[] _modules,
        bytes32[] _perms,
        bool[] _valids
    )
    external;


    function getAllDelegatesWithPerm(address _module, bytes32 _perm) external view returns(address[]);


    function getAllModulesAndPermsFromTypes(address _delegate, uint8[] _types) external view returns(address[], bytes32[]);


    function getPermissions() external view returns(bytes32[]);


    function getAllDelegates() external view returns(address[]);


}


library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
    assert(c >= a);
    return c;
  }
}


library TokenLib {


    using SafeMath for uint256;

    struct ModuleData {
        bytes32 name;
        address module;
        address moduleFactory;
        bool isArchived;
        uint8[] moduleTypes;
        uint256[] moduleIndexes;
        uint256 nameIndex;
    }

    struct Checkpoint {
        uint256 checkpointId;
        uint256 value;
    }

    struct InvestorDataStorage {
        mapping (address => bool) investorListed;
        address[] investors;
        uint256 investorCount;
    }

    event ModuleArchived(uint8[] _types, address _module, uint256 _timestamp);
    event ModuleUnarchived(uint8[] _types, address _module, uint256 _timestamp);

    function archiveModule(ModuleData storage _moduleData, address _module) public {

        require(!_moduleData.isArchived, "Module archived");
        require(_moduleData.module != address(0), "Module missing");
        emit ModuleArchived(_moduleData.moduleTypes, _module, now);
        _moduleData.isArchived = true;
    }

    function unarchiveModule(ModuleData storage _moduleData, address _module) public {

        require(_moduleData.isArchived, "Module unarchived");
        emit ModuleUnarchived(_moduleData.moduleTypes, _module, now);
        _moduleData.isArchived = false;
    }

    function checkPermission(address[] storage _modules, address _delegate, address _module, bytes32 _perm) public view returns(bool) {

        if (_modules.length == 0) {
            return false;
        }

        for (uint8 i = 0; i < _modules.length; i++) {
            if (IPermissionManager(_modules[i]).checkPermission(_delegate, _module, _perm)) {
                return true;
            }
        }

        return false;
    }

    function getValueAt(Checkpoint[] storage _checkpoints, uint256 _checkpointId, uint256 _currentValue) public view returns(uint256) {

        if (_checkpointId == 0) {
            return 0;
        }
        if (_checkpoints.length == 0) {
            return _currentValue;
        }
        if (_checkpoints[0].checkpointId >= _checkpointId) {
            return _checkpoints[0].value;
        }
        if (_checkpoints[_checkpoints.length - 1].checkpointId < _checkpointId) {
            return _currentValue;
        }
        if (_checkpoints[_checkpoints.length - 1].checkpointId == _checkpointId) {
            return _checkpoints[_checkpoints.length - 1].value;
        }
        uint256 min = 0;
        uint256 max = _checkpoints.length - 1;
        while (max > min) {
            uint256 mid = (max + min) / 2;
            if (_checkpoints[mid].checkpointId == _checkpointId) {
                max = mid;
                break;
            }
            if (_checkpoints[mid].checkpointId < _checkpointId) {
                min = mid + 1;
            } else {
                max = mid;
            }
        }
        return _checkpoints[max].value;
    }

    function adjustCheckpoints(TokenLib.Checkpoint[] storage _checkpoints, uint256 _newValue, uint256 _currentCheckpointId) public {

        if (_currentCheckpointId == 0) {
            return;
        }
        if ((_checkpoints.length > 0) && (_checkpoints[_checkpoints.length - 1].checkpointId == _currentCheckpointId)) {
            return;
        }
        _checkpoints.push(
            TokenLib.Checkpoint({
                checkpointId: _currentCheckpointId,
                value: _newValue
            })
        );
    }

    function adjustInvestorCount(
        InvestorDataStorage storage _investorData,
        address _from,
        address _to,
        uint256 _value,
        uint256 _balanceTo,
        uint256 _balanceFrom
        ) public  {

        if ((_value == 0) || (_from == _to)) {
            return;
        }
        if ((_balanceTo == 0) && (_to != address(0))) {
            _investorData.investorCount = (_investorData.investorCount).add(1);
        }
        if (_value == _balanceFrom) {
            _investorData.investorCount = (_investorData.investorCount).sub(1);
        }
        if (!_investorData.investorListed[_to] && (_to != address(0))) {
            _investorData.investors.push(_to);
            _investorData.investorListed[_to] = true;
        }

    }

}