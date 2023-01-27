
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
}// MIT LICENSE 

pragma solidity ^0.8.0;

interface IHabitat {

  function addManyToStakingPool(address account, uint16[] calldata tokenIds) external;

  function addManyHouseToStakingPool(address account, uint16[] calldata tokenIds) external;

  function randomCatOwner(uint256 seed) external view returns (address);

  function randomCrazyCatOwner(uint256 seed) external view returns (address);

  function isOwner(uint256 tokenId, address owner) external view returns (bool);

}// MIT LICENSE 

pragma solidity ^0.8.0;

interface ITraits {

  function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT LICENSE

pragma solidity ^0.8.0;

interface ICHEDDAR {

    function mint(address to, uint256 amount) external;

    function burn(address from, uint256 amount) external;

    function updateOriginAccess() external;

    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);

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


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT LICENSE

pragma solidity ^0.8.0;


interface ICnM is IERC721Enumerable {

    
    struct CatMouse {
        bool isCat; // true if cat
        bool isCrazy; // true if cat is CrazyCatLady, only check if isCat equals to true
        uint8 roll; //0 - habitatless, 1 - Shack, 2 - Ranch, 3 - Mansion

        uint8 body;
        uint8 color;
        uint8 eyes;
        uint8 eyebrows;
        uint8 neck;
        uint8 glasses;
        uint8 hair;
        uint8 head;
        uint8 markings;
        uint8 mouth;
        uint8 nose;
        uint8 props;
        uint8 shirts;
    }

    function getTokenWriteBlock(uint256 tokenId) external view returns(uint64);

    function mint(address recipient, uint256 seed) external;

    function setRoll(uint256 tokenId, uint8 habitatType) external;


    function emitCatStakedEvent(address owner,uint256 tokenId) external;

    function emitCrazyCatStakedEvent(address owner, uint256 tokenId) external;

    function emitMouseStakedEvent(address owner, uint256 tokenId) external;

    
    function emitCatUnStakedEvent(address owner, uint256 tokenId) external;

    function emitCrazyCatUnStakedEvent(address owner, uint256 tokenId) external;

    function emitMouseUnStakedEvent(address owner, uint256 tokenId) external;

    
    function burn(uint256 tokenId) external;

    function getPaidTokens() external view returns (uint256);

    function updateOriginAccess(uint16[] memory tokenIds) external;

    function isCat(uint256 tokenId) external view returns(bool);

    function isClaimable() external view returns(bool);

    function isCrazyCatLady(uint256 tokenId) external view returns(bool);

    function getTokenRoll(uint256 tokenId) external view returns(uint8);

    function getMaxTokens() external view returns (uint256);

    function getTokenTraits(uint256 tokenId) external view returns (CatMouse memory);

    function minted() external view returns (uint16);

}// MIT LICENSE

pragma solidity ^0.8.0;

interface IRandomizer {

    function commitId() external view returns (uint16);

    function getCommitRandom(uint16 id) external view returns (uint256);

    function random() external returns (uint256);

    function sRandom(uint256 tokenId) external returns (uint256);

}// MIT LICENSE

pragma solidity ^0.8.0;

contract CnMGame is Ownable, ReentrancyGuard, Pausable {

  event MintCommitted(address indexed owner, uint256 indexed amount);
  event MintRevealed(address indexed owner, uint256 indexed amount);
  event Roll(address indexed owner, uint256 tokenId, uint8 roll);

  struct MintCommit {
    bool stake;
    uint16 amount;
  }
  struct RollCommit {
    uint256 tokenId;
  }

  uint256 public MINT_PRICE = 0.075 ether;
  uint256 public ROLL_COST = 3000 ether;
  bool public isWhitelistActive;
  bool public isPublicActive;
  uint256 public maxPerWallet = 3;
  mapping(address => uint256) perWallet;

  bytes32 public root;
  mapping(address => mapping(uint16 => MintCommit)) private _mintCommits;
  mapping(address => uint16) private _pendingCommitId;

  uint16 private pendingMintAmt;


  bool public allowCommits = true;

  mapping(address => bool) private admins;

  IHabitat public habitat;
  ICHEDDAR public cheddarToken;
  ITraits public traits;
  ICnM public cnmNFT;
  IRandomizer public randomizer;
  address[] _addresses = [
      0xF456D310b9B40C93d9686199b3A3775d8dd52fd1,
      0x291d931172783AB4B059c9E25F5C2af1D541373f,
      0x4DAfcc597cbEf07A3E089200f054c674d549fc8D,
      0xe3b661D0Fd1FedF2782997E55C417BAA7c49B3b9,
      0xAB4438B61a920B9044A3F182c67FF18138E6EE99,
      0x510245323739DB800B6520463782fBc890cAf023
  ];
  uint256[] _shares = [40,192, 192, 192, 192, 192];

  constructor() {
    _pause();
  }


  modifier requireContractsSet() {

      require(address(cheddarToken) != address(0) && address(traits) != address(0)
        && address(cnmNFT) != address(0) && address(habitat) != address(0) && address(randomizer) != address(0)
        , "Contracts not set");
      _;
  }

  function setContracts(address _cheddar, address _traits, address _cnm, address _habitat, address _randomizer) external onlyOwner {

    cheddarToken = ICHEDDAR(_cheddar);
    traits = ITraits(_traits);
    cnmNFT = ICnM(_cnm);
    habitat = IHabitat(_habitat);
    randomizer = IRandomizer(_randomizer);
  }


  function getPendingMint(address addr) external view returns (MintCommit memory) {

    require(_pendingCommitId[addr] != 0, "no pending commits");
    return _mintCommits[addr][_pendingCommitId[addr]];
  }

  function hasMintPending(address addr) external view returns (bool) {

    return _pendingCommitId[addr] != 0;
  }

  function canMint(address addr) external view returns (bool) {

    uint256 seed = randomizer.getCommitRandom(_pendingCommitId[addr]);
    return _pendingCommitId[addr] != 0 && seed > 0;
  }

  function deleteCommit(address addr) external {

    require(owner() == _msgSender() || admins[_msgSender()], "Only admins can call this");
    uint16 commitIdCur = _pendingCommitId[_msgSender()];
    require(commitIdCur > 0, "No pending commit");
    delete _mintCommits[addr][commitIdCur];
    delete _pendingCommitId[addr];
  }

  function forceRevealCommit(address addr) external {

    require(owner() == _msgSender() || admins[_msgSender()], "Only admins can call this");
    reveal(addr);
  }

  function whitelistMint(uint256 amount, bool stake, uint256 tokenId, bytes32[] calldata proof) external payable nonReentrant {

    require(isWhitelistActive, "not active");
    require(_verify(_leaf(_msgSender(), tokenId), proof), "invalid");
    require(perWallet[msg.sender] + amount <= maxPerWallet, "cannot exceed max");
    require(allowCommits, "adding commits disallowed");
    require(tx.origin == _msgSender(), "Only EOA");
    require(_pendingCommitId[_msgSender()] == 0, "Already have pending mints");
    uint16 minted = cnmNFT.minted();
    uint256 maxTokens = cnmNFT.getMaxTokens();
    uint256 paidTokens = cnmNFT.getPaidTokens();
    require(amount > 0 && minted + pendingMintAmt + amount <= maxTokens, "All tokens minted");
    require(minted + amount <= paidTokens, "All tokens on-sale already sold");
    require(amount * MINT_PRICE == msg.value, "Invalid payment amount");

    uint16 amt = uint16(amount);
    _mintCommits[_msgSender()][randomizer.commitId()] = MintCommit(stake, amt);
    _pendingCommitId[_msgSender()] = randomizer.commitId();
    pendingMintAmt += amt;
    perWallet[msg.sender] += amount;
    emit MintCommitted(_msgSender(), amount);
  }

  function mintCommit(uint256 amount, bool stake) external payable nonReentrant whenNotPaused {

    require(isPublicActive, "Not live");
    require(allowCommits, "adding commits disallowed");
    require(tx.origin == _msgSender(), "Only EOA");
    require(_pendingCommitId[_msgSender()] == 0, "Already have pending mints");
    uint16 minted = cnmNFT.minted();
    uint256 maxTokens = cnmNFT.getMaxTokens();
    uint256 paidTokens = cnmNFT.getPaidTokens();
    require(minted + pendingMintAmt + amount <= maxTokens, "All tokens minted");
    require(amount > 0 && amount <= 4, "Invalid mint amount");
    if (minted < paidTokens) {
        require(
            minted + amount <= paidTokens,
            "All tokens on-sale already sold"
        );
        require(amount * MINT_PRICE == msg.value, "Invalid payment amount");
    } else {
        require(msg.value == 0);
    }

    uint256 totalCheddarCost = 0;
    for (uint i = 1; i <= amount; i++) {
      totalCheddarCost += mintCost(minted + pendingMintAmt + i, maxTokens);
    }
    if (totalCheddarCost > 0) {
      cheddarToken.burn(_msgSender(), totalCheddarCost);
      cheddarToken.updateOriginAccess();
    }
    uint16 amt = uint16(amount);
    _mintCommits[_msgSender()][randomizer.commitId()] = MintCommit(stake, amt);
    _pendingCommitId[_msgSender()] = randomizer.commitId();
    pendingMintAmt += amt;
    emit MintCommitted(_msgSender(), amount);
  }

  function mintReveal() external whenNotPaused nonReentrant {

    require(tx.origin == _msgSender(), "Only EOA1");
    reveal(_msgSender());
  }

  function reveal(address addr) internal {

    uint16 commitIdCur = _pendingCommitId[addr];
    uint256 seed = randomizer.getCommitRandom(commitIdCur);
    require(commitIdCur > 0, "No pending commit");
    require(seed > 0, "random seed not set");
    uint16 minted = cnmNFT.minted();
    MintCommit memory commit = _mintCommits[addr][commitIdCur];
    pendingMintAmt -= commit.amount;
    uint16[] memory tokenIds = new uint16[](commit.amount);
    uint16[] memory tokenIdsToStake = new uint16[](commit.amount);
    for (uint k = 0; k < commit.amount; k++) {
      minted++;
      seed = uint256(keccak256(abi.encode(seed, addr)));
      address recipient = selectRecipient(seed);

      tokenIds[k] = minted;
      if (!commit.stake || recipient != addr) {
        cnmNFT.mint(recipient, seed);
      } else {
        cnmNFT.mint(address(habitat), seed);
        tokenIdsToStake[k] = minted;
      }
    }
    cnmNFT.updateOriginAccess(tokenIds);
    if(commit.stake) {
      habitat.addManyToStakingPool(addr, tokenIdsToStake);
    }
    delete _mintCommits[addr][commitIdCur];
    delete _pendingCommitId[addr];
    emit MintRevealed(addr, tokenIds.length);
  }

  function rollForage(uint256 tokenId) external whenNotPaused nonReentrant returns(uint8) {

    require(allowCommits, "adding commits disallowed");
    require(tx.origin == _msgSender(), "Only EOA");
    require(habitat.isOwner(tokenId, msg.sender), "Not owner");
    require(!cnmNFT.isCat(tokenId), "affected only for Mouse NFTs");

    cheddarToken.burn(_msgSender(), ROLL_COST);
    cheddarToken.updateOriginAccess();
    uint256 seed = randomizer.sRandom(tokenId);
    uint8 roll;

    if ((seed & 0xFFFF) % 100 < 10) {
      roll = 3;
    } else if((seed & 0xFFFF) % 100 < 30) {
      roll = 2;
    } else {
      roll = 1;
    }
    uint8 previous = cnmNFT.getTokenRoll(tokenId);
    if(roll > previous) {
      cnmNFT.setRoll(tokenId, roll);
    }

    emit Roll(msg.sender, tokenId, roll);
    return roll;
  }

  function mintCost(uint256 tokenId, uint256 maxTokens) public pure returns (uint256) {

    if (tokenId <= maxTokens / 5) return 0;
    if (tokenId <= maxTokens * 2 / 5) return 20000 ether;
    if (tokenId <= maxTokens * 4 / 5) return 40000 ether;
    return 80000 ether;
  }


  function selectRecipient(uint256 seed) internal view returns (address) {

    uint16 mintedNum = cnmNFT.minted();
    uint256 paidToken = cnmNFT.getPaidTokens();
    if (mintedNum < paidToken) {
      return _msgSender();
    }

    if (((seed >> 245) % 10) != 0) return _msgSender(); // top 10 bits haven't been used

    address thief = habitat.randomCatOwner(seed >> 144); // 144 bits reserved for trait selection
    if (thief == address(0x0)) return _msgSender();
    return thief;
  }



  function setPaused(bool _paused) external requireContractsSet onlyOwner {

    if (_paused) _pause();
    else _unpause();
  }

  function setAllowCommits(bool allowed) external onlyOwner {

    allowCommits = allowed;
  }

  function setPendingMintAmt(uint256 pendingAmt) external onlyOwner {

    pendingMintAmt = uint16(pendingAmt);
  }

  function addAdmin(address addr) external onlyOwner {

      admins[addr] = true;
  }

  function removeAdmin(address addr) external onlyOwner {

      admins[addr] = false;
  }

  function withdraw() external onlyOwner {

    payable(owner()).transfer(address(this).balance);
  }

  function toggleWhitelistActive() external onlyOwner {

    isWhitelistActive = !isWhitelistActive;
  }

  function togglePublicSale() external onlyOwner {

    isPublicActive = !isPublicActive;
  }

  function setMaxPerWallet(uint256 _amount) external onlyOwner {

    maxPerWallet = _amount;
  }

  function setRoot(bytes32 _root) external onlyOwner {

    root = _root;
  }

  function setPrice(uint256 _price) external onlyOwner {

    MINT_PRICE = _price;
  }

  function setRollPrice(uint256 _price) external onlyOwner {

    ROLL_COST = _price * 1 ether;
  }

  function _leaf(address account, uint256 tokenId)
  internal pure returns (bytes32)
  {

      return keccak256(abi.encodePacked(tokenId, account));
  }

  function _verify(bytes32 leaf, bytes32[] memory proof)
  internal view returns (bool)
  {

      return MerkleProof.verify(proof, root, leaf);
  }
}