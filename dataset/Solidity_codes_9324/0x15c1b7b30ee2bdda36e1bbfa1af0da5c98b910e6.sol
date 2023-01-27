
pragma solidity >=0.6.10;


interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

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

contract CardDistributor is ERC165 {

    using SafeMath for uint;
    bytes4 private constant TRANSFER_FROM_SELECTOR_721 = bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
    bytes4 private constant TRANSFER_FROM_SELECTOR_1155 = bytes4(keccak256(bytes('safeTransferFrom(address,address,uint256,uint256,bytes)')));

    bytes4 private constant TRANSFER_SELECTOR_20 = bytes4(keccak256(bytes('transfer(address,uint256)')));
    bytes4 private constant TRANSFER_FROM_SELECTOR_20 = bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
    bytes4 private constant BALANCE_OF_SELECTOR_20 = bytes4(keccak256(bytes('balanceOf(address)')));

    address public owner;

    struct CardInfo {
        uint256 price; // Card price over ymem
        uint256 amount;
        uint256 nftType; // It's 721 or 1155
    }

    mapping(address=>mapping(uint256=>CardInfo)) public cards;

    address public acceptToken;
    bool public claimable;

    event ClaimNFT(address indexed staker, address indexed nftAddress, uint256 indexed nftId, uint256 price);
    event AddCard(address _nftAddr, uint256 _nftId, uint256 _nftType, uint256 _amount, uint256 _price);
    event WithdrawCard(address _nftAddr, uint256 _nftType, uint256 _amount);

    modifier onlyOwner() {

        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyClaimable() {

        require(claimable, "Not claimable");
        _;
    }

    constructor (address _acceptTokenAddress) public {
        owner = msg.sender;
        acceptToken = _acceptTokenAddress;
        _registerInterface(CardDistributor.onERC721Received.selector);
        _registerInterface(CardDistributor.onERC1155Received.selector);
        _registerInterface(CardDistributor.onERC1155BatchReceived.selector);
    }

    function changeOwner(address newOwner) public onlyOwner() {

        require(newOwner != address(0), "Owner address invalid");
        owner = newOwner;
    }

    function startClaim() public onlyOwner() {

        claimable = true;
    }

    function stopClaim() public onlyOwner() {

        claimable = false;
    }

    function addCard(address _nftAddr, uint256 _nftId, uint256 _nftType, uint256 _amount, uint256 _price) public onlyOwner() {

        require((_nftType == 721 || _nftType == 1155), "Card type must be 721 or 1155");

        CardInfo storage card = cards[_nftAddr][_nftId];

        require(card.nftType == 0 || (card.nftType != 0 && card.nftType == _nftType) , "Wrong NFT type");

        card.nftType = _nftType;
        if (_nftType == 721) {
            card.amount = 1;
        } else {
            card.amount = card.amount.add(_amount);
        }
        card.price = _price;

        emit AddCard(_nftAddr, _nftId, _nftType, _amount, _price);
    }

    function withdrawCard(address _nftAddr, uint256 _nftId) public onlyOwner() {

        CardInfo storage c = cards[_nftAddr][_nftId];
        uint256 amount = c.amount;
        c.amount = 0;

        require(c.nftType != 0, "Card does not exist");
        require(amount > 0 , "Card insufficient");

        _transferNft(_nftAddr, _nftId, c.nftType, msg.sender, amount);

        emit WithdrawCard(_nftAddr, _nftId, amount);
    }

    function resetCard(address _nftAddr, uint256 _nftId) public onlyOwner() {

        delete cards[_nftAddr][_nftId];
    }

    function withdrawToken() public onlyOwner() returns (uint256) {

        (bool success, bytes memory data) = acceptToken.call(abi.encodeWithSelector(BALANCE_OF_SELECTOR_20, address(this)));
        require(success, "Can not get balance");

        uint256 amount = abi.decode(data, (uint256));

        _safeTransferERC20(acceptToken, msg.sender, amount);
        return amount;
    }

    function claimNft(address _nftAddress, uint256 _nftId) onlyClaimable public {

        CardInfo storage card = cards[_nftAddress][_nftId];
        require(card.amount > 0, "No card");

        card.amount = card.amount.sub(1);

        _safeTransferFromERC20(acceptToken, msg.sender, address(this), card.price);

        _transferNft(_nftAddress, _nftId, card.nftType, msg.sender, 1);

        emit ClaimNFT(msg.sender, _nftAddress, _nftId, card.price);
    }

    function _transferNft(address _nftAddress, uint256 _nftId, uint256 _nftType, address _receiver,  uint256 _amount) internal {

        if (_nftType == 721) {
            _transfer721(_nftAddress, _nftId, _receiver);
        } else if(_nftType == 1155) {
            _transfer1155(_nftAddress, _nftId, _receiver, _amount);
        } else {
            revert();
        }
    }

    function _transfer721(address _nftAddress, uint256 _nftId, address _receiver) internal {

        (bool success,) = _nftAddress.call(abi.encodeWithSelector(TRANSFER_FROM_SELECTOR_721, address(this), _receiver, _nftId));
        require(success, 'TRANSFER_721_FAILED');
    }

    function _transfer1155(address _nftAddress, uint256 _nftId, address _receiver, uint256 _amount) internal {

        (bool success,) = _nftAddress.call(abi.encodeWithSelector(TRANSFER_FROM_SELECTOR_1155, address(this), _receiver, _nftId, _amount, ""));
        require(success, 'TRANSFER_1155_FAILED');
    }


    function _safeTransferERC20(address token, address to, uint value) private {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(TRANSFER_SELECTOR_20, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TRANSFER_FAILED');
    }

    function _safeTransferFromERC20(address token, address from, address to, uint value) private {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(TRANSFER_FROM_SELECTOR_20, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TRANSFER_FROM_FAILED');
    }


    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {

        return CardDistributor.onERC721Received.selector;
    }

     function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns(bytes4) {

        return CardDistributor.onERC1155Received.selector;
    }

     function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns(bytes4) {

        return CardDistributor.onERC1155BatchReceived.selector;
    }

}