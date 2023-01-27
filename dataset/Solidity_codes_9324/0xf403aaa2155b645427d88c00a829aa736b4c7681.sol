
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

interface LinkTokenInterface {


  function allowance(
    address owner,
    address spender
  )
    external
    view
    returns (
      uint256 remaining
    );


  function approve(
    address spender,
    uint256 value
  )
    external
    returns (
      bool success
    );


  function balanceOf(
    address owner
  )
    external
    view
    returns (
      uint256 balance
    );


  function decimals()
    external
    view
    returns (
      uint8 decimalPlaces
    );


  function decreaseApproval(
    address spender,
    uint256 addedValue
  )
    external
    returns (
      bool success
    );


  function increaseApproval(
    address spender,
    uint256 subtractedValue
  ) external;


  function name()
    external
    view
    returns (
      string memory tokenName
    );


  function symbol()
    external
    view
    returns (
      string memory tokenSymbol
    );


  function totalSupply()
    external
    view
    returns (
      uint256 totalTokensIssued
    );


  function transfer(
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );


  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  )
    external
    returns (
      bool success
    );


  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );


}// MIT
pragma solidity ^0.8.0;

contract VRFRequestIDBase {


  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  )
    internal
    pure
    returns (
      uint256
    )
  {

    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  function makeRequestId(
    bytes32 _keyHash,
    uint256 _vRFInputSeed
  )
    internal
    pure
    returns (
      bytes32
    )
  {

    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}// MIT
pragma solidity ^0.8.0;



abstract contract VRFConsumerBase is VRFRequestIDBase {

  function fulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    internal
    virtual;

  uint256 constant private USER_SEED_PLACEHOLDER = 0;

  function requestRandomness(
    bytes32 _keyHash,
    uint256 _fee
  )
    internal
    returns (
      bytes32 requestId
    )
  {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    uint256 vRFSeed  = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface immutable internal LINK;
  address immutable private vrfCoordinator;

  mapping(bytes32 /* keyHash */ => uint256 /* nonce */) private nonces;

  constructor(
    address _vrfCoordinator,
    address _link
  ) {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  function rawFulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    external
  {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}// Apache-2.0
pragma solidity ^0.8.0;


contract RandomNumberConsumer is VRFConsumerBase {

    bytes32 internal keyHash;
    uint256 internal fee;

    mapping(bytes32 => address) private requestIdToAddress;

    constructor(
        address _vrfCoordinator,
        address _LINKToken,
        bytes32 _keyHash,
        uint256 _fee
    )
        VRFConsumerBase(
            _vrfCoordinator, // VRF Coordinator
            _LINKToken // LINK Token
        )
    {
        keyHash = _keyHash;
        fee = _fee;
    }

    function getRandomNumber() public returns (bytes32) {

        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK - fill contract with faucet"
        );

        bytes32 requestId = requestRandomness(keyHash, fee);

        requestIdToAddress[requestId] = msg.sender;

        return requestId;
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        virtual
        override
    {

        address requestAddress = requestIdToAddress[requestId];
        saveRandomNumber(requestAddress, randomness);
    }

    function expand(uint256 randomValue, uint256 n)
        public
        pure
        returns (uint256[] memory expandedValues)
    {

        expandedValues = new uint256[](n);
        expandedValues[0] = randomValue;
        for (uint256 i = 0; i < n; i++) {
            expandedValues[i] = uint256(keccak256(abi.encode(randomValue, i)));
        }
        return expandedValues;
    }

    function saveRandomNumber(address addr, uint256 randomNumber)
        internal
        virtual
    {}

}// Apache-2.0
pragma solidity ^0.8.0;

interface INomoVault {
    function nftSaleCallback(
        uint256[] memory tokensIds,
        uint256[] memory prices
    ) external;
}// Apache-2.0
pragma solidity 0.8.9;


contract NFTAirdropMechanic is
    Ownable,
    ReentrancyGuard,
    RandomNumberConsumer
{
    using SafeMath for uint256;
    using Address for address;

    uint256[] private tokens;
    address[] public eligible;
    bool public isAirdropExecuted;
    uint256 public initialTokensLength;
    address public tokensVault;
    address public erc721Address;
    bytes32 public lastRequestId;

    mapping(uint256 => bool) public addedTokens;
    mapping(address => uint256) private addressToRandomNumber;

    event LogTokensBought(uint256[] _transferredTokens);
    event LogTokensAirdropped(uint256[] _airdroppedTokens);
    event LogInitialTokensLengthSet(uint256 _initialTokensLength);
    event LogEligibleSet(address[] _eligible);
    event LogTokensAdded(uint256 length);
    event LogRandomNumberRequested(address from);
    event LogRandomNumberSaved(address from);
    event LogSelectedUsers(address[] privileged);

    modifier isValidAddress(address addr) {
        require(addr != address(0), "Not a valid address!");
        _;
    }

    modifier isValidRandomNumber() {
        require(
            addressToRandomNumber[msg.sender] != 0,
            "Invalid random number"
        );
        _;
    }

    constructor(
        address _erc721Address,
        address _tokensVault,
        address _vrfCoordinator,
        address _LINKToken,
        bytes32 _keyHash,
        uint256 _fee
    )
        isValidAddress(_erc721Address)
        isValidAddress(_tokensVault)
        RandomNumberConsumer(_vrfCoordinator, _LINKToken, _keyHash, _fee)
    {
        erc721Address = _erc721Address;
        tokensVault = _tokensVault;
    }

    function addTokensToCollection(uint256[] memory tokensArray)
        external
        onlyOwner
    {
        require(
            tokensArray.length > 0,
            "Tokens array must include at least one item"
        );

        for (uint256 i = 0; i < tokensArray.length; i++) {
            require(
                !addedTokens[tokensArray[i]],
                "Token has been already added"
            );
            addedTokens[tokensArray[i]] = true;
            tokens.push(tokensArray[i]);
        }

        emit LogTokensAdded(tokensArray.length);
    }

    function setInitialTokensLength(uint256 _initialTokensLength)
        public
        onlyOwner
    {
        require(_initialTokensLength > 0, "must be above 0!");
        initialTokensLength = _initialTokensLength;
        emit LogInitialTokensLengthSet(initialTokensLength);
    }

    function setEligible(address[] memory members) public onlyOwner {
        require(
            members.length > 0 && members.length <= 100,
            "Eligible members array length must be in the bounds of 1 and 100"
        );

        for (uint256 i = 0; i < members.length; i++) {
            eligible.push(members[i]);
        }

        emit LogEligibleSet(members);
    }

    function getRandomValue() public {
        lastRequestId = getRandomNumber();

        emit LogRandomNumberRequested(msg.sender);
    }

    function saveRandomNumber(address from, uint256 n) internal override {
        addressToRandomNumber[from] = n;

        emit LogRandomNumberSaved(from);
    }

    function filterEligible(uint256 privilegedMembers)
        public
        onlyOwner
        isValidRandomNumber
    {
        require(
            eligible.length > privilegedMembers,
            "Eligible members must be more than privileged"
        );

        uint256 usersToRemove = eligible.length - privilegedMembers;

        uint256[] memory randomNumbers = expand(
            addressToRandomNumber[msg.sender],
            usersToRemove
        );
        
        addressToRandomNumber[msg.sender] = 0;

        for (uint256 i = 0; i < usersToRemove; i++) {
            uint256 randomNumber = randomNumbers[i] % eligible.length;
            eligible[randomNumber] = eligible[eligible.length - 1];
            eligible.pop();
        }

        emit LogSelectedUsers(eligible);
    }

    function executeAirdrop() public onlyOwner isValidRandomNumber {
        require(!isAirdropExecuted, "Airdrop has been executed");
        require(
            (tokens.length >= eligible.length) && (eligible.length > 0),
            "Invalid airdrop parameters"
        );

        uint256[] memory randomNumbers = expand(
            addressToRandomNumber[msg.sender],
            eligible.length
        );
        uint256[] memory airdroppedTokens = new uint256[](eligible.length);

        isAirdropExecuted = true;

        addressToRandomNumber[msg.sender] = 0;

        for (uint256 i = 0; i < eligible.length; i++) {
            uint256 randomNumber = randomNumbers[i] % tokens.length;
            uint256 tokenId = tokens[randomNumber];
            airdroppedTokens[i] = tokenId;
            tokens[randomNumber] = tokens[tokens.length - 1];
            tokens.pop();

            IERC721(erc721Address).safeTransferFrom(
                tokensVault,
                eligible[i],
                tokenId
            );
        }

        emit LogTokensAirdropped(airdroppedTokens);
    }

    function getTokensLeft() public view returns (uint256) {
        return tokens.length;
    }
}