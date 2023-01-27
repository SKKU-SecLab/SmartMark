pragma solidity ^0.8.10;

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

library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {

  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {

    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }
}

abstract contract ERC20Basic {
  function totalSupply() public virtual view returns (uint256);
  function balanceOf(address who) public virtual view returns (uint256);
  function transfer(address to, uint256 value) public virtual;

  event Transfer(address indexed from, address indexed to, uint256 value);
}

abstract contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public virtual view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public virtual;
  function approve(address spender, uint256 value) public virtual;

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract ERC1155 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    function balanceOf(uint256 tokenId) public virtual view returns (uint256);
    function setApprovalForAll(address operator, bool approved) public virtual;
    function isApprovedForAll(address account, address operator) public virtual view returns (bool);

    function mintAndTransfer(address[] memory _addrs, uint256 _tokenId, uint256[] memory _amounts, string memory _uri) public virtual;
}

contract TokenRecipient {

    event ReceivedEther(address indexed sender, uint256 amount);
    event Fallback(address indexed sender, uint256 amount);
    event ReceivedTokens(address indexed from, uint256 value, address indexed token, bytes extraData);

    function receiveApproval(address from, uint256 value, address token, bytes memory extraData) public {

        ERC20(token).transferFrom(from, address(this), value);

        emit ReceivedTokens(from, value, token, extraData);
    }

    fallback () external payable {
        emit Fallback(msg.sender, msg.value);
    }


    receive() external payable {
        emit ReceivedEther(msg.sender, msg.value);
    }

}

contract LynKeyMarketPlace is Ownable, TokenRecipient{

    using SafeMath for uint256;
    using Address for address;
    string public constant name = "LynKey Marketplace";
    string public constant version = "1.0";

    string private constant SALE_TYPE_BUY = "BUY";
    string private constant SALE_TYPE_BID = "BID";

    mapping(address => bool) public isAdmin;

    constructor(){
        owner = msg.sender;
        isAdmin[owner] = true;
    }

    ERC20 private tokenContract;
    ERC1155 private NftContract;
    address private feeWallet;

    modifier adminOnly() {

        require(msg.sender == owner || isAdmin[msg.sender] == true);
        _;
    }

    modifier ownerOnly() {

        require(msg.sender == owner);
        _;
    }

    function addAdmin(address _address) external ownerOnly() {

        isAdmin[_address] = true;
    }

    function removeAdmin(address _address) external ownerOnly() {

        isAdmin[_address] = false;
    }

    function setFeeWallet(address _address) external ownerOnly() {

        feeWallet = _address;
    }

    function withdraw(address _token, uint256 amount) external ownerOnly() {

        require(feeWallet != address(0), "require set fee wallet");
        if(_token == address(0)){
            uint256 value = address(this).balance;
            require(value >= amount, "current balance must be than withdraw amount");
            payable(feeWallet).transfer(amount);
        }else{
            require(_token.isContract(), "invalid token contract");
            tokenContract = ERC20(_token);
            uint256 value = tokenContract.balanceOf(address(this));
            require(value >= amount, "current balance must be than withdraw amount");
            tokenContract.transfer(feeWallet, amount);
        }
        
    }

    function exchange(
        address[3] calldata contracts,
        address[8] calldata addrs,
        uint256[3] calldata uints,
        uint256[3] calldata uintTokens,
        string[] memory strs)
        public
        adminOnly()
    {

        require(strs.length == 2, "invalid string array");
        uint256 feeValue = uints[0];
        uint256 sellValue = uints[1];
        uint256 royaltyValue = uints[2];
        uint256 totalValue =  (feeValue + sellValue + royaltyValue);
        
        address fromFee = addrs[0];
        address fromValue = addrs[2];
        address fromRoyalty = addrs[4];

        if(contracts[1] == address(0)){
            require(keccak256(bytes(strs[0])) == keccak256(bytes("BUY")),"invalid sale type");
            require(address(this).balance >=totalValue, "not enough eth balance");
            if(addrs[1] != address(0)){
                payable(addrs[1]).transfer(feeValue);
            }
            if(addrs[3] != address(0) && addrs[3] == addrs[5]){
                payable(addrs[3]).transfer(sellValue + royaltyValue);
            }else{
                if(addrs[3] != address(0)){
                    payable(addrs[3]).transfer(sellValue);
                }
                if(addrs[5]!= address(0)){
                    payable(addrs[5]).transfer(royaltyValue);
                }
            } 
        }else{
            if(keccak256(bytes(strs[0])) == keccak256(bytes("BUY"))) {
                fromFee = address(this);
                fromValue = address(this);
                fromRoyalty = address(this);

                tokenContract = ERC20(contracts[1]);
                require(tokenContract.balanceOf(payable(address(this))) >= totalValue, "not enough token balance");
            }else{
                require(contracts[1] != address(0), "can not bid/offer for currency");
            }

            if(addrs[1] != address(0)){
                transferTokens(contracts[1], fromFee, addrs[1], feeValue);
            }
            if(addrs[3] != address(0) && addrs[3] == addrs[5]){
                transferTokens(contracts[1], fromValue, addrs[3], sellValue + royaltyValue);
            }else{
                if(addrs[3] != address(0)){
                    transferTokens(contracts[1], fromValue, addrs[3], sellValue);
                }
                if(addrs[5]!= address(0)){
                    transferTokens(contracts[1], fromRoyalty, addrs[5], royaltyValue);
                }
            } 
        }
            
        if(contracts[2] != address(0)){
            address[] memory addNft = new address[](2);
            addNft[0] = addrs[6];
            addNft[1] = addrs[7];

            uint256[] memory intNft  = new uint256[](2);
            intNft[0] = uintTokens[1];
            intNft[1] = uintTokens[2];

            if(uintTokens[1] > 0 || uintTokens[2] > 0) {
                NftContract = ERC1155(contracts[2]);
                NftContract.mintAndTransfer(addNft, uintTokens[0],  intNft, strs[1]);
            }
        }
    }


    function transferTokens(address token, address from, address to, uint amount)
        internal
    {

        if (amount > 0) {
            tokenContract = ERC20(token);
            if(from == address(this)){
                tokenContract.transfer(to, amount);
            }else{
                tokenContract.transferFrom(from, to, amount);
            }
        }
    }
}