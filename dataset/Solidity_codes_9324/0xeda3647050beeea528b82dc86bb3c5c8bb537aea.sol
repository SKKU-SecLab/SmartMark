
pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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
}// MIT

pragma solidity ^0.8.0;


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.1;

library AddressUpgradeable {

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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {

        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {

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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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


    uint256[45] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC20BurnableUpgradeable is Initializable, ContextUpgradeable, ERC20Upgradeable {
    function __ERC20Burnable_init() internal onlyInitializing {
    }

    function __ERC20Burnable_init_unchained() internal onlyInitializing {
    }
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

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

}// MIT

pragma solidity ^0.8.0;


interface IERC721EnumerableUpgradeable is IERC721Upgradeable {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

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

}// contracts/IDebtCity.sol

pragma solidity ^0.8.0;



interface IDebtCity is IERC721 {

    function getPayForBanker(uint256 _tokenId) external view returns (uint8);

}// contracts/IDebtCity.sol

pragma solidity ^0.8.0;



interface IProperty is IERC721 {

    function getPayForProperty(uint256 _tokenId) external view returns (uint8);

}// contracts/Paper.sol
pragma solidity ^0.8.0;




contract Paper is ERC20BurnableUpgradeable, OwnableUpgradeable {



    using SafeMathUpgradeable for uint256;

    address nullAddress;

    address public debtCityAddress;
    address public propertyAddress;


    struct Loan {
        uint256 loanTime;
        uint256 loanPeriod;
        bool exists;
    }


    mapping(uint256 => uint256) internal bankerIdToTimeStamp;
    mapping(uint256 => address) internal bankerIdToStaker;
    mapping(address => uint256[]) internal stakerToBankerIds;
    mapping(uint256 => Loan) internal bankerIdToLoanTime;

    mapping(uint256 => uint256) internal propIdToTimeStamp;
    mapping(uint256 => address) internal propIdToStaker;
    mapping(address => uint256[]) internal stakerToPropIds;


    function initialize() initializer public {

        __Ownable_init();
        __ERC20_init("Paper", "PAPER-DC");
        nullAddress = 0x0000000000000000000000000000000000000000;
    }


    function setPaperAddresses(address _debtCityAddress, address _propertyAddress) public onlyOwner {

        debtCityAddress = _debtCityAddress;
        propertyAddress = _propertyAddress;
        return;
    }




    function remove(address staker, uint256 index) internal {

        if (index >= stakerToBankerIds[staker].length) return;

        for (uint256 i = index; i < stakerToBankerIds[staker].length - 1; i++) {
            stakerToBankerIds[staker][i] = stakerToBankerIds[staker][i + 1];
        }
        stakerToBankerIds[staker].pop();
    }

    function removeBankerIdFromStaker(address staker, uint256 bankerId) internal {

        for (uint256 i = 0; i < stakerToBankerIds[staker].length; i++) {
            if (stakerToBankerIds[staker][i] == bankerId) {
                remove(staker, i);
            }
        }
    }


    function removeProp(address staker, uint256 index) internal {

        if (index >= stakerToPropIds[staker].length) return;

        for (uint256 i = index; i < stakerToPropIds[staker].length - 1; i++) {
            stakerToPropIds[staker][i] = stakerToPropIds[staker][i + 1];
        }
        stakerToPropIds[staker].pop();
    }

    function removePropIdFromStaker(address staker, uint256 bankerId) internal {

        for (uint256 i = 0; i < stakerToPropIds[staker].length; i++) {
            if (stakerToPropIds[staker][i] == bankerId) {
                removeProp(staker, i);
            }
        }
    }

    


    function stakePropertyByIds(uint256[] memory propIds) public {

        
        for (uint256 i = 0; i < propIds.length; i++) {
            uint256 propId = propIds[i];

            require(
                IERC721(propertyAddress).ownerOf(propId) == msg.sender &&
                    propIdToStaker[propId] == nullAddress,
                "Property must be stakable by you!"
            );

            IERC721(propertyAddress).transferFrom(
                msg.sender,
                address(this),
                propId
            );

            stakerToPropIds[msg.sender].push(propId);

            propIdToTimeStamp[propId] = block.timestamp;
            propIdToStaker[propId] = msg.sender;

        }
    }

    function simpleStakeByIds(uint256[] memory bankerIds) public {


        for (uint256 i = 0; i < bankerIds.length; i++) {
            uint256 bankerId = bankerIds[i];
            require(
                IERC721(debtCityAddress).ownerOf(bankerId) == msg.sender &&
                    bankerIdToStaker[bankerId] == nullAddress,
                "Banker must be stakable by you!"
            );

            IERC721(debtCityAddress).transferFrom(
                msg.sender,
                address(this),
                bankerId
            );

            stakerToBankerIds[msg.sender].push(bankerId);

            bankerIdToTimeStamp[bankerId] = block.timestamp;
            bankerIdToStaker[bankerId] = msg.sender;

            bankerIdToLoanTime[bankerId] = Loan(0, 0, false);
        }
    }




    function loanStakeByIds(uint256[] memory bankerIds, uint256 numLoanDays) public {


        uint256 totalRewards = 0;

        require(
            numLoanDays > 0 && numLoanDays <= 5,
            "Max number of loan days is 5"
        );

        for (uint256 i = 0; i < bankerIds.length; i++) {
            uint256 bankerId = bankerIds[i];

            if (IERC721(debtCityAddress).ownerOf(bankerId) == msg.sender) {
                IERC721(debtCityAddress).transferFrom(
                    msg.sender,
                    address(this),
                    bankerId
                );

                stakerToBankerIds[msg.sender].push(bankerId);

                bankerIdToTimeStamp[bankerId] = block.timestamp;
                bankerIdToStaker[bankerId] = msg.sender;

                bankerIdToLoanTime[bankerId] = Loan(0, 0, false);
            }

            require(
                IERC721(debtCityAddress).ownerOf(bankerId) == address(this) &&
                    bankerIdToStaker[bankerId] == msg.sender,
                "Banker must be stakable by you!"
            );

            require (bankerIdToLoanTime[bankerId].exists == false, "Cannot loan a banker thats already loaned out");

            uint256 loanPeriod = numLoanDays; 
            bankerIdToLoanTime[bankerId] = Loan(block.timestamp, loanPeriod, true);

            uint8 pay_rate = IDebtCity(debtCityAddress).getPayForBanker(bankerId);

            totalRewards = totalRewards + ((loanPeriod) * (pay_rate * 2));

        }

        _mint(msg.sender, totalRewards);

    }



    function unstakeAllProps() public {

        require(
            stakerToPropIds[msg.sender].length > 0,
            "Must have at least one property staked!"
        );

        uint256 totalRewards = 0;

        for (uint256 i = stakerToPropIds[msg.sender].length; i > 0; i--) {
            uint256 propId = stakerToPropIds[msg.sender][i - 1];

            require(
                propIdToStaker[propId] == msg.sender,
                "Message Sender was not original property staker!"
            );

            uint8 pay_rate = IProperty(propertyAddress).getPayForProperty(propId);
            uint256 stakeTime = block.timestamp - propIdToTimeStamp[propId];
            uint256 daysStaked = stakeTime / 86400;

            uint256 propReward = daysStaked * pay_rate;

            IERC721(propertyAddress).transferFrom(
                address(this),
                msg.sender,
                propId
            );

            totalRewards = totalRewards + propReward;
            removePropIdFromStaker(msg.sender, propId);
            propIdToStaker[propId] = nullAddress;

        }

        _mint(msg.sender, totalRewards);
    }


    function unstakePropsByIds(uint256[] memory propIds) public {

        uint256 totalRewards = 0;

        for (uint256 i = 0; i < propIds.length; i++) {
            
            uint256 propId = propIds[i];

            require(
                propIdToStaker[propId] == msg.sender,
                "Message Sender was not original property staker!"
            );

            uint8 pay_rate = IProperty(propertyAddress).getPayForProperty(propId);
            uint256 stakeTime = block.timestamp - propIdToTimeStamp[propId];
            uint256 daysStaked = stakeTime / 86400;
            uint256 propReward = daysStaked * pay_rate;

            IERC721(propertyAddress).transferFrom(
                address(this),
                msg.sender,
                propId
            );

            totalRewards = totalRewards + propReward;

            removePropIdFromStaker(msg.sender, propId);
            propIdToStaker[propId] = nullAddress;
        }

         _mint(msg.sender, totalRewards);
    }



    function unstakeAllBankers() public {

        require(
            stakerToBankerIds[msg.sender].length > 0,
            "Must have at least one banker staked!"
        );
        uint256 totalRewards = 0;

        for (uint256 i = stakerToBankerIds[msg.sender].length; i > 0; i--) {
            uint256 bankerId = stakerToBankerIds[msg.sender][i - 1];

            require(
                bankerIdToStaker[bankerId] == msg.sender,
                "Message sender was not original staker!"
            );

            Loan memory l = bankerIdToLoanTime[bankerId];
            uint256 loanTime = l.loanTime;
            uint256 loanPeriod = l.loanPeriod;
            uint256 loanPeriodSeconds = loanPeriod * 86400;

            require(block.timestamp > (loanTime + loanPeriodSeconds), "Must have loaned banker for full loan time period");

            uint256 rewardTime;

            if (loanTime > 0) {
                rewardTime = (loanTime - bankerIdToTimeStamp[bankerId]) + (block.timestamp - (loanTime + loanPeriodSeconds));
            } else { 
                rewardTime = block.timestamp - bankerIdToTimeStamp[bankerId];
            }

            uint8 pay_rate = IDebtCity(debtCityAddress).getPayForBanker(bankerId);
            uint256 rewardDays = rewardTime / 86400;
            uint256 bankerReward = (rewardDays * pay_rate) - 5;

            require (bankerReward > 0, "must have staked for at least a day to unstake");

            IERC721(debtCityAddress).transferFrom(
                address(this),
                msg.sender,
                bankerId
            );

            totalRewards = totalRewards + bankerReward;

            removeBankerIdFromStaker(msg.sender, bankerId);

            bankerIdToStaker[bankerId] = nullAddress;
            bankerIdToLoanTime[bankerId] = Loan(0, 0, false);
        }

        _mint(msg.sender, totalRewards);
    }



    function unstakeByIds(uint256[] memory bankerIds) public {

        uint256 totalRewards = 0;

        for (uint256 i = 0; i < bankerIds.length; i++) {
            
            uint256 bankerId = bankerIds[i];

            require(
                bankerIdToStaker[bankerId] == msg.sender,
                "Message sender was not original staker!"
            );

            Loan memory l = bankerIdToLoanTime[bankerId];
            uint256 loanTime = l.loanTime;
            uint256 loanPeriod = l.loanPeriod;
            uint256 loanPeriodSeconds = loanPeriod * 86400;

            require(block.timestamp > (loanTime + loanPeriodSeconds), "Must have loaned banker for full loan time seconds");

            uint256 rewardTime;

            if (loanTime > 0) {
                rewardTime = (loanTime - bankerIdToTimeStamp[bankerId]) + (block.timestamp - (loanTime + loanPeriodSeconds));
            } else {
                rewardTime = block.timestamp - bankerIdToTimeStamp[bankerId];
            }

            uint8 pay_rate = IDebtCity(debtCityAddress).getPayForBanker(bankerId);
            uint256 rewardDays = rewardTime / 86400;
            uint256 bankerReward = (rewardDays * pay_rate) - 5;

            require (bankerReward > 0, "must have staked for at least a day to unstake");

            IERC721(debtCityAddress).transferFrom(
                address(this),
                msg.sender,
                bankerId
            );

            totalRewards = totalRewards + bankerReward;

            removeBankerIdFromStaker(msg.sender, bankerId);

            bankerIdToStaker[bankerId] = nullAddress;
            bankerIdToLoanTime[bankerId] = Loan(0, 0, false);
        }

        _mint(msg.sender, totalRewards);
    }





    function claimBankersById(uint256[] memory bankerIds) public {


        uint256 totalRewards = 0;

        for (uint256 i = 0; i < bankerIds.length; i++) {
            
            uint256 bankerId = bankerIds[i];

            require(
                bankerIdToStaker[bankerId] == msg.sender,
                "Message sender was not original staker!"
            );

            Loan memory l = bankerIdToLoanTime[bankerId];
            uint256 loanTime = l.loanTime;
            uint256 loanPeriod = l.loanPeriod;
            uint256 loanPeriodSeconds = loanPeriod * 86400;

            require(block.timestamp > (loanTime + loanPeriodSeconds), "Must have loaned banker for full loan time seconds");

            uint256 rewardTime;

            if (loanTime > 0) {
                rewardTime = (loanTime - bankerIdToTimeStamp[bankerId]) + (block.timestamp - (loanTime + loanPeriodSeconds));
            } else {
                rewardTime = block.timestamp - bankerIdToTimeStamp[bankerId];
            }

            uint8 pay_rate = IDebtCity(debtCityAddress).getPayForBanker(bankerId);
            uint256 rewardDays = rewardTime / 86400;

            require (rewardDays > 0, "must have staked for at least a day to claim anything");

            totalRewards += (rewardDays * pay_rate);
            bankerIdToTimeStamp[bankerId] = block.timestamp;
            bankerIdToLoanTime[bankerId] = Loan(0, 0, false);
        }

        _mint(msg.sender, totalRewards);
    }


    function claimPropsById(uint256[] memory propIds) public {


        uint256 totalRewards = 0;

        for (uint256 i = 0; i < propIds.length; i++) {
            uint256 propId = propIds[i];

            require(
                propIdToStaker[propId] == msg.sender,
                "Message sender was not original staker!"
            );

            uint8 pay_rate = IProperty(propertyAddress).getPayForProperty(propId);
            uint256 claimTime = block.timestamp - propIdToTimeStamp[propId];
            uint256 daysStaked = claimTime / 86400;

            require (daysStaked > 0, "must have staked for at least a day to claim anything");

            totalRewards = totalRewards + (daysStaked * pay_rate);
            propIdToTimeStamp[propId] = block.timestamp;
        }
        
        _mint(msg.sender, totalRewards);

    }


    function claimAllRewards() public {


        require(
            stakerToBankerIds[msg.sender].length > 0 || stakerToPropIds[msg.sender].length > 0,
            "Must have at least one banker or prop staked!"
        );

        uint256 totalRewards = 0;

        for (uint256 i = stakerToBankerIds[msg.sender].length; i > 0; i--) {
            uint256 bankerId = stakerToBankerIds[msg.sender][i - 1];

            require(
                bankerIdToStaker[bankerId] == msg.sender,
                "Message sender was not original staker!"
            );

            Loan memory l = bankerIdToLoanTime[bankerId];
            uint256 loanTime = l.loanTime;
            uint256 loanPeriod = l.loanPeriod;
            uint256 loanPeriodSeconds = loanPeriod * 86400;

            if (block.timestamp > (loanTime + loanPeriodSeconds)) {
                
                uint256 rewardTime;

                if (loanTime > 0) {
                    rewardTime = (loanTime - bankerIdToTimeStamp[bankerId]) + (block.timestamp - (loanTime + loanPeriodSeconds));
                } else {
                    rewardTime = block.timestamp - bankerIdToTimeStamp[bankerId];
                }

                uint8 pay_rate = IDebtCity(debtCityAddress).getPayForBanker(bankerId);
                uint256 rewardDays = rewardTime / 86400;

                if (rewardDays > 0) {
                    totalRewards = totalRewards + (rewardDays * pay_rate);
                    bankerIdToTimeStamp[bankerId] = block.timestamp;
                    bankerIdToLoanTime[bankerId] = Loan(0, 0, false);
                }

            }
            
        }


        for (uint256 i = stakerToPropIds[msg.sender].length; i > 0; i--) {
            uint256 propId = stakerToPropIds[msg.sender][i - 1];

            require(
                propIdToStaker[propId] == msg.sender,
                "Message sender was not original staker!"
            );

            uint8 pay_rate = IProperty(propertyAddress).getPayForProperty(propId);
            uint256 claimTime = block.timestamp - propIdToTimeStamp[propId];
            uint256 daysStaked = claimTime / 86400;

            if (daysStaked > 0) {
                totalRewards = totalRewards + (daysStaked * pay_rate);
                propIdToTimeStamp[propId] = block.timestamp;
            }
            

        }


        _mint(msg.sender, totalRewards);
    }






    function getBankersStaked(address staker)
        public
        view
        returns (uint256[] memory)
    {

        return stakerToBankerIds[staker];
    }


    function getBankersLoaned(address staker)
        public
        view
        returns (uint256[] memory)
    {


        uint256[] memory loanBankers = new uint256[](stakerToBankerIds[staker].length);

        for (uint256 i = 0; i < stakerToBankerIds[staker].length; i++) {
            uint256 bankerId = stakerToBankerIds[staker][i];

            Loan memory l = bankerIdToLoanTime[bankerId];
            uint256 loanTime = l.loanTime;
            uint256 loanPeriod = l.loanPeriod;

            if (loanTime > 0 && loanPeriod > 0) {
                loanBankers[i] = bankerId;
            }

        }

        return loanBankers;
    }

    function getPropsStaked(address staker)
        public
        view
        returns (uint256[] memory)
    {

        return stakerToPropIds[staker];
    }


    function getRewardsByBankerId(uint256 bankerId)
        public
        view
        returns (uint256)
    {

        require(
            bankerIdToStaker[bankerId] != nullAddress,
            "Banker is not staked!"
        );


        Loan memory l = bankerIdToLoanTime[bankerId];
        uint256 loanTime = l.loanTime;
        uint256 loanPeriod = l.loanPeriod;
        uint256 loanPeriodSeconds = loanPeriod * 86400;

        require(block.timestamp > (loanTime + loanPeriodSeconds), "Banker is still loan time locked so there is no current rewards");

        uint256 rewardTime;

        if (loanTime > 0) {
            rewardTime = (loanTime - bankerIdToTimeStamp[bankerId]) + (block.timestamp - (loanTime + loanPeriodSeconds));
        } else {
            rewardTime = block.timestamp - bankerIdToTimeStamp[bankerId];
        }

        uint8 pay_rate = IDebtCity(debtCityAddress).getPayForBanker(bankerId);

        uint256 rewardDays = rewardTime / 86400;
        uint256 totalRewards = rewardDays * pay_rate;

        return totalRewards;
    }


    function getRewardsByPropertyId(uint256 propId)
        public
        view
        returns (uint256)
    {

        require(
            propIdToStaker[propId] != nullAddress,
            "Property is not staked!"
        );

        uint256 secondsStaked = block.timestamp - propIdToTimeStamp[propId];
        uint256 daysStaked = secondsStaked / 86400;

        uint8 pay_rate = IProperty(propertyAddress).getPayForProperty(propId);

        return (pay_rate * daysStaked);
    }

    

    function getStaker(uint256 bankerId) public view returns (address) {

        return bankerIdToStaker[bankerId];
    }





    function burnFrom(address account, uint256 amount) public virtual override {

        uint256 currentAllowance = allowance(account, _msgSender());

        if (_msgSender() != address(propertyAddress)) {
            require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        }

        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }

}