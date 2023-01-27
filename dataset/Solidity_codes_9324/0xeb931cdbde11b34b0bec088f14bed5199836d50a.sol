

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;




interface IController {

    function mint(address, uint256) external;

    function withdraw(address, uint256) external;

    function withdrawVote(address, uint256) external;

    function deposit(address, uint256) external;

    function depositVote(address, uint256) external;

    function totalAssets(address) external view returns (uint256);

    function rewards() external view returns (address);

    function strategies(address) external view returns (address);

    function vaults(address) external view returns (address);

    function setHarvestInfo(address _token, uint256 _harvestReward) external;

}


interface IVote {

    function castVote(address _comp, uint256 _proposalId) external;

    function propose(address _comp, address[] memory targets, uint256[] memory values, string[] memory signatures, bytes[] memory calldatas, string memory description) external returns (uint256);

    function returnToken(address _comp, address _receiver) external returns (uint256 _amount);

    function proposalThreshold(address _comp) external view returns (uint256);

    function state(address _comp, uint256 _proposalId) external view returns (uint8);

    function proposals(address _comp, uint256 _proposalId) external view returns (uint256 _id, address _proposer,
        uint256 _eta, uint256 _startBlock, uint256 _endBlock, uint256 _forVotes, uint256 _againstVotes, uint256 _abstainVotes, bool _canceled, bool _executed);

}


library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


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


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


contract VoteController {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public governance;
    address public pendingGovernance;
    address public controller;
    address public operator;

    mapping (address => address) public againsts;
    mapping (address => address) public fors;
    mapping (address => address) public abstains;
    mapping (address => address) public proposes;
    mapping (address => address) public governors;
    mapping (address => uint256) public proposalIds;
    mapping (address => uint256) public voteProposalIds;
    mapping (address => uint8) public types;

    constructor (address _controller, address _operator) public {
        governance = msg.sender;
        controller = _controller;
        operator =  _operator;
    }

    function acceptGovernance() external {

        require(msg.sender == pendingGovernance, "!pendingGovernance");
        governance = msg.sender;
        pendingGovernance = address(0);
    }
    function setPendingGovernance(address _pendingGovernance) external {

        require(msg.sender == governance, "!governance");
        pendingGovernance = _pendingGovernance;
    }
    function setController(address _controller) external {

        require(msg.sender == governance, "!governance");
        controller = _controller;
    }
    function setOperator(address _operator) external {

        require(msg.sender == governance, "!governance");
        operator = _operator;
    }
    function setGovernor(address _token, address _governor) external {

        require(msg.sender == governance, "!governance");
        governors[_token] = _governor;
    }

    function setAgainst(address _token, address _against) external {

        require(msg.sender == governance, "!governance");
        againsts[_token] = _against;
    }
    function setFor(address _token, address _for) external {

        require(msg.sender == governance, "!governance");
        fors[_token] = _for;
    }
    function setAbstain(address _token, address _abstain) external {

        require(msg.sender == governance, "!governance");
        abstains[_token] = _abstain;
    }
    function setPropose(address _token, address _propose) external {

        require(msg.sender == governance, "!governance");
        proposes[_token] = _propose;
    }

    function prepareVote(address _token, uint256 _proposalId, uint256 _against, uint256 _for, uint256 _abstain) external {

        require(msg.sender == operator || msg.sender == governance, "!operator");
        require(proposalIds[_token] == 0, "!proposalId");
        uint256 _amount = _for.add(_against).add(_abstain);
        require(_amount > 0, "!_amount");

        IController(controller).withdrawVote(_token, _amount);
        proposalIds[_token] = _proposalId;

        uint8 _type = 0;
        if (_against > 0) {
            address _vote = againsts[_token];
            _tranferVote(_token, _vote, _against);
            _type += 4;
        }
        if (_for > 0) {
            address _vote = fors[_token];
            _tranferVote(_token, _vote, _for);
            _type += 2;
        }
        if (_abstain > 0) {
            address _vote = abstains[_token];
            _tranferVote(_token, _vote, _abstain);
            _type += 1;
        }
        types[_token] = _type;
    }

    function _tranferVote(address _token, address _vote, uint256 _amount) internal {

        require(_vote != address(0), "address(0)");
        uint256 _balance = IERC20(_token).balanceOf(address(this));
        if (_amount > _balance) {
            _amount = _balance;
        }
        IERC20(_token).safeTransfer(_vote, _amount);
    }

    function returnToken(address _token, uint256 _proposalId) external {

        require(msg.sender == operator || msg.sender == governance, "!operator");
        require(proposalIds[_token] == _proposalId, "!proposalId");
        uint8 _type = types[_token];
        require(_type > 0, "!type");

        proposalIds[_token] = 0;
        voteProposalIds[_token] = _proposalId;

        uint256 _totalAmount;
        if (_type >= 4) {
            address _vote = againsts[_token];
            _totalAmount = IVote(_vote).returnToken(_token, controller);
            _type -= 4;
        }
        if (_type >= 2) {
            address _vote = fors[_token];
            uint256 _amount = IVote(_vote).returnToken(_token, controller);
            _totalAmount = _totalAmount.add(_amount);
            _type -= 2;
        }
        if (_type >= 1) {
            address _vote = abstains[_token];
            uint256 _amount = IVote(_vote).returnToken(_token, controller);
            _totalAmount = _totalAmount.add(_amount);
        }

        IController(controller).depositVote(_token, _totalAmount);
    }

    function castVote(address _token, uint256 _proposalId) external {

        require(msg.sender == operator || msg.sender == governance, "!operator");
        require(voteProposalIds[_token] == _proposalId, "!proposalId");
        uint8 _type = types[_token];
        require(_type > 0, "!type");

        voteProposalIds[_token] = 0;
        types[_token] = 0;

        if (_type >= 4) {
            address _vote = againsts[_token];
            IVote(_vote).castVote(_token, _proposalId);
            _type -= 4;
        }
        if (_type >= 2) {
            address _vote = fors[_token];
            IVote(_vote).castVote(_token, _proposalId);
            _type -= 2;
        }
        if (_type >= 1) {
            address _vote = abstains[_token];
            IVote(_vote).castVote(_token, _proposalId);
        }
    }

    function totalAssets(address _token) external view returns (uint256) {

        return IController(controller).totalAssets(_token);
    }

    function state(address _token, uint256 _proposalId) external view returns (uint8){

        address _vote = fors[_token];
        return IVote(_vote).state(_token, _proposalId);
    }

    function proposals(address _token, uint256 _proposalId) external view returns (uint256 _id, address _proposer,
        uint256 _eta, uint256 _startBlock, uint256 _endBlock, uint256 _forVotes, uint256 _againstVotes, uint256 _abstainVotes, bool _canceled, bool _executed){

        address _vote = fors[_token];
        return IVote(_vote).proposals(_token, _proposalId);
    }

    function sweep(address _token) external {

        require(msg.sender == governance, "!governance");

        uint256 _balance = IERC20(_token).balanceOf(address(this));
        address _rewards = IController(controller).rewards();
        IERC20(_token).safeTransfer(_rewards, _balance);
    }

    function setProposalId(address _token, uint256 _proposalId) external {

        require(msg.sender == governance, "!governance");
        proposalIds[_token] = _proposalId;
    }

    function setType(address _token, uint8 _type) external {

        require(msg.sender == governance, "!governance");
        types[_token] = _type;
    }

    function prepareProposeByAdmin(address _token) external {

        require(msg.sender == governance, "!governance");

        address _vote = proposes[_token];
        uint256 _amount = IVote(_vote).proposalThreshold(_token);
        IController(controller).withdrawVote(_token, _amount);
        _tranferVote(_token, _vote, _amount);
    }

    function proposeByAdmin(address _token, address[] memory targets, uint256[] memory values, string[] memory signatures, bytes[] memory calldatas, string memory description) external returns (uint256) {

        require(msg.sender == governance, "!operator");

        address _vote = proposes[_token];
        return IVote(_vote).propose(_token, targets, values, signatures, calldatas, description);
    }

    function returnProposeByAdmin(address _token) external {

        require(msg.sender == governance, "!operator");

        address _vote = proposes[_token];
        uint256 _amount = IVote(_vote).returnToken(_token, controller);
        IController(controller).depositVote(_token, _amount);
    }

    function prepareVoteByAdmin(address _token, uint256 _against, uint256 _for, uint256 _abstain) external {

        require(msg.sender == governance, "!governance");

        uint256 _amount = _for.add(_against).add(_abstain);
        IController(controller).withdrawVote(_token, _amount);

        if (_against > 0) {
            address _vote = againsts[_token];
            _tranferVote(_token, _vote, _against);
        }
        if (_for > 0) {
            address _vote = fors[_token];
            _tranferVote(_token, _vote, _for);
        }
        if (_abstain > 0) {
            address _vote = abstains[_token];
            _tranferVote(_token, _vote, _abstain);
        }
    }

    function returnTokenByAdmin(address _token) external {

        require(msg.sender == governance, "!governance");

        address _vote = againsts[_token];
        uint256 _totalAmount = IVote(_vote).returnToken(_token, controller);

        _vote = fors[_token];
        uint256 _amount = IVote(_vote).returnToken(_token, controller);
        _totalAmount = _totalAmount.add(_amount);

        _vote = abstains[_token];
        _amount = IVote(_vote).returnToken(_token, controller);
        _totalAmount = _totalAmount.add(_amount);

        IController(controller).depositVote(_token, _totalAmount);
    }

    function voteByAdmin(address _token, uint256 _proposalId) external {

        require(msg.sender == governance, "!governance");

        address _vote = againsts[_token];
        IVote(_vote).castVote(_token, _proposalId);

        _vote = fors[_token];
        IVote(_vote).castVote(_token, _proposalId);

        _vote = abstains[_token];
        IVote(_vote).castVote(_token, _proposalId);
    }
}