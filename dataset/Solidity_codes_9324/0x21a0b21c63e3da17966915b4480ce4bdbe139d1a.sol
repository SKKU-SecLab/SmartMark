
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


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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

pragma solidity ^0.8.0;


contract PaymentSplitter is Context {

    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event ERC20PaymentReleased(IERC20 indexed token, address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);

    uint256 private _totalShares;
    uint256 private _totalReleased;

    mapping(address => uint256) private _shares;
    mapping(address => uint256) private _released;
    address[] private _payees;

    mapping(IERC20 => uint256) private _erc20TotalReleased;
    mapping(IERC20 => mapping(address => uint256)) private _erc20Released;

    constructor(address[] memory payees, uint256[] memory shares_) payable {
        require(payees.length == shares_.length, "PaymentSplitter: payees and shares length mismatch");
        require(payees.length > 0, "PaymentSplitter: no payees");

        for (uint256 i = 0; i < payees.length; i++) {
            _addPayee(payees[i], shares_[i]);
        }
    }

    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

    function totalShares() public view returns (uint256) {

        return _totalShares;
    }

    function totalReleased() public view returns (uint256) {

        return _totalReleased;
    }

    function totalReleased(IERC20 token) public view returns (uint256) {

        return _erc20TotalReleased[token];
    }

    function shares(address account) public view returns (uint256) {

        return _shares[account];
    }

    function released(address account) public view returns (uint256) {

        return _released[account];
    }

    function released(IERC20 token, address account) public view returns (uint256) {

        return _erc20Released[token][account];
    }

    function payee(uint256 index) public view returns (address) {

        return _payees[index];
    }

    function release(address payable account) public virtual {

        require(_shares[account] > 0, "PaymentSplitter: account has no shares");

        uint256 totalReceived = address(this).balance + totalReleased();
        uint256 payment = _pendingPayment(account, totalReceived, released(account));

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _released[account] += payment;
        _totalReleased += payment;

        Address.sendValue(account, payment);
        emit PaymentReleased(account, payment);
    }

    function release(IERC20 token, address account) public virtual {

        require(_shares[account] > 0, "PaymentSplitter: account has no shares");

        uint256 totalReceived = token.balanceOf(address(this)) + totalReleased(token);
        uint256 payment = _pendingPayment(account, totalReceived, released(token, account));

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _erc20Released[token][account] += payment;
        _erc20TotalReleased[token] += payment;

        SafeERC20.safeTransfer(token, account, payment);
        emit ERC20PaymentReleased(token, account, payment);
    }

    function _pendingPayment(
        address account,
        uint256 totalReceived,
        uint256 alreadyReleased
    ) private view returns (uint256) {

        return (totalReceived * _shares[account]) / _totalShares - alreadyReleased;
    }

    function _addPayee(address account, uint256 shares_) private {

        require(account != address(0), "PaymentSplitter: account is the zero address");
        require(shares_ > 0, "PaymentSplitter: shares are 0");
        require(_shares[account] == 0, "PaymentSplitter: account already has shares");

        _payees.push(account);
        _shares[account] = shares_;
        _totalShares = _totalShares + shares_;
        emit PayeeAdded(account, shares_);
    }
}// MIT

pragma solidity ^0.8.0;

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}// MIT
pragma solidity ^0.8.0;


interface IMintableToken {

    function mintTokens(uint16 numberOfTokens, address to) external;

    function totalSupply() external returns (uint256);

}

contract HomiesStorefront is Pausable, Ownable, PaymentSplitter {

    struct PresaleWave {
        uint8 mintLimit;
        bytes32 merkleRoot;
    }

    uint256 _mintPrice = 0.1420 ether;
    uint64 _saleStart;
    uint16 _maxPurchaseCount = 5;
    string _baseURIValue;
    PresaleWave[] _presaleWaves;

    mapping(address => uint8) _presalePurchases;

    IMintableToken token;

    constructor(
        uint64 saleStart_,
        address[] memory payees,
        uint256[] memory paymentShares,
        address tokenAddress,
        bytes32 wave0root,
        bytes32 wave1root,
        bytes32 wave2root
    ) PaymentSplitter(payees, paymentShares) {
        _saleStart = saleStart_;
        token = IMintableToken(tokenAddress);

        _presaleWaves.push(PresaleWave({
            merkleRoot: wave0root,
            mintLimit: 4
        }));
        _presaleWaves.push(PresaleWave({
            merkleRoot: wave1root,
            mintLimit: 3
        }));
        _presaleWaves.push(PresaleWave({
            merkleRoot: wave2root,
            mintLimit: 2
        }));
    }

    function pause() public onlyOwner {

        _pause();
    }

    function unpause() public onlyOwner {

        _unpause();
    }

    function setSaleStart(uint64 timestamp) external onlyOwner {

        _saleStart = timestamp;
    }

    function saleStart() public view returns (uint64) {

        return _saleStart;
    }

    function presaleStart() public view returns (uint64) {

        return _saleStart - 6 * 60 * 60;
    }

    function saleHasStarted() public view returns (bool) {

        return _saleStart <= block.timestamp;
    }

    function presaleHasStarted() public view returns (bool) {

        return presaleStart() <= block.timestamp;
    }

    function currentPresaleWave() public view returns (uint8) {

        if (block.timestamp > _saleStart - 2 * 60 * 60) {
            return 2;
        }

        if (block.timestamp > _saleStart - 4 * 60 * 60) {
            return 1;
        }

        return 0;
    }

    function maxPresaleMints(uint8 waveIndex) public view returns (uint8) {

        uint8 currentWave = currentPresaleWave();
        uint8 total = 0;

        if (waveIndex > currentWave) {
            return total;
        }

        for(uint8 i = waveIndex; i <= currentWave; i++) {
            total += _presaleWaves[i].mintLimit;
        }

        return total;
    }

    function presalePurchases(address addr) external view returns(uint8) {

        return _presalePurchases[addr];
    }

    function maxPurchaseCount() public view returns (uint16) {

        return _maxPurchaseCount;
    }

    function setMaxPurchaseCount(uint16 count) external onlyOwner {

        _maxPurchaseCount = count;
    }

    function baseMintPrice() public view returns (uint256) {

        return _mintPrice;
    }

    function setBaseMintPrice(uint256 price) external onlyOwner {

        _mintPrice = price;
    }

    function mintPrice(uint256 numberOfTokens) public view returns (uint256) {

        return _mintPrice * numberOfTokens;
    }

    function presaleWaves() public view returns (PresaleWave[] memory) {

        return _presaleWaves;
    }

    function updatePresaleWave(uint256 waveIndex, uint8 mintLimit, bytes32 merkleRoot)
        external
        onlyOwner
    {

        _presaleWaves[waveIndex] = PresaleWave({
            mintLimit: mintLimit,
            merkleRoot: merkleRoot
        });
    }

    function mintTokens(uint16 numberOfTokens)
        external
        payable
        whenNotPaused
    {

        require(
            numberOfTokens <= _maxPurchaseCount,
            "MAX_PER_TX_EXCEEDED"
        );
        require(
            mintPrice(numberOfTokens) == msg.value,
            "VALUE_INCORRECT"
        );
        require(
            _msgSender() == tx.origin,
            "NOT_CALLED_FROM_EOA"
        );
        require(saleHasStarted(), "SALE_NOT_STARTED");

        token.mintTokens(numberOfTokens, _msgSender());
    }

    function mintPresale(uint8 numberOfTokens, bytes32[] calldata merkleProof, uint8 presaleWave)
        external
        payable
        whenNotPaused
    {

        require(presaleHasStarted(), "PRESALE_NOT_STARTED");
        require(currentPresaleWave() >= presaleWave, "PRESALE_WAVE_NOT_STARTED");

        require(
            _presalePurchases[_msgSender()] + numberOfTokens <= maxPresaleMints(presaleWave),
            "MAX_PRESALE_MINTS_EXCEEDED"
        );

        require(
            mintPrice(numberOfTokens) == msg.value,
            "VALUE_INCORRECT"
        );

        require(
            MerkleProof.verify(
                merkleProof,
                _presaleWaves[presaleWave].merkleRoot,
                keccak256(abi.encodePacked(_msgSender()))
            ),
            "INVALID_MERKLE_PROOF"
        );

        _presalePurchases[_msgSender()] += numberOfTokens;
        token.mintTokens(numberOfTokens, _msgSender());
    }
}