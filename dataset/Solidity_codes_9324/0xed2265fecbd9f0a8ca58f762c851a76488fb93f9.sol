


pragma solidity ^0.8.10;

interface IMintableERC721 {

	function exists(uint256 _tokenId) external view returns(bool);


	function mint(address _to, uint256 _tokenId) external;


	function mintBatch(address _to, uint256 _tokenId, uint256 n) external;


	function safeMint(address _to, uint256 _tokenId) external;


	function safeMint(address _to, uint256 _tokenId, bytes memory _data) external;


	function safeMintBatch(address _to, uint256 _tokenId, uint256 n) external;


	function safeMintBatch(address _to, uint256 _tokenId, uint256 n, bytes memory _data) external;

}



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
}




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
}




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
}




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
}




pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




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

}




pragma solidity ^0.8.0;





pragma solidity ^0.8.0;





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
}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




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
}




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
}



pragma solidity ^0.8.10;








contract MintableSale is Ownable, PaymentSplitter, ReentrancyGuard {

  using MerkleProof for bytes32[];

  uint32 public nextId = 1;

  uint32 public finalId;

  uint32 public batchLimit;

  uint32 public mintLimit;

  uint32 public soldCounter;

  bytes32 public root;

  address public immutable tokenContract;

  mapping(uint32 => mapping(address => uint32)) public mints;

  bool public isPublicSale = false;

  uint32 public saleNumber = 0;
  event Initialized(
    address indexed _by,
    uint32 _nextId,
    uint32 _finalId,
    uint32 _batchLimit,
    uint32 _limit,
    bytes32 _root,
    bool _isPublicSale
  );

  event Bought(
    address indexed _by,
    address indexed _to,
    uint256 _amount,
    uint256 _value
  );

  constructor(
    address _tokenContract,
    address[] memory addressList,
    uint256[] memory shareList
  ) PaymentSplitter(addressList, shareList) {
    require(_tokenContract != address(0), "token contract is not set");

    require(
      IERC165(_tokenContract).supportsInterface(
        type(IMintableERC721).interfaceId
      ),
      "unexpected token contract type"
    );

    tokenContract = _tokenContract;
  }

  function itemsOnSale() public view returns (uint32) {

    return finalId >= nextId ? finalId + 1 - nextId : 0;
  }

  function itemsAvailable() public view returns (uint32) {

    return isActive() ? itemsOnSale() : 0;
  }

  function isActive() public view virtual returns (bool) {

    return nextId <= finalId;
  }

  function initialize(
    uint32 _nextId, // <<<--- keep type in sync with the body type(uint32).max !!!
    uint32 _finalId, // <<<--- keep type in sync with the body type(uint32).max !!!
    uint32 _batchLimit, // <<<--- keep type in sync with the body type(uint32).max !!!
    uint32 _mintLimit, // <<<--- keep type in sync with the body type(uint32).max !!!
    bytes32 _root, // <<<--- keep type in sync with the 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF !!!
    bool _isPublicSale
  ) public onlyOwner {

    require(_nextId > 0, "zero nextId");


    if (_nextId != type(uint32).max) {
      nextId = _nextId;
    }
    if (_finalId != type(uint32).max) {
      finalId = _finalId;
    }
    if (_batchLimit != type(uint32).max) {
      batchLimit = _batchLimit;
    }
    if (_mintLimit != type(uint32).max) {
      mintLimit = _mintLimit;
    }
    if (
      _root !=
      0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    ) {
      root = _root;
    }

    isPublicSale = _isPublicSale;

    saleNumber++;

    emit Initialized(
      msg.sender,
      nextId,
      finalId,
      batchLimit,
      mintLimit,
      root,
      isPublicSale
    );
  }

  function buy(
    uint256 _price,
    uint256 _start,
    uint256 _end,
    bytes32[] memory _proof,
    uint32 _amount
  ) public payable {

    buyTo(msg.sender, _price, _start, _end, _proof, _amount);
  }

  function devBuy(
    uint256 _price,
    uint256 _start,
    uint256 _end,
    bytes32[] memory _proof,
    uint32 _amount
  ) public payable {

    buyTo(msg.sender, _price, _start, _end, _proof, _amount);
  }

  function buyTo(
    address _to,
    uint256 _price,
    uint256 _start,
    uint256 _end,
    bytes32[] memory _proof,
    uint32 _amount
  ) public payable nonReentrant {

    if (isPublicSale) {
      require(msg.sender == tx.origin, "Contract buys not allowed");
    }

    bytes32 leaf = buildLeaf(_price, _start, _end);

    require(_proof.verify(root, leaf), "invalid proof");

    require(_to != address(0), "recipient not set");
    require(
      _amount > 1 && (batchLimit == 0 || _amount <= batchLimit),
      "incorrect amount"
    );
    require(block.timestamp >= _start, "sale not yet started");
    require(block.timestamp <= _end, "sale ended");

    if (mintLimit != 0) {
      require(
        mints[saleNumber][msg.sender] + _amount <= mintLimit,
        "mint limit reached"
      );
    }

    require(
      itemsAvailable() >= _amount,
      "inactive sale or not enough items available"
    );

    uint256 totalPrice = _price * _amount;
    require(msg.value >= totalPrice, "not enough funds");

    mints[saleNumber][msg.sender] += _amount;

    IMintableERC721(tokenContract).mintBatch(_to, nextId, _amount);

    nextId += _amount;
    soldCounter += _amount;

    if (msg.value > totalPrice) {
      payable(msg.sender).transfer(msg.value - totalPrice);
    }

    emit Bought(msg.sender, _to, _amount, totalPrice);
  }

  function devBuySingle(
    uint256 _price,
    uint256 _start,
    uint256 _end,
    bytes32[] memory _proof
  ) public payable {

    buySingleTo(msg.sender, _price, _start, _end, _proof);
  }

  function buySingle(
    uint256 _price,
    uint256 _start,
    uint256 _end,
    bytes32[] memory _proof
  ) public payable {

    buySingleTo(msg.sender, _price, _start, _end, _proof);
  }

  function buySingleTo(
    address _to,
    uint256 _price,
    uint256 _start,
    uint256 _end,
    bytes32[] memory _proof
  ) public payable nonReentrant {

    if (isPublicSale) {
      require(msg.sender == tx.origin, "Contract buys not allowed");
    }
    bytes32 leaf = buildLeaf(_price, _start, _end);

    require(_proof.verify(root, leaf), "invalid proof");

    require(_to != address(0), "recipient not set");
    require(msg.value >= _price, "not enough funds");
    require(block.timestamp >= _start, "sale not yet started");
    require(block.timestamp <= _end, "sale ended");

    if (mintLimit != 0) {
      require(
        mints[saleNumber][msg.sender] + 1 <= mintLimit,
        "mint limit reached"
      );
    }

    require(isActive(), "inactive sale");

    IMintableERC721(tokenContract).mint(_to, nextId);

    nextId++;
    soldCounter++;
    mints[saleNumber][msg.sender]++;

    if (msg.value > _price) {
      payable(msg.sender).transfer(msg.value - _price);
    }

    emit Bought(msg.sender, _to, 1, _price);
  }

  function buildLeaf(
    uint256 _price,
    uint256 _start,
    uint256 _end
  ) internal view returns (bytes32) {

    bytes32 leaf;
    if (!isPublicSale) {
      leaf = keccak256(abi.encodePacked(msg.sender, _price, _start, _end));
    } else {
      leaf = keccak256(abi.encodePacked(_price, _start, _end));
    }
    return leaf;
  }
}