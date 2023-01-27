



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
}




pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}




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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity 0.8.4;


interface StakingContractI {

    function stakedBalance(address who, address token) external view returns (uint);

}


pragma solidity 0.8.4;




contract StakedBalanceFetcher is Ownable {


    event StakingContractAdded(address indexed stakingContract);
    event StakingContractRemoved(address indexed stakingContract);

    StakingContractI[] public stakingContracts;

    function addStakingContract(address _stakingContract) external onlyOwner {

        (bool exists,) = getStakingContractIndex(_stakingContract);
        require(!exists, "StakedBalanceFetcher: Staking contract already added");

        stakingContracts.push(StakingContractI(_stakingContract));

        emit StakingContractAdded(_stakingContract);
    }

    function removeStakingContract(address _stakingContract) external onlyOwner {

        (bool exists, uint index) = getStakingContractIndex(_stakingContract);
        require(exists, "StakedBalanceFetcher: Staking contract not added");

        if(index != stakingContracts.length - 1){
            StakingContractI lastItem = stakingContracts[stakingContracts.length - 1];
            stakingContracts.pop();
            stakingContracts[index] = lastItem;
        }else{
            stakingContracts.pop();
        }

        emit StakingContractRemoved(_stakingContract);
    }

    function getStakingContractIndex(address _stakingContract) private view returns (bool found, uint index){

        uint stakingContractsCount = stakingContracts.length;
        for(uint i = 0; i < stakingContractsCount; i++){
            if(address(stakingContracts[i]) == _stakingContract){
                return (true, i);
            }
        }
        return (false, 0);
    }

    function getStakedBalance(address _holder, address token) public view returns(uint) {

        uint stakedAmount = 0;

        uint stakingContractsCount = stakingContracts.length;
        for(uint i = 0; i < stakingContractsCount; i++){
            stakedAmount += stakingContracts[i].stakedBalance(_holder, address(token));
        }

        return stakedAmount;
    }

}


pragma solidity 0.8.4;


contract VestingStorage is Ownable {

    struct VestingCategory{
        uint cliff;
        uint vestingDuration;
    }

    struct Vesting {
        string category;
        uint startingAmount;
    }


    event VestingCategoryAdded(string name);
    event VestingSet(address indexed vester, string categoryName, uint startingAmount);
    event VestingRemoved(address indexed vester, string categoryName, uint startingAmount);


    mapping(string => VestingCategory) private vestingCategoriesByName;
    string[] public vestingCategoryNames;

    mapping(address => Vesting) private vesters;


    modifier onlyVester(address who){

        require(doVestingExist(vesters[who]), "VestingStorage: Only accessible by vesters");
        _;
    }


    function doVestingCategoryExist(VestingCategory storage _category) internal view returns (bool) {

        return _category.vestingDuration > 0;
    }

    function addVestingCategory(string calldata _name, VestingCategory calldata _category) external onlyOwner{

        require(!doVestingCategoryExist(vestingCategoriesByName[_name]), "VestingStorage: Vesting category already exists");
        require(_category.vestingDuration > 0, "VestingStorage: Vesting duration has to be greater than zero");

        vestingCategoryNames.push(_name);
        vestingCategoriesByName[_name] = _category;

        emit VestingCategoryAdded(_name);
    }

    function getVestingCategory(string memory _name) public view returns(VestingCategory memory) {

        VestingCategory storage category = vestingCategoriesByName[_name];
        require(doVestingCategoryExist(category), "VestingStorage: Vesting category does not exist");
        return category;
    }


    function doVestingExist(Vesting storage _vesting) internal view returns (bool) {

        return _vesting.startingAmount > 0;
    }

    function setVestings(address[] calldata _vesters, Vesting[] calldata _vestings) external onlyOwner{

        require(_vesters.length == _vestings.length, "VestingStorage: Vester and vestings amounts don't match up");
        for(uint i = 0; i < _vesters.length; i++){
            address vester = _vesters[i];
            Vesting calldata vesting = _vestings[i];
            require(vesting.startingAmount > 0, "VestingStorage: Vesting should have greater than zero starting amount");
            require(doVestingCategoryExist(vestingCategoriesByName[vesting.category]), "VestingStorage: Vesting category does not exist");

            vesters[vester] = vesting;

            emit VestingSet(vester, vesting.category, vesting.startingAmount);
        }
    }

    function getVesting(address _vester) public view onlyVester(_vester) returns(Vesting memory){

        return vesters[_vester];
    }

    function removeVesting(address[] calldata _vesters) external onlyOwner{

        for(uint i = 0; i < _vesters.length; i++){
            address vester = _vesters[i];
            require(doVestingExist(vesters[vester]), "VestingStorage: Address is not vesting");

            Vesting memory vesting = vesters[vester];
            
            delete vesters[vester];

            emit VestingRemoved(vester, vesting.category, vesting.startingAmount);
        }
    }

}




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
}




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

         {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity 0.8.4;




contract RecoverTokens is Ownable {

    using SafeERC20 for IERC20;

    event TokensRecovered(address indexed token, uint amount);

    function recoverTokens(address _tokenAddress) external onlyOwner {

        IERC20 token = IERC20(_tokenAddress);
        uint balance = token.balanceOf(address(this));
        require(balance != 0, "RecoverTokens: no balance to recover");

        token.safeTransfer(owner(), balance);

        emit TokensRecovered(_tokenAddress, balance);
    }

}


pragma solidity 0.8.4;






contract VestingController is StakedBalanceFetcher, VestingStorage, RecoverTokens {


    event AmountClaimed(address indexed vester, address indexed recipient, uint amount);

    uint immutable public startDate;
    IERC20 immutable public token;

    constructor(uint _vestingStart, address _tokenAddress){
        startDate = _vestingStart;
        token = IERC20(_tokenAddress);
    }

    function claimTo(address _recipient) external onlyVester(msg.sender) {

        uint currentBalance = token.balanceOf(msg.sender);
        require(currentBalance > 0, "VestingController: Not enough balance for claim");

        uint lockedBalance = currentBalance + getStakedBalance(msg.sender, address(token));

        Vesting memory vesting = getVesting(msg.sender);
        uint amountNotVestedYet = vesting.startingAmount - calculateAmountVested(msg.sender);

        require(lockedBalance > amountNotVestedYet, "VestingController: No claimable amount");

        uint claimableAmount = lockedBalance - amountNotVestedYet;
        uint transferableAmount = Math.min(claimableAmount, currentBalance);
        
        require(token.transferFrom(msg.sender, address(this), transferableAmount));
        require(token.transfer(_recipient, transferableAmount));

        emit AmountClaimed(msg.sender, _recipient, transferableAmount);
    }

    function calculateAmountVested(address _vester) public view onlyVester(_vester) returns(uint) {

        Vesting memory vesting = getVesting(_vester);
        VestingCategory memory category = getVestingCategory(vesting.category);

        uint vestingStart = startDate + category.cliff;

        if(block.timestamp <= vestingStart){
            return 0;
        } else {
            uint timePassed = block.timestamp - vestingStart;

            if(timePassed >= category.vestingDuration){
                return vesting.startingAmount;
            } else {
                return (vesting.startingAmount * timePassed) / category.vestingDuration;
            }
        }
    }

}