pragma solidity ^0.7.0;

abstract contract LockRequestable {

    uint256 public lockRequestCount;

    constructor() {
        lockRequestCount = 0;
    }

    function generatePreLockId() internal returns (bytes32 preLockId, uint256 lockRequestIdx) {
        lockRequestIdx = ++lockRequestCount;
        preLockId = keccak256(
          abi.encodePacked(
            blockhash(block.number - 1),
            address(this),
            lockRequestIdx
          )
        );
    }
}// UNLICENSED
pragma solidity ^0.7.0;


abstract contract CustodianUpgradeable is LockRequestable {

    struct CustodianChangeRequest {
        address proposedNew;
    }

    address public custodian;

    mapping (bytes32 => CustodianChangeRequest) public custodianChangeReqs;

    constructor(
        address _custodian
    )
      LockRequestable()
    {
        custodian = _custodian;
    }

    modifier onlyCustodian {
        require(msg.sender == custodian, "unauthorized");
        _;
    }


    function requestCustodianChange(address _proposedCustodian) external returns (bytes32 lockId) {
        require(_proposedCustodian != address(0), "zero address");

        (bytes32 preLockId, uint256 lockRequestIdx) = generatePreLockId();
        lockId = keccak256(
            abi.encodePacked(
                preLockId,
                this.requestCustodianChange.selector,
                _proposedCustodian
            )
        );

        custodianChangeReqs[lockId] = CustodianChangeRequest({
            proposedNew: _proposedCustodian
        });

        emit CustodianChangeRequested(lockId, msg.sender, _proposedCustodian, lockRequestIdx);
    }

    function confirmCustodianChange(bytes32 _lockId) external onlyCustodian {
        custodian = getCustodianChangeReq(_lockId);

        delete custodianChangeReqs[_lockId];

        emit CustodianChangeConfirmed(_lockId, custodian);
    }

    function getCustodianChangeReq(bytes32 _lockId) private view returns (address _proposedNew) {
        CustodianChangeRequest storage changeRequest = custodianChangeReqs[_lockId];

        require(changeRequest.proposedNew != address(0), "no such lockId");

        return changeRequest.proposedNew;
    }

    event CustodianChangeRequested(
        bytes32 _lockId,
        address _msgSender,
        address _proposedCustodian,
        uint256 _lockRequestIdx
    );

    event CustodianChangeConfirmed(bytes32 _lockId, address _newCustodian);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface EIP2612Interface {

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;


    function nonces(address owner) external view returns (uint256);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

}// UNLICENSED
pragma solidity ^0.7.0;

interface ERC20Interface {






  function totalSupply() external view returns (uint256);


  function balanceOf(address _owner) external view returns (uint256 balance);


  function transfer(address _to, uint256 _value) external returns (bool success);


  function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);


  function approve(address _spender, uint256 _value) external returns (bool success);


  function allowance(address _owner, address _spender) external view returns (uint256 remaining);


  event Transfer(address indexed _from, address indexed _to, uint256 _value);

  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}// UNLICENSED
pragma solidity ^0.7.0;


abstract contract ERC20ImplUpgradeable is CustodianUpgradeable {

    struct ImplChangeRequest {
        address proposedNew;
    }

    ERC20Impl public erc20Impl;

    mapping (bytes32 => ImplChangeRequest) public implChangeReqs;

    constructor(address _custodian) CustodianUpgradeable(_custodian) {
        erc20Impl = ERC20Impl(0x0);
    }

    modifier onlyImpl {
        require(msg.sender == address(erc20Impl), "unauthorized");
        _;
    }

    function requestImplChange(address _proposedImpl) external returns (bytes32 lockId) {
        require(_proposedImpl != address(0), "zero address");

        (bytes32 preLockId, uint256 lockRequestIdx) = generatePreLockId();
        lockId = keccak256(
            abi.encodePacked(
                preLockId,
                this.requestImplChange.selector,
                _proposedImpl
            )
        );

        implChangeReqs[lockId] = ImplChangeRequest({
            proposedNew: _proposedImpl
        });

        emit ImplChangeRequested(lockId, msg.sender, _proposedImpl, lockRequestIdx);
    }

    function confirmImplChange(bytes32 _lockId) external onlyCustodian {
        erc20Impl = getImplChangeReq(_lockId);

        delete implChangeReqs[_lockId];

        emit ImplChangeConfirmed(_lockId, address(erc20Impl));
    }

    function getImplChangeReq(bytes32 _lockId) private view returns (ERC20Impl _proposedNew) {
        ImplChangeRequest storage changeRequest = implChangeReqs[_lockId];

        require(changeRequest.proposedNew != address(0), "no such lockId");

        return ERC20Impl(changeRequest.proposedNew);
    }

    event ImplChangeRequested(
        bytes32 _lockId,
        address _msgSender,
        address _proposedImpl,
        uint256 _lockRequestIdx
    );

    event ImplChangeConfirmed(bytes32 _lockId, address _newImpl);
}// UNLICENSED
pragma solidity ^0.7.0;


contract ERC20Proxy is ERC20Interface, ERC20ImplUpgradeable, EIP2612Interface {


    string public name; // TODO: use `constant` for mainnet

    string public symbol; // TODO: use `constant` for mainnet

    uint8 immutable public decimals; // TODO: use `constant` (18) for mainnet

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _custodian
    )
        ERC20ImplUpgradeable(_custodian)
    {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function totalSupply() external override view returns (uint256) {

        return erc20Impl.totalSupply();
    }

    function balanceOf(address _owner) external override view returns (uint256 balance) {

        return erc20Impl.balanceOf(_owner);
    }

    function emitTransfer(address _from, address _to, uint256 _value) external onlyImpl {

        emit Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) external override returns (bool success) {

        return erc20Impl.transferWithSender(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) external override returns (bool success) {

        return erc20Impl.transferFromWithSender(msg.sender, _from, _to, _value);
    }

    function emitApproval(address _owner, address _spender, uint256 _value) external onlyImpl {

        emit Approval(_owner, _spender, _value);
    }

    function approve(address _spender, uint256 _value) external override returns (bool success) {

        return erc20Impl.approveWithSender(msg.sender, _spender, _value);
    }

    function increaseApproval(address _spender, uint256 _addedValue) external returns (bool success) {

        return erc20Impl.increaseApprovalWithSender(msg.sender, _spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) external returns (bool success) {

        return erc20Impl.decreaseApprovalWithSender(msg.sender, _spender, _subtractedValue);
    }

    function allowance(address _owner, address _spender) external override view returns (uint256 remaining) {

        return erc20Impl.allowance(_owner, _spender);
    }

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external override {

      erc20Impl.permit(owner, spender, value, deadline, v, r, s);
    }
    function nonces(address owner) external override view returns (uint256) {

      return erc20Impl.nonces(owner);
    }
    function DOMAIN_SEPARATOR() external override view returns (bytes32) {

      return erc20Impl.DOMAIN_SEPARATOR();
    }

    function executeCallWithData(address contractAddress, bytes calldata callData) external {

        address implAddr = address(erc20Impl);
        require(msg.sender == implAddr, "unauthorized");
        require(contractAddress != implAddr, "disallowed");

        (bool success, bytes memory returnData) = contractAddress.call(callData);
        if (success) {
            emit CallWithDataSuccess(contractAddress, callData, returnData);
        } else {
            emit CallWithDataFailure(contractAddress, callData, returnData);
        }
    }

    event CallWithDataSuccess(address contractAddress, bytes callData, bytes returnData);
    event CallWithDataFailure(address contractAddress, bytes callData, bytes returnData);
}// UNLICENSED
pragma solidity ^0.7.0;


contract ERC20Store is ERC20ImplUpgradeable {


    uint256 public totalSupply;

    mapping (address => uint256) public balances;

    mapping (address => mapping (address => uint256)) public allowed;

    mapping (address => uint256) public nonces;

    constructor(address _custodian) ERC20ImplUpgradeable(_custodian) {
        totalSupply = 0;
    }



    function setAllowance(
        address _owner,
        address _spender,
        uint256 _value
    )
        external
        onlyImpl
    {

        allowed[_owner][_spender] = _value;
    }

    function setBalance(
        address _owner,
        uint256 _newBalance
    )
        external
        onlyImpl
    {

        balances[_owner] = _newBalance;
    }

    function addBalance(
        address _owner,
        uint256 _balanceIncrease
    )
        external
        onlyImpl
    {

        balances[_owner] = balances[_owner] + _balanceIncrease;
    }

    function setTotalSupplyAndAddBalance(
        uint256 _newTotalSupply,
        address _owner,
        uint256 _balanceIncrease
    )
        external
        onlyImpl
    {

        totalSupply = _newTotalSupply;
        balances[_owner] = balances[_owner] + _balanceIncrease;
    }

    function setBalanceAndDecreaseTotalSupply(
        address _owner,
        uint256 _newBalance,
        uint256 _supplyDecrease
    )
        external
        onlyImpl
    {

        balances[_owner] = _newBalance;
        totalSupply = totalSupply - _supplyDecrease;
    }

    function setBalanceAndAddBalance(
        address _ownerToSet,
        uint256 _newBalance,
        address _ownerToAdd,
        uint256 _balanceIncrease
    )
        external
        onlyImpl
    {

        balances[_ownerToSet] = _newBalance;
        balances[_ownerToAdd] = balances[_ownerToAdd] + _balanceIncrease;
    }

    function setBalanceAndAllowanceAndAddBalance(
        address _ownerToSet,
        uint256 _newBalance,
        address _spenderToSet,
        uint256 _newAllowance,
        address _ownerToAdd,
        uint256 _balanceIncrease
    )
        external
        onlyImpl
    {

        balances[_ownerToSet] = _newBalance;
        allowed[_ownerToSet][_spenderToSet] = _newAllowance;
        balances[_ownerToAdd] = balances[_ownerToAdd] + _balanceIncrease;
    }

    function balanceAndAllowed(
        address _owner,
        address _spender
    )
        external
        view
        returns (uint256 ownerBalance, uint256 spenderAllowance)
    {

        ownerBalance = balances[_owner];
        spenderAllowance = allowed[_owner][_spender];
    }

    function getNonceAndIncrement(
        address _owner
    )
        external
        onlyImpl
        returns (uint256 current)
    {

        current = nonces[_owner];
        nonces[_owner] = current + 1;
    }
}// UNLICENSED
pragma solidity ^0.7.0;


contract ERC20Impl is CustodianUpgradeable {


    struct PendingPrint {
        address receiver;
        uint256 value;
        bytes32 merkleRoot;
    }

    ERC20Proxy immutable public erc20Proxy;

    ERC20Store immutable public erc20Store;

    address immutable public implOwner;

    mapping (bytes32 => PendingPrint) public pendingPrintMap;

    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    bytes32 private immutable _PERMIT_TYPEHASH;


    constructor(
          address _erc20Proxy,
          address _erc20Store,
          address _custodian,
          address _implOwner
    )
        CustodianUpgradeable(_custodian)
    {
        erc20Proxy = ERC20Proxy(_erc20Proxy);
        erc20Store = ERC20Store(_erc20Store);
        implOwner = _implOwner;

        bytes32 hashedName = keccak256(bytes(ERC20Proxy(_erc20Proxy).name()));
        bytes32 hashedVersion = keccak256(bytes("1"));
        bytes32 typeHash = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"); 
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = _getChainId();
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion, _erc20Proxy);
        _TYPE_HASH = typeHash;

        _PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    }

    modifier onlyProxy {

        require(msg.sender == address(erc20Proxy), "unauthorized");
        _;
    }

    modifier onlyImplOwner {

        require(msg.sender == implOwner, "unauthorized");
        _;
    }

    function _approve(
        address _owner,
        address _spender,
        uint256 _amount
    )
        private
    {

        require(_spender != address(0), "zero address"); // disallow unspendable approvals
        erc20Store.setAllowance(_owner, _spender, _amount);
        erc20Proxy.emitApproval(_owner, _spender, _amount);
    }

    function approveWithSender(
        address _sender,
        address _spender,
        uint256 _value
    )
        external
        onlyProxy
        returns (bool success)
    {

        _approve(_sender, _spender, _value);
        return true;
    }

    function increaseApprovalWithSender(
        address _sender,
        address _spender,
        uint256 _addedValue
    )
        external
        onlyProxy
        returns (bool success)
    {

        require(_spender != address(0), "zero address"); // disallow unspendable approvals
        uint256 currentAllowance = erc20Store.allowed(_sender, _spender);
        uint256 newAllowance = currentAllowance + _addedValue;

        require(newAllowance >= currentAllowance, "overflow");

        erc20Store.setAllowance(_sender, _spender, newAllowance);
        erc20Proxy.emitApproval(_sender, _spender, newAllowance);
        return true;
    }

    function decreaseApprovalWithSender(
        address _sender,
        address _spender,
        uint256 _subtractedValue
    )
        external
        onlyProxy
        returns (bool success)
    {

        require(_spender != address(0), "zero address"); // disallow unspendable approvals
        uint256 currentAllowance = erc20Store.allowed(_sender, _spender);
        uint256 newAllowance = currentAllowance - _subtractedValue;

        require(newAllowance <= currentAllowance, "overflow");

        erc20Store.setAllowance(_sender, _spender, newAllowance);
        erc20Proxy.emitApproval(_sender, _spender, newAllowance);
        return true;
    }

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {

        require(owner != address(0x0), "zero address");
        require(block.timestamp <= deadline, "expired");

        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                erc20Store.getNonceAndIncrement(owner),
                deadline
            )
        );

        bytes32 hash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                _domainSeparatorV4(),
                structHash
            )
        );

        address signer = ecrecover(hash, v, r, s);
        require(signer == owner, "invalid signature");

        _approve(owner, spender, value);
    }
    function nonces(address owner) external view returns (uint256) {

      return erc20Store.nonces(owner);
    }
    function DOMAIN_SEPARATOR() external view returns (bytes32) {

      return _domainSeparatorV4();
    }

    function requestPrint(address _receiver, uint256 _value, bytes32 _merkleRoot) external returns (bytes32 lockId) {

        require(_receiver != address(0), "zero address");

        (bytes32 preLockId, uint256 lockRequestIdx) = generatePreLockId();
        lockId = keccak256(
            abi.encodePacked(
                preLockId,
                this.requestPrint.selector,
                _receiver,
                _value,
                _merkleRoot
            )
        );

        pendingPrintMap[lockId] = PendingPrint({
            receiver: _receiver,
            value: _value,
            merkleRoot: _merkleRoot
        });

        emit PrintingLocked(lockId, _receiver, _value, lockRequestIdx);
    }

    function _executePrint(address _receiver, uint256 _value, bytes32 _merkleRoot) private {

        uint256 supply = erc20Store.totalSupply();
        uint256 newSupply = supply + _value;
        if (newSupply >= supply) {
          erc20Store.setTotalSupplyAndAddBalance(newSupply, _receiver, _value);

          erc20Proxy.emitTransfer(address(0), _receiver, _value);
          emit AuditPrint(_merkleRoot);
        }
    }

    function executePrint(address _receiver, uint256 _value, bytes32 _merkleRoot) external onlyCustodian {

        _executePrint(_receiver, _value, _merkleRoot);
    }

    function confirmPrint(bytes32 _lockId) external onlyCustodian {

        PendingPrint storage print = pendingPrintMap[_lockId];

        address receiver = print.receiver;
        require (receiver != address(0), "no such lockId");
        uint256 value = print.value;
        bytes32 merkleRoot = print.merkleRoot;

        delete pendingPrintMap[_lockId];

        emit PrintingConfirmed(_lockId, receiver, value);
        _executePrint(receiver, value, merkleRoot);
    }

    function burn(uint256 _value, bytes32 _merkleRoot) external returns (bool success) {

        uint256 balanceOfSender = erc20Store.balances(msg.sender);
        require(_value <= balanceOfSender, "insufficient balance");

        erc20Store.setBalanceAndDecreaseTotalSupply(
            msg.sender,
            balanceOfSender - _value,
            _value
        );

        erc20Proxy.emitTransfer(msg.sender, address(0), _value);
        emit AuditBurn(_merkleRoot);

        return true;
    }

    function batchTransfer(address[] calldata _tos, uint256[] calldata _values) external returns (bool success) {

        require(_tos.length == _values.length, "inconsistent length");

        uint256 numTransfers = _tos.length;
        uint256 senderBalance = erc20Store.balances(msg.sender);

        for (uint256 i = 0; i < numTransfers; i++) {
          address to = _tos[i];
          require(to != address(0), "zero address");
          uint256 v = _values[i];
          require(senderBalance >= v, "insufficient balance");

          if (msg.sender != to) {
            senderBalance -= v;
            erc20Store.addBalance(to, v);
          }
          erc20Proxy.emitTransfer(msg.sender, to, v);
        }

        erc20Store.setBalance(msg.sender, senderBalance);

        return true;
    }

    function transferFromWithSender(
        address _sender,
        address _from,
        address _to,
        uint256 _value
    )
        external
        onlyProxy
        returns (bool success)
    {

        require(_to != address(0), "zero address"); // ensure burn is the cannonical transfer to 0x0

        (uint256 balanceOfFrom, uint256 senderAllowance) = erc20Store.balanceAndAllowed(_from, _sender);
        require(_value <= balanceOfFrom, "insufficient balance");
        require(_value <= senderAllowance, "insufficient allowance");

        erc20Store.setBalanceAndAllowanceAndAddBalance(
            _from, balanceOfFrom - _value,
            _sender, senderAllowance - _value,
            _to, _value
        );

        erc20Proxy.emitTransfer(_from, _to, _value);

        return true;
    }

    function transferWithSender(
        address _sender,
        address _to,
        uint256 _value
    )
        external
        onlyProxy
        returns (bool success)
    {

        require(_to != address(0), "zero address"); // ensure burn is the cannonical transfer to 0x0

        uint256 balanceOfSender = erc20Store.balances(_sender);
        require(_value <= balanceOfSender, "insufficient balance");

        erc20Store.setBalanceAndAddBalance(
            _sender, balanceOfSender - _value,
            _to, _value
        );

        erc20Proxy.emitTransfer(_sender, _to, _value);

        return true;
    }

    function totalSupply() external view returns (uint256) {

        return erc20Store.totalSupply();
    }

    function balanceOf(address _owner) external view returns (uint256 balance) {

        return erc20Store.balances(_owner);
    }

    function allowance(address _owner, address _spender) external view returns (uint256 remaining) {

        return erc20Store.allowed(_owner, _spender);
    }

    function executeCallInProxy(
        address contractAddress,
        bytes calldata callData
    ) external onlyImplOwner {

        erc20Proxy.executeCallWithData(contractAddress, callData);
    }

    function _domainSeparatorV4() private view returns (bytes32) {

        if (_getChainId() == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION, address(erc20Proxy));
        }
    }

    function _buildDomainSeparator(bytes32 typeHash, bytes32 name, bytes32 version, address verifyingContract) private view returns (bytes32) {

        return keccak256(
            abi.encode(
                typeHash,
                name,
                version,
                _getChainId(),
                verifyingContract
            )
        );
    }

    function _getChainId() private view returns (uint256 chainId) {

        assembly {
            chainId := chainid()
        }
    }

    event PrintingLocked(bytes32 _lockId, address _receiver, uint256 _value, uint256 _lockRequestIdx);
    event PrintingConfirmed(bytes32 _lockId, address _receiver, uint256 _value);

    event AuditBurn(bytes32 merkleRoot);
    event AuditPrint(bytes32 merkleRoot);
}// UNLICENSED
pragma solidity ^0.7.0;


contract PrintLimiter is LockRequestable {


    struct PendingCeilingRaise {
        uint256 raiseBy;
    }

    ERC20Impl immutable public erc20Impl;

    address immutable public custodian;

    address immutable public limitedPrinter;

    uint256 public totalSupplyCeiling;

    mapping (bytes32 => PendingCeilingRaise) public pendingRaiseMap;

    constructor(
        address _erc20Impl,
        address _custodian,
        address _limitedPrinter,
        uint256 _initialCeiling
    )
    {
        erc20Impl = ERC20Impl(_erc20Impl);
        custodian = _custodian;
        limitedPrinter = _limitedPrinter;
        totalSupplyCeiling = _initialCeiling;
    }

    modifier onlyCustodian {

        require(msg.sender == custodian, "unauthorized");
        _;
    }
    modifier onlyLimitedPrinter {

        require(msg.sender == limitedPrinter, "unauthorized");
        _;
    }

    function limitedPrint(address _receiver, uint256 _value, bytes32 _merkleRoot) external onlyLimitedPrinter {

        uint256 totalSupply = erc20Impl.totalSupply();
        uint256 newTotalSupply = totalSupply + _value;

        require(newTotalSupply >= totalSupply, "overflow");
        require(newTotalSupply <= totalSupplyCeiling, "ceiling exceeded");
        erc20Impl.executePrint(_receiver, _value, _merkleRoot);
    }

    function requestCeilingRaise(uint256 _raiseBy) external returns (bytes32 lockId) {

        require(_raiseBy != 0, "zero");

        (bytes32 preLockId, uint256 lockRequestIdx) = generatePreLockId();
        lockId = keccak256(
            abi.encodePacked(
                preLockId,
                this.requestCeilingRaise.selector,
                _raiseBy
            )
        );

        pendingRaiseMap[lockId] = PendingCeilingRaise({
            raiseBy: _raiseBy
        });

        emit CeilingRaiseLocked(lockId, _raiseBy, lockRequestIdx);
    }

    function confirmCeilingRaise(bytes32 _lockId) external onlyCustodian {

        PendingCeilingRaise storage pendingRaise = pendingRaiseMap[_lockId];

        uint256 raiseBy = pendingRaise.raiseBy;
        require(raiseBy != 0, "no such lockId");

        delete pendingRaiseMap[_lockId];

        uint256 newCeiling = totalSupplyCeiling + raiseBy;
        if (newCeiling >= totalSupplyCeiling) {
            totalSupplyCeiling = newCeiling;

            emit CeilingRaiseConfirmed(_lockId, raiseBy, newCeiling);
        }
    }

    function lowerCeiling(uint256 _lowerBy) external onlyLimitedPrinter {

        uint256 newCeiling = totalSupplyCeiling - _lowerBy;
        require(newCeiling <= totalSupplyCeiling, "overflow");
        totalSupplyCeiling = newCeiling;

        emit CeilingLowered(_lowerBy, newCeiling);
    }

    function confirmPrintProxy(bytes32 _lockId) external onlyCustodian {

        erc20Impl.confirmPrint(_lockId);
    }

    function confirmCustodianChangeProxy(bytes32 _lockId) external onlyCustodian {

        erc20Impl.confirmCustodianChange(_lockId);
    }

    event CeilingRaiseLocked(bytes32 _lockId, uint256 _raiseBy, uint256 _lockRequestIdx);
    event CeilingRaiseConfirmed(bytes32 _lockId, uint256 _raiseBy, uint256 _newCeiling);

    event CeilingLowered(uint256 _lowerBy, uint256 _newCeiling);
}// UNLICENSED
pragma solidity ^0.7.0;


contract Initializer {


  function initialize(
      ERC20Store _store,
      ERC20Proxy _proxy,
      ERC20Impl _impl,
      address _implChangeCustodian,
      address _printCustodian) external {


    _store.confirmImplChange(_store.requestImplChange(address(_impl)));
    _proxy.confirmImplChange(_proxy.requestImplChange(address(_impl)));

    _store.confirmCustodianChange(_store.requestCustodianChange(_implChangeCustodian));
    _proxy.confirmCustodianChange(_proxy.requestCustodianChange(_implChangeCustodian));

    _impl.confirmCustodianChange(_impl.requestCustodianChange(_printCustodian));
  }

}// UNLICENSED
pragma solidity ^0.7.0;


contract ERC20ImplPaused {



    ERC20Store immutable public erc20Store;

    constructor(
          address _erc20Store
    )
    {
        erc20Store = ERC20Store(_erc20Store);
    }

    function totalSupply() external view returns (uint256) {

        return erc20Store.totalSupply();
    }

    function balanceOf(address _owner) external view returns (uint256 balance) {

        return erc20Store.balances(_owner);
    }

    function allowance(address _owner, address _spender) external view returns (uint256 remaining) {

        return erc20Store.allowed(_owner, _spender);
    }
}