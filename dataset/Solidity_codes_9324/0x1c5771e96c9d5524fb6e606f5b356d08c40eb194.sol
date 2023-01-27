pragma solidity 0.6.12;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}pragma solidity 0.6.12;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}pragma solidity 0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}pragma solidity 0.6.12;


abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// GPL-3.0-only
pragma solidity 0.6.12;



contract MISOAdminAccess is AccessControl {


    bool private initAccess;

    constructor() public {
    }

    function initAccessControls(address _admin) public {

        require(!initAccess, "Already initialised");
        require(_admin != address(0), "Incorrect input");
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        initAccess = true;
    }


    function hasAdminRole(address _address) public  view returns (bool) {

        return hasRole(DEFAULT_ADMIN_ROLE, _address);
    }


    function addAdminRole(address _address) external {

        grantRole(DEFAULT_ADMIN_ROLE, _address);
    }

    function removeAdminRole(address _address) external {

        revokeRole(DEFAULT_ADMIN_ROLE, _address);
    }
}// GPL-3.0-only
pragma solidity 0.6.12;


contract MISOAccessControls is MISOAdminAccess {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant SMART_CONTRACT_ROLE = keccak256("SMART_CONTRACT_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    constructor() public {
    }



    function hasMinterRole(address _address) public view returns (bool) {

        return hasRole(MINTER_ROLE, _address);
    }

    function hasSmartContractRole(address _address) public view returns (bool) {

        return hasRole(SMART_CONTRACT_ROLE, _address);
    }

    function hasOperatorRole(address _address) public view returns (bool) {

        return hasRole(OPERATOR_ROLE, _address);
    }


    function addMinterRole(address _address) external {

        grantRole(MINTER_ROLE, _address);
    }

    function removeMinterRole(address _address) external {

        revokeRole(MINTER_ROLE, _address);
    }

    function addSmartContractRole(address _address) external {

        grantRole(SMART_CONTRACT_ROLE, _address);
    }

    function removeSmartContractRole(address _address) external {

        revokeRole(SMART_CONTRACT_ROLE, _address);
    }

    function addOperatorRole(address _address) external {

        grantRole(OPERATOR_ROLE, _address);
    }

    function removeOperatorRole(address _address) external {

        revokeRole(OPERATOR_ROLE, _address);
    }

}pragma solidity 0.6.12;

contract SafeTransfer {


    address private constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    event TokensWithdrawn(address token, address to, uint256 amount);

    function _safeTokenPayment(
        address _token,
        address payable _to,
        uint256 _amount
    ) internal {

        if (address(_token) == ETH_ADDRESS) {
            _safeTransferETH(_to,_amount );
        } else {
            _safeTransfer(_token, _to, _amount);
        }

        emit TokensWithdrawn(_token, _to, _amount);
    }


    function _tokenPayment(
        address _token,
        address payable _to,
        uint256 _amount
    ) internal {

        if (address(_token) == ETH_ADDRESS) {
            _to.transfer(_amount);
        } else {
            _safeTransfer(_token, _to, _amount);
        }

        emit TokensWithdrawn(_token, _to, _amount);
    }


    function _safeApprove(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }


    function _safeTransfer(
        address token,
        address to,
        uint256 amount
    ) internal virtual {

        (bool success, bytes memory data) =
            token.call(
                abi.encodeWithSelector(0xa9059cbb, to, amount)
            );
        require(success && (data.length == 0 || abi.decode(data, (bool)))); // ERC20 Transfer failed
    }

    function _safeTransferFrom(
        address token,
        address from,
        uint256 amount
    ) internal virtual {

        (bool success, bytes memory data) =
            token.call(
                abi.encodeWithSelector(0x23b872dd, from, address(this), amount)
            );
        require(success && (data.length == 0 || abi.decode(data, (bool)))); // ERC20 TransferFrom failed
    }

    function _safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function _safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }


}pragma solidity 0.6.12;

interface IERC20 {

  function totalSupply() external view returns (uint256);


  function balanceOf(address account) external view returns (uint256);


  function allowance(address owner, address spender) external view returns (uint256);


  function approve(address spender, uint256 amount) external returns (bool);


  function name() external view returns (string memory);


  function symbol() external view returns (string memory);


  function decimals() external view returns (uint8);


  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) external returns (bool);


  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

}pragma solidity 0.6.12;


library BoringERC20 {

    bytes4 private constant SIG_SYMBOL = 0x95d89b41; // symbol()
    bytes4 private constant SIG_NAME = 0x06fdde03; // name()
    bytes4 private constant SIG_DECIMALS = 0x313ce567; // decimals()
    bytes4 private constant SIG_TRANSFER = 0xa9059cbb; // transfer(address,uint256)
    bytes4 private constant SIG_TRANSFER_FROM = 0x23b872dd; // transferFrom(address,address,uint256)

    function safeSymbol(IERC20 token) internal view returns (string memory) {

        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_SYMBOL));
        return success && data.length > 0 ? abi.decode(data, (string)) : "???";
    }

    function safeName(IERC20 token) internal view returns (string memory) {

        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_NAME));
        return success && data.length > 0 ? abi.decode(data, (string)) : "???";
    }

    function safeDecimals(IERC20 token) internal view returns (uint8) {

        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_DECIMALS));
        return success && data.length == 32 ? abi.decode(data, (uint8)) : 18;
    }

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {

        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(SIG_TRANSFER, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "BoringERC20: Transfer failed");
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {

        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(SIG_TRANSFER_FROM, from, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "BoringERC20: TransferFrom failed");
    }
}pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;




contract BaseBoringBatchable {

    function _getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {

        if (_returnData.length < 68) return "Transaction reverted silently";

        assembly {
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string)); // All that remains is the revert string
    }

    function batch(bytes[] calldata calls, bool revertOnFail) external payable returns (bool[] memory successes, bytes[] memory results) {

        successes = new bool[](calls.length);
        results = new bytes[](calls.length);
        for (uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(calls[i]);
            require(success || !revertOnFail, _getRevertMsg(result));
            successes[i] = success;
            results[i] = result;
        }
    }
}

contract BoringBatchable is BaseBoringBatchable {

    function permitToken(
        IERC20 token,
        address from,
        address to,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {

        token.permit(from, to, amount, deadline, v, r, s);
    }
}pragma solidity 0.6.12;

library BoringMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        require(b == 0 || (c = a * b) / b == a, "BoringMath: Mul Overflow");
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {

        require(b > 0, "BoringMath: Div zero");
        c = a / b;
    }

    function to128(uint256 a) internal pure returns (uint128 c) {

        require(a <= uint128(-1), "BoringMath: uint128 Overflow");
        c = uint128(a);
    }

    function to64(uint256 a) internal pure returns (uint64 c) {

        require(a <= uint64(-1), "BoringMath: uint64 Overflow");
        c = uint64(a);
    }

    function to32(uint256 a) internal pure returns (uint32 c) {

        require(a <= uint32(-1), "BoringMath: uint32 Overflow");
        c = uint32(a);
    }

    function to16(uint256 a) internal pure returns (uint16 c) {

        require(a <= uint16(-1), "BoringMath: uint16 Overflow");
        c = uint16(a);
    }

}

library BoringMath128 {

    function add(uint128 a, uint128 b) internal pure returns (uint128 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint128 a, uint128 b) internal pure returns (uint128 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}

library BoringMath64 {

    function add(uint64 a, uint64 b) internal pure returns (uint64 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint64 a, uint64 b) internal pure returns (uint64 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}

library BoringMath32 {

    function add(uint32 a, uint32 b) internal pure returns (uint32 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}

library BoringMath16 {

    function add(uint16 a, uint16 b) internal pure returns (uint16 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint16 a, uint16 b) internal pure returns (uint16 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}pragma solidity 0.6.12;


contract Documents {


    struct Document {
        uint32 docIndex;    // Store the document name indexes
        uint64 lastModified; // Timestamp at which document details was last modified
        string data; // data of the document that exist off-chain
    }

    mapping(string => Document) internal _documents;
    mapping(string => uint32) internal _docIndexes;
    string[] _docNames;

    event DocumentRemoved(string indexed _name, string _data);
    event DocumentUpdated(string indexed _name, string _data);

    function _setDocument(string calldata _name, string calldata _data) internal {

        require(bytes(_name).length > 0, "Zero name is not allowed");
        require(bytes(_data).length > 0, "Should not be a empty data");
        if (_documents[_name].lastModified == uint64(0)) {
            _docNames.push(_name);
            _documents[_name].docIndex = uint32(_docNames.length);
        }
        _documents[_name] = Document(_documents[_name].docIndex, uint64(now), _data);
        emit DocumentUpdated(_name, _data);
    }


    function _removeDocument(string calldata _name) internal {

        require(_documents[_name].lastModified != uint64(0), "Document should exist");
        uint32 index = _documents[_name].docIndex - 1;
        if (index != _docNames.length - 1) {
            _docNames[index] = _docNames[_docNames.length - 1];
            _documents[_docNames[index]].docIndex = index + 1; 
        }
        _docNames.pop();
        emit DocumentRemoved(_name, _documents[_name].data);
        delete _documents[_name];
    }

    function getDocument(string calldata _name) external view returns (string memory, uint256) {

        return (
            _documents[_name].data,
            uint256(_documents[_name].lastModified)
        );
    }

    function getAllDocuments() external view returns (string[] memory) {

        return _docNames;
    }

    function getDocumentCount() external view returns (uint256) {

        return _docNames.length;
    }

    function getDocumentName(uint256 _index) external view returns (string memory) {

        require(_index < _docNames.length, "Index out of bounds");
        return _docNames[_index];
    }

}pragma solidity 0.6.12;


interface IPointList {

    function isInList(address account) external view returns (bool);

    function hasPoints(address account, uint256 amount) external view  returns (bool);

    function setPoints(
        address[] memory accounts,
        uint256[] memory amounts
    ) external; 

    function initPointList(address accessControl) external ;


}pragma solidity 0.6.12;

interface IMisoMarket {


    function init(bytes calldata data) external payable;

    function initMarket( bytes calldata data ) external;

    function marketTemplate() external view returns (uint256);


}pragma solidity 0.6.12;





contract DutchAuction is IMisoMarket, MISOAccessControls, BoringBatchable, SafeTransfer, Documents , ReentrancyGuard  {

    using BoringMath for uint256;
    using BoringMath128 for uint128;
    using BoringMath64 for uint64;
    using BoringERC20 for IERC20;

    uint256 public constant override marketTemplate = 2;
    address private constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    struct MarketInfo {
        uint64 startTime;
        uint64 endTime;
        uint128 totalTokens;
    }
    MarketInfo public marketInfo;

    struct MarketPrice {
        uint128 startPrice;
        uint128 minimumPrice;
    }
    MarketPrice public marketPrice;

    struct MarketStatus {
        uint128 commitmentsTotal;
        bool finalized;
        bool usePointList;
    }

    MarketStatus public marketStatus;

    address public auctionToken; 
    address public paymentCurrency;  
    address payable public wallet;  
    address public pointList;

    mapping(address => uint256) public commitments; 
    mapping(address => uint256) public claimed;

    event AuctionDeployed(address funder, address token, uint256 totalTokens, address paymentCurrency, address admin, address wallet);
    
    event AuctionTimeUpdated(uint256 startTime, uint256 endTime); 
    event AuctionPriceUpdated(uint256 startPrice, uint256 minimumPrice); 
    event AuctionWalletUpdated(address wallet); 
    event AuctionPointListUpdated(address pointList, bool enabled);

    event AddedCommitment(address addr, uint256 commitment);   
    event TokensWithdrawn(address token, address to, uint256 amount);
    
    event AuctionFinalized();
    event AuctionCancelled();

    function initAuction(
        address _funder,
        address _token,
        uint256 _totalTokens,
        uint256 _startTime,
        uint256 _endTime,
        address _paymentCurrency,
        uint256 _startPrice,
        uint256 _minimumPrice,
        address _admin,
        address _pointList,
        address payable _wallet
    ) public {

        require(_endTime < 10000000000, "DutchAuction: enter an unix timestamp in seconds, not miliseconds");
        require(_startTime >= block.timestamp, "DutchAuction: start time is before current time");
        require(_endTime > _startTime, "DutchAuction: end time must be older than start price");
        require(_totalTokens > 0,"DutchAuction: total tokens must be greater than zero");
        require(_startPrice > _minimumPrice, "DutchAuction: start price must be higher than minimum price");
        require(_minimumPrice > 0, "DutchAuction: minimum price must be greater than 0"); 
        require(_admin != address(0), "DutchAuction: admin is the zero address");
        require(_wallet != address(0), "DutchAuction: wallet is the zero address");
        require(IERC20(_token).decimals() == 18, "DutchAuction: Token does not have 18 decimals");
        if (_paymentCurrency != ETH_ADDRESS) {
            require(IERC20(_paymentCurrency).decimals() > 0, "DutchAuction: Payment currency is not ERC20");
        }

        marketInfo.startTime = BoringMath.to64(_startTime);
        marketInfo.endTime = BoringMath.to64(_endTime);
        marketInfo.totalTokens = BoringMath.to128(_totalTokens);

        marketPrice.startPrice = BoringMath.to128(_startPrice);
        marketPrice.minimumPrice = BoringMath.to128(_minimumPrice);

        auctionToken = _token;
        paymentCurrency = _paymentCurrency;
        wallet = _wallet;

        initAccessControls(_admin);

        _setList(_pointList);
        _safeTransferFrom(_token, _funder, _totalTokens);

        emit AuctionDeployed(_funder, _token, _totalTokens, _paymentCurrency, _admin, _wallet);
        emit AuctionTimeUpdated(_startTime, _endTime);
        emit AuctionPriceUpdated(_startPrice, _minimumPrice);
    }




    function tokenPrice() public view returns (uint256) {

        return uint256(marketStatus.commitmentsTotal)
            .mul(1e18).div(uint256(marketInfo.totalTokens));
    }

    function priceFunction() public view returns (uint256) {

        if (block.timestamp <= uint256(marketInfo.startTime)) {
            return uint256(marketPrice.startPrice);
        }
        if (block.timestamp >= uint256(marketInfo.endTime)) {
            return uint256(marketPrice.minimumPrice);
        }

        return _currentPrice();
    }

    function clearingPrice() public view returns (uint256) {


        uint256 _tokenPrice = tokenPrice();
        uint256 _currentPrice = priceFunction();
        return _tokenPrice > _currentPrice ? _tokenPrice : _currentPrice;

    }



    receive() external payable {
        revertBecauseUserDidNotProvideAgreement();
    }

    function marketParticipationAgreement() public pure returns (string memory) {

        return "I understand that I'm interacting with a smart contract. I understand that tokens committed are subject to the token issuer and local laws where applicable. I reviewed code of the smart contract and understand it fully. I agree to not hold developers or other people associated with the project liable for any losses or misunderstandings";
    }
    function revertBecauseUserDidNotProvideAgreement() internal pure {

        revert("No agreement provided, please review the smart contract before interacting with it");
    }

    function commitEth(
        address payable _beneficiary,
        bool readAndAgreedToMarketParticipationAgreement
    )
        public payable
    {

        require(paymentCurrency == ETH_ADDRESS, "DutchAuction: payment currency is not ETH address"); 
        if(readAndAgreedToMarketParticipationAgreement == false) {
            revertBecauseUserDidNotProvideAgreement();
        }
        uint256 ethToTransfer = calculateCommitment(msg.value);

        uint256 ethToRefund = msg.value.sub(ethToTransfer);
        if (ethToTransfer > 0) {
            _addCommitment(_beneficiary, ethToTransfer);
        }
        if (ethToRefund > 0) {
            _beneficiary.transfer(ethToRefund);
        }

        require(marketStatus.commitmentsTotal <= address(this).balance, "DutchAuction: The committed ETH exceeds the balance");
    }

    function commitTokens(uint256 _amount, bool readAndAgreedToMarketParticipationAgreement) public {

        commitTokensFrom(msg.sender, _amount, readAndAgreedToMarketParticipationAgreement);
    }


    function commitTokensFrom(
        address _from,
        uint256 _amount,
        bool readAndAgreedToMarketParticipationAgreement
    )
        public   nonReentrant  
    {

        require(address(paymentCurrency) != ETH_ADDRESS, "DutchAuction: Payment currency is not a token");
        if(readAndAgreedToMarketParticipationAgreement == false) {
            revertBecauseUserDidNotProvideAgreement();
        }
        uint256 tokensToTransfer = calculateCommitment(_amount);
        if (tokensToTransfer > 0) {
            _safeTransferFrom(paymentCurrency, msg.sender, tokensToTransfer);
            _addCommitment(_from, tokensToTransfer);
        }
    }

    function priceDrop() public view returns (uint256) {

        MarketInfo memory _marketInfo = marketInfo;
        MarketPrice memory _marketPrice = marketPrice;

        uint256 numerator = uint256(_marketPrice.startPrice.sub(_marketPrice.minimumPrice));
        uint256 denominator = uint256(_marketInfo.endTime.sub(_marketInfo.startTime));
        return numerator / denominator;
    }


    function tokensClaimable(address _user) public view returns (uint256 claimerCommitment) {

        if (commitments[_user] == 0) return 0;
        uint256 unclaimedTokens = IERC20(auctionToken).balanceOf(address(this));

        claimerCommitment = commitments[_user].mul(uint256(marketInfo.totalTokens)).div(uint256(marketStatus.commitmentsTotal));
        claimerCommitment = claimerCommitment.sub(claimed[_user]);

        if(claimerCommitment > unclaimedTokens){
            claimerCommitment = unclaimedTokens;
        }
    }

    function totalTokensCommitted() public view returns (uint256) {

        return uint256(marketStatus.commitmentsTotal).mul(1e18).div(clearingPrice());
    }

    function calculateCommitment(uint256 _commitment) public view returns (uint256 committed) {

        uint256 maxCommitment = uint256(marketInfo.totalTokens).mul(clearingPrice()).div(1e18);
        if (uint256(marketStatus.commitmentsTotal).add(_commitment) > maxCommitment) {
            return maxCommitment.sub(uint256(marketStatus.commitmentsTotal));
        }
        return _commitment;
    }

    function isOpen() public view returns (bool) {

        return block.timestamp >= uint256(marketInfo.startTime) && block.timestamp <= uint256(marketInfo.endTime);
    }

    function auctionSuccessful() public view returns (bool) {

        return tokenPrice() >= clearingPrice();
    }

    function auctionEnded() public view returns (bool) {

        return auctionSuccessful() || block.timestamp > uint256(marketInfo.endTime);
    }

    function finalized() public view returns (bool) {

        return marketStatus.finalized;
    }

    function finalizeTimeExpired() public view returns (bool) {

        return uint256(marketInfo.endTime) + 7 days < block.timestamp;
    }

    function _currentPrice() private view returns (uint256) {

        MarketInfo memory _marketInfo = marketInfo;
        MarketPrice memory _marketPrice = marketPrice;
        uint256 priceDiff = block.timestamp.sub(uint256(_marketInfo.startTime)).mul(
            uint256(_marketPrice.startPrice.sub(_marketPrice.minimumPrice))
        ) / uint256(_marketInfo.endTime.sub(_marketInfo.startTime));        
        return uint256(_marketPrice.startPrice).sub(priceDiff);
    }

    function _addCommitment(address _addr, uint256 _commitment) internal {

        require(block.timestamp >= uint256(marketInfo.startTime) && block.timestamp <= uint256(marketInfo.endTime), "DutchAuction: outside auction hours");
        MarketStatus storage status = marketStatus;
        
        uint256 newCommitment = commitments[_addr].add(_commitment);
        if (status.usePointList) {
            require(IPointList(pointList).hasPoints(_addr, newCommitment));
        }
        
        commitments[_addr] = newCommitment;
        status.commitmentsTotal = BoringMath.to128(uint256(status.commitmentsTotal).add(_commitment));
        emit AddedCommitment(_addr, _commitment);
    }




    function cancelAuction() public   nonReentrant  
    {

        require(hasAdminRole(msg.sender));
        MarketStatus storage status = marketStatus;
        require(!status.finalized, "DutchAuction: auction already finalized");
        require( uint256(status.commitmentsTotal) == 0, "DutchAuction: auction already committed" );
        _safeTokenPayment(auctionToken, wallet, uint256(marketInfo.totalTokens));
        status.finalized = true;
        
        emit AuctionCancelled();
    }

    function finalize() public   nonReentrant  
    {


        require(hasAdminRole(msg.sender) 
                || hasSmartContractRole(msg.sender) 
                || wallet == msg.sender
                || finalizeTimeExpired(), "DutchAuction: sender must be an admin");
        
        require(marketInfo.totalTokens > 0, "Not initialized");

        MarketStatus storage status = marketStatus;

        require(!status.finalized, "DutchAuction: auction already finalized");
        if (auctionSuccessful()) {
            _safeTokenPayment(paymentCurrency, wallet, uint256(status.commitmentsTotal));
        } else {
            require(block.timestamp > uint256(marketInfo.endTime), "DutchAuction: auction has not finished yet"); 
            _safeTokenPayment(auctionToken, wallet, uint256(marketInfo.totalTokens));
        }
        status.finalized = true;
        emit AuctionFinalized();
    }


    function withdrawTokens() public  {

        withdrawTokens(msg.sender);
    }

    function withdrawTokens(address payable beneficiary) public   nonReentrant  {

        if (auctionSuccessful()) {
            require(marketStatus.finalized, "DutchAuction: not finalized");
            uint256 tokensToClaim = tokensClaimable(beneficiary);
            require(tokensToClaim > 0, "DutchAuction: No tokens to claim"); 
            claimed[beneficiary] = claimed[beneficiary].add(tokensToClaim);
            _safeTokenPayment(auctionToken, beneficiary, tokensToClaim);
        } else {
            require(block.timestamp > uint256(marketInfo.endTime), "DutchAuction: auction has not finished yet");
            uint256 fundsCommitted = commitments[beneficiary];
            commitments[beneficiary] = 0; // Stop multiple withdrawals and free some gas
            _safeTokenPayment(paymentCurrency, beneficiary, fundsCommitted);
        }
    }



    function setDocument(string calldata _name, string calldata _data) external {

        require(hasAdminRole(msg.sender) );
        _setDocument( _name, _data);
    }

    function setDocuments(string[] calldata _name, string[] calldata _data) external {

        require(hasAdminRole(msg.sender) );
        uint256 numDocs = _name.length;
        for (uint256 i = 0; i < numDocs; i++) {
            _setDocument( _name[i], _data[i]);
        }
    }

    function removeDocument(string calldata _name) external {

        require(hasAdminRole(msg.sender));
        _removeDocument(_name);
    }




    function setList(address _list) external {

        require(hasAdminRole(msg.sender));
        _setList(_list);
    }

    function enableList(bool _status) external {

        require(hasAdminRole(msg.sender));
        marketStatus.usePointList = _status;

        emit AuctionPointListUpdated(pointList, marketStatus.usePointList);
    }

    function _setList(address _pointList) private {

        if (_pointList != address(0)) {
            pointList = _pointList;
            marketStatus.usePointList = true;
        }

        emit AuctionPointListUpdated(pointList, marketStatus.usePointList);
    }


    function setAuctionTime(uint256 _startTime, uint256 _endTime) external {

        require(hasAdminRole(msg.sender));
        require(_startTime < 10000000000, "DutchAuction: enter an unix timestamp in seconds, not miliseconds");
        require(_endTime < 10000000000, "DutchAuction: enter an unix timestamp in seconds, not miliseconds");
        require(_startTime >= block.timestamp, "DutchAuction: start time is before current time");
        require(_endTime > _startTime, "DutchAuction: end time must be older than start time");
        require(marketStatus.commitmentsTotal == 0, "DutchAuction: auction cannot have already started");

        marketInfo.startTime = BoringMath.to64(_startTime);
        marketInfo.endTime = BoringMath.to64(_endTime);
        
        emit AuctionTimeUpdated(_startTime,_endTime);
    }

    function setAuctionPrice(uint256 _startPrice, uint256 _minimumPrice) external {

        require(hasAdminRole(msg.sender));
        require(_startPrice > _minimumPrice, "DutchAuction: start price must be higher than minimum price");
        require(_minimumPrice > 0, "DutchAuction: minimum price must be greater than 0"); 
        require(marketStatus.commitmentsTotal == 0, "DutchAuction: auction cannot have already started");

        marketPrice.startPrice = BoringMath.to128(_startPrice);
        marketPrice.minimumPrice = BoringMath.to128(_minimumPrice);

        emit AuctionPriceUpdated(_startPrice,_minimumPrice);
    }

    function setAuctionWallet(address payable _wallet) external {

        require(hasAdminRole(msg.sender));
        require(_wallet != address(0), "DutchAuction: wallet is the zero address");

        wallet = _wallet;

        emit AuctionWalletUpdated(_wallet);
    }




    function init(bytes calldata _data) external override payable {


    }

    function initMarket(
        bytes calldata _data
    ) public override {

        (
        address _funder,
        address _token,
        uint256 _totalTokens,
        uint256 _startTime,
        uint256 _endTime,
        address _paymentCurrency,
        uint256 _startPrice,
        uint256 _minimumPrice,
        address _admin,
        address _pointList,
        address payable _wallet
        ) = abi.decode(_data, (
            address,
            address,
            uint256,
            uint256,
            uint256,
            address,
            uint256,
            uint256,
            address,
            address,
            address
        ));
        initAuction(_funder, _token, _totalTokens, _startTime, _endTime, _paymentCurrency, _startPrice, _minimumPrice, _admin, _pointList, _wallet);
    }

    function getAuctionInitData(
        address _funder,
        address _token,
        uint256 _totalTokens,
        uint256 _startTime,
        uint256 _endTime,
        address _paymentCurrency,
        uint256 _startPrice,
        uint256 _minimumPrice,
        address _admin,
        address _pointList,
        address payable _wallet
    )
        external 
        pure
        returns (bytes memory _data)
    {

            return abi.encode(
                _funder,
                _token,
                _totalTokens,
                _startTime,
                _endTime,
                _paymentCurrency,
                _startPrice,
                _minimumPrice,
                _admin,
                _pointList,
                _wallet
            );
    }
        
    function getBaseInformation() external view returns(
        address, 
        uint64,
        uint64,
        bool 
    ) {

        return (auctionToken, marketInfo.startTime, marketInfo.endTime, marketStatus.finalized);
    }

    function getTotalTokens() external view returns(uint256) {

        return uint256(marketInfo.totalTokens);
    }

}