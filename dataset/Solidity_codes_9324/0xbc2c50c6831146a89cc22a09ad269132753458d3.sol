pragma solidity >=0.5.0 <0.9.0;

contract OwnableStorage {


    address public _admin;
    address public _governance;

    constructor() payable {
        _admin = msg.sender;
        _governance = msg.sender;
    }

    function setAdmin( address account ) public {

        require( isAdmin( msg.sender ));
        _admin = account;
    }

    function setGovernance( address account ) public {

        require( isAdmin( msg.sender ) || isGovernance( msg.sender ));
        _admin = account;
    }

    function isAdmin( address account ) public view returns( bool ) {

        return account == _admin;
    }

    function isGovernance( address account ) public view returns( bool ) {

        return account == _admin;
    }

}// MIT
pragma solidity >=0.5.0 <0.9.0;


contract Ownable{


    OwnableStorage _storage;

    function initialize( address storage_ ) public {

        _storage = OwnableStorage(storage_);
    }

    modifier OnlyAdmin(){

        require( _storage.isAdmin(msg.sender) );
        _;
    }

    modifier OnlyGovernance(){

        require( _storage.isGovernance( msg.sender ) );
        _;
    }

    modifier OnlyAdminOrGovernance(){

        require( _storage.isAdmin(msg.sender) || _storage.isGovernance( msg.sender ) );
        _;
    }

    function updateAdmin( address admin_ ) public OnlyAdmin {

        _storage.setAdmin(admin_);
    }

    function updateGovenance( address gov_ ) public OnlyAdminOrGovernance {

        _storage.setGovernance(gov_);
    }

}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


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
}// MIT
pragma solidity >=0.5.0 <0.9.0;


contract PunkRewardPool is Ownable, Initializable, ReentrancyGuard{

    using SafeMath for uint;
    using SafeERC20 for IERC20;

    bool isStarting = false;
    bool isInitialize = false;

    uint constant MAX_WEIGHT = 500;
    uint constant BLOCK_YEAR = 2102400;
    
    IERC20 Punk;
    uint startBlock;
    
    address [] forges;

    mapping ( address => uint ) totalSupplies;
    mapping ( address => mapping( address=>uint ) ) balances;
    mapping ( address => mapping( address=>uint ) ) checkPointBlocks;
    
    mapping( address => uint ) weights;
    uint weightSum;
    
    mapping( address => uint ) distributed;
    uint totalDistributed;

    function initializePunkReward( address storage_, address punk_ ) public initializer {

        require(!isInitialize);
        Ownable.initialize( storage_ );
        Punk = IERC20( punk_ );
        startBlock = 0;
        weightSum = 0;
        totalDistributed = 0;

        isInitialize = true;
    }

    function start() public OnlyAdmin{

        startBlock = block.number;
        isStarting = true;
    }
    
    function addForge( address forge ) public OnlyAdminOrGovernance {

        require( !_checkForge( forge ), "PUNK_REWARD_POOL: Already Exist" );
        forges.push( forge );
        weights[ forge ] = 0;
    }
    
    function setForge( address forge, uint weight ) public OnlyAdminOrGovernance {

        require( _checkForge( forge ), "PUNK_REWARD_POOL: Not Exist Forge" );
        ( uint minWeight , uint maxWeight ) = getWeightRange( forge );
        require( minWeight <= weight && weight <= maxWeight, "PUNK_REWARD_POOL: Invalid weight" );
        weights[ forge ] = weight;
        
        weightSum = 0;
        for( uint i = 0 ; i < forges.length ; i++ ){
            weightSum += weights[ forges[ i ] ];
        }

    }

    function getWeightRange( address forge ) public view returns( uint, uint ){

        if( forges.length == 0 ) return ( 1, MAX_WEIGHT );
        if( forges.length == 1 ) return ( weights[ forges[ 0 ] ], weights[ forges[ 0 ] ] );
        if( weightSum == 0 ) return ( 0, MAX_WEIGHT );
        
        uint highestWeight = 0;
        uint excludeWeight = weightSum.sub( weights[ forge ] );

        for( uint i = 0 ; i < forges.length ; i++ ){
            if( forges[ i ] != forge && highestWeight < weights[ forges[ i ] ] ){
                highestWeight = weights[ forges[ i ] ];
            }
        }

        if( highestWeight > excludeWeight.sub( highestWeight ) ){
            return ( highestWeight.sub( excludeWeight.sub( highestWeight ) ), MAX_WEIGHT < excludeWeight ? MAX_WEIGHT : excludeWeight );
        }else{
            return ( 0, MAX_WEIGHT < excludeWeight ? MAX_WEIGHT : excludeWeight );
        }
    }

    function claimPunk( ) public {

        claimPunk( msg.sender );
    }
    
    function claimPunk( address to ) public {

        if( isStarting ){
            for( uint i = 0 ; i < forges.length ; i++ ){
                address forge = forges[i];
                uint reward = getClaimPunk( forge, to );
                checkPointBlocks[ forge ][ to ] = block.number;
                if( reward > 0 ) Punk.safeTransfer( to, reward );
                distributed[ forge ] = distributed[ forge ].add( reward );
                totalDistributed = totalDistributed.add( reward );
            }
        }
    }

    function claimPunk( address forge, address to ) public nonReentrant {

        if( isStarting ){
            uint reward = getClaimPunk( forge, to );
            checkPointBlocks[ forge ][ to ] = block.number;
            if( reward > 0 ) Punk.safeTransfer( to, reward );
            distributed[ forge ] = distributed[ forge ].add( reward );
            totalDistributed = totalDistributed.add( reward );
        }
    }
    
    function staking( address forge, uint amount ) public {

        staking( forge, amount, msg.sender );
    }
    
    function unstaking( address forge, uint amount ) public {

        unstaking( forge, amount, msg.sender );
    }
    
    function staking( address forge, uint amount, address from ) public nonReentrant {

        require( msg.sender == from || _checkForge( msg.sender ), "REWARD POOL : NOT ALLOWD" );
        claimPunk( from );
        checkPointBlocks[ forge ][ from ] = block.number;
        IERC20( forge ).safeTransferFrom( from, address( this ), amount );
        balances[ forge ][ from ] = balances[ forge ][ from ].add( amount );
        totalSupplies[ forge ] = totalSupplies[ forge ].add( amount );
    }
    
    function unstaking( address forge, uint amount, address from ) public nonReentrant {

        require( msg.sender == from || _checkForge( msg.sender ), "REWARD POOL : NOT ALLOWD" );
        claimPunk( from );
        checkPointBlocks[ forge ][ from ] = block.number;
        balances[ forge ][ from ] = balances[ forge ][ from ].sub( amount );
        IERC20( forge ).safeTransfer( from, amount );
        totalSupplies[ forge ] = totalSupplies[ forge ].sub( amount );
    }
    
    function _checkForge( address forge ) internal view returns( bool ){

        bool check = false;
        for( uint  i = 0 ; i < forges.length ; i++ ){
            if( forges[ i ] == forge ){
                check = true;
                break;
            }
        }
        return check;
    }
    
    function _calcRewards( address forge, address user, uint fromBlock, uint currentBlock ) internal view returns( uint ){

        uint balance = balances[ forge ][ user ];
        if( balance == 0 ) return 0;
        uint totalSupply = totalSupplies[ forge ];
        uint weight = weights[ forge ];
        
        uint startPeriod = _getPeriodFromBlock( fromBlock );
        uint endPeriod = _getPeriodFromBlock( currentBlock );
        
        if( startPeriod == endPeriod ){
            
            uint during = currentBlock.sub( fromBlock ).mul( balance ).mul( weight ).mul( _perBlockRateFromPeriod( startPeriod ) );
            return during.div( weightSum ).div( totalSupply );
            
        }else{
            uint denominator = weightSum.mul( totalSupply );
            
            uint duringStartNumerator = _getBlockFromPeriod( startPeriod.add( 1 ) ).sub( fromBlock );
            duringStartNumerator = duringStartNumerator.mul( weight ).mul( _perBlockRateFromPeriod( startPeriod ) ).mul( balance );    
            
            uint duringEndNumerator = currentBlock.sub( _getBlockFromPeriod( endPeriod ) );
            duringEndNumerator = duringEndNumerator.mul( weight ).mul( _perBlockRateFromPeriod( endPeriod ) ).mul( balance );    

            uint duringMid = 0;
            
          for( uint i = startPeriod.add( 1 ) ; i < endPeriod ; i++ ) {
              uint numerator = BLOCK_YEAR.mul( 4 ).mul( balance ).mul( weight ).mul( _perBlockRateFromPeriod( i ) );
              duringMid += numerator.div( denominator );
          }
           
          uint duringStartAmount = duringStartNumerator.div( denominator );
          uint duringEndAmount = duringEndNumerator.div( denominator );
           
          return duringStartAmount + duringMid + duringEndAmount;
        }
    }
    
    function _getBlockFromPeriod( uint period ) internal view returns ( uint ){

        return startBlock.add( period.sub( 1 ).mul( BLOCK_YEAR ).mul( 4 ) );
    }
    
    function _getPeriodFromBlock( uint blockNumber ) internal view returns( uint ){

       return blockNumber.sub( startBlock ).div( BLOCK_YEAR.mul( 4 ) ).add( 1 );
    }
    
    function _perBlockRateFromPeriod( uint period ) internal view returns( uint ){

        uint totalDistribute = Punk.balanceOf( address( this ) ).add( totalDistributed ).div( period.mul( 2 ) );
        uint perBlock = totalDistribute.div( BLOCK_YEAR.mul( 4 ) );
        return perBlock;
    }
    
    function getClaimPunk( address to ) public view returns( uint ){

        uint reward = 0;
        for( uint i = 0 ; i < forges.length ; i++ ){
            reward += getClaimPunk( forges[ i ], to );
        }
        return reward;
    }

    function getClaimPunk( address forge, address to ) public view returns( uint ){

        uint checkPointBlock = checkPointBlocks[ forge ][ to ];
        if( checkPointBlock <= getStartBlock() ){
            checkPointBlock = getStartBlock();
        }
        return checkPointBlock > startBlock ? _calcRewards( forge, to, checkPointBlock, block.number ) : 0;
    }

    function getWeightSum() public view returns( uint ){

        return weightSum;
    }

    function getWeight( address forge ) public view returns( uint ){

        return weights[ forge ];
    }

    function getTotalDistributed( ) public view returns( uint ){

        return totalDistributed;
    }

    function getDistributed( address forge ) public view returns( uint ){

        return distributed[ forge ];
    }

    function getAllocation( ) public view returns( uint ){

        return _perBlockRateFromPeriod( _getPeriodFromBlock( block.number ) );
    }

    function getAllocation( address forge ) public view returns( uint ){

        return getAllocation( ).mul( weights[ forge ] ).div( weightSum );
    }

    function staked( address forge, address account ) public view returns( uint ){

        return balances[ forge ][ account ];
    }

    function getTotalReward() public view returns( uint ){

        return Punk.balanceOf( address( this ) ).add( totalDistributed );
    }

    function getStartBlock() public view returns( uint ){

        return startBlock;
    }

    function checkForge(address forge) public view returns(bool){

        return _checkForge(forge);
    }
    
}