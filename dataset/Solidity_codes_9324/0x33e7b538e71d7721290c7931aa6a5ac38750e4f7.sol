
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

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


library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
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

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// MIT

pragma solidity 0.8.11;

interface IWhitelist {
    function whitelist(address _user) external view returns (bool);
}// MIT
pragma solidity 0.8.11;

contract TimeContract {
    function passed(uint _timestamp) internal view returns(bool) {
        return _timestamp < block.timestamp;
    }

    function notPassed(uint _timestamp) internal view returns(bool) {
        return !passed(_timestamp);
    }
}// MIT
pragma solidity 0.8.11;





contract PropyAuctionV2 is AccessControl, TimeContract {
    using SafeERC20 for IERC20;
    using Address for *;

    bytes32 public constant CONFIG_ROLE = keccak256('CONFIG_ROLE');
    bytes32 public constant FINALIZE_ROLE = keccak256('FINALIZE_ROLE');
    uint32 public constant BID_DEADLINE_EXTENSION = 15 minutes;
    uint32 public constant MAX_AUCTION_LENGTH = 30 days;
    IWhitelist public immutable whitelist;

    mapping(bytes32 => Auction) internal auctions;
    mapping(bytes32 => mapping(address => uint)) internal bids;
    mapping(address => uint) public unclaimed;

    struct Auction {
        uint128 minBid;
        uint32 deadline;
        uint32 finalizeTimeout;
        bool finalized;
    }

    event TokensRecovered(address token, address to, uint value);
    event Bid(IERC721 nft, uint nftId, uint32 start, address user, uint value);
    event Claimed(IERC721 nft, uint nftId, uint32 start, address user, uint value);
    event Withdrawn(address user, uint value);
    event Finalized(IERC721 nft, uint nftId, uint32 start, address winner, uint winnerBid);
    event AuctionAdded(IERC721 nft, uint nftId, uint32 start, uint32 deadline, uint128 minBid, uint32 timeout);
    event MinBidUpdated(IERC721 nft, uint nftId, uint32 start, uint128 minBid);
    event DeadlineExtended(IERC721 nft, uint nftId, uint32 start, uint32 deadline);

    modifier onlyWhitelisted() {
        require(whitelist.whitelist(_msgSender()), "Auction: User is not whitelisted");
        _;
    }

    constructor(
        address _owner,
        address _configurator,
        address _finalizer,
        IWhitelist _whitelist
    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        _grantRole(CONFIG_ROLE, _configurator);
        _grantRole(FINALIZE_ROLE, _finalizer);
        whitelist = _whitelist;
    }

    function _auctionId(IERC721 _nft, uint _nftId, uint32 _start) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(_nft, _nftId, _start));
    }

    function getAuction(IERC721 _nft, uint _nftId, uint32 _start) external view returns(Auction memory) {
        return auctions[_auctionId(_nft, _nftId, _start)];
    }

    function getBid(IERC721 _nft, uint _nftId, uint32 _start, address _bidder) public view returns(uint) {
        return bids[_auctionId(_nft, _nftId, _start)][_bidder];
    }

    function bid(IERC721 _nft, uint _nftId, uint32 _start) external payable virtual {
        _bid(_nft, _nftId, _start, msg.value);
    }

    function _bid(IERC721 _nft, uint _nftId, uint32 _start, uint _amount) internal onlyWhitelisted {
        require(_amount > 0, 'Auction: Zero bid not allowed');
        require(passed(_start), 'Auction: Not started yet');
        bytes32 id = _auctionId(_nft, _nftId, _start);
        Auction memory auction = auctions[id];

        require(auction.deadline > 0, 'Auction: Not found');
        require(notPassed(auction.deadline), 'Auction: Already finished');

        if (passed(auction.deadline - BID_DEADLINE_EXTENSION)) {
            uint32 newDeadline = uint32(block.timestamp) + BID_DEADLINE_EXTENSION;
            auctions[id].deadline = newDeadline;
            emit DeadlineExtended(_nft, _nftId, _start, newDeadline);
        }

        uint newBid = bids[id][_msgSender()] + _amount;
        require(newBid >= auction.minBid, 'Auction: Can not bid less than allowed');

        bids[id][_msgSender()] = newBid;
        emit Bid(_nft, _nftId, _start, _msgSender(), newBid);
    }

    function addAuction(IERC721 _nft, uint _nftId, uint32 _start, uint32 _deadline, uint128 _minBid, uint32 _finalizeTimeout) external onlyRole(CONFIG_ROLE) {
        require(_minBid > 0, 'Auction: Invalid min bid');
        require(notPassed(_start), 'Auction: Start should be more than current time');
        require(_deadline > _start, 'Auction: Deadline should be more than start time');
        require(MAX_AUCTION_LENGTH >= _deadline - _start, 'Auction: Auction time is more than max allowed');
        bytes32 id = _auctionId(_nft, _nftId, _start);
        Auction storage auction = auctions[id];
        require(auction.deadline == 0, 'Auction: Already added');

        auction.minBid = _minBid;
        auction.deadline = _deadline;
        auction.finalizeTimeout = _finalizeTimeout;

        emit AuctionAdded(_nft, _nftId, _start, _deadline, _minBid, _finalizeTimeout);
    }

    function updateMinBid(IERC721 _nft, uint _nftId, uint32 _start, uint128 _minBid) external onlyRole(CONFIG_ROLE) {
        require(_minBid > 0, 'Auction: Invalid min bid');
        Auction storage auction = auctions[_auctionId(_nft, _nftId, _start)];
        require(auction.deadline > 0, 'Auction: Not found');
        auction.minBid = _minBid;

        emit MinBidUpdated(_nft, _nftId, _start, _minBid);
    }

    function updateDeadline(IERC721 _nft, uint _nftId, uint32 _start, uint32 _deadline) external onlyRole(CONFIG_ROLE) {
        bytes32 id = _auctionId(_nft, _nftId, _start);
        Auction memory auction = auctions[id];
        require(auction.deadline > 0, 'Auction: Not found');
        require(_deadline > auction.deadline, 'Auction: New deadline should be more than previous');
        require(_deadline - _start <= MAX_AUCTION_LENGTH, 'Auction: Auction time is more than max allowed');
        Auction storage auctionUpdate = auctions[id];
        auctionUpdate.deadline = _deadline;

        emit DeadlineExtended(_nft, _nftId, _start, _deadline);
    }

    function finalize(IERC721 _nft, uint _nftId, uint32 _start, address payable _treasury, address _winner) external onlyRole(FINALIZE_ROLE) {
        bytes32 id = _auctionId(_nft, _nftId, _start);
        Auction memory auction = auctions[id];
        require(auction.deadline > 0, 'Auction: Not found');
        require(!auction.finalized, 'Auction: Already finalized');
        require(passed(auction.deadline), 'Auction: Not finished yet');
        require(notPassed(auction.deadline + auction.finalizeTimeout), 'Auction: Finalize expired, auction cancelled');
        uint winnerBid = bids[id][_winner];
        require(winnerBid > 0, 'Auction: Winner did not bid');

        bids[id][_winner] = 0;
        auctions[id].finalized = true;

        _nft.safeTransferFrom(_nft.ownerOf(_nftId), _winner, _nftId);
        _pay(_treasury, winnerBid);

        emit Finalized(_nft, _nftId, _start, _winner, winnerBid);
    }

    function claim(IERC721 _nft, uint _nftId, uint32 _start) external {
        claimFor(_nft, _nftId, _start, _msgSender());
    }

    function claimFor(IERC721 _nft, uint _nftId, uint32 _start, address _user) public {
        bytes32 id = _auctionId(_nft, _nftId, _start);
        Auction memory auction = auctions[id];
        require(_isDone(auction), 'Auction: Not done yet');
        uint userBid = bids[id][_user];
        require(userBid > 0, 'Auction: Nothing to claim');

        _claimFor(_nft, _nftId, _start, _user, userBid);
    }

    function _claimFor(IERC721 _nft, uint _nftId, uint32 _start, address _user, uint _userBid) internal {
        bytes32 id = _auctionId(_nft, _nftId, _start);
        bids[id][_user] = 0;
        unclaimed[_user] += _userBid;
        emit Claimed(_nft, _nftId, _start, _user, _userBid);
    }

    function withdraw() external {
        _withdraw(_msgSender());
    }

    function withdrawFor(address _user) external onlyRole(CONFIG_ROLE) {
        _withdraw(_user);
    }

    function _withdraw(address _user) internal {
        uint toWithdraw = unclaimed[_user];
        require(toWithdraw > 0, 'Auction: Nothing to withdraw');

        unclaimed[_user] = 0;
        _pay(_user, toWithdraw);
        emit Withdrawn(_user, toWithdraw);
    }

    function claimAndWithdrawFor(IERC721 _nft, uint _nftId, uint32 _start, address[] calldata _users) external onlyRole(CONFIG_ROLE) {
        bytes32 id = _auctionId(_nft, _nftId, _start);

        Auction memory auction = auctions[id];
        require(auction.deadline > 0, 'Auction: Not found');
        require(_isDone(auction), 'Auction: Not done yet');

        for (uint i = 0; i < _users.length; i++) {
            address _user = _users[i];
            uint _userBid = bids[id][_user];
            if (_userBid > 0) {
                _claimFor(_nft, _nftId, _start, _user, _userBid);
            }
            if (unclaimed[_user] > 0) {
                _withdraw(_user);
            }
        }
    }

    function claimAndWithdraw(IERC721 _nft, uint _nftId, uint32 _start) external {
        claimFor(_nft, _nftId, _start, _msgSender());
        _withdraw(_msgSender());
    }

    function recoverTokens(IERC20 _token, address _destination, uint _amount) public virtual onlyRole(CONFIG_ROLE) {
        require(_destination != address(0), 'Auction: Zero address not allowed');

        _token.safeTransfer(_destination, _amount);
        emit TokensRecovered(address(_token), _destination, _amount);
    }

    function isDone(IERC721 _nft, uint _nftId, uint32 _start) external view returns(bool) {
        return _isDone(auctions[_auctionId(_nft, _nftId, _start)]);
    }

    function _isDone(Auction memory _auction) internal view returns(bool) {
        return _auction.finalized || passed(_auction.deadline + _auction.finalizeTimeout);
    }

    function _pay(address _to, uint _amount) internal virtual {
        payable(_to).sendValue(_amount);
    }
}// MIT
pragma solidity 0.8.11;



contract PropyAuctionV2ERC20 is PropyAuctionV2 {
    using SafeERC20 for IERC20;

    IERC20 public immutable biddingToken;

    constructor(
        address _owner,
        address _configurator,
        address _finalizer,
        IWhitelist _whitelist,
        IERC20 _biddingToken
    ) PropyAuctionV2 (_owner, _configurator, _finalizer, _whitelist) {
        biddingToken = _biddingToken;
    }

    function bid(IERC721, uint, uint32) external payable override {
        revert('Auction: Native currency is not allowed');
    }

    function bidToken(IERC721 _nft, uint _nftId, uint32 _start, uint _amount) external {
        biddingToken.safeTransferFrom(_msgSender(), address(this), _amount);
        _bid(_nft, _nftId, _start, _amount);
    }

    function recoverTokens(IERC20 _token, address _destination, uint _amount) public override {
        require(_token != biddingToken || hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'Auction: Could not recover bidding token');
        super.recoverTokens(_token, _destination, _amount);
    }

    function _pay(address _to, uint _amount) internal override {
        biddingToken.safeTransfer(_to, _amount);
    }
}