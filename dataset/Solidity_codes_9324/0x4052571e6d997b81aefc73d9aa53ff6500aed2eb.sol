
pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.7.4;

interface IGovernable {

    function gasToken() external view returns (address);

    function enableGasPromotion() external view returns (bool);

    function router() external view returns (address);

    
    function isMastermind(address _address) external view returns (bool);

    function isGovernor(address _address) external view returns (bool);

    function isPartner(address _address) external view returns (bool);

    function isUser(address _address) external view returns (bool);

}// MIT

pragma solidity ^0.7.4;


contract DPexGovernance is IGovernable, Initializable, ContextUpgradeable {

    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) public governanceLevels;

    address public override gasToken;

    bool public override enableGasPromotion;

    address public override router;


    event GovernanceLevelChanged(address indexed addressChanged, uint256 oldLevel, uint256 newLevel);


    function initialize() external initializer {

        _setGovernanceLevel(_msgSender(), 100);
        gasToken = 0x0000000000004946c0e9F43F4Dee607b0eF1fA1c;
    }


    modifier onlyMastermind() {

        require(isMastermind(_msgSender()), "Only mastermind is allowed");
        _;
    }
    modifier onlyGovernor() {

        require(isGovernor(_msgSender()), "Only governor is allowed");
        _;
    }
    modifier onlyPartner() {

        require(isPartner(_msgSender()), "Only partner is allowed");
        _;
    }


    function viewGovernanceLevel(address _address) public view returns(uint256) {

        return governanceLevels[_address];
    }
    function isMastermind(address _address) public override view returns (bool) {

        return viewGovernanceLevel(_address) >= 100;
    }
    function isGovernor(address _address) public override view returns (bool) {

        return viewGovernanceLevel(_address) >= 50;
    }
    function isPartner(address _address) public override view returns (bool) {

        return viewGovernanceLevel(_address) >= 10;
    }
    function isUser(address _address) public override view returns (bool) {

        return viewGovernanceLevel(_address) == 0;
    }


    function setGovernanceLevel(address _address, uint256 _level) external {

        require(_address != address(0), "Invalid, governanceLevel is address(0)");
        require(
            (_level < 100 && governanceLevels[_msgSender()] > _level) || 
            (_level >= 100 && governanceLevels[_msgSender()] >= _level), 
            "Governance level to low"
        );
        require(
            governanceLevels[_msgSender()] > governanceLevels[_address] ||
            _msgSender() == _address, 
            "Sender level is lower than address level"
        );
        _setGovernanceLevel(_address, _level);
    }
    function _setGovernanceLevel(address _address, uint256 _level) internal virtual {

        uint256 oldLevel = governanceLevels[_address];
        governanceLevels[_address] = _level;
        emit GovernanceLevelChanged(_address, oldLevel, _level);
    }

    function setGasToken(address _gasToken) external onlyGovernor {

        gasToken = _gasToken;
    }
    function setEnableGasPromotion(bool _enableGasPromotion) external onlyGovernor {

        enableGasPromotion = _enableGasPromotion;
    }
    function setRouter(address _router) external onlyGovernor {

        require(_router != address(0), "DPexGovernance: ROUTER_NO_ADDRESS");
        router = _router;
    }
}