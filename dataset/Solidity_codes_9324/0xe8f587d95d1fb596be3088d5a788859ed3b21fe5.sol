
pragma solidity ^0.5.16;


interface NFTFactory{

    function getMeta( uint256 resId ) external view returns (uint256, uint256, uint256, uint256, uint256, uint256, address);

    function getFactory( uint256 nftId ) external view returns (address);

}


interface IAnftToken{

    function mint(address to, uint256 tokenId) external returns (bool) ;

    function burn(uint256 tokenId) external;

    function safeMint(address to, uint256 tokenId, bytes calldata _data) external returns (bool);

    function ownerOf(uint256 tokenId) external view returns (address);

    function totalSupply() external returns (uint256);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

}

interface IPlayerLink {

    function settleReward( address from,uint256 amount ) external returns (uint256);

    function bindRefer( address from,string calldata  affCode )  external returns (bool);

    function hasRefer(address from) external returns(bool);


}

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

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
}


contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

contract IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);


    function ownerOf(uint256 tokenId) public view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function transferFrom(address from, address to, uint256 tokenId) public;

    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

}

contract IERC721Enumerable is IERC721 {

    function totalSupply() public view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) public view returns (uint256);

}


contract IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);

}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}



library Counters {

    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {

        counter._value = counter._value.sub(1);
    }
}


contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}


contract ERC721 is Context, ERC165, IERC721 {

    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (uint256 => address) private _tokenOwner;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => Counters.Counter) private _ownedTokensCount;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    constructor () public {
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    function balanceOf(address owner) public view returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");

        return _ownedTokensCount[owner].current();
    }

    function ownerOf(uint256 tokenId) public view returns (address) {

        address owner = _tokenOwner[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");

        return owner;
    }

    function approve(address to, uint256 tokenId) public {

        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address to, bool approved) public {

        require(to != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][to] = approved;
        emit ApprovalForAll(_msgSender(), to, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransferFrom(from, to, tokenId, _data);
    }

    function _safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) internal {

        _transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal {

        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {

        require(ownerOf(tokenId) == owner, "ERC721: burn of token that is not own");

        _clearApproval(tokenId);

        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    function _burn(uint256 tokenId) internal {

        _burn(ownerOf(tokenId), tokenId);
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {

        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }
        (bool success, bytes memory returndata) = to.call(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ));
        if (!success) {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert("ERC721: transfer to non ERC721Receiver implementer");
            }
        } else {
            bytes4 retval = abi.decode(returndata, (bytes4));
            return (retval == _ERC721_RECEIVED);
        }
    }

    function _clearApproval(uint256 tokenId) private {

        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}


contract ERC721Enumerable is Context, ERC165, ERC721, IERC721Enumerable {

    mapping(address => uint256[]) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor () public {
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {

        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view returns (uint256) {

        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {

        require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {

        super._transferFrom(from, to, tokenId);

        _removeTokenFromOwnerEnumeration(from, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);
    }

    function _mint(address to, uint256 tokenId) internal {

        super._mint(to, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {

        super._burn(owner, tokenId);

        _removeTokenFromOwnerEnumeration(owner, tokenId);
        _ownedTokensIndex[tokenId] = 0;

        _removeTokenFromAllTokensEnumeration(tokenId);
    }

    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {

        return _ownedTokens[owner];
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {

        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {

        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {


        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        _ownedTokens[from].length--;

    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {


        uint256 lastTokenIndex = _allTokens.length.sub(1);
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        _allTokens.length--;
        _allTokensIndex[tokenId] = 0;
    }
}


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);

    function mint(address account, uint amount) external;

    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


contract Governance {


    address public _governance;

    constructor() public {
        _governance = tx.origin;
    }

    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyGovernance {

        require(msg.sender == _governance, "not governance");
        _;
    }

    function setGovernance(address governance)  public  onlyGovernance
    {

        require(governance != address(0), "new governance the zero address");
        emit GovernanceTransferred(_governance, governance);
        _governance = governance;
    }


}

contract NFTRewardA is Governance {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 public _artd = IERC20(0xA23F8462d90dbc60a06B9226206bFACdEAD2A26F);
    IAnftToken public _anftToken = IAnftToken(0x99a7e1188CE9a0b7514d084878DFb8A405D8529F);
    address public _anftFactory = 0xC1046b1e2941248da9926d57719eEcb61C676719;
    address public _playerLink = address(0x4eD7A3721F203Cf108b4279061B36CC20b14E57A);

    address public _teamWallet = 0x3b2b4f84cFE480289df651bE153c147fa417Fb8A;
    address public _rewardPool = 0x4D732FA01032b41eE0fA152398B22Bfab6689DCb;

    uint256 public constant DURATION = 30 days;
    uint256 public _initReward = 500 * 1e18;
    uint256 public _startTime =  now + 3650 days;
    uint256 public _periodFinish = 0;
    uint256 public _rewardRate = 0;
    uint256 public _lastUpdateTime;
    uint256 public _rewardPerWeightStored;

    uint256 public _teamRewardRate = 500;
    uint256 public _poolRewardRate = 1000;
    uint256 public _baseRate = 10000;
    uint256 public _punishTime = 5 days;
  
    mapping(address => uint256) public _userRewardPerWeightPaid;
    mapping(address => uint256) public _userrewards;
    mapping(uint256 => uint256) public _idRewardPerWeightPaid;
    mapping(uint256 => uint256) public _idrewards;
    mapping(address => uint256) public _lastStakedTime;

    bool public _hasStart = false;
    bool public _hasRewardStart = false;
    uint256 public _fixRateBase = 100000;
    
    uint256 public _totalWeight;
    mapping(address => uint256) public _weightBalances;
    mapping(address => uint256) public _artdBalances;
    mapping(address => uint256[]) public _playerAnft;
    mapping(uint256 => uint256) public _anftMapIndex;
    
    uint256 private _totalPower;
    mapping(address => uint256) private _powerBalances;

    struct User {
        address owner;
        uint256 nftId;
        uint index;
    }
    mapping (uint256 => User) private users;
    uint256[] private usersRecords;

    event ReadyStake(uint256 timestamp);
    event RewardReserved(uint256 reward);
    event StakedANft(address indexed user, uint256 anftId);
    event WithdrawnANft(address indexed user, uint256 anftId);
    event RewardPaid(address indexed user, uint256 reward);
    event NFTReceived(address operator, address from, uint256 tokenId, bytes data);
    event NewJoinId(uint256 indexed anftId, uint index, address owner);

    modifier checkHalve() {

        if (block.timestamp >= _periodFinish) {
            _initReward = _initReward.mul(50).div(100);

            _artd.mint(address(this), _initReward);

            _rewardRate = _initReward.div(DURATION);
            _periodFinish = block.timestamp.add(DURATION);
            emit RewardReserved(_initReward);
        }
        _;
    }
    
    modifier checkStart() {

        require(block.timestamp > _startTime, "not start");
        _;
    }

    modifier updateReward(address account) {

        _rewardPerWeightStored = rewardPerWeight();
        _lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            _userrewards[account] = earned(account);
            _userRewardPerWeightPaid[account] = _rewardPerWeightStored;
        }
        _;
    }
    
    modifier updateIdReward(uint256 anftId) {

        _rewardPerWeightStored = rewardPerWeight();
        _lastUpdateTime = lastTimeRewardApplicable();
        if (anftId != 0) {
            _idrewards[anftId] = earnedId(anftId);
            _idRewardPerWeightPaid[anftId] = _rewardPerWeightStored;
        }
        _;
    }  

    function addUserId(uint256 _nftid) private returns(bool success)
    {

        users[_nftid].nftId = _nftid;
        users[_nftid].owner = msg.sender;
        users[_nftid].index = usersRecords.push(_nftid) -1;
        emit NewJoinId( _nftid, users[_nftid].index, users[_nftid].owner );
        return true;
    }

    function quitUser(uint256 _nftid) private returns(uint index)
    {

        uint toDelete = users[_nftid].index;
        uint256 lastIndex = usersRecords[usersRecords.length-1];
        usersRecords[toDelete] = lastIndex;
        users[lastIndex].index = toDelete; 
        usersRecords.length--;
        return toDelete;   
    }    
    
    function getStaker(uint256 _nftid) public view returns( address )
    {

        return users[_nftid].owner;
    }   

    function UserRecord(uint256 number) public view returns( uint256 )
    {

        return usersRecords[number];
    }   

    function stakeInfo(uint256 number) public view returns( uint256, address, uint256, uint256 )
    {

        uint256 nftid = usersRecords[number];
        address staker = users[nftid].owner;
        uint256 weight = getNftWeight(nftid);
        uint256 earnedbyid = earnedId(nftid);
        return (nftid, staker, weight, earnedbyid);
    }   

    function stakeCount() public view returns( uint )
    {

        return usersRecords.length;
    }  

    function setNftFactoy(address anftfactory) external onlyGovernance{

        _anftFactory = anftfactory;
    }
    
    function seize(IERC20 token, uint256 amount) external onlyGovernance{

        require(token != _artd, "reward");
        token.safeTransfer(_governance, amount);
    }
    
    function lastTimeRewardApplicable() public view returns (uint256) {

        return Math.min(block.timestamp, _periodFinish);
    }

    function rewardPerWeight() public view returns (uint256) {

       
        if( _hasRewardStart == false){
            return _rewardPerWeightStored;
        }
          
        if (totalWeight() == 0) {
            return _rewardPerWeightStored;
        }
        return
            _rewardPerWeightStored.add(
                lastTimeRewardApplicable()
                    .sub(_lastUpdateTime)
                    .mul(_rewardRate)
                    .mul(1e18)
                    .div(totalWeight())
            );
    }

    function earned(address account) public view returns (uint256) {

        return
            getWeight(account)
                .mul(rewardPerWeight().sub(_userRewardPerWeightPaid[account]))
                .div(1e18)
                .add(_userrewards[account]);
    }

    function earnedId(uint256 anftId) public view returns (uint256) {

        return
            getNftWeight(anftId)
                .mul(rewardPerWeight().sub(_idRewardPerWeightPaid[anftId]))
                .div(1e18)
                .add(_idrewards[anftId]);
    }
    
    function getNftWeight( uint256 anftId ) public view returns ( uint256 )
    {

        uint256 era;
        uint256 grade;
        uint256 promote;
        uint256 artdAmount;
        uint256 apwrAmount;
        uint256 skill;
        address factory;

        NFTFactory _nftfactory =  NFTFactory(_anftFactory);
        (era, grade, promote, artdAmount, apwrAmount, skill, factory) = _nftfactory.getMeta(anftId);

        require(artdAmount > 0,"No ARTD amount error");
        uint256 weight = 0;
        require(era > 0, "era zero error");
           
        uint256 artd =  artdAmount.div(1e18);
        uint256 apwr =  apwrAmount.div(1e16);
        uint lv1 = 0;
        uint lv2 = 0;
        uint lv3 = 0;
        if( artd >= 1)
            lv1 = 1;
        if( apwr >= 3)
            lv2 = 1;
        if( skill >= 1)
            lv3 = 1;
            
        weight = lv1 + lv2 + lv3;
            
        return weight;
    }

    function getWeight(address account) public view returns (uint256) {

        return _weightBalances[account];
    }

    function totalWeight() public view returns (uint256) {

        return _totalWeight;
    }
    
    
    function stakeAnft(uint256 anftId, string memory affCode)
        public
        updateReward(msg.sender)
        checkHalve
        checkStart
    {

        uint256[] storage anftIds = _playerAnft[msg.sender];
        if (anftIds.length == 0) {
            anftIds.push(0);    
            _anftMapIndex[0] = 0;
        }
        anftIds.push(anftId);
        _anftMapIndex[anftId] = anftIds.length - 1;
        
        if( _idRewardPerWeightPaid[anftId] == 0 )
        {
            _idRewardPerWeightPaid[anftId] = rewardPerWeight();
            _idrewards[anftId] = 0;
        }

        address owner = NFTownerOf(anftId);
        require(msg.sender == owner);
        
        uint256 stakeweight = 0;

        require(anftId > 0, "Cannot stake zero ID");
        stakeweight = getNftWeight(anftId);

        _totalWeight = _totalWeight.add(stakeweight);
        _weightBalances[msg.sender] = _weightBalances[msg.sender].add(stakeweight);

        _anftToken.safeTransferFrom(msg.sender, address(this), anftId);

        if (!IPlayerLink(_playerLink).hasRefer(msg.sender)) {
            IPlayerLink(_playerLink).bindRefer(msg.sender, affCode);
        }
        
        addUserId(anftId);
        _lastStakedTime[msg.sender] = now;
        emit StakedANft(msg.sender, anftId);        
   
    }
    
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4) {

        if(_hasStart == false) {
            return 0;
        }

        emit NFTReceived(operator, from, tokenId, data);
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    function withdrawAnft(uint256 anftId)
        public
        updateReward(msg.sender)
        updateIdReward(anftId)
        checkHalve
        checkStart
    {

        require(anftId > 0, "the anftId error");
        
        uint256[] memory anftIds = _playerAnft[msg.sender];
        uint256 anftIndex = _anftMapIndex[anftId];
        
        require(anftIds[anftIndex] == anftId, "not AnftId owner");

        uint256 anftArrayLength = anftIds.length-1;
        uint256 tailId = anftIds[anftArrayLength];

        _playerAnft[msg.sender][anftIndex] = tailId;
        _playerAnft[msg.sender][anftArrayLength] = 0;
        _playerAnft[msg.sender].length--;
        _anftMapIndex[tailId] = anftIndex;
        _anftMapIndex[anftId] = 0;

        uint256 weight = 0;

        weight = getNftWeight(anftId);

        if( weight > _totalWeight )
        {
            _totalWeight = 0;
        }
        else
        {
            _totalWeight = _totalWeight.sub(weight);
        }
        
        if( weight > _powerBalances[msg.sender])
        {
            _weightBalances[msg.sender] = 0;
        }
        else
        {
            _weightBalances[msg.sender] = _weightBalances[msg.sender].sub(weight);
        }
        
        _anftToken.safeTransferFrom(address(this), msg.sender, anftId);
        quitUser(anftId);
        
        emit WithdrawnANft(msg.sender, anftId);
    }        

    function withdrawall()
        public
        checkStart
    {

        uint256[] memory anftId = _playerAnft[msg.sender];
        for (uint8 index = 1; index < anftId.length; index++) {
            if (anftId[index] > 0) {
                withdrawAnft(anftId[index]);
            }
        }
    }

    function getPlayerIds( address account ) public view returns( uint256[] memory anftId )
    {

        anftId = _playerAnft[account];
    }

    function exit() external {

        withdrawall();
        getReward();
    }

    function getReward() public 
      updateReward(msg.sender) 
      checkHalve 
      checkStart 
    {

        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            _userrewards[msg.sender] = 0;

            uint256 fee = IPlayerLink(_playerLink).settleReward(msg.sender, reward);
            if(fee > 0){
                _artd.safeTransfer(_playerLink, fee);
            }
            
            uint256 teamReward = reward.mul(_teamRewardRate).div(_baseRate);
            if(teamReward>0){
                _artd.safeTransfer(_teamWallet, teamReward);
            }
            uint256 leftReward = reward.sub(fee).sub(teamReward);
            uint256 poolReward = 0;

            if(now  < (_lastStakedTime[msg.sender] + _punishTime) ){
                poolReward = leftReward.mul(_poolRewardRate).div(_baseRate);
            }
            if(poolReward>0){
                _artd.safeTransfer(_rewardPool, poolReward);
                leftReward = leftReward.sub(poolReward);
            }

            if(leftReward>0){
                _artd.safeTransfer(msg.sender, leftReward );
            }
    
            uint256[] memory anftId = _playerAnft[msg.sender];
            uint256 nftid = 0;
            
            for (uint8 index = 1; index < anftId.length; index++) {
                if (anftId[index] > 0) 
                {
                    nftid = anftId[index];
                    _idrewards[nftid] = 0;
                    _idRewardPerWeightPaid[nftid] = 0;
                }
            }
        
            emit RewardPaid(msg.sender, leftReward);
        }
 
    }

    function readyNFTStake( )
        external
        onlyGovernance
    {

        require(_hasStart == false, "has started");
        _hasStart = true;

         _startTime = now;
         
        emit ReadyStake(now);
    }

    function startNFTReward(uint256 startTime)
        external
        onlyGovernance
        updateReward(address(0))
        updateIdReward(0)
    {

        require(_hasStart == true, "To start NFTStake firstly");
        _hasRewardStart = true;
        
        _startTime = startTime;

        _rewardRate = _initReward.div(DURATION); 
        _artd.mint(address(this), _initReward);

        _lastUpdateTime = _startTime;
        _periodFinish = _startTime.add(DURATION);

        emit RewardReserved(_initReward);
    }


    function reserveMintAmount(uint256 reward)
        external
        onlyGovernance
        updateReward(address(0))
        updateIdReward(0)
    {

        _artd.mint(address(this), reward);
        if (block.timestamp >= _periodFinish) {
            _rewardRate = reward.div(DURATION);
        } else {
            uint256 remaining = _periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(_rewardRate);
            _rewardRate = reward.add(leftover).div(DURATION);
        }
        _lastUpdateTime = block.timestamp;
        _periodFinish = block.timestamp.add(DURATION);
        emit RewardReserved(reward);
    }

    function setTeamRewardRate( uint256 teamRewardRate ) public onlyGovernance {

        _teamRewardRate = teamRewardRate;
    }

    function setPoolRewardRate( uint256  poolRewardRate ) public onlyGovernance{

        _poolRewardRate = poolRewardRate;
    }

    function setWithDrawPunishTime( uint256  punishTime ) public onlyGovernance{

        _punishTime = punishTime;
    }

    function NFTownerOf(uint256 nftId) public view returns (address) {

        IAnftToken _anftx =  IAnftToken(_anftToken);
        address owner = _anftx.ownerOf(nftId);
        require(owner != address(0));
        return owner;
    }
    
}