pragma solidity ^0.8.0;

interface IFla {

    function flashLoan(
        address[] memory tokens_,
        uint256[] memory amts_,
        uint256 route,
        bytes calldata data_,
        bytes calldata instaData_
    ) external;

}

interface IVault {

    function getCurrentExchangePrice()
        external
        view
        returns (uint256 exchangePrice_, uint256 newRevenue_);


    function deleverageAndWithdraw(
        uint256 deleverageAmt_,
        uint256 withdrawAmount_,
        address to_
    ) external;


    function token() external view returns (address);


    function decimals() external view returns (uint8);


    function withdrawalFee() external view returns (uint256);

}

interface IAavePriceOracle {

    function getAssetPrice(address _asset) external view returns (uint256);

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
}//MIT
pragma solidity ^0.8.0;


contract ConstantVariables {

    IFla internal constant fla =
        IFla(0x619Ad2D02dBeE6ebA3CDbDA3F98430410e892882);
    address internal constant oneInchAddr =
        0x1111111254fb6c44bAC0beD2854e76F90643097d;
    IERC20 internal constant wethContract =
        IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 internal constant stethContract =
        IERC20(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84);
    address internal constant ethVaultAddr =
        0xc383a3833A87009fD9597F8184979AF5eDFad019;
    IAavePriceOracle internal constant aaveOracle =
        IAavePriceOracle(0xA50ba011c48153De246E5192C8f9258A2ba79Ca9);
}

contract Variables is ConstantVariables {

    uint256 internal status;

    address public auth;

    mapping(address => bool) public isVault;

    uint256 public premium; // premium for token vaults (in BPS)

    uint256 public premiumEth; // premium for eth vault (in BPS)
}pragma solidity ^0.8.0;

contract Events is Variables {

    event updateAuthLog(address auth_);

    event updateVaultLog(address vaultAddr_, bool isVault_);

    event updatePremiumLog(uint256 premium_);

    event updatePremiumEthLog(uint256 premiumEth_);

    event withdrawPremiumLog(
        address[] tokens_,
        uint256[] amounts_,
        address to_
    );
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


contract AdminModule is Events {

    using SafeERC20 for IERC20;

    modifier nonReentrant() {

        require(status != 2, "ReentrancyGuard: reentrant call");
        status = 2;
        _;
        status = 1;
    }

    modifier onlyAuth() {

        require(auth == msg.sender, "only auth");
        _;
    }

    function updateAuth(address auth_) external onlyAuth {

        auth = auth_;
        emit updateAuthLog(auth_);
    }

    function updateVault(address vaultAddr_, bool isVault_) external onlyAuth {

        isVault[vaultAddr_] = isVault_;
        emit updateVaultLog(vaultAddr_, isVault_);
    }

    function updatePremium(uint256 premium_) external onlyAuth {

        premium = premium_;
        emit updatePremiumLog(premium_);
    }

    function updatePremiumEth(uint256 premiumEth_) external onlyAuth {

        premiumEth = premiumEth_;
        emit updatePremiumEthLog(premiumEth_);
    }

    function withdrawPremium(
        address[] memory tokens_,
        uint256[] memory amounts_,
        address to_
    ) external onlyAuth {

        uint256 length_ = tokens_.length;
        require(amounts_.length == length_, "lengths not same");
        for (uint256 i = 0; i < length_; i++) {
            if (amounts_[i] == type(uint256).max)
                amounts_[i] = IERC20(tokens_[i]).balanceOf(address(this));
            IERC20(tokens_[i]).safeTransfer(to_, amounts_[i]);
        }
        emit withdrawPremiumLog(tokens_, amounts_, to_);
    }
}

contract InstaVaultWrapperImplementation is AdminModule {

    using SafeERC20 for IERC20;

    function deleverageAndWithdraw(
        address vaultAddr_,
        uint256 deleverageAmt_,
        uint256 withdrawAmount_,
        address to_,
        uint256 unitAmt_,
        bytes memory swapData_,
        uint256 route_,
        bytes memory instaData_
    ) external nonReentrant {

        require(unitAmt_ != 0, "unitAmt_ cannot be zero");
        require(isVault[vaultAddr_], "invalid vault");
        (uint256 exchangePrice_, ) = IVault(vaultAddr_)
            .getCurrentExchangePrice();
        uint256 itokenAmt_;
        if (withdrawAmount_ == type(uint256).max) {
            itokenAmt_ = IERC20(vaultAddr_).balanceOf(msg.sender);
            withdrawAmount_ = (itokenAmt_ * exchangePrice_) / 1e18;
        } else {
            itokenAmt_ = (withdrawAmount_ * 1e18) / exchangePrice_;
        }
        IERC20(vaultAddr_).safeTransferFrom(
            msg.sender,
            address(this),
            itokenAmt_
        );
        address[] memory wethList_ = new address[](1);
        wethList_[0] = address(wethContract);
        uint256[] memory wethAmtList_ = new uint256[](1);
        wethAmtList_[0] = deleverageAmt_;
        bytes memory data_ = abi.encode(
            vaultAddr_,
            withdrawAmount_,
            to_,
            unitAmt_,
            swapData_
        );
        fla.flashLoan(wethList_, wethAmtList_, route_, data_, instaData_);
    }

    struct InstaVars {
        address vaultAddr;
        uint256 withdrawAmt;
        uint256 withdrawAmtAfterFee;
        address to;
        uint256 unitAmt;
        bytes swapData;
        uint256 withdrawalFee;
        uint256 iniWethBal;
        uint256 iniStethBal;
        uint256 finWethBal;
        uint256 finStethBal;
        uint256 iniEthBal;
        uint256 finEthBal;
        uint256 ethReceived;
        uint256 stethReceived;
        uint256 iniTokenBal;
        uint256 finTokenBal;
        bool success;
        uint256 wethCut;
        uint256 wethAmtReceivedAfterSwap;
        address tokenAddr;
        uint256 tokenDecimals;
        uint256 tokenPriceInBaseCurrency;
        uint256 ethPriceInBaseCurrency;
        uint256 tokenPriceInEth;
        uint256 tokenCut;
    }

    function executeOperation(
        address[] memory tokens_,
        uint256[] memory amounts_,
        uint256[] memory premiums_,
        address initiator_,
        bytes memory params_
    ) external returns (bool) {

        require(msg.sender == address(fla), "illegal-caller");
        require(initiator_ == address(this), "illegal-initiator");
        require(
            tokens_.length == 1 && tokens_[0] == address(wethContract),
            "invalid-params"
        );

        InstaVars memory v_;
        (v_.vaultAddr, v_.withdrawAmt, v_.to, v_.unitAmt, v_.swapData) = abi
            .decode(params_, (address, uint256, address, uint256, bytes));
        IVault vault_ = IVault(v_.vaultAddr);
        v_.withdrawalFee = vault_.withdrawalFee();
        v_.withdrawAmtAfterFee =
            v_.withdrawAmt -
            ((v_.withdrawAmt * v_.withdrawalFee) / 1e4);
        wethContract.safeApprove(v_.vaultAddr, amounts_[0]);
        if (v_.vaultAddr == ethVaultAddr) {
            v_.iniEthBal = address(this).balance;
            v_.iniStethBal = stethContract.balanceOf(address(this));
            vault_.deleverageAndWithdraw(
                amounts_[0],
                v_.withdrawAmt,
                address(this)
            );
            v_.finEthBal = address(this).balance;
            v_.finStethBal = stethContract.balanceOf(address(this));
            v_.ethReceived = v_.finEthBal - v_.iniEthBal;
            v_.stethReceived = v_.finStethBal - amounts_[0] - v_.iniStethBal;
            require(
                v_.ethReceived + v_.stethReceived + 1e9 >=
                    v_.withdrawAmtAfterFee, // Adding small margin for any potential decimal error
                "something-went-wrong"
            );

            v_.iniWethBal = wethContract.balanceOf(address(this));
            stethContract.safeApprove(oneInchAddr, amounts_[0]);
            Address.functionCall(oneInchAddr, v_.swapData, "1Inch-swap-failed");
            v_.finWethBal = wethContract.balanceOf(address(this));
            v_.wethAmtReceivedAfterSwap = v_.finWethBal - v_.iniWethBal;
            require(
                v_.wethAmtReceivedAfterSwap != 0,
                "wethAmtReceivedAfterSwap cannot be zero"
            );
            require(
                v_.wethAmtReceivedAfterSwap >=
                    (amounts_[0] * v_.unitAmt) / 1e18,
                "Too-much-slippage"
            );

            v_.wethCut =
                amounts_[0] +
                premiums_[0] -
                v_.wethAmtReceivedAfterSwap;
            v_.wethCut = v_.wethCut + ((v_.wethCut * premiumEth) / 10000);
            if (v_.wethCut < v_.ethReceived) {
                Address.sendValue(payable(v_.to), v_.ethReceived - v_.wethCut);
                stethContract.safeTransfer(v_.to, v_.stethReceived);
            } else {
                v_.wethCut -= v_.ethReceived;
                stethContract.safeTransfer(
                    v_.to,
                    v_.stethReceived - v_.wethCut
                );
            }
        } else {
            v_.tokenAddr = vault_.token();
            v_.tokenDecimals = vault_.decimals();
            v_.tokenPriceInBaseCurrency = aaveOracle.getAssetPrice(
                v_.tokenAddr
            );
            v_.ethPriceInBaseCurrency = aaveOracle.getAssetPrice(
                address(wethContract)
            );
            v_.tokenPriceInEth =
                (v_.tokenPriceInBaseCurrency * 1e18) /
                v_.ethPriceInBaseCurrency;

            v_.iniTokenBal = IERC20(v_.tokenAddr).balanceOf(address(this));
            v_.iniStethBal = stethContract.balanceOf(address(this));
            vault_.deleverageAndWithdraw(
                amounts_[0],
                v_.withdrawAmt,
                address(this)
            );
            v_.finTokenBal = IERC20(v_.tokenAddr).balanceOf(address(this));
            v_.finStethBal = stethContract.balanceOf(address(this));
            require(
                v_.finTokenBal - v_.iniTokenBal >=
                    ((v_.withdrawAmtAfterFee * 99999999) / 100000000), // Adding small margin for any potential decimal error
                "something-went-wrong"
            );
            require(
                v_.finStethBal - v_.iniStethBal + 1e9 >= amounts_[0], // Adding small margin for any potential decimal error
                "something-went-wrong"
            );

            v_.iniWethBal = wethContract.balanceOf(address(this));
            stethContract.safeApprove(oneInchAddr, amounts_[0]);
            Address.functionCall(oneInchAddr, v_.swapData, "1Inch-swap-failed");
            v_.finWethBal = wethContract.balanceOf(address(this));
            v_.wethAmtReceivedAfterSwap = v_.finWethBal - v_.iniWethBal;
            require(
                v_.wethAmtReceivedAfterSwap != 0,
                "wethAmtReceivedAfterSwap cannot be zero"
            );
            require(
                v_.wethAmtReceivedAfterSwap >=
                    (amounts_[0] * v_.unitAmt) / 1e18,
                "Too-much-slippage"
            );
            v_.wethCut =
                amounts_[0] +
                premiums_[0] -
                v_.wethAmtReceivedAfterSwap;
            v_.wethCut = v_.wethCut + ((v_.wethCut * premium) / 10000);
            v_.tokenCut =
                (v_.tokenPriceInEth * v_.wethCut) /
                (10**(36 - v_.tokenDecimals));
            IERC20(v_.tokenAddr).safeTransfer(
                v_.to,
                v_.withdrawAmtAfterFee - v_.tokenCut
            );
        }
        wethContract.safeTransfer(address(fla), amounts_[0] + premiums_[0]);
        return true;
    }


    receive() external payable {}
}