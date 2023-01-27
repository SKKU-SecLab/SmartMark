

pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity ^0.5.0;


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


pragma solidity ^0.5.0;


contract IERC721Enumerable is IERC721 {

    function totalSupply() public view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) public view returns (uint256);

}


pragma solidity ^0.5.0;

contract IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);

}


pragma solidity ^0.5.5;

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


pragma solidity ^0.5.0;


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


pragma solidity ^0.5.0;


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


pragma solidity ^0.5.0;








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


pragma solidity ^0.5.0;





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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;





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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;


interface IPool {

    function totalSupply( ) external view returns (uint256);

    function balanceOf( address player ) external view returns (uint256);

}


pragma solidity ^0.5.0;


interface IPlayerBook {

    function settleReward( address from,uint256 amount ) external returns (uint256);

    function bindRefer( address from,string calldata  affCode )  external returns (bool);

    function hasRefer(address from) external returns(bool);


}


pragma solidity ^0.5.0;

interface IGegoFactory {

    function getGego(uint256 tokenId)
        external view
        returns (
            uint256 grade,
            uint256 quality,
            uint256 degoAmount,
            uint256 createdTime,
            uint256 blockNum,
            uint256 resId,
            address author
        );



    function getQualityBase() external view 
        returns (uint256 );

}


pragma solidity ^0.5.0;



contract IGegoToken is IERC721 {

    function mint(address to, uint256 tokenId) external returns (bool) ;

    function burn(uint256 tokenId) external;

}


pragma solidity ^0.5.0;













    
contract NFTReward is IPool,Governance {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 public _dego = IERC20(0x0);
    IGegoFactory public _gegoFactory = IGegoFactory(0x0);
    IGegoToken public _gegoToken = IGegoToken(0x0);
    address public _playerBook = address(0x0);

    address public _teamWallet = 0x3D0a845C5ef9741De999FC068f70E2048A489F2b;
    address public _rewardPool = 0xEA6dEc98e137a87F78495a8386f7A137408f7722;

    uint256 public constant DURATION = 7 days;
    uint256 public _initReward = 52500 * 1e18;
    uint256 public _startTime =  now + 365 days;
    uint256 public _periodFinish = 0;
    uint256 public _rewardRate = 0;
    uint256 public _lastUpdateTime;
    uint256 public _rewardPerTokenStored;

    uint256 public _teamRewardRate = 500;
    uint256 public _poolRewardRate = 1000;
    uint256 public _baseRate = 10000;
    uint256 public _punishTime = 3 days;

    mapping(address => uint256) public _userRewardPerTokenPaid;
    mapping(address => uint256) public _rewards;
    mapping(address => uint256) public _lastStakedTime;

    bool public _hasStart = false;
    uint256 public _fixRateBase = 100000;
    
    uint256 public _totalWeight;
    mapping(address => uint256) public _weightBalances;
    mapping(uint256 => uint256) public _stakeWeightes;
    mapping(uint256 => uint256) public _stakeBalances;

    uint256 public _totalBalance;
    mapping(address => uint256) public _degoBalances;
    uint256 public _maxStakedDego = 200 * 1e18;

    mapping(address => uint256[]) public _playerGego;
    mapping(uint256 => uint256) public _gegoMapIndex;
    


    event RewardAdded(uint256 reward);
    event StakedGEGO(address indexed user, uint256 amount);
    event WithdrawnGego(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event NFTReceived(address operator, address from, uint256 tokenId, bytes data);

    constructor(address dego, address gego, address gegoFactory,address playerBook) public {
        _dego = IERC20(dego);
        _gegoToken = IGegoToken(gego);
        _gegoFactory = IGegoFactory(gegoFactory);
        _playerBook = playerBook;
    }
    

    modifier updateReward(address account) {

        _rewardPerTokenStored = rewardPerToken();
        _lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            _rewards[account] = earned(account);
            _userRewardPerTokenPaid[account] = _rewardPerTokenStored;
        }
        _;
    }

    function setMaxStakedDego(uint256 amount) external onlyGovernance{

        _maxStakedDego = amount;
    }

    function seize(IERC20 token, uint256 amount) external onlyGovernance{

        require(token != _dego, "reward");
        token.safeTransfer(_governance, amount);
    }
    
    function seizeErc721(IERC721 token, uint256 tokenId) external 
    {

        require(token != _gegoToken, "gego stake");
        token.safeTransferFrom(address(this), _governance, tokenId);
    }

    function lastTimeRewardApplicable() public view returns (uint256) {

        return Math.min(block.timestamp, _periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {

        if (totalSupply() == 0) {
            return _rewardPerTokenStored;
        }
        return
            _rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(_lastUpdateTime)
                    .mul(_rewardRate)
                    .mul(1e18)
                    .div(totalSupply())
            );
    }

    function earned(address account) public view returns (uint256) {

        return
            balanceOf(account)
                .mul(rewardPerToken().sub(_userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(_rewards[account]);
    }

    

    function getFixRate(uint256 grade,uint256 quality) public pure returns (uint256){


        require(grade > 0 && grade <7, "the gego not dego");

        uint256 unfold = 0;

        if( grade == 1 ){
            unfold = quality*10000/5000;
            return unfold.add(110000);
        }else if( grade == 2){
            unfold = quality.sub(5000)*10000/3000;
            return unfold.add(120000);
        }else if( grade == 3){
            unfold = quality.sub(8000)*10000/1000;
           return unfold.add(130000);
        }else if( grade == 4){
            unfold = quality.sub(9000)*20000/800;
           return unfold.add(140000);
        }else if( grade == 5){
            unfold = quality.sub(9800)*20000/180;
            return unfold.add(160000);
        }else{
            unfold = quality.sub(9980)*20000/20;
            return unfold.add(180000);
        }
    }

    function getStakeInfo( uint256 gegoId ) public view returns ( uint256 stakeRate, uint256 degoAmount){


        uint256 grade;
        uint256 quality;
        uint256 createdTime;
        uint256 blockNum;
        uint256 resId;
        address author;

        (grade, quality, degoAmount, createdTime,blockNum, resId, author) = _gegoFactory.getGego(gegoId);

        require(degoAmount > 0,"the gego not dego");

        stakeRate = getFixRate(grade,quality);
    }

    function stakeGego(uint256 gegoId, string memory affCode)
        public
        updateReward(msg.sender)
        checkHalve
        checkStart
    {


        uint256[] storage gegoIds = _playerGego[msg.sender];
        if (gegoIds.length == 0) {
            gegoIds.push(0);    
            _gegoMapIndex[0] = 0;
        }
        gegoIds.push(gegoId);
        _gegoMapIndex[gegoId] = gegoIds.length - 1;

        uint256 stakeRate;
        uint256 degoAmount;
        (stakeRate, degoAmount) = getStakeInfo(gegoId);

        uint256 stakedDegoAmount = _degoBalances[msg.sender];
        uint256 stakingDegoAmount = stakedDegoAmount.add(degoAmount) <= _maxStakedDego?degoAmount:_maxStakedDego.sub(stakedDegoAmount);


        if(stakingDegoAmount > 0){
            uint256 stakeWeight = stakeRate.mul(stakingDegoAmount).div(_fixRateBase);
            _degoBalances[msg.sender] = _degoBalances[msg.sender].add(stakingDegoAmount);

            _weightBalances[msg.sender] = _weightBalances[msg.sender].add(stakeWeight);

            _stakeBalances[gegoId] = stakingDegoAmount;
            _stakeWeightes[gegoId] = stakeWeight;
            
            _totalBalance = _totalBalance.add(stakingDegoAmount);
            _totalWeight = _totalWeight.add(stakeWeight);
        }

        _gegoToken.safeTransferFrom(msg.sender, address(this), gegoId);

        if (!IPlayerBook(_playerBook).hasRefer(msg.sender)) {
            IPlayerBook(_playerBook).bindRefer(msg.sender, affCode);
        }
        _lastStakedTime[msg.sender] = now;
        emit StakedGEGO(msg.sender, gegoId);
        
    }
    
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4) {

        if(_hasStart == false) {
            return 0;
        }

        emit NFTReceived(operator, from, tokenId, data);
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    function withdrawGego(uint256 gegoId)
        public
        updateReward(msg.sender)
        checkHalve
        checkStart
    {

        require(gegoId > 0, "the gegoId error");
        
        uint256[] memory gegoIds = _playerGego[msg.sender];
        uint256 gegoIndex = _gegoMapIndex[gegoId];
        
        require(gegoIds[gegoIndex] == gegoId, "not gegoId owner");

        uint256 gegoArrayLength = gegoIds.length-1;
        uint256 tailId = gegoIds[gegoArrayLength];

        _playerGego[msg.sender][gegoIndex] = tailId;
        _playerGego[msg.sender][gegoArrayLength] = 0;
        _playerGego[msg.sender].length--;
        _gegoMapIndex[tailId] = gegoIndex;
        _gegoMapIndex[gegoId] = 0;

        uint256 stakeWeight = _stakeWeightes[gegoId];
        _weightBalances[msg.sender] = _weightBalances[msg.sender].sub(stakeWeight);
        _totalWeight = _totalWeight.sub(stakeWeight);

        uint256 stakeBalance = _stakeBalances[gegoId];
        _degoBalances[msg.sender] = _degoBalances[msg.sender].sub(stakeBalance);
        _totalBalance = _totalBalance.sub(stakeBalance);



        _gegoToken.safeTransferFrom(address(this), msg.sender, gegoId);

        _stakeBalances[gegoId] = 0;
        _stakeWeightes[gegoId] = 0;

        emit WithdrawnGego(msg.sender, gegoId);
    }

    function withdraw()
        public
        checkStart
    {


        uint256[] memory gegoId = _playerGego[msg.sender];
        for (uint8 index = 1; index < gegoId.length; index++) {
            if (gegoId[index] > 0) {
                withdrawGego(gegoId[index]);
            }
        }
    }

    function getPlayerIds( address account ) public view returns( uint256[] memory gegoId )
    {

        gegoId = _playerGego[account];
    }

    function exit() external {

        withdraw();
        getReward();
    }

    function getReward() public updateReward(msg.sender) checkHalve checkStart {

        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            _rewards[msg.sender] = 0;

            uint256 fee = IPlayerBook(_playerBook).settleReward(msg.sender, reward);
            if(fee > 0){
                _dego.safeTransfer(_playerBook, fee);
            }
            
            uint256 teamReward = reward.mul(_teamRewardRate).div(_baseRate);
            if(teamReward>0){
                _dego.safeTransfer(_teamWallet, teamReward);
            }
            uint256 leftReward = reward.sub(fee).sub(teamReward);
            uint256 poolReward = 0;


            if(now  < (_lastStakedTime[msg.sender] + _punishTime) ){
                poolReward = leftReward.mul(_poolRewardRate).div(_baseRate);
            }
            if(poolReward>0){
                _dego.safeTransfer(_rewardPool, poolReward);
                leftReward = leftReward.sub(poolReward);
            }

            if(leftReward>0){
                _dego.safeTransfer(msg.sender, leftReward );
            }
      
            emit RewardPaid(msg.sender, leftReward);
        }
    }

    modifier checkHalve() {

        if (block.timestamp >= _periodFinish) {
            _initReward = _initReward.mul(50).div(100);

            _dego.mint(address(this), _initReward);

            _rewardRate = _initReward.div(DURATION);
            _periodFinish = block.timestamp.add(DURATION);
            emit RewardAdded(_initReward);
        }
        _;
    }
    
    modifier checkStart() {

        require(block.timestamp > _startTime, "not start");
        _;
    }

    function startNFTReward(uint256 startTime)
        external
        onlyGovernance
        updateReward(address(0))
    {

        require(_hasStart == false, "has started");
        _hasStart = true;
        
        _startTime = startTime;

        _rewardRate = _initReward.div(DURATION); 
        _dego.mint(address(this), _initReward);

        _lastUpdateTime = _startTime;
        _periodFinish = _startTime.add(DURATION);

        emit RewardAdded(_initReward);
    }


    function notifyMintAmount(uint256 reward)
        external
        onlyGovernance
        updateReward(address(0))
    {

        _dego.mint(address(this), reward);
        if (block.timestamp >= _periodFinish) {
            _rewardRate = reward.div(DURATION);
        } else {
            uint256 remaining = _periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(_rewardRate);
            _rewardRate = reward.add(leftover).div(DURATION);
        }
        _lastUpdateTime = block.timestamp;
        _periodFinish = block.timestamp.add(DURATION);
        emit RewardAdded(reward);
    }

    function setTeamRewardRate( uint256 teamRewardRate ) public onlyGovernance {

        _teamRewardRate = teamRewardRate;
    }

    function setPoolRewardRate( uint256  poolRewardRate ) public onlyGovernance{

        _poolRewardRate = poolRewardRate;
    }

    function totalSupply()  public view returns (uint256) {

        return _totalWeight;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _weightBalances[account];
    }
    
    function setWithDrawPunishTime( uint256  punishTime ) public onlyGovernance{

        _punishTime = punishTime;
    }

}