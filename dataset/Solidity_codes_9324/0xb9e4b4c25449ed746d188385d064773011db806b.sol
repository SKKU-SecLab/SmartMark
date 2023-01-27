

pragma solidity ^0.5.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            return (address(0));
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        return ecrecover(hash, v, r, s);
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}


pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "role already has the account");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "role dosen't have the account");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        return role.bearer[account];
    }
}


pragma solidity ^0.5.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceID) external view returns (bool);

}

contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}


pragma solidity ^0.5.0;


interface IERC173 /* is ERC165 */ {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() external view returns (address);


    function transferOwnership(address _newOwner) external;

}

contract ERC173 is IERC173, ERC165  {

    address private _owner;

    constructor() public {
        _registerInterface(0x7f5828d0);
        _transferOwnership(msg.sender);
    }

    modifier onlyOwner() {

        require(msg.sender == owner(), "Must be owner");
        _;
    }

    function owner() public view returns (address) {

        return _owner;
    }

    function transferOwnership(address _newOwner) public onlyOwner() {

        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address _newOwner) internal {

        address previousOwner = owner();
	_owner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }
}


pragma solidity ^0.5.0;



contract Operatable is ERC173 {

    using Roles for Roles.Role;

    event OperatorAdded(address indexed account);
    event OperatorRemoved(address indexed account);

    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;
    Roles.Role private operators;

    constructor() public {
        operators.add(msg.sender);
        _paused = false;
    }

    modifier onlyOperator() {

        require(isOperator(msg.sender), "Must be operator");
        _;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function transferOwnership(address _newOwner) public onlyOperator() {

        _transferOwnership(_newOwner);
    }

    function isOperator(address account) public view returns (bool) {

        return operators.has(account);
    }

    function addOperator(address account) public onlyOperator() {

        operators.add(account);
        emit OperatorAdded(account);
    }

    function removeOperator(address account) public onlyOperator() {

        operators.remove(account);
        emit OperatorRemoved(account);
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    function pause() public onlyOperator() whenNotPaused() {

        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyOperator() whenPaused() {

        _paused = false;
        emit Unpaused(msg.sender);
    }

}


pragma solidity ^0.5.0;


contract Withdrawable {

    using Roles for Roles.Role;

    event WithdrawerAdded(address indexed account);
    event WithdrawerRemoved(address indexed account);

    Roles.Role private withdrawers;

    constructor() public {
        withdrawers.add(msg.sender);
    }

    modifier onlyWithdrawer() {

        require(isWithdrawer(msg.sender), "Must be withdrawer");
        _;
    }

    function isWithdrawer(address account) public view returns (bool) {

        return withdrawers.has(account);
    }

    function addWithdrawer(address account) public onlyWithdrawer() {

        withdrawers.add(account);
        emit WithdrawerAdded(account);
    }

    function removeWithdrawer(address account) public onlyWithdrawer() {

        withdrawers.remove(account);
        emit WithdrawerRemoved(account);
    }

    function withdrawEther() public onlyWithdrawer() {

        msg.sender.transfer(address(this).balance);
    }

}


pragma solidity ^0.5.0;

library Uint256 {


    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(a >= b, "subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "division by 0");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "modulo by 0");
        return a % b;
    }

    function toString(uint256 a) internal pure returns (string memory) {

        bytes32 retBytes32;
        uint256 len = 0;
        if (a == 0) {
            retBytes32 = "0";
            len++;
        } else {
            uint256 value = a;
            while (value > 0) {
                retBytes32 = bytes32(uint256(retBytes32) / (2 ** 8));
                retBytes32 |= bytes32(((value % 10) + 48) * 2 ** (8 * 31));
                value /= 10;
                len++;
            }
        }

        bytes memory ret = new bytes(len);
        uint256 i;

        for (i = 0; i < len; i++) {
            ret[i] = retBytes32[i];
        }
        return string(ret);
    }
}


pragma solidity 0.5.17;





interface GuildAsset {

    function getTotalVolume(uint16 _guildType) external view returns (uint256);

}

interface SPLGuildPool {

    function addEthToGuildPool(uint16 _guildType, address _purchaseBy) external payable;

}

interface IngameMoney {

    function hashTransactedAt(bytes32 _hash) external view returns(uint256);

    function buy(address payable _user, address payable _referrer, uint256 _referralBasisPoint, uint16 _guildType, bytes calldata _signature, bytes32 _hash) external payable;

}

contract SPLSPLGatewayV1 is Operatable, Withdrawable, IngameMoney {

    using Uint256 for uint256;
    struct Campaign {
        uint8 purchaseType;
        uint8 subPurchaseType;
        uint8 proxyPurchaseType;
    }

    uint8 constant PURCHASE_NORMAL = 0;
    uint8 constant PURCHASE_ETH_BACK = 1;
    uint8 constant PURCHASE_UP20 = 2;
    uint8 constant PURCHASE_REGULAR = 3;
    uint8 constant PURCHASE_ETH_BACK_UP20 = 4;

    Campaign public campaign;

    mapping(uint256 => bool) public payableOptions;
    address public validater;

    GuildAsset public guildAsset;
    SPLGuildPool public guildPool;
    uint256 public guildBasisPoint;

    uint256 constant BASE = 10000;
    uint256 private nonce;
    uint16 public chanceDenom;
    uint256 public ethBackBasisPoint;
    bytes private salt;
    mapping(bytes32 => uint256) private _hashTransactedAt;

    event Sold(
        address indexed user,
        address indexed referrer,
        uint8 purchaseType,
        uint256 grossValue,
        uint256 referralValue,
        uint256 guildValue,
        uint256 netValue,
        uint16 indexed guildType
    );

    event CampaignUpdated(
        uint8 purchaseType,
        uint8 subPurchaseType,
        uint8 proxyPurchaseType
    );

    event GuildBasisPointUpdated(
        uint256 guildBasisPoint
    );

    constructor(
        address _validater,
        address _guildAssetAddress,
        address payable _guildPoolAddress
    ) public payable {
        setValidater(_validater);
        setGuildAssetAddress(_guildAssetAddress);
        setGuildPoolAddress(_guildPoolAddress);
        setCampaign(0, 0, 0);
        updateGuildBasisPoint(1500);
        updateEthBackBasisPoint(5000);
        updateChance(25);
        salt = bytes("iiNg4uJulaa4Yoh7");

        nonce = 222;

        payableOptions[0.03 ether] = true;
        payableOptions[0.05 ether] = true;
        payableOptions[0.1 ether] = true;
        payableOptions[0.5 ether] = true;
        payableOptions[1 ether] = true;
        payableOptions[5 ether] = true;
        payableOptions[10 ether] = true;
    }

    function setValidater(address _varidater) public onlyOperator() {

        validater = _varidater;
    }

    function setPayableOption(uint256 _option, bool desired) external onlyOperator() {

        payableOptions[_option] = desired;
    }

    function setCampaign(
        uint8 _purchaseType,
        uint8 _subPurchaseType,
        uint8 _proxyPurchaseType
    )
        public
        onlyOperator()
    {

        campaign = Campaign(_purchaseType, _subPurchaseType, _proxyPurchaseType);
        emit CampaignUpdated(_purchaseType, _subPurchaseType, _proxyPurchaseType);
    }

    function setGuildAssetAddress(address _guildAssetAddress) public onlyOwner() {

        guildAsset = GuildAsset(_guildAssetAddress);
    }

    function setGuildPoolAddress(address payable _guildPoolAddress) public onlyOwner() {

        guildPool = SPLGuildPool(_guildPoolAddress);
    }

    function updateGuildBasisPoint(uint256 _newGuildBasisPoint) public onlyOwner() {

        guildBasisPoint = _newGuildBasisPoint;
        emit GuildBasisPointUpdated(
            guildBasisPoint
        );
    }

    function updateChance(uint16 _newchanceDenom) public onlyOperator() {

        chanceDenom = _newchanceDenom;
    }

    function updateEthBackBasisPoint(uint256 _ethBackBasisPoint) public onlyOperator() {

        ethBackBasisPoint = _ethBackBasisPoint;
    }

    function buy(
        address payable _user,
        address payable _referrer,
        uint256 _referralBasisPoint,
        uint16 _guildType,
        bytes memory _signature,
        bytes32 _hash
    )
        public
        payable
        whenNotPaused()
    {

        require(_referralBasisPoint + ethBackBasisPoint + guildBasisPoint <= BASE, "Invalid basis points");
        require(payableOptions[msg.value], "Invalid msg.value");
        require(validateSig(encodeData(_user, _referrer, _referralBasisPoint, _guildType), _signature), "Invalid signature");
        if (_hash != bytes32(0)) {
            recordHash(_hash);
        }
        uint8 purchaseType = campaign.proxyPurchaseType;
        uint256 netValue = msg.value;
        uint256 referralValue = _referrerBack(_referrer, _referralBasisPoint);
        uint256 guildValue = _guildPoolBack(_guildType);
        netValue = msg.value.sub(referralValue).sub(guildValue);

        emit Sold(
            _user,
            _referrer,
            purchaseType,
            msg.value,
            referralValue,
            guildValue,
            netValue,
            _guildType
        );
    }

    function buySPL(
        address payable _referrer,
        uint256 _referralBasisPoint,
        uint16 _guildType,
        bytes memory _signature
    )
        public
        payable
    {

        require(_referralBasisPoint + ethBackBasisPoint + guildBasisPoint <= BASE, "Invalid basis points");
        require(payableOptions[msg.value], "Invalid msg.value");
        require(validateSig(encodeData(msg.sender, _referrer, _referralBasisPoint, _guildType), _signature), "Invalid signature");

        uint8 purchaseType = campaign.purchaseType;
        uint256 netValue = msg.value;
        uint256 referralValue = 0;
        uint256 guildValue = 0;

        if (purchaseType == PURCHASE_ETH_BACK || purchaseType == PURCHASE_ETH_BACK_UP20) {
            if (getRandom(chanceDenom, nonce, msg.sender) == 0) {
                uint256 ethBackValue = _ethBack(msg.sender, ethBackBasisPoint);
                netValue = netValue.sub(ethBackValue);
            } else {
                purchaseType = campaign.subPurchaseType;
                referralValue = _referrerBack(_referrer, _referralBasisPoint);
                guildValue = _guildPoolBack(_guildType);
                netValue = msg.value.sub(referralValue).sub(guildValue);
            }
            nonce++;
        } else {
            referralValue = _referrerBack(_referrer, _referralBasisPoint);
            guildValue = _guildPoolBack(_guildType);
            netValue = msg.value.sub(referralValue).sub(guildValue);
        }

        emit Sold(
            msg.sender,
            _referrer,
            purchaseType,
            msg.value,
            referralValue,
            guildValue,
            netValue,
            _guildType
        );
    }

    function hashTransactedAt(bytes32 _hash) public view returns (uint256) {

        return _hashTransactedAt[_hash];
    }

    function recordHash(bytes32 _hash) internal {

        require(_hashTransactedAt[_hash] == 0, "The hash is already transacted");
        _hashTransactedAt[_hash] = block.number;
    }

    function getRandom(uint16 max, uint256 _nonce, address _sender) public view returns (uint16) {

        return uint16(
            bytes2(
                keccak256(
                    abi.encodePacked(
                        blockhash(block.number-1),
                        _sender,
                        _nonce,
                        salt
                    )
                )
            )
        ) % max;
    }

    function _ethBack(address payable _buyer, uint256 _ethBackBasisPoint) internal returns (uint256) {

        uint256 ethBackValue = msg.value.mul(_ethBackBasisPoint).div(BASE);
        _buyer.transfer(ethBackValue);
        return ethBackValue;
    }

    function _guildPoolBack(uint16 _guildType) internal returns (uint256) {

        if(_guildType == 0) {
            return 0;
        }
        require(guildAsset.getTotalVolume(_guildType) != 0, "Invalid _guildType");

        uint256 guildValue;
        guildValue = msg.value.mul(guildBasisPoint).div(BASE);
        guildPool.addEthToGuildPool.value(guildValue)(_guildType, msg.sender);
        return guildValue;
    }

    function _referrerBack(address payable _referrer, uint256 _referralBasisPoint) internal returns (uint256) {

        if(_referrer == address(0x0) || _referrer == msg.sender) {
            return 0;
        }
        uint256 referralValue = msg.value.mul(_referralBasisPoint).div(BASE);
        _referrer.transfer(referralValue);
        return referralValue;
    }

    function encodeData(address _sender, address _referrer, uint256 _referralBasisPoint, uint16 _guildType) public pure returns (bytes32) {

        return keccak256(abi.encode(
                            _sender,
                            _referrer,
                            _referralBasisPoint,
                            _guildType
                            )
                    );
    }

    function validateSig(bytes32 _message, bytes memory _signature) public view returns (bool) {

        require(validater != address(0), "validater must be set");
        address signer = ECDSA.recover(ECDSA.toEthSignedMessageHash(_message), _signature);
        return (signer == validater);
    }

    function recover(bytes32 _message, bytes memory _signature) public pure returns (address) {

        address signer = ECDSA.recover(ECDSA.toEthSignedMessageHash(_message), _signature);
        return signer;
    }
}