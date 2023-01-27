
pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.7.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.7.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity ^0.7.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}// MIT

pragma solidity ^0.7.0;


interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);
}// MIT

pragma solidity ^0.7.0;


abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}// MIT

pragma solidity ^0.7.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() {
        _registerInterface(
            ERC1155Receiver(0).onERC1155Received.selector ^
            ERC1155Receiver(0).onERC1155BatchReceived.selector
        );
    }
}// MIT

pragma solidity ^0.7.0;


contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}// MIT

pragma solidity ^0.7.0;


interface IERC1155 is IERC165 {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}// MIT

pragma solidity ^0.7.0;

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
        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;


abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

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
}//GPL-3.0-only
pragma solidity ^0.7.0;

interface IEscrow {
    function setMakerDeposit(uint256 _offerId) external;

    function setNFTDeposit(uint256 _offerId) external;

    function withdrawDeposit(uint256 offerId, uint256 orderId) external;

    function withdrawNftDeposit(uint256 _nftOfferId, uint256 _nftOrderId) external;

    function freezeEscrow(address _account) external returns (bool);

    function setdOTCAddress(address _token) external returns (bool);

    function freezeOneDeposit(uint256 offerId, address _account) external returns (bool);

    function unFreezeOneDeposit(uint256 offerId, address _account) external returns (bool);

    function unFreezeEscrow(address _account) external returns (bool status);

    function cancelDeposit(
        uint256 offerId,
        address token,
        address maker,
        uint256 _amountToSend
    ) external returns (bool status);

    function cancelNftDeposit(uint256 nftOfferId) external;

    function removeOffer(uint256 offerId, address _account) external returns (bool status);

    function setNFTDOTCAddress(address _token) external returns (bool status);
}//GPL-3.0-only
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

interface IdOTC {

    struct Offer {
        bool isNft;
        address maker;
        uint256 offerId;
        uint256[] nftIds; // list nft ids
        bool fullyTaken;
        uint256 amountIn; // offer amount
        uint256 offerFee;
        uint256 unitPrice;
        uint256 amountOut; // the amount to be receive by the maker
        address nftAddress;
        uint256 expiryTime;
        uint256 offerPrice;
        OfferType offerType; // can be PARTIAL or FULL
        uint256[] nftAmounts;
        address escrowAddress;
        address specialAddress; // makes the offer avaiable for one account.
        address tokenInAddress; // Token to exchange for another
        uint256 availableAmount; // available amount
        address tokenOutAddress; // Token to receive by the maker
    }

    struct Order {
        uint256 offerId;
        uint256 amountToSend; // the amount the taker sends to the maker
        address takerAddress;
        uint256 amountToReceive;
        uint256 minExpectedAmount; // the amount the taker is to recieve
    }

    enum OfferType { PARTIAL, FULL }

    function getOfferOwner(uint256 offerId) external view returns (address owner);

    function getOffer(uint256 offerId) external view returns (Offer memory offer);

    function getTaker(uint256 orderId) external view returns (address taker);

    function getTakerOrders(uint256 orderId) external view returns (Order memory order);
}//GPL-3.0-only
pragma solidity ^0.7.0;

interface INFTdOTC {

    struct Offer {
        bool isNft;
        address maker;
        uint256 offerId;
        uint256[] nftIds; // list nft ids
        bool fullyTaken;
        uint256 amountIn; // offer amount
        uint256 offerFee;
        uint256 unitPrice;
        uint256 amountOut; // the amount to be receive by the maker
        address nftAddress;
        uint256 expiryTime;
        uint256 offerPrice;
        OfferType offerType; // can be PARTIAL or FULL
        uint256[] nftAmounts;
        address escrowAddress;
        address specialAddress; // makes the offer avaiable for one account.
        address tokenInAddress; // Token to exchange for another
        uint256 availableAmount; // available amount
        address tokenOutAddress; // Token to receive by the maker
    }

    struct NftOrder {
        uint256 offerId;
        uint256[] nftIds;
        uint256 amountPaid;
        uint256[] nftAmounts;
        address takerAddress;
    }

    enum OfferType { PARTIAL, FULL }

    function getNftOfferOwner(uint256 _nftOfferId) external view returns (address owner);

    function getNftOffer(uint256 _nftOfferId) external view returns (Offer memory offer);

    function getNftTaker(uint256 _nftOrderId) external view returns (address taker);

    function getNftOrders(uint256 _nftOrderId) external view returns (NftOrder memory order);
}//GPL-3.0-only
pragma solidity ^0.7.0;

contract SwarmDOTCEscrow is ERC1155Holder, IEscrow, AccessControl {
    using SafeMath for uint256;

    uint256 public constant BPSNUMBER = 10**27;
    bool public isFrozen = false;
    address internal dOTC;
    address internal nftDOTC;
    bytes32 public constant ESCROW_MANAGER_ROLE = keccak256("ESCROW_MANAGER_ROLE");
    bytes32 public constant NFT_ESCROW_MANAGER_ROLE = keccak256("NFT_ESCROW_MANAGER_ROLE");

    struct Deposit {
        uint256 offerId;
        address maker;
        uint256 amountDeposited;
        uint256[] nftIds;
        uint256[] nftAmounts;
        bool isFrozen;
    }
    mapping(uint256 => Deposit) private deposits;
    mapping(uint256 => Deposit) private nftDeposits;

    event offerFrozen(uint256 indexed offerId, address indexed offerOwner, address frozenBy);
    event offerUnFrozen(uint256 indexed offerId, address indexed offerOwner, address frozenBy);
    event EscrowFrozen(address indexed frozenBy, address calledBy);
    event UnFreezeEscrow(address indexed unFreezeBy, address calledBy);
    event offerRemove(uint256 indexed offerId, address indexed offerOwner, uint256 amountReverted, address frozenBy);
    event Withdraw(uint256 indexed offerId, uint256 indexed orderId, address indexed taker, uint256 amount);
    event WithdrawNFT(uint256 indexed nftOfferId, uint256 indexed nftOrderId, address indexed taker);
    event canceledNftDeposit(uint256 indexed nftOfferId, address nftAddress, address canceledBy);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setEscrowManager(address _escrowManager) public {
        grantRole(ESCROW_MANAGER_ROLE, _escrowManager);
    }

    function setNFTEscrowManager(address _escrowManager) public {
        grantRole(NFT_ESCROW_MANAGER_ROLE, _escrowManager);
    }

    function setMakerDeposit(uint256 _offerId) external override isEscrowFrozen onlyEscrowManager {
        uint256[] memory emptyArray;
        deposits[_offerId] = Deposit(
            _offerId,
            IdOTC(dOTC).getOfferOwner(_offerId),
            IdOTC(dOTC).getOffer(_offerId).amountIn,
            emptyArray,
            emptyArray,
            false
        );
    }

    function setNFTDeposit(uint256 _offerId) external override isEscrowFrozen onlyNftEscrowManager {
        nftDeposits[_offerId] = Deposit(
            _offerId,
            INFTdOTC(nftDOTC).getNftOfferOwner(_offerId),
            0,
            INFTdOTC(nftDOTC).getNftOffer(_offerId).nftIds,
            INFTdOTC(nftDOTC).getNftOffer(_offerId).nftAmounts,
            false
        );
    }


    function withdrawDeposit(uint256 offerId, uint256 orderId)
        external
        override
        isEscrowFrozen
        isDepositFrozen(offerId)
        onlyEscrowManager
    {
        address token = IdOTC(dOTC).getOffer(offerId).tokenInAddress;
        address _receiver = IdOTC(dOTC).getTakerOrders(orderId).takerAddress;
        uint256 standardAmount = IdOTC(dOTC).getTakerOrders(orderId).amountToReceive;
        uint256 minExpectedAmount = IdOTC(dOTC).getTakerOrders(orderId).minExpectedAmount;
        uint256 _amount = unstandardisedNumber(standardAmount, token);
        require(deposits[offerId].amountDeposited >= standardAmount, "Invalid Amount");
        require(minExpectedAmount <= standardAmount, "Invalid Transaction");
        deposits[offerId].amountDeposited -= standardAmount;
        safeInternalTransfer(token, _receiver, _amount);
        emit Withdraw(offerId, orderId, _receiver, _amount);
    }


    function withdrawNftDeposit(uint256 _nftOfferId, uint256 _nftOrderId)
        external
        override
        isEscrowFrozen
        isNftDepositFrozen(_nftOfferId)
        onlyNftEscrowManager
    {
        address _receiver = INFTdOTC(nftDOTC).getNftOrders(_nftOrderId).takerAddress;
        address _nftAddress = INFTdOTC(nftDOTC).getNftOffer(_nftOfferId).nftAddress;
        IERC1155(_nftAddress).setApprovalForAll(nftDOTC, true);
        emit WithdrawNFT(_nftOfferId, _nftOrderId, _receiver);
    }

    function cancelNftDeposit(uint256 nftOfferId) external override isEscrowFrozen onlyNftEscrowManager {
        address nftAddress = INFTdOTC(nftDOTC).getNftOffer(nftOfferId).nftAddress;
        IERC1155(nftAddress).setApprovalForAll(nftDOTC, true);
        emit canceledNftDeposit(nftOfferId, nftAddress, msg.sender);
    }

    function cancelDeposit(
        uint256 offerId,
        address token,
        address maker,
        uint256 _amountToSend
    ) external override onlyEscrowManager returns (bool status) {
        deposits[offerId].amountDeposited = 0;
        safeInternalTransfer(token, maker, _amountToSend);
        return true;
    }

    function safeInternalTransfer(
        address token,
        address _receiver,
        uint256 _amount
    ) internal {
        require(_amount != 0, "Amount is 0");
        require(ERC20(token).transfer(_receiver, _amount), "Transfer failed and reverted.");
    }


    function freezeEscrow(address _account) external override onlyEscrowManager returns (bool status) {
        isFrozen = true;
        emit EscrowFrozen(msg.sender, _account);
        return true;
    }

    function unFreezeEscrow(address _account) external override onlyEscrowManager returns (bool status) {
        isFrozen = false;
        emit UnFreezeEscrow(msg.sender, _account);
        return true;
    }

    function setdOTCAddress(address _token) external override onlyEscrowManager returns (bool status) {
        dOTC = _token;
        return true;
    }

    function setNFTDOTCAddress(address _token) external override onlyNftEscrowManager returns (bool status) {
        nftDOTC = _token;
        return true;
    }

    function freezeOneDeposit(uint256 offerId, address _account)
        external
        override
        onlyEscrowManager
        returns (bool status)
    {
        deposits[offerId].isFrozen = true;
        emit offerFrozen(offerId, deposits[offerId].maker, _account);
        return true;
    }

    function unFreezeOneDeposit(uint256 offerId, address _account)
        external
        override
        onlyEscrowManager
        returns (bool status)
    {
        deposits[offerId].isFrozen = false;
        emit offerUnFrozen(offerId, deposits[offerId].maker, _account);
        return true;
    }

    function removeOffer(uint256 offerId, address _account) external override onlyEscrowManager returns (bool status) {
        uint256 _amount = deposits[offerId].amountDeposited;
        deposits[offerId].isFrozen = true;
        deposits[offerId].amountDeposited = 0;
        safeInternalTransfer(IdOTC(dOTC).getOffer(offerId).tokenInAddress, deposits[offerId].maker, _amount);
        emit offerRemove(offerId, deposits[offerId].maker, _amount, _account);
        return true;
    }

    function standardiseNumber(uint256 amount, address _token) internal view returns (uint256) {
        uint8 decimal = ERC20(_token).decimals();
        return amount.mul(BPSNUMBER).div(10**decimal);
    }

    function unstandardisedNumber(uint256 _amount, address _token) internal view returns (uint256) {
        uint8 decimal = ERC20(_token).decimals();
        return _amount.mul(10**decimal).div(BPSNUMBER);
    }

    modifier isEscrowFrozen() {
        require(isFrozen == false, "Escrow is Frozen");
        _;
    }

    modifier onlyEscrowManager() {
        require(hasRole(ESCROW_MANAGER_ROLE, _msgSender()), "must have escrow manager role");
        _;
    }

    modifier onlyNftEscrowManager() {
        require(hasRole(NFT_ESCROW_MANAGER_ROLE, _msgSender()), "must have escrow manager role");
        _;
    }

    modifier isDepositFrozen(uint256 offerId) {
        require(deposits[offerId].isFrozen == false, "offer is frozen");
        _;
    }

    modifier isNftDepositFrozen(uint256 offerId) {
        require(nftDeposits[offerId].isFrozen == false, "offer is frozen");
        _;
    }
}