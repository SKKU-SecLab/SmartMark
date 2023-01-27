
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

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


contract ERC721Holder is IERC721Receiver {

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}// MIT

pragma solidity ^0.8.0;

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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.8.2;


interface RealmsToken is IERC721Enumerable {


}// MIT

pragma solidity ^0.8.0;

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
}// MIT
pragma solidity ^0.8.2;

interface LordsToken is IERC20 {}// MIT

pragma solidity ^0.8.12;

contract Journey is ERC721Holder, Ownable, ReentrancyGuard, Pausable {

    event StakeRealms(uint256[] tokenIds, address player);
    event UnStakeRealms(uint256[] tokenIds, address player);

    mapping(address => uint256) public epochClaimed;
    mapping(uint256 => address) public ownership;
    mapping(address => mapping(uint256 => uint256)) public realmsStaked;

    LordsToken public lordsToken;
    RealmsToken public realmsToken;
    address public bridge;
    uint256 public lordsPerRealm;
    uint256 public genesis;
    uint256 public epoch;
    uint256 public finalAge;
    uint256 public halvingAge;
    uint256 public halvingAmount;
    uint256 public gracePeriod;

    uint256 public epochLengh = 3600;

    constructor(
        uint256 _lordsPerRealm,
        uint256 _epoch,
        uint256 _halvingAge,
        uint256 _halvingAmount,
        address _realmsAddress,
        address _lordsToken
    ) {
        lordsPerRealm = _lordsPerRealm;
        epoch = _epoch;
        halvingAge = _halvingAge;
        halvingAmount = _halvingAmount;
        lordsToken = LordsToken(_lordsToken);
        realmsToken = RealmsToken(_realmsAddress);
    }


    function setGracePeriod(uint256 _gracePeriod) external onlyOwner {

        gracePeriod = _gracePeriod;
    }

    function setGenesis(uint256 _time) external onlyOwner {

        genesis = _time;
    }

    function lordsIssuance(uint256 _new) external onlyOwner {

        lordsPerRealm = _new;
    }

    function updateRealmsAddress(address _newRealms) external onlyOwner {

        realmsToken = RealmsToken(_newRealms);
    }

    function updateLordsAddress(address _newLords) external onlyOwner {

        lordsToken = LordsToken(_newLords);
    }

    function updateEpochLength(uint256 _newEpoch) external onlyOwner {

        epoch = _newEpoch;
    }

    function setBridge(address _newBridge) external onlyOwner {

        bridge = _newBridge;
    }

    function setHalvingAmount(uint256 _halvingAmount) external onlyOwner {

        halvingAmount = _halvingAmount;
    }

    function setHalvingAge(uint256 _halvingAge) external onlyOwner {

        halvingAge = _halvingAge;
    }

    function setFinalAge(uint256 _finalAge) external onlyOwner {

        finalAge = _finalAge;
    }

    function pause() external onlyOwner {

        _pause();
    }

    function unpause() external onlyOwner {

        _unpause();
    }

    function boardShip(uint256[] memory _tokenIds)
        external
        whenNotPaused
        nonReentrant
    {

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            require(
                realmsToken.ownerOf(_tokenIds[i]) == msg.sender,
                "NOT_OWNER"
            );
            ownership[_tokenIds[i]] = msg.sender;

            realmsToken.safeTransferFrom(
                msg.sender,
                address(this),
                _tokenIds[i]
            );
        }

        if (getNumberRealms(msg.sender) == 0) {
            epochClaimed[msg.sender] = _epochNum();
        }

        realmsStaked[msg.sender][_epochNum()] += uint256(_tokenIds.length);

        emit StakeRealms(_tokenIds, msg.sender);
    }

    function exitShip(uint256[] memory _tokenIds)
        external
        whenNotPaused
        nonReentrant
    {

        _exitShip(_tokenIds);
    }

    function claimLords() external whenNotPaused nonReentrant {

        _claimLords();
    }


    function _epochNum() internal view returns (uint256) {

        if (finalAge != 0) {
            return finalAge;
        } else if (block.timestamp - genesis < gracePeriod) {
            return 0;
        } else if ((block.timestamp - genesis) / (epoch * epochLengh) == 0) {
            return 1;
        } else {
            return (block.timestamp - genesis) / (epoch * epochLengh) + 1;
        }
    }

    function _exitShip(uint256[] memory _tokenIds) internal {

        (uint256 lords, ) = lordsAvailable(msg.sender);

        if (lords != 0) {
            _claimLords();
        }

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            require(ownership[_tokenIds[i]] == msg.sender, "NOT_OWNER");

            ownership[_tokenIds[i]] = address(0);

            realmsToken.safeTransferFrom(
                address(this),
                msg.sender,
                _tokenIds[i]
            );
        }

        if (_epochNum() == 0) {
            realmsStaked[msg.sender][_epochNum()] -= _tokenIds.length;
        } else {
            uint256 realmsInPrevious = realmsStaked[msg.sender][
                _epochNum() - 1
            ];
            uint256 realmsInCurrent = realmsStaked[msg.sender][_epochNum()];

            if (realmsInPrevious > _tokenIds.length) {
                realmsStaked[msg.sender][_epochNum() - 1] -= _tokenIds.length;
            } else if (realmsInCurrent == _tokenIds.length) {
                realmsStaked[msg.sender][_epochNum()] -= _tokenIds.length;
            } else if (realmsInPrevious <= _tokenIds.length) {
                uint256 oldestFirst = (_tokenIds.length - realmsInPrevious);

                realmsStaked[msg.sender][_epochNum() - 1] -= (_tokenIds.length -
                    oldestFirst);

                realmsStaked[msg.sender][_epochNum()] -= oldestFirst;
            }
        }

        emit UnStakeRealms(_tokenIds, msg.sender);
    }

    function _claimLords() internal {

        require(_epochNum() > 1, "GENESIS_epochNum");

        (uint256 lords, uint256 totalRealms) = lordsAvailable(msg.sender);

        realmsStaked[msg.sender][_epochNum() - 1] = totalRealms;

        epochClaimed[msg.sender] = _epochNum() - 1;

        require(lords > 0, "NOTHING_TO_CLAIM");

        lordsToken.approve(address(this), lords);

        lordsToken.transferFrom(address(this), msg.sender, lords);
    }


    function lordsAvailable(address _player)
        public
        view
        returns (uint256 lords, uint256 totalRealms)
    {

        uint256 preHalvingRealms;
        uint256 postHalvingRealms;

        for (uint256 i = epochClaimed[_player]; i < _epochNum(); i++) {
            totalRealms += realmsStaked[_player][i];
        }

        if (epochClaimed[_player] <= halvingAge && _epochNum() <= halvingAge) {
            for (uint256 i = epochClaimed[_player]; i < _epochNum(); i++) {
                preHalvingRealms +=
                    realmsStaked[_player][i] *
                    ((_epochNum() - 1) - i);
            }
        } else if (
            _epochNum() >= halvingAge && epochClaimed[_player] < halvingAge
        ) {
            for (uint256 i = epochClaimed[_player]; i < halvingAge; i++) {
                preHalvingRealms +=
                    realmsStaked[_player][i] *
                    ((halvingAge) - i);
            }
        }

        if (_epochNum() > halvingAge && epochClaimed[_player] >= halvingAge) {
            for (uint256 i = epochClaimed[_player]; i < _epochNum(); i++) {
                postHalvingRealms +=
                    realmsStaked[_player][i] *
                    ((_epochNum() - 1) - i);
            }
        } else if (
            _epochNum() > halvingAge && epochClaimed[_player] < halvingAge
        ) {
            uint256 total;

            for (uint256 i = epochClaimed[_player]; i < _epochNum(); i++) {
                total += realmsStaked[_player][i] * ((_epochNum() - 1) - i);

                if (i < halvingAge) {
                    total -= realmsStaked[_player][i] * ((halvingAge) - i);
                }
            }

            postHalvingRealms = total;
        }

        if (_epochNum() > 1) {
            lords =
                (lordsPerRealm * preHalvingRealms) +
                (halvingAmount * postHalvingRealms);
        } else {
            lords = 0;
        }
    }

    function withdrawAllLords(address _destination) public onlyOwner {

        uint256 balance = lordsToken.balanceOf(address(this));
        lordsToken.approve(address(this), balance);
        lordsToken.transferFrom(address(this), _destination, balance);
    }

    function getEpoch() public view returns (uint256) {

        return _epochNum();
    }

    function getTimeUntilEpoch() public view returns (uint256) {

        return
            (epoch * epochLengh * (getEpoch())) - (block.timestamp - genesis);
    }

    function getNumberRealms(address _player) public view returns (uint256) {

        uint256 totalRealms;

        if (_epochNum() >= 1) {
            for (uint256 i = epochClaimed[_player]; i <= _epochNum(); i++) {
                totalRealms += realmsStaked[_player][i];
            }
            return totalRealms;
        } else {
            return realmsStaked[_player][0];
        }
    }

    modifier onlyBridge() {

        require(msg.sender == bridge, "NOT_THE_BRIDGE");
        _;
    }

    function bridgeWithdraw(address _player, uint256[] memory _tokenIds)
        public
        onlyBridge
    {

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            ownership[_tokenIds[i]] = address(0);
            realmsToken.safeTransferFrom(address(this), _player, _tokenIds[i]);
        }
        emit UnStakeRealms(_tokenIds, _player);
    }
}