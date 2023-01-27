pragma solidity ^0.7.0;

interface IArchToken {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    function mint(address dst, uint256 amount) external returns (bool);

    function burn(address src, uint256 amount) external returns (bool);

    function updateTokenMetadata(string memory tokenName, string memory tokenSymbol) external returns (bool);

    function supplyManager() external view returns (address);

    function metadataManager() external view returns (address);

    function supplyChangeAllowedAfter() external view returns (uint256);

    function supplyChangeWaitingPeriod() external view returns (uint32);

    function supplyChangeWaitingPeriodMinimum() external view returns (uint32);

    function mintCap() external view returns (uint16);

    function setSupplyManager(address newSupplyManager) external returns (bool);

    function setMetadataManager(address newMetadataManager) external returns (bool);

    function setSupplyChangeWaitingPeriod(uint32 period) external returns (bool);

    function setMintCap(uint16 newCap) external returns (bool);

    event MintCapChanged(uint16 indexed oldMintCap, uint16 indexed newMintCap);
    event SupplyManagerChanged(address indexed oldManager, address indexed newManager);
    event SupplyChangeWaitingPeriodChanged(uint32 indexed oldWaitingPeriod, uint32 indexed newWaitingPeriod);
    event MetadataManagerChanged(address indexed oldManager, address indexed newManager);
    event TokenMetaUpdated(string indexed name, string indexed symbol);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);
}// MIT

pragma solidity ^0.7.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;


contract Multisend is ReentrancyGuard {


    IArchToken public token;

    constructor(IArchToken _token) {
        token = _token;
    }

    function batchTransfer(
        uint256 totalAmount,
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external nonReentrant {

        _batchTransfer(totalAmount, recipients, amounts);
    }

    function batchTransferWithPermit(
        uint256 totalAmount,
        address[] calldata recipients,
        uint256[] calldata amounts,
        uint256 deadline,
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external nonReentrant {

        token.permit(msg.sender, address(this), totalAmount, deadline, v, r, s);
        _batchTransfer(totalAmount, recipients, amounts);
    }

    function _batchTransfer(
        uint256 totalAmount,
        address[] calldata recipients,
        uint256[] calldata amounts
    ) internal {

        require(token.allowance(msg.sender, address(this)) >= totalAmount, "Multisend::_batchTransfer: allowance too low");
        require(token.balanceOf(msg.sender) >= totalAmount, "Multisend::_batchTransfer: sender balance too low");
        require(recipients.length == amounts.length, "Multisend::_batchTransfer: recipients length != amounts length");
        uint256 amountTransferred = 0;
        for (uint256 i; i < recipients.length; i++) {
            bool success = token.transferFrom(msg.sender, recipients[i], amounts[i]);
            require(success, "Multisend::_batchTransfer: failed to transfer tokens");
            amountTransferred = amountTransferred + amounts[i];
        }
        require(amountTransferred == totalAmount, "Multisend::_batchTransfer: total != transferred amount");
    }
}