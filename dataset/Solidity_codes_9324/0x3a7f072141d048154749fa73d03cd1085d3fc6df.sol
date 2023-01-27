pragma solidity ^0.8.0;

interface AggregatorV3Interface {


    function decimals()
    external
    view
    returns (
        uint8
    );


    function description()
    external
    view
    returns (
        string memory
    );


    function version()
    external
    view
    returns (
        uint256
    );


    function getRoundData(
        uint80 _roundId
    )
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

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length == 65) {
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else if (signature.length == 64) {
            assembly {
                let vs := mload(add(signature, 0x40))
                r := mload(add(signature, 0x20))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := add(shr(255, vs), 27)
            }
        } else {
            revert("ECDSA: invalid signature length");
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;
    address private _pendingOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function pendingOwner() public view returns (address) {
        return _pendingOwner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyPendingOwner() {
        require(pendingOwner() == _msgSender(), "Ownable: caller is not the pending owner");
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        _pendingOwner = newOwner;
    }

    function claimOwnership() external onlyPendingOwner {
        _owner = _pendingOwner;
        _pendingOwner = address(0);
        emit OwnershipTransferred(_owner, _pendingOwner);
    }
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

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
        uint256 oldAllowance = token.allowance(address(this), spender);
        require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
        uint256 newAllowance = oldAllowance - value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
}

function _callOptionalReturn(IERC20 token, bytes memory data) private {


bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
if (returndata.length > 0) {// Return data is optional
require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
}
}
}// MIT

pragma solidity ^0.8.0;

interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint wad) external;

    function balanceOf(address user) external returns (uint);

}// MIT

pragma solidity ^0.8.0;


contract TokenManager is Ownable {

    event TokenAdded(address indexed _tokenAddress);
    event TokenRemoved(address indexed _tokenAddress);

    struct Token {
        address tokenAddress;
        string name;
        string symbol;
        uint256 decimals;
        address usdPriceContract;
        bool isStable;
    }

    address[] public tokenAddresses;
    mapping(address => Token) public tokens;

    function addToken(
        address _tokenAddress,
        string memory _name,
        string memory _symbol,
        uint256 _decimals,
        address _usdPriceContract,
        bool _isStable
    ) public onlyOwner {

        (bool found,) = indexOfToken(_tokenAddress);
        require(!found, 'Token already added');
        tokens[_tokenAddress] = Token(_tokenAddress, _name, _symbol, _decimals, _usdPriceContract, _isStable);
        tokenAddresses.push(_tokenAddress);
        emit TokenAdded(_tokenAddress);
    }

    function removeToken(
        address _tokenAddress
    ) public onlyOwner {

        (bool found, uint256 index) = indexOfToken(_tokenAddress);
        require(found, 'Erc20 token not found');
        if (tokenAddresses.length > 1) {
            tokenAddresses[index] = tokenAddresses[tokenAddresses.length - 1];
        }
        tokenAddresses.pop();
        delete tokens[_tokenAddress];
        emit TokenRemoved(_tokenAddress);
    }

    function indexOfToken(address _address) public view returns (bool found, uint256 index) {

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            if (tokenAddresses[i] == _address) {
                return (true, i);
            }
        }
        return (false, 0);
    }

    function getListTokenAddresses() public view returns (address[] memory)
    {

        return tokenAddresses;
    }

    function getLengthTokenAddresses() public view returns (uint256)
    {

        return tokenAddresses.length;
    }
}// MIT

pragma solidity ^0.8.0;


contract LaborXContract is Ownable {

    using SafeERC20 for IERC20;
    using ECDSA for bytes32;

    enum State {NULL, CREATED, BLOCKED, PAYED_TO_FREELANCER, RETURNED_FUNDS_TO_CUSTOMER, DISTRIBUTED_FUNDS_BY_ARBITER}

    event ContractCreated(bytes32 indexed contractId, address token, uint256 amount, address disputer, uint256 deadline);
    event ContractBlocked(bytes32 indexed contractId);
    event PayedToFreelancer(bytes32 indexed contractId, uint256 freelancerFee, uint256 freelancerAmount);
    event RefundedToCustomer(bytes32 indexed contractId, uint256 customerPayAmount);
    event DistributedForPartials(bytes32 indexed contractId, uint256 freelancerFee, uint256 customerPayAmount, uint256 freelancerPayAmount);
    event ServiceFeesChanged(uint256 customerFee, uint256 freelancerFee);

    uint256 public constant FEE_PRECISION = 1000;

    bool private initialized;
    uint256 public customerFee = 0;
    uint256 public freelancerFee = 100;
    uint256 public extraDuration = 172800;
    uint256 public precision = 10000000000;
    uint256 public priceOutdateDelay = 14400;
    uint256 public priceOutdateDelayStable = 172800;
    bool public convertAvailable = true;

    address public weth;
    address public tokenManager;
    address public serviceFeesRecipient;
    address public disputer;

    struct Contract {
        bytes32 contractId;
        address customer;
        address freelancer;
        address disputer;
        address token;
        uint256 amount;
        uint256 customerFee;
        uint256 deadline;
        uint256 percentToBaseConvert;
        State state;
    }

    struct ServiceFeeAccum {
        address token;
        uint256 amount;
    }

    mapping(bytes32 => Contract) public contracts;
    mapping(address => uint256) public serviceFeesAccum;

    function init(address _weth, address _tokenManager, address _disputer, address _serviceFeesRecipient) external onlyOwner {

        require(!initialized, "Initialized");
        weth = _weth;
        tokenManager = _tokenManager;
        disputer = _disputer;
        serviceFeesRecipient = _serviceFeesRecipient;
        initialized = true;
    }

    function createContract(
        bytes32 _contractId,
        address _freelancer,
        address _disputer,
        address _token,
        uint256 _amount,
        uint64 _duration,
        uint256 _percentToBaseConvert
    ) external payable {

        require(contracts[_contractId].state == State.NULL, "Contract already exist");
        (bool found,) = TokenManager(tokenManager).indexOfToken(_token);
        require(found, "Only allowed currency");
        require((_percentToBaseConvert >= 0 && _percentToBaseConvert <= 1000), "Percent to base convert goes beyond the limits from 0 to 1000");
        require(_duration > 0, "Duration must be greater than zero");
        uint256 _deadline = _duration + block.timestamp;
        uint256 feeAmount = customerFee * _amount / FEE_PRECISION;
        uint256 amountWithFee = _amount + feeAmount;
        if (_token == weth) {
            require(msg.value == amountWithFee, 'Incorrect passed msg.value');
            IWETH(weth).deposit{value : amountWithFee}();
        } else {
            IERC20(_token).safeTransferFrom(_msgSender(), address(this), amountWithFee);
        }
        Contract storage jobContract = contracts[_contractId];
        jobContract.state = State.CREATED;
        jobContract.customer = _msgSender();
        jobContract.freelancer = _freelancer;
        if (_disputer != address(0)) jobContract.disputer = _disputer;
        jobContract.token = _token;
        jobContract.amount = _amount;
        if (customerFee != 0) jobContract.customerFee = customerFee;
        jobContract.deadline = _deadline;
        if (_percentToBaseConvert != 0) jobContract.percentToBaseConvert = _percentToBaseConvert;
        emit ContractCreated(_contractId, _token, _amount, _disputer, _deadline);
    }

    function blockContract(bytes32 _contractId) external onlyCreatedState(_contractId) {

        require(
            ((contracts[_contractId].disputer == address(0) && _msgSender() == disputer) || _msgSender() == contracts[_contractId].disputer) ||
            _msgSender() == contracts[_contractId].freelancer,
            "Only disputer or freelancer can block contract"
        );
        contracts[_contractId].state = State.BLOCKED;
        emit ContractBlocked(_contractId);
    }

    function payToFreelancer(
        bytes32 _contractId
    ) external onlyCustomer(_contractId) onlyCreatedState(_contractId) {

        uint256 freelancerFeeAmount = freelancerFee * contracts[_contractId].amount / FEE_PRECISION;
        uint256 customerFeeAmount = contracts[_contractId].customerFee * contracts[_contractId].amount / FEE_PRECISION;
        uint256 freelancerAmount = contracts[_contractId].amount - freelancerFeeAmount;
        contracts[_contractId].state = State.PAYED_TO_FREELANCER;
        if (contracts[_contractId].token == weth) {
            IWETH(weth).withdraw(freelancerAmount);
            payable(contracts[_contractId].freelancer).transfer(freelancerAmount);
        } else {
            if (contracts[_contractId].percentToBaseConvert > 0) {
                uint256 freelancerAmountToBase = freelancerAmount * contracts[_contractId].percentToBaseConvert / FEE_PRECISION;
                bool success = _payInBase(contracts[_contractId].freelancer, contracts[_contractId].token, freelancerAmountToBase);
                if (success) {
                    IERC20(contracts[_contractId].token).safeTransfer(contracts[_contractId].freelancer, freelancerAmount - freelancerAmountToBase);
                } else {
                    IERC20(contracts[_contractId].token).safeTransfer(contracts[_contractId].freelancer, freelancerAmount);
                }
            } else {
                IERC20(contracts[_contractId].token).safeTransfer(contracts[_contractId].freelancer, freelancerAmount);
            }
        }
        serviceFeesAccum[contracts[_contractId].token] += freelancerFeeAmount + customerFeeAmount;
        emit PayedToFreelancer(_contractId, freelancerFee, freelancerAmount);
    }

    function refundToCustomerByFreelancer(
        bytes32 _contractId
    ) external onlyFreelancer(_contractId) onlyCreatedState(_contractId) {

        uint256 customerFeeAmount = contracts[_contractId].customerFee * contracts[_contractId].amount / FEE_PRECISION;
        uint256 customerAmount = contracts[_contractId].amount + customerFeeAmount;
        contracts[_contractId].state = State.RETURNED_FUNDS_TO_CUSTOMER;
        if (contracts[_contractId].token == weth) {
            IWETH(weth).withdraw(customerAmount);
            payable(contracts[_contractId].customer).transfer(customerAmount);
        } else {
            IERC20(contracts[_contractId].token).safeTransfer(
                contracts[_contractId].customer,
                customerAmount
            );
        }
        emit RefundedToCustomer(_contractId, customerAmount);
    }

    function refundToCustomerByCustomer(
        bytes32 _contractId
    ) external onlyCustomer(_contractId) onlyCreatedState(_contractId) {

        require(contracts[_contractId].deadline + extraDuration < block.timestamp, "You cannot refund the funds, deadline plus extra hours");
        uint256 customerFeeAmount = contracts[_contractId].customerFee * contracts[_contractId].amount / FEE_PRECISION;
        uint256 customerAmount = contracts[_contractId].amount + customerFeeAmount;
        contracts[_contractId].state = State.RETURNED_FUNDS_TO_CUSTOMER;
        if (contracts[_contractId].token == weth) {
            IWETH(weth).withdraw(customerAmount);
            payable(contracts[_contractId].customer).transfer(customerAmount);
        } else {
            IERC20(contracts[_contractId].token).safeTransfer(
                contracts[_contractId].customer,
                customerAmount
            );
        }
        emit RefundedToCustomer(_contractId, customerAmount);
    }

    function refundToCustomerWithFreelancerSignature(
        bytes32 _contractId,
        bytes memory signature
    ) public onlyCustomer(_contractId) onlyCreatedState(_contractId) {

        address signerAddress = _contractId.toEthSignedMessageHash().recover(signature);
        require(signerAddress == contracts[_contractId].freelancer, "Freelancer signature is incorrect");
        uint256 customerFeeAmount = contracts[_contractId].customerFee * contracts[_contractId].amount / FEE_PRECISION;
        uint256 customerAmount = contracts[_contractId].amount + customerFeeAmount;
        contracts[_contractId].state = State.RETURNED_FUNDS_TO_CUSTOMER;
        if (contracts[_contractId].token == weth) {
            IWETH(weth).withdraw(customerAmount);
            payable(contracts[_contractId].customer).transfer(customerAmount);
        } else {
            IERC20(contracts[_contractId].token).safeTransfer(
                contracts[_contractId].customer,
                customerAmount
            );
        }
        emit RefundedToCustomer(_contractId, customerAmount);
    }

    function distributionForPartials(
        bytes32 _contractId,
        uint256 _customerAmount
    ) external onlyDisputer(_contractId) onlyBlockedState(_contractId) {

        require(contracts[_contractId].amount >= _customerAmount, "High value of the customer amount");
        uint256 customerBeginFee = contracts[_contractId].amount * contracts[_contractId].customerFee / FEE_PRECISION;
        uint256 freelancerAmount = contracts[_contractId].amount - _customerAmount;
        uint256 freelancerFeeAmount = freelancerAmount * freelancerFee / FEE_PRECISION;
        uint256 freelancerPayAmount = freelancerAmount - freelancerFeeAmount;
        uint256 customerFeeAmount = freelancerAmount * precision * customerBeginFee / contracts[_contractId].amount / precision;
        uint256 customerPayAmount = _customerAmount + (customerBeginFee - customerFeeAmount);
        contracts[_contractId].state = State.DISTRIBUTED_FUNDS_BY_ARBITER;
        if (contracts[_contractId].token == weth) {
            IWETH(weth).withdraw(customerPayAmount + freelancerPayAmount);
            if (customerPayAmount != 0) {
                payable(contracts[_contractId].customer).transfer(customerPayAmount);
            }
            if (freelancerPayAmount != 0) {
                payable(contracts[_contractId].freelancer).transfer(freelancerPayAmount);
            }
        } else {
            if (customerPayAmount != 0) {
                IERC20(contracts[_contractId].token).safeTransfer(contracts[_contractId].customer, customerPayAmount);
            }
            if (freelancerPayAmount != 0) {
                IERC20(contracts[_contractId].token).safeTransfer(contracts[_contractId].freelancer, freelancerPayAmount);
            }
        }
        serviceFeesAccum[contracts[_contractId].token] += customerFeeAmount + freelancerFeeAmount;
        emit DistributedForPartials(_contractId, freelancerFee, customerPayAmount, freelancerPayAmount);
    }

    function withdrawServiceFee(address token) external onlyServiceFeesRecipient {

        require(serviceFeesRecipient != address(0), "Not specified service fee address");
        require(serviceFeesAccum[token] > 0, "You have no accumulated commissions");
        uint256 amount = serviceFeesAccum[token];
        serviceFeesAccum[token] = 0;
        if (token == weth) {
            IWETH(weth).withdraw(amount);
            payable(serviceFeesRecipient).transfer(amount);
        } else {
            IERC20(token).safeTransfer(serviceFeesRecipient, amount);
        }
    }

    function withdrawServiceFees() external onlyServiceFeesRecipient {

        address[] memory addresses = TokenManager(tokenManager).getListTokenAddresses();
        for (uint256 i = 0; i < addresses.length; i++) {
            if (serviceFeesAccum[addresses[i]] > 0) {
                uint256 amount = serviceFeesAccum[addresses[i]];
                serviceFeesAccum[addresses[i]] = 0;
                if (addresses[i] == weth) {
                    IWETH(weth).withdraw(amount);
                    payable(serviceFeesRecipient).transfer(amount);
                } else {
                    IERC20(addresses[i]).safeTransfer(serviceFeesRecipient, amount);
                }
            }
        }
    }

    function checkAbilityConvertToBase(address fromToken, uint256 amount) public view returns (bool success, uint256 amountInBase) {

        if (!convertAvailable) return (false, 0);
        if (address(0) == weth) return (false, 1);
        if (fromToken == weth) return (false, 2);
        (bool found,) = TokenManager(tokenManager).indexOfToken(weth);
        if (!found) return (false, 3);
        (,,,,address priceContractToUSD, bool isStable) = TokenManager(tokenManager).tokens(fromToken);
        if (priceContractToUSD == address(0)) return (false, 4);
        (,int256 answerToUSD,,uint256 updatedAtToUSD,) = AggregatorV3Interface(priceContractToUSD).latestRoundData();
        if ((updatedAtToUSD + (isStable ? priceOutdateDelayStable : priceOutdateDelay )) < block.timestamp) return (false, 5);
        if (answerToUSD <= 0) return (false, 6);
        (,,,,address priceContractToBase,) = TokenManager(tokenManager).tokens(weth);
        (,int256 answerToBase,,uint256 updatedAtToBase,) = AggregatorV3Interface(priceContractToBase).latestRoundData();
        if ((updatedAtToBase + priceOutdateDelay) < block.timestamp) return (false, 7);
        if (answerToBase <= 0) return (false, 8);
        uint256 amountInUSD = amount * uint(answerToUSD) / (10 ** AggregatorV3Interface(priceContractToUSD).decimals());
        amountInBase = amountInUSD * (10 ** 18) / uint(answerToBase);
        if (amountInBase > serviceFeesAccum[weth]) return (false, 9);
        return (true, amountInBase);
    }

    function addToServiceFeeAccumBase() external payable onlyServiceFeesRecipient {

        IWETH(weth).deposit{value : msg.value}();
        serviceFeesAccum[weth] += msg.value;
    }

    function setPrecision(uint256 _precision) external onlyOwner {

        precision = _precision;
    }

    function setServiceFeesRecipient(address _address) external onlyOwner {

        serviceFeesRecipient = _address;
    }

    function setDisputer(address _address) external onlyOwner {

        disputer = _address;
    }

    function setTokenManager(address _address) external onlyOwner {

        tokenManager = _address;
    }

    function setServiceFees(uint256 _customerFee, uint256 _freelancerFee) external onlyOwner {

        customerFee = _customerFee;
        freelancerFee = _freelancerFee;
        emit ServiceFeesChanged(customerFee, freelancerFee);
    }

    function setExtraDuration(uint256 _extraDuration) external onlyOwner {

        extraDuration = _extraDuration;
    }

    function setPriceOutdateDelay(uint256 _priceOutdateDelay, uint256 _priceOutdateDelayStable) external onlyOwner {

        priceOutdateDelay = _priceOutdateDelay;
        priceOutdateDelayStable = _priceOutdateDelayStable;
    }

    function setConvertAvailable(bool _convertAvailable) external onlyOwner {

        convertAvailable = _convertAvailable;
    }

    function _payInBase(address to, address fromToken, uint256 amount) internal returns (bool) {

        (bool success, uint256 amountInBase) = checkAbilityConvertToBase(fromToken, amount);
        if (!success) return false;
        IWETH(weth).withdraw(amountInBase);
        payable(to).transfer(amountInBase);
        serviceFeesAccum[weth] -= amountInBase;
        serviceFeesAccum[fromToken] += amount;
        return true;
    }

    receive() external payable {
        assert(msg.sender == weth);
    }

    function getAccumulatedFees() public view returns (ServiceFeeAccum[] memory _fees) {

        uint256 length = TokenManager(tokenManager).getLengthTokenAddresses();
        ServiceFeeAccum[] memory fees = new ServiceFeeAccum[](length);
        for (uint256 i = 0; i < length; i++) {
            address token = TokenManager(tokenManager).tokenAddresses(i);
            fees[i].token = token;
            fees[i].amount = serviceFeesAccum[token];
        }
        return fees;
    }

    function getServiceFees() public view returns (uint256 _customerFee, uint256 _freelancerFee) {

        _customerFee = customerFee;
        _freelancerFee = freelancerFee;
    }

    modifier onlyCreatedState (bytes32 _contractId) {

        require(contracts[_contractId].state == State.CREATED, "Contract allowed only created state");
        _;
    }

    modifier onlyBlockedState (bytes32 _contractId) {

        require(contracts[_contractId].state == State.BLOCKED, "Contract allowed only blocked state");
        _;
    }

    modifier onlyServiceFeesRecipient () {

        require(_msgSender() == serviceFeesRecipient, "Only service fees recipient can call this function");
        _;
    }

    modifier onlyFreelancer (bytes32 _contractId) {

        require(_msgSender() == contracts[_contractId].freelancer, "Only freelancer can call this function");
        _;
    }

    modifier onlyCustomer (bytes32 _contractId) {

        require(_msgSender() == contracts[_contractId].customer, "Only customer can call this function");
        _;
    }

    modifier onlyTxSender (bytes32 _contractId) {

        require(msg.sender == tx.origin, "Only tx sender can call this function");
        _;
    }

    modifier onlyDisputer (bytes32 _contractId) {

        require((contracts[_contractId].disputer == address(0) && _msgSender() == disputer) || _msgSender() == contracts[_contractId].disputer, "Only disputer can call this function");
        _;
    }
}