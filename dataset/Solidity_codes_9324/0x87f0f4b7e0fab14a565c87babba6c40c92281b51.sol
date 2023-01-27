




pragma solidity ^0.8.0;

library ECDSA {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract IERC20Token is IERC20 {
    function upgrade(uint256 value) public virtual;
}

interface IHermesContract {

    enum Status { Active, Paused, Punishment, Closed }
    function initialize(address _token, address _operator, uint16 _hermesFee, uint256 _minStake, uint256 _maxStake, address payable _routerAddress) external;

    function openChannel(address _party, uint256 _amountToLend) external;

    function getOperator() external view returns (address);

    function getStake() external view returns (uint256);

    function getStatus() external view returns (Status);

}


contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == msg.sender || _owner == address(0x0), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}


contract FundsRecovery is Ownable, ReentrancyGuard {

    address payable internal fundsDestination;
    IERC20Token public token;

    event DestinationChanged(address indexed previousDestination, address indexed newDestination);

    function setFundsDestination(address payable _newDestination) public virtual onlyOwner {

        require(_newDestination != address(0));
        emit DestinationChanged(fundsDestination, _newDestination);
        fundsDestination = _newDestination;
    }

    function getFundsDestination() public view returns (address) {

        return fundsDestination;
    }

    function claimEthers() public nonReentrant {

        require(fundsDestination != address(0));
        fundsDestination.transfer(address(this).balance);
    }

    function claimTokens(address _token) public nonReentrant {

        require(fundsDestination != address(0));
        require(_token != address(token), "native token funds can't be recovered");
        uint256 _amount = IERC20Token(_token).balanceOf(address(this));
        IERC20Token(_token).transfer(fundsDestination, _amount);
    }
}

contract Utils {

    function getChainID() internal view returns (uint256) {

        uint256 chainID;
        assembly {
            chainID := chainid()
        }
        return chainID;
    }

    function max(uint a, uint b) internal pure returns (uint) {

        return a > b ? a : b;
    }

    function min(uint a, uint b) internal pure returns (uint) {

        return a < b ? a : b;
    }

    function round(uint a, uint m) internal pure returns (uint ) {

        return ((a + m - 1) / m) * m;
    }
}



interface Channel {

    function initialize(address _token, address _dex, address _identityHash, address _hermesId, uint256 _fee) external;

}

contract Registry is FundsRecovery, Utils {

    using ECDSA for bytes32;

    uint256 public lastNonce;
    address payable public dex;     // Any uniswap v2 compatible DEX router address
    uint256 public minimalHermesStake;
    Registry public parentRegistry; // If there is parent registry, we will check for

    struct Implementation {
        address channelImplAddress;
        address hermesImplAddress;
    }
    Implementation[] internal implementations;

    struct Hermes {
        address operator;   // hermes operator who will sign promises
        uint256 implVer;    // version of hermes implementation smart contract
        function() external view returns(uint256) stake;
        bytes url;          // hermes service URL
    }
    mapping(address => Hermes) private hermeses;

    mapping(address => address) private identities;   // key: identity, value: beneficiary wallet address

    event RegisteredIdentity(address indexed identity, address beneficiary);
    event RegisteredHermes(address indexed hermesId, address hermesOperator, bytes ur);
    event HermesURLUpdated(address indexed hermesId, bytes newURL);
    event ConsumerChannelCreated(address indexed identity, address indexed hermesId, address channelAddress);
    event BeneficiaryChanged(address indexed identity, address newBeneficiary);
    event MinimalHermesStakeChanged(uint256 newMinimalStake);

    receive() external payable {
        revert("Registry: Rejecting tx with ethers sent");
    }

    function initialize(address _tokenAddress, address payable _dexAddress, uint256 _minimalHermesStake, address _channelImplementation, address _hermesImplementation, address payable _parentRegistry) public onlyOwner {

        require(!isInitialized(), "Registry: is already initialized");

        minimalHermesStake = _minimalHermesStake;

        require(_tokenAddress != address(0));
        token = IERC20Token(_tokenAddress);

        require(_dexAddress != address(0));
        dex = _dexAddress;

        setImplementations(_channelImplementation, _hermesImplementation);

        transferOwnership(msg.sender);

        parentRegistry = Registry(_parentRegistry);
    }

    function isInitialized() public view returns (bool) {

        return address(token) != address(0);
    }

    function registerIdentity(address _hermesId, uint256 _stakeAmount, uint256 _transactorFee, address _beneficiary, bytes memory _signature) public {

        require(isActiveHermes(_hermesId), "Registry: provided hermes have to be active");

        address _identity = keccak256(abi.encodePacked(getChainID(), address(this), _hermesId, _stakeAmount, _transactorFee, _beneficiary)).recover(_signature);
        require(_identity != address(0), "Registry: wrong identity signature");

        uint256 _totalFee = _stakeAmount + _transactorFee;
        require(_totalFee <= token.balanceOf(getChannelAddress(_identity, _hermesId)), "Registry: not enought funds in channel to cover fees");

        _openChannel(_identity, _hermesId, _beneficiary, _totalFee);

        if (_stakeAmount > 0) {
            IHermesContract(_hermesId).openChannel(_identity, _stakeAmount);
        }

        if (_transactorFee > 0) {
            token.transfer(msg.sender, _transactorFee);
        }
    }

    function openConsumerChannel(address _hermesId, uint256 _transactorFee, bytes memory _signature) public {

        require(isActiveHermes(_hermesId), "Registry: provided hermes have to be active");

        address _identity = keccak256(abi.encodePacked(getChainID(), address(this), _hermesId, _transactorFee)).recover(_signature);
        require(_identity != address(0), "Registry: wrong channel openinig signature");

        require(_transactorFee <= token.balanceOf(getChannelAddress(_identity, _hermesId)), "Registry: not enought funds in channel to cover fees");

        _openChannel(_identity, _hermesId, address(0), _transactorFee);
    }

    function openConsumerChannel(address _identity, address _hermesId) public {

        require(isActiveHermes(_hermesId), "Registry: provided hermes have to be active");
        require(!isChannelOpened(_identity, _hermesId), "Registry: such consumer channel is already opened");

        _openChannel(_identity, _hermesId, address(0), 0);
    }

    function _openChannel(address _identity, address _hermesId, address _beneficiary, uint256 _fee) internal returns (address) {

        bytes32 _salt = keccak256(abi.encodePacked(_identity, _hermesId));
        bytes memory _code = getProxyCode(getChannelImplementation(hermeses[_hermesId].implVer));
        Channel _channel = Channel(deployMiniProxy(uint256(_salt), _code));
        _channel.initialize(address(token), dex, _identity, _hermesId, _fee);

        emit ConsumerChannelCreated(_identity, _hermesId, address(_channel));

        if (_beneficiary == address(0)) {
            _beneficiary = address(_channel);
        }

        if (!isRegistered(_identity)) {
            identities[_identity] = _beneficiary;
            emit RegisteredIdentity(_identity, _beneficiary);
        }

        return address(_channel);
    }

    function registerHermes(address _hermesOperator, uint256 _hermesStake, uint16 _hermesFee, uint256 _minChannelStake, uint256 _maxChannelStake, bytes memory _url) public {

        require(isInitialized(), "Registry: only initialized registry can register hermeses");
        require(_hermesOperator != address(0), "Registry: hermes operator can't be zero address");
        require(_hermesStake >= minimalHermesStake, "Registry: hermes have to stake at least minimal stake amount");

        address _hermesId = getHermesAddress(_hermesOperator);
        require(!isHermes(_hermesId), "Registry: hermes already registered");

        IHermesContract _hermes = IHermesContract(deployMiniProxy(uint256(uint160(_hermesOperator)), getProxyCode(getHermesImplementation())));

        token.transferFrom(msg.sender, address(_hermes), _hermesStake);

        _hermes.initialize(address(token), _hermesOperator, _hermesFee, _minChannelStake, _maxChannelStake, dex);

        hermeses[_hermesId] = Hermes(_hermesOperator, getLastImplVer(), _hermes.getStake, _url);

        token.approve(_hermesId, type(uint256).max);

        emit RegisteredHermes(_hermesId, _hermesOperator, _url);
    }

    function getChannelAddress(address _identity, address _hermesId) public view returns (address) {

        bytes32 _code = keccak256(getProxyCode(getChannelImplementation(hermeses[_hermesId].implVer)));
        bytes32 _salt = keccak256(abi.encodePacked(_identity, _hermesId));
        return getCreate2Address(_salt, _code);
    }

    function getHermes(address _hermesId) public view returns (Hermes memory) {

        return isHermes(_hermesId) || !hasParentRegistry() ? hermeses[_hermesId] : parentRegistry.getHermes(_hermesId);
    }

    function getHermesAddress(address _hermesOperator) public view returns (address) {

        bytes32 _code = keccak256(getProxyCode(getHermesImplementation()));
        return getCreate2Address(bytes32(uint256(uint160(_hermesOperator))), _code);
    }

    function getHermesAddress(address _hermesOperator, uint256 _implVer) public view returns (address) {

        bytes32 _code = keccak256(getProxyCode(getHermesImplementation(_implVer)));
        return getCreate2Address(bytes32(uint256(uint160(_hermesOperator))), _code);
    }

    function getHermesURL(address _hermesId) public view returns (bytes memory) {

        return hermeses[_hermesId].url;
    }

    function updateHermesURL(address _hermesId, bytes memory _url, bytes memory _signature) public {

        require(isActiveHermes(_hermesId), "Registry: provided hermes has to be active");

        address _operator = keccak256(abi.encodePacked(address(this), _hermesId, _url, lastNonce++)).recover(_signature);
        require(_operator == hermeses[_hermesId].operator, "wrong signature");

        hermeses[_hermesId].url = _url;

        emit HermesURLUpdated(_hermesId, _url);
    }

    function getCreate2Address(bytes32 _salt, bytes32 _code) internal view returns (address) {

        return address(uint160(uint256(keccak256(abi.encodePacked(
            bytes1(0xff),
            address(this),
            bytes32(_salt),
            bytes32(_code)
        )))));
    }

    function getProxyCode(address _implementation) public pure returns (bytes memory) {

        bytes memory _code = hex"3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe5af43d82803e903d91602b57fd5bf3";

        bytes20 _targetBytes = bytes20(_implementation);
        for (uint8 i = 0; i < 20; i++) {
            _code[20 + i] = _targetBytes[i];
        }

        return _code;
    }

    function deployMiniProxy(uint256 _salt, bytes memory _code) internal returns (address payable) {

        address payable _addr;

        assembly {
            _addr := create2(0, add(_code, 0x20), mload(_code), _salt)
            if iszero(extcodesize(_addr)) {
                revert(0, 0)
            }
        }

        return _addr;
    }

    function getBeneficiary(address _identity) public view returns (address) {

        if (hasParentRegistry())
            return parentRegistry.getBeneficiary(_identity);

        return identities[_identity];
    }

    function setBeneficiary(address _identity, address _newBeneficiary, bytes memory _signature) public {

        require(_newBeneficiary != address(0), "Registry: beneficiary can't be zero address");

        if (hasParentRegistry()) {
            parentRegistry.setBeneficiary(_identity, _newBeneficiary, _signature);
        } else {
            lastNonce = lastNonce + 1;

            address _rootRegistry = hasParentRegistry() ? address(parentRegistry) : address(this);
            address _signer = keccak256(abi.encodePacked(getChainID(), _rootRegistry, _identity, _newBeneficiary, lastNonce)).recover(_signature);
            require(_signer == _identity, "Registry: have to be signed by identity owner");

            identities[_identity] = _newBeneficiary;

            emit BeneficiaryChanged(_identity, _newBeneficiary);
        }
    }

    function setMinimalHermesStake(uint256 _newMinimalStake) public onlyOwner {

        require(isInitialized(), "Registry: only initialized registry can set new minimal hermes stake");
        minimalHermesStake = _newMinimalStake;
        emit MinimalHermesStakeChanged(_newMinimalStake);
    }


    function getChannelImplementation() public view returns (address) {

        return implementations[getLastImplVer()].channelImplAddress;
    }

    function getChannelImplementation(uint256 _implVer) public view returns (address) {

        return implementations[_implVer].channelImplAddress;
    }

    function getHermesImplementation() public view returns (address) {

        return implementations[getLastImplVer()].hermesImplAddress;
    }

    function getHermesImplementation(uint256 _implVer) public view returns (address) {

        return implementations[_implVer].hermesImplAddress;
    }

    function setImplementations(address _newChannelImplAddress, address _newHermesImplAddress) public onlyOwner {

        require(isInitialized(), "Registry: only initialized registry can set new implementations");
        require(isSmartContract(_newChannelImplAddress) && isSmartContract(_newHermesImplAddress), "Registry: implementations have to be smart contracts");
        implementations.push(Implementation(_newChannelImplAddress, _newHermesImplAddress));
    }

    function getLastImplVer() public view returns (uint256) {

        return implementations.length-1;
    }


    function isSmartContract(address _addr) internal view returns (bool) {

        uint _codeLength;

        assembly {
            _codeLength := extcodesize(_addr)
        }

        return _codeLength != 0;
    }

    function hasParentRegistry() public view returns (bool) {

        return address(parentRegistry) != address(0);
    }

    function isRegistered(address _identity) public view returns (bool) {

        if (hasParentRegistry())
            return parentRegistry.isRegistered(_identity);

        return identities[_identity] != address(0);
    }

    function isHermes(address _hermesId) public view returns (bool) {

        address _hermesOperator = hermeses[_hermesId].operator;
        uint256 _implVer = hermeses[_hermesId].implVer;
        address _addr = getHermesAddress(_hermesOperator, _implVer);
        if (_addr != _hermesId)
            return false; // hermesId should be same as generated address

        return isSmartContract(_addr) || parentRegistry.isHermes(_hermesId);
    }

    function isActiveHermes(address _hermesId) internal view returns (bool) {

        require(isHermes(_hermesId), "Registry: hermes have to be registered");

        IHermesContract.Status status = IHermesContract(_hermesId).getStatus();
        return status == IHermesContract.Status.Active;
    }

    function isChannelOpened(address _identity, address _hermesId) public view returns (bool) {

        return isSmartContract(getChannelAddress(_identity, _hermesId)) || isSmartContract(parentRegistry.getChannelAddress(_identity, _hermesId));
    }

    function transferCollectedFeeTo(address _beneficiary) public onlyOwner{

        uint256 _collectedFee = token.balanceOf(address(this));
        require(_collectedFee > 0, "collected fee cannot be less than zero");
        token.transfer(_beneficiary, _collectedFee);
    }
}