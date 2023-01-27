

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}












interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}





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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
}


library SafeERC20 {

    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}







interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}









interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}


contract ERC721Holder is IERC721Receiver {


    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}







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

}















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

}







abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId
            || super.supportsInterface(interfaceId);
    }
}


contract ERC1155Holder is ERC1155Receiver {

    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
}






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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}





abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}


contract NFTProtocolDEX is ERC1155Holder, ERC721Holder, ReentrancyGuard {

    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;

    event SwapMade(
        Component[] make,
        Component[] take,
        address indexed makerAddress,
        address[] whitelist,
        uint256 indexed id
    );

    event SwapTaken(uint256 swapId, address takerAddress, uint256 fee);

    event SwapDropped(uint256 swapId);

    event Vote(uint256 flatFee, uint256 feeBypassLow, uint256 feeBypassHigh);

    address public msig;

    address public immutable nftProtocolTokenAddress;

    uint256 public flat = 1000000000000000;

    bool public locked = false;

    uint256 public felo = 10000 * 10**18;

    uint256 public fehi = 100000 * 10**18;

    uint8 private constant LEFT = 0;
    uint8 private constant RIGHT = 1;

    uint8 public constant ERC1155_ASSET = 0;

    uint8 public constant ERC721_ASSET = 1;

    uint8 public constant ERC20_ASSET = 2;

    uint8 public constant ETHER_ASSET = 3;

    uint8 public constant OPEN_SWAP = 0;

    uint8 public constant CLOSED_SWAP = 1;

    uint8 public constant DROPPED_SWAP = 2;

    struct Swap {
        uint256 id;
        uint8 status;
        Component[][2] components;
        address makerAddress;
        address takerAddress;
        bool whitelistEnabled;
    }

    struct Component {
        uint8 assetType;
        address tokenAddress;
        uint256[] tokenIds;
        uint256[] amounts;
    }

    mapping(uint256 => Swap) private swaps;

    uint256 public size;

    mapping(uint256 => mapping(address => bool)) public list;

    mapping(address => uint256) private pendingWithdrawals;

    uint256 private usersEthBalance;

    modifier unlocked {

        require(!locked, "DEX shut down");
        _;
    }

    modifier onlyMsig {

        require(msg.sender == msig, "Unauthorized");
        _;
    }

    constructor(address _nftProtocolToken, address _multisig) {
        msig = _multisig;
        nftProtocolTokenAddress = _nftProtocolToken;
        emit Vote(flat, felo, fehi);
    }

    function make(
        Component[] calldata _make,
        Component[] calldata _take,
        address[] calldata _whitelist
    ) external payable nonReentrant unlocked {

        require(msg.sender != msig, "Multisig cannot make swap");
        require(_take.length > 0, "Empty taker array");
        require(_make.length > 0, "Empty maker array");

        checkAssets(_take);
        uint256 totalEther = checkAssets(_make);
        require(msg.value >= totalEther, "Insufficient ETH");

        swaps[size].whitelistEnabled = _whitelist.length > 0;
        for (uint256 i = 0; i < _whitelist.length; i++) {
            list[size][_whitelist[i]] = true;
        }

        swaps[size].id = size;
        swaps[size].makerAddress = msg.sender;
        for (uint256 i = 0; i < _take.length; i++) {
            swaps[size].components[RIGHT].push(_take[i]);
        }
        for (uint256 i = 0; i < _make.length; i++) {
            swaps[size].components[LEFT].push(_make[i]);
        }

        usersEthBalance += msg.value;

        if (msg.value > totalEther) {
            pendingWithdrawals[msg.sender] += msg.value - totalEther;
        }

        size += 1;

        for (uint256 i = 0; i < _make.length; i++) {
            transferAsset(_make[i], msg.sender, address(this));
        }

        emit SwapMade(_make, _take, msg.sender, _whitelist, size - 1);
    }

    function take(uint256 _swapId) external payable nonReentrant unlocked {

        require(msg.sender != msig, "Multisig cannot take swap");

        require(_swapId < size, "Invalid swapId");
        Swap memory swp = swaps[_swapId];
        require(swp.status == OPEN_SWAP, "Swap not open");

        require(!swp.whitelistEnabled || list[_swapId][msg.sender], "Not whitelisted");

        uint256 totalEther = checkAssets(swp.components[RIGHT]);
        uint256 fee = fees();
        require(msg.value >= totalEther + fee, "Insufficient ETH (price+fee)");

        swaps[_swapId].status = CLOSED_SWAP;
        swaps[_swapId].takerAddress = msg.sender;

        usersEthBalance += totalEther;

        if (msg.value > totalEther + fee) {
            pendingWithdrawals[msg.sender] += msg.value - totalEther - fee;
        }

        for (uint256 i = 0; i < swp.components[LEFT].length; i++) {
            transferAsset(swp.components[LEFT][i], address(this), msg.sender);
        }

        for (uint256 i = 0; i < swp.components[RIGHT].length; i++) {
            transferAsset(swp.components[RIGHT][i], msg.sender, swp.makerAddress);
        }

        emit SwapTaken(_swapId, msg.sender, fee);
    }

    function drop(uint256 _swapId) external nonReentrant unlocked {

        Swap memory swp = swaps[_swapId];
        require(msg.sender == swp.makerAddress, "Not swap maker");
        require(swaps[_swapId].status == OPEN_SWAP, "Swap not open");

        swaps[_swapId].status = DROPPED_SWAP;

        for (uint256 i = 0; i < swp.components[LEFT].length; i++) {
            transferAsset(swp.components[LEFT][i], address(this), swp.makerAddress);
        }

        emit SwapDropped(_swapId);
    }

    function pend() public view returns (uint256) {

        return pendingWithdrawals[msg.sender];
    }

    function pull() external nonReentrant {

        uint256 amount = pendingWithdrawals[msg.sender];
        pendingWithdrawals[msg.sender] = 0;
        if (msg.sender != msig) {
            usersEthBalance -= amount;
        }
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Ether transfer failed");
    }

    function swap(uint256 _swapId) public view returns (Swap memory) {

        require(_swapId < size, "Invalid swapId");
        return swaps[_swapId];
    }

    function fees() public view returns (uint256) {

        uint256 balance = IERC20(nftProtocolTokenAddress).balanceOf(msg.sender);
        if (balance >= fehi) {
            return 0;
        }
        if (balance < felo) {
            return flat;
        }
        uint256 startFee = (flat * 9) / 10;
        return startFee - (startFee * (balance - felo)) / (fehi - felo);
    }

    function vote(
        uint256 _flatFee,
        uint256 _feeBypassLow,
        uint256 _feeBypassHigh
    ) external onlyMsig {

        require(_feeBypassLow <= _feeBypassHigh, "bypassLow must be <= bypassHigh");

        flat = _flatFee;
        felo = _feeBypassLow;
        fehi = _feeBypassHigh;

        emit Vote(_flatFee, _feeBypassLow, _feeBypassHigh);
    }

    function lock(bool _locked) external onlyMsig {

        locked = _locked;
    }

    function auth(address _to) external onlyMsig {

        require(_to != address(0x0), "Cannot set to zero address");
        msig = _to;
    }

    function lift() external onlyMsig {

        uint256 amount = address(this).balance;
        pendingWithdrawals[msg.sender] = amount - usersEthBalance;
    }

    function transferAsset(
        Component memory _comp,
        address _from,
        address _to
    ) internal {

        if (_comp.assetType == ERC1155_ASSET) {
            IERC1155 nft = IERC1155(_comp.tokenAddress);
            nft.safeBatchTransferFrom(_from, _to, _comp.tokenIds, _comp.amounts, "");
        } else if (_comp.assetType == ERC721_ASSET) {
            IERC721 nft = IERC721(_comp.tokenAddress);
            nft.safeTransferFrom(_from, _to, _comp.tokenIds[0]);
        } else if (_comp.assetType == ERC20_ASSET) {
            IERC20 coin = IERC20(_comp.tokenAddress);
            uint256 amount = _comp.amounts[0];
            if (_from == address(this)) {
                coin.safeTransfer(_to, amount);
            } else {
                coin.safeTransferFrom(_from, _to, amount);
            }
        } else {
            pendingWithdrawals[_to] += _comp.amounts[0];
        }
    }

    function checkAsset(Component memory _comp) internal pure returns (uint256) {

        if (_comp.assetType == ERC1155_ASSET) {
            require(
                _comp.tokenIds.length == _comp.amounts.length,
                "TokenIds and amounts len differ"
            );
        } else if (_comp.assetType == ERC721_ASSET) {
            require(_comp.tokenIds.length == 1, "TokenIds array length must be 1");
        } else if (_comp.assetType == ERC20_ASSET) {
            require(_comp.amounts.length == 1, "Amounts array length must be 1");
        } else if (_comp.assetType == ETHER_ASSET) {
            require(_comp.amounts.length == 1, "Amounts array length must be 1");
            return _comp.amounts[0];
        } else {
            revert("Invalid asset type");
        }
        return 0;
    }

    function checkAssets(Component[] memory _assets) internal pure returns (uint256) {

        uint256 totalEther = 0;
        for (uint256 i = 0; i < _assets.length; i++) {
            totalEther += checkAsset(_assets[i]);
        }
        return totalEther;
    }
}