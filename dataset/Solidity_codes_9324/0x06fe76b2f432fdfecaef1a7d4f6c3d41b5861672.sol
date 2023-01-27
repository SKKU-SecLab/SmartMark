

pragma solidity 0.6.5;
pragma experimental ABIEncoderV2;


struct ProtocolBalance {
    ProtocolMetadata metadata;
    AdapterBalance[] adapterBalances;
}


struct ProtocolMetadata {
    string name;
    string description;
    string websiteURL;
    string iconURL;
    uint256 version;
}


struct AdapterBalance {
    AdapterMetadata metadata;
    FullTokenBalance[] balances;
}


struct AdapterMetadata {
    address adapterAddress;
    string adapterType;
}


struct FullTokenBalance {
    TokenBalance base;
    TokenBalance[] underlying;
}


struct TokenBalance {
    TokenMetadata metadata;
    uint256 amount;
}


struct TokenMetadata {
    address token;
    string name;
    string symbol;
    uint8 decimals;
}


struct Component {
    address token;
    string tokenType;
    uint256 rate;
}


library Strings {


    function isEmpty(string memory s) internal pure returns (bool) {

        return bytes(s).length == 0;
    }

    function isEqualTo(string memory s1, string memory s2) internal pure returns (bool) {

        return keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2));
    }
}


interface TokenAdapter {


    function getMetadata(address token) external view returns (TokenMetadata memory);


    function getComponents(address token) external view returns (Component[] memory);

}


interface ProtocolAdapter {


    function adapterType() external pure returns (string memory);


    function tokenType() external pure returns (string memory);


    function getBalance(address token, address account) external view returns (uint256);

}


abstract contract Ownable {

    modifier onlyOwner {
        require(msg.sender == owner, "O: onlyOwner function!");
        _;
    }

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function transferOwnership(address _owner) external onlyOwner {
        require(_owner != address(0), "O: new owner is the zero address!");
        emit OwnershipTransferred(owner, _owner);
        owner = _owner;
    }
}


abstract contract TokenAdapterManager is Ownable {

    using Strings for string;

    string internal constant INITIAL_NAME = "Initial token name";

    mapping (string => string) internal nextTokenAdapterName;
    mapping (string => address) internal tokenAdapter;

    constructor() internal {
        nextTokenAdapterName[INITIAL_NAME] = INITIAL_NAME;
    }

    function addTokenAdapters(
        string[] memory tokenAdapterNames,
        address[] memory adapters
    )
        public
        onlyOwner
    {
        uint256 length = tokenAdapterNames.length;
        require(length == adapters.length, "TAM: lengths differ!");
        require(length != 0, "PM: empty!");

        for (uint256 i = 0; i < length; i++) {
            addTokenAdapter(tokenAdapterNames[i], adapters[i]);
        }
    }
    function removeTokenAdapters(
        string[] memory tokenAdapterNames
    )
        public
        onlyOwner
    {
        require(tokenAdapterNames.length != 0, "PM: empty!");

        for (uint256 i = 0; i < tokenAdapterNames.length; i++) {
            removeTokenAdapter(tokenAdapterNames[i]);
        }
    }

    function updateTokenAdapter(
        string memory tokenAdapterName,
        address adapter
    )
        public
        onlyOwner
    {
        require(isValidTokenAdapter(tokenAdapterName), "TAM: bad name!");
        require(adapter != address(0), "TAM: zero!");

        tokenAdapter[tokenAdapterName] = adapter;
    }

    function getTokenAdapterNames()
        public
        view
        returns (string[] memory)
    {
        uint256 counter = 0;
        string memory currentTokenAdapterName = nextTokenAdapterName[INITIAL_NAME];

        while (!currentTokenAdapterName.isEqualTo(INITIAL_NAME)) {
            currentTokenAdapterName = nextTokenAdapterName[currentTokenAdapterName];
            counter++;
        }

        string[] memory tokenAdapters = new string[](counter);
        counter = 0;
        currentTokenAdapterName = nextTokenAdapterName[INITIAL_NAME];

        while (!currentTokenAdapterName.isEqualTo(INITIAL_NAME)) {
            tokenAdapters[counter] = currentTokenAdapterName;
            currentTokenAdapterName = nextTokenAdapterName[currentTokenAdapterName];
            counter++;
        }

        return tokenAdapters;
    }

    function getTokenAdapter(
        string memory tokenAdapterName
    )
        public
        view
        returns (address)
    {
        return tokenAdapter[tokenAdapterName];
    }

    function isValidTokenAdapter(
        string memory tokenAdapterName
    )
        public
        view
        returns (bool)
    {
        return !nextTokenAdapterName[tokenAdapterName].isEmpty() && !tokenAdapterName.isEqualTo(INITIAL_NAME);
    }

    function addTokenAdapter(
        string memory tokenAdapterName,
        address adapter
    )
        internal
    {
        require(!tokenAdapterName.isEqualTo(INITIAL_NAME), "TAM: initial name!");
        require(!tokenAdapterName.isEmpty(), "TAM: empty name!");
        require(nextTokenAdapterName[tokenAdapterName].isEmpty(), "TAM: name exists!");
        require(adapter != address(0), "TAM: zero!");

        nextTokenAdapterName[tokenAdapterName] = nextTokenAdapterName[INITIAL_NAME];
        nextTokenAdapterName[INITIAL_NAME] = tokenAdapterName;

        tokenAdapter[tokenAdapterName] = adapter;
    }

    function removeTokenAdapter(
        string memory tokenAdapterName
    )
        internal
    {
        require(isValidTokenAdapter(tokenAdapterName), "TAM: bad name!");

        string memory prevTokenAdapterName;
        string memory currentTokenAdapterName = nextTokenAdapterName[tokenAdapterName];
        while (!currentTokenAdapterName.isEqualTo(tokenAdapterName)) {
            prevTokenAdapterName = currentTokenAdapterName;
            currentTokenAdapterName = nextTokenAdapterName[currentTokenAdapterName];
        }

        nextTokenAdapterName[prevTokenAdapterName] = nextTokenAdapterName[tokenAdapterName];
        delete nextTokenAdapterName[tokenAdapterName];

        delete tokenAdapter[tokenAdapterName];
    }
}


abstract contract ProtocolManager is Ownable {

    using Strings for string;

    string internal constant INITIAL_PROTOCOL_NAME = "Initial protocol name";

    mapping (string => string) internal nextProtocolName;
    mapping (string => ProtocolMetadata) internal protocolMetadata;
    mapping (string => address[]) internal protocolAdapters;
    mapping (address => address[]) internal supportedTokens;

    constructor() internal {
        nextProtocolName[INITIAL_PROTOCOL_NAME] = INITIAL_PROTOCOL_NAME;
    }

    function addProtocols(
        string[] memory protocolNames,
        ProtocolMetadata[] memory metadata,
        address[][] memory adapters,
        address[][][] memory tokens
    )
        public
        onlyOwner
    {
        require(protocolNames.length == metadata.length, "PM: protocolNames & metadata differ!");
        require(protocolNames.length == adapters.length, "PM: protocolNames & adapters differ!");
        require(protocolNames.length == tokens.length, "PM: protocolNames & tokens differ!");
        require(protocolNames.length != 0, "PM: empty!");

        for (uint256 i = 0; i < protocolNames.length; i++) {
            addProtocol(protocolNames[i], metadata[i], adapters[i], tokens[i]);
        }
    }

    function removeProtocols(
        string[] memory protocolNames
    )
        public
        onlyOwner
    {
        require(protocolNames.length != 0, "PM: empty!");

        for (uint256 i = 0; i < protocolNames.length; i++) {
            removeProtocol(protocolNames[i]);
        }
    }

    function updateProtocolMetadata(
        string memory protocolName,
        string memory name,
        string memory description,
        string memory websiteURL,
        string memory iconURL
    )
        public
        onlyOwner
    {
        require(isValidProtocol(protocolName), "PM: bad name!");
        require(abi.encodePacked(name, description, websiteURL, iconURL).length != 0, "PM: empty!");

        ProtocolMetadata storage metadata = protocolMetadata[protocolName];

        if (!name.isEmpty()) {
            metadata.name = name;
        }

        if (!description.isEmpty()) {
            metadata.description = description;
        }

        if (!websiteURL.isEmpty()) {
            metadata.websiteURL = websiteURL;
        }

        if (!iconURL.isEmpty()) {
            metadata.iconURL = iconURL;
        }

        metadata.version++;
    }

    function addProtocolAdapters(
        string memory protocolName,
        address[] memory adapters,
        address[][] memory tokens
    )
        public
        onlyOwner
    {
        require(isValidProtocol(protocolName), "PM: bad name!");
        require(adapters.length != 0, "PM: empty!");

        for (uint256 i = 0; i < adapters.length; i++) {
            addProtocolAdapter(protocolName, adapters[i], tokens[i]);
        }

        protocolMetadata[protocolName].version++;
    }

    function removeProtocolAdapters(
        string memory protocolName,
        uint256[] memory adapterIndices
    )
        public
        onlyOwner
    {
        require(isValidProtocol(protocolName), "PM: bad name!");
        require(adapterIndices.length != 0, "PM: empty!");

        for (uint256 i = 0; i < adapterIndices.length; i++) {
            removeProtocolAdapter(protocolName, adapterIndices[i]);
        }

        protocolMetadata[protocolName].version++;
    }

    function updateProtocolAdapter(
        string memory protocolName,
        uint256 index,
        address newAdapterAddress,
        address[] memory newSupportedTokens
    )
        public
        onlyOwner
    {
        require(isValidProtocol(protocolName), "PM: bad name!");
        require(index < protocolAdapters[protocolName].length, "PM: bad index!");
        require(newAdapterAddress != address(0), "PM: empty!");

        address adapterAddress = protocolAdapters[protocolName][index];

        if (newAdapterAddress == adapterAddress) {
            supportedTokens[adapterAddress] = newSupportedTokens;
        } else {
            protocolAdapters[protocolName][index] = newAdapterAddress;
            supportedTokens[newAdapterAddress] = newSupportedTokens;
            delete supportedTokens[adapterAddress];
        }

        protocolMetadata[protocolName].version++;
    }

    function getProtocolNames()
        public
        view
        returns (string[] memory)
    {
        uint256 counter = 0;
        string memory currentProtocolName = nextProtocolName[INITIAL_PROTOCOL_NAME];

        while (!currentProtocolName.isEqualTo(INITIAL_PROTOCOL_NAME)) {
            currentProtocolName = nextProtocolName[currentProtocolName];
            counter++;
        }

        string[] memory protocols = new string[](counter);
        counter = 0;
        currentProtocolName = nextProtocolName[INITIAL_PROTOCOL_NAME];

        while (!currentProtocolName.isEqualTo(INITIAL_PROTOCOL_NAME)) {
            protocols[counter] = currentProtocolName;
            currentProtocolName = nextProtocolName[currentProtocolName];
            counter++;
        }

        return protocols;
    }

    function getProtocolMetadata(
        string memory protocolName
    )
        public
        view
        returns (ProtocolMetadata memory)
    {
        return (protocolMetadata[protocolName]);
    }

    function getProtocolAdapters(
        string memory protocolName
    )
        public
        view
        returns (address[] memory)
    {
        return protocolAdapters[protocolName];
    }

    function getSupportedTokens(
        address adapter
    )
        public
        view
        returns (address[] memory)
    {
        return supportedTokens[adapter];
    }

    function isValidProtocol(
        string memory protocolName
    )
        public
        view
        returns (bool)
    {
        return !nextProtocolName[protocolName].isEmpty() && !protocolName.isEqualTo(INITIAL_PROTOCOL_NAME);
    }

    function addProtocol(
        string memory protocolName,
        ProtocolMetadata memory metadata,
        address[] memory adapters,
        address[][] memory tokens
    )
        internal
    {
        require(!protocolName.isEqualTo(INITIAL_PROTOCOL_NAME), "PM: initial name!");
        require(!protocolName.isEmpty(), "PM: empty name!");
        require(nextProtocolName[protocolName].isEmpty(), "PM: name exists!");
        require(adapters.length == tokens.length, "PM: adapters & tokens differ!");

        nextProtocolName[protocolName] = nextProtocolName[INITIAL_PROTOCOL_NAME];
        nextProtocolName[INITIAL_PROTOCOL_NAME] = protocolName;

        protocolMetadata[protocolName] = ProtocolMetadata({
            name: metadata.name,
            description: metadata.description,
            websiteURL: metadata.websiteURL,
            iconURL: metadata.iconURL,
            version: metadata.version
        });

        for (uint256 i = 0; i < adapters.length; i++) {
            addProtocolAdapter(protocolName, adapters[i], tokens[i]);
        }
    }

    function removeProtocol(
        string memory protocolName
    )
        internal
    {
        require(isValidProtocol(protocolName), "PM: bad name!");

        string memory prevProtocolName;
        string memory currentProtocolName = nextProtocolName[protocolName];
        while (!currentProtocolName.isEqualTo(protocolName)) {
            prevProtocolName = currentProtocolName;
            currentProtocolName = nextProtocolName[currentProtocolName];
        }

        delete protocolMetadata[protocolName];

        nextProtocolName[prevProtocolName] = nextProtocolName[protocolName];
        delete nextProtocolName[protocolName];

        uint256 length = protocolAdapters[protocolName].length;
        for (uint256 i = length - 1; i < length; i--) {
            removeProtocolAdapter(protocolName, i);
        }
    }

    function addProtocolAdapter(
        string memory protocolName,
        address adapter,
        address[] memory tokens
    )
        internal
    {
        require(adapter != address(0), "PM: zero!");
        require(supportedTokens[adapter].length == 0, "PM: exists!");

        protocolAdapters[protocolName].push(adapter);
        supportedTokens[adapter] = tokens;
    }

    function removeProtocolAdapter(
        string memory protocolName,
        uint256 index
    )
        internal
    {
        uint256 length = protocolAdapters[protocolName].length;
        require(index < length, "PM: bad index!");

        delete supportedTokens[protocolAdapters[protocolName][index]];

        if (index != length - 1) {
            protocolAdapters[protocolName][index] = protocolAdapters[protocolName][length - 1];
        }

        protocolAdapters[protocolName].pop();
    }
}


contract AdapterRegistry is Ownable, ProtocolManager, TokenAdapterManager {


    using Strings for string;

    function getFullTokenBalance(
        string calldata tokenType,
        address token
    )
        external
        view
        returns (FullTokenBalance memory)
    {

        Component[] memory components = getComponents(tokenType, token, 1e18);
        return getFullTokenBalance(tokenType, token, 1e18, components);
    }

    function getFinalFullTokenBalance(
        string calldata tokenType,
        address token
    )
        external
        view
        returns (FullTokenBalance memory)
    {

        Component[] memory finalComponents = getFinalComponents(tokenType, token, 1e18);
        return getFullTokenBalance(tokenType, token, 1e18, finalComponents);
    }

    function getBalances(
        address account
    )
        external
        view
        returns (ProtocolBalance[] memory)
    {

        string[] memory protocolNames = getProtocolNames();

        return getProtocolBalances(account, protocolNames);
    }

    function getProtocolBalances(
        address account,
        string[] memory protocolNames
    )
        public
        view
        returns (ProtocolBalance[] memory)
    {

        ProtocolBalance[] memory protocolBalances = new ProtocolBalance[](protocolNames.length);
        uint256 counter = 0;

        for (uint256 i = 0; i < protocolNames.length; i++) {
            protocolBalances[i] = ProtocolBalance({
                metadata: protocolMetadata[protocolNames[i]],
                adapterBalances: getAdapterBalances(account, protocolAdapters[protocolNames[i]])
            });
            if (protocolBalances[i].adapterBalances.length > 0) {
                counter++;
            }
        }

        ProtocolBalance[] memory nonZeroProtocolBalances = new ProtocolBalance[](counter);
        counter = 0;

        for (uint256 i = 0; i < protocolNames.length; i++) {
            if (protocolBalances[i].adapterBalances.length > 0) {
                nonZeroProtocolBalances[counter] = protocolBalances[i];
                counter++;
            }
        }

        return nonZeroProtocolBalances;
    }

    function getAdapterBalances(
        address account,
        address[] memory adapters
    )
        public
        view
        returns (AdapterBalance[] memory)
    {

        AdapterBalance[] memory adapterBalances = new AdapterBalance[](adapters.length);
        uint256 counter = 0;

        for (uint256 i = 0; i < adapterBalances.length; i++) {
            adapterBalances[i] = getAdapterBalance(
                account,
                adapters[i],
                supportedTokens[adapters[i]]
            );
            if (adapterBalances[i].balances.length > 0) {
                counter++;
            }
        }

        AdapterBalance[] memory nonZeroAdapterBalances = new AdapterBalance[](counter);
        counter = 0;

        for (uint256 i = 0; i < adapterBalances.length; i++) {
            if (adapterBalances[i].balances.length > 0) {
                nonZeroAdapterBalances[counter] = adapterBalances[i];
                counter++;
            }
        }

        return nonZeroAdapterBalances;
    }

    function getAdapterBalance(
        address account,
        address adapter,
        address[] memory tokens
    )
        public
        view
        returns (AdapterBalance memory)
    {

        string memory tokenType = ProtocolAdapter(adapter).tokenType();
        uint256[] memory amounts = new uint256[](tokens.length);
        uint256 counter;

        for (uint256 i = 0; i < amounts.length; i++) {
            try ProtocolAdapter(adapter).getBalance(tokens[i], account) returns (uint256 result) {
                amounts[i] = result;
            } catch {
                amounts[i] = 0;
            }
            if (amounts[i] > 0) {
                counter++;
            }
        }

        FullTokenBalance[] memory finalFullTokenBalances = new FullTokenBalance[](counter);
        counter = 0;

        for (uint256 i = 0; i < amounts.length; i++) {
            if (amounts[i] > 0) {
                finalFullTokenBalances[counter] = getFullTokenBalance(
                    tokenType,
                    tokens[i],
                    amounts[i],
                    getFinalComponents(tokenType, tokens[i], amounts[i])
                );
                counter++;
            }
        }

        return AdapterBalance({
            metadata: AdapterMetadata({
                adapterAddress: adapter,
                adapterType: ProtocolAdapter(adapter).adapterType()
            }),
            balances: finalFullTokenBalances
        });
    }

    function getFullTokenBalance(
        string memory tokenType,
        address token,
        uint256 amount,
        Component[] memory components
    )
        internal
        view
        returns (FullTokenBalance memory)
    {

        TokenBalance[] memory componentTokenBalances = new TokenBalance[](components.length);

        for (uint256 i = 0; i < components.length; i++) {
            componentTokenBalances[i] = getTokenBalance(
                components[i].tokenType,
                components[i].token,
                components[i].rate
            );
        }

        return FullTokenBalance({
            base: getTokenBalance(tokenType, token, amount),
            underlying: componentTokenBalances
        });
    }

    function getFinalComponents(
        string memory tokenType,
        address token,
        uint256 amount
    )
        internal
        view
        returns (Component[] memory)
    {

        uint256 totalLength = getFinalComponentsNumber(tokenType, token, true);
        Component[] memory finalTokens = new Component[](totalLength);
        uint256 length;
        uint256 init = 0;

        Component[] memory components = getComponents(tokenType, token, amount);
        Component[] memory finalComponents;

        for (uint256 i = 0; i < components.length; i++) {
            finalComponents = getFinalComponents(
                components[i].tokenType,
                components[i].token,
                components[i].rate
            );

            length = finalComponents.length;

            if (length == 0) {
                finalTokens[init] = components[i];
                init = init + 1;
            } else {
                for (uint256 j = 0; j < length; j++) {
                    finalTokens[init + j] = finalComponents[j];
                }

                init = init + length;
            }
        }

        return finalTokens;
    }

    function getFinalComponentsNumber(
        string memory tokenType,
        address token,
        bool initial
    )
        internal
        view
        returns (uint256)
    {

        uint256 totalLength = 0;
        Component[] memory components = getComponents(tokenType, token, 1e18);

        if (components.length == 0) {
            return initial ? uint256(0) : uint256(1);
        }

        for (uint256 i = 0; i < components.length; i++) {
            totalLength = totalLength + getFinalComponentsNumber(
                components[i].tokenType,
                components[i].token,
                false
            );
        }

        return totalLength;
    }

    function getComponents(
        string memory tokenType,
        address token,
        uint256 amount
    )
        internal
        view
        returns (Component[] memory)
    {

        TokenAdapter adapter = TokenAdapter(tokenAdapter[tokenType]);
        Component[] memory components;

        if (address(adapter) != address(0)) {
            try adapter.getComponents(token) returns (Component[] memory result) {
                components = result;
            } catch {
                components = new Component[](0);
            }
        } else {
            components = new Component[](0);
        }

        for (uint256 i = 0; i < components.length; i++) {
            components[i].rate = components[i].rate * amount / 1e18;
        }

        return components;
    }

    function getTokenBalance(
        string memory tokenType,
        address token,
        uint256 amount
    )
        internal
        view
        returns (TokenBalance memory)
    {

        TokenAdapter adapter = TokenAdapter(tokenAdapter[tokenType]);
        TokenBalance memory tokenBalance;
        tokenBalance.amount = amount;

        if (address(adapter) != address(0)) {
            try adapter.getMetadata(token) returns (TokenMetadata memory result) {
                tokenBalance.metadata = result;
            } catch {
                tokenBalance.metadata = TokenMetadata({
                    token: token,
                    name: "Not available",
                    symbol: "N/A",
                    decimals: 0
                });
            }
        } else {
            tokenBalance.metadata = TokenMetadata({
                token: token,
                name: "Not available",
                symbol: "N/A",
                decimals: 0
            });
        }

        return tokenBalance;
    }
}