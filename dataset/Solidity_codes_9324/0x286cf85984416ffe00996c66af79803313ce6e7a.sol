

pragma solidity ^0.7.0;


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

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}

interface IHornLockVault {

    function balanceOf(address account) external view returns (uint256);

    function claimableBalanceOf(address account) external view returns (uint256);

    function claimableHornOf(address account) external view returns (uint256);

    function deposit(uint256 amount, address referralAddr) external payable returns(bool);

    function withdraw() external payable returns(bool);

    function burn(uint256 amount) external payable returns(bool);

    function reserve() external view returns (uint256);

    function lockedAssets() external view returns (uint256);

    
    event Deposit(address indexed from, uint256 value, uint256 fee, uint256 fromDate, uint256 toDate);
    event Withdraw(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value, uint256 weightAdded);
    event DepositReward(address indexed to, uint256 reward, uint256 totalFee, uint256 senderBalance, uint256 contractBalance, uint256 weightPercent);
    event ReferralReward(address indexed from, address indexed to, uint256 amount, uint256 reward, uint256 baseFee);
    event NewPool(uint256 index, uint256 timestamp);
    event Claim(address indexed from, uint256 amount);
    event Log(string text);
    event LogUINT(uint256 value);
    event LogUINTText(string key, uint256 value);
    event LogAddress(address value);
}

interface IExtendedERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function symbol() external view returns (string memory);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);



    function mint(address to, uint256 amount) external;

    function burn(address from, uint256 amount) external;


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract HornLockVaultV2 is IHornLockVault {

    using SafeMath for uint256;

    struct LockedAsset {
        address account;
        uint256 amount;
        uint256 burnedHorn;
        uint256 fees;
        uint256 fromDate;
        uint256 toDate;
        uint256 alreadyClaimedHorn;
        bool isBurnAsset;
        uint256 depositIndex;
        uint256 enterPoolFees;
    }

    struct RewardFee {
        uint256 totalAssetAmount;
        uint256 totalFeesAmount;
        uint256 amount;
        uint256 depositIndex;
    }

    mapping(address => LockedAsset[]) private _lockedAssetsByAddress;
    mapping(uint256 => uint256) private _feesAtIndex;
    RewardFee private _poolFees;

    bool public _isActive = true;
    address public _createdFrom;
    address public _owner;
    string public _vaultName;
    uint128 public _fee;
    uint128 public _depositRewardFee;
    uint256 public _hornPerDay;
    uint256 public _feesVault;
    uint256 public _minLockDays;
    uint256 public _weightPerHorn;
    uint256 private _depositIndex = 0;
    bool public _isPaused = false;
    bool public _hornRewardDisabled = false;
    IExtendedERC20 private _token;
    address public _tokenAddr;
    IExtendedERC20 private _hornToken;
    address public _hornTokenAddr;

    constructor(
        address owner,
        address lockedTokenAddr,
        address hornTokenAddr,
        uint128 fee,
        uint128 depositRewardFee,
        uint256 hornPerDay,
        uint256 minLockDays,
        uint256 weightPerHorn
    ) {
        _createdFrom = msg.sender;
        _owner = owner;
        _tokenAddr = lockedTokenAddr;
        _token = IExtendedERC20(lockedTokenAddr);
        _hornTokenAddr = hornTokenAddr;
        _hornToken = IExtendedERC20(hornTokenAddr);
        _vaultName = _token.symbol();
        _fee = fee;
        _depositRewardFee = depositRewardFee;
        _hornPerDay = hornPerDay;
        _minLockDays = minLockDays;
        _weightPerHorn = weightPerHorn;

        _poolFees = RewardFee({
            amount: 0,
            totalFeesAmount: 0,
            totalAssetAmount: 0,
            depositIndex: _depositIndex
        });
    }

    function balanceOf(address account) public view override returns (uint256) {

        uint256 totalBalance = 0;
        for (uint256 i = 0; i < _lockedAssetsByAddress[account].length; i++) {
            if (_lockedAssetsByAddress[account][i].isBurnAsset || _lockedAssetsByAddress[account][i].amount <= 0) continue;
            totalBalance = totalBalance.add(
                _lockedAssetsByAddress[account][i].amount
            );
        }
        return totalBalance;
    }

    function claimableBalanceOf(address account)
        public
        view
        override
        returns (uint256)
    {

        uint256 totalBalance = 0;
        for (uint256 i = 0; i < _lockedAssetsByAddress[account].length; i++) {
            if (_lockedAssetsByAddress[account][i].isBurnAsset) continue;
            if (_lockedAssetsByAddress[account][i].toDate <= block.timestamp) {
                totalBalance = totalBalance.add(
                    _lockedAssetsByAddress[account][i].amount
                );
            }
        }
        return totalBalance;
    }

    function claimableHornOf(address account)
        public
        view
        override
        returns (uint256)
    {

        uint256 totalBalance = 0;
        for (uint256 i = 0; i < _lockedAssetsByAddress[account].length; i++) {
            if (
                _lockedAssetsByAddress[account][i].amount > 0 &&
                !_lockedAssetsByAddress[account][i].isBurnAsset
            ) {
                LockedAsset memory asset = _lockedAssetsByAddress[account][i];
                uint256 period =
                    block.timestamp.sub(asset.fromDate).div(60).div(60).div(24);
                if (period <= 0) continue;
                uint256 reward =
                    _hornPerDay.mul(asset.amount.mul(100)).div(10000).mul(
                        period
                    );
                reward = reward.div(100).sub(asset.alreadyClaimedHorn);
                totalBalance = totalBalance.add(reward);
            }
        }
        return totalBalance;
    }

    function reserve() public view override returns (uint256) {

        return _hornToken.balanceOf(address(this));
    }

    function lockedAssets() public view override returns (uint256) {

        uint256 totalBalance = _token.balanceOf(address(this)).sub(_feesVault);
        return totalBalance;
    }

    function getBurnedHornAmount(address account)
        public
        view
        returns (uint256)
    {

        uint256 totalBalance = 0;
        for (uint256 i = 0; i < _lockedAssetsByAddress[account].length; i++) {
            if (
                account == _lockedAssetsByAddress[account][i].account &&
                _lockedAssetsByAddress[account][i].isBurnAsset
            ) {
                totalBalance = totalBalance.add(
                    _lockedAssetsByAddress[account][i].burnedHorn
                );
            }
        }
        return totalBalance;
    }

    function name() public view returns (string memory) {

        return _vaultName;
    }

    function setPauseState(bool newState) external payable returns (bool) {

        require(
            msg.sender == _owner || msg.sender == _createdFrom,
            "Only the owner can do this"
        );
        _isPaused = newState;
        return true;
    }

    function setActiveState(bool newState) external payable returns (bool) {

        require(
            msg.sender == _owner || msg.sender == _createdFrom,
            "Only the owner can do this"
        );
        _isActive = newState;
        return true;
    }

    function setHornRewardDisabledState(bool newState)
        external
        payable
        returns (bool)
    {

        require(
            msg.sender == _owner || msg.sender == _createdFrom,
            "Only the owner can do this"
        );
        _hornRewardDisabled = newState;
        return true;
    }

    function deposit(uint256 amount, address referralAddr)
        external
        payable
        override
        returns (bool)
    {

        require(amount > 0, "Invalid amount");
        require(!_isPaused, "Deposit are paused for now");
        _deposit(msg.sender, amount, referralAddr);
        return true;
    }

    function balanceIndexes(address account, bool filterBurned)
        public
        view
        returns (uint256[] memory)
    {

        uint256 count = 0;
        for (uint256 i = 0; i < _lockedAssetsByAddress[account].length; i++) {
            if (
                _lockedAssetsByAddress[account][i].amount > 0 &&
                _lockedAssetsByAddress[account][i].isBurnAsset == filterBurned
            ) {
                count++;
            }
        }
        uint256[] memory indexes = new uint256[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < _lockedAssetsByAddress[account].length; i++) {
            if (
                _lockedAssetsByAddress[account][i].amount > 0 &&
                _lockedAssetsByAddress[account][i].isBurnAsset == filterBurned
            ) {
                indexes[index] = i;
                index++;
            }
        }
        return indexes;
    }

    function getLockedAssetsCountByAccount(address account)
        public
        view
        returns (uint256)
    {

        uint256 count = 0;
        for (uint256 i = 0; i < _lockedAssetsByAddress[account].length; i++) {
            if (
                _lockedAssetsByAddress[account][i].account == account &&
                _lockedAssetsByAddress[account][i].amount > 0
            ) {
                count++;
            }
        }
        return count;
    }

    function claimableFees(address account, uint256 index)
        public
        view
        returns (uint256)
    {

        uint256 totalFees = 0;
        LockedAsset memory asset = _lockedAssetsByAddress[account][index];
        if (
            _poolFees.amount <= 0 ||
            asset.fees > _poolFees.amount ||
            asset.account != account ||
            asset.amount <= 0
        ) return 0;

        uint256 contractBalance = _poolFees.totalAssetAmount;
        if (asset.fees > _poolFees.amount) return 0;
        uint256 feesSinceDeposit =
            _feesAtIndex[_depositIndex].sub(_feesAtIndex[asset.depositIndex]); // gas saver
        uint256 reducedEnterPoolFees = asset.enterPoolFees;
        if (feesSinceDeposit > reducedEnterPoolFees) {
            reducedEnterPoolFees = 0;
        } else {
            reducedEnterPoolFees = reducedEnterPoolFees.sub(feesSinceDeposit);
        }
        
        uint256 fees = 0;
        if(_poolFees.amount >= reducedEnterPoolFees) {
            fees = _poolFees.amount.sub(reducedEnterPoolFees);
        }
        else {
            fees = _poolFees.amount;
        }


        uint256 senderBalance = asset.amount;
        uint256 weightPercent =
            senderBalance.mul(10000).div(contractBalance).mul(100);
        uint256 reward = fees.mul(weightPercent).div(1000000);
        totalFees = totalFees.add(reward);
        return totalFees;
    }

    function weightInPool(address account, uint256 index)
        public
        view
        returns (uint256)
    {

        LockedAsset memory asset = _lockedAssetsByAddress[account][index];
        uint256 contractBalance = _poolFees.totalAssetAmount;
        uint256 senderBalance = asset.amount;
        uint256 weightPercent =
            senderBalance.mul(10000).div(contractBalance).mul(100);
        return weightPercent;
    }

    function _deposit(
        address sender,
        uint256 amount,
        address referralAddr
    ) internal {

        require(
            _token.balanceOf(sender) >= amount,
            "Transfer amount exceeds balance"
        );
        require(
            _token.transferFrom(msg.sender, address(this), amount) == true,
            "Error transferFrom on the contract"
        );
        uint256 fee = (amount * _fee) / 10000;
        if (referralAddr != address(0) && referralAddr != msg.sender) {
            uint256 referralFee = (fee * 5000) / 10000;
            uint256 baseFee = fee;
            fee = fee.sub(referralFee);
            require(
                _token.transfer(referralAddr, referralFee) == true,
                "Error transferFrom on the contract for referral"
            );
            emit ReferralReward(
                sender,
                referralAddr,
                amount,
                referralFee,
                baseFee
            );
        }
        uint256 depositFee = (amount * _depositRewardFee) / 10000;
        uint256 amountSubFee = amount.sub(fee).sub(depositFee);

        _feesVault = _feesVault.add(fee);
        if (_depositIndex == 0) {
            _feesVault = _feesVault.add(depositFee);
        } else {
            _poolFees.totalFeesAmount = _poolFees.totalFeesAmount.add(
                depositFee
            );
            _poolFees.amount = _poolFees.amount.add(depositFee);
        }
        _poolFees.totalAssetAmount = _poolFees.totalAssetAmount.add(
            amountSubFee
        );

        _depositIndex = _depositIndex.add(1);
        _poolFees.depositIndex = _depositIndex;
        _feesAtIndex[_depositIndex] = _poolFees.totalFeesAmount;

        _lockedAssetsByAddress[sender].push(
            LockedAsset({
                enterPoolFees: _poolFees.amount,
                account: sender,
                fees: depositFee,
                amount: amountSubFee,
                burnedHorn: 0,
                fromDate: block.timestamp,
                toDate: block.timestamp.add(_minLockDays * 1 days),
                alreadyClaimedHorn: 0,
                isBurnAsset: false,
                depositIndex: _depositIndex
            })
        );

        emit Deposit(
            sender,
            amount,
            fee.add(depositFee),
            block.timestamp,
            block.timestamp.add(_minLockDays * 1 days)
        );
    }

    function withdraw() external payable override returns (bool) {

        require(!_isPaused, "Withdraw are paused for now");
        _withdraw(msg.sender);
        return true;
    }

    function _withdraw(address sender) internal {

        uint256 totalWithdraw = 0;
        uint256 totalRemovedAssetsCount = 0;
        for (uint256 i = 0; i < _lockedAssetsByAddress[sender].length; i++) {
            LockedAsset storage asset = _lockedAssetsByAddress[sender][i];
            if (asset.toDate <= block.timestamp && asset.amount > 0) {
                totalRemovedAssetsCount = totalRemovedAssetsCount + 1;
                uint256 hornreward = 0;
                if (!asset.isBurnAsset) {
                    hornreward = _rewardWithdrawalHorn(
                        sender,
                        asset.amount,
                        asset.fromDate,
                        block.timestamp,
                        asset.alreadyClaimedHorn
                    );
                }
                uint256 reward = _claimFeesForAsset(asset, asset.amount);

                if (!asset.isBurnAsset) {
                    totalWithdraw = totalWithdraw.add(asset.amount).add(reward);
                } else {
                    totalWithdraw = totalWithdraw.add(reward);
                }
                asset.alreadyClaimedHorn = asset.alreadyClaimedHorn.add(
                    hornreward
                );
            }
        }

        LockedAsset[] storage newLockedAssetArray;
        for (uint256 i = 0; i < _lockedAssetsByAddress[sender].length; i++) {
            LockedAsset storage asset = _lockedAssetsByAddress[sender][i];
            if (asset.toDate <= block.timestamp && asset.amount > 0) {
                asset.amount = 0;
                asset.burnedHorn = 0;
            } else {
                newLockedAssetArray.push(_lockedAssetsByAddress[sender][i]);
            }
        }
        _lockedAssetsByAddress[sender] = newLockedAssetArray;

        if (totalWithdraw <= 0) return;
        require(
            _token.transfer(sender, totalWithdraw) == true,
            "Error transferFrom on the contract"
        );
        emit Withdraw(sender, totalWithdraw);
    }

    function burn(uint256 amount) external payable override returns (bool) {

        require(!_isPaused, "Burn are paused for now");
        require(amount > 0, "Invalid amount");
        _burn(msg.sender, amount);
        return true;
    }

    function _burn(address sender, uint256 burnAmount) internal {

        require(
            _hornToken.balanceOf(sender) >= burnAmount,
            "Transfer amount exceeds balance"
        );
        _hornToken.burn(sender, burnAmount);

        _depositIndex = _depositIndex.add(1);
        _lockedAssetsByAddress[sender].push(
            LockedAsset({
                enterPoolFees: _poolFees.amount,
                account: sender,
                fees: 0,
                amount: burnAmount.mul(_weightPerHorn).div(1 ether),
                burnedHorn: burnAmount,
                fromDate: block.timestamp,
                toDate: block.timestamp.add(_minLockDays * 1 days),
                alreadyClaimedHorn: 0,
                isBurnAsset: true,
                depositIndex: _depositIndex
            })
        );
        emit Burn(
            sender,
            burnAmount,
            burnAmount.mul(_weightPerHorn).div(1 ether)
        );
    }

    function claimHorn() public payable {

        require(!_hornRewardDisabled, "Claim are disabled for now");
        uint256 totalClaim = 0;
        for (
            uint256 i = 0;
            i < _lockedAssetsByAddress[msg.sender].length;
            i += 1
        ) {
            LockedAsset storage asset = _lockedAssetsByAddress[msg.sender][i];
            if (asset.amount > 0 && !asset.isBurnAsset) {
                uint256 reward =
                    _rewardWithdrawalHorn(
                        msg.sender,
                        asset.amount,
                        asset.fromDate,
                        block.timestamp,
                        asset.alreadyClaimedHorn
                    );
                asset.alreadyClaimedHorn = asset.alreadyClaimedHorn.add(reward);
                totalClaim = totalClaim.add(reward);
            }
        }
        if (totalClaim <= 0) return;
        emit Claim(msg.sender, totalClaim);
    }

    function _rewardWithdrawalHorn(
        address receiver,
        uint256 amount,
        uint256 fromDate,
        uint256 toDate,
        uint256 alreadyClaimed
    ) internal returns (uint256) {

        if (_hornRewardDisabled) return 0;

        uint256 period = toDate.sub(fromDate).div(60).div(60).div(24);
        if (period <= 0) return 0;
        uint256 reward =
            _hornPerDay.mul(amount.mul(100)).div(10000).mul(period);
        reward = reward.div(100).sub(alreadyClaimed);
        if (reward <= 0) return 0;
        _hornToken.mint(address(this), reward);
        require(
            _hornToken.transfer(receiver, reward) == true,
            "Error transferFrom for reward on the contract"
        );
        return reward;
    }

    function _claimFeesForAsset(
        LockedAsset storage asset,
        uint256 withdrawAmount
    ) internal returns (uint256) {

        if (_poolFees.amount <= 0 || asset.fees > _poolFees.amount) return 0;
        uint256 contractBalance = _poolFees.totalAssetAmount;
        uint256 feesSinceDeposit =
            _feesAtIndex[_depositIndex].sub(_feesAtIndex[asset.depositIndex]); // gas saver
        uint256 reducedEnterPoolFees = asset.enterPoolFees;
        if (feesSinceDeposit > reducedEnterPoolFees) {
            reducedEnterPoolFees = 0;
        } else {
            reducedEnterPoolFees = reducedEnterPoolFees.sub(feesSinceDeposit);
        }

        uint256 fees = 0;
        if(_poolFees.amount >= reducedEnterPoolFees) {
            fees = _poolFees.amount.sub(reducedEnterPoolFees);
        }
        else {
            fees = _poolFees.amount;
        }

        uint256 senderBalance = withdrawAmount;
        uint256 reward = (fees * (senderBalance.mul(10000).div(contractBalance).mul(100))) / 1000000;

        _poolFees.amount = _poolFees.amount.sub(reward);
        _poolFees.totalAssetAmount = _poolFees.totalAssetAmount.sub(
            withdrawAmount
        );
        return reward;
    }

    function withdrawFees() public payable {

        require(
            msg.sender == _owner || msg.sender == _createdFrom,
            "Only the owner can do this"
        );
        require(
            _token.transfer(msg.sender, _feesVault) == true,
            "Error transferFrom on the contract"
        );
        _feesVault = 0;
    }
}

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
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

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
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

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
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

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}

contract HornToken is ERC20, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    uint256 private _initialSupply = 5000000 * 10 ** 18;
    uint256 private _totalSupply = 0;
    uint256 private _alreadyMinted = 0;
    uint256 private _maxMintAmount = 5000000 * 10 ** 18;
    uint256 private _maxSupply = 10000000 * 10 ** 18;

    constructor() ERC20("Horn", "HORN") {
        _totalSupply = _initialSupply;
        _mint(msg.sender, _initialSupply);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        _setupRole(BURNER_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) public {
        require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");
        require(_totalSupply + amount <= _maxSupply, "Can't mint more tokens");
        require(_alreadyMinted + amount <= _maxMintAmount, "Can't mint more tokens");
        _totalSupply += amount;
        _alreadyMinted += amount;
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public {
        require(hasRole(BURNER_ROLE, msg.sender), "Caller is not a burner");
        _totalSupply -= amount;
        _burn(from, amount);
    }
}

contract UnifiedHornVault {
    address private _owner;
    address private _hornTokenAddr;
    HornToken private _hornToken;

    address[] public vaultIndexes;

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only the owner can do this action");
        _;
    }

    constructor(address hornTokenAddr) {
        _owner = msg.sender;
        _hornTokenAddr = hornTokenAddr;
        _hornToken = HornToken(hornTokenAddr);
    }

    function fetchIndexes() public view returns (address[] memory) {
        address[] memory result = new address[](vaultIndexes.length);
        for (uint256 i = 0; i < vaultIndexes.length; i++) {
            result[i] = vaultIndexes[i];
        }
        return result;
    }

    function addPool(
        address lockedTokenAddr,
        address hornTokenAddr,
        uint128 fee,
        uint128 depositRewardFee,
        uint256 hornPerDay,
        uint256 minLockDays,
        uint256 weightPerHorn
    ) public payable onlyOwner returns (address) {
        HornLockVaultV2 vault =
            new HornLockVaultV2(
                msg.sender,
                lockedTokenAddr,
                hornTokenAddr,
                fee,
                depositRewardFee,
                hornPerDay,
                minLockDays,
                weightPerHorn
            );
        _hornToken.grantRole(_hornToken.MINTER_ROLE(), address(vault));
        _hornToken.grantRole(_hornToken.BURNER_ROLE(), address(vault));
        vault.setActiveState(true);

        vaultIndexes.push(address(vault));

        return address(vault);
    }

    function addExistingPool(address addr)
        public
        payable
        onlyOwner
        returns (address)
    {
        vaultIndexes.push(addr);
        return addr;
    }

    function removePool(address addr) public payable onlyOwner {
        HornLockVaultV2 vault = HornLockVaultV2(addr);
        vault.setActiveState(false);

        address[] memory newArray = new address[](vaultIndexes.length - 1);
        uint256 new_index = 0;
        for (uint256 i = 0; i < vaultIndexes.length; i++) {
            if (vaultIndexes[i] != addr) {
                newArray[new_index++] = vaultIndexes[i];
            }
        }
        vaultIndexes = newArray;
    }
}