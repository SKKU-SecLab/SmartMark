
pragma solidity >=0.8.3 <0.9.0;

interface ERC721TokenReceiver {

  function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);

}

contract ERC721Token {

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
  
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    uint256 internal count = 0;
    uint256 internal burned = 0;
    mapping (uint256 => address) internal owners;
    mapping (uint256 => uint256) internal tokenCIDs;
    mapping (uint256 => address) internal approveds;
    mapping (address => mapping (address => bool)) internal operators;
    
    
    string public name;
    string public symbol;

    constructor(string memory _name, string memory _symbol, uint256[] memory _tokenCIDs) {
        name = _name;
        symbol = _symbol;
        
        for (uint256 i = 0; i < _tokenCIDs.length; i++) {
            mint(_tokenCIDs[i]);
        }
    }
    
    function mint(uint256 _tokenCID) public {

        require(0 < ++count);

        owners[count] = msg.sender;
        tokenCIDs[count] = _tokenCID;
        emit Transfer(address(0), msg.sender, count);
    }
    
    function mintMultiple(uint256[] calldata _tokenCIDs) public {

        for (uint256 i = 0; i < _tokenCIDs.length; i++) {
            mint(_tokenCIDs[i]);
        }
    }
    
    function burn(uint256 _tokenId) public {

        address _owner = owners[_tokenId];
        require(
            _owner != address(0) && 
            (msg.sender == _owner || operators[_owner][msg.sender] || msg.sender == approveds[_tokenId])
        );
        owners[_tokenId] = address(0);
        approveds[_tokenId] = address(0);
        tokenCIDs[_tokenId] = 0;
        burned++;
        emit Transfer(_owner, address(0), _tokenId);
    }
    
    function decimals() public pure returns (uint8) {

        return 0;
    }
    
    function totalSupply() public view returns (uint256) {

        return count - burned;
    }

    function tokenURI(uint256 _tokenId) public view returns (string memory) {

        address _owner = owners[_tokenId];
        require(_owner != address(0));
        
        uint256 _tokenCID = tokenCIDs[_tokenId];
        
        return string(abi.encodePacked("https://ipfs.io/ipfs/", encode(abi.encodePacked(hex"1220", _tokenCID))));
    }

    function balanceOf(address _owner) public view returns (uint256) {

        require(_owner != address(0));
        uint256 _balance = 0;
        for (uint256 _tokenId = count; _tokenId > 0; _tokenId--) {
            if (owners[_tokenId] == msg.sender) {
                _balance++;
            }
        }
        return _balance;
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {

        address _owner = owners[_tokenId];
        require(_owner != address(0));
        return _owner;
    }

    function approve(address _approved, uint256 _tokenId) public {

        address _owner = owners[_tokenId];
        require(_owner != address(0) && (msg.sender == _owner || operators[_owner][msg.sender]));
        approveds[_tokenId] = _approved;
        emit Approval(_owner, _approved, _tokenId);
    }
    
    function getApproved(uint256 _tokenId) public view returns (address) {

        address _owner = owners[_tokenId];
        require(_owner != address(0));
        address _approved = approveds[_tokenId];
        return _approved;
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public {

        address _owner = owners[_tokenId];
        require(
            _owner != address(0) && 
            (msg.sender == _owner || operators[_owner][msg.sender] || msg.sender == approveds[_tokenId]) &&
            _from == _owner && 
            _to != address(0)
        );
        owners[_tokenId] = _to;
        approveds[_tokenId] = address(0);
        emit Transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata _data) public {

        _safeTransferFrom(_from, _to, _tokenId, _data);
    }
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public {

        _safeTransferFrom(_from, _to, _tokenId, "");
    }

    function _safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) private {

        transferFrom(_from, _to, _tokenId);
        
        if (isContract(_to)) {
            bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
            require(retval == 0x150b7a02);
        }
    }

    function setApprovalForAll(address _operator, bool _approved) public {

        operators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }
    
    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {

        return operators[_owner][_operator];
    }
    
    function supportsInterface(bytes4 _interfaceID) public pure returns (bool) {

        return _interfaceID == 0x80ac58cd || _interfaceID == 0x01ffc9a7;
    }
    
    function isContract(address _addr) private view returns (bool addressCheck) {

        
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(_addr) } // solhint-disable-line
        addressCheck = (codehash != 0x0 && codehash != accountHash);
    }
    
    bytes constant ALPHABET = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
    function encode(bytes memory input) private pure returns (string memory) {

        uint8 leading_zeros = 0;
        for (uint8 i = 0; i < input.length; i++) {
            if (input[i] == 0) {
                leading_zeros++;
            } else {
                break;
            }
        }
        
        uint8 length = uint8((input.length - leading_zeros) * 138 / 100 + 1); // log(256) / log(58), rounded up.
        uint8[] memory b58_digits = new uint8[](length); 

        b58_digits[0] = 0;
        uint8 digitlength = 1;
        for (uint8 i = leading_zeros; i < input.length; i++) {
            uint32 carry = uint8(input[i]);
            for (uint8 j = 0; j < digitlength; j++) {
                carry += uint32(b58_digits[j]) * 256;
                b58_digits[j] = uint8(carry % 58);
                carry /= 58;
            }
            
            while (carry > 0) {
                b58_digits[digitlength] = uint8(carry % 58);
                digitlength++;
                carry /= 58;
            }
        }
        
        if (digitlength == 1 && b58_digits[0] == 0) {
            digitlength = 0;
        }
        
        bytes memory b58_encoding = new bytes(leading_zeros + digitlength);
        for (uint8 i = 0; i < leading_zeros; i++) {
            b58_encoding[i] = '1';
        }
        for (uint8 j = 0; j < digitlength; j++) {
            b58_encoding[j + leading_zeros] = ALPHABET[uint8(b58_digits[digitlength - j - 1])];
        }
        return string(b58_encoding);
    }

}

