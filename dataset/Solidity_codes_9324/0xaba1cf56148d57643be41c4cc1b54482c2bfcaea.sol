



pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}




pragma solidity >=0.6.0 <0.8.0;

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


pragma solidity 0.7.5;


interface IPartnerDeployer {


    function deploy(
        string calldata referralId,
        address payable feeWallet,
        uint256 fee,
        uint256 paraswapShare,
        uint256 partnerShare,
        address owner,
        uint256 timelock,
        uint256 maxFee,
        bool positiveSlippageToUser,
        bool noPositiveSlippage
    )
        external
        returns(address);

}


pragma solidity 0.7.5;





contract PartnerRegistry is Ownable {


    using SafeMath for uint256;

    mapping(bytes32 => address) private _referralVsPartner;
    mapping(bytes32 => address) private _removedPartners;

    IPartnerDeployer private _partnerDeployer;

    event PartnerAdded(string referralId, address indexed partnerContract);
    event PartnerRemoved(string referralId);
    event PartnerDeployerChanged(address indexed partnerDeployer);

    constructor(address partnerDeployer) public {
        _partnerDeployer = IPartnerDeployer(partnerDeployer);
    }

    function getPartnerDeployer() external view returns(address) {

        return address(_partnerDeployer);
    }

    function changePartnerDeployer(address partnerDeployer) external onlyOwner {

        require(partnerDeployer != address(0), "Invalid address");
        _partnerDeployer = IPartnerDeployer(partnerDeployer);
        emit PartnerDeployerChanged(partnerDeployer);
    }

    function getPartnerContract(string calldata referralId) public view returns(address) {

        return _referralVsPartner[keccak256(abi.encodePacked(referralId))];
    }

    function addPartner(
        string calldata referralId,
        address payable feeWallet,
        uint256 fee,
        uint256 paraswapShare,
        uint256 partnerShare,
        address owner,
        uint256 timelock,
        uint256 maxFee,
        bool positiveSlippageToUser,
        bool noPositiveSlippage
    )
        external
        onlyOwner
    {

        require(feeWallet != address(0), "Invalid fee wallet");
        require(owner != address(0), "Invalid owner for partner");
        require(fee <= 10000, "Invalid fee passed");
        require(paraswapShare.add(partnerShare) == 10000, "Invalid shares");
        require(bytes(referralId).length > 0, "Empty referralId");

        require(getPartnerContract(referralId) == address(0), "Partner already exists");
        require(_removedPartners[keccak256(abi.encodePacked(referralId))] == address(0), "Partner was removed before");

        address partner = _partnerDeployer.deploy(
            referralId,
            feeWallet,
            fee,
            paraswapShare,
            partnerShare,
            owner,
            timelock,
            maxFee,
            positiveSlippageToUser,
            noPositiveSlippage
        );

        _referralVsPartner[keccak256(abi.encodePacked(referralId))] = address(partner);

        emit PartnerAdded(referralId, partner);
    }

    function removePartner(string calldata referralId) external onlyOwner {

        address partner = getPartnerContract(referralId);

        require(partner != address(0), "Partner doesn't exist");

        _referralVsPartner[keccak256(abi.encodePacked(referralId))] = address(0);

        _removedPartners[keccak256(abi.encodePacked(referralId))] = partner;

        emit PartnerRemoved(referralId);
    }
}