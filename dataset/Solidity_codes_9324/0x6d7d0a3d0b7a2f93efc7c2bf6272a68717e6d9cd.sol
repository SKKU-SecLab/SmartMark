
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

}// MIT

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {

    using Address for address;

    mapping(uint256 => mapping(address => uint256)) private _balances;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    string private _uri;

    constructor(string memory uri_) {
        _setURI(uri_);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function uri(uint256) public view virtual override returns (string memory) {

        return _uri;
    }

    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {

        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {

        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(_msgSender() != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {

        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {

        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {

        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {

        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function _setURI(string memory newuri) internal virtual {

        _uri = newuri;
    }

    function _mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {

        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][account] += amount;
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }

    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(
        address account,
        uint256 id,
        uint256 amount
    ) internal virtual {

        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 accountBalance = _balances[id][account];
        require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][account] = accountBalance - amount;
        }

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    function _burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {

        require(account != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 accountBalance = _balances[id][account];
            require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][account] = accountBalance - amount;
            }
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}


    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {

        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
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
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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
}// MIT
pragma solidity ^0.8.0;

interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

}// MIT
pragma solidity ^0.8.0;

interface IERC20 {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

}// MIT
pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT
pragma solidity ^0.8.0;


contract PolkaBridgeNFT is ERC1155, Ownable {

    constructor(string memory _uri) ERC1155(_uri) {
        _setURI(_uri);
    }

    function setURI(string memory uri_) 
        public onlyOwner {

        _setURI(uri_);
    }

    function mintNFT(address recipient_, uint256 id_, uint256 amount_)
        public onlyOwner {    

        _mint(recipient_, id_, amount_, '');
    }

    function multiMintNFT(address recipient_, uint256[] memory ids_, uint256[] memory amounts_)
        public onlyOwner {

        _mintBatch(recipient_, ids_, amounts_, '');
    }
}// MIT
pragma solidity ^0.8.0;


contract PolkaBridgeINO is Ownable, ReentrancyGuard, IERC1155Receiver {

    using SafeMath for uint256;
    using Strings for uint256;
    using Counters for Counters.Counter;
    address public immutable WETH;
    address payable Owner;
    Counters.Counter private tokenCounter;
    PolkaBridgeNFT public polkaBridgeNFT;
    string public name;
    string public symbol;

    constructor(
        PolkaBridgeNFT _polkaBridgeNFT,
        address payable _owner,
        address _WETH,
        string memory _name,
        string memory _symbol
    ) // string memory _uri
    {
        Owner = payable(_owner);
        WETH = _WETH;
        name = _name;
        symbol = _symbol;
        polkaBridgeNFT = _polkaBridgeNFT;

    }

    receive() external payable {}

    struct INOPool {
        uint256 Id;
        uint256 Begin;
        uint256 End;
        uint256 Type; // 1:public, 2:private
        uint256 AmountPBRRequire; //must e18,important when init
        uint256 LockDuration; //lock after purchase
        uint256 ActivedDate;
        uint256 StopDate;
        uint256 claimType; // 1: claim in PBR INO, 2: claim in other project
        bool IsActived;
        bool IsStopped;
        uint256[] PackageIds;
    }
    struct Package {
        uint256 Id;
        uint256 PoolId;
        uint256 TotalSoldCount;
        uint256 MinimumTokenSoldout;
        uint256 TotalItemCount;
        uint256 RatePerETH; // times 1e18
        address[] UsersPurchased;
    }
    struct User {
        uint256 Id;
        bool IsWhitelist;
        uint256 WhitelistDate;
        uint256 PurchaseTime;
        bool IsClaimed;
        uint256 TotalETHPurchase;
        uint256 PurchasedItemCount;
        uint256[] PurchasedPackageIds;
    }
    mapping(uint256 => mapping(address => User)) public whitelist; // (packageId, userId) -> listuser
    mapping(uint256 => mapping(address => bool)) public purchasecheck; // (packageId, userId) -> purchasecheck
    mapping(address => mapping(uint256 => User)) private users; // (userId, poolId) -> user
    INOPool[] pools;
    Package[] packages;

    function changeOwner(address payable _owner) external onlyOwner {

        Owner = payable(_owner);
    }



    function poolLength() external view returns (uint256) {

        return pools.length;
    }

    function packageLength() external view returns (uint256) {

        return packages.length;
    }

    function addWhitelist(address user, uint256 pid) public onlyOwner {

        uint256 poolIndex = pid.sub(1);
        uint256[] memory packageIds = pools[poolIndex].PackageIds;
        uint256 packagesLength = packageIds.length;
        for (uint256 i = 0; i < packagesLength; i++) {
            uint256 packageId = packageIds[i];
            whitelist[packageId][user].Id = pid;
            whitelist[packageId][user].IsWhitelist = true;
            whitelist[packageId][user].WhitelistDate = block.timestamp;
        }
    }

    function addMulWhitelist(address[] memory user, uint256 pid)
        public
        onlyOwner
    {

        uint256 poolIndex = pid.sub(1);
        uint256[] memory packageIds = pools[poolIndex].PackageIds;
        uint256 packagesLength = packageIds.length;
        for (uint256 i = 0; i < user.length; i++) {
            for (uint256 j = 0; j < packagesLength; j++) {
                uint256 packageId = packageIds[j];
                whitelist[packageId][user[i]].Id = pid;
                whitelist[packageId][user[i]].IsWhitelist = true;
                whitelist[packageId][user[i]].WhitelistDate = block.timestamp;
            }
        }
    }

    function updateWhitelist(
        address user,
        uint256 pid,
        bool isWhitelist
    ) public onlyOwner {

        uint256 poolIndex = pid.sub(1);
        uint256[] memory packageIds = pools[poolIndex].PackageIds;
        uint256 packagesLength = packageIds.length;
        for (uint256 i = 0; i < packagesLength; i++) {
            uint256 packageId = packageIds[i];
            whitelist[packageId][user].IsWhitelist = isWhitelist;
        }
    }

    function IsWhitelist(address user, uint256 pid) public view returns (bool) {

        uint256 poolIndex = pid.sub(1);
        uint256[] memory packageIds = pools[poolIndex].PackageIds;
        return whitelist[packageIds[0]][user].IsWhitelist;
    }

    function addPackageToPool(
        uint256 _PoolId,
        uint256 _MinimumTokenSoldout,
        uint256 _TotalItemCount,
        uint256 _RatePerETH
    ) public onlyOwner {

        uint256 id = packages.length.add(1);
        packages.push(
            Package({
                Id: id,
                PoolId: _PoolId,
                TotalSoldCount: 0,
                MinimumTokenSoldout: _MinimumTokenSoldout,
                TotalItemCount: _TotalItemCount,
                RatePerETH: _RatePerETH,
                UsersPurchased: new address[](0)
            })
        );
        uint256 poolIndex = _PoolId.sub(1);
        pools[poolIndex].PackageIds.push(id);
    }

    function addPool(
        uint256 _Begin,
        uint256 _End,
        uint256 _Type, //1:public, 2:private
        uint256 _AmountPBRRequire, //must e18,important when init
        uint256 _LockDuration, //lock after purchase
        uint256 _claimType
    ) public onlyOwner {

        pools.push(
            INOPool({
                Id: pools.length.add(1),
                Begin: _Begin,
                End: _End,
                Type: _Type, //1:public, 2:private
                AmountPBRRequire: _AmountPBRRequire, //must e18,important when init
                LockDuration: _LockDuration, //lock after purchase
                ActivedDate: 0,
                StopDate: 0,
                IsActived: true,
                IsStopped: false,
                claimType: _claimType,
                PackageIds: new uint256[](0)
            })
        );
    }

    function updatePool(
        uint256 pid,
        uint256 _Begin,
        uint256 _End,
        uint256 _Type,
        uint256 _AmountPBRRequire,
        uint256 _LockDuration,
        uint256 _claimType
    ) public onlyOwner {

        uint256 poolIndex = pid.sub(1);
        pools[poolIndex].claimType = _claimType;
        if (_Begin > 0) {
            pools[poolIndex].Begin = _Begin;
        }
        if (_End > 0) {
            pools[poolIndex].End = _End;
        }
        if (_Type > 0) {
            pools[poolIndex].Type = _Type;
        }
        if (_AmountPBRRequire > 0) {
            pools[poolIndex].AmountPBRRequire = _AmountPBRRequire;
        }
        if (_LockDuration > 0) {
            pools[poolIndex].LockDuration = _LockDuration;
        }
    }

    function stopPool(uint256 pid) public onlyOwner {

        uint256 poolIndex = pid.sub(1);
        pools[poolIndex].IsActived = false;
        pools[poolIndex].IsStopped = true;
        pools[poolIndex].StopDate = block.timestamp;
    }

    function activePool(uint256 pid) public onlyOwner {

        uint256 poolIndex = pid.sub(1);
        pools[poolIndex].IsActived = true;
        pools[poolIndex].IsStopped = false;
        pools[poolIndex].ActivedDate = block.timestamp;
        pools[poolIndex].StopDate = 0;
    }

    function updatePackage(
        uint256 _PackageId,
        uint256 _PoolId,
        uint256 _MinimumTokenSoldout,
        uint256 _TotalItemCount,
        uint256 _RatePerETH
    ) public onlyOwner {

        uint256 packageIndex = _PackageId.sub(1);
        packages[packageIndex].PoolId = _PoolId;
        if (_MinimumTokenSoldout > 0) {
            packages[packageIndex].MinimumTokenSoldout = _MinimumTokenSoldout;
        }
        if (_TotalItemCount > 0) {
            packages[packageIndex].TotalItemCount = _TotalItemCount;
        }
        if (_RatePerETH > 0) {
            packages[packageIndex].RatePerETH = _RatePerETH;
        }
    }

    function getBalanceItemByPackageId(uint256 packageId)
        public
        view
        returns (uint256)
    {

        uint256 packageIndex = packageId.sub(1);
        return packages[packageIndex].TotalItemCount;
    }

    function getRemainINOToken(uint256 packageId)
        public
        view
        returns (uint256)
    {

        uint256 packageIndex = packageId.sub(1);
        return
            packages[packageIndex].TotalItemCount.sub(
                packages[packageIndex].TotalSoldCount
            );
    }

    function purchaseINO(uint256 packageId, uint256 quantity)
        public
        payable
        nonReentrant
    {

        uint256 packageIndex = packageId.sub(1);
        uint256 poolId = packages[packageIndex].PoolId;
        uint256 poolIndex = poolId.sub(1);
        require(pools[poolIndex].IsActived, "invalid pool");
        require(
            block.timestamp >= pools[poolIndex].Begin &&
                block.timestamp <= pools[poolIndex].End,
            "invalid time"
        );
        if (pools[poolIndex].Type == 2)
            require(IsWhitelist(msg.sender, poolId), "invalid user");
        uint256 ethAmount = msg.value;
        uint256 calcItemAmount = ethAmount
            .mul(packages[packageIndex].RatePerETH)
            .div(1e18);
        require(calcItemAmount >= quantity, "insufficient funds");
        uint256 restETH;
        if (calcItemAmount > quantity)
            restETH =
                ethAmount -
                quantity
                    .mul(uint256(1).div(packages[packageIndex].RatePerETH))
                    .mul(1e18);
        uint256 remainToken = getRemainINOToken(packageId);
        require(
            remainToken > packages[packageIndex].MinimumTokenSoldout,
            "INO sold out"
        );
        require(remainToken >= quantity, "INO sold out");
        whitelist[packageId][msg.sender].TotalETHPurchase = whitelist[
            packageId
        ][msg.sender].TotalETHPurchase.add(ethAmount);
        whitelist[packageId][msg.sender].PurchasedItemCount = whitelist[
            packageId
        ][msg.sender].PurchasedItemCount.add(quantity);
        whitelist[packageId][msg.sender].PurchaseTime = block.timestamp;
        if (!purchasecheck[packageId][msg.sender]) {
            packages[packageIndex].UsersPurchased.push(msg.sender);
            purchasecheck[packageId][msg.sender] = true;
            users[msg.sender][poolId].PurchasedPackageIds.push(packageId);
        }
        packages[packageIndex].TotalSoldCount = packages[packageIndex]
            .TotalSoldCount
            .add(quantity);
        IWETH(WETH).deposit{value: ethAmount}();
        IWETH(WETH).withdraw(restETH);
        payable(msg.sender).transfer(restETH);
    }

    function claimPool(uint256 pid) public nonReentrant {

        uint256 poolIndex = pid.sub(1);
        require(pools[poolIndex].claimType == 1, "invalid claim");
        if (pools[poolIndex].Type == 2)
            require(IsWhitelist(msg.sender, pid), "invalid user");
        require(
            block.timestamp >
                pools[poolIndex].End.add(pools[poolIndex].LockDuration),
            "not on time for claiming NFTs"
        );
        uint256[] memory packageIds = users[msg.sender][pid]
            .PurchasedPackageIds;
        uint256 packagesLength = packageIds.length;
        require(
            !whitelist[packageIds[0]][msg.sender].IsClaimed,
            "user already claimed"
        );
        for (uint256 i = 0; i < packagesLength; i++) {
            uint256 packageId = packageIds[i];
            if (purchasecheck[packageId][msg.sender]) {
                uint256 itemCount = whitelist[packageId][msg.sender]
                    .PurchasedItemCount;
                IERC1155(polkaBridgeNFT).safeTransferFrom(
                    address(this),
                    msg.sender,
                    packageId,
                    itemCount,
                    ""
                );
                whitelist[packageId][msg.sender].IsClaimed = true;
            }
        }
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual returns (bytes4) {

        return this.onERC721Received.selector;
    }

    function supportsInterface(bytes4 interfaceId)
        external
        pure
        override
        returns (bool)
    {

        return interfaceId == this.supportsInterface.selector;
    }

    function getPoolInfo(uint256 pid)
        public
        view
        returns (INOPool memory retSt)
    {

        uint256 poolIndex = pid.sub(1);
        return pools[poolIndex];
    }

    function getPackageInfo(uint256 packageId)
        public
        view
        returns (Package memory retSt)
    {

        uint256 packageIndex = packageId.sub(1);
        return packages[packageIndex];
    }

    function getPurchasedPackageIds(address user_, uint256 pid)
        public
        view
        returns (uint256[] memory)
    {

        return users[user_][pid].PurchasedPackageIds;
    }

    function withdrawPoolFund() public onlyOwner {

        uint256 ETHbalance = IERC20(WETH).balanceOf(address(this));
        IWETH(WETH).withdraw(ETHbalance);
        Owner.transfer(ETHbalance);
    }

    function withdrawETHFund() public onlyOwner {

        uint256 balance = address(this).balance;
        require(balance > 0, "not enough fund");
        Owner.transfer(balance);
    }

    function withdrawErc20(IERC20 token) public {

        token.transfer(Owner, token.balanceOf(address(this)));
    }
}