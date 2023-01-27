


pragma solidity ^0.8.3;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


interface INTokenController {

    
    event NTokenOpened(address tokenAddress, address ntokenAddress, address owner);
    
    event NTokenDisabled(address tokenAddress);
    
    event NTokenEnabled(address tokenAddress);

    struct Config {

        uint96 openFeeNestAmount;

        uint8 state;
    }

    struct NTokenTag {

        address ntokenAddress;

        uint96 nestFee;
    
        address tokenAddress;

        uint40 index;

        uint48 startTime;

        uint8 state;
    }


    function setConfig(Config memory config) external;


    function getConfig() external view returns (Config memory);


    function setNTokenMapping(address tokenAddress, address ntokenAddress, uint state) external;


    function getTokenAddress(address ntokenAddress) external view returns (address);


    function getNTokenAddress(address tokenAddress) external view returns (address);


    
    function disable(address tokenAddress) external;


    function enable(address tokenAddress) external;


    function open(address tokenAddress) external;



    function getNTokenTag(address tokenAddress) external view returns (NTokenTag memory);


    function getNTokenCount() external view returns (uint);


    function list(uint offset, uint count, uint order) external view returns (NTokenTag[] memory);

}


interface INToken {

        
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function increaseTotal(uint256 value) external;


    function checkBlockInfo() external view returns(uint256 createBlock, uint256 recentlyUsedBlock);


    function checkBidder() external view returns(address);

    
    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256); 


    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);

}


interface INestMapping {


    function setBuiltinAddress(
        address nestTokenAddress,
        address nestNodeAddress,
        address nestLedgerAddress,
        address nestMiningAddress,
        address ntokenMiningAddress,
        address nestPriceFacadeAddress,
        address nestVoteAddress,
        address nestQueryAddress,
        address nnIncomeAddress,
        address nTokenControllerAddress
    ) external;


    function getBuiltinAddress() external view returns (
        address nestTokenAddress,
        address nestNodeAddress,
        address nestLedgerAddress,
        address nestMiningAddress,
        address ntokenMiningAddress,
        address nestPriceFacadeAddress,
        address nestVoteAddress,
        address nestQueryAddress,
        address nnIncomeAddress,
        address nTokenControllerAddress
    );


    function getNestTokenAddress() external view returns (address);


    function getNestNodeAddress() external view returns (address);


    function getNestLedgerAddress() external view returns (address);


    function getNestMiningAddress() external view returns (address);


    function getNTokenMiningAddress() external view returns (address);


    function getNestPriceFacadeAddress() external view returns (address);


    function getNestVoteAddress() external view returns (address);


    function getNestQueryAddress() external view returns (address);


    function getNnIncomeAddress() external view returns (address);


    function getNTokenControllerAddress() external view returns (address);


    function registerAddress(string memory key, address addr) external;


    function checkAddress(string memory key) external view returns (address);

}


interface INestGovernance is INestMapping {


    function setGovernance(address addr, uint flag) external;


    function getGovernance(address addr) external view returns (uint);


    function checkGovernance(address addr, uint flag) external view returns (bool);

}


interface INestLedger {


    event ApplicationChanged(address addr, uint flag);
    
    struct Config {
        
        uint16 nestRewardScale;

    }
    
    function setConfig(Config memory config) external;


    function getConfig() external view returns (Config memory);


    function setApplication(address addr, uint flag) external;


    function checkApplication(address addr) external view returns (uint);


    function carveETHReward(address ntokenAddress) external payable;


    function addETHReward(address ntokenAddress) external payable;


    function totalETHRewards(address ntokenAddress) external view returns (uint);


    function pay(address ntokenAddress, address tokenAddress, address to, uint value) external;


    function settle(address ntokenAddress, address tokenAddress, address to, uint value) external payable;

}


contract NestBase {


    address constant NEST_TOKEN_ADDRESS = 0x04abEdA201850aC0124161F037Efd70c74ddC74C;

    uint constant NEST_GENESIS_BLOCK = 5120000;

    function initialize(address nestGovernanceAddress) virtual public {

        require(_governance == address(0), 'NEST:!initialize');
        _governance = nestGovernanceAddress;
    }

    address public _governance;

    function update(address nestGovernanceAddress) virtual public {


        address governance = _governance;
        require(governance == msg.sender || INestGovernance(governance).checkGovernance(msg.sender, 0), "NEST:!gov");
        _governance = nestGovernanceAddress;
    }

    function migrate(address tokenAddress, uint value) external onlyGovernance {


        address to = INestGovernance(_governance).getNestLedgerAddress();
        if (tokenAddress == address(0)) {
            INestLedger(to).addETHReward { value: value } (address(0));
        } else {
            TransferHelper.safeTransfer(tokenAddress, to, value);
        }
    }


    modifier onlyGovernance() {

        require(INestGovernance(_governance).checkGovernance(msg.sender, 0), "NEST:!gov");
        _;
    }

    modifier noContract() {

        require(msg.sender == tx.origin, "NEST:!contract");
        _;
    }
}


contract NToken is NestBase, INToken {


    constructor (string memory _name, string memory _symbol) {

        GENESIS_BLOCK_NUMBER = block.number;
        name = _name;                                                               
        symbol = _symbol;
        _state = block.number;
    }

    address _ntokenMiningAddress;
    
    string public name;

    string public symbol;

    uint8 constant public decimals = 18;

    uint256 _state;
    
    mapping (address=>uint) private _balances;

    mapping (address=>mapping(address=>uint)) private _allowed;

    uint256 immutable public GENESIS_BLOCK_NUMBER;

    function update(address nestGovernanceAddress) override public {

        super.update(nestGovernanceAddress);
        _ntokenMiningAddress = INestGovernance(nestGovernanceAddress).getNTokenMiningAddress();
    }

    function increaseTotal(uint256 value) override public {


        require(msg.sender == _ntokenMiningAddress, "NToken:!Auth");
        
        _balances[msg.sender] += value;

        uint totalSupply_ = (_state >> 128) + value;
        require(totalSupply_ < 0x100000000000000000000000000000000, "NToken:!totalSupply");
        _state = (totalSupply_ << 128) | block.number;
    }
        
    function checkBlockInfo() 
        override public view 
        returns(uint256 createBlock, uint256 recentlyUsedBlock) 
    {

        return (GENESIS_BLOCK_NUMBER, _state & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
    }

    function checkBidder() override public view returns(address) {

        return _ntokenMiningAddress;
    }

    function totalSupply() override public view returns (uint256) {

        return _state >> 128;
    }

    function balanceOf(address owner) override public view returns (uint256) {

        return _balances[owner];
    }

    function allowance(address owner, address spender) override public view returns (uint256) 
    {

        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) override public returns (bool) 
    {

        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) override public returns (bool) 
    {

        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) override public returns (bool) 
    {

        mapping(address=>uint) storage allowed = _allowed[from];
        allowed[msg.sender] -= value;
        _transfer(from, to, value);
        emit Approval(from, msg.sender, allowed[msg.sender]);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) 
    {

        require(spender != address(0));

        mapping(address=>uint) storage allowed = _allowed[msg.sender];
        allowed[spender] += addedValue;
        emit Approval(msg.sender, spender, allowed[spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) 
    {

        require(spender != address(0));

        mapping(address=>uint) storage allowed = _allowed[msg.sender];
        allowed[spender] -= subtractedValue;
        emit Approval(msg.sender, spender, allowed[spender]);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {

        _balances[from] -= value;
        _balances[to] += value;
        emit Transfer(from, to, value);
    }
}


contract NTokenController is NestBase, INTokenController {



    Config _config;

    NTokenTag[] _nTokenTagList;

    mapping(address=>uint) public _nTokenTags;


    function setConfig(Config memory config) override external onlyGovernance {

        require(uint(config.state) <= 1, "NTokenController:!value");
        _config = config;
    }

    function getConfig() override external view returns (Config memory) {

        return _config;
    }

    function setNTokenMapping(address tokenAddress, address ntokenAddress, uint state) override external onlyGovernance {

        
        uint index = _nTokenTags[tokenAddress];
        if (index == 0) {

            _nTokenTagList.push(NTokenTag(
                ntokenAddress,
                uint96(0),
                tokenAddress,
                uint40(_nTokenTagList.length),
                uint48(block.timestamp),
                uint8(state)
            ));
            _nTokenTags[tokenAddress] = _nTokenTags[ntokenAddress] = _nTokenTagList.length;
        } else {

            NTokenTag memory tag = _nTokenTagList[index - 1];
            tag.ntokenAddress = ntokenAddress;
            tag.tokenAddress = tokenAddress;
            tag.index = uint40(index - 1);
            tag.startTime = uint48(block.timestamp);
            tag.state = uint8(state);

            _nTokenTagList[index - 1] = tag;
            _nTokenTags[tokenAddress] = _nTokenTags[ntokenAddress] = index;
        }
    }

    function getTokenAddress(address ntokenAddress) override external view returns (address) {


        uint index = _nTokenTags[ntokenAddress];
        if (index > 0) {
            return _nTokenTagList[index - 1].tokenAddress;
        }
        return address(0);
    }

    function getNTokenAddress(address tokenAddress) override public view returns (address) {


        uint index = _nTokenTags[tokenAddress];
        if (index > 0) {
            return _nTokenTagList[index - 1].ntokenAddress;
        }
        return address(0);
    }

    
    function disable(address tokenAddress) override external onlyGovernance
    {

        _nTokenTagList[_nTokenTags[tokenAddress] - 1].state = 0;
        emit NTokenDisabled(tokenAddress);
    }

    function enable(address tokenAddress) override external onlyGovernance
    {

        _nTokenTagList[_nTokenTags[tokenAddress] - 1].state = 1;
        emit NTokenEnabled(tokenAddress);
    }

    function open(address tokenAddress) override external noContract
    {

        Config memory config = _config;
        require(config.state == 1, "NTokenController:!state");

        require(getNTokenAddress(tokenAddress) == address(0), "NTokenController:!exists");

        uint index = _nTokenTags[tokenAddress];
        require(index == 0 || _nTokenTagList[index - 1].state == 0, "NTokenController:!active");

        uint ntokenCounter = _nTokenTagList.length;

        string memory sn = getAddressStr(ntokenCounter);
        NToken ntoken = new NToken(strConcat("NToken", sn), strConcat("N", sn));

        address governance = _governance;
        ntoken.initialize(address(this));
        ntoken.update(governance);

        TransferHelper.safeTransferFrom(tokenAddress, msg.sender, address(this), 1);
        require(IERC20(tokenAddress).balanceOf(address(this)) >= 1, "NTokenController:!transfer");
        TransferHelper.safeTransfer(tokenAddress, msg.sender, 1);

        IERC20(NEST_TOKEN_ADDRESS).transferFrom(msg.sender, governance, uint(config.openFeeNestAmount));

        _nTokenTags[tokenAddress] = _nTokenTags[address(ntoken)] = ntokenCounter + 1;
        _nTokenTagList.push(NTokenTag(
            address(ntoken),
            config.openFeeNestAmount,
            tokenAddress,
            uint40(_nTokenTagList.length),
            uint48(block.timestamp),
            1
        ));

        emit NTokenOpened(tokenAddress, address(ntoken), msg.sender);
    }


    function getNTokenTag(address tokenAddress) override external view returns (NTokenTag memory) 
    {

        return _nTokenTagList[_nTokenTags[tokenAddress] - 1];
    }

    function getNTokenCount() override external view returns (uint) {

        return _nTokenTagList.length;
    }

    function list(uint offset, uint count, uint order) override external view returns (NTokenTag[] memory) {

        
        NTokenTag[] storage nTokenTagList = _nTokenTagList;
        NTokenTag[] memory result = new NTokenTag[](count);
        uint length = nTokenTagList.length;
        uint i = 0;

        if (order == 0) {

            uint index = length - offset;
            uint end = index > count ? index - count : 0;
            while (index > end) {
                result[i++] = nTokenTagList[--index];
            }
        } 
        else {
            
            uint index = offset;
            uint end = index + count;
            if (end > length) {
                end = length;
            }
            while (index < end) {
                result[i++] = nTokenTagList[index++];
            }
        }

        return result;
    }


    function strConcat(string memory _a, string memory _b) public pure returns (string memory)
    {

        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ret = new string(_ba.length + _bb.length);
        bytes memory bret = bytes(ret);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) {
            bret[k++] = _ba[i];
        } 
        for (uint i = 0; i < _bb.length; i++) {
            bret[k++] = _bb[i];
        } 
        return string(ret);
    } 
    
    function getAddressStr(uint256 iv) public pure returns (string memory) 
    {

        bytes memory buf = new bytes(64);
        uint256 index = 0;
        do {
            buf[index++] = bytes1(uint8(iv % 10 + 48));
            iv /= 10;
        } while (iv > 0 || index < 4);
        bytes memory str = new bytes(index);
        for(uint256 i = 0; i < index; ++i) {
            str[i] = buf[index - i - 1];
        }
        return string(str);
    }
}