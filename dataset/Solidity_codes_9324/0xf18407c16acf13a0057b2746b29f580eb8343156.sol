
pragma solidity ^0.6.0;

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

struct StoredMessageData {
    address firstAuthor;
    uint totalBurned;
    uint totalTipped;
}

contract SmokeSignal {

    IERC20 public token;
    address public donationAddress;

    constructor(IERC20 _token, address _donationAddress) public {
        token = _token;
        donationAddress = _donationAddress;
    }

    mapping (bytes32 => StoredMessageData) public storedMessageData;

    event MessageBurn(
        bytes32 indexed _hash,
        address indexed _from,
        uint _burnAmount,
        string _message
    );

    function burnMessage(string calldata _message, uint _burnAmount, uint _donateAmount)
        external
        returns(bytes32)
    {

        internalDonateIfNonzero(_donateAmount);

        bytes32 hash = keccak256(abi.encode(_message));

        internalBurnForMessageHash(hash, _burnAmount);

        if (storedMessageData[hash].firstAuthor == address(0)) {
            storedMessageData[hash].firstAuthor = msg.sender;
        }

        emit MessageBurn(
            hash,
            msg.sender,
            _burnAmount,
            _message
        );

        return hash;
    }

    event HashBurn(
        bytes32 indexed _hash,
        address indexed _from,
        uint _burnAmount
    );

    function burnHash(bytes32 _hash, uint _burnAmount, uint _donateAmount)
        external
    {

        internalDonateIfNonzero(_donateAmount);

        internalBurnForMessageHash(_hash, _burnAmount);

        emit HashBurn(
            _hash,
            msg.sender,
            _burnAmount
        );
    }

    event HashTip(
        bytes32 indexed _hash,
        address indexed _from,
        uint _tipAmount
    );

    function tipHashOrBurnIfNoAuthor(bytes32 _hash, uint _amount, uint _donateAmount)
        external
    {

        internalDonateIfNonzero(_donateAmount);

        address author = storedMessageData[_hash].firstAuthor;
        if (author == address(0)) {
            internalBurnForMessageHash(_hash, _amount);

            emit HashBurn(
                _hash,
                msg.sender,
                _amount
            );
        }
        else {
            internalTipForMessageHash(_hash, author, _amount);

            emit HashTip(
                _hash,
                msg.sender,
                _amount
            );
        }
    }

    function internalBurnForMessageHash(bytes32 _hash, uint _burnAmount)
        internal
    {

        require(_burnAmount > 0, "burnAmount must be greater than 0");
        bool burnSuccess = burnFrom(msg.sender, _burnAmount);
        require(burnSuccess, "Burn failed");

        storedMessageData[_hash].totalBurned += _burnAmount;
    }

    function burnFrom(address _who, uint _burnAmount)
        internal
        returns(bool)
    {

        return token.transferFrom(_who, address(0), _burnAmount);
    }

    function internalTipForMessageHash(bytes32 _hash, address author, uint _tipAmount)
        internal
    {

        require(_tipAmount > 0, "tipAmount must be greater than 0");
        bool transferSuccess = token.transferFrom(msg.sender, author, _tipAmount);
        require(transferSuccess, "Tip transfer failed");

        storedMessageData[_hash].totalTipped += _tipAmount;
    }

    function internalDonateIfNonzero(uint _donateAmount)
        internal
    {

        if (_donateAmount > 0) {
            bool transferSuccess = token.transferFrom(msg.sender, donationAddress, _donateAmount);
            require(transferSuccess, "Donation transfer failed");
        }
    }
}