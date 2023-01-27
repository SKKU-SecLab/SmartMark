pragma solidity >=0.5.0;

interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

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
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
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

interface ISwapRouter {


    function weth() external returns(address);


    function swapExactTokensForTokens(
        address[] memory _path,
        uint _supplyTokenAmount,
        uint _minOutput
    ) external;


    function compound(
        address[] memory _path,
        uint _amount
    ) external;


}// MIT

pragma solidity ^0.8.0;


contract Controller is Ownable, Pausable {


    struct RewardReceiver {
        address receiver;
        uint share;
    }

    IERC20 public rewardToken;
    address public feeConverter;

    RewardReceiver[] public rewardReceivers;
    ISwapRouter public swapRouter;

    uint public feeConversionIncentive;

    constructor(
        RewardReceiver[] memory _rewardReceivers,
        ISwapRouter _swapRouter,
        uint _feeConversionIncentive,
        IERC20 _rewardToken
    ) {
        rewardToken = _rewardToken;
        feeConversionIncentive = _feeConversionIncentive;
        swapRouter = _swapRouter;

        for(uint i = 0; i < _rewardReceivers.length; i++) {
            rewardReceivers.push(_rewardReceivers[i]);
        }
    }

    function setFeeConverter(address _feeConverter) external onlyOwner {

        feeConverter = _feeConverter;
    }

    function getRewardReceivers() external view returns(RewardReceiver[] memory){

        return rewardReceivers;
    }

    function setRewardReceivers(RewardReceiver[] memory _rewardReceivers) onlyOwner external {

        delete rewardReceivers;

        for(uint i = 0; i < _rewardReceivers.length; i++) {
            rewardReceivers.push(_rewardReceivers[i]);
        }
    }

    function setFeeConversionIncentive(uint _value) onlyOwner external {

        feeConversionIncentive = _value;
    }

    function setRewardToken(IERC20 _token) onlyOwner external {

        rewardToken = _token;
    }

    function pause() external onlyOwner {

        _pause();
    }

    function unpause() external onlyOwner {

        _unpause();
    }

}// MIT

pragma solidity ^0.8.0;


contract Controllable {


    Controller public controller;

    constructor(Controller _controller) {
        controller = _controller;
    }

    modifier whenNotPaused() {

        require(!controller.paused(), "Forbidden: System is paused");
        _;
    }

}// MIT

pragma solidity ^0.8.0;

abstract contract Constants {

    uint MAX_INT = 2 ** 256 - 1;

}pragma solidity ^0.8.0;


contract AllowanceChecker is Constants {


    function approveIfNeeded(address _token, address _spender) internal {

        if (IERC20(_token).allowance(address(this), _spender) < MAX_INT) {
            IERC20(_token).approve(_spender, MAX_INT);
        }
    }

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


abstract contract ExternalMulticall {

    struct CallData {
        address target;
        bytes data;
    }

    function multicall(CallData[] calldata data) external payable returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint i = 0; i < data.length; i++) {
            results[i] = Address.functionCall(data[i].target, data[i].data);
        }
        return results;
    }
}// MIT

pragma solidity ^0.8.0;



contract FeeConverter is ExternalMulticall, Controllable, AllowanceChecker {


    event FeeDistribution(
        address recipient,
        uint amount
    );

    constructor(Controller _controller) Controllable(_controller) {}

    receive() external payable {}

    function convertToken(
        address[] memory _path,
        uint _inputAmount,
        uint _minOutput,
        address _incentiveCollector
    ) external whenNotPaused {


        require(_path[_path.length - 1] == address(controller.rewardToken()), "Output token needs to be reward token");

        uint rewardTokenBalanceBeforeConversion = controller.rewardToken().balanceOf(address(this));
        _executeConversion(_path, _inputAmount, _minOutput);
        uint rewardTokenBalanceAfterConversion = controller.rewardToken().balanceOf(address(this));

        _sendIncentiveReward(
            _incentiveCollector,
            rewardTokenBalanceAfterConversion - rewardTokenBalanceBeforeConversion
        );
    }

    function wrapETH() external whenNotPaused {

        uint balance = address(this).balance;
        if (balance > 0) {
            IWETH(controller.swapRouter().weth()).deposit{value : balance}();
        }
    }

    function transferRewardTokenToReceivers() external whenNotPaused {


        Controller.RewardReceiver[] memory receivers = controller.getRewardReceivers();

        uint totalAmount = controller.rewardToken().balanceOf(address(this));
        uint remaining = totalAmount;
        uint nbReceivers = receivers.length;

        if (nbReceivers > 0) {
            for(uint i = 0; i < nbReceivers - 1; i++) {
                uint receiverShare = totalAmount * receivers[i].share / 100e18;
                _sendRewardToken(receivers[i].receiver, receiverShare);

                remaining -= receiverShare;
            }
            _sendRewardToken(receivers[nbReceivers - 1].receiver, remaining);
        }
    }

    function _executeConversion(
        address[] memory _path,
        uint _inputAmount,
        uint _minOutput
    ) internal {

        ISwapRouter router = controller.swapRouter();

        approveIfNeeded(_path[0], address(router));

        controller.swapRouter().swapExactTokensForTokens(
            _path,
            _inputAmount,
            _minOutput
        );
    }

    function _sendIncentiveReward(address _incentiveCollector, uint _totalAmount) internal {

        uint incentiveShare = controller.feeConversionIncentive();
        if (incentiveShare > 0) {
            uint callerIncentive = _totalAmount * incentiveShare / 100e18;
            _sendRewardToken(_incentiveCollector, callerIncentive);
        }
    }

    function _sendRewardToken(
        address _recipient,
        uint _amount
    ) internal {

        controller.rewardToken().transfer(_recipient, _amount);
        emit FeeDistribution(_recipient, _amount);
    }

}