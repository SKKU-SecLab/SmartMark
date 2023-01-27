


pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

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
}

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
}


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
}

pragma solidity ^0.8.0;

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}

pragma solidity ^0.8.0;

contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
    unchecked {
        _approve(sender, _msgSender(), currentAllowance - amount);
    }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    unchecked {
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
    }

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

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
    unchecked {
        _balances[sender] = senderBalance - amount;
    }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
    unchecked {
        _balances[account] = accountBalance - amount;
    }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}

pragma solidity ^0.8.0;

library EnumerableSet {

    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

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
        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
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

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

pragma solidity ^0.8.10;

interface IYielder {
    function ownerOf(uint256 _tokenId) external view returns(address);
}

interface IBooster {
    function computeAmount(uint256 amount) external view returns(uint256);
    function computeAmounts(uint256[] calldata amounts, uint256[] calldata yieldingCores, uint256[] calldata tokens) external view returns(uint256);
}

contract HumansOfTheMetaverseToken is ERC20("HOTM", "HOTM"), Ownable, Pausable, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.UintSet;

    struct YielderSettings {
        uint256 _defaultYieldRate; // fallback for yieldingCoresAmount absence
        uint256 _startTime;
        uint256 _endTime;
        uint256 _timeRate;
        mapping(uint256 => uint256) _tokenYieldingCoresMapping; // tokenId => yieldingCoreId (i.e. job)
        mapping(uint256 => uint256) _yieldingCoresAmountMapping; // yieldingCoreId => amount
        mapping(uint256 => uint256) _lastClaim; // tokenId => date
    }

    struct BoosterSettings {
        address _appliesFor; // yielder
        bool _status;
        EnumerableSet.UintSet _yieldingCores;
        mapping(uint256 => uint256) _boosterStartDates; // tokenId => boosterStartDate
    }

    mapping(address => YielderSettings) yielders;

    mapping(address => BoosterSettings) boosters;

    address[] public boostersAddresses; // boosters should be iterable

    mapping(address => mapping(address => EnumerableSet.UintSet)) tokensOwnerShip; // map econtract addrss => map owner address => yieldingToken

    uint256 public allowedPublicTokensMinted = 31207865 ether; // max total supply * 0.6
    uint256 public foundersAndOthersAllowedMinting = 20805244 ether;
    uint256 public foundersLinearDistributionPeriod = 365 days;

    uint256 public foundersAndOthersLastClaim;

    constructor() {
        _pause();
        foundersAndOthersLastClaim = block.timestamp;
    }


    function setYielderSettings(
        uint256 _defaultYieldRate,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _timeRate,
        address _yielderAddress
    ) external onlyOwner {
        YielderSettings storage yielderSettings =  yielders[_yielderAddress];

        yielderSettings._defaultYieldRate = _defaultYieldRate;
        yielderSettings._startTime = _startTime;
        yielderSettings._endTime = _endTime;
        yielderSettings._timeRate = _timeRate;
    }

    function getYielderSettings(address _address) internal view returns (YielderSettings storage) {
        YielderSettings storage yielderSettings = yielders[_address];
        require(yielderSettings._startTime != uint256(0), "There is no yielder with provided address");

        return yielderSettings;
    }

    function setTokenYielderMapping(
        address _yielderAddress,
        uint256[] calldata _tokenIds,
        uint256[] calldata _yieldingCores
    ) external onlyOwner {
        require(_tokenIds.length == _yieldingCores.length, "Provided arrays should have the same length");

        YielderSettings storage yielderSettings = getYielderSettings(_yielderAddress);

        for(uint256 i = 0; i < _tokenIds.length; ++i) {
            yielderSettings._tokenYieldingCoresMapping[_tokenIds[i]] = _yieldingCores[i];
        }
    }

    function setYieldingAmountMapping(
        address _yielderAddress,
        uint256[] calldata _yieldingCores,
        uint256[] calldata _amounts
    ) external onlyOwner {
        require(_amounts.length == _yieldingCores.length, "Provided arrays should have the same length");

        YielderSettings storage yielderSettings = getYielderSettings(_yielderAddress);

        for(uint256 i = 0; i < _yieldingCores.length; ++i) {
            yielderSettings._yieldingCoresAmountMapping[_yieldingCores[i]] = _amounts[i] * (10 ** 18); // cast to ether
        }
    }

    function setEndDateForYielder(uint256 _endTime, address _contract) external onlyOwner {
        YielderSettings storage yielderSettings = getYielderSettings(_contract);
        yielderSettings._endTime = _endTime;
    }

    function setStartDateForYielder(uint256 _startTime, address _contract) external onlyOwner {
        YielderSettings storage yielderSettings = getYielderSettings(_contract);
        yielderSettings._startTime = _startTime;
    }

    function setDefaultYieldRateForYielder(uint256 _defaultYieldRate, address _contract) external onlyOwner {
        YielderSettings storage yielderSettings = getYielderSettings(_contract);
        yielderSettings._defaultYieldRate = _defaultYieldRate * (10 ** 18);
    }

    function setTimeRateForYielder(uint256 _timeRate, address _contract) external onlyOwner {
        YielderSettings storage yielderSettings = getYielderSettings(_contract);
        yielderSettings._timeRate = _timeRate;
    }


    function setBoosterConfiguration(
        address _appliesFor,
        bool _status,
        address _boosterAddress
    ) external onlyOwner {
        boostersAddresses.push(_boosterAddress);
        BoosterSettings storage boosterSettings = boosters[_boosterAddress];
        boosterSettings._appliesFor=  _appliesFor;
        boosterSettings._status = _status;
    }

    function getBoosterSettings(address _address) internal view returns (BoosterSettings storage) {
        BoosterSettings storage boosterSettings = boosters[_address];
        require(boosterSettings._appliesFor != address(0), "There is no yielder with provided address");

        return boosterSettings;
    }

    function setBoosterCores(address _boosterAddress, uint256[] calldata _yieldingCoresIds) external onlyOwner {
        BoosterSettings storage boosterSettings = getBoosterSettings(_boosterAddress);
        for (uint256 i = 0; i < _yieldingCoresIds.length; ++i) {
            boosterSettings._yieldingCores.add(_yieldingCoresIds[i]);
        }
    }

    function setBoosterStatus(address _boosterAddress, bool _status) external onlyOwner {
        BoosterSettings storage boosterSettings = getBoosterSettings(_boosterAddress);
        boosterSettings._status = _status;
    }

    function setBoosterAppliesFor(address _boosterAddress, address _appliesFor) external onlyOwner{
        BoosterSettings storage boosterSettings = getBoosterSettings(_boosterAddress);
        boosterSettings._appliesFor = _appliesFor;
    }

    function replaceBoosterCores(address _boosterAddress, uint256[] calldata _yieldingCoresIds) external onlyOwner {
        BoosterSettings storage boosterSettings = getBoosterSettings(_boosterAddress);

        for (uint256 i = 0; i < boosterSettings._yieldingCores.length(); ++i) {
            boosterSettings._yieldingCores.remove(boosterSettings._yieldingCores.at(i));
        }

        for (uint256 i = 0; i < _yieldingCoresIds.length; ++i) {
            boosterSettings._yieldingCores.add(_yieldingCoresIds[i]);
        }
    }



    function claimRewards(
        address _contractAddress,
        uint256[] calldata _tokenIds
    ) external whenNotPaused nonReentrant() returns (uint256) {
        YielderSettings storage yielderSettings = getYielderSettings(_contractAddress);

        for(uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 _tokenId = _tokenIds[i];
            processTokenOwnerShip(_contractAddress, _tokenId);
        }
        uint256 currentTime = block.timestamp;

        uint256 totalUnclaimedRewards = computeUnclaimedRewardsAndUpdate(yielderSettings, _contractAddress, _tokenIds, currentTime);

        claimTokens(totalUnclaimedRewards);

        for(uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 _tokenId = _tokenIds[i];
            if (currentTime > yielderSettings._endTime) {
                yielderSettings._lastClaim[_tokenId] = yielderSettings._endTime;
            } else {
                yielderSettings._lastClaim[_tokenId] = currentTime;
            }
        }

        return totalUnclaimedRewards;
    }

    function checkClaimableAmount(address _contractAddress, uint256[] calldata _tokenIds) view external whenNotPaused returns(uint256) {
        YielderSettings storage yielderSettings = getYielderSettings(_contractAddress);

        uint256 totalUnclaimedRewards = computeUnclaimedRewardsSafe(yielderSettings, _contractAddress, _tokenIds, block.timestamp);

        return totalUnclaimedRewards;
    }

    function computeUnclaimedRewardsAndUpdate(
        YielderSettings storage _yielderSettings,
        address _yielderAddress,
        uint256[] calldata _tokenIds,
        uint256 _currentTime
    ) internal returns (uint256) {
        uint256 totalReward = 0;

        totalReward += computeBaseAccumulatedRewards(_yielderSettings, _tokenIds, _currentTime);
        totalReward += computeBoostersAccumulatedRewardsAndUpdate(_yielderAddress, _yielderSettings, _tokenIds, _currentTime);

        return totalReward;
    }

    function computeUnclaimedRewardsSafe(
        YielderSettings storage _yielderSettings,
        address _yielderAddress,
        uint256[] calldata _tokenIds,
        uint256 _currentTime
    ) internal view returns (uint256) {
        uint256 totalReward = 0;

        totalReward += computeBaseAccumulatedRewards(_yielderSettings, _tokenIds, _currentTime);
        totalReward += computeBoostersAccumulatedRewardsSafe(_yielderAddress, _yielderSettings, _tokenIds, _currentTime);

        return totalReward;
    }

    function computeBaseAccumulatedRewards(
        YielderSettings storage _yielderSettings,
        uint256[] calldata _tokenIds,
        uint256 _currentTime
    ) internal view returns (uint256) {
        uint256 baseAccumulatedRewards = 0;

        for (uint256 i = 0; i < _tokenIds.length; ++i) {
            uint256 lastClaimDate = getLastClaimForYielder(_yielderSettings, _tokenIds[i]);

            if (lastClaimDate != _yielderSettings._endTime) {
                uint256 secondsElapsed = _currentTime - lastClaimDate;
                if (_yielderSettings._defaultYieldRate != uint256(0)) {
                    baseAccumulatedRewards += secondsElapsed * _yielderSettings._defaultYieldRate / _yielderSettings._timeRate;
                } else {
                    baseAccumulatedRewards +=
                    secondsElapsed * _yielderSettings._yieldingCoresAmountMapping[_yielderSettings._tokenYieldingCoresMapping[_tokenIds[i]]] / _yielderSettings._timeRate;
                }
            }
        }

        return baseAccumulatedRewards;
    }

    function computeBoostersAccumulatedRewardsAndUpdate(
        address _yielderAddress,
        YielderSettings storage _yielderSettings,
        uint256[] calldata _tokenIds,
        uint256 _currentTime
    ) internal returns (uint256) {

        uint256 boosterAccumulatedRewards = 0;

        for (uint256 boosterIndex = 0; boosterIndex < boostersAddresses.length; ++boosterIndex) {
            BoosterSettings storage boosterSettings = getBoosterSettings(boostersAddresses[boosterIndex]);
            uint256 toBeSentArraysIndex = 0;
            uint256[] memory accumulatedRewardsForBooster = new uint256[](_tokenIds.length);
            uint256[] memory validTokensCandidates = new uint256[](_tokenIds.length);

            if (boosterSettings._appliesFor == _yielderAddress && boosterSettings._status) {
                for (uint256 i = 0; i < _tokenIds.length; ++i) {
                    uint256 boosterStartDate = getLastClaimForBooster(boosterSettings, _tokenIds[i]);
                    if (
                        (
                        boosterSettings._yieldingCores.length() == 0
                        || boosterSettings._yieldingCores.contains(_yielderSettings._tokenYieldingCoresMapping[_tokenIds[i]])
                        ) && getLastClaimForYielder(_yielderSettings, _tokenIds[i]) != _yielderSettings._endTime
                        && boosterStartDate != uint256(0)
                    ) {
                        uint256 secondsElapsed = _currentTime - boosterStartDate;

                        if (_yielderSettings._defaultYieldRate != uint256(0)) {
                            accumulatedRewardsForBooster[toBeSentArraysIndex] =
                            secondsElapsed * _yielderSettings._defaultYieldRate / _yielderSettings._timeRate;
                        } else {
                            uint256 tokenYieldingCoresMapping = _yielderSettings._tokenYieldingCoresMapping[_tokenIds[i]];
                            uint256 yieldingCoresAmountMapping = _yielderSettings._yieldingCoresAmountMapping[tokenYieldingCoresMapping];
                            accumulatedRewardsForBooster[toBeSentArraysIndex] =
                            secondsElapsed * yieldingCoresAmountMapping / _yielderSettings._timeRate;
                        }
                        validTokensCandidates[toBeSentArraysIndex] = _tokenIds[i];
                        toBeSentArraysIndex++;
                    }
                }
                if (boosterSettings._yieldingCores.length() != 0) {
                    uint256[] memory yieldingCores = new uint256[](validTokensCandidates.length);

                    for (uint256 i = 0; i < validTokensCandidates.length; ++i) {
                        yieldingCores[i] = _yielderSettings._tokenYieldingCoresMapping[validTokensCandidates[i]];
                    }

                    boosterAccumulatedRewards +=
                    IBooster(boostersAddresses[boosterIndex]).computeAmounts(accumulatedRewardsForBooster, yieldingCores, validTokensCandidates);
                } else {
                    uint256 summedBoosterAccumulatedRewards = 0;
                    for (uint256 i = 0; i < validTokensCandidates.length; ++i) {
                        summedBoosterAccumulatedRewards += accumulatedRewardsForBooster[i];
                    }
                    boosterAccumulatedRewards += IBooster(boostersAddresses[boosterIndex]).computeAmount(summedBoosterAccumulatedRewards);
                }
                for (uint256 i = 0; i < validTokensCandidates.length; ++i) {
                    if (boosterSettings._boosterStartDates[validTokensCandidates[i]] != uint256(0)) {
                        boosterSettings._boosterStartDates[validTokensCandidates[i]] = _currentTime;
                    }
                }
            }
        }

        return boosterAccumulatedRewards;
    }

    function computeBoostersAccumulatedRewardsSafe(
        address _yielderAddress,
        YielderSettings storage _yielderSettings,
        uint256[] calldata _tokenIds,
        uint256 _currentTime
    ) internal view returns (uint256) {

        uint256 boosterAccumulatedRewards = 0;

        for (uint256 boosterIndex = 0; boosterIndex < boostersAddresses.length; ++boosterIndex) {
            BoosterSettings storage boosterSettings = getBoosterSettings(boostersAddresses[boosterIndex]);
            uint256 toBeSentArraysIndex = 0;
            uint256[] memory accumulatedRewardsForBooster = new uint256[](_tokenIds.length);
            uint256[] memory validTokensCandidates = new uint256[](_tokenIds.length);

            if (boosterSettings._appliesFor == _yielderAddress && boosterSettings._status) {
                for (uint256 i = 0; i < _tokenIds.length; ++i) {
                    uint256 boosterStartDate = getLastClaimForBooster(boosterSettings, _tokenIds[i]);
                    if (
                        (
                        boosterSettings._yieldingCores.length() == 0
                        || boosterSettings._yieldingCores.contains(_yielderSettings._tokenYieldingCoresMapping[_tokenIds[i]])
                        ) && getLastClaimForYielder(_yielderSettings, _tokenIds[i]) != _yielderSettings._endTime
                        && boosterStartDate != uint256(0)
                    ) {

                        uint256 secondsElapsed = _currentTime - boosterStartDate;

                        if (_yielderSettings._defaultYieldRate != uint256(0)) {
                            accumulatedRewardsForBooster[toBeSentArraysIndex] =
                            secondsElapsed * _yielderSettings._defaultYieldRate / _yielderSettings._timeRate;
                        } else {
                            uint256 tokenYieldingCoresMapping = _yielderSettings._tokenYieldingCoresMapping[_tokenIds[i]];
                            uint256 yieldingCoresAmountMapping = _yielderSettings._yieldingCoresAmountMapping[tokenYieldingCoresMapping];
                            accumulatedRewardsForBooster[toBeSentArraysIndex] =
                            secondsElapsed * yieldingCoresAmountMapping / _yielderSettings._timeRate;
                        }
                        validTokensCandidates[toBeSentArraysIndex] = _tokenIds[i];
                        toBeSentArraysIndex++;
                    }
                }
                if (boosterSettings._yieldingCores.length() != 0) {
                    uint256[] memory yieldingCores = new uint256[](validTokensCandidates.length);

                    for (uint256 i = 0; i < validTokensCandidates.length; ++i) {
                        yieldingCores[i] = _yielderSettings._tokenYieldingCoresMapping[validTokensCandidates[i]];
                    }

                    boosterAccumulatedRewards +=
                    IBooster(boostersAddresses[boosterIndex]).computeAmounts(accumulatedRewardsForBooster, yieldingCores, validTokensCandidates);

                } else {
                    uint256 summedBoosterAccumulatedRewards = 0;
                    for (uint256 i = 0; i < validTokensCandidates.length; ++i) {
                        summedBoosterAccumulatedRewards += accumulatedRewardsForBooster[i];
                    }
                    boosterAccumulatedRewards += IBooster(boostersAddresses[boosterIndex]).computeAmount(summedBoosterAccumulatedRewards);
                }
            }
        }

        return boosterAccumulatedRewards;
    }

    function getLastClaimForYielder(YielderSettings storage _yielderSettings, uint256 _tokenId) internal view returns (uint256) {
        uint256 lastClaimDate =  _yielderSettings._lastClaim[_tokenId];
        if (lastClaimDate == uint256(0)) {
            lastClaimDate = _yielderSettings._startTime;
        }

        return lastClaimDate;
    }

    function getLastClaim(address _yielderAddress, uint256 _tokenId) external whenNotPaused view returns (uint256) {
        YielderSettings storage yielderSettings = getYielderSettings(_yielderAddress);

        return getLastClaimForYielder(yielderSettings, _tokenId);
    }

    function getLastClaimForBooster(BoosterSettings storage _boosterSettings, uint256 _tokenId) view internal returns (uint256) {
        uint256 lastClaimDate = _boosterSettings._boosterStartDates[_tokenId];

        return lastClaimDate;
    }



    function watchTransfer(address _from, address _to, uint256 _tokenId) external {
        getYielderSettings(msg.sender);

        if (_from == address(0)) {
            tokensOwnerShip[msg.sender][_to].add(_tokenId);
        } else {
            tokensOwnerShip[msg.sender][_to].add(_tokenId);
            if (tokensOwnerShip[msg.sender][_from].contains(_tokenId)) {
                tokensOwnerShip[msg.sender][_from].remove(_tokenId);
                if (tokensOwnerShip[msg.sender][_from].length() == 0) {
                    delete tokensOwnerShip[msg.sender][_from];
                }
            }
        }
    }

    function watchBooster(address _collection, uint256[] calldata _tokenIds, uint256[] calldata _startDates) external {
        BoosterSettings storage boosterSettings = getBoosterSettings(msg.sender);

        if (boosterSettings._appliesFor == _collection) {
            for (uint32 i = 0; i < _tokenIds.length; ++i) {
                boosterSettings._boosterStartDates[_tokenIds[i]] = _startDates[i];
            }
        }
    }

    function claimTokens(uint256 _amount) internal {
        if (allowedPublicTokensMinted - _amount >= 0) {
            _mint(msg.sender, _amount);
            allowedPublicTokensMinted -= _amount;
        } else {
            IERC20(address(this)).transfer(msg.sender, _amount);
        }
    }

    function processTokenOwnerShip(address _contractAddress, uint256 _tokenId) internal {
        if (!tokensOwnerShip[_contractAddress][msg.sender].contains(_tokenId)) {
            address owner = IYielder(_contractAddress).ownerOf(_tokenId);
            if (owner == msg.sender) {
                tokensOwnerShip[_contractAddress][msg.sender].add(_tokenId);
            }
        }
        require(tokensOwnerShip[_contractAddress][msg.sender].contains(_tokenId), "Not the owner of the token");

    }

    function reserveTeamTokens() external onlyOwner {
        uint256 currentDate = block.timestamp;
        _mint(msg.sender, foundersAndOthersAllowedMinting * (currentDate - foundersAndOthersLastClaim) / foundersLinearDistributionPeriod);

        foundersAndOthersLastClaim = block.timestamp;
    }

    function withdrawContractAdditionalTokens() external onlyOwner {
        IERC20(address(this)).transfer(msg.sender, IERC20(address(this)).balanceOf(address(this)));
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function setPublicAllowedTokensToBeMinted(uint256 _amount) external onlyOwner {
        allowedPublicTokensMinted = _amount;
    }
}