

pragma solidity 0.8.6;

contract ADKContract {

 
    
    uint256 public totalSupply;
    
    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    
    string public name;     // Aidos Kuneen Wrapped ADK
    uint8 public decimals;  // 8
    string public symbol;   // ADK
    
    address public mainMeshOwner;  //the 'mesh owner', holds all token still inside the ADK Mesh (if not in circulation as wADK)
    address public statusAddress;  // is the request status admin, an address which can update user request stati.
    
    
    string public ADK_DEPOSIT_ADDRESS_LIVE; 
                      
    
    string public ADK_DEPOSIT_ADDRESS_PREVIOUS; 
                                                     
    uint256 public ADKDepositAddrCount; // Total number of historical ADK Mesh Contract deposit addresses
    
    mapping (uint256 => string) public ADKDepositAddrHistory; // holds the history of all ADK Mesh deposit addresses

    uint256 public requestID;    // counter / unique request ID 
    mapping (uint256 => string) public requestStatus; // Can be used to provide feedback to users re. status of their ADK/wADK requests.
    
    
    uint256 public minimumADKforXChainTransfer;  
    
    constructor( // EIP20 Standard
        uint256 _initialAmount,
        string memory _tokenName,
        uint8  _decimalUnits,
        string memory _tokenSymbol
    ) {
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes (8 for ADK)
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
        balances[msg.sender] = _initialAmount;               // Give the mesh address all initial tokens
        totalSupply = _initialAmount;                        // 2500000000000000 ADK in Mesh initially
        mainMeshOwner = msg.sender;                          // the address representing the ADK Mesh
        statusAddress = msg.sender;                          // initially also the owner
        requestID = 0; 
        ADKDepositAddrCount = 0;
        minimumADKforXChainTransfer = 10000000000;           // initially 100 ADK = 10000000000 units
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    function transfer(address _to, uint256 _value) public returns (bool success) {

        require(balances[msg.sender] >= _value);
        require(address(this) != _to); // prevent accidental send of tokens to the contract itself! RTFM people!
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        uint256 vallowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && vallowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (vallowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balances[_owner];
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

        return allowed[_owner][_spender];
    }
    
    

    modifier onlyOwnerOrStatusAdmin {

        require(msg.sender == mainMeshOwner || msg.sender == statusAddress);
        _;
    }

    modifier onlyOwner {

        require(msg.sender == mainMeshOwner);
        _;
    }
    
    
    
    function ADM_setNewMinADKLimit(uint256 _newLimit) public onlyOwner {

        minimumADKforXChainTransfer = _newLimit;
    }

    
    function ADM_setNewStatusAdmin(address _newAdmin) public onlyOwner {

        statusAddress = _newAdmin;
    }

    
    function ADM_setNewOwner(address _newOwner) public onlyOwner {

        require(balances[_newOwner] == 0); // new mesh address cannot hold wADK already.
        mainMeshOwner = _newOwner;
        if ( balances[msg.sender] > 0 ) {
            transfer( _newOwner , balances[msg.sender] );
        }
    }
    
     
     event EvtTransferFromMesh(address _receiver, address _mesh_address, string _adk_address, uint256 _value);
     event EvtTransferToMesh(address _sender, address _mesh_address, string _adk_address, uint256 _value, uint256 _requestID, uint256 _fees);
     event EvtADKDepositAddressUpd(string ADK_DEPOSIT_ADDRESS_LIVE);
     event EvtStatusChanged(uint256 _requestID, string _oldStatus, string _newStatus);
    
    
    
    modifier requireValidADKAddress (string memory _adk_address) {

        bool valid = true;
        bytes memory adkBytes = bytes (_adk_address);
        require(adkBytes.length == 81 || adkBytes.length == 90); //address with or without checksum
        
        for (uint i = 0; i < adkBytes.length; i++) {
            if ( 
                ! (
                    uint8(adkBytes[i]) == 57 //9
                     || (uint8(adkBytes[i]) >= 65 && uint8(adkBytes[i]) <= 90) //A-Z
                  )
               ) valid = false;
        }
        require (valid);
        _;
    } 
     
    
    function USR_transferToMesh(string memory _adk_address, uint256 _value) payable requireValidADKAddress (_adk_address) public {

        requestID += 1;
        require (_value >= minimumADKforXChainTransfer);
        transfer( mainMeshOwner , _value );
        requestStatus[requestID] = "RQ"; // transfer to mesh requested
        emit EvtTransferToMesh(msg.sender, mainMeshOwner, _adk_address, _value, requestID, msg.value);
    }
    
    
    
    function ADM_transferFromMesh(address _receiver, uint256 _value, string memory _from_adk_address) public {

        if (msg.sender == mainMeshOwner) { // if owner sends, then just use transfer 
            transfer( _receiver , _value );
        }
        else {
            transferFrom(mainMeshOwner, _receiver, _value); // otherwise use transferFrom (meaning the owner had to authorize the transfer first)
        }                                            // This will be used by custom helper contracts to pay multiple accounts etc
        
        emit EvtTransferFromMesh( _receiver, msg.sender, _from_adk_address, _value);
    }
    
    
    function ADM_updateMeshDepositAddress(string memory _new_deposit_adk_address) public 
                           onlyOwnerOrStatusAdmin requireValidADKAddress (_new_deposit_adk_address){

        
        ADK_DEPOSIT_ADDRESS_PREVIOUS = ADK_DEPOSIT_ADDRESS_LIVE; 
        ADK_DEPOSIT_ADDRESS_LIVE = _new_deposit_adk_address; 
        
        ADKDepositAddrCount += 1;
        ADKDepositAddrHistory[ADKDepositAddrCount] = _new_deposit_adk_address; // holds the history of all ADK Mesh deposit addresses
        
        emit EvtADKDepositAddressUpd(ADK_DEPOSIT_ADDRESS_LIVE);
    }
    
    
    function ADM_updateRequestStatus(uint256 _requestID, string memory _status) public onlyOwnerOrStatusAdmin {

        string memory oldStatus = requestStatus[requestID];
        requestStatus[requestID] = _status;
        emit EvtStatusChanged(_requestID, oldStatus, _status);
    }

    
    function USR_ETHAddrEncode(bytes memory ethAddr) public pure returns(string memory) {

        bytes memory alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ9";
        require(ethAddr.length == 20); //20 bytes / an ethereum address 
    
        bytes memory str = new bytes(81);
        for (uint i = 0; i < 40; i++) {
            str[i*2+1] = alphabet[10+uint(uint8(ethAddr[i%20] & 0x0f))];  // add 10 to mix up the characters
            str[i*2] = alphabet[uint(uint8(ethAddr[i%20] >> 4))];  
        }
        str[80] = "9";
        return string(str);
    }
    
    
    function USR_ETHAddrDecode(string memory adkString) public pure returns(address) {

        bytes memory str = new bytes(20); //2*40 hex char plus leading 0x
        bytes memory adkString_b = bytes(adkString);
        for (uint i = 0; i < 20; i++) {
            uint8 low = uint8(adkString_b[i*2+1])==57? 26 - 10 : uint8(adkString_b[i*2+1]) - 65 - 10;
            uint8 high = uint8(adkString_b[i*2])==57? 26 : uint8(adkString_b[i*2]) - 65;
            str[i] = bytes1(high * 16 + low); // Low Hex Char 
        }
        return utilBytesToAddress(str);
    }
    
    
    function utilBytesToAddress(bytes memory bys) private pure returns (address addr) {

        require(bys.length == 20);
        assembly {
          addr := mload(add(bys,20))
        } 
    }
    
    
    event EvtReceivedGeneric(address, uint);
    event EvtReceivedFee(address, uint, string);
    
    receive() external payable {
         emit EvtReceivedGeneric(msg.sender, msg.value);
    }
    
    
    function ADM_CollectFees(address payable _collectToAddress, uint256 _value) onlyOwnerOrStatusAdmin public {

        _collectToAddress.transfer(_value); 
    }

    
    function USR_FeePayment(string memory _feeInfo) payable public {

         emit EvtReceivedFee(msg.sender, msg.value, _feeInfo);
    }
    
    
}