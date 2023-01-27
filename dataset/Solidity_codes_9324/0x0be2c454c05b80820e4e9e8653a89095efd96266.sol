
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

}// MIT

pragma solidity >=0.8.0;


library UInt256Set {

    struct Set {
        mapping(uint256 => uint256) keyPointers;
        uint256[] keyList;
    }

    function insert(Set storage self, uint256 key) public {

        require(
            !exists(self, key),
            "UInt256Set: key already exists in the set."
        );
        self.keyList.push(key);
        self.keyPointers[key] = self.keyList.length - 1;
    }

    function remove(Set storage self, uint256 key) public {

        if (!exists(self, key)) return;
        uint256 last = count(self) - 1;
        uint256 rowToReplace = self.keyPointers[key];
        if (rowToReplace != last) {
            uint256 keyToMove = self.keyList[last];
            self.keyPointers[keyToMove] = rowToReplace;
            self.keyList[rowToReplace] = keyToMove;
        }
        delete self.keyPointers[key];
        delete self.keyList[self.keyList.length - 1];
    }

    function count(Set storage self) public view returns (uint256) {

        return (self.keyList.length);
    }

    function exists(Set storage self, uint256 key)
        public
        view
        returns (bool)
    {

        if (self.keyList.length == 0) return false;
        return self.keyList[self.keyPointers[key]] == key;
    }

    function keyAtIndex(Set storage self, uint256 index)
        public
        view
        returns (uint256)
    {

        return self.keyList[index];
    }
}// MIT

pragma solidity >=0.8.0;


library AddressSet {

    struct Set {
        mapping(address => uint256) keyPointers;
        address[] keyList;
    }

    function insert(Set storage self, address key) public {

        require(
            !exists(self, key),
            "AddressSet: key already exists in the set."
        );
        self.keyList.push(key);
        self.keyPointers[key] = self.keyList.length - 1;
    }

    function remove(Set storage self, address key) public {

        require(
            exists(self, key),
            "AddressSet: key does not exist in the set."
        );
        if (!exists(self, key)) return;
        uint256 last = count(self) - 1;
        uint256 rowToReplace = self.keyPointers[key];
        if (rowToReplace != last) {
            address keyToMove = self.keyList[last];
            self.keyPointers[keyToMove] = rowToReplace;
            self.keyList[rowToReplace] = keyToMove;
        }
        delete self.keyPointers[key];
        self.keyList.pop();
    }

    function count(Set storage self) public view returns (uint256) {

        return (self.keyList.length);
    }

    function exists(Set storage self, address key)
        public
        view
        returns (bool)
    {

        if (self.keyList.length == 0) return false;
        return self.keyList[self.keyPointers[key]] == key;
    }

    function keyAtIndex(Set storage self, uint256 index)
        public
        view
        returns (address)
    {

        return self.keyList[index];
    }
}// MIT
pragma solidity ^0.8.4;

interface IMarketplace {

    event Bids(uint256 indexed itemId, address bidder, uint256 amount);
    event Sales(uint256 indexed itemId, address indexed owner, uint256 amount, uint256 quantity, uint256 indexed tokenId);
    event Closes(uint256 indexed itemId);
    event Listings(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address receiver,
        address owner,
        uint256 price,
        bool sold
    );
    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address seller;
        address owner;
        uint256 price;
        uint256 quantity;
        bool sold;
        address receiver;
    }
}// MIT
pragma solidity >=0.8.0;

interface IERC1155Burn {


    event Burned(
        address target,
        uint256 tokenHash,
        uint256 amount
    );

    function burn(
        address target,
        uint256 tokenHash,
        uint256 amount
    ) external;



}// MIT
pragma solidity >=0.8.0;


interface ITokenMinter {


    struct Minter {

        address account;
        uint256 minted;
        uint256 burned;
        uint256 spent;

    }

    event MinterRegistered(
        address indexed registrant,
        uint256 depositPaid
    );

    event MinterUnregistered(
        address indexed registrant,
        uint256 depositReturned
    );

    event MinterReloaded(
        address indexed registrant,
        uint256 amountDeposited
    );

    function minter(address _minter) external returns (Minter memory _minterObj);


    function mint(address receiver, uint256 collectionId, uint256 id, uint256 amount) external;


    function burn(address target, uint256 id, uint256 amount) external;


}//Unlicense
pragma solidity ^0.8.0;

interface ITokenSale {


    struct TokenSaleEntry {
        address payable receiver;
        address sourceToken;
        uint256 sourceTokenId;
        address token;
        uint256 quantity;
        uint256 price;
        uint256 quantitySold;
    }

    event TokenSaleSet(address indexed token, uint256 indexed tokenId, uint256 price, uint256 quantity);
    event TokenSold(address indexed buyer, address indexed tokenAddress, uint256 indexed tokenId, uint256 salePrice);
    event TokensSet(address indexed tokenAddress, ITokenSale.TokenSaleEntry tokens);

}// MIT
pragma solidity >=0.8.0;


interface ITokenPrice {


    enum PriceModifier {

        None,
        Fixed,
        Exponential,
        InverseLog

    }

    struct TokenPriceData {

        uint256 price;
        PriceModifier priceModifier;
        uint256 priceModifierFactor;
        uint256 maxPrice;

    }

    function getIncreasedPrice() external view returns (uint256);


    function getTokenPrice() external view returns (TokenPriceData memory);



}// MIT
pragma solidity >=0.8.0;


interface IToken {


    struct Token {

        uint256 id;
        uint256 balance;
        bool burn;

    }

    struct TokenSet {

        mapping(uint256 => uint256) keyPointers;
        uint256[] keyList;
        Token[] valueList;

    }

    struct TokenDefinition {

        address token;

        uint256 id;

        uint256 collectionId;

        string name;

        string symbol;

        string description;

        uint8 decimals;

        uint256 totalSupply;

        bool generateId;

        uint256 probability;

        uint256 probabilityIndex;

        uint256 probabilityRoll;

    }

    struct TokenRecord {

        uint256 id;
        address owner;
        address minter;
        uint256 _type;
        uint256 balance;

    }

    enum TokenSourceType {

        Static,
        Collection

    }

    struct TokenSource {

        TokenSourceType _type;
        uint256 staticSourceId;
        address collectionSourceAddress;

    }
}//Unlicense
pragma solidity ^0.8.0;


interface IMerkleAirdrop {

    function airdropRedeemed(
        uint256 drop,
        address recipient,
        uint256 amount
    ) external;

     function initMerkleAirdrops(IAirdrop.AirdropSettings[] calldata settingsList) external;

     function airdrop(uint256 drop) external view returns (IAirdrop.AirdropSettings memory settings);

     function airdropRedeemed(uint256 drop, address recipient) external view returns (bool isRedeemed);

}

interface IAirdrop {




    struct AirdropSettings {
        bool whitelistOnly;

        uint256 whitelistId;

        bytes32 whitelistHash;

        uint256 maxQuantity; // max number of tokens that can be sold
        uint256 maxQuantityPerSale; // max number of tokens that can be sold per sale
        uint256 minQuantityPerSale; // min number of tokens that can be sold per sale
        uint256 maxQuantityPerAccount; // max number of tokens that can be sold per account

        uint256 quantitySold;

        uint256 startTime; // block number when the sale starts
        uint256 endTime; // block number when the sale ends

        ITokenPrice.TokenPriceData initialPrice;

        uint256 tokenHash;

        IAirdropTokenSale.PaymentType paymentType; // the type of payment that is being used
        address tokenAddress; // the address of the payment token, if payment type is TOKEN

        address payee;
    }

    event AirdropLaunched(uint256 indexed airdropId, AirdropSettings airdrop);

    event AirdropRedeemed(uint256 indexed airdropId, address indexed beneficiary, uint256 indexed tokenHash, bytes32[] proof, uint256 amount);

    function airdropRedeemed(uint256 drop, address recipient) external view returns (bool isRedeemed);


    function redeemAirdrop(uint256 drop, uint256 leaf, address recipient, uint256 amount, uint256 total, bytes32[] memory merkleProof) external payable;


    function airdrop(uint256 drop) external view returns (AirdropSettings memory settings);


}//Unlicense
pragma solidity ^0.8.0;


interface IAirdropTokenSale {



    enum PaymentType {
        ETH,
        TOKEN
    }

    struct TokenSaleSettings {

        address contractAddress; // the contract doing the selling
        address token; // the token being sold
        uint256 tokenHash; // the token hash being sold. set to 0 to autocreate hash
        uint256 collectionHash; // the collection hash being sold. set to 0 to autocreate hash
        
        address owner; // the owner of the contract
        address payee; // the payee of the contract

        string symbol; // the symbol of the token
        string name; // the name of the token
        string description; // the description of the token

        bool openState; // open or closed
        uint256 startTime; // block number when the sale starts
        uint256 endTime; // block number when the sale ends

        uint256 maxQuantity; // max number of tokens that can be sold
        uint256 maxQuantityPerSale; // max number of tokens that can be sold per sale
        uint256 minQuantityPerSale; // min number of tokens that can be sold per sale
        uint256 maxQuantityPerAccount; // max number of tokens that can be sold per account

        ITokenPrice.TokenPriceData initialPrice;

        PaymentType paymentType; // the type of payment that is being used
        address tokenAddress; // the address of the payment token, if payment type is TOKEN

    }

    event TokenSaleOpen (uint256 tokenSaleId, TokenSaleSettings tokenSale );

    event TokenSaleClosed (uint256 tokenSaleId, TokenSaleSettings tokenSale );

    event TokenPurchased (uint256 tokenSaleId, address indexed purchaser, uint256 tokenId, uint256 quantity );

    event TokenSaleSettingsUpdated (uint256 tokenSaleId, TokenSaleSettings tokenSale );

    function getTokenSaleSettings(uint256 tokenSaleId) external view returns (TokenSaleSettings memory settings);


    function updateTokenSaleSettings(uint256 iTokenSaleId, TokenSaleSettings memory settings) external;


    function initTokenSale(
        TokenSaleSettings memory tokenSaleInit,
        IAirdrop.AirdropSettings[] calldata settingsList
    ) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC721A {


    struct TokenOwnership {
        address addr;
        uint64 startTimestamp;
        bool burned;
    }

    struct AddressData {
        uint64 balance;
        uint64 numberMinted;
        uint64 numberBurned;
        uint64 aux;
    }

}