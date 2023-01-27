pragma solidity >=0.6.0;

library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}// AGPL-3.0-only
pragma solidity >=0.8.0;

library FixedPointMathLib {


    uint256 internal constant YAD = 1e8;
    uint256 internal constant WAD = 1e18;
    uint256 internal constant RAY = 1e27;
    uint256 internal constant RAD = 1e45;


    function fmul(
        uint256 x,
        uint256 y,
        uint256 baseUnit
    ) internal pure returns (uint256 z) {

        assembly {
            z := mul(x, y)

            if iszero(or(iszero(x), eq(div(z, x), y))) {
                revert(0, 0)
            }

            z := div(z, baseUnit)
        }
    }

    function fdiv(
        uint256 x,
        uint256 y,
        uint256 baseUnit
    ) internal pure returns (uint256 z) {

        assembly {
            z := mul(x, baseUnit)

            if iszero(and(iszero(iszero(y)), or(iszero(x), eq(div(z, x), baseUnit)))) {
                revert(0, 0)
            }

            z := div(z, y)
        }
    }

    function fpow(
        uint256 x,
        uint256 n,
        uint256 baseUnit
    ) internal pure returns (uint256 z) {

        assembly {
            switch x
            case 0 {
                switch n
                case 0 {
                    z := baseUnit
                }
                default {
                    z := 0
                }
            }
            default {
                switch mod(n, 2)
                case 0 {
                    z := baseUnit
                }
                default {
                    z := x
                }

                let half := shr(1, baseUnit)

                for {
                    n := shr(1, n)
                } n {
                    n := shr(1, n)
                } {
                    if shr(128, x) {
                        revert(0, 0)
                    }

                    let xx := mul(x, x)

                    let xxRound := add(xx, half)

                    if lt(xxRound, xx) {
                        revert(0, 0)
                    }

                    x := div(xxRound, baseUnit)

                    if mod(n, 2) {
                        let zx := mul(z, x)

                        if iszero(eq(div(zx, x), z)) {
                            if iszero(iszero(x)) {
                                revert(0, 0)
                            }
                        }

                        let zxRound := add(zx, half)

                        if lt(zxRound, zx) {
                            revert(0, 0)
                        }

                        z := div(zxRound, baseUnit)
                    }
                }
            }
        }
    }


    function sqrt(uint256 x) internal pure returns (uint256 z) {

        assembly {
            z := 1

            let y := x

            if iszero(lt(y, 0x100000000000000000000000000000000)) {
                y := shr(128, y) // Like dividing by 2 ** 128.
                z := shl(64, z)
            }
            if iszero(lt(y, 0x10000000000000000)) {
                y := shr(64, y) // Like dividing by 2 ** 64.
                z := shl(32, z)
            }
            if iszero(lt(y, 0x100000000)) {
                y := shr(32, y) // Like dividing by 2 ** 32.
                z := shl(16, z)
            }
            if iszero(lt(y, 0x10000)) {
                y := shr(16, y) // Like dividing by 2 ** 16.
                z := shl(8, z)
            }
            if iszero(lt(y, 0x100)) {
                y := shr(8, y) // Like dividing by 2 ** 8.
                z := shl(4, z)
            }
            if iszero(lt(y, 0x10)) {
                y := shr(4, y) // Like dividing by 2 ** 4.
                z := shl(2, z)
            }
            if iszero(lt(y, 0x8)) {
                z := shl(1, z)
            }

            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

            let zRoundDown := div(x, z)

            if lt(zRoundDown, z) {
                z := zRoundDown
            }
        }
    }
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

pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

interface IAccessControlUpgradeable {

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

library StringsUpgradeable {

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

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
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
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
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

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// AGPL-3.0-only
pragma solidity >=0.8.0;


library BondPriceLib {


    using FixedPointMathLib for uint256;

    struct QuotePriceInfo {
        uint256 virtualInputReserves; 
        uint256 lastUpdate;
        uint256 halfLife;
        uint256 levelBips;
    }

    function getAmountOut(
        uint256 input,
        uint256 outputReserves,
        uint256 virtualOutputReserves,
        uint256 virtualInputReserves,
        uint256 elapsed,
        uint256 halfLife,
        uint256 levelBips
    ) internal pure returns (uint256 output) {


        output = input.fmul(
            outputReserves + virtualOutputReserves, 
            expToLevel(virtualInputReserves, elapsed, halfLife, levelBips) + input
        );
    }

    function expToLevel(
        uint256 x, 
        uint256 elapsed, 
        uint256 halfLife,
        uint256 levelBips
    ) internal pure returns (uint256 z) {


        z = x >> (elapsed / halfLife);

        z -= z.fmul(elapsed % halfLife, halfLife) >> 1;
        
        z += FixedPointMathLib.fmul(x - z, levelBips, 1e4);
    }
}// AGPL-3.0-only
pragma solidity >=0.8.0;


library AccrualBondLib {


    struct Position {
        uint256 owed;
        uint256 redeemed;
        uint256 creation;
    }

    function getRedeemAmountOut(
        uint256 owed,
        uint256 redeemed,
        uint256 creation,
        uint256 term
    ) internal view returns (uint256) {

        
        uint256 elapsed = block.timestamp - creation;

        if (elapsed > term) elapsed = term;

        return FixedPointMathLib.fmul(owed, elapsed, term) - redeemed;
    }
}// AGPL-3.0-only
pragma solidity >=0.8.0;


contract AccrualBondStorageV1 {

    
    address public beneficiary;
    
    address public outputToken;

    uint256 public totalDebt;
    
    uint256 public virtualOutputReserves;
    
    uint256 public totalAssets;
    
    uint256 public term;
    
    uint256 public cnvEmitted;
    
    uint256 public policyMintAllowance;

    mapping(address => BondPriceLib.QuotePriceInfo) public quoteInfo;
    
    mapping(address => AccrualBondLib.Position[]) public positions;
}// AGPL-3.0-only
pragma solidity >=0.8.0;





interface ICNV {

    function mint(address guy, uint256 wad) external;

    function burn(address guy, uint256 wad) external;

}

contract AccrualBondsV1 is AccrualBondStorageV1, Initializable, AccessControlUpgradeable, PausableUpgradeable {



    bytes32 public constant TREASURY_ROLE           = DEFAULT_ADMIN_ROLE;
    bytes32 public constant STAKING_ROLE            = bytes32(keccak256("STAKING_ROLE"));
    bytes32 public constant POLICY_ROLE             = bytes32(keccak256("POLICY_ROLE"));


    event BondSold(
        address indexed bonder, 
        address indexed token, 
        uint256 input, 
        uint256 output
    );

    event BondRedeemed(
        address indexed bonder, 
        uint256 indexed bondId, 
        uint256 output
    );

    event BondTransfered(
        address indexed sender,
        address indexed recipient,
        uint256 senderBondId,
        uint256 recipientBondId
    );

    event PolicyUpdate(
        address indexed caller, 
        uint256 supplyDelta, 
        bool indexed positiveDelta,
        uint256 newVirtualOutputReserves, 
        address[] tokens, 
        uint256[] virtualInputReserves, 
        uint256[] halfLives, 
        uint256[] levelBips, 
        bool[] updateElapsed
    );

    event InputAssetAdded(
        address indexed caller, 
        address indexed token, 
        uint256 virtualInputReserves, 
        uint256 halfLife, 
        uint256 levelBips
    );

    event InputAssetRemoved(
        address indexed caller,
        address indexed token
    );

    event PolicyMintAllowanceSet(
        address indexed caller, 
        uint256 mintAllowance
    );

    event BeneficiarySet(
        address indexed caller, 
        address beneficiary
    );

    event Vebase(
        uint256 outputTokensEmitted
    );


    function initialize(
        uint256 _term,
        uint256 _virtualOutputReserves,
        address _outputToken,
        address _beneficiary,
        address _treasury,
        address _policy,
        address _staking
    ) external virtual initializer {

        require(term == 0, "INITIALIZED");

        __Context_init();
        __AccessControl_init();
        __Pausable_init();
        __ERC165_init();

        term = _term;
        virtualOutputReserves = _virtualOutputReserves;
        outputToken = _outputToken;
        beneficiary = _beneficiary;

        _grantRole(DEFAULT_ADMIN_ROLE, _treasury);
        _grantRole(POLICY_ROLE, _policy);
        _grantRole(STAKING_ROLE, _staking);

        _pause();
    }




    function _purchaseBond(
        address sender,
        address recipient,
        address token,
        uint256 input,
        uint256 minOutput
    ) internal whenNotPaused() virtual returns (uint256 output) {


        
        BondPriceLib.QuotePriceInfo storage quote = quoteInfo[token];
        
        require(quote.virtualInputReserves != 0,"!LIQUIDITY");
        
        uint256 availableDebt = IERC20Upgradeable(outputToken).balanceOf(address(this)) - totalDebt;
        
        output = BondPriceLib.getAmountOut(
            input,
            availableDebt,
            virtualOutputReserves,
            quote.virtualInputReserves,
            block.timestamp - quote.lastUpdate,
            quote.halfLife,
            quote.levelBips
        );
        
        require(output >= minOutput && availableDebt >= output, "!output");


        TransferHelper.safeTransferFrom(token, sender, beneficiary, input);
        
        unchecked { 
            cnvEmitted += output;

            totalDebt += output;
        }

        quote.virtualInputReserves += input;
        
        positions[recipient].push(AccrualBondLib.Position(output, 0, block.timestamp));
      
        emit BondSold(sender, token, input, output);
    }

    function purchaseBond(
        address recipient,
        address token,
        uint256 input,
        uint256 minOutput
    ) external virtual returns (uint256 output) {

        
        return _purchaseBond(msg.sender, recipient, token, input, minOutput);
    }

    function purchaseBondUsingPermit(
        address recipient,
        address token,
        uint256 input,
        uint256 minOutput,
        uint256 deadline, uint8 v, bytes32 r, bytes32 s
    ) external virtual returns (uint256 output) {

        
        IERC20Permit(token).permit(msg.sender, address(this), input, deadline, v, r, s);

        return _purchaseBond(msg.sender, recipient, token, input, minOutput);
    }


    function redeemBond(
        address recipient,
        uint256 bondId
    ) external whenNotPaused() virtual returns (uint256 output) {



        AccrualBondLib.Position storage position = positions[msg.sender][bondId];
        
        output = AccrualBondLib.getRedeemAmountOut(position.owed, position.redeemed, position.creation, term);
        
        if (output > 0) {

            
            totalDebt -= output;
            
            position.redeemed += output;
            
            TransferHelper.safeTransfer(outputToken, recipient, output);
            
            emit BondRedeemed(msg.sender, bondId, output);
        }

        require(output > 0, "!output");
    }

    function redeemBondBatch(
        address recipient,
        uint256[] memory bondIds
    ) external whenNotPaused() virtual returns (uint256 totalOutput) {


        uint256 length = bondIds.length;

        for (uint256 i; i < length;) {

            AccrualBondLib.Position storage position = positions[msg.sender][bondIds[i]];
            
            uint256 output = AccrualBondLib.getRedeemAmountOut(position.owed, position.redeemed, position.creation, term);
            
            position.redeemed += output;

            totalOutput += output;

            emit BondRedeemed(msg.sender, bondIds[i], output);

            unchecked { i++; }
        }

        totalDebt -= totalOutput;
        
        TransferHelper.safeTransfer(outputToken, recipient, totalOutput);
    }


    function transferBond(
        address recipient,
        uint256 bondId
    ) external whenNotPaused() virtual {


        AccrualBondLib.Position memory position = positions[msg.sender][bondId];

        delete positions[msg.sender][bondId];

        positions[recipient].push(position);

        emit BondTransfered(msg.sender, recipient, bondId, positions[recipient].length);
    }


    function policyUpdate(
        uint256 supplyDelta,
        bool positiveDelta,
        uint256 newVirtualOutputReserves,
        address[] memory tokens,
        uint256[] memory virtualInputReserves,
        uint256[] memory halfLives,
        uint256[] memory levelBips,
        bool[] memory updateElapsed
    ) external virtual onlyRole(POLICY_ROLE) {



        if (supplyDelta > 0) {

            if (positiveDelta) {

                policyMintAllowance -= supplyDelta;


                ICNV(outputToken).mint(address(this), supplyDelta);
            } else {

                require(
                    IERC20Upgradeable(outputToken).balanceOf(address(this)) - totalDebt >= supplyDelta, 
                    "!supplyDelta"
                );

                policyMintAllowance += supplyDelta;


                ICNV(outputToken).burn(address(this), supplyDelta);
            }
        }

        if (newVirtualOutputReserves > 0) virtualOutputReserves = newVirtualOutputReserves;

        uint256 length = tokens.length;

        if (length > 0) {

            require(
                length == virtualInputReserves.length &&
                length == halfLives.length       &&
                length == levelBips.length,
                "!LENGTH"
            );

            for (uint256 i; i < length; ) {

                require(halfLives[i] > 0, "!halfLife");

                quoteInfo[tokens[i]] = BondPriceLib.QuotePriceInfo(
                    virtualInputReserves[i],
                    updateElapsed[i] ? block.timestamp : quoteInfo[tokens[i]].lastUpdate,
                    halfLives[i],
                    levelBips[i]
                );

                unchecked { ++i; }
            }
        }

        emit PolicyUpdate(
            msg.sender, 
            supplyDelta,
            positiveDelta, 
            newVirtualOutputReserves, 
            tokens, 
            virtualInputReserves, 
            halfLives, 
            levelBips, 
            updateElapsed
        );
    }

    function addQuoteAsset(
        address token,
        uint256 virtualInputReserves,
        uint256 halfLife,
        uint256 levelBips
    ) external virtual onlyRole(TREASURY_ROLE) {


        require(quoteInfo[token].lastUpdate == 0, "!EXISTENT");

        unchecked { ++totalAssets; }

        quoteInfo[token] = BondPriceLib.QuotePriceInfo(
            virtualInputReserves,
            block.timestamp,
            halfLife,
            levelBips
        );

        emit InputAssetAdded(msg.sender, token, virtualInputReserves, halfLife, levelBips);
    }

    function removeQuoteAsset(
        address token
    ) external virtual {


        require(hasRole(POLICY_ROLE, msg.sender) || hasRole(TREASURY_ROLE, msg.sender));

        BondPriceLib.QuotePriceInfo memory quote = quoteInfo[token];

        require(quote.lastUpdate != 0, "!NONEXISTENT");

        --totalAssets;

        delete quoteInfo[token];

        emit InputAssetRemoved(msg.sender, token);
    }

    function setPolicyMintAllowance(
        uint256 mintAllowance
    ) external virtual onlyRole(TREASURY_ROLE) {


        policyMintAllowance = mintAllowance;

        emit PolicyMintAllowanceSet(msg.sender, mintAllowance);
    }

    function setBeneficiary(
        address accrualTo
    ) external virtual onlyRole(TREASURY_ROLE) {

        
        beneficiary = accrualTo;
        
        emit BeneficiarySet(msg.sender, accrualTo);
    }

    function pause() external virtual {

        
        require(hasRole(POLICY_ROLE, msg.sender) || hasRole(TREASURY_ROLE, msg.sender));
        
        _pause();
    }

    function unpause() external virtual {


        require(hasRole(POLICY_ROLE, msg.sender) || hasRole(TREASURY_ROLE, msg.sender));
        
        _unpause();
    }


    function vebase() external virtual onlyRole(STAKING_ROLE) returns (bool) {


        emit Vebase(cnvEmitted);

        delete cnvEmitted;

        return true;
    }


    function getVirtualInputReserves(
        address token
    ) external virtual view returns (uint256) {

        BondPriceLib.QuotePriceInfo memory quote = quoteInfo[token];

        return BondPriceLib.expToLevel(
            quote.virtualInputReserves, 
            block.timestamp - quote.lastUpdate, 
            quote.halfLife, 
            quote.levelBips
        );
    }

    function getUserPositionCount(
        address account
    ) external virtual view returns (uint256) {

        return positions[account].length;
    }

    function getAvailableSupply() external virtual view returns (uint256) {

        return IERC20Upgradeable(outputToken).balanceOf(address(this)) - totalDebt;
    }

    function getSpotPrice(
        address token
    ) external virtual view returns (uint256) {


        BondPriceLib.QuotePriceInfo memory quote = quoteInfo[token];

        uint256 virtualInputReserves = BondPriceLib.expToLevel(
            quote.virtualInputReserves, 
            block.timestamp - quote.lastUpdate, 
            quote.halfLife, 
            quote.levelBips
        );

        return FixedPointMathLib.fmul(
            1e18,
            virtualInputReserves,
            IERC20Upgradeable(outputToken).balanceOf(address(this)) - totalDebt + virtualOutputReserves
        );
    }

    function getAmountOut(
        address token,
        uint256 input
    ) external virtual view returns (uint256 output) {


        BondPriceLib.QuotePriceInfo memory quote = quoteInfo[token];

        uint256 availableDebt = IERC20Upgradeable(outputToken).balanceOf(address(this)) - totalDebt;

        output = BondPriceLib.getAmountOut(
            input,
            availableDebt,
            virtualOutputReserves,
            quote.virtualInputReserves,
            block.timestamp - quote.lastUpdate,
            quote.halfLife,
            quote.levelBips
        );
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20Permit {

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

}