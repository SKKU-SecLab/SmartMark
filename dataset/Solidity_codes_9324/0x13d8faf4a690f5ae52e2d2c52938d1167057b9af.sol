

pragma solidity ^0.8.0;
pragma abicoder v2;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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
}

library Counters {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}

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
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

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

abstract contract ERC20Interface {
  function transferFrom(address from, address to, uint256 tokenId) public virtual;
  function transfer(address recipient, uint256 amount) public virtual;
}

abstract contract ERC721Interface {
  function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual;
  function balanceOf(address owner) public virtual view returns (uint256 balance) ;
}

abstract contract ERC1155Interface {
  function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public virtual;
}

abstract contract customInterface {
  function bridgeSafeTransferFrom(address dapp, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public virtual;
}

contract BatchSwap is Ownable, Pausable, ReentrancyGuard, IERC721Receiver, IERC1155Receiver {

    address constant ERC20      = 0x90b7cf88476cc99D295429d4C1Bb1ff52448abeE;
    address constant ERC721     = 0x58874d2951524F7f851bbBE240f0C3cF0b992d79;
    address constant ERC1155    = 0xEDfdd7266667D48f3C9aB10194C3d325813d8c39;

    address public TRADESQUAD = 0xdbD4264248e2f814838702E0CB3015AC3a7157a1;
    address payable public VAULT = payable(0x48c45a687173ec396353cD1E507B26Fa4F6Ff6D9);

    mapping (address => address) dappRelations;

    mapping (address => bool) whiteList;
    
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    uint256 constant secs = 86400;
    
    Counters.Counter private _swapIds;

    bool private swapFlag;
    
    struct swapStruct {
        address dapp;
        address typeStd;
        uint256[] tokenId;
        uint256[] blc;
        bytes data;
    }
    
    enum swapStatus { Opened, Closed, Cancelled }
    
    struct swapIntent {
        uint256 id;
        address payable addressOne;
        uint256 valueOne;
        address payable addressTwo;
        uint256 valueTwo;
        uint256 swapStart;
        uint256 swapEnd;
        uint256 swapFee;
        swapStatus status;
    }
    
    mapping(uint256 => swapStruct[]) nftsOne;
    mapping(uint256 => swapStruct[]) nftsTwo;

    struct paymentStruct {
        bool status;
        uint256 value;
    }
    
    mapping (address => swapIntent[]) swapList;
    mapping (uint256 => uint256) swapMatch;
    
    paymentStruct payment;

    mapping(uint256 => address) checksCreator;
    mapping(uint256 => address) checksCounterparty;
    
    
    event swapEvent(address indexed _creator, uint256 indexed time, swapStatus indexed _status, uint256 _swapId, address _swapCounterPart);
    event paymentReceived(address indexed _payer, uint256 _value);

    receive() external payable { 
        emit paymentReceived(msg.sender, msg.value);
    }
    
    function createSwapIntent(swapIntent memory _swapIntent, swapStruct[] memory _nftsOne, swapStruct[] memory _nftsTwo) payable public whenNotPaused nonReentrant {

        if(payment.status) {
            if(ERC721Interface(TRADESQUAD).balanceOf(msg.sender)==0) {
                require(msg.value>=payment.value.add(_swapIntent.valueOne), "Not enought WEI for handle the transaction");
                _swapIntent.swapFee = getWeiPayValueAmount() ;
            }
            else {
                require(msg.value>=_swapIntent.valueOne, "Not enought WEI for handle the transaction");
                _swapIntent.swapFee = 0 ;
            }
        }
        else
            require(msg.value>=_swapIntent.valueOne, "Not enought WEI for handle the transaction");

        _swapIntent.addressOne = payable(msg.sender);
        _swapIntent.id = _swapIds.current();
        checksCreator[_swapIntent.id] = _swapIntent.addressOne ;
        checksCounterparty[_swapIntent.id] = _swapIntent.addressTwo ;
        _swapIntent.swapStart = block.timestamp;
        _swapIntent.swapEnd = 0;
        _swapIntent.status = swapStatus.Opened ;

        swapMatch[_swapIds.current()] = swapList[msg.sender].length;
        swapList[msg.sender].push(_swapIntent);
        
        uint256 i;
        for(i=0; i<_nftsOne.length; i++)
            nftsOne[_swapIntent.id].push(_nftsOne[i]);
            
        for(i=0; i<_nftsTwo.length; i++)
            nftsTwo[_swapIntent.id].push(_nftsTwo[i]);
        
        for(i=0; i<nftsOne[_swapIntent.id].length; i++) {
            require(whiteList[nftsOne[_swapIntent.id][i].dapp], "A DAPP is not handled by the system");
            if(nftsOne[_swapIntent.id][i].typeStd == ERC20) {
                ERC20Interface(nftsOne[_swapIntent.id][i].dapp).transferFrom(_swapIntent.addressOne, address(this), nftsOne[_swapIntent.id][i].blc[0]);
            }
            else if(nftsOne[_swapIntent.id][i].typeStd == ERC721) {
                ERC721Interface(nftsOne[_swapIntent.id][i].dapp).safeTransferFrom(_swapIntent.addressOne, address(this), nftsOne[_swapIntent.id][i].tokenId[0], nftsOne[_swapIntent.id][i].data);
            }
            else if(nftsOne[_swapIntent.id][i].typeStd == ERC1155) {
                ERC1155Interface(nftsOne[_swapIntent.id][i].dapp).safeBatchTransferFrom(_swapIntent.addressOne, address(this), nftsOne[_swapIntent.id][i].tokenId, nftsOne[_swapIntent.id][i].blc, nftsOne[_swapIntent.id][i].data);
            }
            else {
                customInterface(dappRelations[nftsOne[_swapIntent.id][i].dapp]).bridgeSafeTransferFrom(nftsOne[_swapIntent.id][i].dapp, _swapIntent.addressOne, dappRelations[nftsOne[_swapIntent.id][i].dapp], nftsOne[_swapIntent.id][i].tokenId, nftsOne[_swapIntent.id][i].blc, nftsOne[_swapIntent.id][i].data);
            }
        }

        emit swapEvent(msg.sender, (block.timestamp-(block.timestamp%secs)), _swapIntent.status, _swapIntent.id, _swapIntent.addressTwo);
        _swapIds.increment();
    }
    
    function closeSwapIntent(address _swapCreator, uint256 _swapId) payable public whenNotPaused nonReentrant {

        require(checksCounterparty[_swapId] == msg.sender, "You're not the interested counterpart");    
        require(swapList[_swapCreator][swapMatch[_swapId]].status == swapStatus.Opened, "Swap Status is not opened");
        require(swapList[_swapCreator][swapMatch[_swapId]].addressTwo == msg.sender, "You're not the interested counterpart"); 

        if(payment.status) {
            if(ERC721Interface(TRADESQUAD).balanceOf(msg.sender)==0) {
                require(msg.value>=payment.value.add(swapList[_swapCreator][swapMatch[_swapId]].valueTwo), "Not enought WEI for handle the transaction");
                if(payment.value.add(swapList[_swapCreator][swapMatch[_swapId]].swapFee) > 0)
                    VAULT.transfer(payment.value.add(swapList[_swapCreator][swapMatch[_swapId]].swapFee));
            }
            else {
                require(msg.value>=swapList[_swapCreator][swapMatch[_swapId]].valueTwo, "Not enought WEI for handle the transaction");
                if(swapList[_swapCreator][swapMatch[_swapId]].swapFee>0)
                    VAULT.transfer(swapList[_swapCreator][swapMatch[_swapId]].swapFee);
            }
        }
        else
            require(msg.value>=swapList[_swapCreator][swapMatch[_swapId]].valueTwo, "Not enought WEI for handle the transaction");
        
        swapList[_swapCreator][swapMatch[_swapId]].addressTwo = payable(msg.sender);
        swapList[_swapCreator][swapMatch[_swapId]].swapEnd = block.timestamp;
        swapList[_swapCreator][swapMatch[_swapId]].status = swapStatus.Closed;
        
        uint256 i;
        for(i=0; i<nftsOne[_swapId].length; i++) {
            require(whiteList[nftsOne[_swapId][i].dapp], "A DAPP is not handled by the system");
            if(nftsOne[_swapId][i].typeStd == ERC20) {
                ERC20Interface(nftsOne[_swapId][i].dapp).transfer(swapList[_swapCreator][swapMatch[_swapId]].addressTwo, nftsOne[_swapId][i].blc[0]);
            }
            else if(nftsOne[_swapId][i].typeStd == ERC721) {
                ERC721Interface(nftsOne[_swapId][i].dapp).safeTransferFrom(address(this), swapList[_swapCreator][swapMatch[_swapId]].addressTwo, nftsOne[_swapId][i].tokenId[0], nftsOne[_swapId][i].data);
            }
            else if(nftsOne[_swapId][i].typeStd == ERC1155) {
                ERC1155Interface(nftsOne[_swapId][i].dapp).safeBatchTransferFrom(address(this), swapList[_swapCreator][swapMatch[_swapId]].addressTwo, nftsOne[_swapId][i].tokenId, nftsOne[_swapId][i].blc, nftsOne[_swapId][i].data);
            }
            else {
                customInterface(dappRelations[nftsOne[_swapId][i].dapp]).bridgeSafeTransferFrom(nftsOne[_swapId][i].dapp, dappRelations[nftsOne[_swapId][i].dapp], swapList[_swapCreator][swapMatch[_swapId]].addressTwo, nftsOne[_swapId][i].tokenId, nftsOne[_swapId][i].blc, nftsOne[_swapId][i].data);
            }
        }
        if(swapList[_swapCreator][swapMatch[_swapId]].valueOne > 0)
            swapList[_swapCreator][swapMatch[_swapId]].addressTwo.transfer(swapList[_swapCreator][swapMatch[_swapId]].valueOne);
        
        for(i=0; i<nftsTwo[_swapId].length; i++) {
            require(whiteList[nftsTwo[_swapId][i].dapp], "A DAPP is not handled by the system");
            if(nftsTwo[_swapId][i].typeStd == ERC20) {
                ERC20Interface(nftsTwo[_swapId][i].dapp).transferFrom(swapList[_swapCreator][swapMatch[_swapId]].addressTwo, swapList[_swapCreator][swapMatch[_swapId]].addressOne, nftsTwo[_swapId][i].blc[0]);
            }
            else if(nftsTwo[_swapId][i].typeStd == ERC721) {
                ERC721Interface(nftsTwo[_swapId][i].dapp).safeTransferFrom(swapList[_swapCreator][swapMatch[_swapId]].addressTwo, swapList[_swapCreator][swapMatch[_swapId]].addressOne, nftsTwo[_swapId][i].tokenId[0], nftsTwo[_swapId][i].data);
            }
            else if(nftsTwo[_swapId][i].typeStd == ERC1155) {
                ERC1155Interface(nftsTwo[_swapId][i].dapp).safeBatchTransferFrom(swapList[_swapCreator][swapMatch[_swapId]].addressTwo, swapList[_swapCreator][swapMatch[_swapId]].addressOne, nftsTwo[_swapId][i].tokenId, nftsTwo[_swapId][i].blc, nftsTwo[_swapId][i].data);
            }
            else {
                customInterface(dappRelations[nftsTwo[_swapId][i].dapp]).bridgeSafeTransferFrom(nftsTwo[_swapId][i].dapp, swapList[_swapCreator][swapMatch[_swapId]].addressTwo, swapList[_swapCreator][swapMatch[_swapId]].addressOne, nftsTwo[_swapId][i].tokenId, nftsTwo[_swapId][i].blc, nftsTwo[_swapId][i].data);
            }
        }
        if(swapList[_swapCreator][swapMatch[_swapId]].valueTwo>0)
            swapList[_swapCreator][swapMatch[_swapId]].addressOne.transfer(swapList[_swapCreator][swapMatch[_swapId]].valueTwo);

        emit swapEvent(msg.sender, (block.timestamp-(block.timestamp%secs)), swapStatus.Closed, _swapId, _swapCreator);
    }

    function cancelSwapIntent(uint256 _swapId) public nonReentrant {

        require(checksCreator[_swapId] == msg.sender, "You're not the interested counterpart");
        require(swapList[msg.sender][swapMatch[_swapId]].addressOne == msg.sender, "You're not the interested counterpart");   
        require(swapList[msg.sender][swapMatch[_swapId]].status == swapStatus.Opened, "Swap Status is not opened");

        if(swapList[msg.sender][swapMatch[_swapId]].swapFee>0)
            payable(msg.sender).transfer(swapList[msg.sender][swapMatch[_swapId]].swapFee);
        uint256 i;
        for(i=0; i<nftsOne[_swapId].length; i++) {
            if(nftsOne[_swapId][i].typeStd == ERC20) {
                ERC20Interface(nftsOne[_swapId][i].dapp).transfer(swapList[msg.sender][swapMatch[_swapId]].addressOne, nftsOne[_swapId][i].blc[0]);
            }
            else if(nftsOne[_swapId][i].typeStd == ERC721) {
                ERC721Interface(nftsOne[_swapId][i].dapp).safeTransferFrom(address(this), swapList[msg.sender][swapMatch[_swapId]].addressOne, nftsOne[_swapId][i].tokenId[0], nftsOne[_swapId][i].data);
            }
            else if(nftsOne[_swapId][i].typeStd == ERC1155) {
                ERC1155Interface(nftsOne[_swapId][i].dapp).safeBatchTransferFrom(address(this), swapList[msg.sender][swapMatch[_swapId]].addressOne, nftsOne[_swapId][i].tokenId, nftsOne[_swapId][i].blc, nftsOne[_swapId][i].data);
            }
            else {
                customInterface(dappRelations[nftsOne[_swapId][i].dapp]).bridgeSafeTransferFrom(nftsOne[_swapId][i].dapp, dappRelations[nftsOne[_swapId][i].dapp], swapList[msg.sender][swapMatch[_swapId]].addressOne, nftsOne[_swapId][i].tokenId, nftsOne[_swapId][i].blc, nftsOne[_swapId][i].data);
            }
        }

        if(swapList[msg.sender][swapMatch[_swapId]].valueOne > 0)
            swapList[msg.sender][swapMatch[_swapId]].addressOne.transfer(swapList[msg.sender][swapMatch[_swapId]].valueOne);

        swapList[msg.sender][swapMatch[_swapId]].swapEnd = block.timestamp;
        swapList[msg.sender][swapMatch[_swapId]].status = swapStatus.Cancelled;
        emit swapEvent(msg.sender, (block.timestamp-(block.timestamp%secs)), swapStatus.Cancelled, _swapId, address(0));
    }

    function setTradeSquadAddress(address _tradeSquad) public onlyOwner {

        TRADESQUAD = _tradeSquad ;
    }

    function setVaultAddress(address payable _vault) public onlyOwner {

        VAULT = _vault ;
    }

    function setDappRelation(address _dapp, address _customInterface) public onlyOwner {

        dappRelations[_dapp] = _customInterface;
    }

    function setWhitelist(address[] memory _dapp, bool _status) public onlyOwner {

        uint256 i;
        for(i=0; i< _dapp.length; i++) {
            whiteList[_dapp[i]] = _status;
        }
    }

    function editCounterPart(uint256 _swapId, address payable _counterPart) public {

        require(checksCreator[_swapId] == msg.sender, "You're not the interested counterpart");
        require(msg.sender == swapList[msg.sender][swapMatch[_swapId]].addressOne, "Message sender must be the swap creator");
        checksCounterparty[_swapId] = _counterPart;
        swapList[msg.sender][swapMatch[_swapId]].addressTwo = _counterPart;
    }

    function setPayment(bool _status, uint256 _value) public onlyOwner whenNotPaused {

        payment.status = _status;
        payment.value = _value * (1 wei);
    }

    function pauseContract(bool _paused) public onlyOwner {

        _paused?_pause():_unpause();
    }

    function getWhiteList(address _address) public view returns(bool) {

        return whiteList[_address];
    }

    function getWeiPayValueAmount() public view returns(uint256) {

        return payment.value;
    }

    function getSwapIntentByAddress(address _creator, uint256 _swapId) public view returns(swapIntent memory) {

        return swapList[_creator][swapMatch[_swapId]];
    }
    
    function getSwapStructSize(uint256 _swapId, bool _nfts) public view returns(uint256) {

        if(_nfts)
            return nftsOne[_swapId].length ;
        else
            return nftsTwo[_swapId].length ;
    }

    function getSwapStruct(uint256 _swapId, bool _nfts, uint256 _index) public view returns(swapStruct memory) {

        if(_nfts)
            return nftsOne[_swapId][_index] ;
        else
            return nftsTwo[_swapId][_index] ;
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external override returns (bytes4) {

        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
    function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes calldata data) external override returns (bytes4) {

        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }
    function onERC1155BatchReceived(address operator, address from, uint256[] calldata id, uint256[] calldata value, bytes calldata data) external override returns (bytes4) {

        return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
    }
    function supportsInterface(bytes4 interfaceID) public view virtual override returns (bool) {

        return  interfaceID == 0x01ffc9a7 || interfaceID == 0x4e2312e0;
    }
}