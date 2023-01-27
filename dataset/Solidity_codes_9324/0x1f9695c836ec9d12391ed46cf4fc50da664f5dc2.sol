

pragma solidity ^0.7.1;

contract Souls{



    constructor(){
        supportedInterfaces[0x80ac58cd] = true;
        supportedInterfaces[0x5b5e139f] = true;
        supportedInterfaces[0x01ffc9a7] = true;

    }


    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    mapping(address => uint256) internal BALANCES;
    mapping (uint256 => address) internal ALLOWANCE;
    mapping (address => mapping (address => bool)) internal AUTHORISED;

    uint[] SOULS;  //Array of all souls [tokenId,tokenId,...]
    mapping(uint256 => address) OWNERS;  //Mapping of soul owners

    string private __name = "EtherSouls";
    string private __symbol = "SOUL";
    bytes private __uriBase = bytes("https://www.ethersouls.xyz/tokenData/metadata?id=");


    mapping(address => uint[]) internal OWNER_INDEX_TO_ID;
    mapping(uint => uint) internal OWNER_ID_TO_INDEX;
    mapping(uint => uint) internal ID_TO_INDEX;

    address constant VITALIK = 0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B;

    function isValidToken(uint256 _tokenId) internal view returns(bool){

        return OWNERS[_tokenId] != address(0);
    }


    function balanceOf(address _owner) external view returns (uint256){

        return BALANCES[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns(address){

        require(isValidToken(_tokenId),"invalid");
        return OWNERS[_tokenId];
    }


    function separate() external {

        uint tokenId = uint(msg.sender);

        require(OWNERS[tokenId] == address(0),"exists");


        OWNERS[tokenId] = msg.sender;
        BALANCES[msg.sender]++;

        OWNER_ID_TO_INDEX[tokenId] = OWNER_INDEX_TO_ID[msg.sender].length;
        OWNER_INDEX_TO_ID[msg.sender].push(tokenId);

        ID_TO_INDEX[tokenId] = SOULS.length;
        SOULS.push(tokenId);

        emit Transfer(address(0),VITALIK,tokenId);
        emit Transfer(VITALIK,msg.sender,tokenId);
    }


    function approve(address _approved, uint256 _tokenId)  external{

        address owner = ownerOf(_tokenId);
        require( owner == msg.sender                    //Require Sender Owns Token
            || AUTHORISED[owner][msg.sender]                //  or is approved for all.
        ,"permission");
        emit Approval(owner, _approved, _tokenId);
        ALLOWANCE[_tokenId] = _approved;
    }

    function getApproved(uint256 _tokenId) external view returns (address) {

        require(isValidToken(_tokenId),"invalid");
        return ALLOWANCE[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {

        return AUTHORISED[_owner][_operator];
    }


    function setApprovalForAll(address _operator, bool _approved) external {

        emit ApprovalForAll(msg.sender,_operator, _approved);
        AUTHORISED[msg.sender][_operator] = _approved;
    }


    function transferFrom(address _from, address _to, uint256 _tokenId) public {


        address owner = ownerOf(_tokenId);

        require ( owner == msg.sender             //Require sender owns token
        || ALLOWANCE[_tokenId] == msg.sender      //or is approved for this token
            || AUTHORISED[owner][msg.sender]          //or is approved for all
        ,"permission");
        require(owner == _from,"owner");
        require(_to != address(0),"zero");

        emit Transfer(_from, _to, _tokenId);


        OWNERS[_tokenId] =_to;

        BALANCES[_from]--;
        BALANCES[_to]++;

        if(ALLOWANCE[_tokenId] != address(0)){
            delete ALLOWANCE[_tokenId];
        }

        uint oldIndex = OWNER_ID_TO_INDEX[_tokenId];
        if(oldIndex != OWNER_INDEX_TO_ID[_from].length - 1){
            OWNER_INDEX_TO_ID[_from][oldIndex] = OWNER_INDEX_TO_ID[_from][OWNER_INDEX_TO_ID[_from].length - 1];
            OWNER_ID_TO_INDEX[OWNER_INDEX_TO_ID[_from][oldIndex]] = oldIndex;
        }
        OWNER_INDEX_TO_ID[_from].pop();

        OWNER_ID_TO_INDEX[_tokenId] = OWNER_INDEX_TO_ID[_to].length;
        OWNER_INDEX_TO_ID[_to].push(_tokenId);

    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) public {

        transferFrom(_from, _to, _tokenId);

        uint32 size;
        assembly {
            size := extcodesize(_to)
        }
        if(size > 0){
            ERC721TokenReceiver receiver = ERC721TokenReceiver(_to);
            require(receiver.onERC721Received(msg.sender,_from,_tokenId,data) == bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")),"receiver");
        }

    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external {

        safeTransferFrom(_from,_to,_tokenId,"");
    }




    function tokenURI(uint256 _tokenId) public view returns (string memory){

        require(isValidToken(_tokenId));

        uint[50] memory reversed;

        string memory uri = string(__uriBase);


        string[10] memory lib;
        lib[0] = "0";
        lib[1] = "1";
        lib[2] = "2";
        lib[3] = "3";
        lib[4] = "4";
        lib[5] = "5";
        lib[6] = "6";
        lib[7] = "7";
        lib[8] = "8";
        lib[9] = "9";

        uint len = 0;
        while (_tokenId != 0) {
            uint remainder = _tokenId % 10;
            _tokenId /= 10;
            reversed[len] = remainder;
            len++;
        }

        for(uint j = len; j > 0; j--){
            uri = string(abi.encodePacked(uri,lib[reversed[j-1]]));
        }

        return uri;

    }









function name() external view returns (string memory _name){

        return __name;
    }

    function symbol() external view returns (string memory _symbol){

        return __symbol;
    }



    function totalSupply() external view returns (uint256){

        return SOULS.length;
    }

    function tokenByIndex(uint256 _index) external view returns(uint256){

        require(_index < SOULS.length,"index");
        return SOULS[_index];


    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256){

        require(_index < BALANCES[_owner],"index");
        return OWNER_INDEX_TO_ID[_owner][_index];
    }


    mapping (bytes4 => bool) internal supportedInterfaces;
    function supportsInterface(bytes4 interfaceID) external view returns (bool){

        return supportedInterfaces[interfaceID];
    }
}




interface ERC721TokenReceiver {

    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);

}