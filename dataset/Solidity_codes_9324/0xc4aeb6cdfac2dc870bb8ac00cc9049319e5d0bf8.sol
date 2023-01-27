pragma solidity 0.4.25;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}
pragma solidity 0.4.25;


contract IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);

    function ownerOf(uint256 tokenId) public view returns (address owner);


    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function transferFrom(address from, address to, uint256 tokenId) public;

    function safeTransferFrom(address from, address to, uint256 tokenId) public;


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

}
pragma solidity 0.4.25;

contract IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4);

}
pragma solidity 0.4.25;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'mul');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, 'div');
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, 'sub');
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, 'add');

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}
pragma solidity 0.4.25;

library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}
pragma solidity 0.4.25;


contract ERC165 is IERC165 {

    bytes4 private constant _InterfaceId_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_InterfaceId_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff);
        _supportedInterfaces[interfaceId] = true;
    }
}
pragma solidity 0.4.25;


contract ERC721 is ERC165, IERC721 {

    using SafeMath for uint256;
    using Address for address;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (uint256 => address) internal _tokenOwner;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => uint256) private _ownedTokensCount;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    bytes4 private constant _InterfaceId_ERC721 = 0x80ac58cd;

    constructor () public {
        _registerInterface(_InterfaceId_ERC721);
    }

    function balanceOf(address owner) public view returns (uint256) {

        require(owner != address(0));
        return _ownedTokensCount[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {

        address owner = _tokenOwner[tokenId];
        require(owner != address(0));
        return owner;
    }

    function approve(address to, uint256 tokenId) public {

        address owner = ownerOf(tokenId);
        require(to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {

        require(_exists(tokenId));
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address to, bool approved) public {

        require(to != msg.sender);
        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {

        require(_isApprovedOrOwner(msg.sender, tokenId));
        require(to != address(0));

        _clearApproval(from, tokenId);
        _removeTokenFrom(from, tokenId);
        _addTokenTo(to, tokenId);

        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {

        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data));
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _mint(address to, uint256 tokenId) internal {

        require(to != address(0));
        _addTokenTo(to, tokenId);
        emit Transfer(address(0), to, tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {

        _clearApproval(owner, tokenId);
        _removeTokenFrom(owner, tokenId);
        emit Transfer(owner, address(0), tokenId);
    }

    function _addTokenTo(address to, uint256 tokenId) internal {

        require(_tokenOwner[tokenId] == address(0));
        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to] = _ownedTokensCount[to].add(1);
    }

    function _removeTokenFrom(address from, uint256 tokenId) internal {

        require(ownerOf(tokenId) == from);
        _ownedTokensCount[from] = _ownedTokensCount[from].sub(1);
        _tokenOwner[tokenId] = address(0);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) internal returns (bool) {

        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    function _clearApproval(address owner, uint256 tokenId) private {

        require(ownerOf(tokenId) == owner);
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}
pragma solidity 0.4.25;


contract IERC721Enumerable is IERC721 {

    function totalSupply() public view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) public view returns (uint256);

}
pragma solidity 0.4.25;


contract ERC721Enumerable is ERC165, ERC721, IERC721Enumerable {

    mapping(address => uint256[]) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    bytes4 private constant _InterfaceId_ERC721Enumerable = 0x780e9d63;

    constructor () public {
        _registerInterface(_InterfaceId_ERC721Enumerable);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {

        require(index < balanceOf(owner));
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view returns (uint256) {

        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {

        require(index < totalSupply());
        return _allTokens[index];
    }

    function _addTokenTo(address to, uint256 tokenId) internal {

        super._addTokenTo(to, tokenId);
        uint256 length = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
        _ownedTokensIndex[tokenId] = length;
    }

    function _removeTokenFrom(address from, uint256 tokenId) internal {

        super._removeTokenFrom(from, tokenId);

        uint256 tokenIndex = _ownedTokensIndex[tokenId];
        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 lastToken = _ownedTokens[from][lastTokenIndex];

        _ownedTokens[from][tokenIndex] = lastToken;
        _ownedTokens[from].length--;


        _ownedTokensIndex[tokenId] = 0;
        _ownedTokensIndex[lastToken] = tokenIndex;
    }

    function _mint(address to, uint256 tokenId) internal {

        super._mint(to, tokenId);

        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {

        super._burn(owner, tokenId);

        uint256 tokenIndex = _allTokensIndex[tokenId];
        uint256 lastTokenIndex = _allTokens.length.sub(1);
        uint256 lastToken = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastToken;
        _allTokens[lastTokenIndex] = 0;

        _allTokens.length--;
        _allTokensIndex[tokenId] = 0;
        _allTokensIndex[lastToken] = tokenIndex;
    }
}
pragma solidity 0.4.25;


contract IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);

}
pragma solidity 0.4.25;


contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {

    string private _name;

    string private _symbol;

    mapping(uint256 => string) private _tokenURIs;

    bytes4 private constant InterfaceId_ERC721Metadata = 0x5b5e139f;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        _registerInterface(InterfaceId_ERC721Metadata);
    }

    function name() external view returns (string memory) {

        return _name;
    }

    function symbol() external view returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId));
        return _tokenURIs[tokenId];
    }

    function _setTokenURI(uint256 tokenId, string memory uri) internal {

        require(_exists(tokenId));
        _tokenURIs[tokenId] = uri;
    }

    function _burn(address owner, uint256 tokenId) internal {

        super._burn(owner, tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}
pragma solidity 0.4.25;



contract TBoxToken is ERC721, ERC721Enumerable, ERC721Metadata {

    constructor (string memory name, string memory symbol) ERC721Metadata(name, symbol) public {}
}
pragma solidity 0.4.25;


interface ISettings {

    function oracleAddress() external view returns(address);

    function minDeposit() external view returns(uint256);

    function sysFee() external view returns(uint256);

    function userFee() external view returns(uint256);

    function ratio() external view returns(uint256);

    function globalTargetCollateralization() external view returns(uint256);

    function tmvAddress() external view returns(uint256);

    function maxStability() external view returns(uint256);

    function minStability() external view returns(uint256);

    function gasPriceLimit() external view returns(uint256);

    function isFeeManager(address account) external view returns (bool);

    function tBoxManager() external view returns(address);

}
pragma solidity 0.4.25;


interface IToken {

    function burnLogic(address from, uint256 value) external;

    function approve(address spender, uint256 value) external;

    function balanceOf(address who) external view returns (uint256);

    function mint(address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 tokenId) external;

}

pragma solidity 0.4.25;


interface IOracle {

    function ethUsdPrice() external view returns(uint256);

}
pragma solidity 0.4.25;



contract TBoxManager is TBoxToken {


    uint256 public globalETH;

    uint256 public precision = 100000;

    ISettings public settings;

    Box[] public boxes;

    struct Box {
        uint256     collateral;
        uint256     tmvReleased;
    }

    event Created(uint256 indexed id, address owner, uint256 collateral, uint256 tmvReleased);

    event Closed(uint256 indexed id, address indexed owner, address indexed closer);

    event Capitalized(uint256 indexed id, address indexed owner, address indexed who, uint256 tmvAmount, uint256 totalEth, uint256 userEth);

    event EthWithdrawn(uint256 indexed id, uint256 value, address who);

    event TmvWithdrawn(uint256 indexed id, uint256 value, address who);

    event EthAdded(uint256 indexed id, uint256 value, address who);

    event TmvAdded(uint256 indexed id, uint256 value, address who);

    modifier validTx() {

        require(tx.gasprice <= settings.gasPriceLimit(), "Gas price is greater than allowed");
        _;
    }

    modifier onlyAdmin() {

        require(settings.isFeeManager(msg.sender), "You have no access");
        _;
    }

    modifier onlyExists(uint256 _id) {

        require(_exists(_id), "Box does not exist");
        _;
    }

    modifier onlyApprovedOrOwner(uint256 _id) {

        require(_isApprovedOrOwner(msg.sender, _id), "Box isn't your");
        _;
    }

    constructor(address _settings) TBoxToken("TBoxToken", "TBX") public {
        settings = ISettings(_settings);
    }

    function() external payable {
        create(0);
    }

    function withdrawFee(address _beneficiary) external onlyAdmin {

        require(_beneficiary != address(0), "Zero address, be careful");

        uint256 _fees = address(this).balance.sub(globalETH);

        require(_fees > 0, "There is no available fees");

        _beneficiary.transfer(_fees);
    }

    function create(uint256 _tokensToWithdraw) public payable validTx returns (uint256) {

        require(msg.value >= settings.minDeposit(), "Deposit is very small");

        if (_tokensToWithdraw > 0) {

            uint256 _tokenLimit = overCapWithdrawableTmv(msg.value);

            uint256 _maxGlobal = globalWithdrawableTmv(msg.value);

            if (_tokenLimit > _maxGlobal) {
                _tokenLimit = _maxGlobal;
            }

            uint256 _local = defaultWithdrawableTmv(msg.value);

            if (_tokenLimit < _local) {
                _tokenLimit = _local;
            }

            require(_tokensToWithdraw <= _tokenLimit, "Token amount is more than available");

            IToken(settings.tmvAddress()).mint(msg.sender, _tokensToWithdraw);
        }

        uint256 _id = boxes.push(Box(msg.value, _tokensToWithdraw)).sub(1);

        globalETH = globalETH.add(msg.value);

        _mint(msg.sender, _id);

        emit Created(_id, msg.sender, msg.value, _tokensToWithdraw);

        return _id;
    }

    function close(uint256 _id) external onlyApprovedOrOwner(_id) {


        address _owner = _tokenOwner[_id];

        uint256 _tokensNeed = boxes[_id].tmvReleased;
        _burnTMV(msg.sender, _tokensNeed);

        uint256 _collateral = boxes[_id].collateral;

        _burn(_owner, _id);

        delete boxes[_id];

        msg.sender.transfer(_collateral);

        globalETH = globalETH.sub(_collateral);

        emit Closed(_id, _owner, msg.sender);
    }

    function capitalizeMax(uint256 _id) external {

        capitalize(_id, maxCapAmount(_id));
    }

    function capitalize(uint256 _id, uint256 _tmv) public validTx {


        uint256 _maxCapAmount = maxCapAmount(_id);

        require(_tmv <= _maxCapAmount && _tmv >= 10 ** 17, "Tokens amount out of range");

        boxes[_id].tmvReleased = boxes[_id].tmvReleased.sub(_tmv);

        uint256 _equivalentETH = _tmv.mul(precision).div(rate());

        uint256 _fee = _tmv.mul(settings.sysFee()).div(rate());

        uint256 _userReward = _tmv.mul(settings.userFee()).div(rate());

        boxes[_id].collateral = boxes[_id].collateral.sub(_fee.add(_userReward).add(_equivalentETH));

        globalETH = globalETH.sub(_fee.add(_userReward).add(_equivalentETH));

        _burnTMV(msg.sender, _tmv);

        msg.sender.transfer(_equivalentETH.add(_userReward));

        emit Capitalized(_id, ownerOf(_id), msg.sender, _tmv, _equivalentETH.add(_userReward).add(_fee), _equivalentETH.add(_userReward));
    }

    function withdrawEthMax(uint256 _id) external {

        withdrawEth(_id, withdrawableEth(_id));
    }

    function withdrawEth(uint256 _id, uint256 _amount) public onlyApprovedOrOwner(_id) validTx {

        require(_amount > 0, "Withdrawing zero");

        require(_amount <= withdrawableEth(_id), "You can't withdraw so much");

        boxes[_id].collateral = boxes[_id].collateral.sub(_amount);

        globalETH = globalETH.sub(_amount);

        msg.sender.transfer(_amount);

        emit EthWithdrawn(_id, _amount, msg.sender);
    }

    function withdrawTmvMax(uint256 _id) external onlyApprovedOrOwner(_id) {

        withdrawTmv(_id, boxWithdrawableTmv(_id));
    }

    function withdrawTmv(uint256 _id, uint256 _amount) public onlyApprovedOrOwner(_id) validTx {

        require(_amount > 0, "Withdrawing zero");

        require(_amount <= boxWithdrawableTmv(_id), "You can't withdraw so much");

        boxes[_id].tmvReleased = boxes[_id].tmvReleased.add(_amount);

        IToken(settings.tmvAddress()).mint(msg.sender, _amount);

        emit TmvWithdrawn(_id, _amount, msg.sender);
    }

    function addEth(uint256 _id) external payable onlyExists(_id) {

        require(msg.value > 0, "Don't add 0");

        boxes[_id].collateral = boxes[_id].collateral.add(msg.value);

        globalETH = globalETH.add(msg.value);

        emit EthAdded(_id, msg.value, msg.sender);
    }

    function addTmv(uint256 _id, uint256 _amount) external onlyExists(_id) {

        require(_amount > 0, "Don't add 0");

        require(_amount <= boxes[_id].tmvReleased, "Too much tokens");

        _burnTMV(msg.sender, _amount);
        boxes[_id].tmvReleased = boxes[_id].tmvReleased.sub(_amount);

        emit TmvAdded(_id, _amount, msg.sender);
    }

    function closeDust(uint256 _id) external onlyExists(_id) validTx {

        require(collateralPercent(_id) >= settings.minStability(), "This Box isn't collapsable");

        require(boxes[_id].collateral.mul(rate()) < precision.mul(3).mul(10 ** 18), "It's only possible to collapse dust");

        uint256 _tmvReleased = boxes[_id].tmvReleased;
        _burnTMV(msg.sender, _tmvReleased);

        uint256 _collateral = boxes[_id].collateral;

        uint256 _eth = _tmvReleased.mul(precision).div(rate());

        uint256 _userReward = _tmvReleased.mul(settings.userFee()).div(rate());

        address _owner = ownerOf(_id);

        delete boxes[_id];

        _burn(_owner, _id);

        msg.sender.transfer(_eth.add(_userReward));

        globalETH = globalETH.sub(_collateral);

        emit Closed(_id, _owner, msg.sender);
    }

    function _burnTMV(address _from, uint256 _amount) internal {

        if (_amount > 0) {
            require(IToken(settings.tmvAddress()).balanceOf(_from) >= _amount, "You don't have enough tokens");
            IToken(settings.tmvAddress()).burnLogic(_from, _amount);
        }
    }

    function rate() public view returns(uint256) {

        return IOracle(settings.oracleAddress()).ethUsdPrice();
    }

    function boxWithdrawableTmv(uint256 _id) public view onlyExists(_id) returns(uint256) {

        Box memory box = boxes[_id];

        uint256 _amount = withdrawableTmv(box.collateral);

        if (box.tmvReleased >= _amount) {
            return 0;
        }

        return _amount.sub(box.tmvReleased);
    }

    function withdrawableEth(uint256 _id) public view onlyExists(_id) returns(uint256) {


        uint256 _avlbl = _freeEth(_id);
        if (_avlbl == 0) {
            return 0;
        }
        uint256 _rest = boxes[_id].collateral.sub(_avlbl);
        if (_rest < settings.minDeposit()) {
            return boxes[_id].collateral.sub(settings.minDeposit());
        }
        else return _avlbl;
    }

    function _freeEth(uint256 _id) internal view returns(uint256) {

        Box memory box = boxes[_id];

        if (box.tmvReleased == 0) {
            return box.collateral;
        }

        uint256 _maxGlobal = globalWithdrawableEth();
        uint256 _globalAvailable;

        if (_maxGlobal > 0) {
            uint256 _need = overCapFrozenEth(box.tmvReleased);
            if (box.collateral > _need) {
                uint256 _free = box.collateral.sub(_need);
                if (_free > _maxGlobal) {
                    _globalAvailable = _maxGlobal;
                }

                else return _free;
            }
        }

        uint256 _frozen = defaultFrozenEth(box.tmvReleased);
        if (box.collateral > _frozen) {
            uint256 _localAvailable = box.collateral.sub(_frozen);
            return (_localAvailable > _globalAvailable) ? _localAvailable : _globalAvailable;
        } else {
            return _globalAvailable;
        }

    }

    function collateralPercent(uint256 _id) public view onlyExists(_id) returns(uint256) {

        Box memory box = boxes[_id];
        if (box.tmvReleased == 0) {
            return 10**27; //some unreachable number
        }
        uint256 _ethCollateral = box.collateral;
        return _ethCollateral.mul(rate()).div(box.tmvReleased);
    }

    function isApprovedOrOwner(address _spender, uint256 _tokenId) external view returns (bool) {

        return _isApprovedOrOwner(_spender, _tokenId);
    }

    function globalCollateralization() public view returns (uint256) {

        uint256 _supply = IToken(settings.tmvAddress()).totalSupply();
        if (_supply == 0) {
            return settings.globalTargetCollateralization();
        }
        return globalETH.mul(rate()).div(_supply);
    }

    function globalWithdrawableTmv(uint256 _value) public view returns (uint256) {

        uint256 _supply = IToken(settings.tmvAddress()).totalSupply();
        if (globalCollateralization() <= settings.globalTargetCollateralization()) {
            return 0;
        }
        uint256 _totalBackedTmv = defaultWithdrawableTmv(globalETH.add(_value));
        return _totalBackedTmv.sub(_supply);
    }

    function globalWithdrawableEth() public view returns (uint256) {

        uint256 _supply = IToken(settings.tmvAddress()).totalSupply();
        if (globalCollateralization() <= settings.globalTargetCollateralization()) {
            return 0;
        }
        uint256 _need = defaultFrozenEth(_supply);
        return globalETH.sub(_need);
    }

    function defaultWithdrawableTmv(uint256 _collateral) public view returns (uint256) {

        uint256 _num = _collateral.mul(rate());
        uint256 _div = settings.globalTargetCollateralization();
        return _num.div(_div);
    }

    function overCapWithdrawableTmv(uint256 _collateral) public view returns (uint256) {

        uint256 _num = _collateral.mul(rate());
        uint256 _div = settings.ratio();
        return _num.div(_div);
    }

    function defaultFrozenEth(uint256 _supply) public view returns (uint256) {

        return _supply.mul(settings.globalTargetCollateralization()).div(rate());
    }


    function overCapFrozenEth(uint256 _supply) public view returns (uint256) {

        return _supply.mul(settings.ratio()).div(rate());
    }


    function maxCapAmount(uint256 _id) public view onlyExists(_id) returns (uint256) {

        uint256 _colP = collateralPercent(_id);
        require(_colP >= settings.minStability() && _colP < settings.maxStability(), "It's only possible to capitalize toxic Boxes");

        Box memory box = boxes[_id];

        uint256 _num = box.tmvReleased.mul(settings.ratio()).sub(box.collateral.mul(rate()));
        uint256 _div = settings.ratio().sub(settings.minStability());
        return _num.div(_div);
    }

    function withdrawableTmv(uint256 _collateral) public view returns(uint256) {

        uint256 _amount = overCapWithdrawableTmv(_collateral);
        uint256 _maxGlobal = globalWithdrawableTmv(0);
        if (_amount > _maxGlobal) {
            _amount = _maxGlobal;
        }
        uint256 _local = defaultWithdrawableTmv(_collateral);
        if (_amount < _local) {
            _amount = _local;
        }
        return _amount;
    }

    function withdrawPercent(uint256 _collateral) external view returns(uint256) {

        uint256 _amount = overCapWithdrawableTmv(_collateral);
        uint256 _maxGlobal = globalWithdrawableTmv(_collateral);
        if (_amount > _maxGlobal) {
            _amount = _maxGlobal;
        }
        uint256 _local = defaultWithdrawableTmv(_collateral);
        if (_amount < _local) {
            _amount = _local;
        }
        return _collateral.mul(rate()).div(_amount);
    }
}
