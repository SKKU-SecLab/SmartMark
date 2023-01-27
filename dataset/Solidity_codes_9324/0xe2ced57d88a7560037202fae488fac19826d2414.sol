
pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

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
        return !AddressUpgradeable.isContract(address(this));
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

pragma solidity >=0.6.0 <0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// UNLICENSED
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


contract FuseFeeDistributor is Initializable, OwnableUpgradeable {

    using AddressUpgradeable for address;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    function initialize(uint256 _defaultInterestFeeRate) public initializer {

        require(_defaultInterestFeeRate <= 1e18, "!Interest fee");
        __Ownable_init();
        defaultInterestFeeRate = _defaultInterestFeeRate;
        maxSupplyEth = uint256(-1);
        maxUtilizationRate = uint256(-1);
    }

    uint256 public defaultInterestFeeRate;

    function _setDefaultInterestFeeRate(uint256 _defaultInterestFeeRate) external onlyOwner {

        require(_defaultInterestFeeRate <= 1e18, "!Interest fee");
        defaultInterestFeeRate = _defaultInterestFeeRate;
    }

    function _withdrawAssets(address erc20Contract) external {

        if (erc20Contract == address(0)) {
            uint256 balance = address(this).balance;
            require(balance > 0, "!balance");
            (bool success, ) = owner().call{value: balance}("");
            require(success, "!transfer");
        } else {
            IERC20Upgradeable token = IERC20Upgradeable(erc20Contract);
            uint256 balance = token.balanceOf(address(this));
            require(balance > 0, "!balance");
            token.safeTransfer(owner(), balance);
        }
    }

    uint256 public minBorrowEth;

    uint256 public maxSupplyEth;

    uint256 public maxUtilizationRate;

    function _setPoolLimits(uint256 _minBorrowEth, uint256 _maxSupplyEth, uint256 _maxUtilizationRate) external onlyOwner {

        minBorrowEth = _minBorrowEth;
        maxSupplyEth = _maxSupplyEth;
        maxUtilizationRate = _maxUtilizationRate;
    }

    function _pauseAllBorrowing() external onlyGuardian {

        minBorrowEth = uint(-1);
    }

    receive() external payable { }

    function _callPool(address[] calldata targets, bytes[] calldata data) external onlyOwner {

        require(targets.length > 0 && targets.length == data.length, "!Array lengths");
        for (uint256 i = 0; i < targets.length; i++) targets[i].functionCall(data[i]);
    }

    function _callPool(address[] calldata targets, bytes calldata data) external onlyOwner {

        require(targets.length > 0, "!target addresses");
        for (uint256 i = 0; i < targets.length; i++) targets[i].functionCall(data);
    }

    function deployCEther(bytes calldata constructorData) external virtual returns (address) {

        (address comptroller, , , , address implementation, , , ) = abi.decode(constructorData, (address, address, string, string, address, bytes, uint256, uint256));

        require(cEtherDelegateWhitelist[address(0)][implementation][false], "!CEtherDelegate");

        require(comptroller == msg.sender, "!Comptroller");

        bytes memory cEtherDelegatorCreationCode = hex"608060405234801561001057600080fd5b50604051610785380380610785833981810160405261010081101561003457600080fd5b8151602083015160408085018051915193959294830192918464010000000082111561005f57600080fd5b90830190602082018581111561007457600080fd5b825164010000000081118282018810171561008e57600080fd5b82525081516020918201929091019080838360005b838110156100bb5781810151838201526020016100a3565b50505050905090810190601f1680156100e85780820380516001836020036101000a031916815260200191505b506040526020018051604051939291908464010000000082111561010b57600080fd5b90830190602082018581111561012057600080fd5b825164010000000081118282018810171561013a57600080fd5b82525081516020918201929091019080838360005b8381101561016757818101518382015260200161014f565b50505050905090810190601f1680156101945780820380516001836020036101000a031916815260200191505b506040818152602083015192018051929491939192846401000000008211156101bc57600080fd5b9083019060208201858111156101d157600080fd5b82516401000000008111828201881017156101eb57600080fd5b82525081516020918201929091019080838360005b83811015610218578181015183820152602001610200565b50505050905090810190601f1680156102455780820380516001836020036101000a031916815260200191505b5060405260200180519060200190929190805190602001909291905050506103ba8489898989878760405160240180876001600160a01b03166001600160a01b03168152602001866001600160a01b03166001600160a01b031681526020018060200180602001858152602001848152602001838103835287818151815260200191508051906020019080838360005b838110156102ed5781810151838201526020016102d5565b50505050905090810190601f16801561031a5780820380516001836020036101000a031916815260200191505b50838103825286518152865160209182019188019080838360005b8381101561034d578181015183820152602001610335565b50505050905090810190601f16801561037a5780820380516001836020036101000a031916815260200191505b5060408051601f198184030181529190526020810180516001600160e01b03908116631e70b25560e21b1790915290995061049c16975050505050505050565b5061048e848560008660405160240180846001600160a01b03166001600160a01b031681526020018315151515815260200180602001828103825283818151815260200191508051906020019080838360005b8381101561042557818101518382015260200161040d565b50505050905090810190601f1680156104525780820380516001836020036101000a031916815260200191505b5060408051601f198184030181529190526020810180516001600160e01b039081166350d85b7360e01b1790915290955061049c169350505050565b50505050505050505061055e565b606060006060846001600160a01b0316846040518082805190602001908083835b602083106104dc5780518252601f1990920191602091820191016104bd565b6001836020036101000a038019825116818451168082178552505050505050905001915050600060405180830381855af49150503d806000811461053c576040519150601f19603f3d011682016040523d82523d6000602084013e610541565b606091505b50915091506000821415610556573d60208201fd5b949350505050565b6102188061056d6000396000f3fe60806040526004361061001e5760003560e01c80635c60da1b146100e1575b6000546040805160048152602481019091526020810180516001600160e01b031663076de25160e21b17905261005d916001600160a01b031690610112565b50600080546040516001600160a01b0390911690829036908083838082843760405192019450600093509091505080830381855af49150503d80600081146100c1576040519150601f19603f3d011682016040523d82523d6000602084013e6100c6565b606091505b505090506040513d6000823e8180156100dd573d82f35b3d82fd5b3480156100ed57600080fd5b506100f66101d4565b604080516001600160a01b039092168252519081900360200190f35b606060006060846001600160a01b0316846040518082805190602001908083835b602083106101525780518252601f199092019160209182019101610133565b6001836020036101000a038019825116818451168082178552505050505050905001915050600060405180830381855af49150503d80600081146101b2576040519150601f19603f3d011682016040523d82523d6000602084013e6101b7565b606091505b509150915060008214156101cc573d60208201fd5b949350505050565b6000546001600160a01b03168156fea265627a7a723158208e3e63485e5f7ae8cba3fa394e12885c029940469c7a173b8ff7745fabdad3b364736f6c63430005110032";
        cEtherDelegatorCreationCode = abi.encodePacked(cEtherDelegatorCreationCode, constructorData);
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, address(0), block.number));
        address proxy;

        assembly {
            proxy := create2(0, add(cEtherDelegatorCreationCode, 32), mload(cEtherDelegatorCreationCode), salt)
            if iszero(extcodesize(proxy)) {
                revert(0, "!CEther.")
            }
        }

        return proxy;
    }

    function deployCErc20(bytes calldata constructorData) external virtual returns (address) {

        (address underlying, address comptroller, , , , address implementation, , , ) = abi.decode(constructorData, (address, address, address, string, string, address, bytes, uint256, uint256));

        require(cErc20DelegateWhitelist[address(0)][implementation][false], "!CErc20Delegate");

        require(comptroller == msg.sender, "!Comptroller");

        bytes memory cErc20DelegatorCreationCode = hex"608060405234801561001057600080fd5b506040516107f53803806107f5833981810160405261012081101561003457600080fd5b81516020830151604080850151606086018051925194969395919493918201928464010000000082111561006757600080fd5b90830190602082018581111561007c57600080fd5b825164010000000081118282018810171561009657600080fd5b82525081516020918201929091019080838360005b838110156100c35781810151838201526020016100ab565b50505050905090810190601f1680156100f05780820380516001836020036101000a031916815260200191505b506040526020018051604051939291908464010000000082111561011357600080fd5b90830190602082018581111561012857600080fd5b825164010000000081118282018810171561014257600080fd5b82525081516020918201929091019080838360005b8381101561016f578181015183820152602001610157565b50505050905090810190601f16801561019c5780820380516001836020036101000a031916815260200191505b506040818152602083015192018051929491939192846401000000008211156101c457600080fd5b9083019060208201858111156101d957600080fd5b82516401000000008111828201881017156101f357600080fd5b82525081516020918201929091019080838360005b83811015610220578181015183820152602001610208565b50505050905090810190601f16801561024d5780820380516001836020036101000a031916815260200191505b50604081815260208381015193909101516001600160a01b03808e1660248501908152818e166044860152908c16606485015260c4840185905260e4840182905260e0608485019081528b516101048601528b519597509195506103b59489948f948f948f948f948f948d948d949260a4830192610124019189019080838360005b838110156102e75781810151838201526020016102cf565b50505050905090810190601f1680156103145780820380516001836020036101000a031916815260200191505b50838103825286518152865160209182019188019080838360005b8381101561034757818101518382015260200161032f565b50505050905090810190601f1680156103745780820380516001836020036101000a031916815260200191505b5060408051601f198184030181529190526020810180516001600160e01b0390811663a0b0d28960e01b17909152909a506104981698505050505050505050565b50610489848560008660405160240180846001600160a01b03166001600160a01b031681526020018315151515815260200180602001828103825283818151815260200191508051906020019080838360005b83811015610420578181015183820152602001610408565b50505050905090810190601f16801561044d5780820380516001836020036101000a031916815260200191505b5060408051601f198184030181529190526020810180516001600160e01b039081166350d85b7360e01b17909152909550610498169350505050565b5050505050505050505061055a565b606060006060846001600160a01b0316846040518082805190602001908083835b602083106104d85780518252601f1990920191602091820191016104b9565b6001836020036101000a038019825116818451168082178552505050505050905001915050600060405180830381855af49150503d8060008114610538576040519150601f19603f3d011682016040523d82523d6000602084013e61053d565b606091505b50915091506000821415610552573d60208201fd5b949350505050565b61028c806105696000396000f3fe60806040526004361061001e5760003560e01c80635c60da1b1461011e575b341561005b5760405162461bcd60e51b81526004018080602001828103825260378152602001806102216037913960400191505060405180910390fd5b6000546040805160048152602481019091526020810180516001600160e01b031663076de25160e21b17905261009a916001600160a01b03169061014f565b50600080546040516001600160a01b0390911690829036908083838082843760405192019450600093509091505080830381855af49150503d80600081146100fe576040519150601f19603f3d011682016040523d82523d6000602084013e610103565b606091505b505090506040513d6000823e81801561011a573d82f35b3d82fd5b34801561012a57600080fd5b50610133610211565b604080516001600160a01b039092168252519081900360200190f35b606060006060846001600160a01b0316846040518082805190602001908083835b6020831061018f5780518252601f199092019160209182019101610170565b6001836020036101000a038019825116818451168082178552505050505050905001915050600060405180830381855af49150503d80600081146101ef576040519150601f19603f3d011682016040523d82523d6000602084013e6101f4565b606091505b50915091506000821415610209573d60208201fd5b949350505050565b6000546001600160a01b03168156fe43457263323044656c656761746f723a66616c6c6261636b3a2063616e6e6f742073656e642076616c756520746f2066616c6c6261636ba265627a7a7231582005c7822f7294a2303680b0d2b051bee472cd65b928fd92bacf345e29e5b26c9f64736f6c63430005110032";
        cErc20DelegatorCreationCode = abi.encodePacked(cErc20DelegatorCreationCode, constructorData);
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, underlying, block.number));
        address proxy;

        assembly {
            proxy := create2(0, add(cErc20DelegatorCreationCode, 32), mload(cErc20DelegatorCreationCode), salt)
            if iszero(extcodesize(proxy)) {
                revert(0, "!CErc20")
            }
        }

        return proxy;
    }

    mapping(address => mapping(address => bool)) public comptrollerImplementationWhitelist;

    function _editComptrollerImplementationWhitelist(address[] calldata oldImplementations, address[] calldata newImplementations, bool[] calldata statuses) external onlyOwner {

        require(newImplementations.length > 0 && newImplementations.length == oldImplementations.length && newImplementations.length == statuses.length, "No Comptroller implementations supplied or array lengths not equal.");
        for (uint256 i = 0; i < newImplementations.length; i++) comptrollerImplementationWhitelist[oldImplementations[i]][newImplementations[i]] = statuses[i];
    }

    mapping(address => mapping(address => mapping(bool => bool))) public cErc20DelegateWhitelist;

    function _editCErc20DelegateWhitelist(address[] calldata oldImplementations, address[] calldata newImplementations, bool[] calldata allowResign, bool[] calldata statuses) external onlyOwner {

        require(newImplementations.length > 0 && newImplementations.length == oldImplementations.length && newImplementations.length == allowResign.length && newImplementations.length == statuses.length, "No CErc20Delegate implementations supplied or array lengths not equal.");
        for (uint256 i = 0; i < newImplementations.length; i++) cErc20DelegateWhitelist[oldImplementations[i]][newImplementations[i]][allowResign[i]] = statuses[i];
    }

    mapping(address => mapping(address => mapping(bool => bool))) public cEtherDelegateWhitelist;

    function _editCEtherDelegateWhitelist(address[] calldata oldImplementations, address[] calldata newImplementations, bool[] calldata allowResign, bool[] calldata statuses) external onlyOwner {

        require(newImplementations.length > 0 && newImplementations.length == oldImplementations.length && newImplementations.length == allowResign.length && newImplementations.length == statuses.length, "No CEtherDelegate implementations supplied or array lengths not equal.");
        for (uint256 i = 0; i < newImplementations.length; i++) cEtherDelegateWhitelist[oldImplementations[i]][newImplementations[i]][allowResign[i]] = statuses[i];
    }

    mapping(address => address) internal _latestComptrollerImplementation;

    function latestComptrollerImplementation(address oldImplementation) external view returns (address) {

        return _latestComptrollerImplementation[oldImplementation] != address(0) ? _latestComptrollerImplementation[oldImplementation] : oldImplementation;
    }

    function _setLatestComptrollerImplementation(address oldImplementation, address newImplementation) external onlyOwner {

        _latestComptrollerImplementation[oldImplementation] = newImplementation;
    }

    struct CDelegateUpgradeData {
        address implementation;
        bool allowResign;
        bytes becomeImplementationData;
    }

    mapping(address => CDelegateUpgradeData) public _latestCErc20Delegate;

    mapping(address => CDelegateUpgradeData) public _latestCEtherDelegate;

    function latestCErc20Delegate(address oldImplementation) external view returns (address, bool, bytes memory) {

        CDelegateUpgradeData memory data = _latestCErc20Delegate[oldImplementation];
        bytes memory emptyBytes;
        return data.implementation != address(0) ? (data.implementation, data.allowResign, data.becomeImplementationData) : (oldImplementation, false, emptyBytes);
    }

    function latestCEtherDelegate(address oldImplementation) external view returns (address, bool, bytes memory) {

        CDelegateUpgradeData memory data = _latestCEtherDelegate[oldImplementation];
        bytes memory emptyBytes;
        return data.implementation != address(0) ? (data.implementation, data.allowResign, data.becomeImplementationData) : (oldImplementation, false, emptyBytes);
    }

    function _setLatestCEtherDelegate(address oldImplementation, address newImplementation, bool allowResign, bytes calldata becomeImplementationData) external onlyOwner {

        _latestCEtherDelegate[oldImplementation] = CDelegateUpgradeData(newImplementation, allowResign, becomeImplementationData);
    }

    function _setLatestCErc20Delegate(address oldImplementation, address newImplementation, bool allowResign, bytes calldata becomeImplementationData) external onlyOwner {

        _latestCErc20Delegate[oldImplementation] = CDelegateUpgradeData(newImplementation, allowResign, becomeImplementationData);
    }

    mapping(address => int256) public customInterestFeeRates;

    function interestFeeRate() external view returns (uint256) {

        (bool success, bytes memory data) = msg.sender.staticcall(abi.encodeWithSignature("comptroller()"));

        if (success && data.length == 32) {
            (address comptroller) = abi.decode(data, (address));
            int256 customRate = customInterestFeeRates[comptroller];
            if (customRate > 0) return uint256(customRate);
            if (customRate < 0) return 0;
        }

        return defaultInterestFeeRate;
    }

    function _setCustomInterestFeeRate(address comptroller, int256 rate) external onlyOwner {

        require(rate <= 1e18, "!Interest fee");
        customInterestFeeRates[comptroller] = rate;
    }

    mapping(address => bool) public isGuardian;

    function _editGuardianWhitelist(address[] calldata accounts, bool[] calldata status) external onlyOwner {

        require(accounts.length > 0 && accounts.length == status.length, "!Array lengths");
        for (uint256 i = 0; i < accounts.length; i++) isGuardian[accounts[i]] = status[i];
    }

    modifier onlyGuardian {

        require(isGuardian[msg.sender], "!guardian.");
        _;
    }
}