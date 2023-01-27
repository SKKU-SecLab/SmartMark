
pragma solidity 0.5.12;


contract IERC223Token {

    function transfer(address _to, uint256 _value) public returns (bool);

    function balanceOf(address who)public view returns (uint);

}

contract ForwarderContract {

    
    address payable public parentAddress;
 
    event ForwarderDeposited(address from, uint value, bytes data);
    event TokensFlushed(address forwarderAddress, uint value, address tokenContractAddress);

    modifier onlyParent {

        require(msg.sender == parentAddress);
        _;
    }
    
    constructor() public{
        parentAddress = msg.sender;
    }

    function() external payable {
        parentAddress.transfer(msg.value);
        emit ForwarderDeposited(msg.sender, msg.value, msg.data);
    }

    function flushDeposit(address _tokenContractAddress) public onlyParent {

        IERC223Token instance = IERC223Token(_tokenContractAddress);
        uint forwarderBalance = instance.balanceOf(address(this));
        require(forwarderBalance > 0);
        require(instance.transfer(parentAddress, forwarderBalance));
        emit TokensFlushed(address(this), forwarderBalance, _tokenContractAddress);
    }
  
    function flushAmountToken(address _from, uint _value) external{

        require(IERC223Token(_from).transfer(parentAddress, _value), "instance error");
    }

    function flush() public {

        parentAddress.transfer(address(this).balance);
    }
}

contract ExchangeWallet {

    
    address[] public signers;
    bool public safeMode; 
    uint private forwarderCount;
    uint private lastNounce;
    
    event Deposited(address from, uint value, bytes data);
    event SafeModeActivated(address msgSender);
    event SafeModeInActivated(address msgSender);
    event ForwarderCreated(address forwarderAddress);
    event Transacted(address msgSender, address otherSigner, bytes32 operation, address toAddress, uint value, bytes data);
    event TokensTransfer(address tokenContractAddress, uint value);
    
    modifier onlySigner {

        require(validateSigner(msg.sender));
        _;
    }

    constructor(address[] memory allowedSigners) public {
        require(allowedSigners.length == 3);
        signers = allowedSigners;
    }

    function() external payable {
        if(msg.value > 0){
            emit Deposited(msg.sender, msg.value, msg.data);
        }
    }
    
    function validateSigner(address signer) public view returns (bool) {

        for (uint i = 0; i < signers.length; i++) {
            if (signers[i] == signer) {
                return true;
            }
        }
        return false;
    }

    function activateSafeMode() public onlySigner {

        require(!safeMode);
        safeMode = true;
        emit SafeModeActivated(msg.sender);
    }
    
    function deactivateSafeMode() public onlySigner {

        require(safeMode);
        safeMode = false;
        emit SafeModeInActivated(msg.sender);
    }
    
    function generateForwarder() public returns (address) {

        ForwarderContract f = new ForwarderContract();
        forwarderCount += 1;
        emit ForwarderCreated(address(f));
        return(address(f));
    }
    
    function totalForwarderCount() public view returns(uint){

        return forwarderCount;
    }
    
    function flushForwarderDeposit(address payable forwarderAddress, address tokenContractAddress) public onlySigner {

        ForwarderContract forwarder = ForwarderContract(forwarderAddress);
        forwarder.flushDeposit(tokenContractAddress);
    }
    
    function getNonce() public view returns (uint) {

        return lastNounce+1;
    }
    
    function generateEtherHash(address toAddress, uint value, bytes memory data, uint expireTime, uint nounce)public pure returns (bytes32){

        return keccak256(abi.encodePacked("ETHER", toAddress, value, data, expireTime, nounce));
    }

    function transferMultiSigEther(address payable toAddress, uint value, bytes memory data, uint expireTime, uint nounce, bytes memory signature) public payable onlySigner {

        bytes32 operationHash = keccak256(abi.encodePacked("ETHER", toAddress, value, data, expireTime, nounce));
        address otherSigner = verifyMultiSig(toAddress, operationHash, signature, expireTime, nounce);
        toAddress.transfer(value);
        emit Transacted(msg.sender, otherSigner, operationHash, toAddress, value, data);
    }
    
    function generateTokenHash( address toAddress, uint value, address tokenContractAddress, uint expireTime, uint nounce) public pure returns (bytes32){

        return keccak256(abi.encodePacked("ERC20", toAddress, value, tokenContractAddress, expireTime, nounce));
    }
  
    function transferMultiSigTokens(address toAddress, uint value, address tokenContractAddress, uint expireTime, uint nounce, bytes memory signature) public onlySigner {

        bytes32 operationHash = keccak256(abi.encodePacked("ERC20", toAddress, value, tokenContractAddress, expireTime, nounce));
        verifyMultiSig(toAddress, operationHash, signature, expireTime, nounce);
        IERC223Token instance = IERC223Token(tokenContractAddress);
        require(instance.balanceOf(address(this)) > 0);
        require(instance.transfer(toAddress, value));
        emit TokensTransfer(tokenContractAddress, value);
    }
    
    function recoverAddressFromSignature(bytes32 operationHash, bytes memory signature) private pure returns (address) {

        require(signature.length == 65);
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
        if (v < 27) {
            v += 27; 
        }
        return ecrecover(operationHash, v, r, s);
    }

    function validateNonce(uint nounce) private onlySigner {

        require(nounce > lastNounce && nounce <= (lastNounce+1000), "Enter Valid Nounce");
        lastNounce=nounce;
    }

    function verifyMultiSig(address toAddress, bytes32 operationHash, bytes memory signature, uint expireTime, uint nounce) private returns (address) {


        address otherSigner = recoverAddressFromSignature(operationHash, signature);
        if (safeMode && !validateSigner(toAddress)) {
            revert("safemode error");
        }
        require(validateSigner(otherSigner) && expireTime > now);
        require(otherSigner != msg.sender);
        validateNonce(nounce);
        return otherSigner;
    }
}