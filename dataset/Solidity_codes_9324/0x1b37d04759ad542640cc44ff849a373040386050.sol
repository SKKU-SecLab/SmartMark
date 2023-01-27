

pragma solidity 0.8.9;

interface FundDistribution {

    function sendReward(address _fundAddress) external returns (bool);

}



pragma solidity 0.8.9;

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





pragma solidity 0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}





pragma solidity 0.8.9;



abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _transferOwnership(_msgSender());
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



pragma solidity 0.8.9;

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





pragma solidity 0.8.9;

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

        (bool success, ) = recipient.call{value: amount}("");
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

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
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





pragma solidity 0.8.9;





abstract contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory tokenName, string memory tokenSymbol) {
        _name = tokenName;
        _symbol = tokenSymbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        virtual
        override
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}



pragma solidity 0.8.9;



contract MeedsToken is ERC20("Meeds Token", "MEED"), Ownable {

    function mint(address _to, uint256 _amount) public onlyOwner {

        _mint(_to, _amount);
    }
}



pragma solidity 0.8.9;






library SafeERC20 {

    using SafeMath for uint256;
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

        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
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

        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(
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



pragma solidity 0.8.9;







contract TokenFactory is Ownable, FundDistribution {


    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    struct UserInfo {
        uint256 amount; // How many LP tokens the user has staked
        uint256 rewardDebt; // How much MEED rewards the user had received
    }

    struct FundInfo {
        uint256 fixedPercentage; // How many fixed percentage of minted MEEDs will be sent to this fund contract
        uint256 allocationPoint; // How many allocation points assigned to this pool comparing to other pools
        uint256 lastRewardTime; // Last block timestamp that MEEDs distribution has occurred
        uint256 accMeedPerShare; // Accumulated MEEDs per share: price of LP Token comparing to 1 MEED (multiplied by 10^12 to make the computation more precise)
        bool isLPToken; // // The Liquidity Pool rewarding distribution will be handled by this contract
    }

    uint256 public constant MAX_MEED_SUPPLY = 1e26;

    uint256 public constant MEED_REWARDING_PRECISION = 1e12;

    MeedsToken public meed;

    uint256 public meedPerMinute;

    address[] public fundAddresses;

    mapping(address => FundInfo) public fundInfos;

    mapping(address => mapping(address => UserInfo)) public userLpInfos;

    uint256 public totalAllocationPoints = 0;
    uint256 public totalFixedPercentage = 0;

    uint256 public startRewardsTime;

    event Deposit(address indexed user, address indexed lpAddress, uint256 amount);
    event Withdraw(address indexed user, address indexed lpAddress, uint256 amount);
    event EmergencyWithdraw(address indexed user, address indexed lpAddress, uint256 amount);
    event Harvest(address indexed user, address indexed lpAddress, uint256 amount);

    event FundAdded(address indexed fundAddress, uint256 allocation, bool fixedPercentage, bool isLPToken);
    event FundAllocationChanged(address indexed fundAddress, uint256 allocation, bool fixedPercentage);

    event MaxSupplyReached(uint256 timestamp);

    constructor (
        MeedsToken _meed,
        uint256 _meedPerMinute,
        uint256 _startRewardsTime
    ) {
        meed = _meed;
        meedPerMinute = _meedPerMinute;
        startRewardsTime = _startRewardsTime;
    }

    function setMeedPerMinute(uint256 _meedPerMinute) external onlyOwner {

        require(_meedPerMinute > 0, "TokenFactory#setMeedPerMinute: _meedPerMinute must be strictly positive integer");
        meedPerMinute = _meedPerMinute;
    }

    function addLPToken(IERC20 _lpToken, uint256 _value, bool _isFixedPercentage) external onlyOwner {

        require(address(_lpToken).isContract(), "TokenFactory#addLPToken: _fundAddress must be an ERC20 Token Address");
        _addFund(address(_lpToken), _value, _isFixedPercentage, true);
    }

    function addFund(address _fundAddress, uint256 _value, bool _isFixedPercentage) external onlyOwner {

        _addFund(_fundAddress, _value, _isFixedPercentage, false);
    }

    function updateAllocation(address _fundAddress, uint256 _value, bool _isFixedPercentage) external onlyOwner {

        FundInfo storage fund = fundInfos[_fundAddress];
        require(fund.lastRewardTime > 0, "TokenFactory#updateAllocation: _fundAddress isn't a recognized LPToken nor a fund address");

        sendReward(_fundAddress);

        if (_isFixedPercentage) {
            require(fund.accMeedPerShare == 0, "TokenFactory#setFundAllocation Error: can't change fund percentage from variable to fixed");
            totalFixedPercentage = totalFixedPercentage.sub(fund.fixedPercentage).add(_value);
            require(totalFixedPercentage <= 100, "TokenFactory#setFundAllocation: total percentage can't be greater than 100%");
            fund.fixedPercentage = _value;
            totalAllocationPoints = totalAllocationPoints.sub(fund.allocationPoint);
            fund.allocationPoint = 0;
        } else {
            require(!fund.isLPToken || fund.fixedPercentage == 0, "TokenFactory#setFundAllocation Error: can't change Liquidity Pool percentage from fixed to variable");
            totalAllocationPoints = totalAllocationPoints.sub(fund.allocationPoint).add(_value);
            fund.allocationPoint = _value;
            totalFixedPercentage = totalFixedPercentage.sub(fund.fixedPercentage);
            fund.fixedPercentage = 0;
        }
        emit FundAllocationChanged(_fundAddress, _value, _isFixedPercentage);
    }

    function sendAllRewards() external {

        uint256 length = fundAddresses.length;
        for (uint256 index = 0; index < length; index++) {
            sendReward(fundAddresses[index]);
        }
    }

    function batchSendRewards(address[] memory _fundAddresses) external {

        uint256 length = _fundAddresses.length;
        for (uint256 index = 0; index < length; index++) {
            sendReward(fundAddresses[index]);
        }
    }

    function sendReward(address _fundAddress) public override returns (bool) {

        if (block.timestamp < startRewardsTime) {
            return true;
        }

        FundInfo storage fund = fundInfos[_fundAddress];
        require(fund.lastRewardTime > 0, "TokenFactory#sendReward: _fundAddress isn't a recognized LPToken nor a fund address");

        uint256 pendingRewardAmount = _pendingRewardBalanceOf(fund);
        if (fund.isLPToken) {
          fund.accMeedPerShare = _getAccMeedPerShare(_fundAddress, pendingRewardAmount);
          _mint(address(this), pendingRewardAmount);
        } else {
          _mint(_fundAddress, pendingRewardAmount);
        }
        fund.lastRewardTime = block.timestamp;
        return true;
    }

    function deposit(IERC20 _lpToken, uint256 _amount) public {

        address _lpAddress = address(_lpToken);
        FundInfo storage fund = fundInfos[_lpAddress];
        require(fund.isLPToken, "TokenFactory#deposit Error: Liquidity Pool doesn't exist");

        sendReward(_lpAddress);

        UserInfo storage user = userLpInfos[_lpAddress][msg.sender];
        if (user.amount > 0) {
            uint256 pending = user
                .amount
                .mul(fund.accMeedPerShare).div(MEED_REWARDING_PRECISION)
                .sub(user.rewardDebt);
            _safeMeedTransfer(msg.sender, pending);
        }
        IERC20(_lpAddress).safeTransferFrom(address(msg.sender), address(this), _amount);
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(fund.accMeedPerShare).div(MEED_REWARDING_PRECISION);
        emit Deposit(msg.sender, _lpAddress, _amount);
    }

    function withdraw(IERC20 _lpToken, uint256 _amount) public {

        address _lpAddress = address(_lpToken);
        FundInfo storage fund = fundInfos[_lpAddress];
        require(fund.isLPToken, "TokenFactory#withdraw Error: Liquidity Pool doesn't exist");

        sendReward(_lpAddress);

        UserInfo storage user = userLpInfos[_lpAddress][msg.sender];
        uint256 pendingUserReward = user.amount.mul(fund.accMeedPerShare).div(1e12).sub(
            user.rewardDebt
        );
        _safeMeedTransfer(msg.sender, pendingUserReward);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(fund.accMeedPerShare).div(1e12);

        if (_amount > 0) {
          IERC20(_lpAddress).safeTransfer(address(msg.sender), _amount);
          emit Withdraw(msg.sender, _lpAddress, _amount);
        } else {
          emit Harvest(msg.sender, _lpAddress, pendingUserReward);
        }
    }

    function emergencyWithdraw(IERC20 _lpToken) public {

        address _lpAddress = address(_lpToken);
        FundInfo storage fund = fundInfos[_lpAddress];
        require(fund.isLPToken, "TokenFactory#emergencyWithdraw Error: Liquidity Pool doesn't exist");

        UserInfo storage user = userLpInfos[_lpAddress][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;

        IERC20(_lpAddress).safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _lpAddress, amount);
    }

    function harvest(IERC20 _lpAddress) public {

        withdraw(_lpAddress, 0);
    }

    function fundsLength() public view returns (uint256) {

        return fundAddresses.length;
    }

    function pendingRewardBalanceOf(IERC20 _lpToken, address _user) public view returns (uint256) {

        address _lpAddress = address(_lpToken);
        if (block.timestamp < startRewardsTime) {
            return 0;
        }
        FundInfo storage fund = fundInfos[_lpAddress];
        if (!fund.isLPToken) {
            return 0;
        }
        uint256 pendingRewardAmount = _pendingRewardBalanceOf(fund);
        uint256 accMeedPerShare = _getAccMeedPerShare(_lpAddress, pendingRewardAmount);
        UserInfo storage user = userLpInfos[_lpAddress][_user];
        return user.amount.mul(accMeedPerShare).div(MEED_REWARDING_PRECISION).sub(user.rewardDebt);
    }

    function pendingRewardBalanceOf(address _fundAddress) public view returns (uint256) {

        if (block.timestamp < startRewardsTime) {
            return 0;
        }
        return _pendingRewardBalanceOf(fundInfos[_fundAddress]);
    }

    function _addFund(address _fundAddress, uint256 _value, bool _isFixedPercentage, bool _isLPToken) private {

        require(fundInfos[_fundAddress].lastRewardTime == 0, "TokenFactory#_addFund : Fund address already exists, use #setFundAllocation to change allocation");

        uint256 lastRewardTime = block.timestamp > startRewardsTime ? block.timestamp : startRewardsTime;

        fundAddresses.push(_fundAddress);
        fundInfos[_fundAddress] = FundInfo({
          lastRewardTime: lastRewardTime,
          isLPToken: _isLPToken,
          allocationPoint: 0,
          fixedPercentage: 0,
          accMeedPerShare: 0
        });

        if (_isFixedPercentage) {
            totalFixedPercentage = totalFixedPercentage.add(_value);
            fundInfos[_fundAddress].fixedPercentage = _value;
            require(totalFixedPercentage <= 100, "TokenFactory#_addFund: total percentage can't be greater than 100%");
        } else {
            totalAllocationPoints = totalAllocationPoints.add(_value);
            fundInfos[_fundAddress].allocationPoint = _value;
        }
        emit FundAdded(_fundAddress, _value, _isFixedPercentage, _isLPToken);
    }

    function _getMultiplier(uint256 _fromTimestamp, uint256 _toTimestamp) internal view returns (uint256) {

        return _toTimestamp.sub(_fromTimestamp).mul(meedPerMinute).div(1 minutes);
    }

    function _pendingRewardBalanceOf(FundInfo memory _fund) internal view returns (uint256) {

        uint256 periodTotalMeedRewards = _getMultiplier(_fund.lastRewardTime, block.timestamp);
        if (_fund.fixedPercentage > 0) {
          return periodTotalMeedRewards
            .mul(_fund.fixedPercentage)
            .div(100);
        } else if (_fund.allocationPoint > 0) {
          return periodTotalMeedRewards
            .mul(_fund.allocationPoint)
            .mul(100 - totalFixedPercentage)
            .div(totalAllocationPoints)
            .div(100);
        }
        return 0;
    }

    function _getAccMeedPerShare(address _lpAddress, uint256 pendingRewardAmount) internal view returns (uint256) {

        FundInfo memory fund = fundInfos[_lpAddress];
        if (block.timestamp > fund.lastRewardTime) {
            uint256 lpSupply = IERC20(_lpAddress).balanceOf(address(this));
            if (lpSupply > 0) {
              return fund.accMeedPerShare.add(pendingRewardAmount.mul(MEED_REWARDING_PRECISION).div(lpSupply));
            }
        }
        return fund.accMeedPerShare;
    }

    function _safeMeedTransfer(address _to, uint256 _amount) internal {

        uint256 meedBal = meed.balanceOf(address(this));
        if (_amount > meedBal) {
            meed.transfer(_to, meedBal);
        } else {
            meed.transfer(_to, _amount);
        }
    }

    function _mint(address _to, uint256 _amount) internal {

        uint256 totalSupply = meed.totalSupply();
        if (totalSupply.add(_amount) > MAX_MEED_SUPPLY) {
            if (MAX_MEED_SUPPLY > totalSupply) {
              uint256 remainingAmount = MAX_MEED_SUPPLY.sub(totalSupply);
              meed.mint(_to, remainingAmount);
              emit MaxSupplyReached(block.timestamp);
            }
        } else {
            meed.mint(_to, _amount);
        }
    }

}