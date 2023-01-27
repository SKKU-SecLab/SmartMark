
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT
pragma solidity ^0.8.0;


contract RecoverableERC721Holder is Ownable, IERC721Receiver {

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }

    function emergencyTransferOut(address[] calldata _tokenAddressesToTransfer, address[] calldata _recipients, uint[] calldata _tokenIds) external onlyOwner {

        require((_tokenAddressesToTransfer.length == _tokenIds.length) && (_tokenIds.length == _recipients.length), "ERROR: INVALID INPUT DATA - MISMATCHED LENGTHS");

        for(uint i = 0; i < _recipients.length; i++) {
            IToken(_tokenAddressesToTransfer[i]).safeTransferFrom(address(this), _recipients[i], _tokenIds[i]);
        }
    }
}// MIT
pragma solidity ^0.8.0;



interface ITunnel {

    function sendMessage(bytes calldata _message) external;

}

contract Harbour is Ownable, Pausable, RecoverableERC721Holder {


    address public tunnel;

    address public ggold;
    address public wood;

    address public goldhunters;
    address public ships;
    address public houses;

    mapping (address => address) public reflection;

    constructor(
        address _tunnel,
        address _ggold, 
        address _wood,
        address _goldhunters,
        address _ships, 
        address _houses
    ) {
        tunnel = _tunnel;
        ggold = _ggold;
        wood = _wood;
        goldhunters = _goldhunters;
        ships = _ships;
        houses = _houses;
        _pause();
    }


    function pause() external onlyOwner {

        _pause();
    }

    function unpause() external onlyOwner {

        _unpause();
    }

    function setReflection(address _key, address _reflection) external onlyOwner {

        reflection[_key] = _reflection;
        reflection[_reflection] = _key;
    }


    function travel(
        uint256 _ggoldAmount, 
        uint256 _woodAmount,
        uint16[] calldata _goldhunterIds,
        uint16[] calldata _shipIds,
        uint16[] calldata _houseIds
    ) external whenNotPaused {

        uint256 callsIndex = 0;

        bytes[] memory calls = new bytes[](
            (_ggoldAmount > 0 ? 1 : 0) + 
            (_woodAmount > 0 ? 1 : 0) +
            (_goldhunterIds.length > 0 ? 1 : 0) +
            (_shipIds.length > 0 ? 1 : 0) +
            (_houseIds.length > 0 ? 1 : 0)
        );

        if (_ggoldAmount > 0) {
            ICoin(ggold).burn(msg.sender, _ggoldAmount);
            calls[callsIndex] = abi.encodeWithSelector(this.mintToken.selector, reflection[address(ggold)], msg.sender, _ggoldAmount);
            callsIndex++;
        }

        if (_woodAmount > 0) {
            ICoin(wood).burn(msg.sender, _woodAmount);
            calls[callsIndex] = abi.encodeWithSelector(this.mintToken.selector, reflection[address(wood)], msg.sender, _woodAmount);
            callsIndex++;
        }

        if (_goldhunterIds.length > 0) {
            _stakeMany(goldhunters, _goldhunterIds);
            calls[callsIndex] = abi.encodeWithSelector(this.unstakeMany.selector, reflection[address(goldhunters)], msg.sender, _goldhunterIds);
            callsIndex++;
        }

        if (_shipIds.length > 0) {
            _stakeMany(ships, _shipIds);
            calls[callsIndex] = abi.encodeWithSelector(this.unstakeMany.selector, reflection[address(ships)], msg.sender, _shipIds);
            callsIndex++;
        }

        if (_houseIds.length > 0) {
            _stakeMany(houses, _houseIds);
            calls[callsIndex] = abi.encodeWithSelector(this.unstakeMany.selector, reflection[address(houses)], msg.sender, _houseIds);
        }

        ITunnel(tunnel).sendMessage(abi.encode(reflection[address(this)], calls));
    }


    function _stakeMany(address nft, uint16[] calldata ids) internal {

        for(uint i = 0; i < ids.length; i++) {
            IToken(nft).safeTransferFrom(msg.sender, address(this), ids[i]);
        }
    }

    modifier onlyTunnel {

        require(msg.sender == tunnel, "ERROR: Msg.Sender is Not Tunnel");
        _;
    }

    function mintToken(address token, address to, uint256 amount) external onlyTunnel { 

        ICoin(token).mint(to, amount);
    }

    function unstakeMany(address nft, address harbourUser, uint16[] calldata ids) external onlyTunnel {

        for(uint i = 0; i < ids.length; i++) {
            IToken(nft).safeTransferFrom(address(this), harbourUser, ids[i]);
        }
    }
}// MIT LICENSE
pragma solidity ^0.8.9;

interface ICoin {

    function mint(address account, uint amount) external;

    function burn(address _from, uint _amount) external;

    function balanceOf(address account) external returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

}

interface IToken {

    function ownerOf(uint id) external view returns (address);

    function transferFrom(address from, address to, uint tokenId) external;

    function safeTransferFrom(address from, address to, uint tokenId) external; // ERC721

    function safeTransferFrom(address from, address to, uint tokenId, uint amount) external; // ERC1155

    function isApprovedForAll(address owner, address operator) external returns(bool);

    function setApprovalForAll(address operator, bool approved) external;

}

interface IGHGMetadata {

    function getGoldhunterMetadata(uint16 _tokenId) external view returns (string memory);

    function getShipMetadata(uint16 _tokenId) external view returns (string memory);

    function getHouseMetadata(uint16 _tokenId) external view returns (string memory);


    function shipIsPirate(uint16 _tokenId) external view returns (bool);

    function shipIsCrossedTheOcean(uint16 _tokenId) external view returns (bool);

    function getShipBackground(uint16 _tokenId) external view returns (string memory);

    function getShipShip(uint16 _tokenId) external view returns (string memory);

    function getShipFlag(uint16 _tokenId) external view returns (string memory);

    function getShipMast(uint16 _tokenId) external view returns (string memory);

    function getShipAnchor(uint16 _tokenId) external view returns (string memory);

    function getShipSail(uint16 _tokenId) external view returns (string memory);

    function getShipWaves(uint16 _tokenId) external view returns (string memory);


    function getHouseBackground(uint16 _tokenId) external view returns (string memory);

    function getHouseType(uint16 _tokenId) external view returns (string memory);

    function getHouseWindow(uint16 _tokenId) external view returns (string memory);

    function getHouseDoor(uint16 _tokenId) external view returns (string memory);

    function getHouseRoof(uint16 _tokenId) external view returns (string memory);

    function getHouseForeground(uint16 _tokenId) external view returns (string memory);


    function goldhunterIsCrossedTheOcean(uint16 _tokenId) external view returns (bool);

    function goldhunterIsPirate(uint16 _tokenId) external view returns (bool);

    function getGoldhunterIsGen0(uint16 _tokenId) external pure returns (bool);

    function getGoldhunterSkin(uint16 _tokenId) external view returns (string memory);

    function getGoldhunterLegs(uint16 _tokenId) external view returns (string memory);

    function getGoldhunterFeet(uint16 _tokenId) external view returns (string memory);

    function getGoldhunterTshirt(uint16 _tokenId) external view returns (string memory);

    function getGoldhunterHeadwear(uint16 _tokenId) external view returns (string memory);

    function getGoldhunterMouth(uint16 _tokenId) external view returns (string memory);

    function getGoldhunterNeck(uint16 _tokenId) external view returns (string memory);

    function getGoldhunterSunglasses(uint16 _tokenId) external view returns (string memory);

    function getGoldhunterTool(uint16 _tokenId) external view returns (string memory);

    function getGoldhunterPegleg(uint16 _tokenId) external view returns (string memory);

    function getGoldhunterHook(uint16 _tokenId) external view returns (string memory);

    function getGoldhunterDress(uint16 _tokenId) external view returns (string memory);

    function getGoldhunterFace(uint16 _tokenId) external view returns (string memory);

    function getGoldhunterPatch(uint16 _tokenId) external view returns (string memory);

    function getGoldhunterEars(uint16 _tokenId) external view returns (string memory);

    function getGoldhunterHead(uint16 _tokenId) external view returns (string memory);

    function getGoldhunterArm(uint16 _tokenId) external view returns (string memory);

}