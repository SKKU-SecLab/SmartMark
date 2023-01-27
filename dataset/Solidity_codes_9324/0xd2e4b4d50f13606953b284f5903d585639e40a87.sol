
pragma solidity >=0.7.0;


library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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
    assert(c >= a);
    return c;
  }
}

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}

contract Ownable {

  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  constructor()  {
    owner = msg.sender;
  }


  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

}


interface Token {

    function transfer(address, uint) external returns (bool);

    function balanceOf(address _owner) external returns (uint256 balance) ;

}

contract DFSocial_Game1 is Ownable {

    using SafeMath for uint;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    
    event joined( address dir, uint level);
    event refCodeUsed( string code);
    event eventStarted();
    event RewardTransferred( address dir, uint amount);
    
    
    address private constant tokenAddress = 0x54ee01beB60E745329E6a8711Ad2D6cb213e38d7;  
    
    uint public TOTAL_REWARD ;
    uint public amountToPlay ;
    uint public timeToJoin ; 
    uint public timeToFinish ; 
    uint public maxPlayers ; 
    uint public amountToBonus;
    uint public bonusInLevels;
    
    EnumerableSet.AddressSet private gamers;
    uint public totalDiff;
    bool public started;
    uint public startTime;
    
    
    mapping (address => uint) public levelStart;
    mapping (address => uint) public levelEnd;
    mapping (address => uint) public diff;
    mapping (address => uint) public share;
    mapping (address => uint) public reward;
    mapping (address => bool) public bonus;
    
    
    mapping (address => string) public names;
    mapping (address => uint) public position;
    mapping (address => string) public region; 
    mapping (address => string) public ref;
             
    function startEvent(uint _total_reward, uint _amountToPlay, uint _timeToJoin, uint _timeToFinish, uint _maxPlayers, uint _amountToBonus, uint _bonusInLevels) public onlyOwner{ 

        require(!started );
        while(gamers.length() >0 ){
            address actual = gamers.at(0);
            gamers.remove(actual);
            levelStart[actual] = 0;
            levelEnd[actual] = 0;
            diff[actual] = 0;
            share[actual] = 0;
            reward[actual] = 0;
            names[actual] = "";
            region[actual] = "";
            position[actual] = 0;
            bonus[actual] = false;
            ref[actual] = "";
            
            
            
        }
        totalDiff = 0;
        started = true;
        startTime = block.timestamp;
        
        TOTAL_REWARD = _total_reward;
        amountToPlay = _amountToPlay;
        timeToJoin = _timeToJoin;
        timeToFinish = _timeToFinish;
        maxPlayers = _maxPlayers;
        amountToBonus  = _amountToBonus;
        bonusInLevels = _bonusInLevels;
        
        emit eventStarted();
    }     

    function timeToFinishJoins() public view returns (uint){

        
        uint returnTime;
        
        if(startTime == 0 ){
            returnTime = 0;
        }else{
            returnTime = startTime.add(timeToJoin);
        }
        
       
        return returnTime;
    }
    
    function timeToFinishGame() public view returns (uint){

        
        uint returnTime;
        
        if(startTime == 0 ){
            returnTime = 0;
        }else{
            returnTime = startTime.add(timeToFinish);
        }
        
       
        return returnTime;
    }
        
    function join(string memory _name,  uint _levelStart, string memory _region) public{

        require(block.timestamp.sub(startTime) < timeToJoin, "Joins deadline finished");
        require(!gamers.contains(msg.sender), "You are already playing");
        require(gamers.length() < maxPlayers, "Max players reached");
        
        uint amount = Token(tokenAddress).balanceOf(msg.sender);
        require(amount >= amountToPlay, "Not enought DFSocial");
        if(amount >= amountToBonus){
            bonus[msg.sender] = true;
        }
        
        gamers.add(msg.sender);
        names[msg.sender] = _name;
        levelStart[msg.sender] = _levelStart;
        region[msg.sender] = _region;
        ref[msg.sender] = "";
        emit joined(msg.sender, _levelStart);
    }
    
    function joinWithRef(string memory _name,  uint _levelStart, string memory _region, string memory _ref) public{

        require(block.timestamp.sub(startTime) < timeToJoin, "Joins deadline finished");
        require(!gamers.contains(msg.sender), "You are already playing");
        require(gamers.length() < maxPlayers, "Max players reached");
        
        uint amount = Token(tokenAddress).balanceOf(msg.sender);
        require(amount >= amountToPlay, "Not enought DFSocial");
        if(amount >= amountToBonus){
            bonus[msg.sender] = true;
        }
        
        gamers.add(msg.sender);
        names[msg.sender] = _name;
        levelStart[msg.sender] = _levelStart;
        region[msg.sender] = _region;
        ref[msg.sender] = _ref;
        emit joined(msg.sender, _levelStart);
        emit refCodeUsed(_ref);
    }
    
    
    function setlevelEnd(uint _levelEnd) public    {

        require(gamers.contains(msg.sender), "You're not playing");
        require(block.timestamp.sub(startTime) > timeToJoin, "Not yet"); 
        require(block.timestamp.sub(startTime) < timeToFinish, "Event finished");
        
        uint amount = Token(tokenAddress).balanceOf(msg.sender);
        require(amount >= amountToPlay, "Not enought DFSocial");
        if(amount >= amountToBonus && bonus[msg.sender] == true){
            levelEnd[msg.sender] = _levelEnd.add(bonusInLevels);
        }else{
            bonus[msg.sender] = false;
            levelEnd[msg.sender] = _levelEnd;   
        }
        
        
        
    }
    
    function end() public onlyOwner    {

        require(started, "Game didn't start! ");
        require(block.timestamp.sub(startTime) > timeToFinish, "Not yet");
        started = false;
        
        address actual;
        for(uint i = 0; i < gamers.length() ; i = i.add(1)){
            actual = gamers.at(i);
            if(levelEnd[actual] > levelStart[actual]){
                diff[actual] = levelEnd[actual].sub(levelStart[actual]);
                totalDiff=totalDiff.add(diff[actual]);
            }else{
                diff[actual] = 0;
            }
           
        }
        for(uint j = 0; j < gamers.length() ; j = j.add(1)){
            actual = gamers.at(j);
            share[actual] = diff[actual].mul(1e20).div(totalDiff);  // % * 1e18
            reward[actual] = TOTAL_REWARD.mul(share[actual]).div(1e20);
        }
        
        address[] memory jugadores = new address[](gamers.length()) ;
        
        uint nivelMaximo = 0;
        uint indice = 0;
        uint l;
        uint posicion = 1;
        
        
        for(uint k = 0; k< gamers.length(); k = k.add(1)){
            jugadores[k] = gamers.at(k);
        }
        uint aux = gamers.length();
        while(aux > 0){
            nivelMaximo = 0;
            indice = 0;
            for( l = 0; l< aux; l = l.add(1)){
                
                if(diff[jugadores[l]] > nivelMaximo){
                    nivelMaximo = diff[jugadores[l]];
                    indice = l;
                }
                
            }
            
           
            position[jugadores[indice]]=posicion;
            posicion = posicion.add(1);
            
            jugadores[indice] = jugadores[aux - 1];
            aux=aux.sub(1);
        }
        
        
    }
    
    function claim() public{

        require(gamers.contains(msg.sender), "You're not playing");
        require(reward[msg.sender] > 0, "Nothing to claim");
        if(bonus[msg.sender]){
            require(Token(tokenAddress).balanceOf(msg.sender) >= amountToBonus, "Not enought DFSocial (5)");
        }else{
            require(Token(tokenAddress).balanceOf(msg.sender) >= amountToPlay, "Not enought DFSocial (1)");
        }
        
        
        uint _rew = reward[msg.sender];
        reward[msg.sender] = 0;
        require(Token(tokenAddress).transfer(msg.sender, _rew), "Could not transfer tokens.");
        emit RewardTransferred (msg.sender, _rew);
        
    }
    
    function getIsGamer(address dir) public view returns (bool){

        return gamers.contains(dir);
    }
    
    function getName(address player) public view returns (string memory )  {

        return names[player];
    }
    
    function aaGetInfo(address player) public view returns (string memory, string memory )  {

        return (names[player], region[player]);
    }

    function getlevelStart() public view returns (uint)  {

        return levelStart[msg.sender];
    }
    
    function getlevelEnd() public view returns (uint)  {

        return levelEnd[msg.sender];
    }
    
    function getNumGamers() public view returns (uint){

        return gamers.length();
    }
    function getStakersList() 
        public 
        view
        onlyOwner
        returns (address[] memory,
                 uint[] memory,
                 uint[] memory) {

        
        uint length = gamers.length();
        address[] memory _players = new address[](length);
        uint[] memory niveles = new uint[](length);
        uint[] memory nivelesFin = new uint[](length);
        
        for (uint i = 0; i < length; i = i.add(1)) {
            address gamer = gamers.at(i);
            _players[i] = gamer;
            niveles[i] = levelStart[gamer];
            nivelesFin[i] = levelEnd[gamer];
            
        }
        
        return (_players, niveles, nivelesFin);
    }
    
    
    function deletePlayer(address _player) public onlyOwner{

        require(gamers.contains(_player));
        gamers.remove(_player);
        
        
        levelStart[_player] = 0;
        levelEnd[_player] = 0;
        diff[_player] = 0;
        share[_player] = 0;
        reward[_player] = 0;
        names[_player] = "";
        region[_player] = "";
        position[_player] = 0;
        bonus[_player] = false;
        ref[_player] = "";
        
        
    }
    
    function deletePlayers (address[] memory _players) public onlyOwner{
        for(uint i=0; i < _players.length; i=i.add(1)){
            if(gamers.contains(_players[i])){
                gamers.remove(_players[i]);
                
                levelStart[_players[i]] = 0;
                levelEnd[_players[i]] = 0;
                diff[_players[i]] = 0;
                share[_players[i]] = 0;
                reward[_players[i]] = 0;
                names[_players[i]] = "";
                region[_players[i]] = "";
                position[_players[i]] = 0;
                bonus[_players[i]] = false;
                ref[_players[i]] = "";
            }
        }
    }
    
    function getGamer(uint pos) public view returns (address){

        return gamers.at(pos);
    }
    
}