
pragma solidity 0.6.0;

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
contract Nest_3_VoteFactory {

    using SafeMath for uint256;
    
    uint256 _limitTime = 7 days;                                    //  Vote duration投票持续时间
    uint256 _NNLimitTime = 1 days;                                  //  NestNode raising time NestNode筹集时间
    uint256 _circulationProportion = 51;                            //  Proportion of votes to pass 通过票数比例
    uint256 _NNUsedCreate = 10;                                     //  The minimum number of NNs to create a voting contract创建投票合约最小 NN 数量
    uint256 _NNCreateLimit = 100;                                   //  The minimum number of NNs needed to start voting开启投票需要筹集 NN 最小数量
    uint256 _emergencyTime = 0;                                     //  The emergency state start time紧急状态启动时间
    uint256 _emergencyTimeLimit = 3 days;                           //  The emergency state duration紧急状态持续时间
    uint256 _emergencyNNAmount = 1000;                              //  The number of NNs required to switch the emergency state切换紧急状态需要nn数量
    ERC20 _NNToken;                                                 //  NestNode Token守护者节点Token（NestNode）
    ERC20 _nestToken;                                               //  NestToken
    mapping(string => address) _contractAddress;                    //  Voting contract mapping投票合约映射
    mapping(address => bool) _modifyAuthority;                      //  Modify permissions修改权限
    mapping(address => address) _myVote;                            //  Personal voting address我的投票
    mapping(address => uint256) _emergencyPerson;                   //  Emergency state personal voting number紧急状态个人存储量
    mapping(address => bool) _contractData;                         //  Voting contract data投票合约集合
    bool _stateOfEmergency = false;                                 //  Emergency state紧急状态
    address _destructionAddress;                                    //  Destroy contract address销毁合约地址

    event ContractAddress(address contractAddress);
    
    constructor () public {
        _modifyAuthority[address(msg.sender)] = true;
    }
    
    function changeMapping() public onlyOwner {

        _NNToken = ERC20(checkAddress("nestNode"));
        _destructionAddress = address(checkAddress("nest.v3.destruction"));
        _nestToken = ERC20(address(checkAddress("nest")));
    }
    
    function createVote(address implementContract, uint256 nestNodeAmount) public {

        require(address(tx.origin) == address(msg.sender), "It can't be a contract");
        require(nestNodeAmount >= _NNUsedCreate);
        Nest_3_VoteContract newContract = new Nest_3_VoteContract(implementContract, _stateOfEmergency, nestNodeAmount);
		require(_NNToken.transferFrom(address(tx.origin), address(newContract), nestNodeAmount), "Authorization transfer failed");
		_contractData[address(newContract)] = true;
        emit ContractAddress(address(newContract));
    }
    
    function nestVote(address contractAddress) public {

        require(address(msg.sender) == address(tx.origin), "It can't be a contract");
        require(_contractData[contractAddress], "It's not a voting contract");
        require(!checkVoteNow(address(msg.sender)));
        Nest_3_VoteContract newContract = Nest_3_VoteContract(contractAddress);
        newContract.nestVote();
        _myVote[address(tx.origin)] = contractAddress;
    }
    
    function nestNodeVote(address contractAddress, uint256 NNAmount) public {

        require(address(msg.sender) == address(tx.origin), "It can't be a contract");
        require(_contractData[contractAddress], "It's not a voting contract");
        Nest_3_VoteContract newContract = Nest_3_VoteContract(contractAddress);
        require(_NNToken.transferFrom(address(tx.origin), address(newContract), NNAmount), "Authorization transfer failed");
        newContract.nestNodeVote(NNAmount);
    }
    
    function startChange(address contractAddress) public {

        require(address(msg.sender) == address(tx.origin), "It can't be a contract");
        require(_contractData[contractAddress], "It's not a voting contract");
        Nest_3_VoteContract newContract = Nest_3_VoteContract(contractAddress);
        require(_stateOfEmergency == newContract.checkStateOfEmergency());
        addSuperManPrivate(address(newContract));
        newContract.startChange();
        deleteSuperManPrivate(address(newContract));
    }
    
    function sendNestNodeForStateOfEmergency(uint256 amount) public {

        require(_NNToken.transferFrom(address(tx.origin), address(this), amount));
        _emergencyPerson[address(tx.origin)] = _emergencyPerson[address(tx.origin)].add(amount);
    }
    
    function turnOutNestNodeForStateOfEmergency() public {

        require(_emergencyPerson[address(tx.origin)] > 0);
        require(_NNToken.transfer(address(tx.origin), _emergencyPerson[address(tx.origin)]));
        _emergencyPerson[address(tx.origin)] = 0;
        uint256 nestAmount = _nestToken.balanceOf(address(this));
        require(_nestToken.transfer(address(_destructionAddress), nestAmount));
    }
    
    function changeStateOfEmergency() public {

        if (_stateOfEmergency) {
            require(now > _emergencyTime.add(_emergencyTimeLimit));
            _stateOfEmergency = false;
            _emergencyTime = 0;
        } else {
            require(_emergencyPerson[address(msg.sender)] > 0);
            require(_NNToken.balanceOf(address(this)) >= _emergencyNNAmount);
            _stateOfEmergency = true;
            _emergencyTime = now;
        }
    }
    
    function checkVoteNow(address user) public view returns (bool) {

        if (_myVote[user] == address(0x0)) {
            return false;
        } else {
            Nest_3_VoteContract vote = Nest_3_VoteContract(_myVote[user]);
            if (vote.checkContractEffective() || vote.checkPersonalAmount(user) == 0) {
                return false;
            }
            return true;
        }
    }
    
    function checkMyVote(address user) public view returns (address) {

        return _myVote[user];
    }
    
    function checkLimitTime() public view returns (uint256) {

        return _limitTime;
    }
    
    function checkNNLimitTime() public view returns (uint256) {

        return _NNLimitTime;
    }
    
    function checkCirculationProportion() public view returns (uint256) {

        return _circulationProportion;
    }
    
    function checkNNUsedCreate() public view returns (uint256) {

        return _NNUsedCreate;
    }
    
    function checkNNCreateLimit() public view returns (uint256) {

        return _NNCreateLimit;
    }
    
    function checkStateOfEmergency() public view returns (bool) {

        return _stateOfEmergency;
    }
    
    function checkEmergencyTime() public view returns (uint256) {

        return _emergencyTime;
    }
    
    function checkEmergencyTimeLimit() public view returns (uint256) {

        return _emergencyTimeLimit;
    }
    
    function checkEmergencyPerson(address user) public view returns (uint256) {

        return _emergencyPerson[user];
    }
    
    function checkEmergencyNNAmount() public view returns (uint256) {

        return _emergencyNNAmount;
    }
    
    function checkContractData(address contractAddress) public view returns (bool) {

        return _contractData[contractAddress];
    }
    
    function changeLimitTime(uint256 num) public onlyOwner {

        require(num > 0, "Parameter needs to be greater than 0");
        _limitTime = num;
    }
    
    function changeNNLimitTime(uint256 num) public onlyOwner {

        require(num > 0, "Parameter needs to be greater than 0");
        _NNLimitTime = num;
    }
    
    function changeCirculationProportion(uint256 num) public onlyOwner {

        require(num > 0, "Parameter needs to be greater than 0");
        _circulationProportion = num;
    }
    
    function changeNNUsedCreate(uint256 num) public onlyOwner {

        _NNUsedCreate = num;
    }
    
    function checkNNCreateLimit(uint256 num) public onlyOwner {

        _NNCreateLimit = num;
    }
    
    function changeEmergencyTimeLimit(uint256 num) public onlyOwner {

        require(num > 0);
        _emergencyTimeLimit = num.mul(1 days);
    }
    
    function changeEmergencyNNAmount(uint256 num) public onlyOwner {

        require(num > 0);
        _emergencyNNAmount = num;
    }
    
    function checkAddress(string memory name) public view returns (address contractAddress) {

        return _contractAddress[name];
    }
    
    function addContractAddress(string memory name, address contractAddress) public onlyOwner {

        _contractAddress[name] = contractAddress;
    }
    
    function addSuperMan(address superMan) public onlyOwner {

        _modifyAuthority[superMan] = true;
    }
	
    function addSuperManPrivate(address superMan) private {

        _modifyAuthority[superMan] = true;
    }
    
    function deleteSuperMan(address superMan) public onlyOwner {

        _modifyAuthority[superMan] = false;
    }
    function deleteSuperManPrivate(address superMan) private {

        _modifyAuthority[superMan] = false;
    }
    
    function deleteContractData(address contractAddress) public onlyOwner {

        _contractData[contractAddress] = false;
    }
    
    function checkOwners(address man) public view returns (bool) {

        return _modifyAuthority[man];
    }
    
    modifier onlyOwner() {

        require(checkOwners(msg.sender), "No authority");
        _;
    }
}

contract Nest_3_VoteContract {

    using SafeMath for uint256;
    
    Nest_3_Implement _implementContract;                //  Executable contract
    Nest_3_TokenSave _tokenSave;                        //  Lock-up contract
    Nest_3_VoteFactory _voteFactory;                    //  Voting factory contract
    Nest_3_TokenAbonus _tokenAbonus;                    //  Bonus logic contract
    ERC20 _nestToken;                                   //  NestToken
    ERC20 _NNToken;                                     //  NestNode Token
    address _miningSave;                                //  Mining pool contract
    address _implementAddress;                          //  Executable contract address
    address _destructionAddress;                        //  Destruction contract address
    uint256 _createTime;                                //  Creation time
    uint256 _endTime;                                   //  End time
    uint256 _totalAmount;                               //  Total votes
    uint256 _circulation;                               //  Passed votes
    uint256 _destroyedNest;                             //  Destroyed NEST
    uint256 _NNLimitTime;                               //  NestNode raising time
    uint256 _NNCreateLimit;                             //  Minimum number of NNs to create votes
    uint256 _abonusTimes;                               //  Period number of used snapshot in emergency state
    uint256 _allNNAmount;                               //  Total number of NNs
    bool _effective = false;                            //  Whether vote is effective
    bool _nestVote = false;                             //  Whether NEST vote can be performed
    bool _isChange = false;                             //  Whether NEST vote is executed
    bool _stateOfEmergency;                             //  Whether the contract is in emergency state
    mapping(address => uint256) _personalAmount;        //  Number of personal votes
    mapping(address => uint256) _personalNNAmount;      //  Number of NN personal votes
    
    constructor (address contractAddress, bool stateOfEmergency, uint256 NNAmount) public {
        Nest_3_VoteFactory voteFactory = Nest_3_VoteFactory(address(msg.sender));
        _voteFactory = voteFactory;
        _nestToken = ERC20(voteFactory.checkAddress("nest"));
        _NNToken = ERC20(voteFactory.checkAddress("nestNode"));
        _implementContract = Nest_3_Implement(address(contractAddress));
        _implementAddress = address(contractAddress);
        _destructionAddress = address(voteFactory.checkAddress("nest.v3.destruction"));
        _personalNNAmount[address(tx.origin)] = NNAmount;
        _allNNAmount = NNAmount;
        _createTime = now;                                    
        _endTime = _createTime.add(voteFactory.checkLimitTime());
        _NNLimitTime = voteFactory.checkNNLimitTime();
        _NNCreateLimit = voteFactory.checkNNCreateLimit();
        _stateOfEmergency = stateOfEmergency;
        if (stateOfEmergency) {
            _tokenAbonus = Nest_3_TokenAbonus(voteFactory.checkAddress("nest.v3.tokenAbonus"));
            _abonusTimes = _tokenAbonus.checkTimes().sub(2);
            require(_abonusTimes > 0);
            _circulation = _tokenAbonus.checkTokenAllValueHistory(address(_nestToken),_abonusTimes).mul(voteFactory.checkCirculationProportion()).div(100);
        } else {
            _miningSave = address(voteFactory.checkAddress("nest.v3.miningSave"));
            _tokenSave = Nest_3_TokenSave(voteFactory.checkAddress("nest.v3.tokenSave"));
            _circulation = (uint256(10000000000 ether).sub(_nestToken.balanceOf(address(_miningSave))).sub(_nestToken.balanceOf(address(_destructionAddress)))).mul(voteFactory.checkCirculationProportion()).div(100);
        }
        if (_allNNAmount >= _NNCreateLimit) {
            _nestVote = true;
        }
    }
    
    function nestVote() public onlyFactory {

        require(now <= _endTime, "Voting time exceeded");
        require(!_effective, "Vote in force");
        require(_nestVote);
        require(_personalAmount[address(tx.origin)] == 0, "Have voted");
        uint256 amount;
        if (_stateOfEmergency) {
            amount = _tokenAbonus.checkTokenSelfHistory(address(_nestToken),_abonusTimes, address(tx.origin));
        } else {
            amount = _tokenSave.checkAmount(address(tx.origin), address(_nestToken));
        }
        _personalAmount[address(tx.origin)] = amount;
        _totalAmount = _totalAmount.add(amount);
        ifEffective();
    }
    
    function nestVoteCancel() public {

        require(address(msg.sender) == address(tx.origin), "It can't be a contract");
        require(now <= _endTime, "Voting time exceeded");
        require(!_effective, "Vote in force");
        require(_personalAmount[address(tx.origin)] > 0, "No vote");                     
        _totalAmount = _totalAmount.sub(_personalAmount[address(tx.origin)]);
        _personalAmount[address(tx.origin)] = 0;
    }
    
    function nestNodeVote(uint256 NNAmount) public onlyFactory {

        require(now <= _createTime.add(_NNLimitTime), "Voting time exceeded");
        require(!_nestVote);
        _personalNNAmount[address(tx.origin)] = _personalNNAmount[address(tx.origin)].add(NNAmount);
        _allNNAmount = _allNNAmount.add(NNAmount);
        if (_allNNAmount >= _NNCreateLimit) {
            _nestVote = true;
        }
    }
    
    function turnOutNestNode() public {

        if (_nestVote) {
            if (!_stateOfEmergency || !_effective) {
                require(now > _endTime, "Vote unenforceable");
            }
        } else {
            require(now > _createTime.add(_NNLimitTime));
        }
        require(_personalNNAmount[address(tx.origin)] > 0);
        require(_NNToken.transfer(address(tx.origin), _personalNNAmount[address(tx.origin)]));
        _personalNNAmount[address(tx.origin)] = 0;
        uint256 nestAmount = _nestToken.balanceOf(address(this));
        _destroyedNest = _destroyedNest.add(nestAmount);
        require(_nestToken.transfer(address(_destructionAddress), nestAmount));
    }
    
    function startChange() public onlyFactory {

        require(!_isChange);
        _isChange = true;
        if (_stateOfEmergency) {
            require(_effective, "Vote unenforceable");
        } else {
            require(_effective && now > _endTime, "Vote unenforceable");
        }
        _voteFactory.addSuperMan(address(_implementContract));
        _implementContract.doit();
        _voteFactory.deleteSuperMan(address(_implementContract));
    }
    
    function ifEffective() private {

        if (_totalAmount >= _circulation) {
            _effective = true;
        }
    }
    
    function checkContractEffective() public view returns (bool) {

        if (_effective || now > _endTime) {
            return true;
        } 
        return false;
    }
    
    function checkImplementAddress() public view returns (address) {

        return _implementAddress;
    }
    
    function checkCreateTime() public view returns (uint256) {

        return _createTime;
    }
    
    function checkEndTime() public view returns (uint256) {

        return _endTime;
    }
    
    function checkTotalAmount() public view returns (uint256) {

        return _totalAmount;
    }
    
    function checkCirculation() public view returns (uint256) {

        return _circulation;
    }
    
    function checkPersonalAmount(address user) public view returns (uint256) {

        return _personalAmount[user];
    }
    
    function checkDestroyedNest() public view returns (uint256) {

        return _destroyedNest;
    }
    
    function checkEffective() public view returns (bool) {

        return _effective;
    }
    
    function checkStateOfEmergency() public view returns (bool) {

        return _stateOfEmergency;
    }
    
    function checkNNLimitTime() public view returns (uint256) {

        return _NNLimitTime;
    }
    
    function checkNNCreateLimit() public view returns (uint256) {

        return _NNCreateLimit;
    }
    
    function checkAbonusTimes() public view returns (uint256) {

        return _abonusTimes;
    }
    
    function checkPersonalNNAmount(address user) public view returns (uint256) {

        return _personalNNAmount[address(user)];
    }
    
    function checkAllNNAmount() public view returns (uint256) {

        return _allNNAmount;
    }
    
    function checkNestVote() public view returns (bool) {

        return _nestVote;
    }
    
    function checkIsChange() public view returns (bool) {

        return _isChange;
    }
    
    modifier onlyFactory() {

        require(address(_voteFactory) == address(msg.sender), "No authority");
        _;
    }
}

interface Nest_3_Implement {

    function doit() external;

}

interface Nest_3_TokenSave {

    function checkAmount(address sender, address token) external view returns (uint256);

}

interface Nest_3_TokenAbonus {

    function checkTokenAllValueHistory(address token, uint256 times) external view returns (uint256);

    function checkTokenSelfHistory(address token, uint256 times, address user) external view returns (uint256);

    function checkTimes() external view returns (uint256);

}

interface ERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}