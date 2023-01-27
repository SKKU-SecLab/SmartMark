
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

pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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

pragma solidity ^0.8.2;


abstract contract Initializable {
    uint8 private _initialized;

    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}// MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);


  function description() external view returns (string memory);


  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

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
        _checkRole(role);
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
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

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    uint256[49] private __gap;
}// Apache-2.0
pragma solidity 0.8.12;


contract Presale is AccessControl, Initializable, OwnableUpgradeable {

    AggregatorV3Interface internal priceFeed;

    mapping(address => BuyerData) buyerInfo;
    mapping(string => TokenData) tokenInfo;
    mapping(address => bool) discountWhitelist;
    mapping(string => uint256) referralCodes;

    uint256 public startTime;
    uint256 public endTime;
    uint256 public totalUnitAmount;
    uint256 public totalAmountSold;

    uint256 public unitPrice;
    uint256 public distrPercWithHYFI;
    uint256 public HYFIexchangeRate;
    address internal collectorWallet;
    address[] internal _buyersAddressList;
    string[] internal referralCodeList;

    struct BuyerData {
        uint256 totalAmountBought;
        uint256 referralAmountBought;
        mapping(string => uint256) referrals;
        string[] referralsList;
    }

    struct TokenData {
        IERC20 tokenAddress;
        uint256 totalAmountBought;
        uint256 decimals;
    }

    bytes32 public constant HYFI_SETTER_ROLE = keccak256("HYFI_SETTER_ROLE");

    event AllUnitsSold(uint256 unitAmount, uint256 endTime);
    event AddedToWhitelist(address indexed account);
    event CurrencyWithdrawn(address from, address to, uint256 amount);
    event ERC20Withdrawn(
        address from,
        address to,
        uint256 amount,
        address tokenAddress
    );
    event FundsRetrieved(address addr, uint256 amount);
    event UnitSold(string token, uint256 amount);
    event RemovedFromWhitelist(address indexed account);

    modifier addressNotZero(address addr) {

        require(
            addr != address(0),
            "Passed parameter has zero address declared"
        );
        _;
    }

    modifier amountNotZero(uint256 amount) {

        require(amount > 0, "Passed amount is equal to zero");
        _;
    }

    modifier limitedExchangeRate(uint256 rate) {

        require(
            rate > 0 && rate <= 10**18,
            "Exhange rate must be greater than 0 and less or equal to 10^18"
        );
        _;
    }

    modifier ongoingSale() {

        require(
            block.timestamp >= startTime,
            "You can not buy any units, sale has not started yet"
        );
        require(
            block.timestamp <= endTime,
            "You can no longer buy any units, time expired"
        );
        _;
    }

    modifier saleEnded() {

        require(
            block.timestamp >= endTime,
            "You can still buy items, sale has not ended yet"
        );
        _;
    }

    modifier possiblePurchaseUntilHardcap(uint256 amount) {

        require(
            totalAmountSold + amount <= totalUnitAmount,
            "Hardcap is reached, can not buy that many units"
        );
        _;
    }

    receive() external payable {}

    fallback() external payable {}

    function initialize(
        IERC20 USDTtokenAddress,
        IERC20 USDCtokenAddress,
        IERC20 HYFItokenAddress,
        address _collectorWallet,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _unitPrice,
        uint256 _HYFIexchangeRate
    ) public payable initializer {

        __Ownable_init();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(HYFI_SETTER_ROLE, msg.sender);
        priceFeed = AggregatorV3Interface(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        );

        tokenInfo["USDT"].tokenAddress = USDTtokenAddress;
        tokenInfo["USDT"].decimals = tokenInfo["USDC"].decimals = 10**6;

        tokenInfo["USDC"].tokenAddress = USDCtokenAddress;

        tokenInfo["HYFI"].tokenAddress = HYFItokenAddress;
        tokenInfo["HYFI"].decimals = tokenInfo["ETH"].decimals = 10**18;

        collectorWallet = _collectorWallet;

        unitPrice = _unitPrice;
        distrPercWithHYFI = 50;
        HYFIexchangeRate = _HYFIexchangeRate;

        startTime = _startTime;
        endTime = _endTime;

        totalUnitAmount = 10_000;
        totalAmountSold = 0;
    }

    function buyWithTokens(
        string memory token,
        bool buyWithHYFI,
        uint256 amount,
        string memory referralCode
    )
        external
        payable
        addressNotZero(msg.sender)
        amountNotZero(amount)
        ongoingSale
        possiblePurchaseUntilHardcap(amount)
    {

        require(
            keccak256(abi.encodePacked(token)) ==
                keccak256(abi.encodePacked("USDT")) ||
                keccak256(abi.encodePacked(token)) ==
                keccak256(abi.encodePacked("USDC")),
            "No stable coin provided"
        );
        uint256 discount = _discountPercentageCalculator(amount, msg.sender);
        if (buyWithHYFI) {
            _buyWithHYFIToken(token, amount, discount);
            emit UnitSold(token, amount);
        } else {
            _buyWithMainToken(token, amount, discount);
            emit UnitSold(token, amount);
        }
        if (bytes(referralCode).length != 0) {
            _updateReferral(amount, referralCode, msg.sender);
        }
    }

    function buyWithCurrency(uint256 amount, string memory referralCode)
        external
        payable
        addressNotZero(msg.sender)
        amountNotZero(amount)
        ongoingSale
        possiblePurchaseUntilHardcap(amount)
    {

        _buyWithCurrency(
            amount,
            _discountPercentageCalculator(amount, msg.sender)
        );
        if (bytes(referralCode).length != 0) {
            _updateReferral(amount, referralCode, msg.sender);
        }
    }

    function _buyWithMainToken(
        string memory token,
        uint256 unitAmount,
        uint256 discount
    ) internal {

        uint256 priceTotal = simpleTokenPaymentCalculator(
            token,
            unitAmount,
            discount
        );
        require(
            tokenInfo[token].tokenAddress.balanceOf(msg.sender) >= priceTotal,
            "Buyer does not have enough funds to make this purchase"
        );
        tokenInfo[token].tokenAddress.transferFrom(
            msg.sender,
            collectorWallet,
            priceTotal
        );
        _updateData(token, unitAmount, msg.sender);
    }

    function _buyWithHYFIToken(
        string memory token,
        uint256 unitAmount,
        uint256 discount
    ) internal limitedExchangeRate(HYFIexchangeRate) {

        uint256 HYFItokenPayment;
        uint256 stableCoinPaymentAmount;
        (
            stableCoinPaymentAmount,
            HYFItokenPayment
        ) = mixedTokenPaymentCalculator(token, unitAmount, discount);
        tokenInfo[token].tokenAddress.transferFrom(
            msg.sender,
            collectorWallet,
            stableCoinPaymentAmount
        );
        tokenInfo["HYFI"].tokenAddress.transferFrom(
            msg.sender,
            collectorWallet,
            HYFItokenPayment
        );
        _updateData("HYFI", unitAmount, msg.sender);
    }

    function _buyWithCurrency(uint256 unitAmount, uint256 discount) internal {

        uint256 priceTotal = currencyPaymentCalculator(unitAmount, discount);
        require(
            msg.value == priceTotal,
            "Buyer does not have enough funds to make this purchase"
        );
        payable(collectorWallet).transfer(priceTotal);
        _updateData("ETH", unitAmount, msg.sender);
    }

    function _updateData(
        string memory token,
        uint256 unitAmount,
        address buyer
    ) internal {

        totalAmountSold += unitAmount;
        tokenInfo[token].totalAmountBought += unitAmount;
        if (buyerInfo[buyer].totalAmountBought == 0) {
            _buyersAddressList.push(buyer);
        }
        buyerInfo[buyer].totalAmountBought += unitAmount;
        if (totalAmountSold >= totalUnitAmount) {
            endTime = block.timestamp;
            emit AllUnitsSold(unitAmount, endTime);
        }
    }

    function _updateReferral(
        uint256 amount,
        string memory referralCode,
        address buyer
    ) internal {

        if (buyerInfo[buyer].referrals[referralCode] == 0) {
            buyerInfo[buyer].referralsList.push(referralCode);
        }
        buyerInfo[buyer].referrals[referralCode] += amount;
        if (referralCodes[referralCode] == 0) {
            referralCodeList.push(referralCode);
        }
        buyerInfo[buyer].referralAmountBought += amount;
        referralCodes[referralCode] += amount;
    }

    function withdrawCurrency(address recipient, uint256 amount)
        external
        onlyOwner
        amountNotZero(amount)
        addressNotZero(recipient)
    {

        require(
            address(this).balance >= amount,
            "Contract does not have enough currency"
        );
        payable(recipient).transfer(amount);
        emit CurrencyWithdrawn(recipient, msg.sender, amount);
    }

    function withdrawERC20Tokens(
        IERC20 tokenAddress,
        address recipient,
        uint256 amount
    )
        external
        onlyOwner
        amountNotZero(amount)
        addressNotZero(recipient)
        returns (bool)
    {

        require(
            tokenAddress.balanceOf(address(this)) >= amount,
            "Contract does not have enough ERC20 tokens"
        );
        tokenAddress.approve(address(this), amount);
        if (!tokenAddress.transferFrom(address(this), recipient, amount)) {
            return false;
        }
        emit ERC20Withdrawn(
            recipient,
            msg.sender,
            amount,
            address(tokenAddress)
        );
        return true;
    }

    function addToWhitelist(address _address) public onlyOwner {

        discountWhitelist[_address] = true;
        emit AddedToWhitelist(_address);
    }

    function addMultipleToWhitelist(address[] memory _addresses)
        external
        onlyOwner
    {

        for (uint256 addr = 0; addr < _addresses.length; addr++) {
            addToWhitelist(_addresses[addr]);
        }
    }

    function removeFromWhitelist(address _address) external onlyOwner {

        discountWhitelist[_address] = false;
        emit RemovedFromWhitelist(_address);
    }

    function isWhitelisted(address _address) public view returns (bool) {

        return discountWhitelist[_address];
    }

    function setNewSaleTime(uint256 newStartTime, uint256 newEndTime)
        external
        onlyOwner
    {

        startTime = newStartTime;
        endTime = newEndTime;
    }

    function setCollectorWalletAddress(address newAddress) external onlyOwner {

        collectorWallet = newAddress;
    }

    function setTotalUnitAmount(uint256 newAmount) external onlyOwner {

        totalUnitAmount = newAmount;
    }

    function setHYFIexchangeRate(uint256 newExchangeRate)
        external
        onlyRole(HYFI_SETTER_ROLE)
        limitedExchangeRate(newExchangeRate)
    {

        HYFIexchangeRate = newExchangeRate;
    }

    function setUnitPrice(uint256 newPrice) external onlyOwner {

        unitPrice = newPrice;
    }

    function discountAmountCalculator(uint256 discount, uint256 value)
        public
        pure
        returns (uint256 discountAmount)
    {

        discountAmount = (value * discount) / 10000;
        return discountAmount;
    }

    function currencyPaymentCalculator(uint256 unitAmount, uint256 discount)
        public
        view
        returns (uint256 paymentAmount)
    {

        uint256 priceTotal = ((unitAmount * unitPrice * 10**8) *
            tokenInfo["ETH"].decimals) / uint256(getLatestETHPrice());
        priceTotal -= discountAmountCalculator(discount, priceTotal);
        return priceTotal;
    }

    function simpleTokenPaymentCalculator(
        string memory token,
        uint256 unitAmount,
        uint256 discount
    ) public view returns (uint256 paymentAmount) {

        uint256 priceTotal = (unitPrice * tokenInfo[token].decimals) *
            unitAmount;
        priceTotal -= discountAmountCalculator(discount, priceTotal);
        return priceTotal;
    }

    function mixedTokenPaymentCalculator(
        string memory token,
        uint256 unitAmount,
        uint256 discount
    )
        public
        view
        returns (uint256 stableCoinPaymentAmount, uint256 HYFIPaymentAmount)
    {

        uint256 baseTokenPayment = ((unitPrice * tokenInfo[token].decimals) *
            unitAmount *
            distrPercWithHYFI) / 100;
        baseTokenPayment -= discountAmountCalculator(
            discount,
            baseTokenPayment
        );
        uint256 HYFItokenPayment = ((((unitPrice * tokenInfo["HYFI"].decimals) *
            unitAmount *
            distrPercWithHYFI) / 100) / HYFIexchangeRate) * 10**18;
        HYFItokenPayment -= discountAmountCalculator(
            discount,
            HYFItokenPayment
        );
        return (baseTokenPayment, HYFItokenPayment);
    }

    function _discountPercentageCalculator(uint256 unitAmount, address buyer)
        internal
        view
        returns (uint256 discountPrecentage)
    {

        if (unitAmount <= 4) {
            discountPrecentage = 1000;
        } else if (unitAmount <= 50) {
            discountPrecentage = 1500;
        } else {
            discountPrecentage = 2000;
        }
        if (isWhitelisted(buyer)) {
            discountPrecentage += 500;
        }
        return discountPrecentage;
    }

    function getBuyerData(address addr)
        external
        view
        returns (
            uint256,
            uint256,
            string[] memory
        )
    {

        return (
            buyerInfo[addr].totalAmountBought,
            buyerInfo[addr].referralAmountBought,
            buyerInfo[addr].referralsList
        );
    }

    function getBuyerReferralData(address addr, string memory refferal)
        external
        view
        returns (uint256)
    {

        return (buyerInfo[addr].referrals[refferal]);
    }

    function getTokenData(string memory token)
        external
        view
        returns (TokenData memory)
    {

        return (tokenInfo[token]);
    }

    function getAmountBoughtWithReferral(string memory referralCode)
        external
        view
        returns (uint256)
    {

        return (referralCodes[referralCode]);
    }

    function getAllReferralCodeList()
        external
        view
        onlyOwner
        returns (string[] memory)
    {

        return (referralCodeList);
    }

    function getTotalAmountOfBuyers() external view returns (uint256) {

        return (_buyersAddressList.length);
    }

    function getBuyerFromListById(uint256 id) external view returns (address) {

        return (_buyersAddressList[id]);
    }

    function getAllBuyers() external view returns (address[] memory) {

        return (_buyersAddressList);
    }

    function getLatestETHPrice() public view returns (int256) {

        (
            ,
            int256 price, /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/
            ,
            ,

        ) = priceFeed.latestRoundData();
        return price;
    }

    function _msgSender()
        internal
        view
        virtual
        override(Context, ContextUpgradeable)
        returns (address)
    {

        return msg.sender;
    }

    function _msgData()
        internal
        view
        virtual
        override(Context, ContextUpgradeable)
        returns (bytes calldata)
    {

        return msg.data;
    }
}