
pragma solidity 0.8.3;

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function decimals() external view returns (uint8);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);


    function balanceOf(address addr) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract CommitRevealVault {

    bytes32 private _authorizedCaller;

    bytes32 private _challenge;

    bool private _reentrancyGuard;

    event AuthorizedCallerChanged (bytes32 previousCaller, bytes32 newCaller);

    constructor (bytes32 newChallenge, bytes32 newAuthorizedCaller) {
        require(newAuthorizedCaller != bytes32(0), "Authorized caller required");
        require(newChallenge != bytes32(0), "Challenge required");

        _challenge = newChallenge;
        _authorizedCaller = newAuthorizedCaller;
    }

    modifier onlyAuthorizedCaller () {

        require(keccak256(abi.encodePacked(msg.sender, address(this))) == _authorizedCaller, "Unauthorized caller");
        _;
    }

    modifier ifNotReentrant () {

        require(!_reentrancyGuard, "Reentrant call rejected");
        _reentrancyGuard = true;
        _;
        _reentrancyGuard = false;
    }

    receive() external payable {} // solhint-disable-line no-empty-blocks

    fallback() external payable {}

    function transferOwnership (bytes32 newAuthorizedCaller, bytes32 newChallenge, bytes32 a, bytes32 b, bytes32 c, bytes32 d) 
    public onlyAuthorizedCaller ifNotReentrant {
        require(newAuthorizedCaller != bytes32(0) && newAuthorizedCaller != _authorizedCaller, "Caller rotation required");
        require(newChallenge != bytes32(0) && newChallenge != _challenge, "Challenge rotation required");

        require(_challenge == keccak256(abi.encode(a, b, c, d)), "Invalid proof");

        emit AuthorizedCallerChanged(_authorizedCaller, newAuthorizedCaller);
        _authorizedCaller = newAuthorizedCaller;
        _challenge = newChallenge;
    }

    function transferNative (address payable toAddress, uint256 toAmount, bytes32 newChallenge, bytes32 a, bytes32 b, bytes32 c, bytes32 d) 
    public onlyAuthorizedCaller ifNotReentrant {
        require(toAddress != address(0), "Invalid address");
        require(toAmount > 0, "Invalid amount");
        require(newChallenge != bytes32(0) && newChallenge != _challenge, "Challenge rotation required");

        require(_challenge == keccak256(abi.encode(a, b, c, d)), "Invalid proof");

        _challenge = newChallenge;

        toAddress.transfer(toAmount);
    }

    function transferToken (IERC20 contractAddr, address toAddress, uint256 toAmount, bytes32 newChallenge, bytes32 a, bytes32 b, bytes32 c, bytes32 d) 
    public onlyAuthorizedCaller ifNotReentrant {
        require(toAddress != address(0), "Invalid address");
        require(toAmount > 0, "Invalid amount");
        require(newChallenge != bytes32(0) && newChallenge != _challenge, "Challenge rotation required");

        require(_challenge == keccak256(abi.encode(a, b, c, d)), "Invalid proof");

        _challenge = newChallenge;

        require(contractAddr.transfer(toAddress, toAmount), "ERC20 transfer failed");
    }
}