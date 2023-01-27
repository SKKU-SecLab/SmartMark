pragma solidity ^0.8.0;

library Constants {

    bytes32 internal constant USDC_TICKER = 'usdc';
    bytes32 internal constant USDT_TICKER = 'usdt';
    bytes32 internal constant DAI_TICKER = 'dai';
    bytes32 internal constant CRV_TICKER = 'a3CRV';

    uint256 internal constant CVX_BUSD_PID = 3;
    uint256 internal constant CVX_SUSD_PID = 4;
    uint256 internal constant CVX_USDK_PID = 12;
    uint256 internal constant CVX_USDN_PID = 13;
    uint256 internal constant CVX_MUSD_PID = 14;
    uint256 internal constant CVX_RSV_PID = 15;
    uint256 internal constant CVX_DUSD_PID = 17;
    uint256 internal constant CVX_AAVE_PID = 24;
    uint256 internal constant CVX_USDP_PID = 28;
    uint256 internal constant CVX_IRONBANK_PID = 29;
    uint256 internal constant CVX_TUSD_PID = 31;
    uint256 internal constant CVX_FRAX_PID = 32;
    uint256 internal constant CVX_LUSD_PID = 33;
    uint256 internal constant CVX_BUSDV2_PID = 34;
    uint256 internal constant CVX_MIM_PID = 40;
    uint256 internal constant CVX_OUSD_PID = 56;
    uint256 internal constant TRADE_DEADLINE = 2000;

    address internal constant CVX_ADDRESS = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
    address internal constant CRV_ADDRESS = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    address internal constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address internal constant USDT_ADDRESS = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address internal constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address internal constant TUSD_ADDRESS = 0x0000000000085d4780B73119b644AE5ecd22b376;
    address internal constant SUSD_ADDRESS = 0x57Ab1ec28D129707052df4dF418D58a2D46d5f51;
    address internal constant BUSD_ADDRESS = 0x4Fabb145d64652a948d72533023f6E7A623C7C53;
    address internal constant OUSD_ADDRESS = 0x2A8e1E676Ec238d8A992307B495b45B3fEAa5e86;
    address internal constant MUSD_ADDRESS = 0xe2f2a5C287993345a840Db3B0845fbC70f5935a5;
    address internal constant MIM_ADDRESS = 0x99D8a9C45b2ecA8864373A26D1459e3Dff1e17F3;
    address internal constant DUSD_ADDRESS = 0x5BC25f649fc4e26069dDF4cF4010F9f706c23831;
    address internal constant LUSD_ADDRESS = 0x5f98805A4E8be255a32880FDeC7F6728C6568bA0;
    address internal constant USDP_ADDRESS = 0x1456688345527bE1f37E9e627DA0837D6f08C925;
    address internal constant USDN_ADDRESS = 0x674C6Ad92Fd080e4004b2312b45f796a192D27a0;
    address internal constant USDK_ADDRESS = 0x1c48f86ae57291F7686349F12601910BD8D470bb;
    address internal constant FRAX_ADDRESS = 0x853d955aCEf822Db058eb8505911ED77F175b99e;
    address internal constant RSV_ADDRESS = 0x196f4727526eA7FB1e17b2071B3d8eAA38486988;
    address internal constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address internal constant SUSHI_ROUTER_ADDRESS = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    address internal constant SUSHI_CRV_WETH_ADDRESS = 0x58Dc5a51fE44589BEb22E8CE67720B5BC5378009;
    address internal constant SUSHI_WETH_CVX_ADDRESS = 0x05767d9EF41dC40689678fFca0608878fb3dE906;
    address internal constant SUSHI_WETH_USDT_ADDRESS = 0x06da0fd433C1A5d7a4faa01111c044910A184553;
    address internal constant CVX_BOOSTER_ADDRESS = 0xF403C135812408BFbE8713b5A23a04b3D48AAE31;
    address internal constant CRV_3POOL_ADDRESS = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;
    address internal constant CRV_3POOL_LP_ADDRESS = 0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490;
    address internal constant CRV_AAVE_ADDRESS = 0xDeBF20617708857ebe4F679508E7b7863a8A8EeE;
    address internal constant CRV_AAVE_LP_ADDRESS = 0xFd2a8fA60Abd58Efe3EeE34dd494cD491dC14900;
    address internal constant CVX_AAVE_REWARDS_ADDRESS = 0xE82c1eB4BC6F92f85BF7EB6421ab3b882C3F5a7B;
    address internal constant CRV_IRONBANK_ADDRESS = 0x2dded6Da1BF5DBdF597C45fcFaa3194e53EcfeAF;
    address internal constant CRV_IRONBANK_LP_ADDRESS = 0x5282a4eF67D9C33135340fB3289cc1711c13638C;
    address internal constant CVX_IRONBANK_REWARDS_ADDRESS =
        0x3E03fFF82F77073cc590b656D42FceB12E4910A8;
    address internal constant CRV_TUSD_ADDRESS = 0xEcd5e75AFb02eFa118AF914515D6521aaBd189F1;
    address internal constant CRV_TUSD_LP_ADDRESS = 0xEcd5e75AFb02eFa118AF914515D6521aaBd189F1;
    address internal constant CVX_TUSD_REWARDS_ADDRESS = 0x308b48F037AAa75406426dACFACA864ebd88eDbA;
    address internal constant CRV_SUSD_ADDRESS = 0xA5407eAE9Ba41422680e2e00537571bcC53efBfD;
    address internal constant CRV_SUSD_LP_ADDRESS = 0xC25a3A3b969415c80451098fa907EC722572917F;
    address internal constant CVX_SUSD_REWARDS_ADDRESS = 0x22eE18aca7F3Ee920D01F25dA85840D12d98E8Ca;
    address internal constant CVX_SUSD_EXTRA_ADDRESS = 0x81fCe3E10D12Da6c7266a1A169c4C96813435263;
    address internal constant SUSD_EXTRA_ADDRESS = 0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F;
    address internal constant SUSD_EXTRA_PAIR_ADDRESS = 0xA1d7b2d891e3A1f9ef4bBC5be20630C2FEB1c470;
    address internal constant CRV_USDK_ADDRESS = 0x3E01dD8a5E1fb3481F0F589056b428Fc308AF0Fb;
    address internal constant CRV_USDK_LP_ADDRESS = 0x97E2768e8E73511cA874545DC5Ff8067eB19B787;
    address internal constant CVX_USDK_REWARDS_ADDRESS = 0xa50e9071aCaD20b31cd2bbe4dAa816882De82BBe;
    address internal constant CRV_USDP_ADDRESS = 0x42d7025938bEc20B69cBae5A77421082407f053A;
    address internal constant CRV_USDP_LP_ADDRESS = 0x7Eb40E450b9655f4B3cC4259BCC731c63ff55ae6;
    address internal constant CVX_USDP_REWARDS_ADDRESS = 0x24DfFd1949F888F91A0c8341Fc98a3F280a782a8;
    address internal constant CVX_USDP_EXTRA_ADDRESS = 0x5F91615268bE6b4aDD646b2560785B8F17dccBb4;
    address internal constant USDP_EXTRA_ADDRESS = 0x92E187a03B6CD19CB6AF293ba17F2745Fd2357D5;
    address internal constant USDP_EXTRA_PAIR_ADDRESS = 0x69aa90C6cD099BF383Bd9A0ac29E61BbCbF3b8D9;
    address internal constant CRV_BUSD_ADDRESS = 0x79a8C46DeA5aDa233ABaFFD40F3A0A2B1e5A4F27;
    address internal constant CRV_BUSD_LP_ADDRESS = 0x3B3Ac5386837Dc563660FB6a0937DFAa5924333B;
    address internal constant CVX_BUSD_REWARDS_ADDRESS = 0x602c4cD53a715D8a7cf648540FAb0d3a2d546560;
    address internal constant CRV_BUSDV2_ADDRESS = 0x4807862AA8b2bF68830e4C8dc86D0e9A998e085a;
    address internal constant CRV_BUSDV2_LP_ADDRESS = 0x4807862AA8b2bF68830e4C8dc86D0e9A998e085a;
    address internal constant CVX_BUSDV2_REWARDS_ADDRESS =
        0xbD223812d360C9587921292D0644D18aDb6a2ad0;
    address internal constant CRV_OUSD_ADDRESS = 0x87650D7bbfC3A9F10587d7778206671719d9910D;
    address internal constant CRV_OUSD_LP_ADDRESS = 0x87650D7bbfC3A9F10587d7778206671719d9910D;
    address internal constant CRV_OUSD_EXTRA_ADDRESS = 0x8A05801c1512F6018e450b0F69e9Ca7b985fCea3;
    address internal constant OUSD_EXTRA_ADDRESS = 0x8207c1FfC5B6804F6024322CcF34F29c3541Ae26;
    address internal constant OUSD_EXTRA_PAIR_ADDRESS = 0x72ea6Ca0D47b337f1EA44314d9d90E2A897eDaF5;
    address internal constant CVX_OUSD_REWARDS_ADDRESS = 0x7D536a737C13561e0D2Decf1152a653B4e615158;
    address internal constant CRV_USDN_ADDRESS = 0x0f9cb53Ebe405d49A0bbdBD291A65Ff571bC83e1;
    address internal constant CRV_USDN_LP_ADDRESS = 0x4f3E8F405CF5aFC05D68142F3783bDfE13811522;
    address internal constant CVX_USDN_REWARDS_ADDRESS = 0x4a2631d090e8b40bBDe245e687BF09e5e534A239;
    address internal constant CRV_LUSD_ADDRESS = 0xEd279fDD11cA84bEef15AF5D39BB4d4bEE23F0cA;
    address internal constant CRV_LUSD_LP_ADDRESS = 0xEd279fDD11cA84bEef15AF5D39BB4d4bEE23F0cA;
    address internal constant CVX_LUSD_REWARDS_ADDRESS = 0x2ad92A7aE036a038ff02B96c88de868ddf3f8190;
    address internal constant CVX_LUSD_EXTRA_ADDRESS = 0x0000000000000000000000000000000000000000;
    address internal constant LUSD_EXTRA_ADDRESS = 0x0000000000000000000000000000000000000000;
    address internal constant LUSD_EXTRA_PAIR_ADDRESS = 0x0000000000000000000000000000000000000000;
    address internal constant CRV_MUSD_ADDRESS = 0x8474DdbE98F5aA3179B3B3F5942D724aFcdec9f6;
    address internal constant CRV_MUSD_LP_ADDRESS = 0x1AEf73d49Dedc4b1778d0706583995958Dc862e6;
    address internal constant CVX_MUSD_REWARDS_ADDRESS = 0xDBFa6187C79f4fE4Cda20609E75760C5AaE88e52;
    address internal constant CVX_MUSD_EXTRA_ADDRESS = 0x93A5C724c4992FCBDA6b96F06fa15EB8B5c485b7;
    address internal constant MUSD_EXTRA_ADDRESS = 0xa3BeD4E1c75D00fa6f4E5E6922DB7261B5E9AcD2;
    address internal constant MUSD_EXTRA_PAIR_ADDRESS = 0x663242D053057f317A773D7c262B700616d0b9A0;
    address internal constant CRV_DUSD_ADDRESS = 0x8038C01A0390a8c547446a0b2c18fc9aEFEcc10c;
    address internal constant CRV_DUSD_LP_ADDRESS = 0x3a664Ab939FD8482048609f652f9a0B0677337B9;
    address internal constant CVX_DUSD_REWARDS_ADDRESS = 0x1992b82A8cCFC8f89785129D6403b13925d6226E;
    address internal constant CVX_DUSD_EXTRA_ADDRESS = 0x666F8eEE6FD6839853993977CC86a7A51425673C;
    address internal constant DUSD_EXTRA_ADDRESS = 0x20c36f062a31865bED8a5B1e512D9a1A20AA333A;
    address internal constant DUSD_EXTRA_PAIR_ADDRESS = 0x663242D053057f317A773D7c262B700616d0b9A0;
    address internal constant CRV_RSV_ADDRESS = 0xC18cC39da8b11dA8c3541C598eE022258F9744da;
    address internal constant CRV_RSV_LP_ADDRESS = 0xC2Ee6b0334C261ED60C72f6054450b61B8f18E35;
    address internal constant CVX_RSV_REWARDS_ADDRESS = 0xedfCCF611D7c40F43e77a1340cE2C29EEEC27205;
    address internal constant CVX_RSV_EXTRA_ADDRESS = 0x0000000000000000000000000000000000000000;
    address internal constant RSV_EXTRA_ADDRESS = 0x0000000000000000000000000000000000000000;
    address internal constant RSV_EXTRA_PAIR_ADDRESS = 0x0000000000000000000000000000000000000000;
    address internal constant CRV_FRAX_ADDRESS = 0xd632f22692FaC7611d2AA1C0D552930D43CAEd3B;
    address internal constant CRV_FRAX_LP_ADDRESS = 0xd632f22692FaC7611d2AA1C0D552930D43CAEd3B;
    address internal constant CVX_FRAX_REWARDS_ADDRESS = 0xB900EF131301B307dB5eFcbed9DBb50A3e209B2e;
    address internal constant CVX_FRAX_EXTRA_ADDRESS = 0x0000000000000000000000000000000000000000;
    address internal constant FRAX_EXTRA_ADDRESS = 0x0000000000000000000000000000000000000000;
    address internal constant FRAX_EXTRA_PAIR_ADDRESS = 0x0000000000000000000000000000000000000000;
    address internal constant CRV_MIM_ADDRESS = 0x5a6A4D54456819380173272A5E8E9B9904BdF41B;
    address internal constant CRV_MIM_LP_ADDRESS = 0x5a6A4D54456819380173272A5E8E9B9904BdF41B;
    address internal constant CVX_MIM_REWARDS_ADDRESS = 0xFd5AbF66b003881b88567EB9Ed9c651F14Dc4771;
    address internal constant CVX_MIM_EXTRA_ADDRESS = 0x69a92f1656cd2e193797546cFe2EaF32EACcf6f7;
    address internal constant MIM_EXTRA_ADDRESS = 0x090185f2135308BaD17527004364eBcC2D37e5F6;
    address internal constant MIM_EXTRA_PAIR_ADDRESS = 0xb5De0C3753b6E1B4dBA616Db82767F17513E6d4E;
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.1;

library Address {

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
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
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}//MIT
pragma solidity ^0.8.0;

interface ICurvePoolPricable {

    function get_virtual_price() external view returns (uint256);

}//MIT
pragma solidity ^0.8.0;


interface ICurvePool is ICurvePoolPricable {

    function add_liquidity(uint256[3] memory amounts, uint256 min_mint_amount) external;


    function remove_liquidity(uint256 burn_amount, uint256[3] memory min_amounts) external;


    function remove_liquidity_imbalance( uint256[3] memory amounts, uint256 max_burn_amount) external;


    function remove_liquidity_one_coin(uint256 burn_amount, int128 i, uint256 min_received) external;


    function exchange(
        int128 i,
        int128 j,
        uint256 input,
        uint256 min_output
    ) external;


    function calc_token_amount(uint256[3] memory amounts, bool is_deposit)
        external
        view
        returns (uint256);


    function calc_withdraw_one_coin(uint256 burn_amount, int128 i)
        external
        view
        returns (uint256);

}//MIT
pragma solidity ^0.8.0;


interface ICurvePool2 is ICurvePoolPricable {

    function add_liquidity(uint256[2] memory amounts, uint256 min_mint_amount) external returns(uint256);


    function remove_liquidity(uint256 burn_amount, uint256[2] memory min_amounts) external returns(uint256[2] memory);


    function remove_liquidity_imbalance( uint256[2] memory amounts, uint256 max_burn_amount) external returns(uint256);


    function remove_liquidity_one_coin(uint256 burn_amount, int128 i, uint256 min_received) external returns(uint256);


    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 input,
        uint256 min_output
    ) external;


    function calc_token_amount(uint256[2] memory amounts, bool is_deposit)
    external
    view
    returns (uint256);


    function calc_withdraw_one_coin(uint256 burn_amount, int128 i)
    external
    view
    returns (uint256);

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


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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
}//MIT
pragma solidity ^0.8.0;


interface ICurvePool4 is ICurvePoolPricable {

    function add_liquidity(uint256[4] memory amounts, uint256 min_mint_amount) external;


    function remove_liquidity(uint256 burn_amount, uint256[4] memory min_amounts) external;


    function remove_liquidity_imbalance( uint256[4] memory amounts, uint256 max_burn_amount) external;



    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 input,
        uint256 min_output
    ) external;


    function calc_token_amount(uint256[4] memory amounts, bool is_deposit)
    external
    view
    returns (uint256);


}//MIT
pragma solidity ^0.8.0;

interface IConvexRewards {

    function balanceOf(address account) external view returns (uint256);


    function earned(address account) external view returns (uint256);


    function rewardRate() external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function withdrawAllAndUnwrap(bool claim) external;


    function withdrawAndUnwrap(uint256 amount, bool claim) external;

}//MIT
pragma solidity ^0.8.0;

interface IUniswapRouter {

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);

}//MIT
pragma solidity ^0.8.0;


interface IConvexMinter is IERC20Metadata {

    function totalCliffs() external view returns (uint256);


    function reductionPerCliff() external view returns (uint256);

}//MIT
pragma solidity ^0.8.0;

interface IZunami {

    function totalDeposited() external returns (uint256);


    function deposited(address account) external returns (uint256);


    function totalHoldings() external returns (uint256);


    function calcManagementFee(uint256 amount) external returns (uint256);

}//MIT
pragma solidity ^0.8.0;

interface IConvexBooster {

    function depositAll(uint256 pid, bool stake) external returns (bool);


    function withdrawAll(uint256 pid) external returns (bool);


    function balanceOf(address account) external view returns (uint256);


    function withdraw(uint256 pid, uint256 amount) external returns (bool);

}//MIT
pragma solidity ^0.8.0;




abstract contract CurveConvexStratBase is Ownable {
    using SafeERC20 for IERC20Metadata;
    using SafeERC20 for IConvexMinter;

    enum WithdrawalType { Base, OneCoin }

    struct Config {
        IERC20Metadata[3] tokens;
        IERC20Metadata crv;
        IConvexMinter cvx;
        IUniswapRouter router;
        IConvexBooster booster;
        address[] cvxToUsdtPath;
        address[] crvToUsdtPath;
    }

    Config internal _config;

    IZunami public zunami;

    uint256 public constant UNISWAP_USD_MULTIPLIER = 1e12;
    uint256 public constant CURVE_PRICE_DENOMINATOR = 1e18;
    uint256 public constant DEPOSIT_DENOMINATOR = 10000;
    uint256 public constant ZUNAMI_DAI_TOKEN_ID = 0;
    uint256 public constant ZUNAMI_USDC_TOKEN_ID = 1;
    uint256 public constant ZUNAMI_USDT_TOKEN_ID = 2;

    uint256 public minDepositAmount = 9975; // 99.75%
    address public feeDistributor;

    uint256 public managementFees = 0;

    IERC20Metadata public poolLP;
    IConvexRewards public cvxRewards;
    uint256 public cvxPoolPID;

    uint256[4] public decimalsMultipliers;

    event SoldRewards(uint256 cvxBalance, uint256 crvBalance, uint256 extraBalance);

    modifier onlyZunami() {
        require(_msgSender() == address(zunami), 'must be called by Zunami contract');
        _;
    }

    constructor(
        Config memory config_,
        address poolLPAddr,
        address rewardsAddr,
        uint256 poolPID
    ) {
        _config = config_;

        for (uint256 i; i < 3; i++) {
            decimalsMultipliers[i] = calcTokenDecimalsMultiplier(_config.tokens[i]);
        }

        cvxPoolPID = poolPID;
        poolLP = IERC20Metadata(poolLPAddr);
        cvxRewards = IConvexRewards(rewardsAddr);
        feeDistributor = _msgSender();
    }

    function config() external view returns(Config memory) {
        return _config;
    }

    function deposit(uint256[3] memory amounts) external returns (uint256) {
        if (!checkDepositSuccessful(amounts)) {
            return 0;
        }

        uint256 poolLPs = depositPool(amounts);

        return (poolLPs * getCurvePoolPrice()) / CURVE_PRICE_DENOMINATOR;
    }

   function checkDepositSuccessful(uint256[3] memory amounts) internal view virtual returns (bool);

    function depositPool(uint256[3] memory amounts) internal virtual returns (uint256);

    function getCurvePoolPrice() internal view virtual returns (uint256);

    function withdrawCvx(uint256 removingCrvLps) internal virtual {
        cvxRewards.withdrawAndUnwrap(removingCrvLps, true);
    }

    function snapshotTokensBalances(uint256 userRatioOfCrvLps)
        internal
        view
        returns (uint256[] memory userBalances, uint256[] memory prevBalances)
    {
        userBalances = new uint256[](3);
        prevBalances = new uint256[](3);
        for (uint256 i = 0; i < 3; i++) {
            uint256 managementFee = (i == ZUNAMI_USDT_TOKEN_ID) ? managementFees : 0;
            prevBalances[i] = _config.tokens[i].balanceOf(address(this));
            userBalances[i] = ((prevBalances[i] - managementFee) * userRatioOfCrvLps) / 1e18;
        }
    }

    function transferAllTokensOut(
        address withdrawer,
        uint256[] memory userBalances,
        uint256[] memory prevBalances
    ) internal {
        uint256 transferAmount;
        for (uint256 i = 0; i < 3; i++) {
            transferAmount = _config.tokens[i].balanceOf(address(this)) - prevBalances[i] + userBalances[i];
            if(transferAmount > 0) {
                _config.tokens[i].safeTransfer(
                    withdrawer,
                    transferAmount
                );
            }
        }
    }

    function transferZunamiAllTokens() internal {
        uint256 transferAmount;
        for (uint256 i = 0; i < 3; i++) {
            uint256 managementFee = (i == ZUNAMI_USDT_TOKEN_ID) ? managementFees : 0;
            transferAmount = _config.tokens[i].balanceOf(address(this)) - managementFee;
            if(transferAmount > 0) {
                _config.tokens[i].safeTransfer(
                    _msgSender(),
                    transferAmount
                );
            }
        }
    }

    function calcWithdrawOneCoin(
        uint256 sharesAmount,
        uint128 tokenIndex
    ) external virtual view returns(uint256 tokenAmount);

    function calcSharesAmount(
        uint256[3] memory tokenAmounts,
        bool isDeposit
    ) external virtual view returns(uint256 sharesAmount);

    function withdraw(
        address withdrawer,
        uint256 userRatioOfCrvLps, // multiplied by 1e18
        uint256[3] memory tokenAmounts,
        WithdrawalType withdrawalType,
        uint128 tokenIndex
    ) external virtual onlyZunami returns (bool) {

        require(userRatioOfCrvLps > 0 && userRatioOfCrvLps <= 1e18, "Wrong lp Ratio");
        (
            bool success,
            uint256 removingCrvLps,
            uint[] memory tokenAmountsDynamic
        ) = calcCrvLps(withdrawalType, userRatioOfCrvLps, tokenAmounts, tokenIndex);

        if (!success) {
            return false;
        }

        withdrawCvx(removingCrvLps);

        (
            uint256[] memory userBalances,
            uint256[] memory prevBalances
        ) = snapshotTokensBalances(userRatioOfCrvLps);

        removeCrvLps(removingCrvLps, tokenAmountsDynamic, withdrawalType, tokenAmounts, tokenIndex);

        transferAllTokensOut(withdrawer, userBalances, prevBalances);

        return true;
    }

    function calcCrvLps(
        WithdrawalType withdrawalType,
        uint256 userRatioOfCrvLps, // multiplied by 1e18
        uint256[3] memory tokenAmounts,
        uint128 tokenIndex
    ) internal virtual returns(
        bool success,
        uint256 removingCrvLps,
        uint[] memory tokenAmountsDynamic
    );

    function removeCrvLps(
        uint256 removingCrvLps,
        uint[] memory tokenAmountsDynamic,
        WithdrawalType withdrawalType,
        uint256[3] memory tokenAmounts,
        uint128 tokenIndex
    ) internal virtual;

    function calcTokenDecimalsMultiplier(IERC20Metadata token) internal view returns (uint256) {
        uint8 decimals = token.decimals();
        require(decimals <= 18, 'Zunami: wrong token decimals');
        if (decimals == 18) return 1;
        return 10**(18 - decimals);
    }

    function sellRewards() internal virtual {
        uint256 cvxBalance = _config.cvx.balanceOf(address(this));
        uint256 crvBalance = _config.crv.balanceOf(address(this));
        if (cvxBalance == 0 || crvBalance == 0) {
            return;
        }
        _config.cvx.safeApprove(address(_config.router), cvxBalance);
        _config.crv.safeApprove(address(_config.router), crvBalance);

        uint256 usdtBalanceBefore = _config.tokens[ZUNAMI_USDT_TOKEN_ID].balanceOf(
            address(this)
        );

        _config.router.swapExactTokensForTokens(
            cvxBalance,
            0,
            _config.cvxToUsdtPath,
            address(this),
            block.timestamp + Constants.TRADE_DEADLINE
        );

        _config.router.swapExactTokensForTokens(
            crvBalance,
            0,
            _config.crvToUsdtPath,
            address(this),
            block.timestamp + Constants.TRADE_DEADLINE
        );

        uint256 usdtBalanceAfter = _config.tokens[ZUNAMI_USDT_TOKEN_ID].balanceOf(
            address(this)
        );

        managementFees += zunami.calcManagementFee(usdtBalanceAfter - usdtBalanceBefore);
        emit SoldRewards(cvxBalance, crvBalance, 0);
    }

    function autoCompound() public onlyZunami {
        sellRewards();

        uint256 usdtBalance =  _config.tokens[ZUNAMI_USDT_TOKEN_ID].balanceOf(address(this));

        uint256[3] memory amounts;
        amounts[ZUNAMI_USDT_TOKEN_ID] = usdtBalance;

        if(usdtBalance > 0) depositPool(amounts);
    }

    function totalHoldings() public view virtual returns (uint256) {
        uint256 crvLpHoldings = (cvxRewards.balanceOf(address(this)) * getCurvePoolPrice()) /
            CURVE_PRICE_DENOMINATOR;

        uint256 crvEarned = cvxRewards.earned(address(this));

        uint256 cvxTotalCliffs = _config.cvx.totalCliffs();
        uint256 cvxRemainCliffs = cvxTotalCliffs - _config.cvx.totalSupply() / _config.cvx.reductionPerCliff();

        uint256 amountIn = (crvEarned * cvxRemainCliffs) /
            cvxTotalCliffs +
            _config.cvx.balanceOf(address(this));
        uint256 cvxEarningsUSDT = priceTokenByExchange(amountIn, _config.cvxToUsdtPath);

        amountIn = crvEarned + _config.crv.balanceOf(address(this));
        uint256 crvEarningsUSDT = priceTokenByExchange(amountIn, _config.crvToUsdtPath);

        uint256 tokensHoldings = 0;
        for (uint256 i = 0; i < 3; i++) {
            tokensHoldings +=
                _config.tokens[i].balanceOf(address(this)) *
                decimalsMultipliers[i];
        }

        return
            tokensHoldings +
            crvLpHoldings +
            (cvxEarningsUSDT + crvEarningsUSDT) *
            decimalsMultipliers[ZUNAMI_USDT_TOKEN_ID];
    }

    function priceTokenByExchange(uint256 amountIn, address[] memory exchangePath)
        internal
        view
        returns (uint256)
    {
        if (amountIn == 0) return 0;
        uint256[] memory amounts = _config.router.getAmountsOut(amountIn, exchangePath);
        return amounts[amounts.length - 1];
    }

    function claimManagementFees() public returns (uint256) {
        uint256 usdtBalance = _config.tokens[ZUNAMI_USDT_TOKEN_ID].balanceOf(address(this));
        uint256 transferBalance = managementFees > usdtBalance ? usdtBalance : managementFees;
        if (transferBalance > 0) {
            _config.tokens[ZUNAMI_USDT_TOKEN_ID].safeTransfer(
                feeDistributor,
                transferBalance
            );
        }
        managementFees = 0;

        return transferBalance;
    }

    function updateMinDepositAmount(uint256 _minDepositAmount) public onlyOwner {
        require(_minDepositAmount > 0 && _minDepositAmount <= 10000, 'Wrong amount!');
        minDepositAmount = _minDepositAmount;
    }

    function renounceOwnership() public view override onlyOwner {
        revert('The strategy must have an owner');
    }

    function setZunami(address zunamiAddr) external onlyOwner {
        zunami = IZunami(zunamiAddr);
    }

    function withdrawStuckToken(IERC20Metadata _token) external onlyOwner {
        uint256 tokenBalance = _token.balanceOf(address(this));
        if(tokenBalance > 0) {
            _token.safeTransfer(_msgSender(), tokenBalance);
        }
    }

    function changeFeeDistributor(address _feeDistributor) external onlyOwner {
        feeDistributor = _feeDistributor;
    }

    function toArr2(uint[] memory arrInf) internal pure returns(uint[2] memory arr) {
        arr[0] = arrInf[0];
        arr[1] = arrInf[1];
    }

    function fromArr2(uint[2] memory arr) internal pure returns(uint[] memory arrInf) {
        arrInf = new uint256[](2);
        arrInf[0] = arr[0];
        arrInf[1] = arr[1];
    }

    function toArr3(uint[] memory arrInf) internal pure returns(uint[3] memory arr) {
        arr[0] = arrInf[0];
        arr[1] = arrInf[1];
        arr[2] = arrInf[2];
    }

    function fromArr3(uint[3] memory arr) internal pure returns(uint[] memory arrInf) {
        arrInf = new uint256[](3);
        arrInf[0] = arr[0];
        arrInf[1] = arr[1];
        arrInf[2] = arr[2];
    }

    function toArr4(uint[] memory arrInf) internal pure returns(uint[4] memory arr) {
        arr[0] = arrInf[0];
        arr[1] = arrInf[1];
        arr[2] = arrInf[2];
        arr[3] = arrInf[3];
    }

    function fromArr4(uint[4] memory arr) internal pure returns(uint[] memory arrInf) {
        arrInf = new uint256[](4);
        arrInf[0] = arr[0];
        arrInf[1] = arr[1];
        arrInf[2] = arr[2];
        arrInf[3] = arr[3];
    }
}//MIT
pragma solidity ^0.8.0;



abstract contract CurveConvexExtraStratBase is Context, CurveConvexStratBase {
    using SafeERC20 for IERC20Metadata;

    uint256 public constant ZUNAMI_EXTRA_TOKEN_ID = 3;

    IERC20Metadata public token;
    IERC20Metadata public extraToken;
    IConvexRewards public extraRewards;
    address[] extraTokenSwapPath;

    constructor(
        Config memory config,
        address poolLPAddr,
        address rewardsAddr,
        uint256 poolPID,
        address tokenAddr,
        address extraRewardsAddr,
        address extraTokenAddr
    ) CurveConvexStratBase(config, poolLPAddr, rewardsAddr, poolPID) {
        token = IERC20Metadata(tokenAddr);
        if (extraTokenAddr != address(0)) {
            extraToken = IERC20Metadata(extraTokenAddr);
            extraTokenSwapPath = [extraTokenAddr, Constants.WETH_ADDRESS, Constants.USDT_ADDRESS];
        }
        extraRewards = IConvexRewards(extraRewardsAddr);

        decimalsMultipliers[ZUNAMI_EXTRA_TOKEN_ID] = calcTokenDecimalsMultiplier(token);
    }

    function totalHoldings() public view virtual override returns (uint256) {
        uint256 extraEarningsUSDT = 0;
        if (address(extraToken) != address(0)) {
            uint256 amountIn = extraRewards.earned(address(this)) +
                extraToken.balanceOf(address(this));
            extraEarningsUSDT = priceTokenByExchange(amountIn, extraTokenSwapPath);
        }

        return
            super.totalHoldings() +
            extraEarningsUSDT *
            decimalsMultipliers[ZUNAMI_USDT_TOKEN_ID] +
            token.balanceOf(address(this)) *
            decimalsMultipliers[ZUNAMI_EXTRA_TOKEN_ID];
    }

    function sellRewards() internal override {
        super.sellRewards();
        if (address(extraToken) != address(0)) {
            sellExtraToken();
        }
    }

    function sellExtraToken() public virtual {
        uint256 extraBalance = extraToken.balanceOf(address(this));
        if (extraBalance == 0) {
            return;
        }

        uint256 usdtBalanceBefore = _config.tokens[ZUNAMI_USDT_TOKEN_ID].balanceOf(
            address(this)
        );

        extraToken.safeApprove(address(_config.router), extraToken.balanceOf(address(this)));
        _config.router.swapExactTokensForTokens(
            extraBalance,
            0,
            extraTokenSwapPath,
            address(this),
            block.timestamp + Constants.TRADE_DEADLINE
        );

        managementFees += zunami.calcManagementFee(
            _config.tokens[ZUNAMI_USDT_TOKEN_ID].balanceOf(address(this)) -
                usdtBalanceBefore
        );

        emit SoldRewards(0, 0, extraBalance);
    }

    function withdrawAll() external virtual onlyZunami {
        cvxRewards.withdrawAllAndUnwrap(true);

        sellRewards();

        withdrawAllSpecific();

        transferZunamiAllTokens();
    }

    function withdrawAllSpecific() internal virtual;
}//MIT
pragma solidity ^0.8.0;



contract CurveConvexStrat2 is CurveConvexExtraStratBase {

    using SafeERC20 for IERC20Metadata;

    uint128 public constant CURVE_3POOL_LP_TOKEN_ID = 1;
    int128 public constant CURVE_3POOL_LP_TOKEN_ID_INT = int128(CURVE_3POOL_LP_TOKEN_ID);

    ICurvePool2 public pool;
    ICurvePool public pool3;
    IERC20Metadata public pool3LP;

    constructor(
        Config memory config,
        address poolAddr,
        address poolLPAddr,
        address rewardsAddr,
        uint256 poolPID,
        address tokenAddr,
        address extraRewardsAddr,
        address extraTokenAddr
    )
        CurveConvexExtraStratBase(
            config,
            poolLPAddr,
            rewardsAddr,
            poolPID,
            tokenAddr,
            extraRewardsAddr,
            extraTokenAddr
        )
    {
        pool = ICurvePool2(poolAddr);

        pool3 = ICurvePool(Constants.CRV_3POOL_ADDRESS);
        pool3LP = IERC20Metadata(Constants.CRV_3POOL_LP_ADDRESS);
    }

    function checkDepositSuccessful(uint256[3] memory amounts)
        internal
        view
        override
        returns (bool)
    {

        uint256 amountsTotal;
        for (uint256 i = 0; i < 3; i++) {
            amountsTotal += amounts[i] * decimalsMultipliers[i];
        }
        uint256 amountsMin = (amountsTotal * minDepositAmount) / DEPOSIT_DENOMINATOR;
        uint256 lpPrice = pool3.get_virtual_price();
        uint256 depositedLp = pool3.calc_token_amount(amounts, true);

        return (depositedLp * lpPrice) / CURVE_PRICE_DENOMINATOR >= amountsMin;
    }

    function depositPool(uint256[3] memory amounts) internal override returns (uint256 poolLPs) {

        for (uint256 i = 0; i < 3; i++) {
            _config.tokens[i].safeIncreaseAllowance(address(pool3), amounts[i]);
        }
        pool3.add_liquidity(amounts, 0);

        uint256[2] memory amounts2;
        amounts2[CURVE_3POOL_LP_TOKEN_ID] = pool3LP.balanceOf(address(this));
        pool3LP.safeIncreaseAllowance(address(pool), amounts2[CURVE_3POOL_LP_TOKEN_ID]);
        poolLPs = pool.add_liquidity(amounts2, 0);

        poolLP.safeApprove(address(_config.booster), poolLPs);
        _config.booster.depositAll(cvxPoolPID, true);
    }

    function getCurvePoolPrice() internal view override returns (uint256) {

        return pool.get_virtual_price();
    }

    function calcWithdrawOneCoin(uint256 userRatioOfCrvLps, uint128 tokenIndex)
        external
        view
        override
        returns (uint256 tokenAmount)
    {

        uint256 removingCrvLps = (cvxRewards.balanceOf(address(this)) * userRatioOfCrvLps) / 1e18;
        uint256 pool3Lps = pool.calc_withdraw_one_coin(removingCrvLps, CURVE_3POOL_LP_TOKEN_ID_INT);
        return pool3.calc_withdraw_one_coin(pool3Lps, int128(tokenIndex));
    }

    function calcSharesAmount(uint256[3] memory tokenAmounts, bool isDeposit)
        external
        view
        override
        returns (uint256 sharesAmount)
    {

        uint256[2] memory tokenAmounts2;
        tokenAmounts2[CURVE_3POOL_LP_TOKEN_ID] = pool3.calc_token_amount(tokenAmounts, isDeposit);
        return pool.calc_token_amount(tokenAmounts2, isDeposit);
    }

    function calcCrvLps(
        WithdrawalType withdrawalType,
        uint256 userRatioOfCrvLps, // multiplied by 1e18
        uint256[3] memory tokenAmounts,
        uint128 tokenIndex
    )
        internal
        view
        override
        returns (
            bool success,
            uint256 removingCrvLps,
            uint256[] memory tokenAmountsDynamic
        )
    {

        uint256[2] memory minAmounts2;
        minAmounts2[CURVE_3POOL_LP_TOKEN_ID] = pool3.calc_token_amount(tokenAmounts, false);

        removingCrvLps = (cvxRewards.balanceOf(address(this)) * userRatioOfCrvLps) / 1e18;

        success = removingCrvLps >= pool.calc_token_amount(minAmounts2, false);

        if (success && withdrawalType == WithdrawalType.OneCoin) {
            uint256 pool3Lps = pool.calc_withdraw_one_coin(removingCrvLps, CURVE_3POOL_LP_TOKEN_ID_INT);
            success =
                tokenAmounts[tokenIndex] <=
                pool3.calc_withdraw_one_coin(pool3Lps, int128(tokenIndex));
        }

        tokenAmountsDynamic = new uint256[](2);
    }

    function removeCrvLps(
        uint256 removingCrvLps,
        uint256[] memory tokenAmountsDynamic,
        WithdrawalType withdrawalType,
        uint256[3] memory tokenAmounts,
        uint128 tokenIndex
    ) internal override {

        uint256 prevCrv3Balance = pool3LP.balanceOf(address(this));

        uint256[2] memory minAmounts2;
        pool.remove_liquidity_one_coin(removingCrvLps, CURVE_3POOL_LP_TOKEN_ID_INT, 0);

        uint256 crv3LiqAmount = pool3LP.balanceOf(address(this)) - prevCrv3Balance;
        if (withdrawalType == WithdrawalType.Base) {
            pool3.remove_liquidity(crv3LiqAmount, tokenAmounts);
        } else if (withdrawalType == WithdrawalType.OneCoin) {
            pool3.remove_liquidity_one_coin(
                crv3LiqAmount,
                int128(tokenIndex),
                tokenAmounts[tokenIndex]
            );
        }
    }

    function sellToken() public {

        uint256 sellBal = token.balanceOf(address(this));
        if (sellBal > 0) {
            token.safeApprove(address(pool), sellBal);
            pool.exchange_underlying(0, 3, sellBal, 0);
        }
    }

    function withdrawAllSpecific() internal override {

        uint256[2] memory minAmounts2;
        uint256[3] memory minAmounts;
        pool.remove_liquidity(poolLP.balanceOf(address(this)), minAmounts2);
        sellToken();
        pool3.remove_liquidity(pool3LP.balanceOf(address(this)), minAmounts);
    }
}//MIT
pragma solidity ^0.8.0;


contract USDNCurveConvex is CurveConvexStrat2 {

    constructor(Config memory config)
        CurveConvexStrat2(
            config,
            Constants.CRV_USDN_ADDRESS,
            Constants.CRV_USDN_LP_ADDRESS,
            Constants.CVX_USDN_REWARDS_ADDRESS,
            Constants.CVX_USDN_PID,
            Constants.USDN_ADDRESS,
            address(0),
            address(0)
        )
    {}
}