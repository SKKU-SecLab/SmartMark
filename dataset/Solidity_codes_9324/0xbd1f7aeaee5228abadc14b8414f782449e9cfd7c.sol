
pragma solidity ^0.6.2;


contract ERC666{


    constructor() public{

        supportedInterfaces[0x80ac58cd] = true;
        supportedInterfaces[0x780e9d63] = true;
        supportedInterfaces[0x5b5e139f] = true;
        supportedInterfaces[0x01ffc9a7] = true;

    }

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);


    mapping(address => int256) internal BALANCES;
    mapping (uint256 => address) internal ALLOWANCE;
    mapping (address => mapping (address => bool)) internal AUTHORISED;

    uint total_supply = uint(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF)  * 666;


    mapping(uint256 => address) OWNERS;  //Mapping of ticket owners

    string private __name = "CryptoSatan";
    string private __symbol = "SATAN";
    string private __tokenURI = "https://anallergytoanalogy.github.io/beelzebub/metadata/beelzebub.json";


    function isValidToken(uint256 _tokenId) internal view returns(bool){

        return _tokenId < total_supply;
    }


    function balanceOf(address _owner) external view returns (uint256){

        return uint(666 + BALANCES[_owner]);
    }

    function ownerOf(uint256 _tokenId) public view returns(address){

        require(isValidToken(_tokenId),"invalid");
        uint innerId = tokenId_to_innerId(_tokenId);

        if(OWNERS[innerId] == address(0)){
            return address(_tokenId / 666 + 1);
        }else{
            return OWNERS[innerId];
        }
    }

    function tokenId_to_innerId(uint _tokenId) internal pure returns(uint){

        return _tokenId /6;
    }


    function approve(address _approved, uint256 _tokenId)  external{

        address owner = ownerOf(_tokenId);
        uint innerId = tokenId_to_innerId(_tokenId);

        require( owner == msg.sender                    //Require Sender Owns Token
        || AUTHORISED[owner][msg.sender]                //  or is approved for all.
        ,"permission");
        for(uint  i = 0 ; i < 6; i++){
            emit Approval(owner, _approved, innerId*6 + i);
        }

        ALLOWANCE[innerId] = _approved;
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


        uint innerId = tokenId_to_innerId(_tokenId);

        address owner = ownerOf(_tokenId);

        require ( owner == msg.sender             //Require sender owns token
        || ALLOWANCE[innerId] == msg.sender      //or is approved for this token
        || AUTHORISED[owner][msg.sender]          //or is approved for all
        ,"permission");
        require(owner == _from,"owner");
        require(_to != address(0),"zero");


        for(uint  i = 0 ; i < 6; i++){
            emit Transfer(_from, _to, innerId*6 + i);
        }

        OWNERS[innerId] =_to;

        BALANCES[_from] -= 6;
        BALANCES[_to] += 6;

        if(ALLOWANCE[innerId] != address(0)){
            delete ALLOWANCE[innerId];
        }

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

        require(isValidToken(_tokenId),"invalid");
        return __tokenURI;
    }

    function name() external view returns (string memory _name){

        return __name;
    }

    function symbol() external view returns (string memory _symbol){

        return __symbol;
    }



    function totalSupply() external view returns (uint256){

        return total_supply;
    }

    function tokenByIndex(uint256 _index) external view returns(uint256){

        require(_index < total_supply,"index");
        return _index;
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256){

        require(_index < uint(666 + BALANCES[_owner]),"index");
        return (uint(_owner) - 1) * 666 + _index;
    }

    mapping (bytes4 => bool) internal supportedInterfaces;
    function supportsInterface(bytes4 interfaceID) external view returns (bool){

        return supportedInterfaces[interfaceID];
    }
}




interface ERC721TokenReceiver {

    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);

}

contract ValidReceiver is ERC721TokenReceiver{

    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) override external returns(bytes4){

        _operator;_from;_tokenId;_data;
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
}

contract InvalidReceiver is ERC721TokenReceiver{

    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) override external returns(bytes4){

        _operator;_from;_tokenId;_data;
        return bytes4(keccak256("suck it nerd"));
    }
}