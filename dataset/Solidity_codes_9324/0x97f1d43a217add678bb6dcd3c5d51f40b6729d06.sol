pragma solidity >=0.8.0;

abstract contract ERC1155 {

    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 amount
    );

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] amounts
    );

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);


    mapping(address => mapping(uint256 => uint256)) public balanceOf;

    mapping(address => mapping(address => bool)) public isApprovedForAll;


    function uri(uint256 id) public view virtual returns (string memory);


    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual {
        require(msg.sender == from || isApprovedForAll[from][msg.sender], "NOT_AUTHORIZED");

        balanceOf[from][id] -= amount;
        balanceOf[to][id] += amount;

        emit TransferSingle(msg.sender, from, to, id, amount);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155Received(msg.sender, from, id, amount, data) ==
                    ERC1155TokenReceiver.onERC1155Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual {
        uint256 idsLength = ids.length; // Saves MLOADs.

        require(idsLength == amounts.length, "LENGTH_MISMATCH");

        require(msg.sender == from || isApprovedForAll[from][msg.sender], "NOT_AUTHORIZED");

        for (uint256 i = 0; i < idsLength; ) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            balanceOf[from][id] -= amount;
            balanceOf[to][id] += amount;

            unchecked {
                i++;
            }
        }

        emit TransferBatch(msg.sender, from, to, ids, amounts);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155BatchReceived(msg.sender, from, ids, amounts, data) ==
                    ERC1155TokenReceiver.onERC1155BatchReceived.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function balanceOfBatch(address[] memory owners, uint256[] memory ids)
        public
        view
        virtual
        returns (uint256[] memory balances)
    {
        uint256 ownersLength = owners.length; // Saves MLOADs.

        require(ownersLength == ids.length, "LENGTH_MISMATCH");

        balances = new uint256[](owners.length);

        unchecked {
            for (uint256 i = 0; i < ownersLength; i++) {
                balances[i] = balanceOf[owners[i]][ids[i]];
            }
        }
    }


    function supportsInterface(bytes4 interfaceId) public pure virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0xd9b67a26 || // ERC165 Interface ID for ERC1155
            interfaceId == 0x0e89341c; // ERC165 Interface ID for ERC1155MetadataURI
    }


    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal {
        balanceOf[to][id] += amount;

        emit TransferSingle(msg.sender, address(0), to, id, amount);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155Received(msg.sender, address(0), id, amount, data) ==
                    ERC1155TokenReceiver.onERC1155Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _batchMint(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal {
        uint256 idsLength = ids.length; // Saves MLOADs.

        require(idsLength == amounts.length, "LENGTH_MISMATCH");

        for (uint256 i = 0; i < idsLength; ) {
            balanceOf[to][ids[i]] += amounts[i];

            unchecked {
                i++;
            }
        }

        emit TransferBatch(msg.sender, address(0), to, ids, amounts);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155BatchReceived(msg.sender, address(0), ids, amounts, data) ==
                    ERC1155TokenReceiver.onERC1155BatchReceived.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _batchBurn(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal {
        uint256 idsLength = ids.length; // Saves MLOADs.

        require(idsLength == amounts.length, "LENGTH_MISMATCH");

        for (uint256 i = 0; i < idsLength; ) {
            balanceOf[from][ids[i]] -= amounts[i];

            unchecked {
                i++;
            }
        }

        emit TransferBatch(msg.sender, from, address(0), ids, amounts);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal {
        balanceOf[from][id] -= amount;

        emit TransferSingle(msg.sender, from, address(0), id, amount);
    }
}

interface ERC1155TokenReceiver {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity ^0.8.0;

interface IFYToken is IERC20 {

    function underlying() external view returns (address);


    function maturity() external view returns (uint256);


    function mature() external;


    function mintWithUnderlying(address to, uint256 amount) external;


    function redeem(address to, uint256 amount) external returns (uint256);


    function mint(address to, uint256 fyTokenAmount) external;


    function burn(address from, uint256 fyTokenAmount) external;

}// MIT
pragma solidity ^0.8.0;

interface IOracle {

    function peek(
        bytes32 base,
        bytes32 quote,
        uint256 amount
    ) external view returns (uint256 value, uint256 updateTime);


    function get(
        bytes32 base,
        bytes32 quote,
        uint256 amount
    ) external returns (uint256 value, uint256 updateTime);

}// MIT
pragma solidity ^0.8.0;

library DataTypes {

    struct Series {
        IFYToken fyToken; // Redeemable token for the series.
        bytes6 baseId; // Asset received on redemption.
        uint32 maturity; // Unix time at which redemption becomes possible.
    }

    struct Debt {
        uint96 max; // Maximum debt accepted for a given underlying, across all series
        uint24 min; // Minimum debt accepted for a given underlying, across all series
        uint8 dec; // Multiplying factor (10**dec) for max and min
        uint128 sum; // Current debt for a given underlying, across all series
    }

    struct SpotOracle {
        IOracle oracle; // Address for the spot price oracle
        uint32 ratio; // Collateralization ratio to multiply the price for
    }

    struct Vault {
        address owner;
        bytes6 seriesId; // Each vault is related to only one series, which also determines the underlying.
        bytes6 ilkId; // Asset accepted as collateral
    }

    struct Balances {
        uint128 art; // Debt amount
        uint128 ink; // Collateral amount
    }
}// MIT
pragma solidity ^0.8.0;

interface ICauldron {

    function lendingOracles(bytes6 baseId) external view returns (IOracle);


    function vaults(bytes12 vault)
        external
        view
        returns (DataTypes.Vault memory);


    function series(bytes6 seriesId)
        external
        view
        returns (DataTypes.Series memory);


    function assets(bytes6 assetsId) external view returns (address);


    function balances(bytes12 vault)
        external
        view
        returns (DataTypes.Balances memory);


    function debt(bytes6 baseId, bytes6 ilkId)
        external
        view
        returns (DataTypes.Debt memory);


    function spotOracles(bytes6 baseId, bytes6 ilkId)
        external
        returns (DataTypes.SpotOracle memory);


    function build(
        address owner,
        bytes12 vaultId,
        bytes6 seriesId,
        bytes6 ilkId
    ) external returns (DataTypes.Vault memory);


    function destroy(bytes12 vault) external;


    function tweak(
        bytes12 vaultId,
        bytes6 seriesId,
        bytes6 ilkId
    ) external returns (DataTypes.Vault memory);


    function give(bytes12 vaultId, address receiver)
        external
        returns (DataTypes.Vault memory);


    function stir(
        bytes12 from,
        bytes12 to,
        uint128 ink,
        uint128 art
    ) external returns (DataTypes.Balances memory, DataTypes.Balances memory);


    function pour(
        bytes12 vaultId,
        int128 ink,
        int128 art
    ) external returns (DataTypes.Balances memory);


    function roll(
        bytes12 vaultId,
        bytes6 seriesId,
        int128 art
    ) external returns (DataTypes.Vault memory, DataTypes.Balances memory);


    function slurp(
        bytes12 vaultId,
        uint128 ink,
        uint128 art
    ) external returns (DataTypes.Balances memory);



    function debtFromBase(bytes6 seriesId, uint128 base)
        external
        returns (uint128 art);


    function debtToBase(bytes6 seriesId, uint128 art)
        external
        returns (uint128 base);



    function mature(bytes6 seriesId) external;


    function accrual(bytes6 seriesId) external returns (uint256);


    function level(bytes12 vaultId) external returns (int256);

}// MIT
pragma solidity ^0.8.0;

interface IJoin {

    function asset() external view returns (address);


    function join(address user, uint128 wad) external returns (uint128);


    function exit(address user, uint128 wad) external returns (uint128);

}// MIT
pragma solidity ^0.8.0;

interface IERC2612 {

    function permit(address owner, address spender, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;


    function nonces(address owner) external view returns (uint256);

}// MIT
pragma solidity >= 0.8.0;


interface IPool is IERC20, IERC2612 {

    function ts() external view returns(int128);

    function g1() external view returns(int128);

    function g2() external view returns(int128);

    function maturity() external view returns(uint32);

    function scaleFactor() external view returns(uint96);

    function getCache() external view returns (uint112, uint112, uint32);

    function base() external view returns(IERC20);

    function fyToken() external view returns(IFYToken);

    function getBaseBalance() external view returns(uint112);

    function getFYTokenBalance() external view returns(uint112);

    function retrieveBase(address to) external returns(uint128 retrieved);

    function retrieveFYToken(address to) external returns(uint128 retrieved);

    function sellBase(address to, uint128 min) external returns(uint128);

    function buyBase(address to, uint128 baseOut, uint128 max) external returns(uint128);

    function sellFYToken(address to, uint128 min) external returns(uint128);

    function buyFYToken(address to, uint128 fyTokenOut, uint128 max) external returns(uint128);

    function sellBasePreview(uint128 baseIn) external view returns(uint128);

    function buyBasePreview(uint128 baseOut) external view returns(uint128);

    function sellFYTokenPreview(uint128 fyTokenIn) external view returns(uint128);

    function buyFYTokenPreview(uint128 fyTokenOut) external view returns(uint128);

    function mint(address to, address remainder, uint256 minRatio, uint256 maxRatio) external returns (uint256, uint256, uint256);

    function mintWithBase(address to, address remainder, uint256 fyTokenToBuy, uint256 minRatio, uint256 maxRatio) external returns (uint256, uint256, uint256);

    function burn(address baseTo, address fyTokenTo, uint256 minRatio, uint256 maxRatio) external returns (uint256, uint256, uint256);

    function burnForBase(address to, uint256 minRatio, uint256 maxRatio) external returns (uint256, uint256);

}// MIT

pragma solidity ^0.8.0;


interface IWETH9 is IERC20 {

    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);

    function deposit() external payable;

    function withdraw(uint wad) external;

}// MIT

pragma solidity >=0.6.0;


library RevertMsgExtractor {

    function getRevertMsg(bytes memory returnData)
        internal pure
        returns (string memory)
    {

        if (returnData.length < 68) return "Transaction reverted silently";

        assembly {
            returnData := add(returnData, 0x04)
        }
        return abi.decode(returnData, (string)); // All that remains is the revert string
    }
}// MIT
pragma solidity ^0.8.0;


library IsContract {

  function isContract(address account) internal view returns (bool) {

      return account.code.length > 0;
  }
}// BUSL-1.1
pragma solidity 0.8.6;


contract Router {

    using IsContract for address;

    address immutable public owner;

    constructor () {
        owner = msg.sender;
    }

    function route(address target, bytes calldata data)
        external payable
        returns (bytes memory result)
    {

        require(msg.sender == owner, "Only owner");
        require(target.isContract(), "Target is not a contract");
        bool success;
        (success, result) = target.call(data);
        if (!success) revert(RevertMsgExtractor.getRevertMsg(result));
    }
}// BUSL-1.1
pragma solidity 0.8.6;


contract LadleStorage {

    event JoinAdded(bytes6 indexed assetId, address indexed join);
    event PoolAdded(bytes6 indexed seriesId, address indexed pool);
    event ModuleAdded(address indexed module, bool indexed set);
    event IntegrationAdded(address indexed integration, bool indexed set);
    event TokenAdded(address indexed token, bool indexed set);
    event FeeSet(uint256 fee);

    ICauldron public immutable cauldron;
    Router public immutable router;
    IWETH9 public immutable weth;
    uint256 public borrowingFee;
    bytes12 cachedVaultId;

    mapping (bytes6 => IJoin)                   public joins;            // Join contracts available to manage assets. The same Join can serve multiple assets (ETH-A, ETH-B, etc...)
    mapping (bytes6 => IPool)                   public pools;            // Pool contracts available to manage series. 12 bytes still free.
    mapping (address => bool)                   public modules;          // Trusted contracts to delegatecall anything on.
    mapping (address => bool)                   public integrations;     // Trusted contracts to call anything on.
    mapping (address => bool)                   public tokens;           // Trusted contracts to call `transfer` or `permit` on.

    constructor (ICauldron cauldron_, IWETH9 weth_) {
        cauldron = cauldron_;
        router = new Router();
        weth = weth_;
    }
}// BUSL-1.1
pragma solidity 0.8.6;


contract Transfer1155Module is LadleStorage {


    constructor (ICauldron cauldron, IWETH9 weth) LadleStorage(cauldron, weth) { }

    function transfer1155(ERC1155 token, uint256 id, address receiver, uint128 wad, bytes memory data)
        external payable
    {

        require(tokens[address(token)], "Unknown token");
        token.safeTransferFrom(msg.sender, receiver, id, wad, data);
    }
}