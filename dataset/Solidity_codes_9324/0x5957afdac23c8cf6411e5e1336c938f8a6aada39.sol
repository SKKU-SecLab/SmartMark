

pragma solidity ^0.5.0;


contract EIP20Interface {



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



    function name() public view returns (string memory tokenName_);


    function symbol() public view returns (string memory tokenSymbol_);


    function decimals() public view returns (uint8 tokenDecimals_);


    function totalSupply()
        public
        view
        returns (uint256 totalTokenSupply_);


    function balanceOf(address _owner) public view returns (uint256 balance_);


    function allowance(
        address _owner,
        address _spender
    )
        public
        view
        returns (uint256 allowance_);



    function transfer(
        address _to,
        uint256 _value
    )
        public
        returns (bool success_);


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        returns (bool success_);


    function approve(
        address _spender,
        uint256 _value
    )
        public
        returns (bool success_);


}


pragma solidity ^0.5.0;



interface GatewayInterface {



    function bounty()
        external
        returns (uint256);


    function stake(
        uint256 _amount,
        address _beneficiary,
        uint256 _gasPrice,
        uint256 _gasLimit,
        uint256 _nonce,
        bytes32 _hashLock
    )
        external
        returns (bytes32 messageHash_);


    function revertStake(
        bytes32 _messageHash
    )
        external
        returns
    (
        address staker_,
        uint256 stakerNonce_,
        uint256 amount_
    );

}


pragma solidity ^0.5.0;




library SafeMath {


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;


        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}


pragma solidity ^0.5.0;





contract EIP20Token is EIP20Interface {


    using SafeMath for uint256;



    string internal tokenName;
    string internal tokenSymbol;
    uint8  private tokenDecimals;
    uint256 internal totalTokenSupply;

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;



    constructor(
        string memory _symbol,
        string memory _name,
        uint8 _decimals
    )
        public
    {
        tokenSymbol = _symbol;
        tokenName = _name;
        tokenDecimals = _decimals;
        totalTokenSupply = 0;
    }



    function name() public view returns (string memory) {

        return tokenName;
    }

    function symbol() public view returns (string memory) {

        return tokenSymbol;
    }

    function decimals() public view returns (uint8) {

        return tokenDecimals;
    }

    function balanceOf(address _owner) public view returns (uint256) {

        return balances[_owner];
    }

    function totalSupply()
        public
        view
        returns (uint256)
    {

        return totalTokenSupply;
    }

    function allowance(
        address _owner,
        address _spender
    )
        public
        view
        returns (uint256)
    {

        return allowed[_owner][_spender];
    }

    function transfer(
        address _to,
        uint256 _value
    )
        public
        returns (bool success_)
    {


        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        returns (bool success_)
    {

        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }

    function approve(
        address _spender,
        uint256 _value
    )
        public
        returns (bool success_)
    {


        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }
}


pragma solidity ^0.5.0;


interface OrganizationInterface {


    function isOrganization(
        address _organization
    )
        external
        view
        returns (bool isOrganization_);


    function isWorker(address _worker) external view returns (bool isWorker_);


}


pragma solidity ^0.5.0;



contract Organized {



    OrganizationInterface public organization;



    modifier onlyOrganization()
    {

        require(
            organization.isOrganization(msg.sender),
            "Only the organization is allowed to call this method."
        );

        _;
    }

    modifier onlyWorker()
    {

        require(
            organization.isWorker(msg.sender),
            "Only whitelisted workers are allowed to call this method."
        );

        _;
    }



    constructor(OrganizationInterface _organization) public {
        require(
            address(_organization) != address(0),
            "Organization contract address must not be zero."
        );

        organization = _organization;
    }

}


pragma solidity ^0.5.0;







contract BrandedToken is Organized, EIP20Token {



    using SafeMath for uint256;



    event StakeRequested(
        bytes32 indexed _stakeRequestHash,
        address _staker,
        uint256 _stake,
        uint256 _nonce
    );

    event StakeRequestAccepted(
        bytes32 indexed _stakeRequestHash,
        address _staker,
        uint256 _stake
    );

    event StakeRequestRevoked(
        bytes32 indexed _stakeRequestHash,
        address _staker,
        uint256 _stake
    );

    event Redeemed(
        address _redeemer,
        uint256 _valueTokens
    );

    event StakeRequestRejected(
        bytes32 indexed _stakeRequestHash,
        address _staker,
        uint256 _stake
    );

    event SymbolSet(string _symbol);

    event NameSet(string _name);



    struct StakeRequest {
        address staker;
        uint256 stake;
        uint256 nonce;
    }



    EIP20Interface public valueToken;

    uint256 public conversionRate;

    uint8 public conversionRateDecimals;

    uint256 public nonce;

    bool public allRestrictionsLifted;

    bytes32 private constant EIP712_DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(address verifyingContract)"
    );

    bytes32 private constant BT_STAKE_REQUEST_TYPEHASH = keccak256(
        "StakeRequest(address staker,uint256 stake,uint256 nonce)"
    );

    bytes32 private DOMAIN_SEPARATOR = keccak256(
        abi.encode(
            EIP712_DOMAIN_TYPEHASH,
            address(this)
        )
    );

    mapping(address => bytes32) public stakeRequestHashes;

    mapping(bytes32 => StakeRequest) public stakeRequests;

    mapping(address => bool) private unrestricted;



    modifier onlyUnrestricted {

        require(
            allRestrictionsLifted || unrestricted[msg.sender],
            "Msg.sender is restricted."
        );
        _;
    }



    constructor(
        EIP20Interface _valueToken,
        string memory _symbol,
        string memory _name,
        uint8 _decimals,
        uint256 _conversionRate,
        uint8 _conversionRateDecimals,
        OrganizationInterface _organization
    )
        EIP20Token(_symbol, _name, _decimals)
        Organized(_organization)
        public
    {
        require(
            address(_valueToken) != address(0),
            "ValueToken is zero."
        );
        require(
            _conversionRate != 0,
            "ConversionRate is zero."
        );
        require(
            _conversionRateDecimals <= 5,
            "ConversionRateDecimals is greater than 5."
        );

        valueToken = _valueToken;
        conversionRate = _conversionRate;
        conversionRateDecimals = _conversionRateDecimals;
    }



    function requestStake(
        uint256 _stake,
        uint256 _mint
    )
        external
        returns (bytes32 stakeRequestHash_)
    {

        require(
            _mint == convertToBrandedTokens(_stake),
            "Mint is not equivalent to stake."
        );
        require(
            stakeRequestHashes[msg.sender] == bytes32(0),
            "Staker has a stake request hash."
        );

        StakeRequest memory stakeRequest = StakeRequest({
            staker: msg.sender,
            stake: _stake,
            nonce: nonce
        });
        stakeRequestHash_ = hash(stakeRequest);
        stakeRequestHashes[msg.sender] = stakeRequestHash_;
        stakeRequests[stakeRequestHash_] = stakeRequest;

        nonce += 1;

        emit StakeRequested(
            stakeRequestHash_,
            stakeRequest.staker,
            stakeRequest.stake,
            stakeRequest.nonce
        );

        require(
            valueToken.transferFrom(msg.sender, address(this), _stake),
            "ValueToken.transferFrom returned false."
        );
    }

    function acceptStakeRequest(
        bytes32 _stakeRequestHash,
        bytes32 _r,
        bytes32 _s,
        uint8 _v
    )
        external
        returns (bool success_)
    {

        require(
            stakeRequests[_stakeRequestHash].staker != address(0),
            "Stake request not found."
        );

        StakeRequest memory stakeRequest = stakeRequests[_stakeRequestHash];
        delete stakeRequestHashes[stakeRequest.staker];
        delete stakeRequests[_stakeRequestHash];

        require(
            verifySigner(stakeRequest, _r, _s, _v),
            "Signer is not a worker."
        );

        emit StakeRequestAccepted(
            _stakeRequestHash,
            stakeRequest.staker,
            stakeRequest.stake
        );

        uint256 mint = convertToBrandedTokens(stakeRequest.stake);
        balances[stakeRequest.staker] = balances[stakeRequest.staker]
            .add(mint);
        totalTokenSupply = totalTokenSupply.add(mint);

        emit Transfer(address(0), stakeRequest.staker, mint);

        return true;
    }

    function liftRestriction(
        address[] calldata _restrictionLifted
    )
        external
        onlyWorker
        returns (bool success_)
    {

        for (uint256 i = 0; i < _restrictionLifted.length; i++) {
            unrestricted[_restrictionLifted[i]] = true;
        }

        return true;
    }

    function isUnrestricted(address _actor)
        external
        view
        returns (bool isUnrestricted_)
    {

        return unrestricted[_actor];
    }

    function liftAllRestrictions()
        external
        onlyOrganization
        returns (bool success_)
    {

        allRestrictionsLifted = true;

        return true;
    }

    function revokeStakeRequest(
        bytes32 _stakeRequestHash
    )
        external
        returns (bool success_)
    {

        require(
            stakeRequests[_stakeRequestHash].staker == msg.sender,
            "Msg.sender is not staker."
        );

        uint256 stake = stakeRequests[_stakeRequestHash].stake;

        delete stakeRequestHashes[msg.sender];
        delete stakeRequests[_stakeRequestHash];

        emit StakeRequestRevoked(
            _stakeRequestHash,
            msg.sender,
            stake
        );

        require(
            valueToken.transfer(msg.sender, stake),
            "ValueToken.transfer returned false."
        );

        return true;
    }

    function redeem(
        uint256 _brandedTokens
    )
        external
        returns (bool success_)
    {

        balances[msg.sender] = balances[msg.sender].sub(_brandedTokens);
        totalTokenSupply = totalTokenSupply.sub(_brandedTokens);
        uint256 valueTokens = convertToValueTokens(_brandedTokens);

        emit Redeemed(msg.sender, valueTokens);

        emit Transfer(msg.sender, address(0), _brandedTokens);

        require(
            valueToken.transfer(msg.sender, valueTokens),
            "ValueToken.transfer returned false."
        );

        return true;
    }

    function rejectStakeRequest(
        bytes32 _stakeRequestHash
    )
        external
        onlyWorker
        returns (bool success_)
    {

        require(
            stakeRequests[_stakeRequestHash].staker != address(0),
            "Stake request not found."
        );

        StakeRequest memory stakeRequest = stakeRequests[_stakeRequestHash];

        delete stakeRequestHashes[stakeRequest.staker];
        delete stakeRequests[_stakeRequestHash];

        emit StakeRequestRejected(
            _stakeRequestHash,
            stakeRequest.staker,
            stakeRequest.stake
        );

        require(
            valueToken.transfer(stakeRequest.staker, stakeRequest.stake),
            "ValueToken.transfer returned false."
        );

        return true;
    }

    function setSymbol(
        string calldata _symbol
    )
        external
        onlyWorker
        returns (bool success_)
    {

        tokenSymbol = _symbol;

        emit SymbolSet(tokenSymbol);

        return true;
    }

    function setName(
        string calldata _name
    )
        external
        onlyWorker
        returns (bool success_)
    {

        tokenName = _name;

        emit NameSet(tokenName);

        return true;
    }



    function transfer(
        address _to,
        uint256 _value
    )
        public
        onlyUnrestricted
        returns (bool success_)
    {

        return super.transfer(_to, _value);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        onlyUnrestricted
        returns (bool success_)
    {

        return super.transferFrom(_from, _to, _value);
    }

    function convertToBrandedTokens(
        uint256 _valueTokens
    )
        public
        view
        returns (uint256)
    {

        return (
            _valueTokens
            .mul(conversionRate)
            .div(10 ** uint256(conversionRateDecimals))
        );
    }

    function convertToValueTokens(
        uint256 _brandedTokens
    )
        public
        view
        returns (uint256)
    {

        return (
            _brandedTokens
            .mul(10 ** uint256(conversionRateDecimals))
            .div(conversionRate)
        );
    }



    function hash(
        StakeRequest memory _stakeRequest
    )
        private
        pure
        returns (bytes32)
    {

        return keccak256(
            abi.encode(
                BT_STAKE_REQUEST_TYPEHASH,
                _stakeRequest.staker,
                _stakeRequest.stake,
                _stakeRequest.nonce
            )
        );
    }

    function verifySigner(
        StakeRequest memory _stakeRequest,
        bytes32 _r,
        bytes32 _s,
        uint8 _v
    )
        private
        view
        returns (bool)
    {

        bytes32 typedData = keccak256(
            abi.encodePacked(
                byte(0x19), // the initial 0x19 byte
                byte(0x01), // the version byte for structured data
                DOMAIN_SEPARATOR,
                hash(_stakeRequest)
            )
        );

        return organization.isWorker(ecrecover(typedData, _v, _r, _s));
    }
}


pragma solidity ^0.5.0;






contract GatewayComposer {



    struct StakeRequest {
        uint256 stakeVT;
        address gateway;
        address beneficiary;
        uint256 gasPrice;
        uint256 gasLimit;
        uint256 nonce;
    }



    address public owner;

    EIP20Interface public valueToken;

    BrandedToken public brandedToken;

    mapping (bytes32 => StakeRequest) public stakeRequests;

    bool private mutexAcquired;



    modifier onlyOwner() {

        require(
            owner == msg.sender,
            "Only owner can call the function."
        );
        _;
    }

    modifier mutex() {

        require(
            !mutexAcquired,
            "Mutex is already acquired."
        );
        mutexAcquired = true;
        _;
        mutexAcquired = false;
    }



    constructor(
        address _owner,
        EIP20Interface _valueToken,
        BrandedToken _brandedToken
    )
        public
    {
        require(
            _owner != address(0),
            "Owner address is zero."
        );
        require(
            address(_valueToken) != address(0),
            "ValueToken address is zero."
        );
        require(
            address(_brandedToken) != address(0),
            "BrandedToken address is zero."
        );
        require(
            _owner != address(_valueToken),
            "ValueToken address is same as owner address."
        );
        require(
            _owner != address(_brandedToken),
            "BrandedToken address is same as owner address."
        );
        require(
            address(_valueToken) == address(_brandedToken.valueToken()),
            "ValueToken should match BrandedToken.valueToken."
        );

        owner = _owner;
        valueToken = _valueToken;
        brandedToken = _brandedToken;
    }



    function requestStake(
        uint256 _stakeVT,
        uint256 _mintBT,
        address _gateway,
        address _beneficiary,
        uint256 _gasPrice,
        uint256 _gasLimit,
        uint256 _nonce
    )
        external
        onlyOwner
        mutex
        returns (bytes32 stakeRequestHash_)
    {

        require(
            _stakeVT > uint256(0),
            "Stake amount is zero."
        );
        require(
            _mintBT == brandedToken.convertToBrandedTokens(_stakeVT),
            "_mintBT should match converted _stakeVT."
        );
        require(
            _gateway != address(0),
            "Gateway address is zero."
        );
        require(
            owner != _gateway,
            "Gateway address is same as owner address."
        );
        require(
            _beneficiary != address(0),
            "Beneficiary address is zero."
        );
        require(
            valueToken.transferFrom(msg.sender, address(this), _stakeVT),
            "ValueToken transferFrom returned false."
        );
        require(
            valueToken.approve(address(brandedToken), _stakeVT),
            "ValueToken approve returned false."
        );

        stakeRequestHash_ = brandedToken.requestStake(_stakeVT, _mintBT);

        stakeRequests[stakeRequestHash_] = StakeRequest({
            stakeVT: _stakeVT,
            gateway: _gateway,
            beneficiary: _beneficiary,
            gasPrice: _gasPrice,
            gasLimit: _gasLimit,
            nonce: _nonce
        });
    }

    function acceptStakeRequest(
        bytes32 _stakeRequestHash,
        bytes32 _r,
        bytes32 _s,
        uint8 _v,
        bytes32 _hashLock
    )
        external
        returns (bytes32 messageHash_)
    {

        StakeRequest memory stakeRequest = stakeRequests[_stakeRequestHash];

        delete stakeRequests[_stakeRequestHash];

        require(
            stakeRequest.stakeVT > uint256(0),
            "Stake request not found."
        );

        uint256 bounty = GatewayInterface(stakeRequest.gateway).bounty();
        require(
            valueToken.transferFrom(msg.sender, address(this), bounty),
            "ValueToken transferFrom returned false."
        );
        require(
            valueToken.approve(stakeRequest.gateway, bounty),
            "ValueToken approve returned false."
        );

        require(
            brandedToken.acceptStakeRequest(
                _stakeRequestHash,
                _r,
                _s,
                _v
            ),
            "BrandedToken acceptStakeRequest returned false."
        );

        uint256 mintBT = brandedToken.convertToBrandedTokens(
            stakeRequest.stakeVT
        );

        require(
            brandedToken.approve(stakeRequest.gateway, mintBT),
            "BrandedToken approve returned false."
        );

        messageHash_ = GatewayInterface(stakeRequest.gateway).stake(
            mintBT,
            stakeRequest.beneficiary,
            stakeRequest.gasPrice,
            stakeRequest.gasLimit,
            stakeRequest.nonce,
            _hashLock
        );
    }

    function revokeStakeRequest(
        bytes32 _stakeRequestHash
    )
        external
        onlyOwner
        returns (bool success_)
    {

        StakeRequest memory stakeRequest = stakeRequests[_stakeRequestHash];

        delete stakeRequests[_stakeRequestHash];

        require(
            stakeRequest.stakeVT > uint256(0),
            "Stake request not found."
        );
        require(
            brandedToken.revokeStakeRequest(_stakeRequestHash),
            "BrandedToken revokeStakeRequest returned false."
        );
        require(
            valueToken.transfer(owner, stakeRequest.stakeVT),
            "ValueToken transfer returned false."
        );

        success_ = true;
    }

    function transferToken(
        EIP20Interface _token,
        address _to,
        uint256 _value
    )
        external
        onlyOwner
        returns (bool success_)
    {

        require(
            address(_token) != address(0),
            "EIP20 token address is zero."
        );
        require(
            _token.transfer(_to, _value),
            "EIP20Token transfer returned false."
        );

        success_ = true;
    }

    function approveToken(
        EIP20Interface _token,
        address _spender,
        uint256 _value
    )
        external
        onlyOwner
        returns (bool success_)
    {

        require(
            address(_token) != address(0),
            "EIP20 token address is zero."
        );
        require(
            _token.approve(_spender, _value),
            "EIP20token approve returned false."
        );

        success_ = true;
    }

    function destroy()
        external
        onlyOwner
    {

        require(
            valueToken.balanceOf(address(this)) == 0,
            "ValueToken balance should be 0."
        );
        require(
            brandedToken.balanceOf(address(this)) == 0,
            "BrandedToken balance should be 0."
        );
        require(
            brandedToken.stakeRequestHashes(address(this)) == bytes32(0),
            "In progress stake requests are present."
        );

        selfdestruct(msg.sender);
    }

    function revertStake(
        address _gateway,
        uint256 _penalty,
        bytes32 _messageHash
    )
        external
        onlyOwner
        returns (bool success_)
    {

        require(
            _gateway != address(0),
            "Gateway address is zero."
        );
        require(
            owner != _gateway,
            "Gateway address is same as owner address."
        );
        require(
            valueToken.transferFrom(msg.sender, address(this), _penalty),
            "ValueToken transferFrom returned false."
        );
        require(
            valueToken.approve(_gateway, _penalty),
            "ValueToken approve returned false."
        );

        GatewayInterface(_gateway).revertStake(_messageHash);

        return true;
    }
}