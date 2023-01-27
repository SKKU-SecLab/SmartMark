
pragma solidity 0.5.17;

contract Ownership {


  address public owner;
  event OwnershipUpdated(address oldOwner, address newOwner);

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner, "Not owner");
    _;
  }

  function updateOwner(address _newOwner)
    public
    onlyOwner
  {

    require(_newOwner != address(0x0), "Invalid address");
    owner = _newOwner;
    emit OwnershipUpdated(msg.sender, owner);
  }

  function renounceOwnership(uint _validationCode)
    public
    onlyOwner
  {

    require(_validationCode == 123456789, "Invalid code");
    owner = address(0);
    emit OwnershipUpdated(msg.sender, owner);
  }
}/**

* MIT License
* ===========
* 
* Copyright (c) 2020 OLegacy
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
*/

pragma solidity 0.5.17;

library Address {

  

  function isContract(address account) internal view returns (bool) {

      bytes32 codehash;
      bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
      assembly { codehash := extcodehash(account) }
      return (codehash != accountHash && codehash != 0x0);
  }

}/**

* MIT License
* ===========
* 
* Copyright (c) 2020 OLegacy
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
*/

pragma solidity 0.5.17;

contract ERC20Interface {

    function balanceOf(address tokenOwner) public view returns (uint256 balance);

    function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);

    function transfer(address to, uint256 tokens) public returns (bool success);

    function approve(address spender, uint256 tokens) public returns (bool success);

    function transferFrom(address from, address to, uint256 tokens) public returns (bool success);


    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}/**

* MIT License
* ===========
* 
* Copyright (c) 2020 OLegacy
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
*/

pragma solidity ^0.5.17;



library SafeERC20 {


    using Address for address;

    function safeTransfer(ERC20Interface token, address to, uint256 value) internal {

        require(address(token).isContract(), "SafeERC20: call to non-contract");
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

  
    function _callOptionalReturn(ERC20Interface token, bytes memory data) private {


        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}/**

* MIT License
* ===========
* 
* Copyright (c) 2020 OLegacy
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
*/

pragma solidity 0.5.17;



library SafeMath {



    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        assert(c >= a && c >= b);
        return c;
    }
}


interface TokenRecipient {

    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; 

    function tokenFallback(address _from, uint256 _value, bytes calldata _data) external;

}

contract OToken is ERC20Interface, Ownership {


    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for ERC20Interface;

    string public constant name = 'O Token'; // Name of token
    string public constant symbol = 'OT';  // Symbol of token
    uint256 public constant decimals = 8; // Decimals in token
    address public deputyOwner; // to perform tasks on behalf of owner in automated applications
    uint256 public totalSupply = 0; // initially totalSupply 0

    address public suspenseWallet; // the contract resposible for burning tokens
    address public centralRevenueWallet; // platform wallet to collect commission
    address public minter; // adddress of minter

    uint256 public commission_numerator; // commission percentage numerator
    uint256 public commission_denominator;// commission percentage denominator

    mapping (address => uint256) balances; // balances mapping to hold OT balance of address
    mapping (address => mapping (address => uint256) ) allowed; // mapping to hold allowances

    mapping (address => bool) public isTaxFreeSender; // tokens transferred from these users won't be taxed
    mapping (address => bool) public isTaxFreeRecipeint; // if token transferred to these addresses won't be taxed
    mapping (string => mapping(string => bool)) public sawtoothHashMapping;
    mapping (address => bool) public trustedContracts; // contracts on which tokenFallback will be called

    event MintOrBurn(address _from, address to, uint256 _token, string sawtoothHash, string orderId );
    event CommssionUpdate(uint256 _numerator, uint256 _denominator);
    event TaxFreeUserUpdate(address _user, bool _isWhitelisted, string _type);
    event TrustedContractUpdate(address _contractAddress, bool _isActive);
    event MinterUpdated(address _newMinter, address _oldMinter);
    event SuspenseWalletUpdated(address _newSuspenseWallet, address _oldSuspenseWallet);
    event DeputyOwnerUpdated(address _oldOwner, address _newOwner);
    event CRWUpdated(address _newCRW, address _oldCRW);

    constructor (address _minter, address _crw, address _newDeputyOwner)
        public
        onlyNonZeroAddress(_minter)
        onlyNonZeroAddress(_crw)
        onlyNonZeroAddress(_newDeputyOwner)
    {
        owner = msg.sender; // set owner address to be msg.sender
        minter = _minter; // set minter address
        centralRevenueWallet = _crw; // set central revenue wallet address
        deputyOwner = _newDeputyOwner; // set deputy owner
        commission_numerator = 1; // set commission
        commission_denominator = 100;
        emit MinterUpdated(_minter, address(0));
        emit CRWUpdated(_crw, address(0));
        emit DeputyOwnerUpdated(_newDeputyOwner, address(0));
        emit CommssionUpdate(1, 100);
    }


    modifier canBurn() {

        require(msg.sender == suspenseWallet, "only suspense wallet is allowed");
        _;
    }

    modifier onlyMinter() {

        require(msg.sender == minter,"only minter is allowed");
        _;
    }

    modifier onlyDeputyOrOwner() {

        require(msg.sender == owner || msg.sender == deputyOwner, "Only owner or deputy owner is allowed");
        _;
    }

    modifier onlyNonZeroAddress(address _user) {

        require(_user != address(0), "Zero address not allowed");
        _;
    }

    modifier onlyValidSawtoothEntry(string memory _sawtoothHash, string memory _orderId) {

        require(!sawtoothHashMapping[_sawtoothHash][_orderId], "Sawtooth hash amd orderId combination already used");
        _;
    }
 
 

    function transfer(address _to, uint256 _value) public returns (bool) {

        return privateTransfer(msg.sender, _to, _value, false, false); // internal method
    }

    function transferIncludingFee(address _to, uint256 _value)
        public
        onlyNonZeroAddress(_to)
        returns(bool)
    {

        return privateTransfer(msg.sender, _to, _value, false, true);
    }

    function bulkTransfer (address[] memory _addressArr, uint256[] memory _amountArr, bool _includingFees) public returns (bool) {
        require(_addressArr.length == _amountArr.length, "Invalid params");
        for(uint256 i = 0 ; i < _addressArr.length; i++){
            uint256 _value = _amountArr[i];
            address _to = _addressArr[i];
            privateTransfer(msg.sender, _to, _value, false, _includingFees); // internal method
        }
        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool) {

        return _approve(msg.sender, _spender, _value);
    }

    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {

       return _increaseApproval(msg.sender, _spender, _addedValue);
    }
  
    function decreaseApproval (address _spender, uint256 _subtractedValue) public returns (bool) {
        return _decreaseApproval(msg.sender, _spender, _subtractedValue);
    }
    
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool) {

        TokenRecipient spender = TokenRecipient(_spender);
        if (approve(_spender, _value)) {
                spender.receiveApproval(msg.sender, _value, address(this), _extraData);
                return true;
        }else{
            return false;
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        require(_value <= allowed[_from][msg.sender] ,"Insufficient approval");
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        privateTransfer(_from, _to, _value, false, false);
    }


   
    function mint(address _to, uint256 _value, string memory _sawtoothHash, string memory _orderId)
        public
        onlyMinter
        onlyNonZeroAddress(_to)
        onlyValidSawtoothEntry(_sawtoothHash, _orderId)
        returns (bool)
    {

        sawtoothHashMapping[_sawtoothHash][_orderId] = true;
        totalSupply = totalSupply.add(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(address(0), _to, _value);
        emit MintOrBurn(address(0), _to, _value, _sawtoothHash, _orderId);
        return true;

    }

    function bulkMint (address[] memory _addressArr, uint256[] memory _amountArr, string memory _sawtoothHash, string memory _orderId)
        public
        onlyMinter
        onlyValidSawtoothEntry(_sawtoothHash, _orderId)
        returns (bool)
    {
        require(_addressArr.length == _amountArr.length, "Invalid params");
        for(uint256 i = 0; i < _addressArr.length; i++){
            uint256 _value = _amountArr[i];
            address _to = _addressArr[i];
            
            require(_to != address(0),"Zero address not allowed");
            totalSupply = totalSupply.add(_value);
            balances[_to] = balances[_to].add(_value);
            sawtoothHashMapping[_sawtoothHash][_orderId] = true;
            emit Transfer(address(0), _to, _value);
            emit MintOrBurn(address(0), _to, _value, _sawtoothHash, _orderId);
        }
        return true;

    }

    function burn(uint256 _value, string memory _sawtoothHash, string memory _orderId)
        public
        canBurn
        onlyValidSawtoothEntry(_sawtoothHash, _orderId)
        returns (bool)
    {

        require(balances[msg.sender] >= _value, "Insufficient balance");
        sawtoothHashMapping[_sawtoothHash][_orderId] = true;
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Transfer(msg.sender, address(0), _value);
        emit MintOrBurn(msg.sender, address(0), _value, _sawtoothHash, _orderId);
        return true;
    }

    function updateTaxFreeRecipient(address[] memory _users, bool _isSpecial)
        public
        onlyDeputyOrOwner
        returns (bool)
    {

        for(uint256 i=0; i<_users.length; i++) {
            require(_users[i] != address(0), "Zero address not allowed");
            isTaxFreeRecipeint[_users[i]] = _isSpecial;
            emit TaxFreeUserUpdate(_users[i], _isSpecial, 'Recipient');
        }
        
        return true;
    }

    function updateTaxFreeSender(address[] memory _users, bool _isSpecial)
        public
        onlyDeputyOrOwner
        returns (bool)
    {

        for(uint256 i=0; i<_users.length; i++) {
            require(_users[i] != address(0), "Zero address not allowed");
            isTaxFreeSender[_users[i]] = _isSpecial;
            emit TaxFreeUserUpdate(_users[i], _isSpecial, 'Sender');
        }
        return true;
    }


    function addSuspenseWallet(address _suspenseWallet)
        public
        onlyOwner
        onlyNonZeroAddress(_suspenseWallet)
        returns (bool)
    {

        emit SuspenseWalletUpdated(_suspenseWallet, suspenseWallet);
        suspenseWallet = _suspenseWallet;
        return true;
    }

    function updateMinter(address _minter)
        public
        onlyOwner
        onlyNonZeroAddress(_minter)
        returns (bool)
    {

        emit MinterUpdated(_minter, minter);
        minter = _minter;
        return true;
    }

    function addTrustedContracts(address _contractAddress, bool _isActive) public onlyDeputyOrOwner {

        require(_contractAddress.isContract(), "Only contract address can be added");
        trustedContracts[_contractAddress] = _isActive;
        emit TrustedContractUpdate(_contractAddress, _isActive);
    }

    function updateCommssion(uint256 _numerator, uint256 _denominator)
        public
        onlyDeputyOrOwner
    {

        commission_denominator = _denominator;
        commission_numerator = _numerator;
        emit CommssionUpdate(_numerator, _denominator);
    }

    function updateDeputyOwner(address _newDeputyOwner)
        public
        onlyOwner
        onlyNonZeroAddress(_newDeputyOwner)
    {

        emit DeputyOwnerUpdated(_newDeputyOwner, deputyOwner);
        deputyOwner = _newDeputyOwner;
    }


    function updateCRW(address _newCrw)
        public
        onlyOwner
        onlyNonZeroAddress(_newCrw)
    {

        emit CRWUpdated(_newCrw, centralRevenueWallet);
        centralRevenueWallet = _newCrw;
    }

    function transferAnyERC20Token(address _tokenAddress, uint256 _value) public onlyOwner {

        ERC20Interface(_tokenAddress).safeTransfer(owner, _value);
    }




    function privateTransfer(address _from, address _to, uint256 _amount, bool _withoutFees, bool _includingFees)
        internal
        onlyNonZeroAddress(_to)
        returns (bool)
    {

        uint256 _amountToTransfer = _amount;
        if(_withoutFees || isTaxFreeTx(_from, _to)) {
            require(balances[_from] >= _amount, "Insufficient balance");
            _transferWithoutFee(_from, _to, _amountToTransfer);
        } else {
            uint256 fee = calculateCommission(_amount);

            if(_includingFees) {
                require(balances[_from] >= _amount, "Insufficient balance");
                _amountToTransfer = _amount.sub(fee);
            } else {
                require(balances[_from] >= _amount.add(fee), "Insufficient balance");
            }
            if(fee > 0 ) _transferWithoutFee(_from, centralRevenueWallet, fee);
            _transferWithoutFee(_from, _to, _amountToTransfer);
        }
        notifyTrustedContract(_from, _to, _amountToTransfer);
        return true;
    }


    function _approve(address _sender, address _spender, uint256 _value)
        internal returns (bool)
    {

        allowed[_sender][_spender] = _value;
        emit Approval (_sender, _spender, _value);
        return true;
    }

    function _increaseApproval(address _sender, address _spender, uint256 _addedValue)
        internal returns (bool)
    {

        allowed[_sender][_spender] = allowed[_sender][_spender].add(_addedValue);
        emit Approval(_sender, _spender, allowed[_sender][_spender]);
        return true;
    }

    function _decreaseApproval (address _sender, address _spender, uint256 _subtractedValue )
        internal returns (bool)
    {
        uint256 oldValue = allowed[_sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[_sender][_spender] = 0;
        } else {
            allowed[_sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(_sender, _spender, allowed[_sender][_spender]);
        return true;
    }

    function _transferWithoutFee(address _from, address _to, uint256 _amount)
        private
        returns (bool)
    {

        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }


    function notifyTrustedContract(address _from, address _to, uint256 _value) internal {

        if(trustedContracts[_to]) {
            TokenRecipient trustedContract = TokenRecipient(_to);
            trustedContract.tokenFallback(_from, _value, '0x');
        }

    }


  
    function allowance(address _tokenOwner, address _spender) public view returns (uint256 remaining) {

        return allowed[_tokenOwner][_spender];
    }


    function balanceOf(address _tokenOwner) public view returns (uint256 balance) {

        return balances[_tokenOwner];
    }

    function calculateCommission(uint256 _amount) public view returns (uint256) {

        return _amount.mul(commission_numerator).div(commission_denominator).div(100);
    }

    function isTaxFreeTx(address _from, address _to) public view returns(bool) {

        if(isTaxFreeRecipeint[_to] || isTaxFreeSender[_from]) return true;
        else return false;
    }

    function () external payable {
        revert("Contract does not accept ethers");
    }
}


contract AdvancedOToken is OToken {

    mapping(address => mapping(bytes32 => bool)) public tokenUsed; // mapping to track token is used or not
    
    bytes4 public methodWord_transfer = bytes4(keccak256("transfer(address,uint256)"));
    bytes4 public methodWord_approve = bytes4(keccak256("approve(address,uint256)"));
    bytes4 public methodWord_increaseApproval = bytes4(keccak256("increaseApproval(address,uint256)"));
    bytes4 public methodWord_decreaseApproval = bytes4(keccak256("decreaseApproval(address,uint256)"));


    constructor(address minter, address crw, address deputyOwner) public OToken(minter, crw, deputyOwner) {
    }

    function getChainID() public pure returns (uint256) {

        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    function preAuthorizedBulkTransfer(
        bytes32 message, bytes32 r, bytes32 s, uint8 v, bytes32 token, uint256 networkFee, address[] memory _addressArr,
        uint256[] memory _amountArr, bool _includingFees )
        public
        returns (bool)
    {

        require(_addressArr.length == _amountArr.length, "Invalid params");

        bytes32 proof = getProofBulkTransfer(
            token, networkFee, msg.sender, _addressArr, _amountArr, _includingFees
        );
       
        address signer = preAuthValidations(proof, message, token, r, s, v);

        if (networkFee > 0) {
            privateTransfer(signer, msg.sender, networkFee, true, false);
        }

        for(uint256 i = 0; i < _addressArr.length; i++){
            uint256 _value = _amountArr[i];
            address _to = _addressArr[i];
            privateTransfer(signer, _to, _value, false, _includingFees);
        }

        return true;

    }

    function preAuthorizedTransfer(
        bytes32 message, bytes32 r, bytes32 s, uint8 v, bytes32 token, uint256 networkFee, address to, uint256 amount, bool includingFees)
        public
    {


        bytes32 proof = getProofTransfer(methodWord_transfer, token, networkFee, msg.sender, to, amount, includingFees);
        address signer = preAuthValidations(proof, message, token, r, s, v);

        if (networkFee > 0) {
            privateTransfer(signer, msg.sender, networkFee, true, false);
        }

        privateTransfer(signer, to, amount, false, includingFees);
        
    }

    function preAuthorizedApproval(
        bytes4 methodHash, bytes32 message, bytes32 r, bytes32 s, uint8 v, bytes32 token, uint256 networkFee, address to, uint256 amount)
        public
        returns (bool)
    {

        bytes32 proof = getProofApproval (methodHash, token, networkFee, msg.sender, to, amount);
        address signer = preAuthValidations(proof, message, token, r, s, v);

        if(methodHash == methodWord_approve) return _approve(signer, to, amount);
        else if(methodHash == methodWord_increaseApproval) return _increaseApproval(signer, to, amount);
        else if(methodHash == methodWord_decreaseApproval) return _decreaseApproval(signer, to, amount);
    }

    function preAuthValidations(bytes32 proof, bytes32 message, bytes32 token, bytes32 r, bytes32 s, uint8 v)
        private
        returns(address)
    {

        address signer = getSigner(message, r, s, v);
        require(signer != address(0),"Zero address not allowed");
        require(!tokenUsed[signer][token],"Token already used");
        require(proof == message, "Invalid proof");
        tokenUsed[signer][token] = true;
        return signer;
    }

    
    function getSigner(bytes32 message, bytes32 r, bytes32 s, uint8 v)
        public
        pure
        returns (address)
    {

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, message));
        address signer = ecrecover(prefixedHash, v, r, s);
        return signer;
    }

    
    function getProofBulkTransfer(bytes32 token, uint256 networkFee, address broadcaster, address[] memory _addressArr, uint256[] memory _amountArr, bool _includingFees)
        public
        view
        returns (bytes32)
    {

        bytes32 proof = keccak256(abi.encodePacked(
            getChainID(),
            bytes4(methodWord_transfer),
            address(this),
            token,
            networkFee,
            broadcaster,
            _addressArr,
            _amountArr,
            _includingFees
        ));
        return proof;
    }



    function getProofApproval(bytes4 methodHash, bytes32 token, uint256 networkFee, address broadcaster, address to, uint256 amount)
        public
        view
        returns (bytes32)
    {

        require(
            methodHash == methodWord_approve ||
            methodHash == methodWord_increaseApproval ||
            methodHash == methodWord_decreaseApproval,
            "Method not supported");
        bytes32 proof = keccak256(abi.encodePacked(
            getChainID(),
            bytes4(methodHash),
            address(this),
            token,
            networkFee,
            broadcaster,
            to,
            amount
        ));
        return proof;
    }

    function getProofTransfer(bytes4 methodHash, bytes32 token, uint256 networkFee, address broadcaster, address to, uint256 amount, bool includingFees)
        public
        view
        returns (bytes32)
    {

        require(methodHash == methodWord_transfer, "Method not supported");
        bytes32 proof = keccak256(abi.encodePacked(
            getChainID(),
            bytes4(methodHash),
            address(this),
            token,
            networkFee,
            broadcaster,
            to,
            amount,
            includingFees
        ));
        return proof;
    }

   

}