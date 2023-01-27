
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

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// MIT

pragma solidity ^0.8.0;


interface IS16NFT {

    function mintEditionsUser(
        address _to,
        uint256[] memory _tokenIds,
        uint256[] memory _quantity
    ) external returns (bool);


    function claimNfts(
        address _to,
        uint256[] memory tokenIds,
        uint256[] memory quantity) 
        external returns (bool);


    function updateIdsEdition(uint256[] memory _tokenIds,uint256[] memory _quantity) external;


    function getmintedEditionsToken(uint256 _tokenId)
        external
        view
        returns (uint256);


    function isMinted(uint256 _tokenId) external view returns (bool);


    function totalSupply() external view returns (uint256);


    function cap() external view returns (uint256);


    function getEditionCap() external view returns (uint256);


}

interface IS16Presale {

    function isRegisterforPresale(address wallet) external view returns (bool);

}

interface IS16Token {

    function airdropTokenUser(address account, uint256 amount) external;

}
 
contract S16Distributor is AccessControl {

    
    struct ClaimNFTPreSale {
        address claimWallet;
        uint256[] claimedTokenIds;
        uint256[] claimedQuantities;
        uint256[] unClaimedTokenIds;
        uint256[] unClaimedQuantities; 
    }

    struct ClaimTokenPreSale {
        address claimWallet;
        uint256 claimAmount;
        uint256 unClaimedAmount;
    }

     struct ClaimNFTPublicSale {
        address claimWallet;
        uint256[] tokenIds;
        uint256[] quantity;
        uint256[] unClaimedTokenIds;
        uint256[] unClaimedQuantities;
    }

    struct ClaimTokenPublicSale  {
        address claimWallet;
        uint256 claimAmount;
        uint256 unClaimedAmount;
    }

    uint256 public preSaleMintPrice = 0.16 ether;
    uint256 public publicSaleMintPrice = 0.25 ether;

    uint256 public PRE_SALE_START_TIME;
    uint256 public PUBLIC_SALE_TIME_START;

    uint256 private userEditionCap = 10; 

    uint256 public _trackerTokenId;

    bool public _mintingPaused = false;
    address public s16AdminWallet;

    mapping(address => uint256) public mintLimit;

    mapping (address => ClaimNFTPreSale) public claimS16NFTsPreSale;
    mapping(address => ClaimTokenPreSale) public claimTokensPreSale;

    mapping (address => ClaimNFTPublicSale) public claimS16NFTsPublicSale;
    mapping(address => ClaimTokenPublicSale) public claimTokensPublicSale;


    IS16NFT public s16NFT;
    IS16Token public s16Token;
    IS16Presale public s16Presale;

    constructor(address _s16NFT, address _s16Token, address _s16PreSale,address _s16AdminWallet) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        s16NFT = IS16NFT(_s16NFT);
        s16Token = IS16Token(_s16Token);
        s16Presale = IS16Presale(_s16PreSale);

        s16AdminWallet =_s16AdminWallet;
        
        PRE_SALE_START_TIME = 1643414400;
        PUBLIC_SALE_TIME_START = 1643500800;
    }

    function setS16NFTAddress(address _nftAddress) public {

            require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Caller is not a admin");
            s16NFT = IS16NFT(_nftAddress);

    }

    function setS16TokenAddress(address _sa16Token) public {

            require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Caller is not a admin");
            s16Token = IS16Token(_sa16Token);

    }

    function setS16PreSaleAddress(address _preSale) public {

            require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Caller is not a admin");
            s16Presale = IS16Presale(_preSale);

    }
    

    function updateUserEditionCap(uint256 _newCap) public {

        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Caller is not a admin");
        require(_newCap > 0, "S16Dist: value error");
        userEditionCap = _newCap;
    }

    function setPreSaleStartTime(uint256 _PRE_SALE_START_TIME) public {

        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Caller is not a admin");
        PRE_SALE_START_TIME = _PRE_SALE_START_TIME;
    }

    function setPublicSaleStartTime(uint256 _PUBLIC_SALE_TIME_START) public {

        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Caller is not a admin");
        PUBLIC_SALE_TIME_START = _PUBLIC_SALE_TIME_START;
    }

    function preSaleMint(address wallet, uint256 _editionQty, bool _claimNow) public payable returns(bool) {

        
        require(s16AdminWallet != address(0x0), "S16Dist: eth to null address");
        require(!_mintingPaused, "S16Dist: Minting paused");
        require(s16Presale.isRegisterforPresale(wallet), "S16Dist: you are not registered for presaleMint");
        require(mintLimit[wallet]+_editionQty <= userEditionCap, "S16Dist: your minting limit exceed");
        require(block.timestamp >= PRE_SALE_START_TIME && block.timestamp <= PUBLIC_SALE_TIME_START, "S16Dist: presale time error");
        require(msg.value >= (preSaleMintPrice * _editionQty),"S16Dist: Presale price error");

        payable(s16AdminWallet).transfer(msg.value);
    
       (uint256[] memory tokenIds, uint256[] memory editionQty) = _mintTokensEditions(_editionQty);

        uint256 s16TokenAmount = _editionQty * 16000e18;

        if(_claimNow) {
            s16NFT.mintEditionsUser(wallet, tokenIds, editionQty);
            s16Token.airdropTokenUser(wallet, s16TokenAmount);
            mintLimit[wallet] += _editionQty;
        } else {
            uint256[] storage newClaimTokenIds = claimS16NFTsPreSale[wallet].unClaimedTokenIds;
            uint256[] storage newClaimTokenQty = claimS16NFTsPreSale[wallet].unClaimedQuantities;
            for(uint i =0; i < tokenIds.length; i++) {
                newClaimTokenIds.push(tokenIds[i]);
                newClaimTokenQty.push(editionQty[i]);
            }
            s16NFT.updateIdsEdition(tokenIds,editionQty);
            claimS16NFTsPreSale[wallet]  = ClaimNFTPreSale(wallet,claimS16NFTsPreSale[wallet].claimedTokenIds, claimS16NFTsPreSale[wallet].claimedQuantities, newClaimTokenIds, newClaimTokenQty);
            uint256 prevClaimAmount = claimTokensPreSale[wallet].claimAmount;
            claimTokensPreSale[wallet] = ClaimTokenPreSale(wallet, prevClaimAmount, claimTokensPublicSale[wallet].unClaimedAmount+s16TokenAmount);
            mintLimit[wallet] += _editionQty;
        }

        return true;
    }

    function publicSaleMint(address wallet, uint256 _editionQty, bool _claimNow) public payable returns (bool) {


        require(!_mintingPaused, "S16Dist: Minting paused");
        require(s16AdminWallet != address(0x0), "S16Dist: eth to null address");
        require(block.timestamp >= PUBLIC_SALE_TIME_START, "S16Dist: Public Sale not yet started");
        require(mintLimit[wallet] + _editionQty <= userEditionCap, "S16Dist: your minting limit exceed");
        if(s16Presale.isRegisterforPresale(wallet)){
            require(msg.value >= (preSaleMintPrice * _editionQty),"S16Dist: PublicSale price error");
        }else{
             require(msg.value >= (publicSaleMintPrice * _editionQty), "S16Dist: PublicSale price error");
        }
       
        payable(s16AdminWallet).transfer(msg.value);

        (uint256[] memory tokenIds, uint256[] memory editionQty) = _mintTokensEditions(_editionQty);

        uint256 s16TokenAmount = _editionQty * 16000e18;

        if(_claimNow) {
            s16NFT.mintEditionsUser(wallet, tokenIds, editionQty);
            s16Token.airdropTokenUser(wallet, s16TokenAmount);
            mintLimit[wallet] += _editionQty;
       } else {
            uint256[] storage newClaimTokenIds = claimS16NFTsPublicSale[wallet].unClaimedTokenIds;
            uint256[] storage newClaimTokenQty = claimS16NFTsPublicSale[wallet].unClaimedQuantities;
            for(uint i =0; i < tokenIds.length; i++) {
                newClaimTokenIds.push(tokenIds[i]);
                newClaimTokenQty.push(editionQty[i]);
            }
            s16NFT.updateIdsEdition(tokenIds,editionQty);
            claimS16NFTsPublicSale[wallet]  = ClaimNFTPublicSale(wallet,claimS16NFTsPublicSale[wallet].tokenIds, claimS16NFTsPublicSale[wallet].quantity, newClaimTokenIds, newClaimTokenQty);
            uint256 prevClaimAmount = claimTokensPublicSale[wallet].claimAmount;
            claimTokensPublicSale[wallet] = ClaimTokenPublicSale(wallet, prevClaimAmount, claimTokensPublicSale[wallet].unClaimedAmount+s16TokenAmount);
            mintLimit[wallet] += _editionQty;
        }

        return true;
    }

    function mintbyAdmin(address wallet, uint256 _editionQty) public {

        
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Caller is not a admin");

        (uint256[] memory tokenIds, uint256[] memory editionQty) = _mintTokensEditions(_editionQty);
        
        s16NFT.updateIdsEdition(tokenIds,editionQty);
        s16NFT.claimNfts(wallet, tokenIds, editionQty);

    }

    function _mintTokensEditions(uint256 _editionQty) internal returns (uint256[] memory, uint256[] memory) {


        uint256 totalNFTs = s16NFT.cap();
        uint256[] memory newTokenIds = new uint256[](_editionQty);
        uint256[] memory newEditionQty = new uint256[](_editionQty);

        for(uint i = 0; i < _editionQty; i++) {
            newTokenIds[i] = _trackerTokenId + 1;
            require(!s16NFT.isMinted(newTokenIds[i]), "S16Dist: quantity exceed limit");

            newEditionQty[i] = 1;
            _trackerTokenId++;
            if(_trackerTokenId >= totalNFTs)
                _trackerTokenId = 0;
        }

        return (newTokenIds, newEditionQty);
    }

     function claimPreSale() public {


        address _wallet = msg.sender;

        ClaimNFTPreSale storage preSaleData =  claimS16NFTsPreSale[msg.sender];

        uint unClaimedTokenlength = preSaleData.unClaimedTokenIds.length;

        require(block.timestamp > PRE_SALE_START_TIME, "S16DIST: claim allowed after presale start"); 
        require(_wallet == claimS16NFTsPreSale[_wallet].claimWallet && _wallet == claimTokensPreSale[_wallet].claimWallet,"S16DIST: not claimer");
        require(unClaimedTokenlength != 0, "S16DIST: you cannot claim");
       
        uint256 unClaimedAmount = claimTokensPreSale[_wallet].unClaimedAmount;
        s16Token.airdropTokenUser(_wallet, unClaimedAmount);
        claimTokensPreSale[_wallet].claimAmount += unClaimedAmount;
        claimTokensPreSale[_wallet].unClaimedAmount = 0;
        
        s16NFT.claimNfts( _wallet,claimS16NFTsPreSale[_wallet].unClaimedTokenIds,claimS16NFTsPreSale[_wallet].unClaimedQuantities);
        

        uint256[] storage newClaimedTokenIds = claimS16NFTsPreSale[_wallet].claimedTokenIds;
        uint256[] storage newClaimedTokenQty = claimS16NFTsPreSale[_wallet].claimedQuantities;

        for(uint i =0; i < unClaimedTokenlength; i++) {
                newClaimedTokenIds.push(preSaleData.unClaimedTokenIds[i]);
                newClaimedTokenQty.push(preSaleData.unClaimedQuantities[i]);
            }
        
        delete preSaleData.unClaimedTokenIds;
        delete preSaleData.unClaimedQuantities;
    }

    function claimPublicSale() public {


        address _wallet = msg.sender;

        ClaimNFTPublicSale storage publicSaleData =  claimS16NFTsPublicSale[msg.sender];

        require(block.timestamp > PUBLIC_SALE_TIME_START , "S16DIST: claim allowed after public start"); 
        require(_wallet == claimTokensPublicSale[_wallet].claimWallet  && _wallet == claimS16NFTsPublicSale[_wallet].claimWallet, "S16DIST: not claimer");
        require(publicSaleData.unClaimedTokenIds.length != 0, "S16DIST: you cannot claim");
       
        uint256 unClaimedAmount = claimTokensPublicSale[_wallet].unClaimedAmount;
        s16Token.airdropTokenUser(_wallet, unClaimedAmount);
        claimTokensPublicSale[_wallet].claimAmount += unClaimedAmount;
        claimTokensPublicSale[_wallet].unClaimedAmount = 0;
        
        s16NFT.claimNfts( _wallet, claimS16NFTsPublicSale[_wallet].unClaimedTokenIds, claimS16NFTsPublicSale[_wallet].unClaimedQuantities);
        

        uint256[] storage newClaimedTokenIds = claimS16NFTsPublicSale[_wallet].tokenIds;
        uint256[] storage newClaimedTokenQty = claimS16NFTsPublicSale[_wallet].quantity;

        for(uint i =0; i < publicSaleData.unClaimedTokenIds.length; i++) {
                newClaimedTokenIds.push(publicSaleData.unClaimedTokenIds[i]);
                newClaimedTokenQty.push(publicSaleData.unClaimedQuantities[i]);
            }

        delete publicSaleData.unClaimedTokenIds;
        delete publicSaleData.unClaimedQuantities;
        
    }

    function togglePause(bool _pause) public {

        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "S16DIST: Caller is not a admin");
        require(_mintingPaused != _pause, "S16DIST: Already in desired pause state");
        _mintingPaused = _pause;
    }

    function updatePreSalePrice(uint256 _newPrice) public {

        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "S16DIST: Caller is not admin");
        preSaleMintPrice = _newPrice;
    }

    function updatePublicSalePrice(uint256 _newPrice) public {

        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "S16DIST: Caller is not admin");
        publicSaleMintPrice = _newPrice;
    }

    function updateAdminWallet(address _adminWallet) public {

        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "S16DIST: Caller is not admin");
        require(_adminWallet != address(0x0), "S16Dist: null address error");
        s16AdminWallet = _adminWallet;
    }

    function getUserClaimNFTsPreSale(address _address) public view returns(ClaimNFTPreSale memory) {

       return claimS16NFTsPreSale[_address];
    }

     function getUserClaimTokensPreSale(address _address) public view returns(ClaimTokenPreSale memory) {

       return claimTokensPreSale[_address];
    }

    function getUserClaimNFTsPublicSale(address _address) public view returns(ClaimNFTPublicSale memory) {

       return claimS16NFTsPublicSale[_address];
    }

     function getUserClaimTokensPublicSale(address _address) public view returns(ClaimTokenPublicSale memory) {

       return claimTokensPublicSale[_address];
    }

    function getUserMintedEditions(address _user) public view returns(uint256) {

        return mintLimit[_user];
    }

   
}