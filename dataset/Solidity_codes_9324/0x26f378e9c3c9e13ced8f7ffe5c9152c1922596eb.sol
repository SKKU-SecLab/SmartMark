
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}//██████╗  █████╗ ██╗      █████╗ ██████╗ ██╗███╗   ██╗
                                                     

pragma solidity ^0.8.0;

interface IPaladinController {

    
    function isPalPool(address pool) external view returns(bool);


}//██████╗  █████╗ ██╗      █████╗ ██████╗ ██╗███╗   ██╗
                                                     

pragma solidity ^0.8.0;
pragma abicoder v2;

interface IPalPool {


    event Deposit(address user, uint amount, address palPool);
    event Withdraw(address user, uint amount, address palPool);
    event NewLoan(
        address borrower,
        address delegatee,
        address underlying,
        uint amount,
        address palPool,
        address loanAddress,
        uint256 palLoanTokenId,
        uint startBlock);
    event ExpandLoan(
        address borrower,
        address delegatee,
        address underlying,
        address palPool,
        uint newFeesAmount,
        address loanAddress,
        uint256 palLoanTokenId
    );
    event ChangeLoanDelegatee(
        address borrower,
        address newDelegatee,
        address underlying,
        address palPool,
        address loanAddress,
        uint256 palLoanTokenId
    );
    event CloseLoan(
        address borrower,
        address delegatee,
        address underlying,
        uint amount,
        address palPool,
        uint usedFees,
        address loanAddress,
        uint256 palLoanTokenId,
        bool wasKilled
    );

    event AddReserve(uint amount);
    event RemoveReserve(uint amount);


    function underlying() external view returns(address);

    function palToken() external view returns(address);


    function deposit(uint _amount) external returns(uint);

    function withdraw(uint _amount) external returns(uint);

    
    function borrow(address _delegatee, uint _amount, uint _feeAmount) external returns(uint);

    function expandBorrow(address _loanPool, uint _feeAmount) external returns(uint);

    function closeBorrow(address _loanPool) external;

    function killBorrow(address _loanPool) external;

    function changeBorrowDelegatee(address _loanPool, address _newDelegatee) external;


    function balanceOf(address _account) external view returns(uint);

    function underlyingBalanceOf(address _account) external view returns(uint);


    function isLoanOwner(address _loanAddress, address _user) external view returns(bool);

    function idOfLoan(address _loanAddress) external view returns(uint256);


    function getLoansPools() external view returns(address [] memory);

    function getLoansByBorrower(address _borrower) external view returns(address [] memory);

    function getBorrowData(address _loanAddress) external view returns(
        address _borrower,
        address _delegatee,
        address _loanPool,
        uint256 _palLoanTokenId,
        uint _amount,
        address _underlying,
        uint _feesAmount,
        uint _feesUsed,
        uint _startBlock,
        uint _closeBlock,
        bool _closed,
        bool _killed
    );


    function borrowRatePerBlock() external view returns (uint);

    function supplyRatePerBlock() external view returns (uint);


    function exchangeRateCurrent() external returns (uint);

    function exchangeRateStored() external view returns (uint);


    function minBorrowFees(uint _amount) external view returns (uint);


    function isKillable(address _loan) external view returns(bool);


    function setNewController(address _newController) external;

    function setNewInterestModule(address _interestModule) external;

    function setNewDelegator(address _delegator) external;


    function updateMinBorrowLength(uint _length) external;

    function updatePoolFactors(uint _reserveFactor, uint _killerRatio) external;


    function addReserve(uint _amount) external;

    function removeReserve(uint _amount, address _recipient) external;


}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}//██████╗  █████╗ ██╗      █████╗ ██████╗ ██╗███╗   ██╗
                                                     

pragma solidity ^0.8.0;


interface IPalLoanToken is IERC721 {



    event NewLoanToken(address palPool, address indexed owner, address indexed palLoan, uint256 indexed tokenId);
    event BurnLoanToken(address palPool, address indexed owner, address indexed palLoan, uint256 indexed tokenId);


    function mint(address to, address palPool, address palLoan) external returns(uint256);

    function burn(uint256 tokenId) external returns(bool);


    function tokenURI(uint256 tokenId) external view returns (string memory);


    function tokenOfByIndex(address owner, uint256 tokenIdex) external view returns (uint256);

    function loanOf(uint256 tokenId) external view returns(address);

    function poolOf(uint256 tokenId) external view returns(address);

    function loansOf(address owner) external view returns(address[] memory);

    function tokensOf(address owner) external view returns(uint256[] memory);

    function loansOfForPool(address owner, address palPool) external view returns(address[] memory);

    function allTokensOf(address owner) external view returns(uint256[] memory);

    function allLoansOf(address owner) external view returns(address[] memory);

    function allLoansOfForPool(address owner, address palPool) external view returns(address[] memory);

    function allOwnerOf(uint256 tokenId) external view returns(address);


    function isBurned(uint256 tokenId) external view returns(bool);


    function setNewController(address _newController) external;

    function setNewBaseURI(string memory _newBaseURI) external;


}// agpl-3.0
pragma solidity ^0.8.0;

interface IStakedAave {

    function stake(address to, uint256 amount) external;

    function balanceOf(address account) external view returns (uint256);

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
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
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

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
}//██████╗  █████╗ ██╗      █████╗ ██████╗ ██╗███╗   ██╗
                                                     
pragma solidity ^0.8.0;




contract PalZap is Ownable, Pausable {

    using SafeERC20 for IERC20;

    mapping(address => bool) private allowedSwapTargets;

    IPaladinController public controller;
    IPalLoanToken public loanToken;

    address private aaveAddress;
    address private stkAaveAddress;

    event ZapDeposit(address sender, address palPool, uint256 palTokenAmount);
    event ZapBorrow(address sender, address palPool, uint256 palLoanTokenId);
    event ZapExpandBorrow(address sender, address palPool, address palLoan, uint256 palLoanTokenId);


    constructor(
        address _controller,
        address _loanToken,
        address _swapTarget,
        address _aaveAddress,
        address _stkAaveAddress
    ) {
        controller = IPaladinController(_controller);
        loanToken = IPalLoanToken(_loanToken);

        allowedSwapTargets[_swapTarget] = true;

        aaveAddress = _aaveAddress;
        stkAaveAddress = _stkAaveAddress;
    }


    function zapDeposit(
        address _fromTokenAddress,
        address _toTokenAddress,
        address _poolAddress,
        uint256 _amount,
        address _swapTarget,
        address _allowanceTarget,
        bytes memory _swapData
    ) external payable whenNotPaused returns(uint){

        require(controller.isPalPool(_poolAddress), "Paladin Zap : Incorrect PalPool");
        IPalPool _pool = IPalPool(_poolAddress);

        require(
            _toTokenAddress!= address(0) && _poolAddress!= address(0) && _swapTarget!= address(0),
            "Paladin Zap : Zero Address"
        );
        require(_amount > 0 || msg.value > 0 , "Paladin Zap : Zero amount");
        require(_toTokenAddress == _pool.underlying(), "Paladin Zap : Incorrect toToken");

        uint _pulledAmount = _pullTokens(_fromTokenAddress, _amount);

        require(allowedSwapTargets[_swapTarget], "Paladin Zap : SwapTarget not allowed");

        uint _receivedAmount = _makeSwap(_fromTokenAddress, _toTokenAddress, _pulledAmount, _swapTarget, _allowanceTarget, _swapData);

        uint _palTokenAmount = _depositInPool(_toTokenAddress, _poolAddress, _receivedAmount);

        address _palTokenAddress = _pool.palToken();
        IERC20(_palTokenAddress).safeTransfer(msg.sender, _palTokenAmount);

        emit ZapDeposit(msg.sender, _poolAddress, _palTokenAmount);

        return _palTokenAmount;
    }

    function zapBorrow(
        address _fromTokenAddress,
        address _toTokenAddress,
        address _poolAddress,
        address _delegatee,
        uint256 _borrowAmount,
        uint256 _feesAmount,
        address _swapTarget,
        address _allowanceTarget,
        bytes memory _swapData
    ) external payable whenNotPaused returns(uint){

        require(controller.isPalPool(_poolAddress), "Paladin Zap : Incorrect PalPool");
        IPalPool _pool = IPalPool(_poolAddress);

        require(
            _toTokenAddress!= address(0) && _poolAddress!= address(0) && _delegatee!= address(0) && _swapTarget!= address(0),
            "Paladin Zap : Zero Address"
        );
        require(_borrowAmount > 0 && (_feesAmount > 0 || msg.value > 0), "Paladin Zap : Zero amount");
        require(_toTokenAddress == _pool.underlying(), "Paladin Zap : Incorrect toToken");

        uint _pulledAmount = _pullTokens(_fromTokenAddress, _feesAmount);

        require(allowedSwapTargets[_swapTarget], "Paladin Zap : SwapTarget not allowed");

        uint _receivedAmount = _makeSwap(_fromTokenAddress, _toTokenAddress, _pulledAmount, _swapTarget, _allowanceTarget, _swapData);

        uint _minBorrowAmount = _pool.minBorrowFees(_borrowAmount);
        require(_receivedAmount >= _minBorrowAmount, "Paladin Zap : Fee amount too low");

        uint _newTokenId = _borrowFromPool(_toTokenAddress, _poolAddress, _delegatee, _borrowAmount, _receivedAmount);

        require(
            loanToken.ownerOf(_newTokenId) == address(this),
            "Paladin Zap : PalPool Borrow failed"
        );

        loanToken.safeTransferFrom(address(this), msg.sender, _newTokenId);

        emit ZapBorrow(msg.sender, _poolAddress, _newTokenId);

        return _newTokenId;
    }


    function zapExpandBorrow(
        address _fromTokenAddress,
        address _toTokenAddress,
        address _loanAddress,
        address _poolAddress,
        uint256 _amount,
        address _swapTarget,
        address _allowanceTarget,
        bytes memory _swapData
    ) external payable whenNotPaused returns(bool){

        require(controller.isPalPool(_poolAddress), "Paladin Zap : Incorrect PalPool");
        IPalPool _pool = IPalPool(_poolAddress);

        require(
            _toTokenAddress!= address(0) && _poolAddress!= address(0) && _loanAddress!= address(0) && _swapTarget!= address(0),
            "Paladin Zap : Zero Address"
        );
        require(_amount > 0 || msg.value > 0 , "Paladin Zap : Zero amount");
        require(_toTokenAddress == _pool.underlying(), "Paladin Zap : Incorrect toToken");

        require(_pool.isLoanOwner(_loanAddress, msg.sender), "Paladin Zap : Not PalLoan owner");

        uint _tokenId = _pool.idOfLoan(_loanAddress);

        require(loanToken.poolOf(_tokenId) == _poolAddress, "Paladin Zap : Incorrect PalPool");

        require(loanToken.isApprovedForAll(msg.sender, address(this)), "Paladin Zap : Not approved for PalLoanToken");

        loanToken.safeTransferFrom(msg.sender, address(this), _tokenId);

        uint _pulledAmount = _pullTokens(_fromTokenAddress, _amount);

        require(allowedSwapTargets[_swapTarget], "Paladin Zap : SwapTarget not allowed");

        uint _receivedAmount = _makeSwap(_fromTokenAddress, _toTokenAddress, _pulledAmount, _swapTarget, _allowanceTarget, _swapData);

        _increaseFees(_toTokenAddress, _loanAddress, _poolAddress, _receivedAmount);

        loanToken.safeTransferFrom(address(this), msg.sender, _tokenId);

        emit ZapExpandBorrow(msg.sender, _poolAddress, _loanAddress, _tokenId);

        return true;
    }





    function _pullTokens(
        address _fromTokenAddress,
        uint256 _amount
    ) internal returns(uint256 _receivedAmount) {

        if(_fromTokenAddress == address(0)){
            require(msg.value > 0 , "Paladin Zap : No ETH received");

            return msg.value;
        }
        
        require(_amount > 0 , "Paladin Zap : Token amount null");
        require(msg.value == 0, "Paladin Zap : Multiple tokens sent");

        IERC20 _fromToken = IERC20(_fromTokenAddress);

        require(_fromToken.allowance(msg.sender, address(this)) >= _amount, "Paladin Zap : Allowance too low");

        _fromToken.safeTransferFrom(msg.sender, address(this), _amount);

        return _amount;
    }


    function _getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {

        if (_returnData.length < 68) return 'Transaction reverted silently';
    
        assembly {
            _returnData := add(_returnData, 0x04)
        }

        return abi.decode(_returnData, (string));
    }

    function _makeSwap(
        address _fromTokenAddress,
        address _toTokenAddress,
        uint256 _amount,
        address _swapTarget,
        address _allowanceTarget,
        bytes memory _swapData
    ) internal returns(uint256 _returnAmount) {

        if(_fromTokenAddress == _toTokenAddress){
            return _amount;
        }

        if(_fromTokenAddress == aaveAddress && _toTokenAddress == stkAaveAddress){
            return _stakeInAave(_amount);
        }

        address _outputTokenAddress = _toTokenAddress;
        if(_toTokenAddress == stkAaveAddress){
            _outputTokenAddress = aaveAddress;
        }

        uint256 _valueSwap;
        if (_fromTokenAddress == address(0)) {
            _valueSwap = _amount;
        } else {
            IERC20(_fromTokenAddress).safeIncreaseAllowance(_allowanceTarget, _amount);
        }

        IERC20 _outputToken = IERC20(_outputTokenAddress);
        uint256 _intitialBalance = _outputToken.balanceOf(address(this));

        (bool _success, bytes memory _res) = _swapTarget.call{ value: _valueSwap }(_swapData);
        require(_success, _getRevertMsg(_res));

        _returnAmount = _outputToken.balanceOf(address(this)) - _intitialBalance;

        if(_toTokenAddress == stkAaveAddress){
            uint256 _stakeAmount = _fromTokenAddress == aaveAddress ? _amount : _returnAmount;
            _returnAmount = _stakeInAave(_stakeAmount);
        }

        require(_returnAmount > 0, "Paladin Zap : Swap output null");
    }


    function _stakeInAave(
        uint256 _amount
    ) internal returns(uint256 _stakedAmount) {

        IStakedAave _stkAave = IStakedAave(stkAaveAddress);

        uint256 _initialBalance = _stkAave.balanceOf(address(this));

        IERC20(aaveAddress).safeApprove(stkAaveAddress, _amount);
        _stkAave.stake(address(this), _amount);

        uint256 _newBalance = _stkAave.balanceOf(address(this));
        _stakedAmount = _newBalance - _initialBalance;

        require(_stakedAmount == _amount, "Paladin Zap : Error staking in Aave");

    }


    function _depositInPool(
        address _tokenAddress,
        address _poolAddress,
        uint256 _amount
    ) internal returns(uint256 _palTokenAmount) {

        IPalPool _pool = IPalPool(_poolAddress);
        IERC20 _palToken = IERC20(_pool.palToken());

        uint256 _initialBalance = _palToken.balanceOf(address(this));

        IERC20(_tokenAddress).safeApprove(_poolAddress, _amount);

        _palTokenAmount = _pool.deposit(_amount);

        uint256 _newBalance = _palToken.balanceOf(address(this));

        require(_newBalance - _initialBalance == _palTokenAmount, "Paladin Zap : Error depositing in PalPool");
        
    }


    function _borrowFromPool(
        address _tokenAddress,
        address _poolAddress,
        address _delegatee,
        uint256 _borrowAmount,
        uint256 _feesAmount
    ) internal returns(uint256 _tokenId) {

        IERC20(_tokenAddress).safeApprove(_poolAddress, _feesAmount);

        _tokenId = IPalPool(_poolAddress).borrow(_delegatee, _borrowAmount, _feesAmount);
    }


    function _increaseFees(
        address _tokenAddress,
        address _loanAddress,
        address _poolAddress,
        uint256 _feesAmount
    ) internal returns(bool) {

        IERC20(_tokenAddress).safeApprove(_poolAddress, _feesAmount);

        uint _paidFees = IPalPool(_poolAddress).expandBorrow(_loanAddress, _feesAmount);

        require(_feesAmount == _paidFees ,"Paladin Zap : Error expanding Borrow");

        return true;
    }



    function sendToken(address _tokenAddress, address payable _recipient) external onlyOwner {

        if(_tokenAddress == address(0)){
            Address.sendValue(_recipient, address(this).balance);
        }
        else{
            IERC20(_tokenAddress).safeTransfer(_recipient, IERC20(_tokenAddress).balanceOf(address(this)));
        }
    }

    function setNewController(address _newController) external onlyOwner {

        controller = IPaladinController(_newController);
    }

    function setNewPalLoanToken(address _newPalLoanToken) external onlyOwner {

        loanToken = IPalLoanToken(_newPalLoanToken);
    }


    function addSwapTarget(address _swapTarget) external onlyOwner {

        allowedSwapTargets[_swapTarget] = true;
    }



    receive() external payable {
        require(msg.sender != tx.origin, "Paladin Zap : Do not send ETH directly");
    }

}