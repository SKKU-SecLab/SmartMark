
pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// GPL-3.0
pragma solidity 0.8.10;



contract OmnuumWallet {

    uint256 public immutable consensusRatio;

    uint8 public immutable minLimitForConsensus;

    enum RequestTypes {
        Withdraw,
        Add,
        Remove,
        Change,
        Cancel
    }

    enum OwnerVotes {
        F,
        D,
        C
    }
    struct OwnerAccount {
        address addr;
        OwnerVotes vote;
    }
    struct Request {
        address requester;
        RequestTypes requestType;
        OwnerAccount currentOwner;
        OwnerAccount newOwner;
        uint256 withdrawalAmount;
        mapping(address => bool) voters;
        uint256 votes;
        bool isExecute;
    }

    Request[] public requests;
    mapping(OwnerVotes => uint8) public ownerCounter;
    mapping(address => OwnerVotes) public ownerVote;

    constructor(
        uint256 _consensusRatio,
        uint8 _minLimitForConsensus,
        OwnerAccount[] memory _initialOwnerAccounts
    ) {
        consensusRatio = _consensusRatio;
        minLimitForConsensus = _minLimitForConsensus;
        for (uint256 i; i < _initialOwnerAccounts.length; i++) {
            OwnerVotes vote = _initialOwnerAccounts[i].vote;
            ownerVote[_initialOwnerAccounts[i].addr] = vote;
            ownerCounter[vote]++;
        }

        _checkMinConsensus();
    }

    event PaymentReceived(address indexed sender, address indexed target, string topic, string description, uint256 value);
    event MintFeeReceived(address indexed nftContract, uint256 value);
    event EtherReceived(address indexed sender, uint256 value);
    event Requested(address indexed owner, uint256 indexed requestId, RequestTypes indexed requestType);
    event Approved(address indexed owner, uint256 indexed requestId, OwnerVotes votes);
    event Revoked(address indexed owner, uint256 indexed requestId, OwnerVotes votes);
    event Canceled(address indexed owner, uint256 indexed requestId);
    event Executed(address indexed owner, uint256 indexed requestId, RequestTypes indexed requestType);

    modifier onlyOwner(address _address) {

        require(isOwner(_address), 'OO4');
        _;
    }

    modifier notOwner(address _address) {

        require(!isOwner(_address), 'OO5');
        _;
    }

    modifier isOwnerAccount(OwnerAccount memory _ownerAccount) {

        address _addr = _ownerAccount.addr;
        require(isOwner(_addr) && uint8(ownerVote[_addr]) == uint8(_ownerAccount.vote), 'NX2');
        _;
    }

    modifier onlyRequester(uint256 _reqId) {

        require(requests[_reqId].requester == msg.sender, 'OO6');
        _;
    }

    modifier reachConsensus(uint256 _reqId) {

        require(requests[_reqId].votes >= requiredVotesForConsensus(), 'NE2');
        _;
    }

    modifier reqExists(uint256 _reqId) {

        require(_reqId < requests.length, 'NX3');
        _;
    }

    modifier notExecutedOrCanceled(uint256 _reqId) {

        require(!requests[_reqId].isExecute, 'SE1');

        require(requests[_reqId].requestType != RequestTypes.Cancel, 'SE2');
        _;
    }

    modifier notVoted(address _owner, uint256 _reqId) {

        require(!isOwnerVoted(_owner, _reqId), 'SE3');
        _;
    }

    modifier voted(address _owner, uint256 _reqId) {

        require(isOwnerVoted(_owner, _reqId), 'SE4');
        _;
    }

    modifier isValidAddress(address _address) {

        require(_address != address(0), 'AE1');
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(_address)
        }

        require(codeSize == 0, 'AE2');
        _;
    }

    function mintFeePayment(address _nftContract) external payable {

        require(msg.value > 0, 'NE3');
        emit MintFeeReceived(_nftContract, msg.value);
    }

    function makePayment(
        address _target,
        string calldata _topic,
        string calldata _description
    ) external payable {

        require(msg.value > 0, 'NE3');
        emit PaymentReceived(msg.sender, _target, _topic, _description, msg.value);
    }

    receive() external payable {
        emit EtherReceived(msg.sender, msg.value);
    }


    function requestOwnerManagement(
        RequestTypes _requestType,
        OwnerAccount calldata _currentAccount,
        OwnerAccount calldata _newAccount
    ) external onlyOwner(msg.sender) {

        address requester = msg.sender;

        Request storage request_ = requests.push();
        request_.requester = requester;
        request_.requestType = _requestType;
        request_.currentOwner = OwnerAccount({ addr: _currentAccount.addr, vote: _currentAccount.vote });
        request_.newOwner = OwnerAccount({ addr: _newAccount.addr, vote: _newAccount.vote });
        request_.voters[requester] = true;
        request_.votes = uint8(ownerVote[requester]);

        emit Requested(msg.sender, requests.length - 1, _requestType);
    }

    function requestWithdrawal(uint256 _withdrawalAmount) external onlyOwner(msg.sender) {

        address requester = msg.sender;

        Request storage request_ = requests.push();
        request_.withdrawalAmount = _withdrawalAmount;
        request_.requester = requester;
        request_.requestType = RequestTypes.Withdraw;
        request_.voters[requester] = true;
        request_.votes = uint8(ownerVote[requester]);

        emit Requested(msg.sender, requests.length - 1, RequestTypes.Withdraw);
    }


    function approve(uint256 _reqId)
        external
        onlyOwner(msg.sender)
        reqExists(_reqId)
        notExecutedOrCanceled(_reqId)
        notVoted(msg.sender, _reqId)
    {

        OwnerVotes _vote = ownerVote[msg.sender];
        Request storage request_ = requests[_reqId];
        request_.voters[msg.sender] = true;
        request_.votes += uint8(_vote);

        emit Approved(msg.sender, _reqId, _vote);
    }


    function revoke(uint256 _reqId)
        external
        onlyOwner(msg.sender)
        reqExists(_reqId)
        notExecutedOrCanceled(_reqId)
        voted(msg.sender, _reqId)
    {

        OwnerVotes vote = ownerVote[msg.sender];
        Request storage request_ = requests[_reqId];
        delete request_.voters[msg.sender];
        request_.votes -= uint8(vote);

        emit Revoked(msg.sender, _reqId, vote);
    }


    function cancel(uint256 _reqId) external reqExists(_reqId) notExecutedOrCanceled(_reqId) onlyRequester(_reqId) {

        requests[_reqId].requestType = RequestTypes.Cancel;

        emit Canceled(msg.sender, _reqId);
    }


    function execute(uint256 _reqId) external reqExists(_reqId) notExecutedOrCanceled(_reqId) onlyRequester(_reqId) reachConsensus(_reqId) {

        Request storage request_ = requests[_reqId];
        uint8 type_ = uint8(request_.requestType);
        request_.isExecute = true;

        if (type_ == uint8(RequestTypes.Withdraw)) {
            _withdraw(request_.withdrawalAmount, request_.requester);
        } else if (type_ == uint8(RequestTypes.Add)) {
            _addOwner(request_.newOwner);
        } else if (type_ == uint8(RequestTypes.Remove)) {
            _removeOwner(request_.currentOwner);
        } else if (type_ == uint8(RequestTypes.Change)) {
            _changeOwner(request_.currentOwner, request_.newOwner);
        }
        emit Executed(msg.sender, _reqId, request_.requestType);
    }


    function totalVotes() public view returns (uint256 votes) {

        return ownerCounter[OwnerVotes.D] + 2 * ownerCounter[OwnerVotes.C];
    }


    function isOwner(address _owner) public view returns (bool isVerified) {

        return uint8(ownerVote[_owner]) > 0;
    }


    function isOwnerVoted(address _owner, uint256 _reqId) public view returns (bool isVoted) {

        return requests[_reqId].voters[_owner];
    }


    function requiredVotesForConsensus() public view returns (uint256 votesForConsensus) {

        return Math.ceilDiv((totalVotes() * consensusRatio), 100);
    }


    function getRequestIdsByExecution(
        bool _isExecuted,
        uint256 _cursorIndex,
        uint256 _length
    ) public view returns (uint256[] memory requestIds) {

        uint256[] memory filteredArray = new uint256[](requests.length);
        uint256 counter = 0;
        uint256 lastReqIdx = getLastRequestNo();
        for (uint256 i = Math.min(_cursorIndex, lastReqIdx); i < Math.min(_cursorIndex + _length, lastReqIdx + 1); i++) {
            if (_isExecuted) {
                if (requests[i].isExecute) {
                    filteredArray[counter] = i;
                    counter++;
                }
            } else {
                if (!requests[i].isExecute) {
                    filteredArray[counter] = i;
                    counter++;
                }
            }
        }
        return _compactUintArray(filteredArray, counter);
    }


    function getRequestIdsByOwner(
        address _owner,
        bool _isExecuted,
        uint256 _cursorIndex,
        uint256 _length
    ) public view returns (uint256[] memory requestIds) {

        uint256[] memory filteredArray = new uint256[](requests.length);
        uint256 counter = 0;
        uint256 lastReqIdx = getLastRequestNo();
        for (uint256 i = Math.min(_cursorIndex, lastReqIdx); i < Math.min(_cursorIndex + _length, lastReqIdx + 1); i++) {
            if (_isExecuted) {
                if ((requests[i].requester == _owner) && (requests[i].isExecute)) {
                    filteredArray[counter] = i;
                    counter++;
                }
            } else {
                if ((requests[i].requester == _owner) && (!requests[i].isExecute)) {
                    filteredArray[counter] = i;
                    counter++;
                }
            }
        }
        return _compactUintArray(filteredArray, counter);
    }


    function getRequestIdsByType(
        RequestTypes _requestType,
        bool _isExecuted,
        uint256 _cursorIndex,
        uint256 _length
    ) public view returns (uint256[] memory requestIds) {

        uint256[] memory filteredArray = new uint256[](requests.length);
        uint256 counter = 0;
        uint256 lastReqIdx = getLastRequestNo();
        for (uint256 i = Math.min(_cursorIndex, lastReqIdx); i < Math.min(_cursorIndex + _length, lastReqIdx + 1); i++) {
            if (_isExecuted) {
                if ((requests[i].requestType == _requestType) && (requests[i].isExecute)) {
                    filteredArray[counter] = i;
                    counter++;
                }
            } else {
                if ((requests[i].requestType == _requestType) && (!requests[i].isExecute)) {
                    filteredArray[counter] = i;
                    counter++;
                }
            }
        }
        return _compactUintArray(filteredArray, counter);
    }


    function getLastRequestNo() public view returns (uint256 requestNo) {

        return requests.length - 1;
    }


    function _withdraw(uint256 _value, address _to) private {

        require(_value <= address(this).balance, 'NE4');
        (bool withdrawn, ) = payable(_to).call{ value: _value }('');

        require(withdrawn, 'SE5');
    }


    function _addOwner(OwnerAccount memory _newAccount) private notOwner(_newAccount.addr) isValidAddress(_newAccount.addr) {

        OwnerVotes vote = _newAccount.vote;
        ownerVote[_newAccount.addr] = vote;
        ownerCounter[vote]++;
    }


    function _removeOwner(OwnerAccount memory _removalAccount) private isOwnerAccount(_removalAccount) {

        ownerCounter[_removalAccount.vote]--;
        _checkMinConsensus();
        delete ownerVote[_removalAccount.addr];
    }


    function _changeOwner(OwnerAccount memory _currentAccount, OwnerAccount memory _newAccount) private {

        OwnerVotes _currentVote = _currentAccount.vote;
        OwnerVotes _newVote = _newAccount.vote;
        ownerCounter[_currentVote]--;
        ownerCounter[_newVote]++;
        _checkMinConsensus();

        if (_currentAccount.addr != _newAccount.addr) {
            delete ownerVote[_currentAccount.addr];
        }
        ownerVote[_newAccount.addr] = _newVote;
    }


    function _checkMinConsensus() private view {

        require(requiredVotesForConsensus() >= minLimitForConsensus, 'NE5');
    }

    function _compactUintArray(uint256[] memory targetArray, uint256 length) internal pure returns (uint256[] memory array) {

        uint256[] memory compactArray = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            compactArray[i] = targetArray[i];
        }
        return compactArray;
    }
}