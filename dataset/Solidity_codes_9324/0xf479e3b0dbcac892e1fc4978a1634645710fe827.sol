
pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// GPL-3.0-only
pragma solidity ^0.8.0;

library BytesLib {

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {

        require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }
    
    function toUint256(bytes memory _bytes, uint _start) internal pure returns (uint) {

        require(_bytes.length >= _start + 32, "toUint256_outOfBounds");
        uint tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toTuple128(bytes memory _bytes, uint256 _start) internal pure returns (uint, uint) {

        require(_bytes.length >= _start + 32, "toTuple16_outOfBounds");
        uint tempUint;
        uint n1;
        uint n2;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
            n1 := and(shr(0x80, tempUint), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            n2 := and(tempUint, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
        }

        return (n1, n2);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// GPL-3.0-only
pragma solidity ^0.8.0;

interface IChangeableVariables {

    event AddressChanged(string fieldName, address previousAddress, address newAddress);
    event ValueChanged(string fieldName, uint previousValue, uint newValue);
    event BoolValueChanged(string fieldName, bool previousValue, bool newValue);
}// GPL-3.0-only
pragma solidity ^0.8.0;


abstract contract BaseAccessControl is Context, IChangeableVariables {

    bytes32 public constant CEO_ROLE = keccak256("CEO");
    bytes32 public constant CFO_ROLE = keccak256("CFO");
    bytes32 public constant COO_ROLE = keccak256("COO");

    address private _accessControl;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    constructor (address accessControl) Context() {
        _accessControl = accessControl;
    }

    function accessControlAddress() public view returns (address) {
        return _accessControl;
    }

    function setAccessControlAddress(address newAddress) external onlyRole(CEO_ROLE) {
        address previousAddress = _accessControl;
        _accessControl = newAddress;
        emit AddressChanged("accessControl", previousAddress, newAddress);
    }

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return IAccessControl(accessControlAddress()).hasRole(role, account);
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }
}// GPL-3.0-only
pragma solidity ^0.8.0;


abstract contract LockableReceiver is BaseAccessControl, IERC721Receiver {
    
    using Address for address payable;

    address private _tokenContractAddress;
    mapping(uint => address) private _lockedTokens;

    event TokenLocked(uint tokenId, address indexed holder);
    event TokenWithdrawn(uint tokenId, address indexed holder);
    event EthersWithdrawn(address indexed operator, address indexed to, uint amount);

    constructor (address accessControl, address tokenContractAddress) 
    BaseAccessControl(accessControl) {
        _tokenContractAddress = tokenContractAddress;
    }

    modifier whenLocked(uint tokenId) {
        require(isLocked(tokenId), "LockableReceiver: token must be locked");
        _;
    }

    modifier onlyHolder(uint tokenId) {
        require(holderOf(tokenId) == _msgSender(), "LockableReceiver: caller is not the token holder");
        _;
    }

    function onERC721Received(address operator, address /*from*/, uint /*tokenId*/, bytes calldata /*data*/) 
        external virtual override returns (bytes4) {
        require(operator == address(this), "LockableReceiver: the caller is not a valid operator");
        return this.onERC721Received.selector;
    }

    function receiveApproval(address sender, uint tokenId, address _tokenContract, bytes calldata data) external virtual {
        require(tokenContract() == _msgSender(), "LockableReceiver: not enough privileges to call the method");
        require(_tokenContract == tokenContract(), "LockableReceiver: unable to receive the given token");
    
        IERC721(tokenContract()).safeTransferFrom(sender, address(this), tokenId, data);
        
        _lock(tokenId, sender);
        processERC721(sender, tokenId, data);
    }

    function processERC721(address from, uint tokenId, bytes calldata data) internal virtual {
    }

    function _lock(uint tokenId, address holder) internal {
        _lockedTokens[tokenId] = holder;
        emit TokenLocked(tokenId, holder);
    }

    function _unlock(uint tokenId) internal {
        delete _lockedTokens[tokenId];
    }

    function tokenContract() public view returns (address) {
        return _tokenContractAddress;
    }

    function setTokenContract(address newAddress) external onlyRole(CEO_ROLE) {
        address previousAddress = _tokenContractAddress;
        _tokenContractAddress = newAddress;
        emit AddressChanged("tokenContract", previousAddress, newAddress);
    }

    function isLocked(uint tokenId) public view returns (bool) {
        return _lockedTokens[tokenId] != address(0);
    }

    function holderOf(uint tokenId) public view returns (address) {
        return _lockedTokens[tokenId];
    }

    function withdrawEthers(uint amount, address payable to) external virtual onlyRole(CFO_ROLE) {
        to.sendValue(amount);
        emit EthersWithdrawn(_msgSender(), to, amount);
    }

    function withdraw(uint tokenId) public virtual onlyHolder(tokenId) {
        _transferTokenToHolder(tokenId);
        emit TokenWithdrawn(tokenId, _msgSender());
    }

    function _transferTokenToHolder(uint tokenId) internal virtual {
        address holder = holderOf(tokenId);
        if (holder != address(0)) {
            IERC721(tokenContract()).safeTransferFrom(address(this), holder, tokenId);
            _unlock(tokenId);
        }
    }
}// GPL-3.0-only
pragma solidity ^0.8.0;


abstract contract BaseAuctionReceiver is LockableReceiver {
    
    enum PriceDirection { NONE, UP, DOWN }

    struct PriceSettings { 
        uint startingPrice;
        uint finalPrice;
        uint priceChangePeriod; //in hours
        uint priceChangeStep; 
        PriceDirection direction;
        uint timestampAddedAt; 
    }

    using SafeMath for uint;

    mapping(uint => PriceSettings) internal _priceSettings;
    uint private _fees100;

    constructor (address accessControl, address dragonToken, uint fees100) 
    LockableReceiver(accessControl, dragonToken) {
        _fees100 = fees100;
    }

    function weiMinPrice() internal virtual pure returns (uint) {
        return 0;
    }

    function maxTotalPeriod() internal virtual pure returns (uint) {
        return 0;
    }

    function numOfPriceChangesPerHour() internal virtual pure returns (uint) {
        return 60;
    }

    function feesPercent() public virtual view returns (uint) {
        return _fees100;
    }

    function updateFeesPercent(uint newFees100) external virtual onlyRole(CFO_ROLE) {
        _fees100 = newFees100;
    }

    function calcFees(uint weiAmount, uint fees100) internal virtual pure returns (uint) {
        return weiAmount.div(1e4).mul(fees100);
    }

    function readPriceSettings(bytes calldata data) internal virtual pure returns (uint, uint, uint) {
        uint weiStartingPrice = BytesLib.toUint256(data, 0);
        uint weiFinalPrice = BytesLib.toUint256(data, 0x20);
        uint totalPriceChangePeriod = BytesLib.toUint256(data, 0x40);
        return (weiStartingPrice, weiFinalPrice, totalPriceChangePeriod);
    } 

    function processERC721(address /*from*/, uint tokenId, bytes calldata data) 
        internal virtual override {

        (uint weiStartingPrice, uint weiFinalPrice, uint totalPriceChangePeriod) = 
            readPriceSettings(data);

        uint _weiMinPrice = weiMinPrice();
        uint _maxTotalPeriod = maxTotalPeriod();

        if (_weiMinPrice > 0) {
            require(weiStartingPrice >= _weiMinPrice && weiFinalPrice >= _weiMinPrice, 
                "BaseAuctionReceiver: the starting price and the final price cannot be less than weiMinPrice()");
        }
        if (_maxTotalPeriod > 0) {
            require(totalPriceChangePeriod <= _maxTotalPeriod, 
                "BaseAuctionReceiver: the price change period cannot exceed maxTotalPeriod()");
            require(totalPriceChangePeriod >= 12 && totalPriceChangePeriod.mod(12) == 0, 
                "BaseAuctionReceiver: the price change period should be a multiple of 0.5 days");
        }

        uint step;
        PriceDirection d;
        (step, d) = calcPriceChangeStep(
            weiStartingPrice, weiFinalPrice, totalPriceChangePeriod, numOfPriceChangesPerHour());
        PriceSettings memory settings = PriceSettings ({
            startingPrice: weiStartingPrice,
            finalPrice: weiFinalPrice,
            priceChangePeriod: totalPriceChangePeriod,
            priceChangeStep: step,
            direction: d,
            timestampAddedAt: block.timestamp
        });
        _priceSettings[tokenId] = settings;
    }

    function priceSettingsOf(uint tokenId) public view returns (PriceSettings memory) {
        return _priceSettings[tokenId];
    }

    function priceOf(uint tokenId) public view returns (uint) {
        PriceSettings memory settings = priceSettingsOf(tokenId);
        if (settings.direction == PriceDirection.NONE) {
            return settings.startingPrice;
        }

        uint max = Math.max(settings.startingPrice, settings.finalPrice);
        uint min = Math.min(settings.startingPrice, settings.finalPrice);
        uint diff = max.sub(min);

        uint totalNumOfPeriodsToFinalPrice = diff.div(settings.priceChangeStep);
        uint numOfPeriods = 
            (block.timestamp - settings.timestampAddedAt).div(60)
            .mul(numOfPriceChangesPerHour()).div(60);

        uint result;
        if (numOfPeriods > totalNumOfPeriodsToFinalPrice) {
            result = settings.finalPrice;
        }
        else if (settings.direction == PriceDirection.DOWN) {
            result = settings.startingPrice.sub(settings.priceChangeStep.mul(numOfPeriods));
        }
        else {
            result = settings.startingPrice.add(settings.priceChangeStep.mul(numOfPeriods));
        }
        return result;
    }

    function calcPriceChangeStep(
        uint weiStartingPrice, 
        uint weiFinalPrice, 
        uint totalPriceChangePeriod,
        uint _numOfPriceChangesPerHour) internal virtual pure returns (uint, PriceDirection) {

        if (weiStartingPrice == weiFinalPrice) {
            return (0, PriceDirection.NONE);
        }

        uint max = Math.max(weiStartingPrice, weiFinalPrice);
        uint min = Math.min(weiStartingPrice, weiFinalPrice);
        uint diff = max.sub(min);
        PriceDirection direction = PriceDirection.DOWN;
        if (max == weiFinalPrice) {
            direction = PriceDirection.UP;
        }
        return (diff.div(totalPriceChangePeriod.mul(_numOfPriceChangesPerHour)), direction);
    }

    function withdraw(uint tokenId) public virtual override onlyHolder(tokenId) {
        delete _priceSettings[tokenId];
        super.withdraw(tokenId);
    }
}// GPL-3.0-only
pragma solidity ^0.8.0;

library DragonInfo {

    
    uint constant MASK = 0xF000000000000000000000000;

    enum Types { 
        Unknown,
        Common, 
        Rare16, 
        Rare17, 
        Rare18, 
        Rare19,
        Epic20, 
        Epic21,
        Epic22,
        Epic23,
        Epic24, 
        Legendary
    }

    struct Details { 
        uint genes;
        uint eggId;
        uint parent1Id;
        uint parent2Id;
        uint generation;
        uint strength;
        Types dragonType;
    }

    function getDetails(uint value) internal pure returns (Details memory) {

        return Details (
            {
                genes: uint256(uint104(value)),
                parent1Id: uint256(uint32(value >> 104)),
                parent2Id: uint256(uint32(value >> 136)),
                generation: uint256(uint16(value >> 168)),
                strength: uint256(uint16(value >> 184)),
                dragonType: Types(uint16(value >> 200)),
                eggId: uint256(uint32(value >> 216))
            }
        );
    }

    function getValue(Details memory details) internal pure returns (uint) {

        uint result = uint(details.genes);
        result |= details.parent1Id << 104;
        result |= details.parent2Id << 136;
        result |= details.generation << 168;
        result |= details.strength << 184;
        result |= uint(details.dragonType) << 200;
        result |= details.eggId << 216;
        return result;
    }

    function calcType(uint genes) internal pure returns (Types) {

        uint mask = MASK;
        uint numRare = 0;
        uint numEpic = 0;
        for (uint i = 0; i < 10; i++) { //just Rare and Epic genes are important to check
            if (genes & mask > 0) {
                if (i < 5) { //Epic-range
                    numEpic++;
                }
                else { //Rare-range
                    numRare++;
                }
            }
            mask = mask >> 4;
        }
        Types result = Types.Unknown;
        if (numEpic == 5 && numRare == 5) {
            result = Types.Legendary;
        }
        else if (numEpic < 5 && numRare == 5) {
            result = Types(6 + numEpic);
        }
        else if (numEpic == 0 && numRare < 5) {
            result = Types(1 + numRare);
        }
        else if (numEpic == 0 && numRare == 0) {
            result = Types.Common;
        }

        return result;
    }

    function calcStrength(uint genes) internal pure returns (uint) {

        uint mask = MASK;
        uint strength = 0;
        for (uint i = 0; i < 25; i++) { 
            uint gLevel = (genes & mask) >> ((24 - i) * 4);
            if (i < 6) { //Epic
                strength += 3 * (25 - i) * gLevel;
            } 
            else if (i < 10) { //Rare 
                strength += 2 * (25 - i) * gLevel;
            }
            else { //Common-range
                if (gLevel > 0) {
                    strength += (25 - i) * gLevel;
                }
                else {
                    strength += (25 - i);
                }
            }
            mask = mask >> 4;
        }
        return strength;
    }

    function calcGeneration(uint g1, uint g2) internal pure returns (uint) {

        return (g1 >= g2 ? g1 : g2) + 1;
    }
}// GPL-3.0-only
pragma solidity ^0.8.0;

library Random {

    function rand(uint salt) internal view returns (uint) {

        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, salt)));
    }

    function randFrom(uint[] memory array, uint from, uint to, uint randomValue)
    internal pure returns (uint) {

        uint count = to - from;
        return array[from + randomValue % count];
    }

    function shuffle(uint[] memory array, uint randomValue) internal pure returns (uint[] memory) {

        for (uint i = 0; i < array.length; i++) {
            uint n = i + randomValue % (array.length - i);
            uint temp = array[n];
            array[n] = array[i];
            array[i] = temp;
        }
        return array;
    }
}// GPL-3.0-only
pragma solidity ^0.8.0;


library GenesLib {

    using SafeMath for uint;
    uint private constant MAGIC_NUM = 0x123456789ABCDEF;

    struct GenesRange {
        uint from;
        uint to;
    }

    function setGeneLevelTo(uint genes, uint level, uint position) internal pure returns (uint) {

        return genes | uint(level << (position * 4));
    }

    function geneLevelAt(uint genes, uint position) internal pure returns (uint) {

        return (genes >> (position * 4)) & 0xF;
    }

    function zeroGenePositionsInRange(uint genes, GenesRange memory range) 
    internal pure returns (uint, uint[] memory) {

        uint[] memory zeroPositions = new uint[](range.to - range.from);
        uint count = 0;
        for (uint pos = range.from; pos < range.to; pos++) {
            uint level = geneLevelAt(genes, pos);
            if (level == 0) {
                zeroPositions[count] = pos;
                count++;
            }
        }
        return (count, zeroPositions);
    }

    function randomGeneLevel(uint randomValue, bool includeZero) internal pure returns (uint) {

        if (includeZero) {
            return randomValue.mod(16);
        }
        else {
            return 1 + randomValue.mod(15);
        }
    }

    function randomInheritGenesInRange(uint genes, uint parent1Genes, uint parent2Genes,
        GenesRange memory range, uint randomValue, bool includeZero) internal pure returns (uint) {

        
        for (uint pos = range.from; pos < range.to; pos++) {
            uint geneLevel1 = geneLevelAt(parent1Genes, pos);
            uint geneLevel2 = geneLevelAt(parent2Genes, pos);

            if (includeZero || (geneLevel1 > 0 && geneLevel2 > 0)) {
                uint d = (pos % 2 == 0) ? ((randomValue >> pos) + (MAGIC_NUM >> pos)) : ~(randomValue >> pos);
                uint r = d.mod(100);
                
                if (r < 45) { //45%
                    genes = setGeneLevelTo(genes, geneLevel1, pos);
                }
                else if (r >= 45 && r < 90) { //45%
                    genes = setGeneLevelTo(genes, geneLevel2, pos);
                }
                else { //10%
                    uint level = randomGeneLevel(d, includeZero);
                    genes = setGeneLevelTo(genes, level, pos);
                }
            }
        }
        return genes;
    }

    function randomSetGenesToPositions(uint genes, uint[] memory positions, uint randomValue, bool includeZero) 
    internal pure returns (uint) {

        for (uint i = 0; i < positions.length; i++) {
            genes = setGeneLevelTo(genes, randomGeneLevel(
                (i % 2 > 0) ? ((randomValue >> i) + (MAGIC_NUM >> i)) : ~(randomValue >> i), 
                includeZero), positions[i]);
        }
        return genes;
    }

    function randomGenePositions(GenesRange memory range, uint count, uint randomValue) 
    internal pure returns (uint[] memory) {

        if (count > 0) {
            uint[] memory shuffledRangeArray = 
                Random.shuffle(createOrderedRangeArray(range.from, range.to), randomValue);
            uint[] memory positions = new uint[](count);
            for (uint i = 0; i < count; i++) {
                positions[i] = shuffledRangeArray[i];
            }
            return positions;
        }
        return new uint[](0);
    }

    function createOrderedRangeArray(uint from, uint to) internal pure returns (uint[] memory) {

        uint[] memory rangeArray = new uint[](to - from) ;
        for (uint i = 0; i < rangeArray.length; i++) {
            rangeArray[i] = from + i;
        }
        return rangeArray;
    }

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.0;

library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}// GPL-3.0-only
pragma solidity ^0.8.0;


contract DragonToken is ERC721, BaseAccessControl {

    using Address for address;
    using Counters for Counters.Counter;
    
    Counters.Counter private _dragonIds;

    mapping(uint => uint) private _info;
    mapping(uint => string) private _cids;

    string private _defaultMetadataCid;
    address private _dragonCreator;

    constructor(string memory defaultCid, address accessControl) 
    ERC721("CryptoDragons", "CD")
    BaseAccessControl(accessControl) {        
        _defaultMetadataCid = defaultCid;
    }

    function approveAndCall(address spender, uint256 tokenId, bytes calldata extraData) external returns (bool success) {
        _approve(spender, tokenId);
        (bool _success, ) = 
            spender.call(
                abi.encodeWithSignature("receiveApproval(address,uint256,address,bytes)", 
                _msgSender(), 
                tokenId, 
                address(this), 
                extraData) 
            );
        if(!_success) { 
            revert("DragonToken: spender internal error"); 
        }
        return true;
    }

    function tokenURI(uint tokenId) public view virtual override returns (string memory) {
        string memory cid = _cids[tokenId];
        return string(abi.encodePacked("ipfs://", (bytes(cid).length > 0) ? cid : defaultMetadataCid()));
    }

    function dragonCreatorAddress() public view returns(address) {
        return _dragonCreator;
    }

    function setDragonCreatorAddress(address newAddress) external onlyRole(CEO_ROLE) {
        address previousAddress = _dragonCreator;
        _dragonCreator = newAddress;
        emit AddressChanged("dragonCreator", previousAddress, newAddress);
    }

    function hasMetadataCid(uint tokenId) public view returns(bool) {
        return bytes(_cids[tokenId]).length > 0;
    }

    function setMetadataCid(uint tokenId, string calldata cid) external onlyRole(COO_ROLE) {
        require(bytes(cid).length >= 46, "DragonToken: bad CID");
        require(!hasMetadataCid(tokenId), "DragonToken: CID is already set");
        _cids[tokenId] = cid;
    }

    function defaultMetadataCid() public view returns (string memory){
        return _defaultMetadataCid;
    }

    function setDefaultMetadataCid(string calldata newDefaultCid) external onlyRole(COO_ROLE) {
        _defaultMetadataCid = newDefaultCid;
    }

    function dragonInfo(uint dragonId) public view returns (DragonInfo.Details memory) {
        return DragonInfo.getDetails(_info[dragonId]);
    }

    function strengthOf(uint dragonId) external view returns (uint) {
        DragonInfo.Details memory details = dragonInfo(dragonId);
        return details.strength > 0 ? details.strength : DragonInfo.calcStrength(details.genes);
    }

    function isSiblings(uint dragon1Id, uint dragon2Id) external view returns (bool) {
        DragonInfo.Details memory info1 = dragonInfo(dragon1Id);
        DragonInfo.Details memory info2 = dragonInfo(dragon2Id);
        return 
            (info1.generation > 1 && info2.generation > 1) && //the 1st generation of dragons doesn't have siblings
            (info1.parent1Id == info2.parent1Id || info1.parent1Id == info2.parent2Id || 
            info1.parent2Id == info2.parent1Id || info1.parent2Id == info2.parent2Id);
    }

    function isParent(uint dragon1Id, uint dragon2Id) external view returns (bool) {
        DragonInfo.Details memory info = dragonInfo(dragon1Id);
        return info.parent1Id == dragon2Id || info.parent2Id == dragon2Id;
    }

    function mint(address to, DragonInfo.Details calldata info) external returns (uint) {
        require(_msgSender() == dragonCreatorAddress(), "DragonToken: not enough privileges to call the method");
        
        _dragonIds.increment();
        uint newDragonId = uint(_dragonIds.current());
        
        _info[newDragonId] = DragonInfo.getValue(info);
        _mint(to, newDragonId);

        return newDragonId;
    }

    function setStrength(uint dragonId) external returns (uint) {
        DragonInfo.Details memory details = dragonInfo(dragonId);
        if (details.strength == 0) {
            details.strength = DragonInfo.calcStrength(details.genes);
            _info[dragonId] = DragonInfo.getValue(details);
        }
        return details.strength;
    }
}// GPL-3.0-only
pragma solidity ^0.8.0;


contract DragonCreator is BaseAccessControl {
    
    using Address for address;

    address private _tokenContractAddress;

    mapping(DragonInfo.Types => uint) private _zeroDragonsIssueLimits;
    mapping(address => bool) private _giveBirthCallers;

    bool private _isChangeOfIssueLimitsAllowed;

    event DragonCreated(
        uint dragonId, 
        uint eggId,
        uint parent1Id,
        uint parent2Id,
        uint generation,
        DragonInfo.Types t,
        uint genes,
        address indexed creator,
        address indexed to);

    constructor(address accessControl, address tknContract) BaseAccessControl(accessControl) {
        _tokenContractAddress = tknContract;
        _isChangeOfIssueLimitsAllowed = true;
    }

    function tokenContract() public view returns (address) {
        return _tokenContractAddress;
    }

    function setTokenContract(address newAddress) external onlyRole(CEO_ROLE) {
        address previousAddress = _tokenContractAddress;
        _tokenContractAddress = newAddress;
        emit AddressChanged("tokenContract", previousAddress, newAddress);
    }

    function isChangeOfIssueLimitsAllowed() public view returns (bool) {
        return _isChangeOfIssueLimitsAllowed;
    }

    function currentIssueLimitFor(DragonInfo.Types _dragonType) external view returns (uint) {
        return _zeroDragonsIssueLimits[_dragonType];
    }

    function updateIssueLimitFor(DragonInfo.Types _dragonType, uint newValue) external onlyRole(CEO_ROLE) {
        require(isChangeOfIssueLimitsAllowed(), 
            "DragonCreator: updating the issue limits is not allowed anymore");
        _zeroDragonsIssueLimits[_dragonType] = newValue;
    }

    function blockUpdatingIssueLimitsForever() external onlyRole(CEO_ROLE) {
        _isChangeOfIssueLimitsAllowed = false;
    }
    
    function setGiveBirthCallers(address[] calldata callers, bool value) external onlyRole(CEO_ROLE) {
        for (uint i = 0; i < callers.length; i++) {
            bool previousValue = _giveBirthCallers[callers[i]];
            _giveBirthCallers[callers[i]] = value;
            emit BoolValueChanged(string(abi.encodePacked("giveBirthCallers.", callers[i])), previousValue, value);
        }
    }

    function issue(uint genes, address to) external onlyRole(CEO_ROLE) returns (uint) {
        DragonInfo.Types dragonType = DragonInfo.calcType(genes);
        uint currentLimit = _zeroDragonsIssueLimits[dragonType];
        require(dragonType != DragonInfo.Types.Unknown, "DragonCreator: unable to identify a type of the given dragon");
        require(currentLimit > 0, "DragonCreator: the issue limit has exceeded");
        _zeroDragonsIssueLimits[dragonType] = currentLimit - 1;

        return _createDragon(0, 0, 0, genes, dragonType, to);
    }

    function giveBirth(uint eggId, uint genes, address to) external returns (uint) {
        require(_giveBirthCallers[_msgSender()], "DragonCreator: not enough privileges to call the method");    
        return _createDragon(eggId, 0, 0, genes, DragonInfo.Types.Unknown, to);
    }

    function giveBirth(uint parent1Id, uint parent2Id, uint genes, address to) external returns (uint) {
        require(_giveBirthCallers[_msgSender()], "DragonCreator: not enough privileges to call the method");
        return _createDragon(0, parent1Id, parent2Id, genes, DragonInfo.Types.Unknown, to);
    }

    function _createDragon(uint _eggId, uint _parent1Id, uint _parent2Id, uint _genes, DragonInfo.Types _dragonType, address to)
    internal returns (uint) {
        DragonToken dragonToken = DragonToken(tokenContract());
        DragonInfo.Details memory parent1Details = dragonToken.dragonInfo(_parent1Id);
        DragonInfo.Details memory parent2Details = dragonToken.dragonInfo(_parent2Id);

        if (_parent1Id > 0 && _parent2Id > 0) { //if not 1st-generation dragons
            require(_parent1Id != _parent2Id, "DragonCreator: parent dragons must be different");
            require(
                parent1Details.dragonType != DragonInfo.Types.Legendary 
                && parent2Details.dragonType != DragonInfo.Types.Legendary, 
                "DragonCreator: neither of the parent dragons can be of Legendary-type"
            );
            require(!dragonToken.isSiblings(_parent1Id, _parent2Id), "DragonCreator: the parent dragons must not be siblings");
            require(
                !dragonToken.isParent(_parent1Id, _parent2Id) && !dragonToken.isParent(_parent2Id, _parent1Id), 
                "DragonCreator: neither of the parent dragons must be a parent or child of another"
            );
        }

        DragonInfo.Details memory info = DragonInfo.Details({ 
            eggId: _eggId,
            parent1Id: _parent1Id,
            parent2Id: _parent2Id,
            generation: DragonInfo.calcGeneration(parent1Details.generation, parent2Details.generation),
            dragonType: (_dragonType == DragonInfo.Types.Unknown) ? DragonInfo.calcType(_genes) : _dragonType,
            strength: 0, //DragonInfo.calcStrength(_genes),
            genes: _genes
        });

        uint newDragonId = dragonToken.mint(to, info);
        
        emit DragonCreated(
            newDragonId, info.eggId,
            info.parent1Id, info.parent2Id, 
            info.generation, info.dragonType, 
            info.genes, _msgSender(), to);

        return newDragonId; 
    }
}// GPL-3.0-only
pragma solidity ^0.8.0;


contract DragonCrossbreed is BaseAuctionReceiver {

    using Address for address payable;

    uint constant HOURS_MAX_PERIOD = 24 * 100; //100 days
    uint constant THRESHOLD_DENOMINATOR = 100*1e8;

    uint[10] private _platformPrices;
    uint[10] private _bonusesCommonThresholds;
    uint[5] private _probabilityRareThresholds;
    uint[5] private _probabilityEpicThresholds;

    address private _dragonCreatorAddress;
    address private _dragonRandomnessAddress;

    mapping(address => uint) private _rewards;

    GenesLib.GenesRange private COMMON_RANGE;
    GenesLib.GenesRange private RARE_RANGE;
    GenesLib.GenesRange private EPIC_RANGE;

    event RewardAdded(address indexed operator, address indexed to, uint amount);
    event RewardClaimed(address indexed claimer, address indexed to, uint amount);

    constructor(
        address accessControl, 
        address dragonToken, 
        address dragonCreator, 
        uint fees100) BaseAuctionReceiver(accessControl, dragonToken, fees100) {
            
        _dragonCreatorAddress = dragonCreator;

        _platformPrices = [
            3*1e15, 5*1e15, 8*1e15, 10*1e15, 15*1e15, 
            20*1e15, 25*1e15, 30*1e15, 35*1e15, 40*1e15
        ];
        _bonusesCommonThresholds = [
            1953125, 3906250, 7812500, 15625000, 31250000,
            62500000, 125000000, 250000000, 500000000, 1000000000
        ];
        _probabilityRareThresholds = [1000000000, 500000000, 250000000, 125000000, 62500000];
        _probabilityEpicThresholds = [0, 15625000, 7812500, 3906250, 1953125];

        COMMON_RANGE = GenesLib.GenesRange({from: 0, to: 15});
        RARE_RANGE = GenesLib.GenesRange({from: 15, to: 20});
        EPIC_RANGE = GenesLib.GenesRange({from: 20, to: 25});
    }

    function maxTotalPeriod() internal override virtual pure returns (uint) {
        return HOURS_MAX_PERIOD;
    }

    function numOfPriceChangesPerHour() internal override virtual pure returns (uint) {
        return 30;
    }

    function dragonCreatorAddress() public view returns (address) {
        return _dragonCreatorAddress;
    }

    function setDragonCreatorAddress(address newAddress) external onlyRole(CEO_ROLE) {
        address previousAddress = _dragonCreatorAddress;
        _dragonCreatorAddress = newAddress;
        emit AddressChanged("dragonCreator", previousAddress, newAddress);
    }

    function platformPrice(uint genesCount) public view returns (uint) {
        return _platformPrices[genesCount];
    }

    function setPlatformPrices(uint[10] calldata newPlatformPrices) external onlyRole(CFO_ROLE) {
        _platformPrices = newPlatformPrices;
    }

    function bonusCommonThresholdAt(uint index) external view returns (uint) {
        return _bonusesCommonThresholds[index];
    } 

    function setBonusCommonThreshold(uint[10] calldata newBonusesCommonThresholds) external onlyRole(CFO_ROLE) {
        _bonusesCommonThresholds = newBonusesCommonThresholds;
    }

    function probabilityRareThresholdAt(uint index) external view returns (uint) {
        return _probabilityRareThresholds[index];
    } 

    function setProbabilityRareThreshold(uint[5] calldata newProbabilityRareThresholds) external onlyRole(CFO_ROLE) {
        _probabilityRareThresholds = newProbabilityRareThresholds;
    }

    function probabilityEpicThresholdAt(uint index) external view returns (uint) {
        return _probabilityEpicThresholds[index];
    } 

    function setProbabilityEpicThreshold(uint[5] calldata newProbabilityEpicThresholds) external onlyRole(CFO_ROLE) {
        _probabilityEpicThresholds = newProbabilityEpicThresholds;
    }

    function crossbreedPlatformPrice(uint dragon1Id, uint dragon2Id) external view returns (uint) {
        DragonToken dragonToken = DragonToken(tokenContract());
        uint genes1 = dragonToken.dragonInfo(dragon1Id).genes;
        uint genes2 = dragonToken.dragonInfo(dragon2Id).genes;
        (uint countRare, uint countEpic) = calcCommonRareEpicGenesCount(genes1, genes2);
        return platformPrice(countRare + countEpic);
    }

    function calcCommonRareEpicGenesCount(uint genes1, uint genes2) internal pure returns (uint, uint) {
        uint mask = DragonInfo.MASK;
        
        uint countRare = 0;
        uint countEpic = 0;

        for (uint i = 0; i < 10; i++) { //just Epic and Rare genes are important to count
            if (genes1 & mask > 0 && genes2 & mask > 0) {
                if (i < 5) {
                    countEpic++;
                }
                else {
                    countRare++;
                }
            }
            mask = mask >> 4;
        }
        return (countRare, countEpic);
    }

    function processERC721(address from, uint tokenId, bytes calldata data) 
        internal virtual override {
        DragonInfo.Details memory info = DragonToken(tokenContract()).dragonInfo(tokenId);
        require(info.dragonType != DragonInfo.Types.Legendary, "DragonCrossbreed: the dragon cannot be a Legendary-type");
        super.processERC721(from, tokenId, data);
    }

    function breed(uint myDragonId, uint anotherDragonId, uint salt) external payable {
        DragonToken dragonToken = DragonToken(tokenContract());

        require(
            dragonToken.ownerOf(myDragonId) == _msgSender(), 
            "DragonCrossbreed: the caller is not an owner of the dragon"
        );
        require(
            isLocked(anotherDragonId) || dragonToken.ownerOf(anotherDragonId) == _msgSender(), 
            "DragonCrossbreed: another dragon is not locked nor doesn't belong to the caller"
        );

        DragonInfo.Details memory parent1 = dragonToken.dragonInfo(myDragonId);
        DragonInfo.Details memory parent2 = dragonToken.dragonInfo(anotherDragonId);

        (uint countRare, uint countEpic) = calcCommonRareEpicGenesCount(parent1.genes, parent2.genes);
        uint _platformPrice = platformPrice(countRare + countEpic);
        uint _rentPrice = 0;
        if (isLocked(anotherDragonId)) {
            _rentPrice = priceOf(anotherDragonId);
        }
        require(msg.value >= (_platformPrice + _rentPrice), "DragonCrossbreed: incorrect amount sent to the contract");
        
        uint newGenes = 0;
        uint randomValue = Random.rand(salt);
        uint derivedRandomValue = Random.rand(randomValue ^ salt ^ block.difficulty);
        if (parent1.dragonType == DragonInfo.Types.Common && parent2.dragonType == DragonInfo.Types.Common) {
            (uint y, uint z) = _randomCountOfNewRareEpic(randomValue);
            if (y > 0) {
                uint[] memory positions = GenesLib.randomGenePositions(RARE_RANGE, y, randomValue);
                newGenes = GenesLib.randomSetGenesToPositions(newGenes, positions, randomValue, false);
            }
            if (z > 0) {
                uint[] memory positions = GenesLib.randomGenePositions(EPIC_RANGE, z, randomValue);
                newGenes = GenesLib.randomSetGenesToPositions(newGenes, positions, randomValue, false);
            }
            if (newGenes == 0 && _randomNewRare(0, derivedRandomValue)) { //if the bonuses above were not triggered
                uint[] memory positions = GenesLib.randomGenePositions(RARE_RANGE, 1, derivedRandomValue);
                newGenes = GenesLib.randomSetGenesToPositions(newGenes, positions, derivedRandomValue, false);
            }
            newGenes = GenesLib.randomInheritGenesInRange(newGenes, parent1.genes, parent2.genes, COMMON_RANGE, randomValue, true);
        }
        else if (parent1.dragonType == DragonInfo.Types.Epic20 && parent2.dragonType == DragonInfo.Types.Epic20) {
            uint[] memory positions = GenesLib.randomGenePositions(EPIC_RANGE, 1, randomValue);
            newGenes = GenesLib.randomSetGenesToPositions(newGenes, positions, randomValue, false);
            newGenes = GenesLib.randomInheritGenesInRange(newGenes, parent1.genes, parent2.genes, COMMON_RANGE, randomValue, true);
            newGenes = GenesLib.randomInheritGenesInRange(newGenes, parent1.genes, parent2.genes, RARE_RANGE, randomValue, false);
        }
        else {
            newGenes = GenesLib.randomInheritGenesInRange(newGenes, parent1.genes, parent2.genes, COMMON_RANGE, randomValue, true);
            newGenes = GenesLib.randomInheritGenesInRange(newGenes, parent1.genes, parent2.genes, RARE_RANGE, randomValue, false);
            newGenes = GenesLib.randomInheritGenesInRange(newGenes, parent1.genes, parent2.genes, EPIC_RANGE, randomValue, false);

            if (countRare < 5 && _randomNewRare(countRare, randomValue)) {
                (uint count, uint[] memory positions) = GenesLib.zeroGenePositionsInRange(newGenes, RARE_RANGE);
                uint pos = Random.randFrom(positions, 0, count, derivedRandomValue);
                newGenes = GenesLib.setGeneLevelTo(newGenes, GenesLib.randomGeneLevel(derivedRandomValue, false), pos);
            }
            else if (countRare == 5 && countEpic < 5 && _randomNewEpic(countEpic, randomValue)) {
                (uint count, uint[] memory positions) = GenesLib.zeroGenePositionsInRange(newGenes, EPIC_RANGE);
                uint pos = Random.randFrom(positions, 0, count, derivedRandomValue);
                newGenes = GenesLib.setGeneLevelTo(newGenes, GenesLib.randomGeneLevel(derivedRandomValue, false), pos);
            }
        }

        if (_rentPrice > 0) {
            payable(holderOf(anotherDragonId))
                .sendValue(_rentPrice - calcFees(_rentPrice, feesPercent()));
        }
        DragonCreator(dragonCreatorAddress()).giveBirth(myDragonId, anotherDragonId, newGenes, _msgSender());
    }

    function addReward(address to, uint amount) external onlyRole(COO_ROLE) {
        require(!Address.isContract(to), "DragonCrossbreed: address cannot be contract");
        _rewards[to] += amount;
        emit RewardAdded(_msgSender(), to, amount);
    }

    function claimReward(address payable to, uint amount) external {
        require(!Address.isContract(to), "DragonCrossbreed: address cannot be contract");
        require(amount <= _rewards[_msgSender()], "DragonCrossbreed: the given amount exceeded the allowed reward");
        
        to.sendValue(amount);
        _rewards[_msgSender()] -= amount;

        emit RewardClaimed(_msgSender(), to, amount);
    }

    function _randomCountOfNewRareEpic(uint randomValue) internal view returns (uint, uint) {
        uint r = randomValue % THRESHOLD_DENOMINATOR;
        return 
            (r <= _bonusesCommonThresholds[0]) ? (5, 5) :
            (r <= _bonusesCommonThresholds[1]) ? (5, 4) :
            (r <= _bonusesCommonThresholds[2]) ? (5, 3) :
            (r <= _bonusesCommonThresholds[3]) ? (5, 2) :
            (r <= _bonusesCommonThresholds[4]) ? (5, 1) :
            (r <= _bonusesCommonThresholds[5]) ? (5, 0) :
            (r <= _bonusesCommonThresholds[6]) ? (4, 0) :
            (r <= _bonusesCommonThresholds[7]) ? (3, 0) :
            (r <= _bonusesCommonThresholds[8]) ? (2, 0) :
            (r <= _bonusesCommonThresholds[9]) ? (1, 0) :
            (0, 0);
    }

    function _randomNewRare(uint currentRareCount, uint randomValue) internal view returns (bool) {
        uint r = randomValue % THRESHOLD_DENOMINATOR;
        return r < _probabilityRareThresholds[currentRareCount];
    }

    function _randomNewEpic(uint currentEpicCount, uint randomValue) internal view returns (bool) {
        uint r = randomValue % THRESHOLD_DENOMINATOR;
        return r < _probabilityEpicThresholds[currentEpicCount];
    }
}