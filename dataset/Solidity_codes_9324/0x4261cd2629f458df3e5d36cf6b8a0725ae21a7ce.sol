
pragma solidity 0.7.5;


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

        return _functionCallWithValue(target, data, 0, errorMessage);
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

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

    function addressToString(address _address) internal pure returns(string memory) {

        bytes32 _bytes = bytes32(uint256(_address));
        bytes memory HEX = "0123456789abcdef";
        bytes memory _addr = new bytes(42);

        _addr[0] = '0';
        _addr[1] = 'x';

        for(uint256 i = 0; i < 20; i++) {
            _addr[2+i*2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _addr[3+i*2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }

        return string(_addr);

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

library SafeERC20 {

    using SafeMath for uint256;
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

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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

interface IOwnable {

  function policy() external view returns (address);


  function renounceManagement() external;

  
  function pushManagement( address newOwner_ ) external;

  
  function pullManagement() external;

}

contract Ownable is IOwnable {


    address internal _owner;
    address internal _newOwner;

    event OwnershipPushed(address indexed previousOwner, address indexed newOwner);
    event OwnershipPulled(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipPushed( address(0), _owner );
    }

    function policy() public view override returns (address) {

        return _owner;
    }

    modifier onlyPolicy() {

        require( _owner == msg.sender, "Ownable: caller is not the owner" );
        _;
    }

    function renounceManagement() public virtual override onlyPolicy() {

        emit OwnershipPushed( _owner, address(0) );
        _owner = address(0);
    }

    function pushManagement( address newOwner_ ) public virtual override onlyPolicy() {

        require( newOwner_ != address(0), "Ownable: new owner is the zero address");
        emit OwnershipPushed( _owner, newOwner_ );
        _newOwner = newOwner_;
    }
    
    function pullManagement() public virtual override {

        require( msg.sender == _newOwner, "Ownable: must be new owner to pull");
        emit OwnershipPulled( _owner, _newOwner );
        _owner = _newOwner;
    }
}

interface ILendingPool {

    function deposit( address asset, uint256 amount, address onBehalfOf, uint16 referralCode ) external;

    function withdraw( address asset, uint256 amount, address to ) external;

}

interface IStakedAave {

    function claimRewards(address to, uint256 amount) external;

    function getTotalRewardsBalance(address staker) external view returns (uint256);

}

interface ITreasury {

    function deposit( uint _amount, address _token, uint _profit ) external returns ( uint send_ );

    function manage( address _token, uint _amount ) external;

    function valueOf( address _token, uint _amount ) external view returns ( uint value_ );

}


contract AaveAllocator is Ownable {



    using SafeERC20 for IERC20;
    using SafeMath for uint;




    address immutable lendingPool; // Aave Lending Pool
    address immutable stkAave; // staked Aave ( rewards token )
    address treasury; // Olympus Treasury

    mapping( address => address ) public aTokens; // Corresponding aTokens for tokens

    uint public totalAllocated;
    mapping( address => uint ) public allocated; // amount allocated into pool for token
    mapping( address => uint ) public maxAllocation; // max allocated into pool for token

    uint public changeMaxAllocationTimelock; // timelock in blocks to change max allocation
    mapping( address => uint ) public changeMaxAllocationBlock; // block when new max can be set
    mapping( address => uint ) public newMaxAllocation; // pending new max allocations for tokens



    constructor ( 
        address _treasury, 
        address _lendingPool, 
        address _stkAave,
        uint _changeMaxAllocationTimelock 
    ) {
        require( _treasury != address(0) );
        treasury = _treasury;
        require( _lendingPool != address(0) );
        lendingPool = _lendingPool;
        require( _stkAave != address(0) );
        stkAave = _stkAave;
        changeMaxAllocationTimelock = _changeMaxAllocationTimelock;
    }




    function harvest() external {

        IStakedAave( stkAave ).claimRewards( treasury, rewardsPending() );
    }





    function deposit( address asset, uint amount ) external onlyPolicy() {

        require( !exceedsMaxAllocation( asset, amount ) ); // ensure deposit is within bounds

        ITreasury( treasury ).manage( asset, amount ); // retrieve amount of asset from treasury

        IERC20( asset ).approve( lendingPool, amount ); // deposit into lending pool
        ILendingPool( lendingPool ).deposit( asset, amount, address(this), 0 ); // returns aToken

        allocated[ asset ] = allocated[ asset ].add( amount ); // track amount allocated into pool
        totalAllocated = totalAllocated.add( amount );
        
        address aToken = aTokens[ asset ];
        uint aBalance = IERC20( aToken ).balanceOf( address(this) );
        uint value = ITreasury( treasury ).valueOf( aToken, aBalance );

        IERC20( aToken ).approve( aToken, aBalance );
        ITreasury( treasury ).deposit( aBalance, aToken, value ); 
    }

    function withdraw( address asset, uint amount ) external onlyPolicy() {

        address aToken = aTokens[ asset ];
        ITreasury( treasury ).manage( aToken, amount ); // retrieve amount of aToken from treasury

        IERC20( aToken ).approve( lendingPool, amount ); // withdraw from lending pool
        ILendingPool( lendingPool ).withdraw( aToken, amount, address(this) ); // returns asset

        allocated[ asset ] = allocated[ asset ].sub( amount ); // track amount allocated into pool
        totalAllocated = totalAllocated.sub( amount );

        uint balance = IERC20( asset ).balanceOf( address(this) );
        uint value = ITreasury( treasury ).valueOf( asset, balance );

        IERC20( asset ).approve( treasury, balance );
        ITreasury( treasury ).deposit( balance, asset, value ); 
    }

    function addToken( address token, address aToken, uint max ) external onlyPolicy() {

        require( token != address(0) );
        require( aToken != address(0) );
        require( maxAllocation[ token ] == 0 || max <= maxAllocation[ token ] );
        aTokens[ token ] = aToken;
        maxAllocation[ token ] = max;
    }

    function queueNewMaxAllocation( address asset, uint newMax ) external onlyPolicy() {

        changeMaxAllocationBlock[ asset ] = block.number.add( changeMaxAllocationTimelock );
        newMaxAllocation[ asset ] = newMax;
    }

    function setNewMaxAllocation( address asset ) external onlyPolicy() {

        require( block.number >= changeMaxAllocationBlock[ asset ], "Timelock not expired" );
        maxAllocation[ asset ] = newMaxAllocation[ asset ];
        newMaxAllocation[ asset ] = 0;
    }
    
    function setForProduction( address _treasury, uint _timelock ) external onlyPolicy() {

        require( changeMaxAllocationTimelock == 1 );
        treasury = _treasury;
        changeMaxAllocationTimelock = _timelock;
    }




    function rewardsPending() public view returns ( uint ) {

        return IStakedAave( stkAave ).getTotalRewardsBalance( address(this) );
    }

    function exceedsMaxAllocation( address asset, uint amount ) public view returns ( bool ) {

        uint alreadyAllocated = allocated[ asset ];
        uint willBeAllocated = alreadyAllocated.add( amount );

        return ( willBeAllocated > maxAllocation[ asset ] );
    }
}