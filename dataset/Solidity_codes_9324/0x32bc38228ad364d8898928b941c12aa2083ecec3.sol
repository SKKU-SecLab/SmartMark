
pragma solidity ^0.8.9;

contract Pngn{

    address owner;
    struct Player{
        address payable addr;
        uint last_action_time;
        uint last_action_type;
        bytes32 hash;
        uint num;
    }
    
    Player[8] players;
    uint emptyseati = 9;
    uint256 public withdrawableAmmount;
    modifier onlyOwner() {

        require(msg.sender == owner); //dev: You are not the owner
        _;
    }

    modifier onlyWhenValueOk() {

        require(msg.value == 0.2 ether); //dev: 0.2 ether only
        _;
    }
    
    

    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        withdrawableAmmount = 0;
    }

    function sit() external {

        bool isNewPlayer = true;
        for(uint i=0;i<8;i++){
            if(players[i].addr == msg.sender){
                isNewPlayer = false;
                break;
            }
        }
        require(isNewPlayer==true); //dev: You are already playing
        cleanup_players();
        require(emptyseati != 9); //dev: There are no free seats
        players[emptyseati].addr = payable(msg.sender);
        players[emptyseati].last_action_time = block.timestamp;
        players[emptyseati].last_action_type = 1;
        uint opponenti;
        if((emptyseati % 2) == 0){
            opponenti = emptyseati +1;
        }
        else{
            opponenti = emptyseati -1;
        }
        if(players[opponenti].addr != address(0)){
            players[opponenti].last_action_time = block.timestamp - 1;
        }
    }

    function pick(uint i, bytes32 _hash) external payable onlyWhenValueOk {        

        require(i>=0 && i<8); //dev: Bad index
        require(players[i].addr == msg.sender); //dev: You do not exist there
        require(players[i].last_action_type == 1); //dev: You must be sitted to pick
        uint opponenti;
        if(i%2 == 0){
            opponenti = i+1;
        }
        else{
            opponenti = i-1;
        }
        require(players[opponenti].addr != address(0)); //dev: No opponent
        players[i].last_action_type = 2;
        players[i].last_action_time = block.timestamp;
        players[i].hash = _hash;
        players[i].num = 0;
        players[opponenti].last_action_time = block.timestamp - 1;
    }

    function getPlayers() external view returns(Player[8] memory rp){

        return players; 
    }

    
    function reveal(uint i, uint8 _pickednum, bytes32 _rand) external {

        require(i>=0 && i<8); //dev: Bad index
        require(players[i].addr == msg.sender); //dev: You do not exist there
        require(_pickednum == 1 || _pickednum == 2); //dev: Invalid picked num
        uint opponenti;
        if(i%2 == 0){
            opponenti = i+1;
        }
        else{
            opponenti = i-1;
        }
        require(players[i].last_action_type == 2 ); //dev: You must be picked to reveal
        require(players[opponenti].last_action_type > 1); //dev: Your opponent must be more than sitting
        require(keccak256(abi.encodePacked(_pickednum,_rand))==players[i].hash); //dev: Your data failed verification
        uint winneri = 9;
        if(players[opponenti].last_action_type == 2){
            players[i].last_action_type = 3;
            players[i].last_action_time = block.timestamp;
            players[i].num = _pickednum;
            players[opponenti].last_action_time = block.timestamp - 1; //refresh him too
        }
        else {
            if( _pickednum == players[opponenti].num){
                winneri = i;
                players[i].num = _pickednum + 4;//He found it
                players[opponenti].num = players[opponenti].num + 2;//He was guessed
            }
            else{
                winneri = opponenti; 
                players[i].num = _pickednum + 6;//He did not find it
            }

            players[i].last_action_type = 1;
            players[i].last_action_time = block.timestamp;
            players[i].hash = 0;
            players[opponenti].last_action_type = 1;
            players[opponenti].last_action_time = block.timestamp - 1;
            players[opponenti].hash = 0;
        }
        if(winneri != 9){
            address payable winner = players[winneri].addr;
            withdrawableAmmount += 0.01 ether;
            winner.transfer(0.39 ether);
        }
    }

    function refundAndLeave(uint i) external {

        bool canDo = false;
        if(i>=0 && i<8){
            if(players[i].addr == msg.sender){
                uint opponenti;
                if(i%2 == 0){
                    opponenti = i+1;
                }
                else{
                    opponenti = i-1;
                }
                if(players[i].last_action_type == 2 && players[opponenti].last_action_type < 2){
                    canDo = true;
                }
            }
        }
        require(canDo == true);//dev: Conditions insufficient
        delete players[i];
        cleanup_players();
        payable(msg.sender).transfer(0.2 ether);
    }

    function kickAndWin(uint i) external {

        bool canDo = false;
        uint opponenti;
        if(i>=0 && i<8){
            if(players[i].addr == msg.sender){
                if(i%2 == 0){
                    opponenti = i+1;
                }
                else{
                    opponenti = i-1;
                }
                if(players[i].last_action_type == 3 && players[opponenti].last_action_type == 2 && (block.timestamp - players[opponenti].last_action_time ) > 15 minutes){
                    canDo = true;
                }
            }
        }
        require(canDo == true);//dev: Conditions insufficient
        delete players[opponenti];
        players[i].last_action_type = 1;
        players[i].last_action_time = block.timestamp;
        players[i].hash = 0;
        players[i].num = 9;
        withdrawableAmmount += 0.01 ether;
        cleanup_players();
        payable(msg.sender).transfer(0.39 ether);
    }

    function cleanup_players() private {

        emptyseati = 9;
        uint priority_emptyseati = 9;
        for(uint i=0;i<8;i=i+2){
            if(players[i].addr != address(0) && players[i+1].addr != address(0)){
                if(((block.timestamp - players[i].last_action_time) > 15 minutes) && players[i].last_action_type == 2 && players[i+1].last_action_type == 3){
                    delete players[i];
                    if(priority_emptyseati == 9) priority_emptyseati=i;
                    players[i+1].last_action_type = 1;
                    players[i+1].last_action_time = block.timestamp;
                    players[i+1].hash = 0;
                    players[i+1].num = 9;
                    withdrawableAmmount += 0.01 ether;
                    address payable winner_bylaterevealer = players[i+1].addr;
                    winner_bylaterevealer.transfer(0.39 ether);
                }
                else if(((block.timestamp - players[i+1].last_action_time) > 15 minutes) && players[i+1].last_action_type == 2 && players[i].last_action_type == 3){
                    delete players[i+1];
                    if(priority_emptyseati == 9) priority_emptyseati=i+1;
                    players[i].last_action_type = 1;
                    players[i].last_action_time = block.timestamp;
                    players[i].hash = 0;
                    players[i].num = 9;
                    withdrawableAmmount += 0.01 ether;
                    address payable winner_bylaterevealer = players[i].addr;
                    winner_bylaterevealer.transfer(0.39 ether);
                }
                else if(((block.timestamp - players[i].last_action_time) > 15 minutes) && (block.timestamp - players[i+1].last_action_time) > 15 minutes && players[i].last_action_type == 2 && players[i+1].last_action_type == 2){
                    uint who=9;
                    if(players[i].last_action_time > players[i+1].last_action_time){
                        who = i;
                    }
                    else if(players[i+1].last_action_time > players[i].last_action_time){
                        who = i+1;
                    }
                    else{
                        who = i;
                    }
                    if(who != 9){
                        address payable winner = players[who].addr;
                        delete players[i];
                        delete players[i+1];
                        if(emptyseati == 9) emptyseati=i;
                        withdrawableAmmount += 0.01 ether;
                        winner.transfer(0.39 ether);
                    }
                }
            }
            for(uint j=0;j<2;j++){
                if(players[i+j].addr != address(0) && (block.timestamp - players[i+j].last_action_time) > 15 minutes && players[i+j].last_action_type == 1){
                    delete players[i+j];
                    if(priority_emptyseati == 9) priority_emptyseati = i + j;
                }
                else if(players[i+j].addr == address(0)){
                    if(emptyseati == 9) emptyseati=i+j;
                }
            }
        }
        if(priority_emptyseati != 9){
          emptyseati = priority_emptyseati;
        }
    }

    function withdraw() external onlyOwner {

        payable(msg.sender).transfer(withdrawableAmmount);
        withdrawableAmmount = 0;
    }
}