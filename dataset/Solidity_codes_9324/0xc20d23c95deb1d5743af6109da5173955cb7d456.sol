pragma solidity >=0.6.0 <0.7.0;

interface IDDP {

    function deposit(
        uint256 tokenId,
        uint256 value,
        uint256 maturity,
        address to
    ) external;


    function setClaimPeriod(uint256 claimPeriod) external;

}pragma solidity >=0.6.0 <0.7.0;

interface IAllowList {

    function isAllowedAccount(address account) external view returns (bool);

}

interface IAllowListChange {

    function allowAccount(address account) external;


    function disallowAccount(address account) external;

}pragma solidity >=0.6.0 <0.7.0;


interface ISecurityAssetToken {

    function mint(
        address to,
        uint256 value,
        uint256 maturity
    ) external;


    function burn(uint256 tokenId) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}pragma solidity >=0.6.0 <0.7.0;



contract OperatorVote is Context {

    event AddedFounders(address[] founders);
    event OperatorChanged(address oldOperator, address newOperator);

    address private _operator;
    uint256 private _votesThreshold;

    mapping(address => bool) private _founders;
    mapping(address => address[]) private _candidates;

    constructor(address[] memory founders, uint256 votesThreshold) public {
        _votesThreshold = votesThreshold;

        for (uint256 i = 0; i < founders.length; i++) {
            _founders[founders[i]] = true;
        }

        address msgSender = _msgSender();
        _operator = msgSender;

        emit AddedFounders(founders);
        emit OperatorChanged(address(0), msgSender);
    }

    modifier onlyFounders() {

        require(_founders[_msgSender()], "user is not a founder");
        _;
    }

    modifier onlyOperator() {

        require(_msgSender() == _operator, "user is not the operator");
        _;
    }

    function getNumberVotes(address candidate) external view returns (uint256) {

        return _candidates[candidate].length;
    }

    function getThreshold() external view returns (uint256) {

        return _votesThreshold;
    }

    function getOperator() external view returns (address) {

        return _operator;
    }

    function voteOperator(address candidate) external onlyFounders {

        require(candidate != address(0), "candidate is the zero address");

        address sender = _msgSender();

        for (uint256 i = 0; i < _candidates[candidate].length; i++) {
            require(
                _candidates[candidate][i] != sender,
                "you have already voted"
            );
        }

        if ((_candidates[candidate].length + 1) >= _votesThreshold) {
            delete _candidates[candidate];

            _operator = candidate;
            emit OperatorChanged(_operator, candidate);
        } else {
            _candidates[candidate].push(sender);
        }
    }
}pragma solidity >=0.6.0 <0.7.0;



contract Initializable is Context {

    bool private _isContractInitialized;
    address private _deployer;

    constructor() public {
        _deployer = _msgSender();
    }

    modifier initializer {

        require(_msgSender() == _deployer, "user not allowed to initialize");
        require(!_isContractInitialized, "contract already initialized");
        _;
        _isContractInitialized = true;
    }
}pragma solidity >=0.6.0 <0.7.0;



contract MultiSignature is OperatorVote, Initializable {

    address private _allowList;
    address private _ddp;
    address private _sat;

    constructor (
        address[] memory founders,
        uint256 votesThreshold
        ) public OperatorVote(founders, votesThreshold)
    {
    }

    function configure(
        address allowList,
        address ddp,
        address sat
    ) external initializer
    {

        _allowList = allowList;
        _ddp = ddp;
        _sat = sat;
    }

    function allowAccount (address account) external onlyOperator {
        IAllowListChange(_allowList).allowAccount(account);
    }

    function disallowAccount(address account) external onlyOperator {

        IAllowListChange(_allowList).disallowAccount(account);
    }

    function mintSecurityAssetToken(
        address to,
        uint256 value,
        uint256 maturity) external onlyOperator
    {

        ISecurityAssetToken(_sat).mint(to, value, maturity);
    }

    function burnSecurityAssetToken(uint256 tokenId) external onlyOperator {

        ISecurityAssetToken(_sat).burn(tokenId);
    }

    function transferSecurityAssetToken(
        address from,
        address to,
        uint256 tokenId) external onlyOperator
    {

        ISecurityAssetToken(_sat).transferFrom(from, to, tokenId);
    }

    function setClaimPeriod(uint256 claimPeriod) external onlyOperator {

        IDDP(_ddp).setClaimPeriod(claimPeriod);
    }
}