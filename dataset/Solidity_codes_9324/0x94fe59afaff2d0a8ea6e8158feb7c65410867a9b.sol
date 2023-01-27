
pragma solidity >=0.5.0;

interface ILayerZeroTreasury {

    function getFees(bool payInZro, uint relayerFee, uint oracleFee) external view returns (uint);

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
}// MIT

pragma solidity ^0.7.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity ^0.7.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// BUSL-1.1

pragma solidity >=0.7.0;

interface ILayerZeroUltraLightNodeV1 {

    function validateTransactionProof(uint16 _srcChainId, address _dstAddress, uint _gasLimit, bytes32 _lookupHash, bytes calldata _transactionProof) external;


    function updateHash(uint16 _remoteChainId, bytes32 _lookupHash, uint _confirmations, bytes32 _data) external;


    function withdrawNative(uint8 _type, address _owner, address payable _to, uint _amount) external;


    function withdrawZRO(address _to, uint _amount) external;


    function oracleQuotedAmount(address _oracle) external view returns (uint);


    function relayerQuotedAmount(address _relayer) external view returns (uint);

}// BUSL-1.1

pragma solidity 0.7.6;


contract Treasury is ILayerZeroTreasury, Ownable {

    using SafeMath for uint;

    uint public nativeBP;
    uint public zroFee;
    bool public feeEnabled;
    bool public zroEnabled;

    ILayerZeroUltraLightNodeV1 public immutable uln;

    event NativeBP(uint bp);
    event ZroFee(uint zroFee);
    event FeeEnabled(bool feeEnabled);
    event ZroEnabled(bool zroEnabled);

    constructor(address _uln) {
        uln = ILayerZeroUltraLightNodeV1(_uln);
    }

    function getFees(bool payInZro, uint relayerFee, uint oracleFee) external view override returns (uint) {

        if (feeEnabled) {
            if (payInZro) {
                require(zroEnabled, "LayerZero: ZRO is not enabled");
                return zroFee;
            } else {
                return relayerFee.add(oracleFee).mul(nativeBP).div(10000);
            }
        }
        return 0;
    }

    function setFeeEnabled(bool _feeEnabled) external onlyOwner {

        feeEnabled = _feeEnabled;
        emit FeeEnabled(_feeEnabled);
    }

    function setZroEnabled(bool _zroEnabled) external onlyOwner {

        zroEnabled = _zroEnabled;
        emit ZroEnabled(_zroEnabled);
    }

    function setNativeBP(uint _nativeBP) external onlyOwner {

        nativeBP = _nativeBP;
        emit NativeBP(_nativeBP);
    }

    function setZroFee(uint _zroFee) external onlyOwner {

        zroFee = _zroFee;
        emit ZroFee(_zroFee);
    }

    function withdrawZROFromULN(address _to, uint _amount) external onlyOwner {

        uln.withdrawZRO(_to, _amount);
    }

    function withdrawNativeFromULN(address payable _to, uint _amount) external onlyOwner {

        uln.withdrawNative(0, address(0x0), _to, _amount);
    }
}