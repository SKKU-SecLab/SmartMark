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


interface IInterestToken is IERC20Permit {

    function mint(address _account, uint256 _amount) external;


    function burn(address _account, uint256 _amount) external;

}// Apache-2.0
pragma solidity ^0.8.0;


interface ITranche is IERC20Permit {

    function deposit(uint256 _shares, address destination)
        external
        returns (uint256, uint256);


    function prefundedDeposit(address _destination)
        external
        returns (uint256, uint256);


    function withdrawPrincipal(uint256 _amount, address _destination)
        external
        returns (uint256);


    function withdrawInterest(uint256 _amount, address _destination)
        external
        returns (uint256);


    function interestToken() external view returns (IInterestToken);


    function interestSupply() external view returns (uint128);

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

library DateString {

    uint256 public constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint256 public constant SECONDS_PER_HOUR = 60 * 60;
    uint256 public constant SECONDS_PER_MINUTE = 60;
    int256 public constant OFFSET19700101 = 2440588;

    function _daysToDate(uint256 _days)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day
        )
    {

        int256 __days = int256(_days);
        int256 L = __days + 68569 + OFFSET19700101;
        int256 N = (4 * L) / 146097;
        L = L - (146097 * N + 3) / 4;
        int256 _year = (4000 * (L + 1)) / 1461001;
        L = L - (1461 * _year) / 4 + 31;
        int256 _month = (80 * L) / 2447;
        int256 _day = L - (2447 * _month) / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint256(_year);
        month = uint256(_month);
        day = uint256(_day);
    }

    function encodeAndWriteTimestamp(
        string memory _prefix,
        uint256 _timestamp,
        string storage _output
    ) external {

        _encodeAndWriteTimestamp(_prefix, _timestamp, _output);
    }

    function _encodeAndWriteTimestamp(
        string memory _prefix,
        uint256 _timestamp,
        string storage _output
    ) internal {

        bytes memory bytePrefix = bytes(_prefix);
        bytes storage bytesOutput = bytes(_output);
        for (uint256 i = 0; i < bytePrefix.length; i++) {
            bytesOutput.push(bytePrefix[i]);
        }
        bytesOutput.push(bytes1("-"));
        timestampToDateString(_timestamp, _output);
    }

    function timestampToDateString(
        uint256 _timestamp,
        string storage _outputPointer
    ) public {

        _timestampToDateString(_timestamp, _outputPointer);
    }

    function _timestampToDateString(
        uint256 _timestamp,
        string storage _outputPointer
    ) internal {

        bytes storage output = bytes(_outputPointer);
        (uint256 year, uint256 month, uint256 day) = _daysToDate(
            _timestamp / SECONDS_PER_DAY
        );
        {
            uint256 firstDigit = day / 10;
            output.push(bytes1(uint8(bytes1("0")) + uint8(firstDigit)));
            uint256 secondDigit = day % 10;
            output.push(bytes1(uint8(bytes1("0")) + uint8(secondDigit)));
        }
        if (month == 1) {
            stringPush(output, "J", "A", "N");
        } else if (month == 2) {
            stringPush(output, "F", "E", "B");
        } else if (month == 3) {
            stringPush(output, "M", "A", "R");
        } else if (month == 4) {
            stringPush(output, "A", "P", "R");
        } else if (month == 5) {
            stringPush(output, "M", "A", "Y");
        } else if (month == 6) {
            stringPush(output, "J", "U", "N");
        } else if (month == 7) {
            stringPush(output, "J", "U", "L");
        } else if (month == 8) {
            stringPush(output, "A", "U", "G");
        } else if (month == 9) {
            stringPush(output, "S", "E", "P");
        } else if (month == 10) {
            stringPush(output, "O", "C", "T");
        } else if (month == 11) {
            stringPush(output, "N", "O", "V");
        } else if (month == 12) {
            stringPush(output, "D", "E", "C");
        } else {
            revert("date decoding error");
        }
        {
            uint256 lastDigits = year % 100;
            uint256 firstDigit = lastDigits / 10;
            output.push(bytes1(uint8(bytes1("0")) + uint8(firstDigit)));
            uint256 secondDigit = lastDigits % 10;
            output.push(bytes1(uint8(bytes1("0")) + uint8(secondDigit)));
        }
    }

    function stringPush(
        bytes storage output,
        bytes1 data1,
        bytes1 data2,
        bytes1 data3
    ) internal {

        output.push(data1);
        output.push(data2);
        output.push(data3);
    }
}// Apache-2.0
pragma solidity ^0.8.0;



contract InterestToken is ERC20Permit, IInterestToken {

    ITranche public immutable tranche;

    constructor(
        address _tranche,
        string memory _strategySymbol,
        uint256 _timestamp,
        uint8 _decimals
    )
        ERC20Permit(
            _processName("Element Yield Token ", _strategySymbol, _timestamp),
            _processSymbol("eY", _strategySymbol, _timestamp)
        )
    {
        tranche = ITranche(_tranche);
        _setupDecimals(_decimals);
    }

    function _processName(
        string memory _name,
        string memory _strategySymbol,
        uint256 _timestamp
    ) internal returns (string memory) {

        name = _name;
        DateString._encodeAndWriteTimestamp(_strategySymbol, _timestamp, name);
        return name;
    }

    function _processSymbol(
        string memory _symbol,
        string memory _strategySymbol,
        uint256 _timestamp
    ) internal returns (string memory) {

        symbol = _symbol;
        DateString._encodeAndWriteTimestamp(
            _strategySymbol,
            _timestamp,
            symbol
        );
        return symbol;
    }

    function totalSupply() external view returns (uint256) {

        return uint256(tranche.interestSupply());
    }

    modifier onlyMintAuthority() {

        require(
            msg.sender == address(tranche),
            "caller is not an authorized minter"
        );
        _;
    }

    function mint(address _account, uint256 _amount)
        external
        override
        onlyMintAuthority
    {

        _mint(_account, _amount);
    }

    function burn(address _account, uint256 _amount)
        external
        override
        onlyMintAuthority
    {

        _burn(_account, _amount);
    }
}// Apache-2.0
pragma solidity ^0.8.0;


interface ITrancheFactory {

    function getData()
        external
        returns (
            address,
            uint256,
            InterestToken,
            address
        );

}// Apache-2.0
pragma solidity ^0.8.0;



contract Tranche is ERC20Permit, ITranche {

    IInterestToken public immutable override interestToken;
    IWrappedPosition public immutable position;
    IERC20 public immutable underlying;
    uint8 internal immutable _underlyingDecimals;

    uint128 public valueSupplied;
    uint128 public override interestSupply;
    uint256 public immutable unlockTimestamp;
    uint256 internal constant _SLIPPAGE_BP = 1e13;
    uint256 public speedbump;
    uint256 internal constant _FORTY_EIGHT_HOURS = 172800;
    event SpeedBumpHit(uint256 timestamp);

    constructor() ERC20Permit("Element Principal Token ", "eP") {
        ITrancheFactory trancheFactory = ITrancheFactory(msg.sender);
        (
            address wpAddress,
            uint256 expiration,
            IInterestToken interestTokenTemp,
            address unused
        ) = trancheFactory.getData();
        interestToken = interestTokenTemp;

        IWrappedPosition wpContract = IWrappedPosition(wpAddress);
        position = wpContract;

        unlockTimestamp = expiration;
        IERC20 localUnderlying = wpContract.token();
        underlying = localUnderlying;
        uint8 localUnderlyingDecimals = localUnderlying.decimals();
        _underlyingDecimals = localUnderlyingDecimals;
        _setupDecimals(localUnderlyingDecimals);
    }

    function _extraConstruction() internal override {

        ITrancheFactory trancheFactory = ITrancheFactory(msg.sender);
        (
            address wpAddress,
            uint256 expiration,
            IInterestToken unused,
            address dateLib
        ) = trancheFactory.getData();

        string memory strategySymbol = IWrappedPosition(wpAddress).symbol();



        uint256 namePtr;
        uint256 symbolPtr;
        assembly {
            namePtr := name.slot
            symbolPtr := symbol.slot
        }
        (bool success1, ) = dateLib.delegatecall(
            abi.encodeWithSelector(
                DateString.encodeAndWriteTimestamp.selector,
                strategySymbol,
                expiration,
                namePtr
            )
        );
        (bool success2, ) = dateLib.delegatecall(
            abi.encodeWithSelector(
                DateString.encodeAndWriteTimestamp.selector,
                strategySymbol,
                expiration,
                symbolPtr
            )
        );
        assert(success1 && success2);
    }

    function totalSupply() external view returns (uint256) {

        return uint256(valueSupplied);
    }

    function deposit(uint256 _amount, address _destination)
        external
        override
        returns (uint256, uint256)
    {

        underlying.transferFrom(msg.sender, address(position), _amount);
        return prefundedDeposit(_destination);
    }

    function prefundedDeposit(address _destination)
        public
        override
        returns (uint256, uint256)
    {

        require(block.timestamp < unlockTimestamp, "expired");
        (
            uint256 shares,
            uint256 usedUnderlying,
            uint256 balanceBefore
        ) = position.prefundedDeposit(address(this));
        uint256 holdingsValue = (balanceBefore * usedUnderlying) / shares;
        (uint256 _valueSupplied, uint256 _interestSupply) = (
            uint256(valueSupplied),
            uint256(interestSupply)
        );
        require(_valueSupplied <= holdingsValue + 2, "E:NEG_INT");

        uint256 adjustedAmount;
        if (_valueSupplied > 0 && holdingsValue > _valueSupplied) {
            adjustedAmount =
                usedUnderlying -
                ((holdingsValue - _valueSupplied) * usedUnderlying) /
                _interestSupply;
        } else {
            adjustedAmount = usedUnderlying;
        }
        (valueSupplied, interestSupply) = (
            uint128(_valueSupplied + adjustedAmount),
            uint128(_interestSupply + usedUnderlying)
        );
        interestToken.mint(_destination, usedUnderlying);
        _mint(_destination, adjustedAmount);
        return (adjustedAmount, usedUnderlying);
    }

    function withdrawPrincipal(uint256 _amount, address _destination)
        external
        override
        returns (uint256)
    {

        require(block.timestamp >= unlockTimestamp, "E:Not Expired");
        uint256 localSpeedbump = speedbump;
        uint256 withdrawAmount = _amount;
        uint256 localSupply = uint256(valueSupplied);
        if (localSpeedbump != 0) {
            uint256 holdings = position.balanceOfUnderlying(address(this));
            if (holdings < localSupply) {
                withdrawAmount = (_amount * holdings) / localSupply;
                require(
                    localSpeedbump + _FORTY_EIGHT_HOURS < block.timestamp,
                    "E:Early"
                );
            }
        }
        _burn(msg.sender, _amount);
        valueSupplied = uint128(localSupply) - uint128(_amount);
        uint256 shareBalanceBefore = position.balanceOf(address(this));
        uint256 minOutput = withdrawAmount -
            (withdrawAmount * _SLIPPAGE_BP) /
            1e18;
        (uint256 actualWithdraw, uint256 sharesBurned) = position
            .withdrawUnderlying(_destination, withdrawAmount, minOutput);

        uint256 balanceBefore = (shareBalanceBefore * actualWithdraw) /
            sharesBurned;
        if (balanceBefore < localSupply) {
            require(localSpeedbump != 0, "E:NEG_INT");
            assert(localSpeedbump + _FORTY_EIGHT_HOURS < block.timestamp);
        }
        return (actualWithdraw);
    }

    function hitSpeedbump() external {

        require(speedbump == 0, "E:AlreadySet");
        require(block.timestamp >= unlockTimestamp, "E:Not Expired");
        uint256 totalHoldings = position.balanceOfUnderlying(address(this));
        if (totalHoldings < valueSupplied) {
            emit SpeedBumpHit(block.timestamp);
            speedbump = block.timestamp;
        } else {
            revert("E:NoLoss");
        }
    }

    function withdrawInterest(uint256 _amount, address _destination)
        external
        override
        returns (uint256)
    {

        require(block.timestamp >= unlockTimestamp, "E:Not Expired");
        interestToken.burn(msg.sender, _amount);
        uint256 underlyingValueLocked = position.balanceOfUnderlying(
            address(this)
        );
        (uint256 _valueSupplied, uint256 _interestSupply) = (
            uint256(valueSupplied),
            uint256(interestSupply)
        );
        uint256 interest = underlyingValueLocked > _valueSupplied
            ? underlyingValueLocked - _valueSupplied
            : 0;
        uint256 redemptionAmount = (interest * _amount) / _interestSupply;
        uint256 minRedemption = redemptionAmount -
            (redemptionAmount * _SLIPPAGE_BP) /
            1e18;
        interestSupply = uint128(_interestSupply - _amount);
        (uint256 redemption, ) = position.withdrawUnderlying(
            _destination,
            redemptionAmount,
            minRedemption
        );
        return (redemption);
    }
}// Apache-2.0
pragma solidity ^0.8.0;


interface IInterestTokenFactory {

    function deployInterestToken(
        address tranche,
        string memory strategySymbol,
        uint256 expiration,
        uint8 underlyingDecimals
    ) external returns (InterestToken interestToken);

}// Apache-2.0


pragma solidity ^0.8.0;

contract TrancheFactory {

    event TrancheCreated(
        address indexed trancheAddress,
        address indexed wpAddress,
        uint256 indexed expiration
    );

    IInterestTokenFactory internal immutable _interestTokenFactory;
    address internal _tempWpAddress;
    uint256 internal _tempExpiration;
    IInterestToken internal _tempInterestToken;
    bytes32 public constant TRANCHE_CREATION_HASH = keccak256(
        type(Tranche).creationCode
    );
    address internal immutable _dateLibrary;

    constructor(address _factory, address dateLibrary) {
        _interestTokenFactory = IInterestTokenFactory(_factory);
        _dateLibrary = dateLibrary;
    }

    function deployTranche(uint256 _expiration, address _wpAddress)
        public
        returns (Tranche)
    {

        _tempWpAddress = _wpAddress;
        _tempExpiration = _expiration;

        IWrappedPosition wpContract = IWrappedPosition(_wpAddress);
        bytes32 salt = keccak256(abi.encodePacked(_wpAddress, _expiration));
        string memory wpSymbol = wpContract.symbol();
        IERC20 underlying = wpContract.token();
        uint8 underlyingDecimals = underlying.decimals();

        address predictedAddress = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            address(this),
                            salt,
                            TRANCHE_CREATION_HASH
                        )
                    )
                )
            )
        );

        _tempInterestToken = _interestTokenFactory.deployInterestToken(
            predictedAddress,
            wpSymbol,
            _expiration,
            underlyingDecimals
        );

        Tranche tranche = new Tranche{ salt: salt }();
        emit TrancheCreated(address(tranche), _wpAddress, _expiration);
        require(
            address(tranche) == predictedAddress,
            "CREATE2 address mismatch"
        );

        delete _tempWpAddress;
        delete _tempExpiration;
        delete _tempInterestToken;

        return tranche;
    }

    function getData()
        external
        view
        returns (
            address,
            uint256,
            IInterestToken,
            address
        )
    {

        return (
            _tempWpAddress,
            _tempExpiration,
            _tempInterestToken,
            _dateLibrary
        );
    }
}