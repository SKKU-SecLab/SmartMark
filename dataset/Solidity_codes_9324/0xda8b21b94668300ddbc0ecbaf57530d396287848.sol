
pragma solidity ^0.5.0;

contract LocalCoinSwapEthereumEscrow {


    address public arbitrator;
    address public owner;
    address public relayer;
    uint32 public requestCancellationMinimumTime = 2 hours;
    uint256 public feesAvailableForWithdraw;


    uint8 constant INSTRUCTION_SELLER_CANNOT_CANCEL = 0x01;
    uint8 constant INSTRUCTION_BUYER_CANCEL = 0x02;
    uint8 constant INSTRUCTION_SELLER_CANCEL = 0x03;
    uint8 constant INSTRUCTION_SELLER_REQUEST_CANCEL = 0x04;
    uint8 constant INSTRUCTION_RELEASE = 0x05;
    uint8 constant INSTRUCTION_RESOLVE = 0x06;



    event Created(bytes32 indexed _tradeHash);
    event SellerCancelDisabled(bytes32 indexed _tradeHash);
    event SellerRequestedCancel(bytes32 indexed _tradeHash);
    event CancelledBySeller(bytes32 indexed _tradeHash);
    event CancelledByBuyer(bytes32 indexed _tradeHash);
    event Released(bytes32 indexed _tradeHash);
    event DisputeResolved(bytes32 indexed _tradeHash);

    struct Escrow {
        bool exists;
        uint32 sellerCanCancelAfter;
        uint128 totalGasFeesSpentByRelayer;
    }

    mapping (bytes32 => Escrow) public escrows;

    modifier onlyOwner() {

        require(msg.sender == owner, "Must be owner");
        _;
    }

    modifier onlyArbitrator() {

        require(msg.sender == arbitrator, "Must be arbitrator");
        _;
    }

    constructor(address initialAddress) public {
        owner = initialAddress;
        arbitrator = initialAddress;
        relayer = initialAddress;
    }

    function createEscrow(
        bytes16 _tradeID,
        address _seller,
        address _buyer,
        uint256 _value,
        uint16 _fee,
        uint32 _paymentWindowInSeconds,
        uint32 _expiry,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external payable {

        bytes32 _tradeHash = keccak256(abi.encodePacked(_tradeID, _seller, _buyer, _value, _fee));
        require(!escrows[_tradeHash].exists, "Trade already exists");
        bytes32 _invitationHash = keccak256(abi.encodePacked(
            _tradeHash,
            _paymentWindowInSeconds,
            _expiry
        ));
        require(recoverAddress(_invitationHash, _v, _r, _s) == relayer, "Must be relayer");
        require(block.timestamp < _expiry, "Signature has expired"); // solium-disable-line
        require(msg.value == _value && msg.value > 0, "Incorrect ether sent");
        uint32 _sellerCanCancelAfter = _paymentWindowInSeconds == 0
            ? 1
            : uint32(block.timestamp) + _paymentWindowInSeconds; // solium-disable-line
        escrows[_tradeHash] = Escrow(true, _sellerCanCancelAfter, 0);
        emit Created(_tradeHash);
    }

    uint16 constant GAS_doResolveDispute = 36100;
    function resolveDispute(
        bytes16 _tradeID,
        address payable _seller,
        address payable _buyer,
        uint256 _value,
        uint16 _fee,
        uint8 _v,
        bytes32 _r,
        bytes32 _s,
        uint8 _buyerPercent
    ) external onlyArbitrator {

        address _signature = recoverAddress(keccak256(abi.encodePacked(
            _tradeID,
            INSTRUCTION_RESOLVE
        )), _v, _r, _s);
        require(_signature == _buyer || _signature == _seller, "Must be buyer or seller");

        Escrow memory _escrow;
        bytes32 _tradeHash;
        (_escrow, _tradeHash) = getEscrowAndHash(_tradeID, _seller, _buyer, _value, _fee);
        require(_escrow.exists, "Escrow does not exist");
        require(_buyerPercent <= 100, "_buyerPercent must be 100 or lower");

        uint256 _totalFees = _escrow.totalGasFeesSpentByRelayer + (GAS_doResolveDispute * uint128(tx.gasprice));
        require(_value - _totalFees <= _value, "Overflow error"); // Prevent underflow
        feesAvailableForWithdraw += _totalFees; // Add the the pot for localcoinswap to withdraw

        delete escrows[_tradeHash];
        emit DisputeResolved(_tradeHash);
        if (_buyerPercent > 0) {
          uint256 _escrowFees = (_value * _fee / 10000);
          uint256 _buyerAmount = _value * _buyerPercent / 100 - _totalFees - _escrowFees;
          require(_buyerAmount <= _value, "Overflow error");
          feesAvailableForWithdraw += _escrowFees;
          _buyer.transfer(_buyerAmount);
        }
        if (_buyerPercent < 100) {
          _seller.transfer((_value - _totalFees) * (100 - _buyerPercent) / 100);
        }
    }

    function release(
        bytes16 _tradeID,
        address payable _seller,
        address payable _buyer,
        uint256 _value,
        uint16 _fee
    ) external returns (bool){

        require(msg.sender == _seller, "Must be seller");
        return doRelease(_tradeID, _seller, _buyer, _value, _fee, 0);
    }

    function disableSellerCancel(
        bytes16 _tradeID,
        address _seller,
        address _buyer,
        uint256 _value,
        uint16 _fee
    ) external returns (bool) {

        require(msg.sender == _buyer, "Must be buyer");
        return doDisableSellerCancel(_tradeID, _seller, _buyer, _value, _fee, 0);
    }

    function buyerCancel(
      bytes16 _tradeID,
      address payable _seller,
      address payable _buyer,
      uint256 _value,
      uint16 _fee
    ) external returns (bool) {

        require(msg.sender == _buyer, "Must be buyer");
        return doBuyerCancel(_tradeID, _seller, _buyer, _value, _fee, 0);
    }

    function sellerRequestCancel(
        bytes16 _tradeID,
        address _seller,
        address _buyer,
        uint256 _value,
        uint16 _fee
    ) external returns (bool) {

        require(msg.sender == _seller, "Must be seller");
        return doSellerRequestCancel(_tradeID, _seller, _buyer, _value, _fee, 0);
    }

    uint16 constant GAS_batchRelayBaseCost = 28500;
    function batchRelay(
        bytes16[] memory _tradeID,
        address payable[] memory _seller,
        address payable[] memory _buyer,
        uint256[] memory _value,
        uint16[] memory _fee,
        uint128[] memory _maximumGasPrice,
        uint8[] memory _v,
        bytes32[] memory _r,
        bytes32[] memory _s,
        uint8[] memory _instructionByte
    ) public returns (bool[] memory) {

        bool[] memory _results = new bool[](_tradeID.length);
        uint128 _additionalGas = uint128(msg.sender == relayer ? GAS_batchRelayBaseCost / _tradeID.length : 0);
        for (uint8 i = 0; i < _tradeID.length; i++) {
            _results[i] = relay(
                _tradeID[i],
                _seller[i],
                _buyer[i],
                _value[i],
                _fee[i],
                _maximumGasPrice[i],
                _v[i],
                _r[i],
                _s[i],
                _instructionByte[i],
                _additionalGas
            );
        }
        return _results;
    }

    function withdrawFees(address payable _to, uint256 _amount) external onlyOwner {

        require(_amount <= feesAvailableForWithdraw, "Amount is higher than amount available");
        feesAvailableForWithdraw -= _amount;
        _to.transfer(_amount);
    }

    function setArbitrator(address _newArbitrator) external onlyOwner {

        arbitrator = _newArbitrator;
    }

    function setOwner(address _newOwner) external onlyOwner {

        owner = _newOwner;
    }

    function setRelayer(address _newRelayer) external onlyOwner {

        relayer = _newRelayer;
    }

    function setRequestCancellationMinimumTime(
        uint32 _newRequestCancellationMinimumTime
    ) external onlyOwner {

        requestCancellationMinimumTime = _newRequestCancellationMinimumTime;
    }

    function transferToken(
        _Token _tokenContract,
        address _transferTo,
        uint256 _value
    ) external onlyOwner {

        _tokenContract.transfer(_transferTo, _value);
    }

    function transferTokenFrom(
        _Token _tokenContract,
        address _transferTo,
        address _transferFrom,
        uint256 _value
    ) external onlyOwner {

        _tokenContract.transferFrom(_transferTo, _transferFrom, _value);
    }

    function approveToken(
        _Token _tokenContract,
        address _spender,
        uint256 _value
    ) external onlyOwner {

        _tokenContract.approve(_spender, _value);
    }

    function relay(
        bytes16 _tradeID,
        address payable _seller,
        address payable _buyer,
        uint256 _value,
        uint16 _fee,
        uint128 _maximumGasPrice,
        uint8 _v,
        bytes32 _r,
        bytes32 _s,
        uint8 _instructionByte,
        uint128 _additionalGas
    ) private returns (bool) {

        address _relayedSender = getRelayedSender(
            _tradeID,
            _instructionByte,
            _maximumGasPrice,
            _v,
            _r,
            _s
        );
        if (_relayedSender == _buyer) {
            if (_instructionByte == INSTRUCTION_SELLER_CANNOT_CANCEL) {
                return doDisableSellerCancel(_tradeID, _seller, _buyer, _value, _fee, _additionalGas);
            } else if (_instructionByte == INSTRUCTION_BUYER_CANCEL) {
                return doBuyerCancel(_tradeID, _seller, _buyer, _value, _fee, _additionalGas);
            }
        } else if (_relayedSender == _seller) {
            if (_instructionByte == INSTRUCTION_RELEASE) {
                return doRelease(_tradeID, _seller, _buyer, _value, _fee, _additionalGas);
            } else if (_instructionByte == INSTRUCTION_SELLER_CANCEL) {
                return doSellerCancel(_tradeID, _seller, _buyer, _value, _fee, _additionalGas);
            } else if (_instructionByte == INSTRUCTION_SELLER_REQUEST_CANCEL){
                return doSellerRequestCancel(_tradeID, _seller, _buyer, _value, _fee, _additionalGas);
            }
        } else {
            require(msg.sender == _seller, "Unrecognised party");
            return false;
        }
    }

    function increaseGasSpent(bytes32 _tradeHash, uint128 _gas) private {

        escrows[_tradeHash].totalGasFeesSpentByRelayer += _gas * uint128(tx.gasprice);
    }

    function transferMinusFees(
        address payable _to,
        uint256 _value,
        uint128 _totalGasFeesSpentByRelayer,
        uint16 _fee
    ) private {

        uint256 _totalFees = (_value * _fee / 10000) + _totalGasFeesSpentByRelayer;
        if(_value - _totalFees > _value) {
            return;
        }
        feesAvailableForWithdraw += _totalFees;
        _to.transfer(_value - _totalFees);
    }

    uint16 constant GAS_doRelease = 46588;
    function doRelease(
        bytes16 _tradeID,
        address payable _seller,
        address payable _buyer,
        uint256 _value,
        uint16 _fee,
        uint128 _additionalGas
    ) private returns (bool) {

        Escrow memory _escrow;
        bytes32 _tradeHash;
        (_escrow, _tradeHash) = getEscrowAndHash(_tradeID, _seller, _buyer, _value, _fee);
        if (!_escrow.exists) return false;
        uint128 _gasFees = _escrow.totalGasFeesSpentByRelayer + (msg.sender == relayer
                ? (GAS_doRelease + _additionalGas ) * uint128(tx.gasprice)
                : 0
            );
        delete escrows[_tradeHash];
        emit Released(_tradeHash);
        transferMinusFees(_buyer, _value, _gasFees, _fee);
        return true;
    }

    uint16 constant GAS_doDisableSellerCancel = 28944;
    function doDisableSellerCancel(
        bytes16 _tradeID,
        address _seller,
        address _buyer,
        uint256 _value,
        uint16 _fee,
        uint128 _additionalGas
    ) private returns (bool) {

        Escrow memory _escrow;
        bytes32 _tradeHash;
        (_escrow, _tradeHash) = getEscrowAndHash(_tradeID, _seller, _buyer, _value, _fee);
        if (!_escrow.exists) return false;
        if(_escrow.sellerCanCancelAfter == 0) return false;
        escrows[_tradeHash].sellerCanCancelAfter = 0;
        emit SellerCancelDisabled(_tradeHash);
        if (msg.sender == relayer) {
          increaseGasSpent(_tradeHash, GAS_doDisableSellerCancel + _additionalGas);
        }
        return true;
    }

    uint16 constant GAS_doBuyerCancel = 46255;
    function doBuyerCancel(
        bytes16 _tradeID,
        address payable _seller,
        address payable _buyer,
        uint256 _value,
        uint16 _fee,
        uint128 _additionalGas
    ) private returns (bool) {

        Escrow memory _escrow;
        bytes32 _tradeHash;
        (_escrow, _tradeHash) = getEscrowAndHash(_tradeID, _seller, _buyer, _value, _fee);
        if (!_escrow.exists) {
            return false;
        }
        uint128 _gasFees = _escrow.totalGasFeesSpentByRelayer + (msg.sender == relayer
                ? (GAS_doBuyerCancel + _additionalGas ) * uint128(tx.gasprice)
                : 0
            );
        delete escrows[_tradeHash];
        emit CancelledByBuyer(_tradeHash);
        transferMinusFees(_seller, _value, _gasFees, 0);
        return true;
    }

    uint16 constant GAS_doSellerCancel = 46815;
    function doSellerCancel(
        bytes16 _tradeID,
        address payable _seller,
        address payable _buyer,
        uint256 _value,
        uint16 _fee,
        uint128 _additionalGas
    ) private returns (bool) {

        Escrow memory _escrow;
        bytes32 _tradeHash;
        (_escrow, _tradeHash) = getEscrowAndHash(_tradeID, _seller, _buyer, _value, _fee);
        if (!_escrow.exists) {
            return false;
        }
        if(_escrow.sellerCanCancelAfter <= 1 || _escrow.sellerCanCancelAfter > block.timestamp) { // solium-disable-line
            return false;
        }
        uint128 _gasFees = _escrow.totalGasFeesSpentByRelayer + (msg.sender == relayer
                ? (GAS_doSellerCancel + _additionalGas ) * uint128(tx.gasprice)
                : 0
            );
        delete escrows[_tradeHash];
        emit CancelledBySeller(_tradeHash);
        transferMinusFees(_seller, _value, _gasFees, 0);
        return true;
    }

    uint16 constant GAS_doSellerRequestCancel = 29507;
    function doSellerRequestCancel(
        bytes16 _tradeID,
        address _seller,
        address _buyer,
        uint256 _value,
        uint16 _fee,
        uint128 _additionalGas
    ) private returns (bool) {

        Escrow memory _escrow;
        bytes32 _tradeHash;
        (_escrow, _tradeHash) = getEscrowAndHash(_tradeID, _seller, _buyer, _value, _fee);
        if (!_escrow.exists) {
            return false;
        }
        if(_escrow.sellerCanCancelAfter != 1) {
            return false;
        }
        escrows[_tradeHash].sellerCanCancelAfter = uint32(block.timestamp) // solium-disable-line
            + requestCancellationMinimumTime;
        emit SellerRequestedCancel(_tradeHash);
        if (msg.sender == relayer) {
          increaseGasSpent(_tradeHash, GAS_doSellerRequestCancel + _additionalGas);
        }
        return true;
    }

    function getRelayedSender(
      bytes16 _tradeID,
      uint8 _instructionByte,
      uint128 _maximumGasPrice,
      uint8 _v,
      bytes32 _r,
      bytes32 _s
    ) private view returns (address) {

        bytes32 _hash = keccak256(abi.encodePacked(
            _tradeID,
            _instructionByte,
            _maximumGasPrice
        ));
        return recoverAddress(_hash, _v, _r, _s);
    }

    function getEscrowAndHash(
        bytes16 _tradeID,
        address _seller,
        address _buyer,
        uint256 _value,
        uint16 _fee
    ) private view returns (Escrow storage, bytes32) {

        bytes32 _tradeHash = keccak256(abi.encodePacked(
            _tradeID,
            _seller,
            _buyer,
            _value,
            _fee
        ));
        return (escrows[_tradeHash], _tradeHash);
    }

    function recoverAddress(
        bytes32 _h,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) private pure returns (address) {

        bytes memory _prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 _prefixedHash = keccak256(abi.encodePacked(_prefix, _h));
        return ecrecover(_prefixedHash, _v, _r, _s);
    }
}

contract _Token {

    function transfer(address _to, uint _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint _value) public returns (bool success);

    function approve(address _spender, uint _value) public returns (bool success);

}