







pragma solidity ^0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}



pragma solidity ^0.6.0;

contract ReentrancyGuard {


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}



pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;








interface HTK_Token {

    function balanceOf(address owner) external returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool); //token transfer function 

    function decimals() external returns (uint256);

    function withdrawFunds() external;

    function distributeFunds() external payable returns (bool);

}


contract HonestTreeGame is ReentrancyGuard, Ownable{

    
    using SafeMath for uint256;
    
    
    
    
    address payable public root_node; //Honest Token (HTK) contract address
    HTK_Token public HTK_tokenContract; // The same! But now as an HTK_Token Contract Interface Object. 
    
    
    
    uint256 public participation_fee;
    uint256 public early_bird_participation_fee;
    uint256 public premium_fee;
    mapping(string => address) private aliases;
    uint private DAY_IN_SECONDS;
    uint public contract_creation_date;
    uint public last_participation_date;
    uint public early_bird_deadline;
    bool public early_bird;
    uint public guarantee_period;
    uint public root_node_withdraw_frecuency;
    
    
    uint256 public first_level_up_reward;
    uint256 public second_level_up_reward;
    uint256 public third_level_up_reward;
    uint256 public fourth_level_up_reward;
    
    uint256 public first_level_up_reward_percentage;
    uint256 public second_level_up_reward_percentage;
    uint256 public third_level_up_reward_percentage;
    uint256 public fourth_level_up_reward_percentage;
    
    
    
    uint256 public sum_all_time_players;
    uint256 public confirmed_count; // Helps to give free HTK to the first 100 confirmed players
    uint256 public abort_count;
    uint256 public sum_total_investment;
    
    uint256 public sum_premium_fees;
    uint256 public root_node_premium_fees_already_withdrawn;
    uint public last_root_node_withdraw_date;

    enum PlayerStatus {NOT_YET, PARTICIPATING, CONFIRMED, ABORTED}
    struct Player {
         address first_level_parent_node;
         address second_level_parent_node;
         address third_level_parent_node;
         
         uint256 sign_up_date; 
         uint256 sign_up_epoch_time; 
         
         address[] first_level_down_players;
         address[] second_level_down_players;
         address[] third_level_down_players;
         address[] fourth_level_down_players;
         
         
         uint256 third_level_down_rewards_if_premium; 
         
         mapping(uint256 => uint256) confirmed_rewards_per_date; 
         
         uint256[] interaction_dates;
         
         PlayerStatus status;
         
         uint256 total_withdrawn;
         
         string[] my_aliases;
         
         bool is_premium;
         
         bool is_early_bird;
        
    }
    
    mapping(address => Player) public players;
    
    
    
    event newPlayer(address player_address, string referal);
    event repentant( address player_address);

    constructor(HTK_Token _HTK_tokenContract, address payable _HTK_tokenContract_address) public{
        
        root_node=_HTK_tokenContract_address;
        HTK_tokenContract=_HTK_tokenContract;
        
        early_bird_participation_fee=40 finney; // 0.04 during Early Bird
        participation_fee=70 finney;       //  0.07 after Early Bird
        
        
        early_bird_deadline=1596239999;
        
        guarantee_period=2; // 48 hours guarantee period (2-day)
        
        
        root_node_withdraw_frecuency=15; 
        
        
        early_bird=true;
        
        first_level_up_reward_percentage=40;
        second_level_up_reward_percentage=25;
        third_level_up_reward_percentage=15;
        fourth_level_up_reward_percentage=20; // To Honest Token's Holders
        
        first_level_up_reward=early_bird_participation_fee*first_level_up_reward_percentage/100;   //  0.016  ETH = 40% to first level IN EARLY BIRD
        second_level_up_reward=early_bird_participation_fee*second_level_up_reward_percentage/100;  //  0.01 ETH = 25% to second level IN EARLY BIRD
        third_level_up_reward=early_bird_participation_fee*third_level_up_reward_percentage/100;   //  0.006 ETH = 15% to third level IN EARLY BIRD
        fourth_level_up_reward=early_bird_participation_fee*fourth_level_up_reward_percentage/100;  //  0.008 ETH = 20% to HTK token holders IN EARLY BIRD
        
        sum_premium_fees=0;
        premium_fee=600 finney; //0.6 ETH to be premium
        
        sum_all_time_players=0;
        confirmed_count=0;
        abort_count=0;
        last_participation_date=now;
        last_root_node_withdraw_date=now;
        
        DAY_IN_SECONDS=86400;
        contract_creation_date=now;
        
        players[root_node].first_level_parent_node=root_node;
        players[root_node].second_level_parent_node=root_node;
        players[root_node].third_level_parent_node=root_node;
        players[root_node].sign_up_date=0; // date in days since creation
        players[root_node].sign_up_epoch_time=now;
        string memory _my_alias=addressToAlias(root_node);
        aliases[_my_alias]=root_node;
        players[root_node].my_aliases.push(_my_alias);
        
        players[root_node].status=PlayerStatus.CONFIRMED;
        players[root_node].is_premium=true;
        players[msg.sender].is_premium=true;
        players[root_node].total_withdrawn=0;
        players[root_node].is_early_bird=true;
        
    }
    
    function addressToAlias(address _addr) private view returns(string memory) {

        bytes32 value = bytes32(uint256(_addr));
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(8); // we thinkg that 8 lenght aliases are long enough
        
        bool _alias_exists=true;
        string memory _my_alias;
        uint j=0;
        
        
        while (_alias_exists){ //While this alias already existsl, tries to find anotherone
            for (uint i = 0; i < 4; i++) {
                str[i*2] = alphabet[uint(uint8(value[i + 28 - j] >> 4))];
                str[1+i*2] = alphabet[uint(uint8(value[i + 28 - j] & 0x0f))];
            }
            _my_alias=string(str);
            j+=1;
            _alias_exists=!isTeamNameAvailable(_my_alias);
            require(j<4,'You should use another address!, we dont want to consume all your gas');
        }
        return _my_alias;
    }
    
    function isTeamNameAvailable(string memory _new_team_name) public view returns (bool){

        return (aliases[_new_team_name]==address(0x0));
    }
    
    
    modifier correctParticipationFee() { 

        if(early_bird){
        require(msg.value >= early_bird_participation_fee,'Please send at least 0.04 ETH'); _; }
        else {
        require(msg.value >= participation_fee,'Please send at least 0.06 ETH'); _; }        

    }
    
    modifier notParticipant(){require(players[msg.sender].status!=PlayerStatus.PARTICIPATING,'You are already participating'); _;}

    modifier notConfirmed(){require(players[msg.sender].status!=PlayerStatus.CONFIRMED,'You are already a confirmed player'); _;}

    
    fallback() external payable {
        participateWithReferal('root_node');
    }
    
    receive() external payable {
        participateWithReferal('root_node');
    }

    function participateWithReferal(string memory _my_referal_alias)
        nonReentrant
        correctParticipationFee
        notParticipant // We don't allow double registration.
        notConfirmed 
        public
        payable
        {

            last_participation_date=now;
            
            if(now>=early_bird_deadline){
                players[msg.sender].is_early_bird=false;
                sum_total_investment=sum_total_investment+participation_fee;
                
                
                if(early_bird==true) {
                    early_bird=false;
                    first_level_up_reward=participation_fee*first_level_up_reward_percentage/100;   //  0.028  ETH = 40% to first level
                    second_level_up_reward=participation_fee*second_level_up_reward_percentage/100;  //  0.0175 ETH = 25% to second level
                    third_level_up_reward=participation_fee*third_level_up_reward_percentage/100;   //  0.0105 ETH = 15% to third level
                    fourth_level_up_reward=participation_fee*fourth_level_up_reward_percentage/100;  //  0.014 ETH = 20% to HTK token holders
                    
                }
                
            }
            else{
                players[msg.sender].is_early_bird=true;
                sum_total_investment=sum_total_investment+early_bird_participation_fee;
            }
            
            address _my_referal_address;
            bool new_player;
            
            if (players[msg.sender].status==PlayerStatus.ABORTED){
                
                new_player=false;
                
                
                for (uint i=0; i<players[msg.sender].my_aliases.length;i++){
                    aliases[players[msg.sender].my_aliases[i]]=msg.sender;
                }
                
                
                
                players[msg.sender].status=PlayerStatus.CONFIRMED;
                
            }
            else {
                new_player=true;
                players[msg.sender].status=PlayerStatus.PARTICIPATING;  
                if (aliases[_my_referal_alias]==address(0x0)) { 
                    _my_referal_address=aliases['root_node'];
                }
                else{
                    _my_referal_address=aliases[_my_referal_alias];
                }
                
                
                string memory _my_alias=addressToAlias(msg.sender);
                players[msg.sender].my_aliases.push(_my_alias); 
                aliases[_my_alias]=msg.sender;
                
                players[msg.sender].first_level_parent_node=_my_referal_address;
                players[msg.sender].second_level_parent_node=
                    players[players[msg.sender].first_level_parent_node].first_level_parent_node;
                
                
                players[msg.sender].total_withdrawn=0;
            }
            
            
            address _third_level_parent_node=players[players[msg.sender].second_level_parent_node].first_level_parent_node;
            
            if (!players[_third_level_parent_node].is_premium) {
                if(new_player) {
                    players[_third_level_parent_node].third_level_down_rewards_if_premium+=third_level_up_reward;
                    
                }
                
                _third_level_parent_node=root_node;
            }
            
            players[msg.sender].third_level_parent_node=_third_level_parent_node;
                    
                
            
            
            uint256 _today = getParticipationDayToday();
            players[msg.sender].sign_up_date=_today;
            players[msg.sender].sign_up_epoch_time=now;
            
            if(new_player) {players[players[msg.sender].first_level_parent_node].first_level_down_players.push(msg.sender);}
            pushPlayerReward(players[msg.sender].first_level_parent_node,first_level_up_reward,_today);
            
            
            if(new_player) {players[players[msg.sender].second_level_parent_node].second_level_down_players.push(msg.sender);}
            pushPlayerReward(players[msg.sender].second_level_parent_node, second_level_up_reward,_today);
            

            if(new_player) {players[_third_level_parent_node].third_level_down_players.push(msg.sender);}
            pushPlayerReward(_third_level_parent_node, third_level_up_reward,_today);
            
            if(new_player) {players[root_node].fourth_level_down_players.push(msg.sender);}
            pushPlayerReward(root_node, fourth_level_up_reward,_today);
            
            if(new_player) {
                emit newPlayer(msg.sender, _my_referal_alias);
                sum_all_time_players=sum_all_time_players.add(1); }
            else { 
                emit repentant(msg.sender); 
                
            }
            
        }
    
    function getParticipationDayToday() public view returns (uint256) {

        return ((now.sub(contract_creation_date))/DAY_IN_SECONDS);
    }
    
    function pushPlayerReward(
        address _parent_node,
        uint256 _reward,
        uint256 _today) private {

            
            
            uint _interaction_dates_lenght=players[_parent_node].interaction_dates.length; //Help variable
            
            if(_interaction_dates_lenght==0) {
                
                players[_parent_node].interaction_dates.push(_today);
                players[_parent_node].confirmed_rewards_per_date[_today]=_reward;
            }
            else {
                
                if (players[_parent_node].interaction_dates[_interaction_dates_lenght.sub(1)]<_today) {
                    
                    players[_parent_node].interaction_dates.push(_today);
                    
                    players[_parent_node].confirmed_rewards_per_date[_today]=
                        players[_parent_node].confirmed_rewards_per_date[
                            players[_parent_node].interaction_dates[_interaction_dates_lenght.sub(1)] // previous registered day
                        ].add(_reward); // Sums the previous registered day acumulated reward, with the new player's reward
                        
                }
                else{
                    players[_parent_node].confirmed_rewards_per_date[_today]=
                        players[_parent_node].confirmed_rewards_per_date[_today].add(_reward);
                }
                
            }
            
        
    }
    
    modifier correctPremiumFee() { require(msg.value >= premium_fee,'Please send at least 1 ETH'); _; }

    
    function confirmMyParticipation()
        public
        activePlayer
        notAborted {

            require(players[msg.sender].status==PlayerStatus.PARTICIPATING);
            players[msg.sender].status=PlayerStatus.CONFIRMED;
            
            confirmed_count=confirmed_count.add(1); 
            if (confirmed_count<=100){
                if (HTK_tokenContract.balanceOf(address(this))>=(500*10**HTK_tokenContract.decimals()))
                {
                    HTK_tokenContract.transfer(msg.sender, (500*10**HTK_tokenContract.decimals())); 
                }
            }
        
        }
        
    
    function becomePremium()
        nonReentrant
        public
        activePlayer
        notAborted
        correctPremiumFee
        payable {

            last_participation_date=now;
            
            players[msg.sender].status=PlayerStatus.CONFIRMED;
            sum_premium_fees=sum_premium_fees.add(msg.value);
            sum_total_investment=sum_total_investment.add(msg.value);
            players[msg.sender].is_premium=true;
        }
        
    function sumbitNewTeamName(string memory _new_team_name)
        nonReentrant
        public
        activePlayer
        notAborted {

            require(isTeamNameAvailable(_new_team_name), "That team name is not available!" );
            require(players[msg.sender].my_aliases.length<5,"You have alreade created your 5 custom team name!");
            players[msg.sender].my_aliases.push(_new_team_name);
            aliases[_new_team_name]=msg.sender;
        }
    
    modifier notAborted() { 

        require(players[msg.sender].status!=PlayerStatus.ABORTED,
        'You already aborted your participation. Please join the game again :).'); _;}
        
    modifier activePlayer(){ require(

        (players[msg.sender].status==PlayerStatus.CONFIRMED || players[msg.sender].status==PlayerStatus.PARTICIPATING),
        'You are not an active player. Please join the game :).'); _;}
        
    function withdrawPlayer()
        nonReentrant
        public
        notAborted
        activePlayer{

            uint256 _amount=withdrawCalculation(msg.sender);
            (bool success, ) = msg.sender.call{value: _amount}("");
            require(success, "Transfer failed.");
            
            emit withdraw_event(msg.sender,_amount);
            
        }
        
    function withdrawRootNodeRevenues()
        nonReentrant
        public
    {

        
        
        
        
        require(now>last_root_node_withdraw_date,'Last root node withdraw was just now!');
        
        require((now-last_root_node_withdraw_date)>(root_node_withdraw_frecuency*DAY_IN_SECONDS),
            'Root node withdraws should be done with a minimum of 15 days difference');
        
        last_root_node_withdraw_date=now;
        
        uint256 _amount_participation_fees=withdrawCalculation(root_node);
        
        uint256 _amount_premium_fees=sum_premium_fees.sub(root_node_premium_fees_already_withdrawn);
        
        root_node_premium_fees_already_withdrawn=root_node_premium_fees_already_withdrawn.add(_amount_premium_fees);
        
        (bool success) = HTK_tokenContract.distributeFunds{value: _amount_participation_fees.add(_amount_premium_fees)}();
        require(success, "Transfer failed.");
            
        emit root_node_withdraw_event(_amount_participation_fees.add(_amount_premium_fees));    
        
        
    
    }
    
    event root_node_withdraw_event(uint256 _amount_windrawn);
    
    
    
    modifier isPlayerParticipating(address _player){

        require((players[_player].status==PlayerStatus.PARTICIPATING) || (players[_player].status==PlayerStatus.CONFIRMED),
                'Player is not participant');_;}
    
    function getPlayerConfirmedRewards(address _player) 
        public
        view
        returns (uint256) {

            uint256 _today = getParticipationDayToday();
            uint _interaction_dates_length=players[_player].interaction_dates.length;
            
            if((_today<=guarantee_period) || (_interaction_dates_length==0)) {
                return 0; // too early or no childs yet
            } 
            
            if(players[_player].interaction_dates[0].add(guarantee_period) >= _today){
                return 0; // no child is yet confirmed
            }
            
            
            for(uint t = 1; t < guarantee_period+3; t++)
            {
                if (t>_interaction_dates_length){
                    return 0; // This yould not happen at this time.
                }
                
                uint _my_interaction_day=players[_player].interaction_dates[_interaction_dates_length.sub(t)];
                if (_my_interaction_day<_today.sub(guarantee_period))
                {
                    return players[_player].confirmed_rewards_per_date[_my_interaction_day];
                    
                }
                
            }
        return 0;
    }
        
    
  
        
    function withdrawCalculation(address _player) private returns (uint256 _amount)
        {

            
            uint256 _confirmed_rewards=getPlayerConfirmedRewards(_player);
            
            require(_confirmed_rewards>0,'You have nothing to withdraw yet... Keep spamming!');
            require(_confirmed_rewards>players[_player].total_withdrawn,'You have already withdawn everything for the moment!');
            
            if (players[_player].status==PlayerStatus.PARTICIPATING){
                confirmMyParticipation();
            }
            
            _amount=_confirmed_rewards-players[_player].total_withdrawn;
            
            players[_player].total_withdrawn=
                players[_player].total_withdrawn.add(_amount);
            
            require(_confirmed_rewards==players[_player].total_withdrawn, "Reentrancy guard.");
            
            return(_amount);
            
    }
    
    event withdraw_event(address _player,uint256 _amount);
 

 
    function abort() 
        nonReentrant
        public
        notAborted
        activePlayer
        notConfirmed
        {

            players[msg.sender].status=PlayerStatus.ABORTED;
            abort_count=abort_count.add(1);
            
            uint256 _sign_up_date=players[msg.sender].sign_up_date;
            uint256 _today=getParticipationDayToday();
            
            require(_today>=_sign_up_date);
            require(_today.sub(_sign_up_date)<=guarantee_period,'Too many days have already passed. Too late! We are sorry!');
            
            uint256 _my_first_level_up_reward;
            uint256 _my_second_level_up_reward;
            uint256 _my_third_level_up_reward;
            uint256 _my_fourth_level_up_reward;
            uint256 _my_participation_fee;
            
            if(players[msg.sender].is_early_bird){
                _my_first_level_up_reward=early_bird_participation_fee*first_level_up_reward_percentage/100;
                _my_second_level_up_reward=early_bird_participation_fee*second_level_up_reward_percentage/100; 
                _my_third_level_up_reward=early_bird_participation_fee*third_level_up_reward_percentage/100;   
                _my_fourth_level_up_reward=early_bird_participation_fee*fourth_level_up_reward_percentage/100; 
                _my_participation_fee=early_bird_participation_fee;
            }
            else {
                _my_first_level_up_reward=participation_fee*first_level_up_reward_percentage/100;
                _my_second_level_up_reward=participation_fee*second_level_up_reward_percentage/100;  
                _my_third_level_up_reward=participation_fee*third_level_up_reward_percentage/100;   
                _my_fourth_level_up_reward=participation_fee*fourth_level_up_reward_percentage/100; 
                _my_participation_fee=participation_fee;
                
            }
            
            pullPlayerReward(players[msg.sender].first_level_parent_node, _my_first_level_up_reward, _sign_up_date);
            
            pullPlayerReward(players[msg.sender].second_level_parent_node, _my_second_level_up_reward, _sign_up_date);
            
            pullPlayerReward(players[msg.sender].third_level_parent_node, _my_third_level_up_reward, _sign_up_date);
            
            pullPlayerReward(root_node, _my_fourth_level_up_reward, _sign_up_date);
            
            
            
            for (uint i=0; i<players[msg.sender].my_aliases.length;i++){
                aliases[players[msg.sender].my_aliases[i]]=players[msg.sender].first_level_parent_node;
            }
            
            if(players[msg.sender].interaction_dates.length>0){
                transferMyRewardsAndChildsToRootNode(_today);
            }
            
            
            
            (bool success, ) = msg.sender.call{value:_my_participation_fee}("");
            require(success, "Refund transfer failed :( ");
            
            emit abort_event(msg.sender);
            
        }
    
    event abort_event(address _player);
    
    function pullPlayerReward(address _parent_node, uint256 _reward, uint _sign_up_date) private {

        
        uint _interaction_dates_lenght=players[_parent_node].interaction_dates.length;
        for (uint t=1; t<guarantee_period+3;t++){
            if(t>_interaction_dates_lenght){
                break;
            }
            
            uint _interaction_day=players[_parent_node].interaction_dates[_interaction_dates_lenght.sub(t)];
            
            if(_interaction_day>=_sign_up_date){
                players[_parent_node].confirmed_rewards_per_date[_interaction_day]=
                        players[_parent_node].confirmed_rewards_per_date[_interaction_day].sub(_reward);
            }
            else {
                break;
            }
            
        }
        return;
    }
    
    
    function transferMyRewardsAndChildsToRootNode(uint256 _today) private {

        
        if (players[msg.sender].first_level_down_players.length>0){
            for(uint i=0;i<players[msg.sender].first_level_down_players.length;i++){
                players[players[msg.sender].first_level_down_players[i]].first_level_parent_node=root_node;
                players[msg.sender].first_level_down_players[i]=address(0x0);
            }
        }
        
        if (players[msg.sender].second_level_down_players.length>0){
            for(uint i=0;i<players[msg.sender].second_level_down_players.length;i++){
                players[players[msg.sender].second_level_down_players[i]].second_level_parent_node=root_node;
                players[msg.sender].second_level_down_players[i]=address(0x0);
            }
        }
        
        
        uint _my_interaction_dates_length=players[msg.sender].interaction_dates.length;
        
        
        uint _my_last_day=players[msg.sender].interaction_dates[_my_interaction_dates_length.sub(1)];
        uint _reward_to_transfer=players[msg.sender].confirmed_rewards_per_date[_my_last_day];
        
        players[msg.sender].confirmed_rewards_per_date[_my_last_day]=0;
        
        for (uint j=_my_last_day;j<=_today;j++){
            if(players[root_node].confirmed_rewards_per_date[j]>0){    
                players[root_node].confirmed_rewards_per_date[j]=
                    players[root_node].confirmed_rewards_per_date[j].add(_reward_to_transfer);
            }
        }
        
        if(_my_interaction_dates_length>1){
            for (uint i=0;i<_my_interaction_dates_length.sub(2);i++){
                _my_last_day=players[msg.sender].interaction_dates[i];
                _reward_to_transfer=players[msg.sender].confirmed_rewards_per_date[_my_last_day];
                players[msg.sender].confirmed_rewards_per_date[_my_last_day]=0;
                
                for (uint j=_my_last_day;j<players[msg.sender].interaction_dates[i+1];j++){
                    if(players[root_node].confirmed_rewards_per_date[j]>0){    
                        players[root_node].confirmed_rewards_per_date[j]=
                            players[root_node].confirmed_rewards_per_date[j].add(_reward_to_transfer);
                    }
                }
            }
        }
    }
    
    
    
    function getPlayerPotentialRewards(address _player) public view returns (uint) {

        
            uint _interaction_dates_lenght=players[_player].interaction_dates.length;
            
            if (_interaction_dates_lenght==0){
                return 0;
            }
            else {
                uint _last_interaction_day=players[_player].interaction_dates[_interaction_dates_lenght.sub(1)];
                return players[_player].confirmed_rewards_per_date[_last_interaction_day];
            }
    }
    
    
    function getPlayerAliases(address _player) public view returns(string[] memory){

        return  players[_player].my_aliases;
    }
    
    function getPlayerInteractionDatesArray(address _player) public view returns(uint256[] memory){

        return  players[_player].interaction_dates;
    }
    function getPlayerInteractionDates(address _player, uint _index) public view returns(uint){

        return  players[_player].interaction_dates[_index];
    }
    
    function getPlayerInteractionDatesLenght(address _player) public view returns(uint){

        return  players[_player].interaction_dates.length;
    }
    
    
    function getPlayerConfirmedRewardsPerDate(address _player, uint _date) public view returns(uint){

        return  players[_player].confirmed_rewards_per_date[_date];
    }
    
    function getPlayerFirstLevelDownChilds(address _player) public view returns(address[] memory ){

        return  players[_player].first_level_down_players;
    }
    
    function getPlayerSecondLevelDownChilds(address _player) public view returns(address[] memory){

        return  players[_player].second_level_down_players;
    }
    
    function getPlayerThirdLevelDownChilds(address _player) public view returns(address[] memory){

        return  players[_player].third_level_down_players;
    }
    
    function getPlayerThirdLevelDownChildsNumber(address _player) public view returns(uint){

        return  players[_player].third_level_down_players.length;
    }
    
    function getPlayerFourthLevelDownChilds(address _player) public view returns(address[] memory){

        return  players[_player].fourth_level_down_players;
    }
    
    
    
    function getPlayerTotalChildsNumber(address _player) public view returns(uint){

        return players[_player].first_level_down_players.length +
                    players[_player].second_level_down_players.length + 
                    players[_player].third_level_down_players.length;
    }
    
    
    function closeGame () public onlyOwner{
        require(now>last_participation_date);
        require((now-last_participation_date)>180*DAY_IN_SECONDS);
        
        (bool success, ) = root_node.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
        
        emit GameIsClosed();
    }
    
    event GameIsClosed();

}