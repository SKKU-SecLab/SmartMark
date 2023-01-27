
pragma solidity ^0.6.2;


contract Pathogen721{


    constructor() public{

        supportedInterfaces[0x6466353c] = true;
        supportedInterfaces[0x780e9d63] = true;
        supportedInterfaces[0x5b5e139f] = true;
        supportedInterfaces[0x01ffc9a7] = true;

        LAST_INFECTION = now;
    }

    mapping (   uint    =>  uint)      STRAINS;
    mapping (address => uint)   IMMUNITY;
    mapping (address => uint)  DEATH_DATE;
    uint constant INFECTIOUSNESS = 3;
    uint constant STABILITY = 5;

    uint public LAST_INFECTION = 0;

    uint public INFECTIONS = 0;


    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);


    mapping(address => uint256) internal BALANCES;
    mapping (uint256 => address) internal ALLOWANCE;
    mapping (address => mapping (address => bool)) internal AUTHORISED;

    uint[] PATHOGENS;                      //Array of all tickets [tokenId,tokenId,...]
    mapping(uint256 => address) OWNERS;  //Mapping of ticket owners

    string private __name = "EtherVirus";
    string private __symbol = "2020-nEthV";
    string private __tokenURI = "https://anallergytoanalogy.github.io/pathogen/metadata/2020-nEthV.json";

    mapping(address => uint[]) internal OWNER_INDEX_TO_ID;
    mapping(uint => uint) internal OWNER_ID_TO_INDEX;
    mapping(uint => uint) internal ID_TO_INDEX;



    function vitalSigns(address patient) public view returns(
        bool alive,
        uint pathogens,
        uint immunity,
        uint death_date
    ){

        return (
        isAlive(patient),
        BALANCES[patient],
        IMMUNITY[patient],
        DEATH_DATE[patient]
        );
    }

    function isAlive(address patient) public view returns(bool){

        return (DEATH_DATE[patient] == 0 || DEATH_DATE[patient] > now);
    }


    function get_now() public view returns (uint){

        return now;
    }
    function get_block_number() public view returns(uint){

        return block.number;
    }
    function patientZero() public{

        require(INFECTIONS == 0,"exists");
        for(uint i = 0; i < INFECTIOUSNESS; i++){
            issueToken(msg.sender,1);
        }
        DEATH_DATE[msg.sender] = now + 1 weeks;
        INFECTIONS++;

        IMMUNITY[msg.sender] = 1;
        LAST_INFECTION = now;
    }
    function infectMe() public{

        require(LAST_INFECTION + 1 weeks > now ,"extinct");
        require(isAlive(msg.sender),"dead");
        require(BALANCES[msg.sender] == 0,"sick");
        INFECTIONS++;

        uint strain = STRAINS[PATHOGENS[PATHOGENS.length-1]];
        if(strain < IMMUNITY[msg.sender]){
            strain = IMMUNITY[msg.sender] + 1;
        }

        for(uint i = 0; i < INFECTIOUSNESS; i++){
            issueToken(msg.sender,strain);
        }
        DEATH_DATE[msg.sender] = now + 1 weeks;

        IMMUNITY[msg.sender] = strain;
        LAST_INFECTION = now;
    }

    function vaccinate(uint tokenId, uint vaccine) public{

        require(isValidToken(tokenId),"invalid");
        require(isAlive(msg.sender),"dead");
        require(BALANCES[msg.sender] == 0,"sick");
        require(STRAINS[tokenId] > IMMUNITY[msg.sender],"obsolete");

        uint vaccine_processed_0 = uint(0) - uint(keccak256(abi.encodePacked(vaccine)));
        uint vaccine_processed_1 = uint(keccak256(abi.encodePacked(vaccine_processed_0)));

        require(STRAINS[tokenId] - vaccine_processed_1 == 0,"ineffective");

        IMMUNITY[msg.sender] = STRAINS[tokenId];
    }



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


    function issueToken(address owner, uint strain) internal {

        uint tokenId = PATHOGENS.length + 1;

        OWNERS[tokenId] = owner;
        BALANCES[owner]++;
        STRAINS[tokenId] = strain;


        OWNER_ID_TO_INDEX[tokenId] = OWNER_INDEX_TO_ID[owner].length;
        OWNER_INDEX_TO_ID[owner].push(tokenId);

        ID_TO_INDEX[tokenId] = PATHOGENS.length;
        PATHOGENS.push(tokenId);

        emit Transfer(address(0),owner,tokenId);
    }

    function canInfect(address vector, address victim, uint _tokenId) public view returns(string memory){

        if(victim.balance == 0) return "victim_inactive";
        if(DEATH_DATE[victim] > 0 && now >= DEATH_DATE[victim]) return "victim_dead";
        if(now >= DEATH_DATE[vector]) return "vector_dead";
        if(BALANCES[victim] > 0)    return "victim_sick";
        if(STRAINS[_tokenId] <= IMMUNITY[victim]) return "victim_immune";
        if(BALANCES[vector] == 0) return "vector_healthy";
        return "okay";
    }

    function infect(address vector, address victim, uint _tokenId) internal{

        require(victim.balance > 0,"victim_inactive");

        require(DEATH_DATE[victim] == 0 || now < DEATH_DATE[victim],"victim_dead");
        require(STRAINS[_tokenId] > IMMUNITY[victim],"victim_immune");
        require(BALANCES[victim] == 0,"victim_sick");

        require(now < DEATH_DATE[vector],"vector_dead");
        require(BALANCES[vector] > 0,"vector_healthy");

        DEATH_DATE[victim] = now + 1 weeks;

        uint strain = STRAINS[_tokenId];
        strain += (block.timestamp%STABILITY+1)/STABILITY;

        for(uint i = 0; i < INFECTIOUSNESS-1; i++){
            issueToken(victim,strain);
        }
        IMMUNITY[victim] = strain;
        LAST_INFECTION = now;

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

        infect(_from, _to,  _tokenId);


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


        if(BALANCES[_from] == 0 ){
            DEATH_DATE[_from] += 52000 weeks;
        }else{
            INFECTIONS++;
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

        return PATHOGENS.length;
    }

    function tokenByIndex(uint256 _index) external view returns(uint256){

        require(_index < PATHOGENS.length,"index");
        return PATHOGENS[_index];


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