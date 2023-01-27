


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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


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
}


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

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{ value: amount }("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

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

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) =
            target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {

        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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

library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata =
            address(token).functionCall(
                data,
                "SafeERC20: low-level call failed"
            );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}






pragma solidity ^0.8.0;

interface ICurveAddressProvider {

    function get_registry() external view returns (address);


    function get_address(uint256 _id) external view returns (address);

}

interface ICurveRegistry {

    function get_pool_from_lp_token(address lpToken)
        external
        view
        returns (address);


    function get_lp_token(address swapAddress) external view returns (address);


    function get_n_coins(address _pool)
        external
        view
        returns (uint256[2] memory);


    function get_coins(address _pool) external view returns (address[8] memory);


    function get_underlying_coins(address _pool)
        external
        view
        returns (address[8] memory);

}

interface ICurveCryptoRegistry {

    function get_pool_from_lp_token(address lpToken)
        external
        view
        returns (address);


    function get_lp_token(address swapAddress) external view returns (address);


    function get_n_coins(address _pool) external view returns (uint256);


    function get_coins(address _pool) external view returns (address[8] memory);

}

interface ICurveFactoryRegistry {

    function get_n_coins(address _pool) external view returns (uint256);


    function get_coins(address _pool) external view returns (address[2] memory);


    function get_underlying_coins(address _pool)
        external
        view
        returns (address[8] memory);

}

interface ICurveV2Pool {

    function price_oracle(uint256 k) external view returns (uint256);

}

contract Curve_Registry_V3 is Ownable {

    using SafeERC20 for IERC20;

    ICurveAddressProvider internal constant CurveAddressProvider =
        ICurveAddressProvider(0x0000000022D53366457F9d5E68Ec105046FC4383);

    ICurveRegistry public CurveRegistry;
    ICurveFactoryRegistry public FactoryRegistry;
    ICurveCryptoRegistry public CurveCryptoRegistry;

    address internal constant wbtcToken =
        0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address internal constant sbtcCrvToken =
        0x075b1bb99792c9E1041bA13afEf80C91a1e70fB3;
    address internal constant ETHAddress =
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    mapping(address => bool) public shouldAddUnderlying;
    mapping(address => address) private depositAddresses;

    constructor() {
        CurveRegistry = ICurveRegistry(CurveAddressProvider.get_registry());
        FactoryRegistry = ICurveFactoryRegistry(
            CurveAddressProvider.get_address(3)
        );
        CurveCryptoRegistry = ICurveCryptoRegistry(
            CurveAddressProvider.get_address(5)
        );

        depositAddresses[
            0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51
        ] = 0xbBC81d23Ea2c3ec7e56D39296F0cbB648873a5d3;
        depositAddresses[
            0xA2B47E3D5c44877cca798226B7B8118F9BFb7A56
        ] = 0xeB21209ae4C2c9FF2a86ACA31E123764A3B6Bc06;
        depositAddresses[
            0x52EA46506B9CC5Ef470C5bf89f17Dc28bB35D85C
        ] = 0xac795D2c97e60DF6a99ff1c814727302fD747a80;
        depositAddresses[
            0x06364f10B501e868329afBc005b3492902d6C763
        ] = 0xA50cCc70b6a011CffDdf45057E39679379187287;
        depositAddresses[
            0x79a8C46DeA5aDa233ABaFFD40F3A0A2B1e5A4F27
        ] = 0xb6c057591E073249F2D9D88Ba59a46CFC9B59EdB;
        depositAddresses[
            0xA5407eAE9Ba41422680e2e00537571bcC53efBfD
        ] = 0xFCBa3E75865d2d561BE8D220616520c171F12851;

        shouldAddUnderlying[0xDeBF20617708857ebe4F679508E7b7863a8A8EeE] = true;
        shouldAddUnderlying[0xEB16Ae0052ed37f479f7fe63849198Df1765a733] = true;
        shouldAddUnderlying[0x2dded6Da1BF5DBdF597C45fcFaa3194e53EcfeAF] = true;
    }

    function isCurvePool(address swapAddress) public view returns (bool) {

        if (CurveRegistry.get_lp_token(swapAddress) != address(0)) {
            return true;
        }
        return false;
    }

    function isFactoryPool(address swapAddress) public view returns (bool) {

        if (FactoryRegistry.get_coins(swapAddress)[0] != address(0)) {
            return true;
        }
        return false;
    }

    function isCryptoPool(address swapAddress) public view returns (bool) {

        if (CurveCryptoRegistry.get_lp_token(swapAddress) != address(0)) {
            return true;
        }
        return false;
    }

    function isMetaPool(address swapAddress) public view returns (bool) {

        if (isCurvePool(swapAddress)) {
            uint256[2] memory poolTokenCounts =
                CurveRegistry.get_n_coins(swapAddress);

            if (poolTokenCounts[0] == poolTokenCounts[1]) return false;
            else return true;
        }
        if (isCryptoPool(swapAddress)) {
            uint256 poolTokensCount =
                CurveCryptoRegistry.get_n_coins(swapAddress);
            address[8] memory poolTokens =
                CurveCryptoRegistry.get_coins(swapAddress);

            for (uint256 i = 0; i < poolTokensCount; i++) {
                if (isCurvePool(poolTokens[i])) return true;
            }
        }
        if (isFactoryPool(swapAddress)) return true;
        return false;
    }

    function _isCurveFactoryMetaPool(address swapAddress)
        internal
        view
        returns (uint256)
    {

        if (isCurvePool(swapAddress)) {
            uint256[2] memory poolTokenCounts =
                CurveRegistry.get_n_coins(swapAddress);

            if (poolTokenCounts[0] == poolTokenCounts[1]) return 0;
            else return 1;
        }
        if (isFactoryPool(swapAddress)) return 2;
        return 0;
    }

    function isV2Pool(address swapAddress) public view returns (bool) {

        try ICurveV2Pool(swapAddress).price_oracle(0) {
            return true;
        } catch {
            return false;
        }
    }

    function getDepositAddress(address swapAddress)
        external
        view
        returns (address depositAddress)
    {

        depositAddress = depositAddresses[swapAddress];
        if (depositAddress == address(0)) return swapAddress;
    }

    function getSwapAddress(address tokenAddress)
        external
        view
        returns (address swapAddress)
    {

        swapAddress = CurveRegistry.get_pool_from_lp_token(tokenAddress);
        if (swapAddress != address(0)) {
            return swapAddress;
        }
        swapAddress = CurveCryptoRegistry.get_pool_from_lp_token(tokenAddress);
        if (swapAddress != address(0)) {
            return swapAddress;
        }
        if (isFactoryPool(tokenAddress)) {
            return tokenAddress;
        }
        return address(0);
    }

    function getTokenAddress(address swapAddress)
        external
        view
        returns (address tokenAddress)
    {

        tokenAddress = CurveRegistry.get_lp_token(swapAddress);
        if (tokenAddress != address(0)) {
            return tokenAddress;
        }
        tokenAddress = CurveCryptoRegistry.get_lp_token(swapAddress);
        if (tokenAddress != address(0)) {
            return tokenAddress;
        }
        if (isFactoryPool(swapAddress)) {
            return swapAddress;
        }
        return address(0);
    }

    function getNumTokens(address swapAddress) public view returns (uint256) {

        if (isCurvePool(swapAddress)) {
            return CurveRegistry.get_n_coins(swapAddress)[0];
        } else if (isCryptoPool(swapAddress)) {
            return CurveCryptoRegistry.get_n_coins(swapAddress);
        } else {
            return FactoryRegistry.get_n_coins(swapAddress);
        }
    }

    function getPoolTokens(address swapAddress)
        public
        view
        returns (address[4] memory poolTokens)
    {

        uint256 isCurveFactoryMetaPool = _isCurveFactoryMetaPool(swapAddress);
        if (isCurveFactoryMetaPool == 1) {
            address[8] memory poolUnderlyingCoins =
                CurveRegistry.get_coins(swapAddress);
            for (uint256 i = 0; i < 2; i++) {
                poolTokens[i] = poolUnderlyingCoins[i];
            }
        } else if (isCurveFactoryMetaPool == 2) {
            address[2] memory poolUnderlyingCoins =
                FactoryRegistry.get_coins(swapAddress);
            for (uint256 i = 0; i < 2; i++) {
                poolTokens[i] = poolUnderlyingCoins[i];
            }
        } else if (isCryptoPool(swapAddress)) {
            address[8] memory poolUnderlyingCoins =
                CurveCryptoRegistry.get_coins(swapAddress);

            for (uint256 i = 0; i < 4; i++) {
                poolTokens[i] = poolUnderlyingCoins[i];
            }
        } else {
            address[8] memory poolUnderlyingCoins;
            if (isBtcPool(swapAddress)) {
                poolUnderlyingCoins = CurveRegistry.get_coins(swapAddress);
            } else {
                poolUnderlyingCoins = CurveRegistry.get_underlying_coins(
                    swapAddress
                );
            }
            for (uint256 i = 0; i < 4; i++) {
                poolTokens[i] = poolUnderlyingCoins[i];
            }
        }
    }

    function isBtcPool(address swapAddress) public view returns (bool) {

        address[8] memory poolTokens = CurveRegistry.get_coins(swapAddress);
        for (uint256 i = 0; i < 4; i++) {
            if (poolTokens[i] == wbtcToken || poolTokens[i] == sbtcCrvToken)
                return true;
        }
        return false;
    }

    function isEthPool(address swapAddress) external view returns (bool) {

        address[8] memory poolTokens = CurveRegistry.get_coins(swapAddress);
        for (uint256 i = 0; i < 4; i++) {
            if (poolTokens[i] == ETHAddress) {
                return true;
            }
        }
        return false;
    }

    function isUnderlyingToken(address swapAddress, address toToken)
        external
        view
        returns (bool, uint256)
    {

        address[4] memory poolTokens = getPoolTokens(swapAddress);
        for (uint256 i = 0; i < 4; i++) {
            if (poolTokens[i] == address(0)) return (false, 0);
            if (poolTokens[i] == toToken) return (true, i);
        }
        return (false, 0);
    }

    function update_curve_registry() external onlyOwner {

        address new_address = CurveAddressProvider.get_registry();

        require(address(CurveRegistry) != new_address, "Already updated");

        CurveRegistry = ICurveRegistry(new_address);
    }

    function update_factory_registry() external onlyOwner {

        address new_address = CurveAddressProvider.get_address(3);

        require(address(FactoryRegistry) != new_address, "Already updated");

        FactoryRegistry = ICurveFactoryRegistry(new_address);
    }

    function update_crypto_registry() external onlyOwner {

        address new_address = CurveAddressProvider.get_address(5);

        require(address(CurveCryptoRegistry) != new_address, "Already updated");

        CurveCryptoRegistry = ICurveCryptoRegistry(new_address);
    }

    function updateShouldAddUnderlying(
        address[] calldata swapAddresses,
        bool[] calldata addUnderlying
    ) external onlyOwner {

        require(
            swapAddresses.length == addUnderlying.length,
            "Mismatched arrays"
        );
        for (uint256 i = 0; i < swapAddresses.length; i++) {
            shouldAddUnderlying[swapAddresses[i]] = addUnderlying[i];
        }
    }

    function updateDepositAddresses(
        address[] calldata swapAddresses,
        address[] calldata _depositAddresses
    ) external onlyOwner {

        require(
            swapAddresses.length == _depositAddresses.length,
            "Mismatched arrays"
        );
        for (uint256 i = 0; i < swapAddresses.length; i++) {
            depositAddresses[swapAddresses[i]] = _depositAddresses[i];
        }
    }

    function withdrawTokens(address[] calldata tokens) external onlyOwner {

        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 qty;

            if (tokens[i] == ETHAddress) {
                qty = address(this).balance;
                Address.sendValue(payable(owner()), qty);
            } else {
                qty = IERC20(tokens[i]).balanceOf(address(this));
                IERC20(tokens[i]).safeTransfer(owner(), qty);
            }
        }
    }
}