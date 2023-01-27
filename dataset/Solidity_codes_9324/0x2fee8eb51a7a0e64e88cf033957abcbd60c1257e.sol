
pragma solidity 0.7.3;

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

abstract contract Context {
    function _msgSender() 
        internal
        view 
        virtual
        returns (address payable) 
    {
        return msg.sender;
    }

    function _msgData() 
        internal
        view 
        virtual 
        returns (bytes memory) 
    {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library SafeMath {

    function add(
        uint256 a, 
        uint256 b
    ) 
        internal 
        pure 
        returns (uint256) 
    {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(
        uint256 a, 
        uint256 b
    ) 
        internal 
        pure 
        returns (uint256) 
    {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a, 
        uint256 b, 
        string memory errorMessage
    ) 
        internal 
        pure 
        returns (uint256) 
    {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(
        uint256 a, 
        uint256 b
    ) 
        internal 
        pure 
        returns (uint256) 
    {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(
        uint256 a, 
        uint256 b
    ) 
        internal 
        pure 
        returns (uint256) 
    {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a, 
        uint256 b, 
        string memory errorMessage
    ) 
        internal 
        pure 
        returns (uint256) 
    {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(
        uint256 a, 
        uint256 b
    ) 
        internal 
        pure 
        returns (uint256) 
    {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a, 
        uint256 b, 
        string memory errorMessage
    ) 
        internal 
        pure 
        returns (uint256) 
    {

        require(b != 0, errorMessage);
        return a % b;
    }
}


library Address {

    function isContract(
        address account
    ) 
        internal 
        view 
        returns (bool) 
    {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(
        address payable recipient, 
        uint256 amount
    ) 
        internal 
    {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(
        address target, 
        bytes memory data
    ) 
        internal 
        returns (bytes memory) 
    {

      return functionCall(target, data, "Address: low-level call failed");
    }

   function functionCall(
       address target, 
       bytes memory data, 
       string memory errorMessage
    ) 
        internal 
        returns (bytes memory) 
    {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target, 
        bytes memory data, 
        uint256 value
    ) 
        internal 
        returns (bytes memory) 
    {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target, 
        bytes memory data, 
        uint256 value, 
        string memory errorMessage
    ) 
        internal 
        returns (bytes memory) 
    {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target, 
        bytes memory data, 
        uint256 weiValue, 
        string memory errorMessage
    ) 
        private 
        returns (bytes memory) 
    {

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


abstract contract Ownable is Context {
    address public owner;
    address public pendingOwner;

    event OwnershipTransferred(
        address indexed previousOwner, 
        address indexed newOwner
    );

    constructor () {
        address msgSender = _msgSender();
        owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    modifier onlyOwner() {
        require(owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(
        address newOwner
    ) 
        onlyOwner 
        external 
    {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        pendingOwner = newOwner;
     }
    
     function claimOwnership() 
        external 
    {
        require(_msgSender() == pendingOwner);
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
     }
}

library VerifySignature {


    function getEthSignedMessageHash(bytes32 _messageHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function verify(
        bytes32 _message, bytes memory _signature, address _signer
    )
        internal pure returns (bool)
    {

        bytes32 ethSignedMessageHash = getEthSignedMessageHash(_message);

        return recoverSigner(ethSignedMessageHash, _signature) == _signer;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        internal pure returns (address)
    {

        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        internal pure returns (bytes32 r, bytes32 s, uint8 v)
    {

        require(sig.length == 65, "invalid signature length");

        assembly {

            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

    }
}

contract ETHPortal is Ownable {

    using SafeMath for uint256;
    using Address for address;

    mapping (bytes32 => bool) public txNonces;
    address public signAddress;
    address public tokenAddress;

    string public chainName = "ETH_BLOCKCHAIN";

    event TokensLocked(
        address user,
        uint256 amount
    );

    event TokensUnlocked(
        address user,
        uint256 amount,
        bytes32 txNonce
    );

    constructor(address _signAddress, address _tokenAddress) public {
        signAddress = _signAddress;
        tokenAddress = _tokenAddress;
    }

    function changeSignAddress(address _signAddress) public onlyOwner {

        signAddress = _signAddress;
    }

    function changeTokenAddress(address _tokenAddress) public onlyOwner {

        tokenAddress = _tokenAddress;
    }

    function lockedTokens() public view returns(uint256) {

        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function sendToBSC(uint256 _amount) public {

        require(_amount > 0, "AMOUNT_CANT_BE_ZERO");
        IERC20(tokenAddress).transferFrom(_msgSender(), address(this), _amount);
        emit TokensLocked(_msgSender(), _amount);
    }

    function withdrawFromBSC(bytes calldata _signature, uint256 _amount, bytes32 _txNonce) public {

        require(txNonces[_txNonce] == false, "INVALID_TRANSACTION");
        txNonces[_txNonce] = true;
        require(_amount > 0, "AMOUNT_CANT_BE_ZERO");

        bytes32 message = keccak256(abi.encodePacked(_amount, _msgSender(), _txNonce, chainName));
        require(VerifySignature.verify(message, _signature, signAddress) == true, "INVALID_SIGNATURE");

        IERC20(tokenAddress).transfer(_msgSender(), _amount);
        emit TokensUnlocked(_msgSender(), _amount, _txNonce);

    }
}