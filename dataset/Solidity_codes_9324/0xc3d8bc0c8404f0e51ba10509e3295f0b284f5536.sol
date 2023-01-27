
pragma solidity 0.6.12;

contract Governed {

    event NewGov(address oldGov, address newGov);
    event NewPendingGov(address oldPendingGov, address newPendingGov);

    address public gov;
    address public pendingGov;

    modifier onlyGov {

        require(msg.sender == gov, "!gov");
        _;
    }

    function _setPendingGov(address who)
        public
        onlyGov
    {

        address old = pendingGov;
        pendingGov = who;
        emit NewPendingGov(old, who);
    }

    function _acceptGov()
        public
    {

        require(msg.sender == pendingGov, "!pendingGov");
        address oldgov = gov;
        gov = pendingGov;
        pendingGov = address(0);
        emit NewGov(oldgov, gov);
    }
}

contract SubGoverned is Governed {

    event SubGovModified(
        address account,
        bool isSubGov
    );
    mapping(address => bool) public isSubGov;

    modifier onlyGovOrSubGov() {

        require(msg.sender == gov || isSubGov[msg.sender]);
        _;
    }

    function setIsSubGov(address subGov, bool _isSubGov)
        public
        onlyGov
    {

        isSubGov[subGov] = _isSubGov;
        emit SubGovModified(subGov, _isSubGov);
    }
}

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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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
}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface ISetToken is IERC20 {



    enum ModuleState {
        NONE,
        PENDING,
        INITIALIZED
    }

    struct Position {
        address component;
        address module;
        int256 unit;
        uint8 positionState;
        bytes data;
    }

    struct ComponentPosition {
      int256 virtualUnit;
      address[] externalPositionModules;
      mapping(address => ExternalPosition) externalPositions;
    }

    struct ExternalPosition {
      int256 virtualUnit;
      bytes data;
    }


    
    function addComponent(address _component) external;

    function removeComponent(address _component) external;

    function editDefaultPositionUnit(address _component, int256 _realUnit) external;

    function addExternalPositionModule(address _component, address _positionModule) external;

    function removeExternalPositionModule(address _component, address _positionModule) external;

    function editExternalPositionUnit(address _component, address _positionModule, int256 _realUnit) external;

    function editExternalPositionData(address _component, address _positionModule, bytes calldata _data) external;


    function invoke(address _target, uint256 _value, bytes calldata _data) external returns(bytes memory);


    function editPositionMultiplier(int256 _newMultiplier) external;


    function mint(address _account, uint256 _quantity) external;

    function burn(address _account, uint256 _quantity) external;


    function lock() external;

    function unlock() external;


    function addModule(address _module) external;

    function removeModule(address _module) external;

    function initializeModule() external;


    function setManager(address _manager) external;


    function manager() external view returns (address);

    function moduleStates(address _module) external view returns (ModuleState);

    function getModules() external view returns (address[] memory);

    
    function getDefaultPositionRealUnit(address _component) external view returns(int256);

    function getExternalPositionRealUnit(address _component, address _positionModule) external view returns(int256);

    function getComponents() external view returns(address[] memory);

    function getExternalPositionModules(address _component) external view returns(address[] memory);

    function getExternalPositionData(address _component, address _positionModule) external view returns(bytes memory);

    function isExternalPositionModule(address _component, address _module) external view returns(bool);

    function isComponent(address _component) external view returns(bool);

    
    function positionMultiplier() external view returns (int256);

    function getTotalComponentRealUnits(address _component) external view returns(int256);


    function isInitializedModule(address _module) external view returns(bool);

    function isPendingModule(address _module) external view returns(bool);

    function isLocked() external view returns (bool);

}

contract TreasuryManager is SubGoverned {

    using Address for address;


    modifier onlyAllowedForModule(address _module, address _user){

        require(moduleAdapterAllowlist[_module][_user] || _user == gov , "TreasuryManager::onlyAllowlistedForModule: User is not allowed for module");
        _;
    }


    ISetToken public setToken;

    mapping(address => mapping(address => bool)) public moduleAdapterAllowlist;

    mapping(address => bool) public tokenAllowlist;


    event TokensAdded(address[] tokens);
    event TokensRemoved(address[] tokens);
    
    constructor(
        ISetToken _setToken,
        address _gov,
        address[] memory _allowedTokens        
    ) 
        public
    {
        setToken = _setToken;
        gov = _gov;
        for(uint256 index = 0; index < _allowedTokens.length; index++){
            tokenAllowlist[_allowedTokens[index]] = true;
            emit TokensAdded(_allowedTokens);
        }
    }



    function setManager(address _newManager) 
        external
        onlyGov
    {

        setToken.setManager(_newManager);
    }

    function addModule(address _module) 
        external
        onlyGov
    {

        setToken.addModule(_module);
    }

    function removeModule(address _module)
        external
        onlyGov
    {

        setToken.removeModule(_module);
    }

    function interactModule(address _module, bytes calldata _data)
        external
        onlyAllowedForModule(_module, msg.sender)
    {


        _module.functionCallWithValue(_data, 0);
    }

    function setModuleAdapterAllowed(
        address _module,
        address _adapter,
        bool allowed
    )
        external
        onlyGov
    {

        moduleAdapterAllowlist[_module][_adapter] = allowed;
    }


    function addTokens(address[] memory _tokens)
        public
        onlyGov
    {

        for(uint256 index = 0; index < _tokens.length; index++ ){
            tokenAllowlist[_tokens[index]] = true;
        }
        emit TokensAdded(_tokens);
    }

    function removeTokens(address[] memory _tokens)
        external
        onlyGov
    {

        for(uint256 index = 0; index < _tokens.length; index++ ){
            tokenAllowlist[_tokens[index]] = false;
        }
        emit TokensRemoved(_tokens);
    }

    function isTokenAllowed(address _token)
        external
        view
        returns (bool allowed)
    {

        return tokenAllowlist[_token];
    }

}