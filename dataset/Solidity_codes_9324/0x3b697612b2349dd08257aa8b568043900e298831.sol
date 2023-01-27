
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;


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
}// MIT

pragma solidity ^0.8.0;


contract FLYBYAdminAccess is AccessControl {

    bool private initAccess;
    event AdminRoleGranted(
        address indexed beneficiary,
        address indexed caller
    );

    event AdminRoleRemoved(
        address indexed beneficiary,
        address indexed caller
    );

    function initAccessControls(address _admin) public {

        require(!initAccess, "Already initialised");
        require(_admin != address(0), "Incorrect input");
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        initAccess = true;
    }

    function hasAdminRole(address _address) public view returns (bool) {

        return hasRole(DEFAULT_ADMIN_ROLE, _address);
    }

    function addAdminRole(address _address) external {

        grantRole(DEFAULT_ADMIN_ROLE, _address);
        emit AdminRoleGranted(_address, _msgSender());
    }

    function removeAdminRole(address _address) external {

        revokeRole(DEFAULT_ADMIN_ROLE, _address);
        emit AdminRoleRemoved(_address, _msgSender());
    }
}// MIT

pragma solidity ^0.8.0;


contract FLYBYAccessControls is FLYBYAdminAccess {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant SMART_CONTRACT_ROLE = keccak256("SMART_CONTRACT_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");


    event MinterRoleGranted(
        address indexed beneficiary,
        address indexed caller
    );

    event MinterRoleRemoved(
        address indexed beneficiary,
        address indexed caller
    );

    event OperatorRoleGranted(
        address indexed beneficiary,
        address indexed caller
    );

    event OperatorRoleRemoved(
        address indexed beneficiary,
        address indexed caller
    );

    event SmartContractRoleGranted(
        address indexed beneficiary,
        address indexed caller
    );

    event SmartContractRoleRemoved(
        address indexed beneficiary,
        address indexed caller
    );

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
        emit MinterRoleGranted(_address, _msgSender());
    }

    function removeMinterRole(address _address) external {

        revokeRole(MINTER_ROLE, _address);
        emit MinterRoleRemoved(_address, _msgSender());
    }

    function addSmartContractRole(address _address) external {

        grantRole(SMART_CONTRACT_ROLE, _address);
        emit SmartContractRoleGranted(_address, _msgSender());
    }

    function removeSmartContractRole(address _address) external {

        revokeRole(SMART_CONTRACT_ROLE, _address);
        emit SmartContractRoleRemoved(_address, _msgSender());
    }

    function addOperatorRole(address _address) external {

        grantRole(OPERATOR_ROLE, _address);
        emit OperatorRoleGranted(_address, _msgSender());
    }

    function removeOperatorRole(address _address) external {

        revokeRole(OPERATOR_ROLE, _address);
        emit OperatorRoleRemoved(_address, _msgSender());
    }
}// MIT

pragma solidity ^0.8.0;

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

        require(a <= uint128(type(uint128).max), "BoringMath: uint128 Overflow");
        c = uint128(a);
    }

    function to64(uint256 a) internal pure returns (uint64 c) {

        require(a <= uint64(type(uint64).max), "BoringMath: uint64 Overflow");
        c = uint64(a);
    }

    function to32(uint256 a) internal pure returns (uint32 c) {

        require(a <= uint32(type(uint32).max), "BoringMath: uint32 Overflow");
        c = uint32(a);
    }

    function to16(uint256 a) internal pure returns (uint16 c) {

        require(a <= uint16(type(uint16).max), "BoringMath: uint16 Overflow");
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
}// MIT

pragma solidity ^0.8.0;

contract SafeTransfer {


    address private constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

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
    }
    
    function _safeApprove(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: APPROVE_FAILED");
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
        require(success && (data.length == 0 || abi.decode(data, (bool))));
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
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: cannot transfer");
    }

    function _safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FROM_FAILED");
    }

    function _safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }

}// MIT

pragma solidity ^0.8.0;

interface IFlybyMarket {


    function init(bytes calldata data) external payable;

    function initMarket( bytes calldata data ) external;

    function marketTemplate() external view returns (uint256);


}// MIT

pragma solidity ^0.8.0;

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

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}// MIT

pragma solidity ^0.8.0;

interface ISpaceBoxFactory {

    function deploy(address masterContract, bytes calldata data, bool useCreate2) external payable returns (address cloneAddress) ;

    function masterContractApproved(address, address) external view returns (bool);

    function masterContractOf(address) external view returns (address);

    function setMasterContractApproval(address user, address masterContract, bool approved, uint8 v, bytes32 r, bytes32 s) external;

}// MIT

pragma solidity ^0.8.0;


contract FLYBYMarket is SafeTransfer {


    using BoringMath for uint256;
    using BoringMath128 for uint256;
    using BoringMath64 for uint256;

    FLYBYAccessControls public accessControls;
    bytes32 public constant MARKET_MINTER_ROLE = keccak256("MARKET_MINTER_ROLE");

    bool private initialised;
    struct Auction {
        bool exists;
        uint64 templateId;
        uint128 index;
    }

    address[] public auctions;

    uint256 public auctionTemplateId;

    ISpaceBoxFactory public spaceBox;
    
    mapping(uint256 => address) private auctionTemplates;
    mapping(address => uint256) private auctionTemplateToId;
    mapping(uint256 => uint256) public currentTemplateId;
    mapping(address => Auction) public auctionInfo;

    struct MarketFees {
        uint128 minimumFee;
        uint32 integratorFeePct;
    }

    MarketFees public marketFees;
    bool public locked;
    address payable public flybyDiv;
    event FlybyInitMarket(address sender);
    event AuctionTemplateAdded(address newAuction, uint256 templateId);
    event AuctionTemplateRemoved(address auction, uint256 templateId);
    event MarketCreated(address indexed owner, address indexed addr, address marketTemplate);
    
    function initFLYBYMarket(address _accessControls, address _spaceBox, address[] memory _templates) external {

        require(!initialised);
        require(_accessControls != address(0), "initFLYBYMarket: accessControls cannot be set to zero");
        require(_spaceBox != address(0), "initFLYBYMarket: spaceBox cannot be set to zero");

        accessControls = FLYBYAccessControls(_accessControls);
        spaceBox = ISpaceBoxFactory(_spaceBox);

        auctionTemplateId = 0;
        for(uint i = 0; i < _templates.length; i++) {
            _addAuctionTemplate(_templates[i]);
        }
        locked = true;
        initialised = true;
        emit FlybyInitMarket(msg.sender);
    }

    function setMinimumFee(uint256 _amount) external {

        require(  
            accessControls.hasAdminRole(msg.sender),
            "FLYBYMarket: Sender must be operator"
        );
        marketFees.minimumFee = BoringMath.to128(_amount);
    }

    function setLocked(bool _locked) external {

        require(
            accessControls.hasAdminRole(msg.sender),
            "FLYBYMarket: Sender must be admin"
        );
        locked = _locked;
    }

    function setIntegratorFeePct(uint256 _amount) external {

        require(
            accessControls.hasAdminRole(msg.sender),
            "FLYBYMarket: Sender must be operator"
        );
        require(_amount <= 1000, "FLYBYMarket: Percentage is out of 1000");
        marketFees.integratorFeePct = BoringMath.to32(_amount);
    }

    function setDividends(address payable _divaddr) external {

        require(accessControls.hasAdminRole(msg.sender), "FLYBYMarket.setDev: Sender must be operator");
        require(_divaddr != address(0));
        flybyDiv = _divaddr;
    }

    function setCurrentTemplateId(uint256 _templateType, uint256 _templateId) external {

        require(
            accessControls.hasAdminRole(msg.sender),
            "FLYBYMarket: Sender must be admin"
        );
        require(auctionTemplates[_templateId] != address(0), "FLYBYMarket: incorrect _templateId");
        require(IFlybyMarket(auctionTemplates[_templateId]).marketTemplate() == _templateType, "FLYBYMarket: incorrect _templateType");
        currentTemplateId[_templateType] = _templateId;
    }

    function hasMarketMinterRole(address _address) public view returns (bool) {

        return accessControls.hasRole(MARKET_MINTER_ROLE, _address);
    }

    function deployMarket(
        uint256 _templateId,
        address payable _integratorFeeAccount
    )
        public payable returns (address newMarket)
    {

        if (locked) {
            require(accessControls.hasAdminRole(msg.sender) 
                    || accessControls.hasMinterRole(msg.sender)
                    || hasMarketMinterRole(msg.sender),
                "FLYBYMarket: Sender must be minter if locked"
            );
        }

        MarketFees memory _marketFees = marketFees;
        address auctionTemplate = auctionTemplates[_templateId];
        require(msg.value >= uint256(_marketFees.minimumFee), "FLYBYMarket: Failed to transfer minimumFee");
        require(auctionTemplate != address(0), "FLYBYMarket: Auction template doesn't exist");
        uint256 integratorFee = 0;
        uint256 flybyFee = msg.value;
        if (_integratorFeeAccount != address(0) && _integratorFeeAccount != flybyDiv) {
            integratorFee = flybyFee * uint256(_marketFees.integratorFeePct) / 1000;
            flybyFee = flybyFee - integratorFee;
        }

        newMarket = spaceBox.deploy(auctionTemplate, "", false);
        auctionInfo[newMarket] = Auction(true, BoringMath.to64(_templateId), BoringMath.to128(auctions.length));
        auctions.push(newMarket);
        emit MarketCreated(msg.sender, newMarket, auctionTemplate);
        if (flybyFee > 0) {
            flybyDiv.transfer(flybyFee);
        }
        if (integratorFee > 0) {
            _integratorFeeAccount.transfer(integratorFee);
        }
    }

    function createMarket(
        uint256 _templateId,
        address _token,
        uint256 _tokenSupply,
        bytes calldata _data
    )
        external payable returns (address newMarket)
    {

        newMarket = deployMarket(_templateId, payable(msg.sender));
        if (_tokenSupply > 0) {
            _safeTransferFrom(_token, msg.sender, _tokenSupply);
            require(IERC20(_token).approve(newMarket, _tokenSupply), "1");
        }
        IFlybyMarket(newMarket).initMarket(_data);

        if (_tokenSupply > 0) {
            uint256 remainingBalance = IERC20(_token).balanceOf(address(this));
            if (remainingBalance > 0) {
                _safeTransfer(_token, msg.sender, remainingBalance);
            }
        }
        return newMarket;
    }

    function addAuctionTemplate(address _template) external {

        require(
            accessControls.hasAdminRole(msg.sender) ||
            accessControls.hasOperatorRole(msg.sender),
            "FLYBYMarket: Sender must be operator"
        );
        _addAuctionTemplate(_template);    
    }

    function removeAuctionTemplate(uint256 _templateId) external {

        require(
            accessControls.hasAdminRole(msg.sender) ||
            accessControls.hasOperatorRole(msg.sender),
            "FLYBYMarket: Sender must be operator"
        );
        address template = auctionTemplates[_templateId];
        uint256 templateType = IFlybyMarket(template).marketTemplate();
        if (currentTemplateId[templateType] == _templateId) {
            delete currentTemplateId[templateType];
        }   
        auctionTemplates[_templateId] = address(0);
        delete auctionTemplateToId[template];
        emit AuctionTemplateRemoved(template, _templateId);
    }

    function _addAuctionTemplate(address _template) internal {

        require(_template != address(0), "FLYBYMarket: Incorrect template");
        require(auctionTemplateToId[_template] == 0, "FLYBYMarket: Template already added");
        uint256 templateType = IFlybyMarket(_template).marketTemplate();
        require(templateType > 0, "FLYBYMarket: Incorrect template code ");
        auctionTemplateId++;

        auctionTemplates[auctionTemplateId] = _template;
        auctionTemplateToId[_template] = auctionTemplateId;
        currentTemplateId[templateType] = auctionTemplateId;
        emit AuctionTemplateAdded(_template, auctionTemplateId);
    }

    function getAuctionTemplate(uint256 _templateId) external view returns (address) {

        return auctionTemplates[_templateId];
    }
    function getTemplateId(address _auctionTemplate) external view returns (uint256) {

        return auctionTemplateToId[_auctionTemplate];
    }
    function numberOfAuctions() external view returns (uint) {

            return auctions.length;
        }
    function minimumFee() external view returns(uint128) {

        return marketFees.minimumFee;
    }

    function getMarkets() external view returns(address[] memory) {

        return auctions;
    }

    function getMarketTemplateId(address _auction) external view returns(uint64) {

        return auctionInfo[_auction].templateId;
    }
}