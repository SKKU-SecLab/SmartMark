
pragma solidity ^0.8.0;

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == root;
    }
}// MIT

pragma solidity ^0.8.4;

interface IERC165 {

    function supportsInterface(bytes4 interfaceID) external view returns (bool);

}// MIT

pragma solidity ^0.8.4;

interface IERC721 /* is ERC165 */ {

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) external view returns (uint256);


    function ownerOf(uint256 _tokenId) external view returns (address);


    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external;


    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;


    function transferFrom(address _from, address _to, uint256 _tokenId) external;


    function approve(address _approved, uint256 _tokenId) external;


    function setApprovalForAll(address _operator, bool _approved) external;


    function getApproved(uint256 _tokenId) external view returns (address);


    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

}// MIT

pragma solidity ^0.8.4;

interface IERC721Metadata /* is ERC721 */ {

    function name() external view returns (string memory _name);


    function symbol() external view returns (string memory _symbol);


    function tokenURI(uint256 _tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.4;

interface IERC721TokenReceiver {

    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);

}//Cool kids only

pragma solidity ^0.8.0;

contract Doomsday is IERC721, IERC165, IERC721Metadata{



    constructor(bytes32 _cityRoot, address _earlyAccessHolders){
        supportedInterfaces[0x80ac58cd] = true; //ERC721
        supportedInterfaces[0x5b5e139f] = true; //ERC721Metadata
        supportedInterfaces[0x01ffc9a7] = true; //ERC165

        owner = msg.sender;
        cityRoot = _cityRoot;

        earlyAccessHolders = _earlyAccessHolders;
    }

    address public owner;
    address earlyAccessHolders;

    mapping(address => uint256) internal balances;
    mapping (uint256 => address) internal allowance;
    mapping (address => mapping (address => bool)) internal authorised;

    uint16[] tokenIndexToCity;  //Array of all tokens [cityId,cityId,...]
    mapping(uint256 => address) owners;  //Mapping of owners

    string private __name = "Doomsday NFT";
    string private __symbol = "BUNKER";
    bytes private __uriBase = bytes("https://gateway.pinata.cloud/ipfs/QmUwPH9PmTQrT67M633AJRXACsecmRTihf4DUbJZb9y83M/");
    bytes private __uriSuffix = bytes(".json");

    uint constant MAX_CITIES = 38611;       //from table

    int64 constant MAP_WIDTH         = 4320000;   //map units
    int64 constant MAP_HEIGHT        = 2588795;   //map units
    int64 constant BASE_BLAST_RADIUS = 100000;   //map units

    uint constant MINT_COST = 0.04 ether;

    uint constant MINT_PERCENT_WINNER       = 50;
    uint constant MINT_PERCENT_CALLER       = 25;
    uint constant MINT_PERCENT_CREATOR      = 25;

    uint constant REINFORCE_PERCENT_WINNER  = 90;
    uint constant REINFORCE_PERCENT_CREATOR = 10;


    uint constant IMPACT_BLOCK_INTERVAL = 120;

    mapping(uint16 => uint) public cityToToken;
    mapping(uint16 => int64[2]) coordinates;
    bytes32 cityRoot;

    event Inhabit(uint16 indexed _cityId, uint256 indexed _tokenId);
    event Reinforce(uint256 indexed _tokenId);
    event Impact(uint256 indexed _tokenId);

    mapping(uint => bytes32) structuralData;

    function getStructuralData(uint _tokenId) public view returns (uint8 reinforcement, uint8 damage, bytes32 lastImpact){

        bytes32 _data = structuralData[_tokenId];

        reinforcement = uint8(uint(((_data << 248) >> 248)));
        damage = uint8(uint(((_data << 240) >> 240) >> 8));
        lastImpact = (_data >> 16);

        return (reinforcement, damage, lastImpact);
    }
    function setStructuralData(uint _tokenId, uint8 reinforcement, uint8 damage, bytes32 lastImpact) internal{

        bytes32 _reinforcement = bytes32(uint(reinforcement));
        bytes32 _damage = bytes32(uint(damage)) << 8;
        bytes32 _lastImpact = encodeImpact(lastImpact) << 16;

        structuralData[_tokenId] = _reinforcement ^ _damage ^ _lastImpact;
    }
    function encodeImpact(bytes32 _impact) internal pure returns(bytes32){

        return (_impact << 16) >> 16;
    }


    uint public reinforcements;
    uint public destroyed;
    uint public evacuatedFunds;

    uint ownerWithdrawn;
    bool winnerWithdrawn;

    function tokenToCity(uint _tokenId) public view returns(uint16){

        return tokenIndexToCity[_tokenId - 1];
    }

    uint public startTime;
    uint SALE_TIME = 7 days;
    uint EARLY_ACCESS_TIME = 1 days;

    function startPreApocalypse() public{

        require(msg.sender == owner,"owner");

        require(startTime == 0,"started");
        startTime = block.timestamp;
    }
    enum Stage {Initial,PreApocalypse,Apocalypse,PostApocalypse}
    function stage() public view returns(Stage){

        if(startTime == 0){
            return Stage.Initial;
        }else if(block.timestamp < startTime + SALE_TIME && tokenIndexToCity.length < MAX_CITIES){
            return Stage.PreApocalypse;
        }else if(destroyed < tokenIndexToCity.length - 1){
            return Stage.Apocalypse;
        }else{
            return Stage.PostApocalypse;
        }
    }

    function inhabit(uint16 _cityId, int64[2] calldata _coordinates, bytes32[] memory proof) public payable{

        require(stage() == Stage.PreApocalypse,"stage");
        if(block.timestamp < startTime + EARLY_ACCESS_TIME){
            require(IERC721(earlyAccessHolders).balanceOf(msg.sender) > 0,"early");
        }


        bytes32 leaf = keccak256(abi.encodePacked(_cityId,_coordinates[0],_coordinates[1]));

        require(MerkleProof.verify(proof, cityRoot, leaf),"proof");

        require(cityToToken[_cityId] == 0 && coordinates[_cityId][0] == 0 && coordinates[_cityId][1] == 0,"inhabited");

        require(
            _coordinates[0] >= -MAP_WIDTH/2 &&
            _coordinates[0] <= MAP_WIDTH/2 &&

            _coordinates[1] >= -MAP_HEIGHT/2 &&
            _coordinates[1] <= MAP_HEIGHT/2,
            "off map"
        );  //Not strictly necessary but proves the whitelist hasnt been fucked with


        require(msg.value == MINT_COST,"cost");

        coordinates[_cityId] = _coordinates;

        tokenIndexToCity.push(_cityId);

        uint _tokenId = tokenIndexToCity.length;

        balances[msg.sender]++;
        owners[_tokenId] = msg.sender;
        cityToToken[_cityId] = _tokenId;

        emit Inhabit(_cityId, _tokenId);
        emit Transfer(address(0),msg.sender,_tokenId);
    }

    function isUninhabited(uint16 _cityId) public view returns(bool){

        return coordinates[_cityId][0] == 0 && coordinates[_cityId][1] == 0;
    }

    function reinforce(uint _tokenId) public payable{


        Stage _stage = stage();

        require(_stage == Stage.PreApocalypse || _stage == Stage.Apocalypse,"stage");

        require(ownerOf(_tokenId) == msg.sender,"owner");


        (uint8 _reinforcement, uint8 _damage, bytes32 _lastImpact) = getStructuralData(_tokenId);

        if(_stage == Stage.Apocalypse){
            require(!checkVulnerable(_tokenId,_lastImpact),"vulnerable");
        }


        require(msg.value == (2 ** _reinforcement) *  MINT_COST,"cost");


        setStructuralData(_tokenId,_reinforcement+1,_damage,_lastImpact);

        reinforcements += msg.value - (MINT_COST * MINT_PERCENT_CALLER / 100);

        emit Reinforce(_tokenId);
    }
    function evacuate(uint _tokenId) public{

        Stage _stage = stage();
        require(_stage == Stage.PreApocalypse || _stage == Stage.Apocalypse,"stage");

        require(ownerOf(_tokenId) == msg.sender,"owner");


        if(_stage == Stage.Apocalypse){
            require(!isVulnerable(_tokenId),"vulnerable");
        }

        uint cityCount = tokenIndexToCity.length;


        uint fromPool =
                ((MINT_COST * cityCount * MINT_PERCENT_WINNER / 100 - evacuatedFunds)
                / totalSupply())
               / 2;


        uint toWithdraw = fromPool + getEvacuationRebate(_tokenId);

        balances[owners[_tokenId]]--;
        delete cityToToken[tokenToCity(_tokenId)];
        destroyed++;

        evacuatedFunds += fromPool;

        emit Transfer(owners[_tokenId],address(0),_tokenId);


        payable(msg.sender).send(
            toWithdraw
        );
    }


    function getEvacuationRebate(uint _tokenId) public view returns(uint) {

        (uint8 _reinforcement, uint8 _damage, bytes32 _lastImpact) = getStructuralData(_tokenId);
        _lastImpact;
        return MINT_COST * (1 + _reinforcement - _damage) *  MINT_PERCENT_CALLER / 100;
    }

    function confirmHit(uint _tokenId) public{

        require(stage() == Stage.Apocalypse,"stage");
        require(isValidToken(_tokenId),"invalid");

        (uint8 _reinforcement, uint8 _damage, bytes32 _lastImpact) = getStructuralData(_tokenId);


        require(checkVulnerable(_tokenId,_lastImpact),"vulnerable");

        (int64[2] memory _coordinates, int64 _radius, bytes32 _impactId) = currentImpact();
        _coordinates;_radius;

        _impactId = encodeImpact(_impactId);

        emit Impact(_tokenId);


        if(_damage < _reinforcement){
            _damage++;
            setStructuralData(_tokenId,_reinforcement,_damage,_impactId);
        }else{
            balances[owners[_tokenId]]--;
            delete cityToToken[tokenToCity(_tokenId)];
            destroyed++;

            emit Transfer(owners[_tokenId],address(0),_tokenId);
        }

        payable(msg.sender).send(MINT_COST * MINT_PERCENT_CALLER / 100);
    }


    function winnerWithdraw(uint _winnerTokenId) public{

        require(stage() == Stage.PostApocalypse,"stage");
        require(isValidToken(_winnerTokenId),"invalid");

        require(msg.sender == ownerOf(_winnerTokenId),"ownerOf");
        require(!winnerWithdrawn,"withdrawn");

        winnerWithdrawn = true;

        uint toWithdraw = winnerPrize(_winnerTokenId);
        if(toWithdraw > address(this).balance){
            toWithdraw = address(this).balance;
        }

        payable(msg.sender).send(toWithdraw);

    }

    function ownerWithdraw() public{

        require(msg.sender == owner,"owner");

        uint cityCount = tokenIndexToCity.length;

        uint toWithdraw = MINT_COST * cityCount * (MINT_PERCENT_CREATOR) / 100
            + reinforcements * REINFORCE_PERCENT_CREATOR / 100
            - ownerWithdrawn;

        require(toWithdraw > 0,"empty");

        if(toWithdraw > address(this).balance){
            toWithdraw = address(this).balance;
        }
        ownerWithdrawn += toWithdraw;

        payable(msg.sender).send(toWithdraw);
    }


    function currentImpact() public view returns (int64[2] memory _coordinates, int64 _radius, bytes32 impactId){

        uint eliminationBlock = block.number - (block.number % IMPACT_BLOCK_INTERVAL) - 5;
        int hash = int(uint(blockhash(eliminationBlock))%uint(type(int).max) );


        int o = MAP_HEIGHT/2/int(totalSupply()+1);

        if(o < BASE_BLAST_RADIUS){
            o = BASE_BLAST_RADIUS;
        }
        _coordinates[0] = int64(hash%MAP_WIDTH - MAP_WIDTH/2);
        _coordinates[1] = int64((hash/MAP_WIDTH)%MAP_HEIGHT - MAP_HEIGHT/2);
        _radius = int64((hash/MAP_WIDTH/MAP_HEIGHT)%o + o);

        return(_coordinates,_radius, keccak256(abi.encodePacked(_coordinates,_radius)));
    }

    function checkVulnerable(uint _tokenId, bytes32 _lastImpact) internal view returns(bool){

        (int64[2] memory _coordinates, int64 _radius, bytes32 _impactId) = currentImpact();

        if(_lastImpact == encodeImpact(_impactId)) return false;

        uint16 _cityId = tokenToCity(_tokenId);

        int64 dx = coordinates[_cityId][0] - _coordinates[0];
        int64 dy = coordinates[_cityId][1] - _coordinates[1];

        return (dx**2 + dy**2 < _radius**2) ||
        ((dx + MAP_WIDTH )**2 + dy**2 < _radius**2) ||
        ((dx - MAP_WIDTH )**2 + dy**2 < _radius**2);
    }

    function isVulnerable(uint _tokenId) public  view returns(bool){


        (uint8 _reinforcement, uint8 _damage, bytes32 _lastImpact) = getStructuralData(_tokenId);
        _reinforcement;_damage;

        return checkVulnerable(_tokenId,_lastImpact);
    }


    function getFallen(uint _tokenId) public view returns(uint16 _cityId, address _owner){

        _cityId = tokenToCity(_tokenId);
        _owner = owners[_tokenId];
        require(cityToToken[_cityId] == 0 && _owner != address(0),"survives");
        return (_cityId,owners[_tokenId]);
    }

    function currentPrize() public view returns(uint){

        uint cityCount = tokenIndexToCity.length;
            return MINT_COST * cityCount * MINT_PERCENT_WINNER / 100
            - evacuatedFunds
            + reinforcements * REINFORCE_PERCENT_WINNER / 100;
    }

    function winnerPrize(uint _tokenId) public view returns(uint){

        return currentPrize() + getEvacuationRebate(_tokenId);
    }



    function isValidToken(uint256 _tokenId) internal view returns(bool){

        if(_tokenId == 0) return false;
        return cityToToken[tokenToCity(_tokenId)] != 0;
    }


    function balanceOf(address _owner) external override view returns (uint256){

        return balances[_owner];
    }

    function ownerOf(uint256 _tokenId) public override view returns(address){

        require(isValidToken(_tokenId),"invalid");
        return owners[_tokenId];
    }


    function approve(address _approved, uint256 _tokenId) external override {

        address _owner = ownerOf(_tokenId);
        require( _owner == msg.sender                    //Require Sender Owns Token
            || authorised[_owner][msg.sender]                //  or is approved for all.
        ,"permission");
        emit Approval(_owner, _approved, _tokenId);
        allowance[_tokenId] = _approved;
    }

    function getApproved(uint256 _tokenId) external override view returns (address) {

        require(isValidToken(_tokenId),"invalid");
        return allowance[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) external override view returns (bool) {

        return authorised[_owner][_operator];
    }


    function setApprovalForAll(address _operator, bool _approved) external override {

        emit ApprovalForAll(msg.sender,_operator, _approved);
        authorised[msg.sender][_operator] = _approved;
    }


    function transferFrom(address _from, address _to, uint256 _tokenId) public override {


        address _owner = ownerOf(_tokenId);

        require ( _owner == msg.sender             //Require sender owns token
        || allowance[_tokenId] == msg.sender      //or is approved for this token
            || authorised[_owner][msg.sender]          //or is approved for all
        ,"permission");
        require(_owner == _from,"owner");
        require(_to != address(0),"zero");

        require(!isVulnerable(_tokenId),"vulnerable");

        emit Transfer(_from, _to, _tokenId);


        owners[_tokenId] =_to;

        balances[_from]--;
        balances[_to]++;

        if(allowance[_tokenId] != address(0)){
            delete allowance[_tokenId];
        }

    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) public override {

        transferFrom(_from, _to, _tokenId);

        uint32 size;
        assembly {
            size := extcodesize(_to)
        }
        if(size > 0){
            IERC721TokenReceiver receiver = IERC721TokenReceiver(_to);
            require(receiver.onERC721Received(msg.sender,_from,_tokenId,data) == bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")),"receiver");
        }

    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external override {

        safeTransferFrom(_from,_to,_tokenId,"");
    }


    function tokenURI(uint256 _tokenId) public override view returns (string memory){

        require(isValidToken(_tokenId),'tokenId');

        uint _cityId = tokenToCity(_tokenId);

        uint _i = _cityId;
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }



        return string(abi.encodePacked(__uriBase,bstr,__uriSuffix));


    }



    function name() external override view returns (string memory _name){

        return __name;
    }

    function symbol() external override view returns (string memory _symbol){

        return __symbol;
    }


    function totalSupply() public view returns (uint256){

        return tokenIndexToCity.length - destroyed;
    }

    mapping (bytes4 => bool) internal supportedInterfaces;
    function supportsInterface(bytes4 interfaceID) external override view returns (bool){

        return supportedInterfaces[interfaceID];
    }


    function setOwner(address newOwner) public{

        require(msg.sender == owner,"owner");
        owner = newOwner;
    }
    function setUriComponents(string calldata _newBase, string calldata _newSuffix) public{

        require(msg.sender == owner,"owner");

        __uriBase   = bytes(_newBase);
        __uriSuffix = bytes(_newSuffix);
    }
}//A hedgehog wrote this contract
pragma solidity ^0.8.0;

contract DoomsdayViewer{


    Doomsday doomsday;

    uint constant IMPACT_BLOCK_INTERVAL = 120;

    constructor(address _doomsday){
        doomsday = Doomsday(_doomsday);
    }

    function isEarlyAccess() public view returns(bool){

        return doomsday.stage() == Doomsday.Stage.PreApocalypse && block.timestamp < doomsday.startTime() + 1 days;
    }

    function nextImpactIn() public view returns(uint){

        uint nextEliminationBlock = block.number - (block.number % IMPACT_BLOCK_INTERVAL) - 5 + IMPACT_BLOCK_INTERVAL;
        return nextEliminationBlock - block.number;
    }


    function contractState() public view returns(
            uint totalSupply,
            uint destroyed,
            uint evacuatedFunds,
            Doomsday.Stage stage,
            uint currentPrize,
            bool _isEarlyAccess,
            uint countdown,
            uint _nextImpactIn,
            uint blockNumber
    ){

        stage = doomsday.stage();

        _isEarlyAccess = isEarlyAccess();

        if(_isEarlyAccess){
            countdown = doomsday.startTime() + 1 days - block.timestamp;
        }else if(stage == Doomsday.Stage.PreApocalypse){
            countdown = doomsday.startTime() + 7 days - block.timestamp;
        }

        return (
            doomsday.totalSupply(),
            doomsday.destroyed(),
            doomsday.evacuatedFunds(),
            stage,
            doomsday.currentPrize(),
            _isEarlyAccess,
            countdown,
            nextImpactIn(),
            block.number
        );
    }

    function vulnerableCities(uint startId, uint limit)  public view returns(uint[] memory){

        uint _totalSupply = doomsday.totalSupply();
        uint _maxId = _totalSupply + doomsday.destroyed();
        if(_totalSupply == 0){
            uint[] memory _none;
            return _none;
        }
        require(startId < _maxId + 1,"Invalid start ID");
        uint sampleSize = _maxId - startId;

        if(limit != 0 && sampleSize > limit){
            sampleSize = limit;
        }
        uint[] memory _tokenIds = new uint256[](sampleSize);
        uint _tokenId = startId;
        for(uint i = 0; i < sampleSize; i++){
            try doomsday.ownerOf(_tokenId) returns (address _owner) {
                _owner;
                try doomsday.isVulnerable(_tokenId) returns (bool _isVulnerable) {
                    if(_isVulnerable){
                        _tokenIds[i] = _tokenId;
                    }
                } catch {

                }
            } catch {

            }
            _tokenId++;
        }
        return _tokenIds;
    }

    function cityData(uint startId, uint limit) public view returns(uint[] memory _tokenIds, uint[] memory _cityIds, uint[] memory _reinforcement, uint[] memory _damage, uint blockNumber ){

        uint _totalSupply = doomsday.totalSupply();
        uint _maxId = _totalSupply + doomsday.destroyed();
        if(_totalSupply == 0){
            uint[] memory _none;
            return (_none,_none,_none,_none, block.number);
        }
        require(startId < _maxId + 1,"Invalid start ID");
        uint sampleSize = _maxId - startId + 1;

        if(limit != 0 && sampleSize > limit){
            sampleSize = limit;
        }

        _tokenIds     = new uint256[](sampleSize);
        _cityIds      = new uint256[](sampleSize);
        _reinforcement = new uint256[](sampleSize);
        _damage        = new uint256[](sampleSize);


        uint _tokenId = startId;
        uint8 reinforcement; uint8 damage; bytes32 lastImpact;

        for(uint i = 0; i < sampleSize; i++){
            try doomsday.ownerOf(_tokenId) returns (address owner) {
                owner;
                _tokenIds[i] = _tokenId;

                (reinforcement, damage, lastImpact) = doomsday.getStructuralData(_tokenId);

                _cityIds[i]         = doomsday.tokenToCity(_tokenId);
                _reinforcement[i]    = reinforcement;
                _damage[i]           = damage;

            } catch {

            }
            _tokenId++;
        }
        return (_tokenIds, _cityIds, _reinforcement, _damage, block.number);
    }

    function cities(uint startId, uint limit)  public view returns(uint[] memory){

        uint _totalSupply = doomsday.totalSupply();
        uint _maxId = _totalSupply + doomsday.destroyed();
        if(_totalSupply == 0){
            uint[] memory _none;
            return _none;
        }
        require(startId < _maxId + 1,"Invalid start ID");
        uint sampleSize = _maxId - startId + 1;

        if(limit != 0 && sampleSize > limit){
            sampleSize = limit;
        }
        uint[] memory _tokenIds = new uint256[](sampleSize);
        uint _tokenId = startId;
        for(uint i = 0; i < sampleSize; i++){
            try doomsday.ownerOf(_tokenId) returns (address owner) {
                owner;
                _tokenIds[i] = _tokenId;
            } catch {

            }
            _tokenId++;
        }
        return _tokenIds;
    }

    function bunker(uint16 _cityId) public view returns(uint _tokenId, address _owner, uint8 _reinforcement, uint8 _damage, bool _isVulnerable, bool _isUninhabited){

        _tokenId = doomsday.cityToToken(_cityId);
        _isUninhabited = doomsday.isUninhabited(_cityId);

        if(_tokenId == 0){
            return (0,address(0),uint8(0),uint8(0),false,_isUninhabited);
        }else{
            try doomsday.ownerOf(_tokenId) returns ( address __owner) {
                _owner = __owner;
            } catch {

            }
            bytes32 _lastImpact;
            (_reinforcement, _damage, _lastImpact) = doomsday.getStructuralData(_tokenId);
            _isVulnerable = doomsday.isVulnerable(_tokenId);

            return (_tokenId,_owner,_reinforcement, _damage,_isVulnerable,false);
        }
    }

    function myCities(uint startId, uint limit)  public view returns(uint[] memory){

        uint _totalSupply = doomsday.totalSupply();
        uint _myBalance = doomsday.balanceOf(msg.sender);
        uint _maxId = _totalSupply + doomsday.destroyed();
        if(_totalSupply == 0 || _myBalance == 0){
            uint[] memory _none;
            return _none;
        }
        require(startId < _maxId + 1,"Invalid start ID");
        uint sampleSize = _maxId - startId + 1;

        if(limit != 0 && sampleSize > limit){
            sampleSize = limit;
        }

        uint[] memory _tokenIds = new uint256[](sampleSize);

        uint _tokenId = startId;
        uint found = 0;
        for(uint i = 0; i < sampleSize; i++){
            try doomsday.ownerOf(_tokenId) returns (address owner) {
                if(msg.sender == owner){
                    _tokenIds[found++] = _tokenId;
                }
            } catch {

            }
            _tokenId++;
        }
        return _tokenIds;
    }
}


