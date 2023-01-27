
pragma solidity >=0.7.0 <=0.8.4;
contract Neuy {

    string public name = "NEUY";
    string public symbol = "NEUY";
    string public standard = "NEUY Token v1.0";
    uint256 public totalSupply = 72000000 * 10 ** 18;
    uint public decimals = 18;
    address payable public owner;
    address payable public buOwner;
    address payable public airdropOwner;
    uint256 public minContributorBalance = 200 * 10 ** 18;
    string private rewardKeyId;
    bool public pullEnabled = false;
    
    modifier onlyOwner() {

        require(msg.sender == owner || msg.sender == buOwner);
        _;
    }
    
    modifier allOwners() {

        require(msg.sender == owner || msg.sender == buOwner || msg.sender == airdropOwner);
        _;
    }
    
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
    
    event OwnerSet(
        address indexed oldOwner, 
        address indexed newOwner
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => string) private claimedRewards;
    mapping(address => bool) private contributors;
    mapping(address => string) private contributorsAddresses;
    
    constructor(address _buOwner) {
        balanceOf[msg.sender] = totalSupply;
        buOwner = payable(_buOwner);
        owner = payable(msg.sender);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {

        
        require(_to != address(0x0));
        
        require(balanceOf[msg.sender] >= _value, 'insufficent tokens');
        
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {

        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        
        require(_value <= balanceOf[_from]);
        
        require(_value <= allowance[_from][msg.sender]);

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;
    }
    
    function changeOwner(address newOwner) public onlyOwner {

        emit OwnerSet(owner, newOwner);
        owner = payable(newOwner);
    }
    
    function changeBUOwner(address _buOwner) public onlyOwner {

        require(_buOwner != address(0x0));
        buOwner = payable(_buOwner);
    }
    
    function changeAirDropOwner(address _airdropOwner) public onlyOwner {

        require(_airdropOwner != address(0x0));
        airdropOwner = payable(_airdropOwner);
    }
    
    function finalize() public onlyOwner payable {

        selfdestruct(owner);
    }
    
    function addContributor(address _add, string memory _addS) public onlyOwner {

        contributors[_add] = true;
        contributorsAddresses[_add] = _addS;
    }
    
    function removeContributor(address _add) public onlyOwner {

        contributors[_add] = false;
    }
    
    function changeMinBalance(uint256 _newMin) public onlyOwner {

        minContributorBalance = _newMin * 10 ** 18;
    }
    
    function contributionAirDrop(address[] memory _to_list, uint[] memory _values) public allOwners payable {

        require(_to_list.length < 100);
        require(_to_list.length == _values.length); 
        
        uint totalReward = 0;
        for (uint i = 0; i < _to_list.length; i++) {
            totalReward += _values[i];
        }
        require(totalReward < 200001);
        
        for (uint i = 0; i < _to_list.length; i++) {
            if (balanceOf[_to_list[i]] >= minContributorBalance) {
                mintToken(_to_list[i], _values[i]);
            }
        }
    }
    
    function mintToken(address _to, uint _value) private {

        require(_value < 66800); // No single contributor should be able to get more than
        balanceOf[_to] += _value * 10 ** 16;
        totalSupply += _value * 10 ** 16;
        require(totalSupply < 144000000 * 10 ** 18);
        require(balanceOf[_to] >= _value && totalSupply >= _value); // overflow checks
        emit Transfer(address(0), _to, _value);
    }
    
    function setRewardKey(string memory _rewardId) public onlyOwner {

        pullEnabled = true;
        rewardKeyId = _rewardId;
    }
    
    function setPullStatus(bool _pullStatus) public onlyOwner {

        pullEnabled = _pullStatus;
    }

    function claimContributionReward(bytes32 _rewardHash, uint _value) public payable {

        
        require(pullEnabled == true);
        
        string memory previousRewardId = claimedRewards[msg.sender];
        string memory presentRewardId = rewardKeyId;
        require(sha256(abi.encodePacked(previousRewardId)) != sha256(abi.encodePacked(rewardKeyId)));
        
        require(_rewardHash == keccak256(abi.encodePacked(rewardKeyId,uintToString(_value),contributorsAddresses[address(msg.sender)])));
        
        require(contributors[msg.sender] == true);    

        require(balanceOf[msg.sender] >= minContributorBalance); 
        mintToken(msg.sender, _value);
        claimedRewards[msg.sender] = presentRewardId;
    }
    
    function uintToString(uint _v) internal pure returns (string memory) {

        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (_v != 0) {
            uint remainder = _v % 10;
            _v = _v / 10;
            reversed[i++] = bytes1(uint8(48 + remainder));
        }
        bytes memory s = new bytes(i); // i + 1 is inefficient
        for (uint j = 0; j < i; j++) {
            s[j] = reversed[i - j - 1]; // to avoid the off-by-one error
        }
        string memory str = string(s);  // memory isn't implicitly convertible to storage
        return str;
    }
}