pragma solidity ^0.8.0;

interface IERC20 {

    function symbol() external view returns (string memory);


    function balanceOf(address account) external view returns (uint256);


    function decimals() external view returns (uint8);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}// Apache-2.0
pragma solidity ^0.8.0;


interface IYearnVault is IERC20 {

    function deposit(uint256, address) external returns (uint256);


    function withdraw(
        uint256,
        address,
        uint256
    ) external returns (uint256);


    function pricePerShare() external view returns (uint256);


    function governance() external view returns (address);


    function setDepositLimit(uint256) external;


    function totalSupply() external view returns (uint256);


    function totalAssets() external view returns (uint256);


    function apiVersion() external view returns (string memory);

}// Apache-2.0
pragma solidity ^0.8.0;


interface IWETH is IERC20 {

    function deposit() external payable;


    function withdraw(uint256 wad) external;


    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);
}// Forked from openzepplin

pragma solidity ^0.8.0;


interface IERC20Permit is IERC20 {

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function nonces(address owner) external view returns (uint256);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

}// Apache-2.0
pragma solidity ^0.8.0;


interface IWrappedPosition is IERC20Permit {

    function token() external view returns (IERC20);


    function balanceOfUnderlying(address who) external view returns (uint256);


    function getSharesToUnderlying(uint256 shares)
        external
        view
        returns (uint256);


    function deposit(address sender, uint256 amount) external returns (uint256);


    function withdraw(
        address sender,
        uint256 _shares,
        uint256 _minUnderlying
    ) external returns (uint256);


    function withdrawUnderlying(
        address _destination,
        uint256 _amount,
        uint256 _minUnderlying
    ) external returns (uint256, uint256);


    function prefundedDeposit(address _destination)
        external
        returns (
            uint256,
            uint256,
            uint256
        );

}// Apache-2.0

pragma solidity ^0.8.0;


abstract contract ERC20Permit is IERC20Permit {
    string public name;
    string public override symbol;
    uint8 public override decimals;

    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;
    mapping(address => uint256) public override nonces;

    bytes32 public override DOMAIN_SEPARATOR;
    bytes32
        public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
        decimals = 18;

        balanceOf[address(0)] = type(uint256).max;
        balanceOf[address(this)] = type(uint256).max;

        _extraConstruction();

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(name)),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );
    }

    function _extraConstruction() internal virtual {}

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        return transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(
        address spender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 balance = balanceOf[spender];
        require(balance >= amount, "ERC20: insufficient-balance");
        if (spender != msg.sender) {
            uint256 allowed = allowance[spender][msg.sender];
            if (allowed != type(uint256).max) {
                require(allowed >= amount, "ERC20: insufficient-allowance");
                allowance[spender][msg.sender] = allowed - amount;
            }
        }
        balanceOf[spender] = balance - amount;
        balanceOf[recipient] = balanceOf[recipient] + amount;
        emit Transfer(spender, recipient, amount);
        return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
        balanceOf[account] = balanceOf[account] + amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        balanceOf[account] = balanceOf[account] - amount;
        emit Transfer(account, address(0), amount);
    }

    function approve(address account, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        allowance[msg.sender][account] = amount;
        emit Approval(msg.sender, account, amount);
        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        owner,
                        spender,
                        value,
                        nonces[owner],
                        deadline
                    )
                )
            )
        );
        require(owner != address(0), "ERC20: invalid-address-0");
        require(owner == ecrecover(digest, v, r, s), "ERC20: invalid-permit");
        require(
            deadline == 0 || block.timestamp <= deadline,
            "ERC20: permit-expired"
        );
        require(
            uint256(s) <=
                0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "ERC20: invalid signature 's' value"
        );
        nonces[owner]++;
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _setupDecimals(uint8 decimals_) internal {
        decimals = decimals_;
    }
}// Apache-2.0
pragma solidity ^0.8.0;



abstract contract WrappedPosition is ERC20Permit, IWrappedPosition {
    IERC20 public immutable override token;

    constructor(
        IERC20 _token,
        string memory _name,
        string memory _symbol
    ) ERC20Permit(_name, _symbol) {
        token = _token;
        _setupDecimals(_token.decimals());
    }


    function _deposit() internal virtual returns (uint256, uint256);

    function _withdraw(
        uint256,
        address,
        uint256
    ) internal virtual returns (uint256);

    function _underlying(uint256) internal virtual view returns (uint256);

    function balanceOfUnderlying(address _who)
        external
        override
        view
        returns (uint256)
    {
        return _underlying(balanceOf[_who]);
    }

    function getSharesToUnderlying(uint256 _shares)
        external
        override
        view
        returns (uint256)
    {
        return _underlying(_shares);
    }

    function deposit(address _destination, uint256 _amount)
        external
        override
        returns (uint256)
    {
        token.transferFrom(msg.sender, address(this), _amount);
        (uint256 shares, ) = _deposit();
        _mint(_destination, shares);
        return shares;
    }

    function prefundedDeposit(address _destination)
        external
        override
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        (uint256 shares, uint256 usedUnderlying) = _deposit();

        uint256 balanceBefore = balanceOf[_destination];

        _mint(_destination, shares);
        return (shares, usedUnderlying, balanceBefore);
    }

    function withdraw(
        address _destination,
        uint256 _shares,
        uint256 _minUnderlying
    ) public override returns (uint256) {
        return _positionWithdraw(_destination, _shares, _minUnderlying, 0);
    }

    function withdrawUnderlying(
        address _destination,
        uint256 _amount,
        uint256 _minUnderlying
    ) external override returns (uint256, uint256) {
        uint256 oneUnit = 10**decimals;
        uint256 underlyingPerShare = _underlying(oneUnit);
        uint256 shares = (_amount * oneUnit) / underlyingPerShare;
        uint256 underlyingReceived = _positionWithdraw(
            _destination,
            shares,
            _minUnderlying,
            underlyingPerShare
        );
        return (underlyingReceived, shares);
    }

    function _positionWithdraw(
        address _destination,
        uint256 _shares,
        uint256 _minUnderlying,
        uint256 _underlyingPerShare
    ) internal returns (uint256) {
        _burn(msg.sender, _shares);

        uint256 withdrawAmount = _withdraw(
            _shares,
            _destination,
            _underlyingPerShare
        );

        require(withdrawAmount >= _minUnderlying, "Not enough underlying");
        return withdrawAmount;
    }
}// Apache-2.0
pragma solidity ^0.8.0;


contract YVaultAssetProxy is WrappedPosition {

    IYearnVault public immutable vault;
    uint8 public immutable vaultDecimals;


    mapping(address => uint256) public reserveBalances;
    uint128 public reserveUnderlying;
    uint128 public reserveShares;
    uint256 public reserveSupply;

    constructor(
        address vault_,
        IERC20 _token,
        string memory _name,
        string memory _symbol
    ) WrappedPosition(_token, _name, _symbol) {
        vault = IYearnVault(vault_);
        _token.approve(vault_, type(uint256).max);
        uint8 localVaultDecimals = IERC20(vault_).decimals();
        vaultDecimals = localVaultDecimals;
        require(
            uint8(_token.decimals()) == localVaultDecimals,
            "Inconsistent decimals"
        );
        _versionCheck(IYearnVault(vault_));
    }

    function _versionCheck(IYearnVault _vault) internal virtual view {

        string memory apiVersion = _vault.apiVersion();
        require(
            _stringEq(apiVersion, "0.3.0") ||
                _stringEq(apiVersion, "0.3.1") ||
                _stringEq(apiVersion, "0.3.2") ||
                _stringEq(apiVersion, "0.3.3") ||
                _stringEq(apiVersion, "0.3.4") ||
                _stringEq(apiVersion, "0.3.5"),
            "Unsupported Version"
        );
    }

    function _stringEq(string memory s1, string memory s2)
        internal
        pure
        returns (bool)
    {

        bytes32 h1 = keccak256(abi.encodePacked(s1));
        bytes32 h2 = keccak256(abi.encodePacked(s2));
        return (h1 == h2);
    }

    function reserveDeposit(uint256 _amount) external {

        token.transferFrom(msg.sender, address(this), _amount);
        (uint256 localUnderlying, uint256 localShares) = _getReserves();
        uint256 totalValue = localUnderlying;
        totalValue += _yearnDepositConverter(localShares, true);
        uint256 localReserveSupply = reserveSupply;
        uint256 mintAmount;
        if (localReserveSupply == 0) {
            mintAmount = _amount;
        } else {
            mintAmount = (localReserveSupply * _amount) / totalValue;
        }

        if (localUnderlying == 0 && localShares == 0) {
            _amount -= 1;
        }
        _setReserves(localUnderlying + _amount, localShares);
        reserveBalances[msg.sender] += mintAmount;
        reserveSupply = localReserveSupply + mintAmount;
    }

    function reserveWithdraw(uint256 _amount) external {

        reserveBalances[msg.sender] -= _amount;
        (uint256 localUnderlying, uint256 localShares) = _getReserves();
        uint256 localReserveSupply = reserveSupply;
        uint256 userShares = (localShares * _amount) / localReserveSupply;
        uint256 freedUnderlying = vault.withdraw(userShares, address(this), 0);
        uint256 userUnderlying = (localUnderlying * _amount) /
            localReserveSupply;

        _setReserves(
            localUnderlying - userUnderlying,
            localShares - userShares
        );
        reserveSupply = localReserveSupply - _amount;

        token.transfer(msg.sender, freedUnderlying + userUnderlying);
    }

    function _deposit() internal override returns (uint256, uint256) {

        (uint256 localUnderlying, uint256 localShares) = _getReserves();
        uint256 amount = token.balanceOf(address(this)) - localUnderlying;
        if (localUnderlying != 0 || localShares != 0) {
            amount -= 1;
        }
        uint256 neededShares = _yearnDepositConverter(amount, false);

        if (localShares > neededShares) {
            _setReserves(localUnderlying + amount, localShares - neededShares);
            return (neededShares, amount);
        }
        uint256 shares = vault.deposit(localUnderlying + amount, address(this));

        uint256 userShare = (amount * shares) / (localUnderlying + amount);

        _setReserves(0, localShares + shares - userShare);
        return (userShare, amount);
    }

    function _withdraw(
        uint256 _shares,
        address _destination,
        uint256 _underlyingPerShare
    ) internal override returns (uint256) {

        if (_underlyingPerShare == 0) {
            _underlyingPerShare = _pricePerShare();
        }
        (uint256 localUnderlying, uint256 localShares) = _getReserves();
        uint256 needed = (_shares * _pricePerShare()) / (10**vaultDecimals);
        if (needed < localUnderlying) {
            _setReserves(localUnderlying - needed, localShares + _shares);
            token.transfer(_destination, needed);
            return (needed);
        }
        uint256 amountReceived = vault.withdraw(
            _shares + localShares,
            address(this),
            10000
        );

        uint256 userShare = (_shares * amountReceived) /
            (localShares + _shares);

        _setReserves(localUnderlying + amountReceived - userShare, 0);
        token.transfer(_destination, userShare);
        return userShare;
    }

    function _underlying(uint256 _amount)
        internal
        override
        view
        returns (uint256)
    {

        return (_amount * _pricePerShare()) / (10**vaultDecimals);
    }

    function _pricePerShare() internal view returns (uint256) {

        return vault.pricePerShare();
    }

    function approve() external {

        token.approve(address(vault), 0);
        token.approve(address(vault), type(uint256).max);
    }

    function _getReserves() internal view returns (uint256, uint256) {

        return (uint256(reserveUnderlying), uint256(reserveShares));
    }

    function _setReserves(
        uint256 _newReserveUnderlying,
        uint256 _newReserveShares
    ) internal {

        reserveUnderlying = uint128(_newReserveUnderlying);
        reserveShares = uint128(_newReserveShares);
    }

    function _yearnDepositConverter(uint256 amount, bool sharesIn)
        internal
        virtual
        view
        returns (uint256)
    {

        uint256 yearnTotalSupply = vault.totalSupply();
        uint256 yearnTotalAssets = vault.totalAssets();
        if (sharesIn) {
            return (yearnTotalAssets * amount) / yearnTotalSupply;
        } else {
            return (yearnTotalSupply * amount) / yearnTotalAssets;
        }
    }
}// Apache-2.0
pragma solidity ^0.8.0;


contract YVaultV4AssetProxy is YVaultAssetProxy {

    constructor(
        address vault_,
        IERC20 _token,
        string memory _name,
        string memory _symbol
    ) YVaultAssetProxy(vault_, _token, _name, _symbol) {}

    function _versionCheck(IYearnVault _vault) internal override view {

        string memory apiVersion = _vault.apiVersion();
        require(
            _stringEq(apiVersion, "0.4.2") || _stringEq(apiVersion, "0.4.3"),
            "Unsupported Version"
        );
    }

    function _yearnDepositConverter(uint256 amount, bool sharesIn)
        internal
        override
        view
        returns (uint256)
    {

        uint256 pricePerShare = vault.pricePerShare();
        if (sharesIn) {
            return (pricePerShare * amount) / 10**vaultDecimals;
        } else {
            return (amount * 10**vaultDecimals) / (pricePerShare + 1);
        }
    }
}