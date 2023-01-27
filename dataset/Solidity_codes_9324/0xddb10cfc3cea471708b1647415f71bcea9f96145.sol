
pragma solidity ^0.7.0;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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
        return _functionCallWithValue(target, data, value, errorMessage);
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
}

pragma solidity ^0.7.0;

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
pragma solidity 0.7.4;



contract Constants {

    IERC20 constant ETH = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
}
pragma solidity 0.7.4;


interface IUserWallet {

    function params(bytes32 _key) external view returns(bytes32);

    function owner() external view returns(address payable);

    function demandETH(address payable _recepient, uint _amount) external;

    function demandERC20(IERC20 _token, address _recepient, uint _amount) external;

    function demandAll(IERC20[] calldata _tokens, address payable _recepient) external;

    function demand(address payable _target, uint _value, bytes memory _data) 
        external returns(bool, bytes memory);

}
pragma solidity 0.7.4;

library ParamsLib {

    function toBytes32(address _self) internal pure returns(bytes32) {

        return bytes32(uint(_self));
    }

    function toAddress(bytes32 _self) internal pure returns(address payable) {

        return address(uint(_self));
    }
}

pragma solidity ^0.7.0;

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
pragma solidity 0.7.4;


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

        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
pragma solidity 0.7.4;


contract UserWallet is IUserWallet, Constants {

    using SafeERC20 for IERC20;
    using ParamsLib for *;
    bytes32 constant W2W = 'W2W';
    bytes32 constant OWNER = 'OWNER';
    bytes32 constant REFERRER = 'REFERRER';

    mapping (bytes32 => bytes32) public override params;

    event ParamUpdated(bytes32 _key, bytes32 _value);

    modifier onlyW2wOrOwner () {

        require(msg.sender == params[W2W].toAddress() || msg.sender == owner(), 'Only W2W or owner');
        _;
    }

    modifier onlyOwner () {

        require(msg.sender == owner(), 'Only owner');
        _;
    }

    function init(address _w2w, address _owner, address _referrer) external payable {

        require(owner() == address(0), 'Already initialized');
        params[OWNER] = _owner.toBytes32();
        params[W2W] = _w2w.toBytes32();
        if (_referrer != address(0)) {
            params[REFERRER] = _referrer.toBytes32();
        }
    }

    function demandETH(address payable _recepient, uint _amount) external override onlyW2wOrOwner() {

        _recepient.transfer(_amount);
    }

    function demandERC20(IERC20 _token, address _recepient, uint _amount) external override onlyW2wOrOwner() {

        uint _thisBalance = _token.balanceOf(address(this));
        if (_thisBalance < _amount) {
            _token.safeTransferFrom(owner(), address(this), (_amount - _thisBalance));
        }
        _token.safeTransfer(_recepient, _amount);
    }

    function demandAll(IERC20[] calldata _tokens, address payable _recepient) external override onlyW2wOrOwner() {

        for (uint _i = 0; _i < _tokens.length; _i++) {
            IERC20 _token = _tokens[_i];
            if (_token == ETH) {
                _recepient.transfer(address(this).balance);
            } else {
                _token.safeTransfer(_recepient, _token.balanceOf(address(this)));
            }
        }
    }

    function demand(address payable _target, uint _value, bytes memory _data) 
    external override onlyW2wOrOwner() returns(bool, bytes memory) {

        return _target.call{value: _value}(_data);
    }

    function owner() public view override returns(address payable) {

        return params[OWNER].toAddress();
    }

    function changeParam(bytes32 _key, bytes32 _value) public onlyOwner() {

        require(_key != REFERRER, 'Cannot update referrer');
        params[_key] = _value;
        emit ParamUpdated(_key, _value);
    }
    
    function changeOwner(address _newOwner) public {

        changeParam(OWNER, _newOwner.toBytes32());
    }

    receive() payable external {}
}
pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

contract MinimalProxyFactory {

    function _deployBytecode(address _prototype) internal pure returns(bytes memory) {

        return abi.encodePacked(
            hex'602d600081600a8239f3363d3d373d3d3d363d73',
            _prototype,
            hex'5af43d82803e903d91602b57fd5bf3'
        );
    }

    function _deploy(address _prototype, bytes32 _salt) internal returns(address payable _result) {

        bytes memory _bytecode = _deployBytecode(_prototype);
        assembly {
            _result := create2(0, add(_bytecode, 32), mload(_bytecode), _salt)
        }
        return _result;
    }
}
pragma solidity 0.7.4;


contract UserWalletFactory is MinimalProxyFactory {

    using Address for address;
    address public immutable userWalletPrototype;

    constructor() {
        userWalletPrototype = address(new UserWallet());
    }

    function getBytecodeHash() public view returns(bytes32) {

        return keccak256(_deployBytecode(userWalletPrototype));
    }

    function getUserWallet(address _user) public view returns(IUserWallet) {

        address _predictedAddress = address(uint(keccak256(abi.encodePacked(
            hex'ff',
            address(this),
            bytes32(uint(_user)),
            keccak256(_deployBytecode(userWalletPrototype))
        ))));
        if (_predictedAddress.isContract()) {
            return IUserWallet(_predictedAddress);
        }
        return IUserWallet(0);
    }

    function deployUserWallet(address _w2w, address _referrer) external payable {

        deployUserWalletFor(_w2w, msg.sender, _referrer);
    }

    function deployUserWalletFor(address _w2w, address _owner, address _referrer) public payable {

        UserWallet _userWallet = UserWallet(
            _deploy(userWalletPrototype, bytes32(uint(_owner)))
        );
        _userWallet.init{value: msg.value}(_w2w, _owner, _referrer);
    }
}
