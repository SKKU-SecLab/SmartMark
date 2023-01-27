
pragma solidity ^0.8.0;

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

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

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// MIT

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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

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
}// MIT

pragma solidity ^0.8.0;




contract PVTToken is AccessControl, ERC20 {

    bytes32 public constant MINTER_ROLE = keccak256('MINTER_ROLE');

    constructor()
            ERC20('PVTToken', 'PVT') {

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) virtual {

        _mint(to, amount);
    }
}// MIT

pragma solidity ^0.8.0;


interface IStrategy {

    function farm(address erc20Token_, uint256 amount_) external returns(uint256);

    function estimateReward(address) view external returns(uint256);

    function takeReward(address to_, address currency_, uint256 amount_) external;
    function takeReward(address to_) external;

    function decimals() view external returns(uint256);
    function vaultAddress() view external returns(address);
    function vaultTokenAddress() view external returns(address);
}// MIT

pragma solidity ^0.8.0;




contract Manager is AccessControl {

    using SafeERC20 for ERC20;
    using SafeERC20 for PVTToken;


    struct Stake {
            uint256 pvtAmount;
            uint256 lastBlockNumber;
            uint256 lastTotalWork;
            uint256 rewardsTaken;
    }

    struct Affiliate {
            address affiliateAddress;
            uint256 percentage;
            uint256 ownerPercentage;
            bool valid;
    }

    uint256 public constant RATE_COEF = 100;

    mapping(address => Affiliate) public affiliateMapping;
    address public defaultAffiliate;
    uint256 public affiliatePercentage = 10;
    uint256 public ownerPercentage = 5;
    uint256 public tokenRateT = 1;
    uint256 public tokenRateB = 1;

    PVTToken public pvtToken;
    IStrategy public strategy;

    mapping(address => Stake) public stakesMapping;
    address[] stakersLookup;

    Stake public ownerStake;


    uint256 public totalStableTokenAmount = 0;
    uint256 public lastBlockNumber = 0;
    uint256 public lastTotalWork = 0;
    uint256 public rewardsTaken = 0;
    uint256 public totalPVTAmount = 0;

    event Minted(address indexed minter, uint256 pvtAmount);
    event Staked(address indexed staker, uint256 pvtAmount);
    event Unstaked(address indexed staker, uint256 pvtAmount);
    event RewardTaken(address indexed staker, uint256 amount);


    constructor(address pvtTokenAddress_, address initialStrategyAddress_) {

        lastBlockNumber = block.number;
        strategy = IStrategy(initialStrategyAddress_);
        require(address(0x0) != address(strategy), 'Strategy cannot be null');
        pvtToken = PVTToken(pvtTokenAddress_);
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        defaultAffiliate = _msgSender();
        changeTokenRate(RATE_COEF);
    }


    function getTokenRate() view public returns (uint256) {

        uint256 pd = pvtToken.decimals();
        uint256 sd = ERC20(strategy.vaultTokenAddress()).decimals();
        if (pd >= sd) {
            return tokenRateT / (10 ** (pd - sd));
        } else {
            return tokenRateT;
        }
    }

    function changeTokenRate(uint256 rate_) public onlyRole(DEFAULT_ADMIN_ROLE) {

        require(0 < rate_, 'Token rate cannot be 0');

        uint256 pd = pvtToken.decimals();
        uint256 sd = ERC20(strategy.vaultTokenAddress()).decimals();
        if (pd >= sd) {
            tokenRateT = rate_ * (10 ** (pd - sd));
            tokenRateB = RATE_COEF;
        } else {
            tokenRateT = rate_;
            tokenRateB = RATE_COEF * (10 ** (sd - pd));
        }
    }

    function changeAffiliatePercentage(uint256 percentage_) public onlyRole(DEFAULT_ADMIN_ROLE) {

        require(0 <= percentage_ && percentage_ <= 100, 'Percentage must be from 0 to 100');
        affiliatePercentage = percentage_;
    }

    function changeOwnerPercentage(uint256 percentage_) public onlyRole(DEFAULT_ADMIN_ROLE) {

        require(0 <= percentage_ && percentage_ <= 100, 'Percentage must be from 0 to 100');
        ownerPercentage = percentage_;
    }

    function changeDefaultAffiliate(address newDefaultAffiliateAddress_)
                public onlyRole(DEFAULT_ADMIN_ROLE) {

        require(address(0x0) != newDefaultAffiliateAddress_, 'defaultAffiliate cannot be null');
        defaultAffiliate = newDefaultAffiliateAddress_;
    }

    function getStakers() public view returns(address[] memory) {

        return stakersLookup;
    }

    function changeStrategy(address newStrategyAddress_) public onlyRole(DEFAULT_ADMIN_ROLE) {

        require(address(0x0) != newStrategyAddress_, 'strategy cannot be null');
        strategy = IStrategy(newStrategyAddress_);
    }

    function mintPVTToken(uint256 amount_, address erc20Token_,
                          address affiliateAddress_, bool autoStake_) public {

        require(affiliateAddress_ != _msgSender(), 'User cannot be affiliate');
        uint256 stableTokenAmount = ERC20(erc20Token_).allowance(_msgSender(), address(this));
        if (0 != amount_) {
            require(amount_ <= stableTokenAmount, 'There is no allowance');
            stableTokenAmount = amount_;
        }
        require(0 != stableTokenAmount, 'There is no allowance');
        ERC20(erc20Token_).safeTransferFrom(_msgSender(), address(this), stableTokenAmount);
        (bool success, bytes memory result) = address(strategy).delegatecall(abi.encodeWithSignature(
                        'farm(address,uint256)', erc20Token_, stableTokenAmount));
        require(success, 'Delegate call failed');
        stableTokenAmount = abi.decode(result, (uint256));
        _mintPVTToken(stableTokenAmount, autoStake_);
        _setAffiliateIfNeeded(_msgSender(), affiliateAddress_);
    }

    function stake(uint256 amount_, address affiliateAddress_) public {

        require(affiliateAddress_ != _msgSender(), 'User cannot be affiliate');
        uint256 pvtAmount = pvtToken.allowance(_msgSender(), address(this));
        if (0 != amount_) {
            require(amount_ <= pvtAmount, 'There is no allowance');
            pvtAmount = amount_;
        }
        require(0 < pvtAmount, 'There is no allowance');
        pvtToken.safeTransferFrom(_msgSender(), address(this), pvtAmount);
        _stake(_msgSender(), pvtAmount);
        ownerStake.lastTotalWork += ownerStake.pvtAmount * (block.number - ownerStake.lastBlockNumber);
        ownerStake.lastBlockNumber = block.number;
        ownerStake.pvtAmount -= pvtAmount;
        _setAffiliateIfNeeded(_msgSender(), affiliateAddress_);
    }

    function unstake(uint256 amount_) public {

        require(0 < amount_, 'amount_ cannot be 0');
        Stake storage s = stakesMapping[_msgSender()];
        require(s.pvtAmount >= amount_, 'Not enough tokens');
        pvtToken.safeTransfer(_msgSender(), amount_);
        uint256 a = estimateReward(_msgSender());
        if (0 != a) {
            _takeReward(a);
        }
        s.lastTotalWork += (block.number - s.lastBlockNumber) * s.pvtAmount;
        s.pvtAmount -= amount_;
        s.lastBlockNumber = block.number;

        ownerStake.lastTotalWork += ownerStake.pvtAmount * (block.number - ownerStake.lastBlockNumber);
        ownerStake.lastBlockNumber = block.number;
        ownerStake.pvtAmount += amount_;

        emit Unstaked(_msgSender(), amount_);
    }

    function estimateReward(address userAddress) public view returns (uint256) {

        return _estimateStakeReward(stakesMapping[userAddress]);
    }

    function takeRewardWithExpectedTokens(
            address[] memory expectedTokens_,
            uint256[] memory percentages_,
            bool autoStake_) public {

        uint256 amount = estimateReward(_msgSender());
        require (0 < amount, 'There is no reward');
        _takeReward(amount, expectedTokens_, percentages_, autoStake_);
    }

    function takeReward() public {

        uint256 amount = estimateReward(_msgSender());
        require (0 < amount, 'There is no reward');
        _takeReward(amount);
    }

    function estimateOwnerReward() public view returns (uint256) {

        return _estimateStakeReward(ownerStake);
    }

    function takeOwnerReward(address recipientAddress_)
                    public onlyRole(DEFAULT_ADMIN_ROLE) {

        require(address(0x0) != address(recipientAddress_), 'recipientAddress_ cannot be null');
        uint256 amount = estimateOwnerReward();
        require (0 < amount, 'There is no reward');
        _delegateTakeRewardIfNeeded(recipientAddress_, strategy.vaultTokenAddress(), amount);
        ownerStake.rewardsTaken += amount;
        rewardsTaken += amount;
    }

    function takeAllStableTokens(address newPVTTokenAddress_) public onlyRole(DEFAULT_ADMIN_ROLE) {

        (bool success,) =
            address(strategy).delegatecall(abi.encodeWithSignature('takeReward(address)', _msgSender()));
        require(success, 'Delegate call failed');
        if (address(0x0) != newPVTTokenAddress_) {
            pvtToken = PVTToken(newPVTTokenAddress_);
            _reset();
        }
    }


    function _mintPVTToken(uint256 stableTokenAmount_, bool autoStake_) private {

        uint256 pvtAmount = stableTokenAmount_ * tokenRateT / tokenRateB;
        lastTotalWork += totalPVTAmount * (block.number - lastBlockNumber);
        if (autoStake_) {
            pvtToken.mint(address(this), pvtAmount);
            _stake(_msgSender(), pvtAmount);
        } else {
            pvtToken.mint(_msgSender(), pvtAmount);
            ownerStake.lastTotalWork += ownerStake.pvtAmount * (block.number - ownerStake.lastBlockNumber);
            ownerStake.lastBlockNumber = block.number;
            ownerStake.pvtAmount += pvtAmount;
        }
        totalPVTAmount += pvtAmount;
        lastBlockNumber = block.number;
        totalStableTokenAmount += stableTokenAmount_;

        emit Minted(_msgSender(), pvtAmount);
    }

    function _estimateStakeReward(Stake memory stake_) private view returns (uint256) {

        uint256 e = strategy.estimateReward(address(this));
        if (e <= totalStableTokenAmount) {
            return 0;
        }
        uint256 work = stake_.lastTotalWork + stake_.pvtAmount * (block.number - stake_.lastBlockNumber);
        uint256 Work = lastTotalWork + totalPVTAmount * (block.number - lastBlockNumber);

        uint256 Amount = e + rewardsTaken - totalStableTokenAmount;
        uint256 amount = work * Amount / Work;
        if  (amount <= stake_.rewardsTaken) {
            return 0;
        }
        uint256 total = amount - stake_.rewardsTaken;
        return total > e - totalStableTokenAmount ? e - totalStableTokenAmount : total;
    }

    function _setAffiliateIfNeeded(address userAddress_, address affiliateAddress_) private {

        if (! affiliateMapping[userAddress_].valid) {
            if (address(0x0) != affiliateAddress_) {
                affiliateMapping[userAddress_].affiliateAddress = affiliateAddress_;
            }
            affiliateMapping[userAddress_].ownerPercentage = ownerPercentage;
            affiliateMapping[userAddress_].percentage = affiliatePercentage;
            affiliateMapping[userAddress_].valid = true;
        }
    }

    function _stake(address userAddress_, uint256 pvtAmount_) private {

        Stake storage s = stakesMapping[userAddress_];
        if (0 == s.lastBlockNumber) {
            stakersLookup.push(userAddress_);
        } else {
            s.lastTotalWork += (block.number - s.lastBlockNumber) * s.pvtAmount;
        }
        s.pvtAmount += pvtAmount_;
        s.lastBlockNumber = block.number;

        emit Staked(userAddress_, pvtAmount_);
    }

    function _takeReward(uint256 amount_) private {

        require(affiliateMapping[_msgSender()].valid); // TODO Is it need or not
        _distributeReward(amount_,
                            amount_ * affiliateMapping[_msgSender()].ownerPercentage / 100,
                            affiliateMapping[_msgSender()].affiliateAddress,
                            amount_ * affiliateMapping[_msgSender()].percentage / 100);
        stakesMapping[_msgSender()].rewardsTaken += amount_;
        rewardsTaken += amount_;

        emit RewardTaken(_msgSender(), amount_);
    }

    function _takeReward(uint256 amount_,
                            address[] memory expectedTokens_,
                            uint256[] memory percentages_,
                            bool autoStake_) private {

        require(affiliateMapping[_msgSender()].valid); // TODO Is it need or not
        require(0 != expectedTokens_.length, 'lenght of array cannot be 0');
        require(expectedTokens_.length == percentages_.length,
                            'expectedTokens and percentages lenght must be the same');
        uint256 ownerAmount = amount_ * affiliateMapping[_msgSender()].ownerPercentage / 100;
        uint256 affiliateAmount = amount_ * affiliateMapping[_msgSender()].percentage / 100;
        uint256 amount = amount_ - affiliateAmount - ownerAmount;
        uint256 sum = 0;
        uint256 pSum = 0;
        for (uint256 i = 0; i < expectedTokens_.length - 1; ++i) {
            require(address(0x0) != expectedTokens_[i], 'expected token cannot be null');
            require(0 != percentages_[i], 'percentage cannot be 0');
            uint256 am = amount * percentages_[i] / 100;
            if (expectedTokens_[i] == address(pvtToken)) {
                _mintPVTToken(am, autoStake_);
            } else {
                _delegateTakeRewardIfNeeded(_msgSender(), expectedTokens_[i], am);
            }
            sum += am;
            pSum += percentages_[i];
        }
        require(address(0x0) != expectedTokens_[expectedTokens_.length - 1], 'expected token cannot be null');
        require(0 != percentages_[percentages_.length - 1], 'percentage cannot be 0');
        require(100 == pSum + percentages_[percentages_.length - 1], 'sum of percentages must be 100');
        if (expectedTokens_[expectedTokens_.length - 1] == address(pvtToken)) {
            _mintPVTToken(amount - sum, autoStake_);
        } else {
            _delegateTakeRewardIfNeeded(_msgSender(), expectedTokens_[expectedTokens_.length - 1], amount - sum);
        }
        _distributeReward(ownerAmount + affiliateAmount, ownerAmount,
                            affiliateMapping[_msgSender()].affiliateAddress, affiliateAmount);
        stakesMapping[_msgSender()].rewardsTaken += amount_;
        rewardsTaken += amount_;

        emit RewardTaken(_msgSender(), amount_);
    }

    function _distributeReward(uint256 totalAmount_,
                               uint256 ownerAmount_,
                               address affiliateAddress_,
                               uint256 affiliateAmount_) private {

        _delegateTakeRewardIfNeeded(_msgSender(), strategy.vaultTokenAddress(),
                                   totalAmount_ - ownerAmount_ - affiliateAmount_);
        if (address(0x0) == affiliateAddress_) {
            _delegateTakeRewardIfNeeded(defaultAffiliate,
                                        strategy.vaultTokenAddress(),
                                        affiliateAmount_ + ownerAmount_);
        } else {
            _delegateTakeRewardIfNeeded(defaultAffiliate, strategy.vaultTokenAddress(), ownerAmount_);
            _delegateTakeRewardIfNeeded(affiliateAddress_, strategy.vaultTokenAddress(), affiliateAmount_);
        }
    }

    function _delegateTakeRewardIfNeeded(address address_, address expectedToken_, uint256 amount_) private {

        if (0 != amount_) {
            (bool success,) = address(strategy).delegatecall(
                                        abi.encodeWithSignature('takeReward(address,address,uint256)',
                                        address_, expectedToken_, amount_));
            require(success, 'Delegate call takeReward failed');
        }
    }

    function _reset() private {

        affiliatePercentage = 10;
        ownerPercentage = 5;
        changeTokenRate(RATE_COEF);
        for (uint256 i = 0; i < stakersLookup.length; ++i) {
            address s = stakersLookup[i];
            stakesMapping[s].lastBlockNumber = 0;
            stakesMapping[s].pvtAmount = 0;
            stakesMapping[s].lastTotalWork = 0;
            stakesMapping[s].rewardsTaken = 0;

            affiliateMapping[s].affiliateAddress = address(0x0);
            affiliateMapping[s].percentage = 0;
            affiliateMapping[s].ownerPercentage = 0;
            affiliateMapping[s].valid = false;
        }
        delete stakersLookup;
        ownerStake.pvtAmount = 0;
        ownerStake.lastBlockNumber = 0;
        ownerStake.lastTotalWork = 0;
        ownerStake.rewardsTaken = 0;
        totalStableTokenAmount = 0;
        lastBlockNumber = block.number;
        lastTotalWork = 0;
        rewardsTaken = 0;
        totalPVTAmount = 0;
    }
}