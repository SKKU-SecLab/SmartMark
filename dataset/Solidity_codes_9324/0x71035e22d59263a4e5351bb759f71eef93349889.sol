
pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// Apache-2.0
pragma solidity ^0.8.0;

interface IERC721 {

    function mint(address to, uint256 id) external;

}// Apache-2.0
pragma solidity ^0.8.0;

abstract contract ERC712Domain {
    bytes32 constant DOMAIN_TYPEHASH = keccak256(
        'EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'
    );

    struct Domain {
        string name;
        string version;
    }

    bytes32 domainHash = 0x00;

    function _erc712DomainInit(string memory name,string memory version) internal {
        require(domainHash == 0x00, 'ERC712Domain can only be initialized once');

        domainHash = keccak256(abi.encode(
            DOMAIN_TYPEHASH,
            keccak256(bytes(name)),
            keccak256(bytes(version)),
            block.chainid,
            address(this)
        ));
    }

    function erc712Hash(bytes32 msgHash) public view returns (bytes32) {
        return keccak256(abi.encodePacked('\x19\x01', domainHash, msgHash));
    }

    function erc712Verify(address signer, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public view returns (bool) {
        return ecrecover(erc712Hash(msgHash), v, r, s) == signer;
    }
}// Apache-2.0
pragma solidity ^0.8.0;


contract Auction is Initializable, OwnableUpgradeable, ERC712Domain {

    using SafeERC20Upgradeable for IERC20Upgradeable;

    address public beneficiary;
    address public operator;
    uint256 public items;
    IERC20Upgradeable public weth;
    IERC721 public nft;

    mapping(address => uint256) public used;

    modifier onlyOperator() {

        require(_msgSender() == operator, "Must be the operator");
        _;
    }

    function initialize(
        IERC721 nft_,
        uint256 items_,
        IERC20Upgradeable weth_,
        address beneficiary_,
        address operator_
    ) external initializer {

        __Ownable_init();
        _erc712DomainInit('$CAR Auction', '1');

        nft = nft_;
        items = items_;
        weth = weth_;
        beneficiary = beneficiary_;
        operator = operator_;
    }

    function setBeneficiary(address beneficiary_) external onlyOwner {

        beneficiary = beneficiary_;
    }

    function setOperator(address operator_) external onlyOwner {

        operator = operator_;
    }

    function setWeth(IERC20Upgradeable weth_) external onlyOwner {

        weth = weth_;
    }

    function setNFT(IERC721 nft_) external onlyOwner {

        nft = nft_;
    }

    function selectWinners(
        address[] calldata bidders,
        uint256[] calldata bids,
        bytes32[] calldata formattedAmountHashes,
        bytes32[] memory sigsR,
        bytes32[] memory sigsS,
        uint8[] memory sigsV,
        uint256 startID
    ) external onlyOperator returns (uint256) {

        require(bidders.length <= items, "Too much winners");
        require(bidders.length == bids.length, "Incorrect number of bids");
        require(bidders.length == formattedAmountHashes.length, "Incorrect number of formatted amount hashes");
        require(
            bidders.length == sigsV.length &&
                sigsV.length == sigsR.length &&
                sigsV.length == sigsS.length,
            "Incorrect number of signatures"
        );
        uint256 minted = 0;
        for (uint256 i = 0; i < bidders.length; i++) {
            require(used[bidders[i]] == 0, "Already used");
            used[bidders[i]] = bids[i];
            if (
                !erc712Verify(
                    bidders[i], hashBid(bids[i], formattedAmountHashes[i]), sigsV[i], sigsR[i], sigsS[i]
                )
            ) {
                continue;
            }
            if (
                weth.allowance(bidders[i], address(this)) < bids[i] ||
                weth.balanceOf(bidders[i]) < bids[i]
            ) {
                continue;
            }
            weth.safeTransferFrom(bidders[i], beneficiary, bids[i]);
            nft.mint(bidders[i], startID + minted);
            minted++;
        }
        items -= minted;
        return minted;
    }

    bytes32 constant BID_CONTENTS_HASH = keccak256(bytes(
        'Please sign to confirm your bid. The amounts are shown in WEI and ETH.'
    ));

    bytes32 constant BID_TYPEHASH = keccak256(bytes(
        'Bid(uint256 amount,string contents,address tokenContract,string formattedAmount)'
    ));

    function hashBid(uint256 amount, bytes32 formattedAmountHash) public view returns (bytes32) {

        return keccak256(abi.encode(
            BID_TYPEHASH,
            amount,
            BID_CONTENTS_HASH,
            address(weth),
            formattedAmountHash
        ));
    }
}