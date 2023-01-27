
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function decimals() external view returns (uint8);


    function symbol() external view returns (string memory);


    function name() external view returns (string memory);


    function getOwner() external view returns (address);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address _owner, address spender) external view returns (uint256);


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
contract Context {

    constructor ()  {}

    function _msgSender() internal view returns (address payable) {

        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {

        this;
        return msg.data;
    }
}


contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
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

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success,) = recipient.call{value : amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value : value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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

library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

    unchecked {
        uint256 oldAllowance = token.allowance(address(this), spender);
        require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
        uint256 newAllowance = oldAllowance - value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract LoveVote is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public proposalValue = 100000 * 10 ** 18;

    IERC20 votorToken;

    mapping(address => bool) public directors;

    struct Votor {
        address account;
        uint256 voteCountTotal;
    }


    mapping(address => Votor) public votorMap;
    mapping(address => mapping(uint256 => uint256[5])) public userForProposalOptionAndCounts;

    struct chairperson {
        address account;
        uint256 lastProposalBlockNumber;
    }

    mapping(address => chairperson) public chairpersonMap;

    struct Proposal {
        bool IsMajorProposal;
        address Chairperson;
        string Name;
        uint256 OptionsTotalCounts;
        bool IsEffective;
        bool IsVotingEnd;
        uint256 StartTime;
        uint256 EndTime;
        uint8 WinOption;
    }

    mapping(uint256 => mapping(uint8 => string)) public ProposalOptions;

    Proposal[] public Proposals;

    mapping(uint256 => mapping(uint8 => uint256)) public ProposalsOptionsCounts;
    mapping(uint256 => mapping(address => uint256[5])) public votorOptionAndCounts;

    modifier validateByPid(uint256 _pid) {

        require(_pid < Proposals.length, "The proposal does not exist!");
        _;
    }

    event VoteEvent(address user, uint256 _pid, uint8 Option, uint256 _votes);
    event GetVotor(address user, uint256 _pid, uint8 Option, uint256 account);
    event ProposalEvent(address chairpersonUser, string _name, string _AOptions, string _BOptions, string _COptions,
        string _DOptions, string _FOptions, bool _isMajorProposal);
        
    event ProposalStop(uint256 _pid,address msgsender);
    event ProposaleCalculation(uint256 _pid, bool isMandatorySettlement,address msgsender);

    constructor(IERC20 _votorToken){
        require(address(_votorToken) !=address(0),"_votorToken is zero value! ");
        directors[msg.sender] = true;
        votorToken = _votorToken;
    }

    function addDirector(address _director) external onlyOwner {

        directors[_director] = true;
    }

    function delDirector(address _director) external onlyOwner {

        directors[_director] = false;
    }

    function setProposalValue(uint256 number) external {

        require(directors[msg.sender], "Permission denied!");
        proposalValue = number;
    }

    function getProposalLen() external view returns (uint256){

        return Proposals.length;
    }

    function vote(uint256 _pid, uint8 _options, uint256 _votes) external validateByPid(_pid) {

        require(_options < 5, "The option does not exist!");
        require(_votes >= 1 * 10 ** 18, "At least one vote at a time!");
        Proposal storage thisProposal = Proposals[_pid];
        require(thisProposal.IsEffective, "The proposal is invalid!");
        require(!thisProposal.IsVotingEnd, "The proposal is over!");
        require(thisProposal.EndTime >= block.timestamp, "The proposal is over!");
        thisProposal.OptionsTotalCounts = thisProposal.OptionsTotalCounts.add(_votes);
        ProposalsOptionsCounts[_pid][_options] = ProposalsOptionsCounts[_pid][_options].add(_votes);
        votorToken.safeTransferFrom(msg.sender, address(this), _votes);
        Votor storage user = votorMap[msg.sender];
        user.account = msg.sender;
        user.voteCountTotal = user.voteCountTotal.add(_votes);
        votorOptionAndCounts[_pid][msg.sender][_options] = votorOptionAndCounts[_pid][msg.sender][_options].add(_votes);
        userForProposalOptionAndCounts[msg.sender][_pid][_options] = userForProposalOptionAndCounts[msg.sender][_pid][_options].add(_votes);
        emit VoteEvent(msg.sender, _pid, _options, _votes);
    }

    function getVoted(uint256 _pid) external validateByPid(_pid) {

        Proposal storage thisProposal = Proposals[_pid];
        Votor storage user = votorMap[msg.sender];
        require(!thisProposal.IsEffective || thisProposal.IsVotingEnd, "It can't be redeemed yet!");
        for (uint8 i = 0; i < 5; i++) {
            if (userForProposalOptionAndCounts[msg.sender][_pid][i] > 0) {
                votorToken.safeTransfer(msg.sender, userForProposalOptionAndCounts[msg.sender][_pid][i]);
                user.voteCountTotal = user.voteCountTotal.sub(userForProposalOptionAndCounts[msg.sender][_pid][i]);
                userForProposalOptionAndCounts[msg.sender][_pid][i] = 0;
                emit GetVotor(msg.sender, _pid, i, userForProposalOptionAndCounts[msg.sender][_pid][i]);
            }
        }
    }

    function proposal(string memory _name, string memory _AOptions, string memory _BOptions, string memory _COptions, string memory _DOptions,
        string memory _FOptions, bool _isMajorProposal, uint256 _endDay) external returns (bool){

        require(votorToken.balanceOf(msg.sender) > proposalValue, "Insufficient balance!");
        require(block.number.sub(chairpersonMap[msg.sender].lastProposalBlockNumber) > 129600, "Permission denied");

        uint256 _endTime = block.timestamp + _endDay.mul(86400);
        if (block.number.sub(chairpersonMap[msg.sender].lastProposalBlockNumber) > 129600) {
            Proposals.push(Proposal({
            IsMajorProposal : _isMajorProposal,
            Chairperson : msg.sender,
            Name : _name,
            OptionsTotalCounts : 0,
            StartTime : block.timestamp,
            EndTime : _endTime,
            IsEffective : true,
            IsVotingEnd : false,
            WinOption : 6
            }));
            ProposalOptions[Proposals.length - 1][0] = _AOptions;
            ProposalOptions[Proposals.length - 1][1] = _BOptions;
            ProposalOptions[Proposals.length - 1][2] = _COptions;
            ProposalOptions[Proposals.length - 1][3] = _DOptions;
            ProposalOptions[Proposals.length - 1][4] = _FOptions;
            chairpersonMap[msg.sender] = chairperson({
            account : msg.sender,
            lastProposalBlockNumber : block.number
            });

            emit ProposalEvent(msg.sender, _name, _AOptions, _BOptions, _COptions, _DOptions, _FOptions, _isMajorProposal);
            return true;
        } else {
            return false;
        }

    }

    function IsProposalEnd(uint256 endblock) external view returns (bool isEnd){

        if (endblock <= block.number) {
            return true;
        }
    }

    function proposalStop(uint256 _pid) external validateByPid(_pid) {

        Proposal storage thisProposal = Proposals[_pid];
        require(thisProposal.Chairperson == msg.sender || directors[msg.sender], "Permission denied!");
        thisProposal.IsEffective = false;
        emit ProposalStop(_pid,msg.sender);
    }

    function proposaleCalculation(uint256 _pid, bool isMandatorySettlement) external validateByPid(_pid) {

        Proposal storage thisProposal = Proposals[_pid];
        require(thisProposal.IsEffective, "The proposal is invalid!");
        require(!thisProposal.IsVotingEnd, "The proposal is over!");
        if (!isMandatorySettlement) {
            require(thisProposal.EndTime < block.timestamp, "Voting time is not yet up!");
        }
        require(thisProposal.Chairperson == msg.sender || directors[msg.sender], "Permission denied!");

        if (thisProposal.IsMajorProposal) {
            uint256 winerVotes = thisProposal.OptionsTotalCounts.div(2);
            for (uint8 i = 0; i < 5; i++) {
                if (ProposalsOptionsCounts[_pid][i] > winerVotes) {
                    thisProposal.WinOption = i;
                }
            }
        } else {
            uint256 winerVotes = ProposalsOptionsCounts[_pid][0];
            for (uint8 i = 1; i < 5; i++) {
                if (ProposalsOptionsCounts[_pid][i] > winerVotes) {
                    winerVotes = ProposalsOptionsCounts[_pid][i];
                    thisProposal.WinOption = i;
                }
            }
        }
        thisProposal.EndTime = block.timestamp;
        thisProposal.IsVotingEnd = true;
        emit ProposaleCalculation(_pid,isMandatorySettlement,msg.sender);
    }

}