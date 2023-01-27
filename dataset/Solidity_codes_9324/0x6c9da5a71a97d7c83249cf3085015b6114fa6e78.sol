pragma solidity ^0.8.9;

contract Governance {


    enum Actions { Vote, Configure, SetOwnerAddress, TriggerOwnerWithdraw, ManageDeaths, StopPayouts, Bootstrap }

    struct Permissions {
        bool canVote;
        bool canConfigure;
        bool canSetOwnerAddress;
        bool canTriggerOwnerWithdraw;
        bool canManageDeaths;
        bool canStopPayouts;

        bool canBootstrap;
    }

    struct CallForVote {

        address subject;

        Permissions permissions;

        uint128 yeas;
        uint128 nays;
    }

    struct Vote {
        uint64 callForVoteIndex;
        bool yeaOrNay;
    }

    mapping(address => Permissions) private permissions;

    mapping(uint => CallForVote) private callsForVote;

    mapping(address => uint64) private lastRegisteredCallForVote;

    mapping(address => Vote) private votes;

    uint64 public resolvedCallsForVote;
    uint64 public totalCallsForVote;
    uint64 public totalVoters;

    event CallForVoteRegistered(
        uint64 indexed callForVoteIndex,
        address indexed caller,
        address indexed subject,
        bool canVote,
        bool canConfigure,
        bool canSetOwnerAddress,
        bool canTriggerOwnerWithdraw,
        bool canManageDeaths,
        bool canStopPayouts
    );

    event CallForVoteResolved(
        uint64 indexed callForVoteIndex,
        uint128 yeas,
        uint128 nays
    );

    event VoteCasted(
        uint64 indexed callForVoteIndex,
        address indexed voter,
        bool yeaOrNay,
        uint64 totalVoters,
        uint128 yeas,
        uint128 nays
    );

    constructor() {
        _setPermissions(msg.sender, Permissions({
            canVote: true,
            canConfigure: true,
            canSetOwnerAddress: true,
            canTriggerOwnerWithdraw: true,
            canManageDeaths: true,
            canStopPayouts: true,
            canBootstrap: true
        }));
    }

    function hasPermission(address subject, Actions action) public view returns (bool) {

        if (action == Actions.ManageDeaths) {
            return permissions[subject].canManageDeaths;
        }

        if (action == Actions.Vote) {
            return permissions[subject].canVote;
        }

        if (action == Actions.SetOwnerAddress) {
            return permissions[subject].canSetOwnerAddress;
        }

        if (action == Actions.TriggerOwnerWithdraw) {
            return permissions[subject].canTriggerOwnerWithdraw;
        }

        if (action == Actions.Configure) {
            return permissions[subject].canConfigure;
        }

        if (action == Actions.StopPayouts) {
            return permissions[subject].canStopPayouts;
        }

        if (action == Actions.Bootstrap) {
            return permissions[subject].canBootstrap;
        }

        return false;
    }

    function _setPermissions(address subject, Permissions memory _permissions) private {


        if (permissions[subject].canVote != _permissions.canVote) {
            if (_permissions.canVote) {
                totalVoters += 1;
            } else {
                totalVoters -= 1;

                delete votes[subject];
                delete lastRegisteredCallForVote[subject];
            }
        }

        permissions[subject] = _permissions;
    }

    function callForVote(
        address subject,
        bool canVote,
        bool canConfigure,
        bool canSetOwnerAddress,
        bool canTriggerOwnerWithdraw,
        bool canManageDeaths,
        bool canStopPayouts
    ) external {

        require(
            hasPermission(msg.sender, Actions.Vote),
            "Only addresses with vote permission can register a call for vote"
        );

        require(
            lastRegisteredCallForVote[msg.sender] <= resolvedCallsForVote,
            "Only one active call for vote per address is allowed"
        );

        totalCallsForVote++;

        lastRegisteredCallForVote[msg.sender] = totalCallsForVote;

        callsForVote[totalCallsForVote] = CallForVote({
            subject: subject,
            permissions: Permissions({
                canVote: canVote,
                canConfigure: canConfigure,
                canSetOwnerAddress: canSetOwnerAddress,
                canTriggerOwnerWithdraw: canTriggerOwnerWithdraw,
                canManageDeaths: canManageDeaths,
                canStopPayouts: canStopPayouts,
                canBootstrap: false
            }),
            yeas: 0,
            nays: 0
        });

        emit CallForVoteRegistered(
            totalCallsForVote,
            msg.sender,
            subject,
            canVote,
            canConfigure,
            canSetOwnerAddress,
            canTriggerOwnerWithdraw,
            canManageDeaths,
            canStopPayouts
        );
    }

    function vote(uint64 callForVoteIndex, bool yeaOrNay) external {

        require(hasUnresolvedCallForVote(), "No unresolved call for vote exists");
        require(
            callForVoteIndex == _getCurrenCallForVoteIndex(),
            "Call for vote does not exist or is not active"
        );
        require(
            hasPermission(msg.sender, Actions.Vote),
            "Sender address does not have vote permission"
        );

        uint128 yeas = callsForVote[callForVoteIndex].yeas;
        uint128 nays = callsForVote[callForVoteIndex].nays;

        if (votes[msg.sender].callForVoteIndex == callForVoteIndex) {
            if (votes[msg.sender].yeaOrNay) {
                yeas -= 1;
            } else {
                nays -= 1;
            }
        }

        if (yeaOrNay) {
            yeas += 1;
        } else {
            nays += 1;
        }

        emit VoteCasted(callForVoteIndex, msg.sender, yeaOrNay, totalVoters, yeas, nays);

        if (yeas == (totalVoters / 2 + 1) || nays == (totalVoters - totalVoters / 2)) {

            if (yeas > nays) {
                _setPermissions(
                    callsForVote[callForVoteIndex].subject,
                    callsForVote[callForVoteIndex].permissions
                );
            }

            resolvedCallsForVote += 1;

            delete callsForVote[callForVoteIndex];
            delete votes[msg.sender];

            emit CallForVoteResolved(callForVoteIndex, yeas, nays);

            return;
        }

        votes[msg.sender] = Vote({
            callForVoteIndex: callForVoteIndex,
            yeaOrNay: yeaOrNay
        });

        callsForVote[callForVoteIndex].yeas = yeas;
        callsForVote[callForVoteIndex].nays = nays;
    }

    function getCurrentCallForVote() public view returns (
        uint64 callForVoteIndex,
        uint128 yeas,
        uint128 nays
    ) {

        require(hasUnresolvedCallForVote(), "No unresolved call for vote exists");
        uint64 index = _getCurrenCallForVoteIndex();
        return (index, callsForVote[index].yeas, callsForVote[index].nays);
    }

    function hasUnresolvedCallForVote() public view returns (bool) {

        return totalCallsForVote > resolvedCallsForVote;
    }

    function _getCurrenCallForVoteIndex() private view returns (uint64) {

        return resolvedCallsForVote + 1;
    }
}// UNLICENSED
pragma solidity ^0.8.9;


abstract contract Governed {

    Governance public immutable governance;

    constructor (address governanceAddress) {
        governance = Governance(governanceAddress);
    }

    modifier canManageDeaths(address subject) {
        require(
            governance.hasPermission(subject, Governance.Actions.ManageDeaths),
            "Governance: subject is not allowed to manage deaths"
        );
        _;
    }

    modifier canConfigure(address subject) {
        require(
            governance.hasPermission(subject, Governance.Actions.Configure),
            "Governance: subject is not allowed to configure contracts"
        );
        _;
    }

    modifier canBootstrap(address subject) {
        require(
            governance.hasPermission(subject, Governance.Actions.Bootstrap),
            "Governance: subject is not allowed to bootstrap"
        );
        _;
    }

    modifier canSetOwnerAddress(address subject) {
        require(
            governance.hasPermission(subject, Governance.Actions.SetOwnerAddress),
            "Governance: subject is not allowed to set owner address"
        );
        _;
    }

    modifier canTriggerOwnerWithdraw(address subject) {
        require(
            governance.hasPermission(subject, Governance.Actions.TriggerOwnerWithdraw),
            "Governance: subject is not allowed to trigger owner withdraw"
        );
        _;
    }

    modifier canStopPayouts(address subject) {
        require(
            governance.hasPermission(subject, Governance.Actions.StopPayouts),
            "Governance: subject is not allowed to stop payouts"
        );
        _;
    }
}// UNLICENSED
pragma solidity ^0.8.9;


contract OwnerBalance is Governed {


    address public owner;

    OwnerBalanceContributor public release;
    OwnerBalanceContributor public bank;
    OwnerBalanceContributor public market;

    constructor(address governanceAddress) Governed(governanceAddress) {}

    function setReleaseAddress(address releaseAddress) external canBootstrap(msg.sender) {

        release = OwnerBalanceContributor(releaseAddress);
    }

    function setBankAddress(address bankAddress) external canBootstrap(msg.sender) {

        bank = OwnerBalanceContributor(bankAddress);
    }

    function setMarketAddress(address marketAddress) external canBootstrap(msg.sender) {

        market = OwnerBalanceContributor(marketAddress);
    }

    function setOwner(address _owner) external canSetOwnerAddress(msg.sender) {

        require(_owner != address(0), "Empty owner address is not allowed!");
        owner = _owner;
    }

    function getBalance() external view returns (uint) {

        uint balance;

        balance += release.ownerBalanceDeposits();
        balance += bank.ownerBalanceDeposits();
        balance += market.ownerBalanceDeposits();

        return balance;
    }

    function withdraw() external canTriggerOwnerWithdraw(msg.sender) {

        require(owner != address(0), "Owner address is not set");

        release.withdrawOwnerBalanceDeposits(owner);
        bank.withdrawOwnerBalanceDeposits(owner);
        market.withdrawOwnerBalanceDeposits(owner);
    }
}// UNLICENSED
pragma solidity ^0.8.9;


abstract contract OwnerBalanceContributor {

    address public immutable ownerBalanceAddress;

    uint public ownerBalanceDeposits;

    constructor (address _ownerBalanceAddress) {
        ownerBalanceAddress = _ownerBalanceAddress;
    }

    function _transferToOwnerBalance(uint amount) internal {
        ownerBalanceDeposits += amount;
    }

    function withdrawOwnerBalanceDeposits(address ownerAddress) external {
        require(msg.sender == ownerBalanceAddress, 'Caller must be the OwnerBalance contract');
        uint currentBalance = ownerBalanceDeposits;
        ownerBalanceDeposits = 0;
        payable(ownerAddress).transfer(currentBalance);
    }
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

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

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

}// UNLICENSED
pragma solidity ^0.8.9;


contract Macabris is ERC721, Governed {

    address public releaseAddress;

    address public marketAddress;

    Bank public bank;

    string public baseUri;

    bytes32 public immutable hash;

    constructor(
        bytes32 _hash,
        address governanceAddress
    ) ERC721('Macabris', 'MCBR') Governed(governanceAddress) {
        hash = _hash;
    }

    function setReleaseAddress(address _releaseAddress) external canBootstrap(msg.sender) {
        releaseAddress = _releaseAddress;
    }

    function setMarketAddress(address _marketAddress) external canBootstrap(msg.sender) {
        marketAddress = _marketAddress;
    }

    function setBankAddress(address bankAddress) external canBootstrap(msg.sender) {
        bank = Bank(bankAddress);
    }

    function setBaseUri(string memory _baseUri) external canConfigure(msg.sender) {
        baseUri = _baseUri;
    }

    function exists(uint256 tokenId) external view returns (bool) {
        return _exists(tokenId);
    }

    function _baseURI() override internal view returns (string memory) {
        return baseUri;
    }

    function _transfer(address from, address to, uint256 tokenId) override internal {
        super._transfer(from, to, tokenId);
        bank.onTokenTransfer(tokenId, from, to);
    }

    function _mint(address to, uint256 tokenId) override internal {
        super._mint(to, tokenId);
        bank.onTokenTransfer(tokenId, address(0), to);
    }

    function onRelease(uint256 tokenId, address buyer) external {
        require(msg.sender == releaseAddress, "Caller must be the Release contract");

        _mint(buyer, tokenId);
    }

    function onMarketSale(uint256 tokenId, address seller, address buyer) external {
        require(msg.sender == marketAddress, "Caller must be the Market contract");

        _transfer(seller, buyer, tokenId);
    }
}// UNLICENSED
pragma solidity ^0.8.9;


contract Bank is Governed, OwnerBalanceContributor {

    Macabris public macabris;

    Reaper public reaper;

    struct IntervalActivity {
        int128 activeTokenChange;
        uint128 deposits;
    }

    struct IntervalTotals {
        uint index;
        uint deposits;
        uint payouts;
        uint accountPayouts;
        uint activeTokens;
        uint accountActiveTokens;
    }

    struct IntervalTotalsPacked {
        uint128 deposits;
        uint128 payouts;
        uint128 accountPayouts;
        uint48 activeTokens;
        uint48 accountActiveTokens;
        uint32 index;
    }

    uint64 public immutable startTime;

    uint64 public stopTime;

    uint64 public immutable intervalCount;

    uint64 public immutable intervalLength;

    mapping(uint => IntervalActivity) private intervals;

    mapping(uint => mapping(address => int)) private individualIntervals;

    mapping(address => uint) private withdrawals;

    mapping(address => IntervalTotalsPacked) private lastWithdrawTotals;

    constructor(
        uint64 _startTime,
        uint64 _intervalCount,
        uint64 _intervalLength,
        address governanceAddress,
        address ownerBalanceAddress
    ) Governed(governanceAddress) OwnerBalanceContributor(ownerBalanceAddress) {
        require(_intervalLength > 0, "Interval length can't be zero");
        require(_intervalCount > 0, "At least one interval is required");

        startTime = _startTime;
        intervalCount = _intervalCount;
        intervalLength = _intervalLength;
    }

    function setMacabrisAddress(address macabrisAddress) external canBootstrap(msg.sender) {
        macabris = Macabris(macabrisAddress);
    }

    function setReaperAddress(address reaperAddress) external canBootstrap(msg.sender) {
        reaper = Reaper(reaperAddress);
    }

    function stopPayouts() external canStopPayouts(msg.sender) {
        require(stopTime == 0, "Payouts are already stopped");
        require(block.timestamp < getEndTime(), "Payout schedule is already completed");
        stopTime = uint64(block.timestamp);
    }

    function hasEnded() public view returns (bool) {
        return stopTime > 0 || block.timestamp >= getEndTime();
    }

    function getEndTime() public view returns(uint) {
        return _getIntervalStartTime(intervalCount);
    }

    function _getIntervalStartTime(uint interval) private view returns(uint) {
        return startTime + interval * intervalLength;
    }

    function getNextIntervalStartTime() public view returns (uint) {

        if (stopTime > 0) {
            return 0;
        }

        if (block.timestamp < startTime) {
            return startTime;
        }

        uint currentInterval = _getInterval(block.timestamp);

        if (currentInterval >= (intervalCount - 1)) {
            return 0;
        }

        return _getIntervalStartTime(currentInterval + 1);
    }

    function deposit() external payable {

        if (hasEnded()) {
            _transferToOwnerBalance(msg.value);
            return;
        }

        require(msg.value <= type(uint128).max, "Deposits bigger than uint128 max value are not allowed!");
        uint currentInterval = _getInterval(block.timestamp);
        intervals[currentInterval].deposits += uint128(msg.value);
    }

    function onTokenTransfer(uint tokenId, address from, address to) external {
        require(msg.sender == address(macabris), "Caller must be the Macabris contract");

        if (hasEnded()) {
            return;
        }

        if (reaper.getTimeOfDeath(tokenId) != 0) {
            return;
        }

        uint currentInterval = _getInterval(block.timestamp);

        if (from == address(0)) {
            intervals[currentInterval].activeTokenChange += 1;
        } else {
            individualIntervals[currentInterval][from] -= 1;
        }

        if (to == address(0)) {
            intervals[currentInterval].activeTokenChange -= 1;
        } else {
            individualIntervals[currentInterval][to] += 1;
        }
    }

    function onTokenDeath(uint tokenId) external {
        require(msg.sender == address(reaper), "Caller must be the Reaper contract");

        if (hasEnded()) {
            return;
        }

        if (!macabris.exists(tokenId)) {
            return;
        }

        uint currentInterval = _getInterval(block.timestamp);
        address owner = macabris.ownerOf(tokenId);

        intervals[currentInterval].activeTokenChange -= 1;
        individualIntervals[currentInterval][owner] -= 1;
    }

    function onTokenResurrection(uint tokenId) external {
        require(msg.sender == address(reaper), "Caller must be the Reaper contract");

        if (hasEnded()) {
            return;
        }

        if (!macabris.exists(tokenId)) {
            return;
        }

        uint currentInterval = _getInterval(block.timestamp);
        address owner = macabris.ownerOf(tokenId);

        intervals[currentInterval].activeTokenChange += 1;
        individualIntervals[currentInterval][owner] += 1;
    }

    function _getCurrentInterval() private view returns(uint) {

        if (stopTime > 0) {
            return _getInterval(stopTime);
        }

        uint intervalIndex = _getInterval(block.timestamp);

        if (intervalIndex > intervalCount) {
            return intervalCount;
        }

        return intervalIndex;
    }

    function _getInterval(uint timestamp) private view returns(uint) {

        if (timestamp < startTime) {
            return 0;
        }

        return (timestamp - startTime) / intervalLength;
    }

    function getPoolValue() public view returns (uint) {

        if (hasEnded()) {
            return 0;
        }

        uint currentInterval = _getInterval(block.timestamp);
        IntervalTotals memory totals = _getIntervalTotals(currentInterval, address(0));

        return totals.deposits - totals.payouts;
    }

    function getNextPayout() external view returns (uint) {

        if (hasEnded()) {
            return 0;
        }

        uint currentInterval = _getInterval(block.timestamp);
        IntervalTotals memory totals = _getIntervalTotals(currentInterval, address(0));

        return _getPayoutPerToken(totals);
    }

    function _getPayoutPerToken(IntervalTotals memory totals) private view returns (uint) {
        if (totals.activeTokens > 0 && totals.index < intervalCount) {
            return (totals.deposits - totals.payouts) / (intervalCount - totals.index) / totals.activeTokens;
        } else {
            return 0;
        }
    }

    function getPayoutsTotal() external view returns (uint) {
        uint interval = _getCurrentInterval();
        IntervalTotals memory totals = _getIntervalTotals(interval, address(0));
        uint payouts = totals.payouts;

        if (stopTime > 0 && totals.activeTokens > 0) {

            payouts += (totals.deposits - totals.payouts) / totals.activeTokens * totals.activeTokens;
        }

        return payouts;
    }

    function getAccountPayouts(address account) public view returns (uint) {
        uint interval = _getCurrentInterval();
        IntervalTotals memory totals = _getIntervalTotals(interval, account);
        uint accountPayouts = totals.accountPayouts;

        if (stopTime > 0 && totals.activeTokens > 0) {
            accountPayouts += (totals.deposits - totals.payouts) / totals.activeTokens * totals.accountActiveTokens;
        }

        return accountPayouts;
    }

    function getBalance(address account) public view returns (uint) {
        return getAccountPayouts(account) - withdrawals[account];
    }

    function withdraw(address payable account) external {

        uint interval = _getCurrentInterval();

        if (interval > 1) {
            IntervalTotals memory totals = _getIntervalTotals(interval - 1, account);

            lastWithdrawTotals[account] = IntervalTotalsPacked({
                deposits: uint128(totals.deposits),
                payouts: uint128(totals.payouts),
                accountPayouts: uint128(totals.accountPayouts),
                activeTokens: uint48(totals.activeTokens),
                accountActiveTokens: uint48(totals.accountActiveTokens),
                index: uint32(totals.index)
            });
        }

        uint balance = getBalance(account);
        withdrawals[account] += balance;
        account.transfer(balance);
    }

    function _getIntervalTotals(uint intervalIndex, address account) private view returns (IntervalTotals memory) {

        IntervalTotalsPacked storage packed = lastWithdrawTotals[account];

        IntervalTotals memory totals = IntervalTotals({
            index: packed.index,
            deposits: packed.deposits,
            payouts: packed.payouts,
            accountPayouts: packed.accountPayouts,
            activeTokens: packed.activeTokens,
            accountActiveTokens: packed.accountActiveTokens
        });

        uint prevPayout;
        uint prevAccountPayout;
        uint prevPayoutPerToken;

        for (uint i = totals.index > 0 ? totals.index + 1 : 0; i <= intervalIndex; i++) {

            prevPayoutPerToken = _getPayoutPerToken(totals);
            prevPayout = prevPayoutPerToken * totals.activeTokens;
            prevAccountPayout = totals.accountActiveTokens * prevPayoutPerToken;

            totals.index = i;
            totals.payouts += prevPayout;
            totals.accountPayouts += prevAccountPayout;

            IntervalActivity storage interval = intervals[i];
            totals.deposits += interval.deposits;

            totals.activeTokens = uint(int(totals.activeTokens) + interval.activeTokenChange);
            totals.accountActiveTokens = uint(int(totals.accountActiveTokens) + individualIntervals[i][account]);
        }

        return totals;
    }
}// UNLICENSED
pragma solidity ^0.8.9;


contract Reaper is Governed {

    Bank public bank;

    mapping (uint256 => int64) private _deaths;

    event Death(uint256 indexed tokenId, int64 timeOfDeath);

    event Resurrection(uint256 indexed tokenId);

    constructor(address governanceAddress) Governed(governanceAddress) {}

    function setBankAddress(address bankAddress) external canBootstrap(msg.sender) {
        bank = Bank(bankAddress);
    }

    function markDead(uint256 tokenId, int64 timeOfDeath) external canManageDeaths(msg.sender) {
        require(timeOfDeath != 0, "Time of death of 0 represents an alive token");
        _deaths[tokenId] = timeOfDeath;

        bank.onTokenDeath(tokenId);
        emit Death(tokenId, timeOfDeath);
    }

    function markAlive(uint256 tokenId) external canManageDeaths(msg.sender) {
        require(_deaths[tokenId] != 0, "Token is not dead");
        _deaths[tokenId] = 0;

        bank.onTokenResurrection(tokenId);
        emit Resurrection(tokenId);
    }

    function getTimeOfDeath(uint256 tokenId) external view returns (int64) {
        return _deaths[tokenId];
    }
}