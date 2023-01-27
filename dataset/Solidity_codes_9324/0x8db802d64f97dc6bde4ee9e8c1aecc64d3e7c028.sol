



pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}





pragma solidity ^0.8.0;

interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}





pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}





pragma solidity ^0.8.0;

interface IERC721Metadata is IERC721 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}





pragma solidity ^0.8.0;

interface IERC721Enumerable is IERC721 {


    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}





pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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
}





pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}





pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant alphabet = "0123456789abcdef";

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
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}





pragma solidity ^0.8.0;

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}





pragma solidity ^0.8.0;








contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping (uint256 => address) private _owners;

    mapping (address => uint256) private _balances;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC721Metadata).interfaceId
            || super.supportsInterface(interfaceId);
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

    mapping(uint => string) public uri;
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return uri[tokenId];
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || ERC721.isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || ERC721.isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {

        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
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

    function _transfer(address from, address to, uint256 tokenId) internal virtual {

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

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {

        if (to.isContract()) {
            IERC721Receiver(to).onERC721Received(from, tokenId, _data);
        }
        return true;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }

}
    
    pragma solidity ^ 0.8.0;
    contract GreenPointLandReserves{
        address THIS = address(this);
        uint $ = 1e18;
        uint genesis;
        Totem public totemNFT;
        ERC20 MVT = ERC20(0x3D46454212c61ECb7b31248047Fa033120B88668);
        ERC20 MDT = ERC20(0x32A087D5fdF8c84eC32554c56727a7C81124544E);
        ERC20 COLOR = ERC20(0xe324C8cF74899461Ef7aD2c3EB952DA7819aabc5);
        Oracle public ORACLE = Oracle(address(0));
        
        address public GLR_nonprofit;
        address public DEV;
        address public oracleTeller;
        uint public GLR_funds;
        uint public devPot;

        constructor(){
            genesis = block.timestamp;
            nextFloorRaisingTime = genesis + 86400 * 45;
            totemNFT = new Totem("Totem","TOTEM");
            GLR_nonprofit = msg.sender;
            DEV = msg.sender;
            oracleTeller = msg.sender;
        }

        function shiftOwnership(address addr) public{
            require(msg.sender == GLR_nonprofit);
            GLR_nonprofit = addr;
        }

        function GLR_pullFunds() public{
            require(msg.sender == GLR_nonprofit && GLR_funds > 0);
            uint cash = GLR_funds;
            GLR_funds = 0;
            (bool success, ) = GLR_nonprofit.call{value:cash}("");
            require(success, "Transfer failed.");
        }

        function Dev_pullFunds() public{
            require(msg.sender == DEV && devPot > 0);
            uint cash = devPot;
            devPot = 0;
            (bool success, ) = DEV.call{value:cash}("");
            require(success, "Transfer failed.");
        }

        function shiftDev(address addr) public{
            require(msg.sender == DEV);
            DEV = addr;
        }

        function shiftOracleTeller(address addr) public{
            require(msg.sender == oracleTeller);
            oracleTeller = addr;
        }

        function setOracle(address addr) public{
            require(msg.sender == oracleTeller);
            ORACLE = Oracle(addr);
        }

        function globalData() public view returns(uint _MVT_to_rollout, uint _mvt5xHodlPool, uint _nextFloorRaisingTime, uint _floorPrice, uint _totalACRESupply, uint _totalAcreWeight, uint _totalTotemWeight){
            return (MVT_to_rollout, mvt5xHodlPool, nextFloorRaisingTime, floorPrice, _totalSupply, totalShares[ETHpool], totalTotemWeight);
        }
        
        function userData(address account) public view returns(uint acreBalance, uint totemWeight, uint acreDividends, uint totemDividends, bool MDT_approval, bool MVT_approval){
            return (balanceOf(account), shares[MVTpool][account], dividendsOf(ETHpool, account) + earnings[ETHpool][account], dividendsOf(MVTpool, account) + earnings[MVTpool][account], MDT.allowance(account,THIS)>$*1000000, MVT.allowance(account,THIS)>$*1000000);
        }

        function userData2(address account) public view returns(uint MDT_balance, uint MVT_balance, uint colorDividends){
            return ( MDT.balanceOf(account), MVT.balanceOf(account), colorDividendsOf(account) + earnings[COLORpool][account] );
        }

        uint mvt5xHodlPool;
        event PurchaseAcre(address boughtFor, uint acreBought);
        function purchaseAcre(address buyFor) public payable{
            if( buyFor == address(0) ){
                buyFor = msg.sender;
            }

            require(msg.value > 0 && msg.sender == tx.origin);
            uint MONEY = msg.value;
            uint forDev;
            if(block.timestamp - genesis <= 86400*365){forDev = MONEY * 6/1000;}
            devPot += forDev;

            uint val = MONEY - forDev;
            mint(buyFor, val);
            uint forBuyingMVT = val * (_totalSupply - totalTotemWeight + builder_totalShares) / _totalSupply;
            GLR_funds += val - forBuyingMVT;
            mvt5xHodlPool += forBuyingMVT;
            emit PurchaseAcre(buyFor, val);
            rolloutDepositedMVTRewards();
        }

        uint nextFloorRaisingTime;
        uint floorPrice = 0.00002 ether;
        bool firstBump = true;
        event Sell_MVT(uint mvtSold, uint cashout,uint forManifest,uint forDaily);
        function sell_MVT(uint amount) public{
            address payable sender = payable(msg.sender);
            require( MVT.transferFrom(sender, THIS, amount) );
            uint NOW = block.timestamp;
            
            if(NOW >= nextFloorRaisingTime){
                if(firstBump){
                    firstBump = false;
                    floorPrice = floorPrice * 10;
                }else{
                    floorPrice = floorPrice * 3;
                }
                nextFloorRaisingTime += 300 * 86400;
            }

            uint cost = floorPrice*amount/$;
            require( mvt5xHodlPool >= cost && cost > 0 );
            mvt5xHodlPool -= cost;

            uint forManifest = amount * ( totalTotemWeight - builder_totalShares) / _totalSupply;
            uint forDaily =  amount  - forManifest;
            MVT_to_rollout += forDaily;
            storeUpCommunityRewards(forManifest);
            emit Sell_MVT(amount, cost,forManifest, forDaily);
            (bool success, ) = sender.call{value:cost}("");
            require(success, "Transfer failed.");
        }

        mapping(uint => mapping(address => uint)) public  shares;
        mapping(uint => uint) public totalShares;
        mapping(uint => uint)  earningsPer;
        mapping(uint => mapping(address => uint)) payouts;
        mapping(uint => mapping(address => uint)) public  earnings;
        uint256 constant scaleFactor = 0x10000000000000000;
        uint constant ETHpool = 0;
        uint constant MVTpool = 1;
        uint constant COLORpool = 2;

        function withdraw(uint pool) public{
            address payable sender = payable(msg.sender);
            require(pool>=0 && pool<=2);


            if(pool == COLORpool){
                update(ETHpool, sender);
            }else{
                update(pool, sender);
            }

            if(pool == ETHpool){
                testClean(sender);
            }
            

            uint earned = earnings[pool][sender];
            earnings[pool][sender] = 0;
            require(earned > 0);

            if(pool == ETHpool){
                (bool success, ) = sender.call{value:earned}("");
                require(success, "Transfer failed.");
            }else if(pool == MVTpool){
                MVT.transfer(sender, earned);
            }else if(pool == COLORpool){
                COLOR.transfer(sender, earned);
            }
        }

        function addShares(uint pool, address account, uint amount) internal{
            update(pool, account);
            totalShares[pool] += amount;
            shares[pool][account] += amount;
        }

        function removeShares(uint pool, address account, uint amount) internal{
            update(pool, account);
            totalShares[pool] -= amount;
            shares[pool][account] -= amount;
        }

        function dividendsOf(uint pool, address account) public view returns(uint){
            uint owedPerShare = earningsPer[pool] - payouts[pool][account];
            return shares[pool][account] * owedPerShare / scaleFactor;
        }
        function colorDividendsOf(address account) public view returns(uint){
            uint owedPerShare = earningsPer[COLORpool] - payouts[COLORpool][account];
            return shares[ETHpool][account] * owedPerShare / scaleFactor;
        }
        
        function update(uint pool, address account) internal {
            uint newMoney = dividendsOf(pool, account);
            payouts[pool][account] = earningsPer[pool];
            earnings[pool][account] += newMoney;
            if(pool == ETHpool){
                newMoney = colorDividendsOf(account);
                payouts[COLORpool][account] = earningsPer[COLORpool];
                earnings[COLORpool][account] += newMoney;
            }
        }

        event PayEthToAcreStakers(uint amount);
        function payEthToAcreStakers() payable public{
            uint val = msg.value;
            require(totalShares[ETHpool]>0);
            earningsPer[ETHpool] += val * scaleFactor / totalShares[ETHpool];
            emit PayEthToAcreStakers(val);
        }

        event PayColor( uint amount );
        function tokenFallback(address from, uint value, bytes calldata _data) external{
            if(msg.sender == address(COLOR) ){
                require(totalShares[ETHpool]>0);
                earningsPer[COLORpool] += value * scaleFactor / totalShares[ETHpool];
                emit PayColor(value);
            }else{
                revert("no want");
            }
        }


        mapping(uint => uint) public  builder_shares;
        uint public builder_totalShares;
        uint builder_earningsPer;
        mapping(uint => uint) builder_payouts;
        mapping(uint => uint) public  builder_earnings;
        function builder_addShares(uint TOTEM, uint amount) internal{
            if(!totemManifest[TOTEM]){
                builder_update(TOTEM);
                builder_totalShares += amount;
                builder_shares[TOTEM] += amount;
            }
        }

        function builder_removeShares(uint TOTEM, uint amount) internal{
            if(!totemManifest[TOTEM]){
                builder_update(TOTEM);
                builder_totalShares -= amount;
                builder_shares[TOTEM] -= amount;
            }
        }

        function builder_dividendsOf(uint TOTEM) public view returns(uint){
            uint owedPerShare = builder_earningsPer - builder_payouts[TOTEM];
            return builder_shares[TOTEM] * owedPerShare / scaleFactor;
        }
        
        function builder_update(uint TOTEM) internal{
            uint newMoney = builder_dividendsOf(TOTEM);
            builder_payouts[TOTEM] = builder_earningsPer;
            builder_earnings[TOTEM] += newMoney;        
        }

        uint public MVT_to_rollout;
        uint public lastRollout;

        event DepositMVTForRewards(address addr, uint amount);
        function depositMVTForRewards(uint amount) public{
            require(MVT.transferFrom(msg.sender, THIS, amount));
            storeUpCommunityRewards(amount);
            emit DepositMVTForRewards(msg.sender, amount);
        }

        function storeUpCommunityRewards(uint amount)internal{
            if( builder_totalShares == 0 ){
                storedUpBuilderMVT += amount;
            }else{
                builder_earningsPer += ( amount + storedUpBuilderMVT ) * scaleFactor / builder_totalShares;
                storedUpBuilderMVT = 0;
            }
        }

        event RolloutDepositedMVTRewards(uint amountToDistribute);
        function rolloutDepositedMVTRewards() public{
            uint NOW = block.timestamp;
            if( (NOW - lastRollout) > 86400 && totalShares[MVTpool] > 0 &&  MVT_to_rollout > 0){
                lastRollout = NOW;
                uint amountToDistribute = MVT_to_rollout * (totalTotemWeight-totalShares[MVTpool]) / _totalSupply;
                MVT_to_rollout -= amountToDistribute;
                earningsPer[MVTpool] += amountToDistribute * scaleFactor / totalShares[MVTpool];
                emit RolloutDepositedMVTRewards(amountToDistribute);
            }
        }

        string public name = "Acre";
        string public symbol = "ACRE";
        uint8 constant public decimals = 18;
        mapping(address => uint256) public balances;
        uint _totalSupply;

        mapping(address => mapping(address => uint)) approvals;

        event Transfer(
            address indexed from,
            address indexed to,
            uint256 amount,
            bytes data
        );
        event Transfer(
            address indexed from,
            address indexed to,
            uint256 amount
        );
        
        event Mint(
            address indexed addr,
            uint256 amount
        );

        function mint(address _address, uint _value) internal{
            balances[_address] += _value;
            _totalSupply += _value;
            if(!isContract(msg.sender)) addShares(ETHpool, _address, _value);
            emit Mint(_address, _value);
        }

        function totalSupply() public view returns (uint256) {
            return _totalSupply;
        }

        function balanceOf(address _owner) public view returns (uint256 balance) {
            return balances[_owner];
        }

        function transfer(address _to, uint _value) public virtual returns (bool) {
            bytes memory empty;
            return transferToAddress(_to, _value, empty);
        }

        function transfer(address _to, uint _value, bytes memory _data) public virtual returns (bool) {
            if( isContract(_to) ){
                return transferToContract(_to, _value, _data);
            }else{
                return transferToAddress(_to, _value, _data);
            }
        }

        function transferToAddress(address _to, uint _value, bytes memory _data) private returns (bool) {
            moveTokens(msg.sender, _to, _value);
            emit Transfer(msg.sender, _to, _value, _data);
            return true;
        }

        function transferToContract(address _to, uint _value, bytes memory _data) private returns (bool) {
            moveTokens(msg.sender, _to, _value);
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
            emit Transfer(msg.sender, _to, _value, _data);
            return true;
        }

        function testClean(address addr) public {
            if(isContract(addr)){
                clean(addr);
            }
        }

        function clean(address addr) internal{
            uint _shares = shares[ETHpool][addr];
            if( _shares > 0 ){
                removeShares(ETHpool, addr, _shares);
                uint earned = earnings[ETHpool][addr];
                earnings[ETHpool][addr] = 0;

                require( totalShares[ETHpool] > 0 );
                earningsPer[ETHpool] += earned * scaleFactor / totalShares[ETHpool];
                emit PayEthToAcreStakers(earned);
            }
        }

        function moveTokens(address _from, address _to, uint _amount) internal virtual{
            require( _amount <= balances[_from] );
            balances[_from] -= _amount;
            balances[_to] += _amount;

            if(!isContract(_from) ){
                if(_to != THIS ){
                    require( MVT.transferFrom(_from, THIS, _amount) );
                    storeUpCommunityRewards(_amount);
                }
                removeShares(ETHpool, _from, _amount);
            }else{
                clean(_from);
            }

            if( !isContract(_to) ){
                addShares(ETHpool, _to, _amount);
            }else{
                clean(_to);
            }

            emit Transfer(_from, _to, _amount);
        }

        function allowance(address src, address guy) public view returns (uint) {
            return approvals[src][guy];
        }
        
        function transferFrom(address src, address dst, uint amount) public returns (bool){
            address sender = msg.sender;
            require(approvals[src][sender] >=  amount);
            require(balances[src] >= amount);
            approvals[src][sender] -= amount;
            moveTokens(src,dst,amount);
            bytes memory empty;
            emit Transfer(sender, dst, amount, empty);
            return true;
        }

        event Approval(address indexed src, address indexed guy, uint amount);
        function approve(address guy, uint amount) public returns (bool) {
            address sender = msg.sender;
            approvals[sender][guy] = amount;

            emit Approval( sender, guy, amount );
            return true;
        }

        function isContract(address _addr) public view returns (bool is_contract) {
            uint length;
            assembly {
                length := extcodesize(_addr)
            }
            if(length>0) {
                return true;
            }else {
                return false;
            }
        }

        uint NFTcount;
        
        mapping(address => uint[]) public totemsHad;
        mapping(address => mapping(uint => bool)) public alreadyHadAtleastOnce;

        uint totalTotemWeight;
        event AcreToTotem(address account, uint amount, bool autoStake);
        function acreToTotem(uint amount, bool autoStake) public returns(uint TOTEM_ID){
            address sender = msg.sender;
            require( MDT.transferFrom(sender, THIS, $) );

            totemNFT.mintUniqueTokenTo(autoStake?THIS:sender, NFTcount, amount);

            if(autoStake){
                stakeNFT(sender, NFTcount);
            }else{
                builder_addShares(NFTcount, amount);
                totemsHad[sender].push(NFTcount);
                alreadyHadAtleastOnce[sender][NFTcount] = true;
            }

            NFTcount += 1;
            totalTotemWeight += amount;
            moveTokens(sender, THIS, amount);
            bytes memory empty;
            emit Transfer(sender, THIS, amount, empty);
            emit AcreToTotem(sender, amount, autoStake);
            return NFTcount - 1;
        }

        uint storedUpBuilderMVT;
        event TotemToMDT(address lastOwner, uint totemID, bool preventBurn);
        mapping(uint => bool) public totemManifest;
        function totemToMDT(uint totemID, bool preventBurn) public{
            address sender = msg.sender;
            require( sender == staker[totemID] && !totemManifest[totemID] && !requestLocked[totemID]);
            require( MDT.transfer(sender, $) );
            uint totemWeight = totemNFT.getWeight(totemID);
            removeShares( MVTpool, sender, totemWeight );
            staker[totemID] = address(0);

            uint burnage;
            if(preventBurn){
                require( MVT.transferFrom(sender,THIS, totemWeight) );
                storeUpCommunityRewards(totemWeight);
            }else{
                burnage = totemWeight * totalTotemWeight / _totalSupply;
            }
            storeUpCommunityRewards(builder_dividendsOf(totemID)+builder_earnings[totemID]);
            
            moveTokens(THIS, sender, totemWeight - burnage);
            _totalSupply -= burnage;
            balances[THIS] -= burnage;

            totalTotemWeight -= totemWeight;
            
            emit TotemToMDT(sender, totemID, preventBurn);
        }

        mapping(uint => address) public staker;
        mapping(uint => uint) public lastMove;
        event StakeNFT(address who, uint tokenID);
        function stakeNFT(address who, uint256 tokenID) internal{
            staker[tokenID] = who;

            if( !alreadyHadAtleastOnce[who][tokenID] ){
                totemsHad[who].push(tokenID);
                alreadyHadAtleastOnce[who][tokenID] = true;
            }

            addShares( MVTpool, who, totemNFT.getWeight(tokenID) );
            emit StakeNFT(who, tokenID);
        }

        event UnstakeNFT(address unstaker, uint tokenID);
        function unstakeNFT(uint tokenID) public{
            address sender = msg.sender;
            require(staker[tokenID] == sender && !requestLocked[tokenID] && block.timestamp-lastMove[tokenID]>=86400 );
            uint weight = totemNFT.getWeight(tokenID);
            lastMove[tokenID] = block.timestamp;
            removeShares( MVTpool, sender, weight );
            staker[tokenID] = address(0);
            builder_addShares(tokenID, weight);

            totemNFT.transferFrom(THIS, sender, tokenID);
            emit UnstakeNFT(sender, tokenID);
        }

        function viewTotems(address account, uint[] memory totems) public view returns(uint[] memory tokenIDs, bool[] memory accountIsCurrentlyStaking, uint[] memory acreWeight, bool[] memory owned, bool[] memory manifested, bool[] memory staked, uint[] memory manifestEarnings, uint[] memory lastMoved,bool[] memory pendingManifest){
            uint L;
            if(totems.length==0){
                L = totemsHad[account].length;
            }else{
                L = totems.length;
            }

            tokenIDs = new uint[](L);
            acreWeight = new uint[](L);
            accountIsCurrentlyStaking = new bool[](L);
            owned = new bool[](L);
            manifested = new bool[](L);
            staked = new bool[](L);
            pendingManifest = new bool[](L);
            manifestEarnings = new uint[](L);
            lastMoved = new uint[](L);

            uint tID;
            for(uint c = 0; c<L; c+=1){
                if(totems.length==0){
                    tID = totemsHad[account][c];
                }else{
                    tID = totems[c];
                }
                tokenIDs[c] = tID;
                acreWeight[c] = totemNFT.getWeight(tID);
                accountIsCurrentlyStaking[c] = staker[tID] == account;
                staked[c] = totemNFT.ownerOf(tID) == THIS;
                manifested[c] = totemManifest[tID];
                pendingManifest[c] = requestLocked[tID];
                manifestEarnings[c] = builder_dividendsOf(tID) + builder_earnings[tID];
                lastMoved[c] = lastMove[tID];
                owned[c] = ( staker[tID] == account || totemNFT.ownerOf(tID) == account );
            }
        }

        function onERC721Received(address from, uint256 tokenID, bytes memory _data) external returns(bytes4) {
            bytes4 empty;
            require( msg.sender == address(totemNFT) && block.timestamp-lastMove[tokenID]>=86400 );
            lastMove[tokenID] = block.timestamp;
            builder_removeShares(tokenID, totemNFT.getWeight(tokenID) );
            stakeNFT(from, tokenID);
            return empty;
        }

        mapping(uint=>address) public theWork; //noita
        mapping(uint=>uint) workingTotem;
        mapping(uint=>string) public txt;
        mapping(uint=>bool) requestLocked;
        event OracleRequest(address buidlr, uint totemID, uint earningsToManifest, address _theWork, string text, uint ticketID);
        function oracleRequest(uint totemID, string memory _txt, address contract_optional) public payable returns(uint ticketID){
            address sender = msg.sender;
            require( staker[totemID] == sender && !totemManifest[totemID] && !requestLocked[totemID] );
            uint ID = ORACLE.fileRequestTicket{value: msg.value}(1, true);
            workingTotem[ID] = totemID;
            theWork[totemID] = contract_optional;
            txt[totemID] = _txt;
            requestLocked[totemID] = true;
            emit OracleRequest(sender, totemID, builder_dividendsOf(totemID)+builder_earnings[totemID], contract_optional, _txt, ID);
            return ID;
        }

        event CommunityReward(address buidlr, uint totemID, uint reward, address contractBuilt, string text, uint ticketID);
        event RequestRejected(uint totemID, uint ticketID);
        function oracleIntFallback(uint ticketID, bool requestRejected, uint numberOfOptions, uint[] memory optionWeights, int[] memory intOptions) public{
            uint optWeight;
            uint positive;
            uint negative;
            uint totemID = workingTotem[ticketID];
            require( msg.sender == address(ORACLE) );

            for(uint i; i < numberOfOptions; i+=1){
                optWeight = optionWeights[i];
                if(intOptions[i]>0){
                    positive += optWeight;
                }else{
                    negative += optWeight;
                }
            }

            if(!requestRejected && positive>negative){
                if(!totemManifest[totemID]){
                    totemManifest[totemID] = true;
                    uint earned = builder_earnings[totemID];
                    if(earned>0){
                        if( staker[totemID]==address(0) ){
                            storeUpCommunityRewards(earned);
                        }else{
                            earnings[MVTpool][staker[totemID]] += earned;
                        }
                    }
                    emit CommunityReward(staker[totemID], totemID, earned, theWork[totemID], txt[totemID], ticketID );
                }
            }else{
                emit RequestRejected(totemID,ticketID);
            }
            requestLocked[totemID] = false;
        }
    }

    abstract contract Oracle{
        function fileRequestTicket( uint8 returnType, bool subjective) public virtual payable returns(uint ticketID);
    }

    abstract contract ERC20{
        function totalSupply() external virtual view returns (uint256);
        function balanceOf(address account) external virtual view returns (uint256);
        function allowance(address owner, address spender) external virtual view returns (uint256);
        function transfer(address recipient, uint256 amount) external virtual returns (bool);
        function approve(address spender, uint256 amount) external virtual returns (bool);
        function transferFrom(address sender, address recipient, uint256 amount) external virtual returns (bool);
    }

    contract Totem is ERC721 {
        constructor (string memory _name, string memory _symbol)
            ERC721(_name, _symbol)
        {
            greenpoint = msg.sender;
        }

        address greenpoint;
        mapping(uint => uint)  weight;
        function mintUniqueTokenTo(
            address _to,
            uint256 _tokenId,
            uint _weight
        ) public {
            require(msg.sender == greenpoint);
            super._mint(_to, _tokenId);
            weight[_tokenId] = _weight;
        }

        function getWeight(uint ID) public view returns(uint){
            return weight[ID];
        }

        mapping(uint => string) desiredURI;
        mapping(uint => uint) workingTotem;
        event URI_request(uint totemID, string desiredURI, uint ticketID);
        function uriRequest(uint ID, string memory _desiredURI) public payable returns(uint){
            require( msg.sender == ownerOf(ID) );
            uint otID = GreenPointLandReserves(greenpoint).ORACLE().fileRequestTicket{value:msg.value}(1,true);
            desiredURI[otID] = _desiredURI;
            workingTotem[otID] = ID;
            emit URI_request(ID, _desiredURI, otID);
            return otID;
        }

        event AcceptedURI(uint totemID);
        event RejectedURI(uint totemID);
        function oracleIntFallback(uint ticketID, bool requestRejected, uint numberOfOptions, uint[] memory optionWeights, int[] memory intOptions) public{
            uint optWeight;
            uint positive;
            uint negative;
            
            require( msg.sender == address( GreenPointLandReserves(greenpoint).ORACLE() ) );

            for(uint i; i < numberOfOptions; i+=1){
                optWeight = optionWeights[i];
                if(intOptions[i]>0){
                    positive += optWeight;
                }else{
                    negative += optWeight;
                }
            }
            uint totemID = workingTotem[ticketID];
            if(!requestRejected && positive>negative && !GreenPointLandReserves(greenpoint).totemManifest(totemID) ){
                uri[totemID] = desiredURI[ticketID];
                emit AcceptedURI(totemID);
            }else{
                emit RejectedURI(totemID);
            }
        }

    }

    abstract contract ERC223ReceivingContract{
        function tokenFallback(address _from, uint _value, bytes calldata _data) external virtual;
    }