
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

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
pragma solidity ^0.8.9;


interface IENS {

    function resolver(bytes32 node) external view returns (IResolver);

}

interface IResolver {

    function addr(bytes32 node) external view returns (address);

}

abstract contract Ownable is Context {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 private _releaseFee;

    bool private _releasesERC20;
    bool private _releasesERC721;

    address private _owner;

    bytes32 public _nameHash;

    constructor(uint256 releaseFee, bool releasesERC20, bool releasesERC721) {
        _owner = _msgSender();
        _releaseFee = releaseFee;
        _releasesERC20 = releasesERC20;
        _releasesERC721 = releasesERC721;
    }

    function owner() public view virtual returns (address) {
        if (_nameHash == "") return _owner;
        bytes32 node = _nameHash;
        IENS ens = IENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);
        IResolver resolver = ens.resolver(node);
        return resolver.addr(node);
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function setNameHash(bytes32 nameHash) external onlyOwner {
        _nameHash = nameHash;
    }

    function releaseERC20(IERC20 token, address to, uint256 amount) external onlyOwner {
        require(_releasesERC20, "Not allowed");
        require(token.balanceOf(address(this)) >= amount, "Insufficient balance");

        uint share = 100;
        if (_releaseFee > 0) token.safeTransfer(_msgSender(), amount.mul(_releaseFee).div(100));
        token.safeTransfer(to, amount.mul(share.sub(_releaseFee)).div(100));
    }

    function releaseERC721(IERC721 tokenAddress, address to, uint256 tokenId) external onlyOwner {
        require(_releasesERC721, "Not allowed");
        require(tokenAddress.ownerOf(tokenId) == address(this), "Invalid tokenId");

        tokenAddress.safeTransferFrom(address(this), to, tokenId);
    }

    function withdraw() external virtual onlyOwner {
        payable(_msgSender()).call{value: address(this).balance}("");
    }
}// MIT
pragma solidity ^0.8.9;


interface IUrn {

    function mint(address to, uint256 amount) external;

}

interface IRewardable {

    function getCommittalReward(address to) external view returns (uint256);

    function getRewardRate(address to) external view returns (uint256);

}

contract Graveyard is IERC721Receiver, ReentrancyGuard, Ownable(5, true, false) {

    using SafeMath for uint256;

    uint256 public _releaseStage;
    uint256 public _startRewarding;

    address public _urnAddress;

    address[] public _rewardingContracts;

    mapping(address => uint256) private _claimable;
    mapping(address => uint256) private _claimUpdated;

    mapping(address => uint256) public _whitelist;

    event Committed(address indexed from, address indexed contractAddress, uint256 indexed tokenId, bytes data);

    event ReleaseStage(uint256);

    modifier onlyRewarding {

        bool authorised = false;
        address sender = _msgSender();
        for (uint256 i = 0;i < _rewardingContracts.length;i++) {
            if (_rewardingContracts[i] == sender) {
                authorised = true;
                break;
            }
        }
        require(authorised, "Unauthorized");
        _;
    }

    function releaseStage() external view returns (uint256) {

        return _releaseStage;
    }

    function isWhitelisted(address from, uint256 qty) external view returns (bool) {

        return _whitelist[from] >= qty;
    }

    function claimable(address from) public view returns (uint256) {

        return _claimable[from] + _getPendingClaim(from);
    }

    function claim() external nonReentrant {

        require(_startRewarding != 0 && _urnAddress != address(0), "Rewards unavailable");
        address sender = _msgSender();
        uint256 amount = claimable(sender);
        require(amount > 0, "Nothing to claim");
        _claimable[sender] = 0;
        _claimUpdated[sender] = block.timestamp;
        IUrn(_urnAddress).mint(sender, amount);
    }

    function commitTokens(
        address[] calldata contracts, uint256[][] calldata tokenIds, bytes[][] calldata data
    ) external nonReentrant {

        require(contracts.length == tokenIds.length && tokenIds.length == data.length, "Invalid args");
        address sender = _msgSender();
        for (uint256 i = 0;i < contracts.length;i++) {
            IERC721 token = IERC721(contracts[i]);
            for (uint256 j = 0;j < tokenIds[i].length;j++) {
                token.safeTransferFrom(sender, address(this), tokenIds[i][j], data[i][j]);
            }
        }
    }

    function setState(uint256 stage, address[] calldata contracts) external onlyOwner {

        _releaseStage = stage;
        _rewardingContracts = contracts;
        emit ReleaseStage(stage);
    }

    function startRewards(address urnAddress) external onlyOwner {

        _urnAddress = urnAddress;
        _startRewarding = block.timestamp;
    }

    function updateWhitelist(address from, uint256 qty) external onlyRewarding nonReentrant {

        _whitelist[from] -= qty;
    }

    function updateClaimable(address from, uint256 qty) external onlyRewarding nonReentrant {

       if (_startRewarding == 0)  {
           _claimable[from] += qty;
       } else {
           _claimable[from] += qty + _getPendingClaim(from);
           _claimUpdated[from] = block.timestamp;
       }
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {

        uint256 stage = _releaseStage;
        require(stage == 1 || stage > 2, "Cannot accept");

        emit Committed(from, _msgSender(), tokenId, data);

        if (stage == 1) {
            _whitelist[from] = 3;
        } else {
            uint256 amount = 0;
            for (uint256 i = 0;i < _rewardingContracts.length;i++) {
                amount += IRewardable(_rewardingContracts[i]).getCommittalReward(from);
            }
            _claimable[from] += amount;
        }

        return this.onERC721Received.selector;
    }

    function _getPendingClaim(address from) internal view returns (uint256) {

        if (_startRewarding == 0) return 0;

        uint256 rate = 0;
        for (uint256 i = 0;i < _rewardingContracts.length;i++) {
            rate += IRewardable(_rewardingContracts[i]).getRewardRate(from);
        }

        uint256 startFrom = _claimUpdated[from] == 0 ? _startRewarding : _claimUpdated[from];

        return rate * (block.timestamp - startFrom) / 1 days;
    }
}