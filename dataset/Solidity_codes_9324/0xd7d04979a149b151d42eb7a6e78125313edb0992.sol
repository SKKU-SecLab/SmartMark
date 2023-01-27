
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

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {

        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

}// MIT LICENSE

pragma solidity >=0.6.0 <0.8.9;
pragma experimental ABIEncoderV2;

interface ISimps {
    function ownerOf(uint id) external view returns (address);
    function isQueen(uint16 id) external view returns (bool);
    function transferFrom(address from, address to, uint tokenId) external;
    function safeTransferFrom(address from, address to, uint tokenId, bytes calldata _data ) external;
}

interface ILLove {
    function mint(address account, uint amount) external;
}

interface IRandom {
    function updateRandomIndex() external;
    function getSomeRandomNumber(uint _seed, uint _limit) external view returns (uint16);
    
}

contract SimpsOffice is Ownable, IERC721Receiver {
    uint16 public version=21;
    bool private _paused = false;

    uint16 private _randomIndex = 0;
    uint private _randomCalls = 0;
    mapping(uint => address) private _randomSource;

    struct Stake {
        uint16 tokenId;
        uint80 value;
        address owner;
        uint bouns;
    }

    
    uint public startExtraTimestamp;
    uint public endExtraTimeStamp;
    uint8 public extraPercentage;

    event TokenStaked(address owner, uint16 tokenId, uint value);
    event SimpClaimed(uint16 tokenId, uint earned, bool unstaked);
    event QueenClaimed(uint16 tokenId, uint earned, bool unstaked);

    ISimps public simpsCity;
    ILLove public love;
    IRandom public random;

    mapping(uint256 => uint256) public simpIndices;
    mapping(address => Stake[]) public simpStake;

    mapping(uint256 => uint256) public queenIndices;
    mapping(address => Stake[]) public queenStake;

    mapping(address => uint256) public mercyJackpot;
    mapping(address => uint256) public loveBoost;

    address[] public simpHolders;
    address[] public queenHolders;

    uint16[10] public mercyJackpotTokens;
    address[10] public mercyJackpotWinners;

    uint public totalSimpStaked =0 ;
    uint public totalQueenStaked = 0;
    uint public unaccountedRewards = 0;
    uint public mercyJackpotPool =0;
    uint public lastMercyJackpotPayout = 0;

    uint public constant DAILY_LLOVE_RATE = 10000 ether;
    uint public constant MINIMUM_TIME_TO_EXIT = 2 days;
    uint public constant TAX_PERCENTAGE = 15;
    uint public constant TAX_MERCYJACKPOT = 5;
    uint public MERCY_JACKPOT_PAY_PERIOD = 6 hours;
    uint16 public MERCY_JACKPOT_PAYER_COUNT = 10;
    uint public constant PAY_PERIOD = 1 days;
    
    uint public constant ALL_LOVE_IN_THE_UNIVERSE = 4320000000 ether;

    uint public totalLoveEarned;

    uint public lastClaimTimestamp;
    uint public queenReward = 0;


    constructor(){

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

    function setSimps(address _simpsCity) external onlyOwner {
        simpsCity = ISimps(_simpsCity);
    }

    function setLove(address _love) external onlyOwner {
        love = ILLove(_love);
    }

    function setRandom(address _random) external onlyOwner {
        random = IRandom(_random);
    }

    function getAccountSimps(address user) external view returns (Stake[] memory) {
        return simpStake[user];
    }

    function getAccountQueens(address user) external view returns (Stake[] memory) {
        return queenStake[user];
    }

    function addTokensToStake(address account, uint16[] calldata tokenIds) external {
        require(account == msg.sender || msg.sender == address(simpsCity), "You do not have a permission to do that");

        for (uint i = 0; i < tokenIds.length; i++) {
            if (msg.sender != address(simpsCity)) {
                require(simpsCity.ownerOf(tokenIds[i]) == msg.sender, "This NTF does not belong to msg.sender address");
                simpsCity.transferFrom(msg.sender, address(this), tokenIds[i]);
            } else if (tokenIds[i] == 0) {
                continue; // there may be gaps in the array for stolen tokens
            }

            if (simpsCity.isQueen(tokenIds[i])) {
                _stakeQueens(account, tokenIds[i]);
            } else {
                _stakeSimps(account, tokenIds[i]);
            }
        }
    }

    function _stakeSimps(address account, uint16 tokenId) internal whenNotPaused _updateEarnings {
        totalSimpStaked += 1;

        if (simpStake[account].length == 0) {
            simpHolders.push(account);
        }

        simpIndices[tokenId] = simpStake[account].length;
        simpStake[account].push(Stake({
            owner: account,
            tokenId: uint16(tokenId),
            value: uint80(block.timestamp),
            bouns:0
        }));
        emit TokenStaked(account, tokenId, block.timestamp);
    }


    function _stakeQueens(address account, uint16 tokenId) internal {
        totalQueenStaked += 1;

        if (queenStake[account].length == 0) {
            queenHolders.push(account);
        }

        queenIndices[tokenId] = queenStake[account].length;
        queenStake[account].push(Stake({
            owner: account,
            tokenId: uint16(tokenId),
            value: uint80(queenReward),
            bouns:0
            }));

        emit TokenStaked(account, tokenId, queenReward);
    }

    function addExtraPay(uint start,uint end,uint8 percentage) public onlyOwner{
        startExtraTimestamp = start;
        endExtraTimeStamp = end;
        extraPercentage = percentage;
    }

    function claimFromStake(uint16[] calldata tokenIds, bool unstake) external whenNotPaused _updateEarnings {
        uint owed = 0;
        for (uint i = 0; i < tokenIds.length; i++) {
            if (!simpsCity.isQueen(tokenIds[i])) {
                owed += _claimFromSimp(tokenIds[i], unstake);
            } else {
                owed += _claimFromQueen(tokenIds[i], unstake);
            }
        }

        if(_checkMercyJackpotPayoutTime()){
            _mercyJackpotPayout2();
        }

        if (owed == 0) return;
        love.mint(msg.sender, owed);
    }

    function _claimFromSimp(uint16 tokenId, bool unstake) internal returns (uint owed) {
        Stake memory stake = simpStake[msg.sender][simpIndices[tokenId]];
        require(stake.owner == msg.sender, "This NTF does not belong to msg.sender address");
        require(!(unstake && block.timestamp - stake.value < MINIMUM_TIME_TO_EXIT), "Need to wait 2 days since last claim");

        if (totalLoveEarned < ALL_LOVE_IN_THE_UNIVERSE) {
            owed = ((block.timestamp - stake.value) * DAILY_LLOVE_RATE) / PAY_PERIOD;
        } else if (stake.value > lastClaimTimestamp) {
            owed = 0; // $LLOVE production stopped already
        } else {
            owed = ((lastClaimTimestamp - stake.value) * DAILY_LLOVE_RATE) / PAY_PERIOD; // stop earning additional $LLOVE if it's all been earned
        }

        if(endExtraTimeStamp>0){
            if(block.timestamp<= startExtraTimestamp){
            }else if(stake.value<=startExtraTimestamp && block.timestamp<=endExtraTimeStamp){
                owed = owed+((block.timestamp-startExtraTimestamp)* DAILY_LLOVE_RATE)*extraPercentage/100 / PAY_PERIOD;
            }else if(stake.value>=startExtraTimestamp && block.timestamp<=endExtraTimeStamp){
                owed = owed+ ((block.timestamp - stake.value)* DAILY_LLOVE_RATE)*extraPercentage/100/ PAY_PERIOD;
            }else if(stake.value<=startExtraTimestamp && block.timestamp>=endExtraTimeStamp){
                owed = owed+ (endExtraTimeStamp-startExtraTimestamp)*extraPercentage/100/ PAY_PERIOD;
            }else if(stake.value>=startExtraTimestamp && block.timestamp>=endExtraTimeStamp){
                owed = owed+ (endExtraTimeStamp-stake.value)*extraPercentage/100/ PAY_PERIOD;
            }
        }

        owed = owed+stake.bouns;

        if (unstake) {
            if (random.getSomeRandomNumber(tokenId, 100) <= 50) {
                _payQueenTax((owed * 95) / 100);
                _paymercyJackpotPool((owed * TAX_MERCYJACKPOT)/100);
                owed = 0;
            }
            random.updateRandomIndex();
            totalSimpStaked -= 1;

            Stake memory lastStake = simpStake[msg.sender][simpStake[msg.sender].length - 1];
            simpStake[msg.sender][simpIndices[tokenId]] = lastStake;
            simpIndices[lastStake.tokenId] = simpIndices[tokenId];
            simpStake[msg.sender].pop();
            delete simpIndices[tokenId];
            updateSimpOwnerAddressList(msg.sender);
            simpsCity.safeTransferFrom(address(this), msg.sender, tokenId, "");
        } else {
            _payQueenTax((owed * TAX_PERCENTAGE) / 100);
            _paymercyJackpotPool((owed * TAX_MERCYJACKPOT)/100); // Pay some $LLOVE to queens!
            owed = (owed * (100 - (TAX_PERCENTAGE+TAX_MERCYJACKPOT))) / 100;
            owed = owed + simpStake[msg.sender][simpIndices[tokenId]].bouns; 
            uint80 timestamp = uint80(block.timestamp);

            simpStake[msg.sender][simpIndices[tokenId]] = Stake({
                owner: msg.sender,
                tokenId: uint16(tokenId),
                value: timestamp,
                bouns:0
            }); // reset stake
        }

        emit SimpClaimed(tokenId, owed, unstake);
    }

    function _claimFromQueen(uint16 tokenId, bool unstake) internal returns (uint owed) {
        require(simpsCity.ownerOf(tokenId) == address(this), "This NTF does not belong to contract address");

        Stake memory stake = queenStake[msg.sender][queenIndices[tokenId]];

        require(stake.owner == msg.sender, "This NTF does not belong to msg sender address");
        owed = (queenReward - stake.value);
        owed = owed+stake.bouns;
        if (unstake) {
            totalQueenStaked -= 1; // Remove Alpha from total staked

            Stake memory lastStake = queenStake[msg.sender][queenStake[msg.sender].length - 1];
            queenStake[msg.sender][queenIndices[tokenId]] = lastStake;
            queenIndices[lastStake.tokenId] = queenIndices[tokenId];
            queenStake[msg.sender].pop();
            delete queenIndices[tokenId];
            updateQueenOwnerAddressList(msg.sender);

            simpsCity.safeTransferFrom(address(this), msg.sender, tokenId, "");
        } else {
            queenStake[msg.sender][queenIndices[tokenId]] = Stake({
                owner: msg.sender,
                tokenId: uint16(tokenId),
                value: uint80(queenReward),
                bouns:0
            }); // reset stake
        }
        emit QueenClaimed(tokenId, owed, unstake);
    }

    function startMercyJackpot() public onlyOwner{
        lastMercyJackpotPayout = block.timestamp; 
    }

    function setMercyJackpotPayPeriod(uint period) public onlyOwner{
        MERCY_JACKPOT_PAY_PERIOD = period; 
    }

    function setMercyJackpotPayerCount(uint16 count) public onlyOwner{
        MERCY_JACKPOT_PAYER_COUNT = count; 
    }

    function _checkMercyJackpotPayoutTime() internal returns (bool needPayOut){
        if(lastMercyJackpotPayout>0&&block.timestamp - lastMercyJackpotPayout > MERCY_JACKPOT_PAY_PERIOD){
            lastMercyJackpotPayout = lastMercyJackpotPayout + MERCY_JACKPOT_PAY_PERIOD*((block.timestamp - lastMercyJackpotPayout)/ MERCY_JACKPOT_PAY_PERIOD);
            return true;
        }else{
            return false;
        }
    }

    function checkMercyJackpotPayoutTime() public {
        _checkMercyJackpotPayoutTime();
    }


        


            

                




                


            




    function _mercyJackpotPayout2() internal {


        if(simpHolders.length<=MERCY_JACKPOT_PAYER_COUNT){
            uint payout = mercyJackpotPool/simpHolders.length;
            for(uint16 i =0; i <simpHolders.length; i++ ){
                mercyJackpotWinners[i] = simpHolders[i];
                love.mint(simpHolders[i], payout);
            }

        }else{
            uint payout = mercyJackpotPool/MERCY_JACKPOT_PAYER_COUNT;

            for(uint16 i =0; i<MERCY_JACKPOT_PAYER_COUNT; i++){
                mercyJackpotWinners[i] = simpHolders[random.getSomeRandomNumber(i,simpHolders.length-1)];
                love.mint(mercyJackpotWinners[i],payout);
            }

        }

        mercyJackpotPool = 0;

    }

    function mercyJackpotPayout() public{
         _mercyJackpotPayout2();
    }

    function getJackpotWinners() public view returns(address[] memory){
        address[] memory b = new address[](mercyJackpotWinners.length);
        for (uint i=0; i < mercyJackpotWinners.length; i++) {
            b[i] = mercyJackpotWinners[i];
        }
        return b;
    }

    function updateQueenOwnerAddressList(address account) internal {
        if (queenStake[account].length != 0) {
            return; // No need to update holders
        }

        address lastOwner = queenHolders[queenHolders.length - 1];
        uint indexOfHolder = 0;
        for (uint i = 0; i < queenHolders.length; i++) {
            if (queenHolders[i] == account) {
                indexOfHolder = i;
                break;
            }
        }
        queenHolders[indexOfHolder] = lastOwner;
        queenHolders.pop();
    }


    function updateSimpOwnerAddressList(address account) internal {
        if (simpStake[account].length != 0) {
            return; // No need to update holders
        }

        address lastOwner = simpHolders[simpHolders.length - 1];
        uint indexOfHolder = 0;
        for (uint i = 0; i < simpHolders.length; i++) {
            if (simpHolders[i] == account) {
                indexOfHolder = i;
                break;
            }
        }
        simpHolders[indexOfHolder] = lastOwner;
        simpHolders.pop();
    }


    function _payQueenTax(uint _amount) internal {
        if (totalQueenStaked == 0) {
            unaccountedRewards += _amount;
            return;
        }

        queenReward += (_amount + unaccountedRewards) / totalQueenStaked;
        unaccountedRewards = 0;
    }

    function _paymercyJackpotPool(uint _amount) internal {
        mercyJackpotPool += _amount;
    }


    modifier _updateEarnings() {
        if (totalLoveEarned < ALL_LOVE_IN_THE_UNIVERSE) {
            totalLoveEarned += ((block.timestamp - lastClaimTimestamp) * totalSimpStaked * DAILY_LLOVE_RATE) / PAY_PERIOD;
            lastClaimTimestamp = block.timestamp;
        }
        _;
    }


    function setPaused(bool _state) external onlyOwner {
        _paused = _state;
    }


    function randomQueenOwner() external returns (address) {
        if (totalQueenStaked == 0) return address(0x0);

        uint holderIndex = random.getSomeRandomNumber(totalQueenStaked, queenHolders.length);
        random.updateRandomIndex();

        return queenHolders[holderIndex];
    } 

    function onERC721Received(
        address,
        address from,
        uint,
        bytes calldata
    ) external  override returns (bytes4) {
        require(from == address(0x0), "Cannot send tokens to this contact directly");
        return IERC721Receiver.onERC721Received.selector;
    }
}