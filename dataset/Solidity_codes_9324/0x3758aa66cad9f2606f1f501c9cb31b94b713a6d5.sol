

pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}
interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract MultiSigWallet {

    using Address for address;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    modifier isOwner{

        require(owner == msg.sender, "Only owner can execute it");
        _;
    }
    modifier isManager{

        require(managers[msg.sender] == 1, "Only manager can execute it");
        _;
    }
    struct TxWithdraw {
        uint8 e;
        address payable to;
        uint256 amount;
        bool isERC20;
        address ERC20;
        Signature signature;
    }
    struct TxManagerChange {
        uint8 e;
        address[] adds;
        address[] removes;
        Signature signature;
    }
    struct TxUpgrade {
        uint8 e;
        Signature signature;
    }
    struct Signature {
        uint8 signatureCount;
        address[] signed;
        mapping(address => uint8) signatures;
    }
    struct Validator {
        uint8 e;
        mapping(address => uint8) addsMap;
        mapping(address => uint8) removesMap;
    }
    bool public upgrade = false;
    uint public max_managers = 15;
    uint public rate = 66;
    uint constant DENOMINATOR = 100;
    string constant UPDATE_SEED_MANAGERS = "updateSeedManagers";
    uint8 public current_withdraw_min_signatures;
    address public owner;
    mapping(address => uint8) private seedManagers;
    address[] public seedManagerArray;
    mapping(address => uint8) private managers;
    address[] private managerArray;
    mapping(string => TxWithdraw) private pendingTxWithdraws;
    mapping(string => TxManagerChange) private pendingTxManagerChanges;
    mapping(string => TxUpgrade) private pendingTxUpgrade;
    uint public pendingChangeCount = 0;
    mapping(string => uint8) private completedTxs;
    mapping(string => Validator) private validatorManager;

    constructor(address[] memory _managers) public{
        require(_managers.length <= max_managers, "Exceeded the maximum number of managers");
        owner = msg.sender;
        managerArray = _managers;
        for (uint8 i = 0; i < managerArray.length; i++) {
            managers[managerArray[i]] = 1;
            seedManagers[managerArray[i]] = 1;
            seedManagerArray.push(managerArray[i]);
        }
        require(managers[owner] == 0, "Contract creator cannot act as manager");
        current_withdraw_min_signatures = calMinSignatures(managerArray.length);
    }
    function() external payable {
        emit DepositFunds(msg.sender, msg.value);
    }
    function createOrSignWithdraw(string memory txKey, address payable to, uint256 amount, bool isERC20, address ERC20) public isManager {

        require(to != address(0), "Withdraw: transfer to the zero address");
        require(amount > 0, "Withdrawal amount must be greater than 0");
        require(completedTxs[txKey] == 0, "Transaction has been completed");
        if (pendingTxWithdraws[txKey].e != 0) {
            signTx(txKey);
            return;
        }
        if (isERC20) {
            validateTransferERC20(ERC20, to, amount);
        } else {
            require(address(this).balance >= amount, "This contract address does not have sufficient balance of ether");
        }
        TxWithdraw memory tx1;
        pendingTxWithdraws[txKey] = tx1;
        TxWithdraw storage _tx = pendingTxWithdraws[txKey];
        _tx.e = 1;
        _tx.to = to;
        _tx.amount = amount;
        _tx.isERC20 = isERC20;
        _tx.ERC20 = ERC20;
        _tx.signature.signatureCount = 1;
        _tx.signature.signed.push(msg.sender);
        _tx.signature.signatures[msg.sender] = 1;
    }
    function signTx(string memory txKey) internal {

        TxWithdraw storage tx1 = pendingTxWithdraws[txKey];
        bool canWithdraw = isCompleteSign(tx1.signature, current_withdraw_min_signatures, 0);
        if (canWithdraw) {
            address[] memory signers = getSigners(tx1.signature);
            if (tx1.isERC20) {
                transferERC20(tx1.ERC20, tx1.to, tx1.amount);
            } else {
                uint transferAmount = tx1.amount;
                require(address(this).balance >= transferAmount, "This contract address does not have sufficient balance of ether");
                tx1.to.transfer(transferAmount);
                emit TransferFunds(tx1.to, transferAmount);
            }
            emit TxWithdrawCompleted(signers, txKey);
            deletePendingTx(txKey, tx1.e, 1);
        }
    }
    function createOrSignManagerChange(string memory txKey, address[] memory adds, address[] memory removes, uint8 count) public isManager {

        require(adds.length > 0 || removes.length > 0, "There are no managers joining or exiting");
        require(completedTxs[txKey] == 0, "Transaction has been completed");
        if (pendingTxManagerChanges[txKey].e != 0) {
            signTxManagerChange(txKey);
            return;
        }
        preValidateAddsAndRemoves(txKey, adds, removes, false);
        TxManagerChange memory tx1;
        pendingTxManagerChanges[txKey] = tx1;
        TxManagerChange storage _tx = pendingTxManagerChanges[txKey];
        if (count == 0) {
            count = 1;
        }
        _tx.e = count;
        _tx.adds = adds;
        _tx.removes = removes;
        _tx.signature.signed.push(msg.sender);
        _tx.signature.signatures[msg.sender] = 1;
        _tx.signature.signatureCount = 1;
        pendingChangeCount++;
    }
    function signTxManagerChange(string memory txKey) internal {

        TxManagerChange storage tx1 = pendingTxManagerChanges[txKey];
        address[] memory removes = tx1.removes;
        uint removeLengh = removes.length;
        if(removeLengh > 0) {
            for (uint i = 0; i < removeLengh; i++) {
                if (removes[i] == msg.sender) {
                    revert("Exiting manager cannot participate in manager change transactions");
                }
            }
        }
        bool canChange = isCompleteSign(tx1.signature, 0, removeLengh);
        if (canChange) {
            removeManager(tx1.removes, false);
            addManager(tx1.adds, false);
            current_withdraw_min_signatures = calMinSignatures(managerArray.length);
            pendingChangeCount--;
            address[] memory signers = getSigners(tx1.signature);
            emit TxManagerChangeCompleted(signers, txKey);
            deletePendingTx(txKey, tx1.e, 2);
        }
    }
    function createOrSignUpgrade(string memory txKey) public isManager {

        require(completedTxs[txKey] == 0, "Transaction has been completed");
        if (pendingTxUpgrade[txKey].e != 0) {
            signTxUpgrade(txKey);
            return;
        }
        TxUpgrade memory tx1;
        pendingTxUpgrade[txKey] = tx1;
        TxUpgrade storage _tx = pendingTxUpgrade[txKey];
        _tx.e = 1;
        _tx.signature.signed.push(msg.sender);
        _tx.signature.signatures[msg.sender] = 1;
        _tx.signature.signatureCount = 1;
    }
    function signTxUpgrade(string memory txKey) internal {

        TxUpgrade storage tx1 = pendingTxUpgrade[txKey];
        bool canUpgrade= isCompleteSign(tx1.signature, current_withdraw_min_signatures, 0);
        if (canUpgrade) {
            upgrade = true;
            address[] memory signers = getSigners(tx1.signature);
            emit TxUpgradeCompleted(signers, txKey);
            deletePendingTx(txKey, tx1.e, 3);
        }
    }
    function isCompleteSign(Signature storage signature, uint8 min_signatures, uint removeLengh) internal returns (bool){

        bool complete = false;
        signature.signatureCount = calValidSignatureCount(signature);
        if (min_signatures == 0) {
            min_signatures = calMinSignatures(managerArray.length - removeLengh);
        }
        if (signature.signatureCount >= min_signatures) {
            complete = true;
        }
        if (!complete) {
            require(signature.signatures[msg.sender] == 0, "Duplicate signature");
            signature.signed.push(msg.sender);
            signature.signatures[msg.sender] = 1;
            signature.signatureCount++;
            if (signature.signatureCount >= min_signatures) {
                complete = true;
            }
        }
        return complete;
    }
    function calValidSignatureCount(Signature storage signature) internal returns (uint8){

        uint8 count = 0;
        uint len = signature.signed.length;
        for (uint i = 0; i < len; i++) {
            if (managers[signature.signed[i]] > 0) {
                count++;
            } else {
                delete signature.signatures[signature.signed[i]];
            }
        }
        return count;
    }
    function getSigners(Signature storage signature) internal returns (address[] memory){

        address[] memory signers = new address[](signature.signatureCount);
        uint len = managerArray.length;
        uint k = 0;
        for (uint i = 0; i < len; i++) {
            if (signature.signatures[managerArray[i]] > 0) {
                signers[k++] = managerArray[i];
                delete signature.signatures[managerArray[i]];
            }
        }
        return signers;
    }
    function preValidateAddsAndRemoves(string memory txKey, address[] memory adds, address[] memory removes, bool _isOwner) internal {

        Validator memory _validator;
        validatorManager[txKey] = _validator;
        mapping(address => uint8) storage validateAdds = validatorManager[txKey].addsMap;
        uint addLen = adds.length;
        for (uint i = 0; i < addLen; i++) {
            address add = adds[i];
            require(managers[add] == 0, "The address list that is being added already exists as a manager");
            require(validateAdds[add] == 0, "Duplicate parameters for the address to join");
            validateAdds[add] = 1;
        }
        require(validateAdds[owner] == 0, "Contract creator cannot act as manager");
        mapping(address => uint8) storage validateRemoves = validatorManager[txKey].removesMap;
        uint removeLen = removes.length;
        for (uint i = 0; i < removeLen; i++) {
            address remove = removes[i];
            require(_isOwner || seedManagers[remove] == 0, "Can't exit seed manager");
            require(!_isOwner || seedManagers[remove] == 1, "Can only exit the seed manager");
            require(managers[remove] == 1, "There are addresses in the exiting address list that are not manager");
            require(validateRemoves[remove] == 0, "Duplicate parameters for the address to exit");
            validateRemoves[remove] = 1;
        }
        require(validateRemoves[msg.sender] == 0, "Exiting manager cannot participate in manager change transactions");
        require(managerArray.length + addLen - removeLen <= max_managers, "Exceeded the maximum number of managers");
        clearValidatorManager(txKey, adds, removes);
    }
    function clearValidatorManager(string memory txKey, address[] memory adds, address[] memory removes) internal {

        uint addLen = adds.length;
        if(addLen > 0) {
            mapping(address => uint8) storage validateAdds = validatorManager[txKey].addsMap;
            for (uint i = 0; i < addLen; i++) {
                delete validateAdds[adds[i]];
            }
        }
        uint removeLen = removes.length;
        if(removeLen > 0) {
            mapping(address => uint8) storage validateRemoves = validatorManager[txKey].removesMap;
            for (uint i = 0; i < removeLen; i++) {
                delete validateRemoves[removes[i]];
            }
        }
        delete validatorManager[txKey];
    }
    function updateSeedManagers(address[] memory adds, address[] memory removes) public isOwner {

        require(adds.length > 0 || removes.length > 0, "There are no managers joining or exiting");
        preValidateAddsAndRemoves(UPDATE_SEED_MANAGERS, adds, removes, true);
        removeManager(removes, true);
        addManager(adds, true);
        current_withdraw_min_signatures = calMinSignatures(managerArray.length);
        emit TxManagerChangeCompleted(new address[](0), UPDATE_SEED_MANAGERS);
    }
    function updateMaxManagers(uint _max_managers) public isOwner {

        max_managers = _max_managers;
    }
    function calMinSignatures(uint managerCounts) internal view returns (uint8) {

        if (managerCounts == 0) {
            return 0;
        }
        uint numerator = rate * managerCounts + DENOMINATOR - 1;
        return uint8(numerator / DENOMINATOR);
    }
    function removeManager(address[] memory removes, bool _isSeed) internal {

        if (removes.length == 0) {
            return;
        }
        for (uint i = 0; i < removes.length; i++) {
            address remove = removes[i];
            managers[remove] = 0;
            if (_isSeed) {
                seedManagers[remove] = 0;
            }
        }
        uint newLength = managerArray.length - removes.length;
        address[] memory tempManagers = new address[](newLength);
        uint k = 0;
        for (uint i = 0; i < managerArray.length; i++) {
            if (managers[managerArray[i]] == 1) {
                tempManagers[k++] = managerArray[i];
            }
        }
        delete managerArray;
        managerArray = tempManagers;
        if (_isSeed) {
            uint _newLength = seedManagerArray.length - removes.length;
            address[] memory _tempManagers = new address[](_newLength);
            uint t = 0;
            for (uint i = 0; i < seedManagerArray.length; i++) {
                if (seedManagers[seedManagerArray[i]] == 1) {
                    _tempManagers[t++] = seedManagerArray[i];
                }
            }
            delete seedManagerArray;
            seedManagerArray = _tempManagers;
        }
    }
    function addManager(address[] memory adds, bool _isSeed) internal {

        if (adds.length == 0) {
            return;
        }
        for (uint i = 0; i < adds.length; i++) {
            address add = adds[i];
            if(managers[add] == 0) {
                managers[add] = 1;
                managerArray.push(add);
            }
            if (_isSeed && seedManagers[add] == 0) {
                seedManagers[add] = 1;
                seedManagerArray.push(add);
            }
        }
    }
    function deletePendingTx(string memory txKey, uint8 e, uint types) internal {

        completedTxs[txKey] = e;
        if (types == 1) {
            delete pendingTxWithdraws[txKey];
        } else if (types == 3) {
            delete pendingTxUpgrade[txKey];
        }
    }
    function validateTransferERC20(address ERC20, address to, uint256 amount) internal view {

        require(to != address(0), "ERC20: transfer to the zero address");
        require(address(this) != ERC20, "Do nothing by yourself");
        require(ERC20.isContract(), "the address is not a contract address");
        IERC20 token = IERC20(ERC20);
        uint256 balance = token.balanceOf(address(this));
        require(balance >= amount, "No enough balance");
    }
    function transferERC20(address ERC20, address to, uint256 amount) internal {

        IERC20 token = IERC20(ERC20);
        uint256 balance = token.balanceOf(address(this));
        require(balance >= amount, "No enough balance");
        token.safeTransfer(to, amount);
    }
    function upgradeContractS1() public isOwner {

        require(upgrade, "Denied");
        address(uint160(owner)).transfer(address(this).balance);
    }
    function upgradeContractS2(address ERC20, address to, uint256 amount) public isOwner {

        require(upgrade, "Denied");
        validateTransferERC20(ERC20, to, amount);
        transferERC20(ERC20, to, amount);
    }
    function isCompletedTx(string memory txKey) public view returns (bool){

        return completedTxs[txKey] > 0;
    }
    function pendingWithdrawTx(string memory txKey) public view returns (address to, uint256 amount, bool isERC20, address ERC20, uint8 signatureCount) {

        TxWithdraw storage tx1 = pendingTxWithdraws[txKey];
        return (tx1.to, tx1.amount, tx1.isERC20, tx1.ERC20, tx1.signature.signatureCount);
    }
    function pendingManagerChangeTx(string memory txKey) public view returns (uint8 txCount, string memory key, address[] memory adds, address[] memory removes, uint8 signatureCount) {

        TxManagerChange storage tx1 = pendingTxManagerChanges[txKey];
        return (tx1.e, txKey, tx1.adds, tx1.removes, tx1.signature.signatureCount);
    }
    function ifManager(address _manager) public view returns (bool) {

        return managers[_manager] == 1;
    }
    function allManagers() public view returns (address[] memory) {

        return managerArray;
    }
    event DepositFunds(address from, uint amount);
    event TransferFunds( address to, uint amount );
    event TxWithdrawCompleted( address[] signers, string txKey );
    event TxManagerChangeCompleted( address[] signers, string txKey );
    event TxUpgradeCompleted( address[] signers, string txKey );
}