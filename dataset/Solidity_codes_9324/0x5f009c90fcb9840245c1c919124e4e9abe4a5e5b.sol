
pragma solidity 0.7.6;

library LowGasSafeMath {

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x);
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x);
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(x == 0 || (z = x * y) / x == y);
    }

    function add(int256 x, int256 y) internal pure returns (int256 z) {

        require((z = x + y) >= x == (y >= 0));
    }

    function sub(int256 x, int256 y) internal pure returns (int256 z) {

        require((z = x - y) <= x == (y >= 0));
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, 'SafeMath: division by zero');
        return a / b;
    }
}/*
    Copyright 2021 Babylon Finance.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    Apache License, Version 2.0
*/
pragma solidity 0.7.6;

interface IBabController {


    function createGarden(
        address _reserveAsset,
        string memory _name,
        string memory _symbol,
        string memory _tokenURI,
        uint256 _seed,
        uint256[] calldata _gardenParams,
        uint256 _initialContribution,
        bool[] memory _publicGardenStrategistsStewards
    ) external payable returns (address);


    function removeGarden(address _garden) external;


    function addReserveAsset(address _reserveAsset) external;


    function removeReserveAsset(address _reserveAsset) external;


    function disableGarden(address _garden) external;


    function editPriceOracle(address _priceOracle) external;


    function editIshtarGate(address _ishtarGate) external;


    function editGardenValuer(address _gardenValuer) external;


    function editRewardsDistributor(address _rewardsDistributor) external;


    function editTreasury(address _newTreasury) external;


    function editGardenFactory(address _newGardenFactory) external;


    function editGardenNFT(address _newGardenNFT) external;


    function editStrategyNFT(address _newStrategyNFT) external;


    function editStrategyFactory(address _newStrategyFactory) external;


    function addIntegration(string memory _name, address _integration) external;


    function editIntegration(string memory _name, address _integration) external;


    function removeIntegration(string memory _name) external;


    function setOperation(uint8 _kind, address _operation) external;


    function setDefaultTradeIntegration(address _newDefaultTradeIntegation) external;


    function addKeeper(address _keeper) external;


    function addKeepers(address[] memory _keepers) external;


    function removeKeeper(address _keeper) external;


    function enableGardenTokensTransfers() external;


    function enableBABLMiningProgram() external;


    function setAllowPublicGardens() external;


    function editLiquidityReserve(address _reserve, uint256 _minRiskyPairLiquidityEth) external;


    function maxContributorsPerGarden() external view returns (uint256);


    function gardenCreationIsOpen() external view returns (bool);


    function openPublicGardenCreation() external;


    function setMaxContributorsPerGarden(uint256 _newMax) external;


    function owner() external view returns (address);


    function guardianGlobalPaused() external view returns (bool);


    function guardianPaused(address _address) external view returns (bool);


    function setPauseGuardian(address _guardian) external;


    function setGlobalPause(bool _state) external returns (bool);


    function setSomePause(address[] memory _address, bool _state) external returns (bool);


    function isPaused(address _contract) external view returns (bool);


    function priceOracle() external view returns (address);


    function gardenValuer() external view returns (address);


    function gardenNFT() external view returns (address);


    function strategyNFT() external view returns (address);


    function rewardsDistributor() external view returns (address);


    function gardenFactory() external view returns (address);


    function treasury() external view returns (address);


    function ishtarGate() external view returns (address);


    function strategyFactory() external view returns (address);


    function defaultTradeIntegration() external view returns (address);


    function gardenTokensTransfersEnabled() external view returns (bool);


    function bablMiningProgramEnabled() external view returns (bool);


    function allowPublicGardens() external view returns (bool);


    function enabledOperations(uint256 _kind) external view returns (address);


    function getProfitSharing()
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );


    function getBABLSharing()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );


    function getGardens() external view returns (address[] memory);


    function getOperations() external view returns (address[20] memory);


    function isGarden(address _garden) external view returns (bool);


    function getIntegrationByName(string memory _name) external view returns (address);


    function getIntegrationWithHash(bytes32 _nameHashP) external view returns (address);


    function isValidReserveAsset(address _reserveAsset) external view returns (bool);


    function isValidKeeper(address _keeper) external view returns (bool);


    function isSystemContract(address _contractAddress) external view returns (bool);


    function isValidIntegration(string memory _name, address _integration) external view returns (bool);


    function getMinCooldownPeriod() external view returns (uint256);


    function getMaxCooldownPeriod() external view returns (uint256);


    function protocolPerformanceFee() external view returns (uint256);


    function protocolManagementFee() external view returns (uint256);


    function minLiquidityPerReserve(address _reserve) external view returns (uint256);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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

pragma solidity >=0.6.2 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20 {

    using SafeMath for uint256;
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

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}/*
    Copyright 2020 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    Apache License, Version 2.0
*/

pragma solidity 0.7.6;

library AddressArrayUtils {

    function indexOf(address[] memory A, address a) internal pure returns (uint256, bool) {

        uint256 length = A.length;
        for (uint256 i = 0; i < length; i++) {
            if (A[i] == a) {
                return (i, true);
            }
        }
        return (uint256(-1), false);
    }

    function contains(address[] memory A, address a) internal pure returns (bool) {

        (, bool isIn) = indexOf(A, a);
        return isIn;
    }

    function hasDuplicate(address[] memory A) internal pure returns (bool) {

        require(A.length > 0, 'A is empty');

        for (uint256 i = 0; i < A.length - 1; i++) {
            address current = A[i];
            for (uint256 j = i + 1; j < A.length; j++) {
                if (current == A[j]) {
                    return true;
                }
            }
        }
        return false;
    }

    function remove(address[] memory A, address a) internal pure returns (address[] memory) {

        (uint256 index, bool isIn) = indexOf(A, a);
        if (!isIn) {
            revert('Address not in array.');
        } else {
            (address[] memory _A, ) = pop(A, index);
            return _A;
        }
    }

    function pop(address[] memory A, uint256 index) internal pure returns (address[] memory, address) {

        uint256 length = A.length;
        require(index < A.length, 'Index must be < A length');
        address[] memory newAddresses = new address[](length - 1);
        for (uint256 i = 0; i < index; i++) {
            newAddresses[i] = A[i];
        }
        for (uint256 j = index + 1; j < length; j++) {
            newAddresses[j - 1] = A[j];
        }
        return (newAddresses, A[index]);
    }

    function extend(address[] memory A, address[] memory B) internal pure returns (address[] memory) {

        uint256 aLength = A.length;
        uint256 bLength = B.length;
        address[] memory newAddresses = new address[](aLength + bLength);
        for (uint256 i = 0; i < aLength; i++) {
            newAddresses[i] = A[i];
        }
        for (uint256 j = 0; j < bLength; j++) {
            newAddresses[aLength + j] = B[j];
        }
        return newAddresses;
    }
}/*
    Copyright 2021 Babylon Finance.
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    Apache License, Version 2.0
*/

pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;




contract TimeLockRegistry is Ownable {

    using LowGasSafeMath for uint256;
    using Address for address;
    using AddressArrayUtils for address[];


    event Register(address receiver, uint256 distribution);
    event Cancel(address receiver, uint256 distribution);
    event Claim(address account, uint256 distribution);


    modifier onlyBABLToken() {

        require(msg.sender == address(token), 'only BABL Token');
        _;
    }


    TimeLockedToken public token;

    struct Registration {
        address receiver;
        uint256 distribution;
        bool investorType;
        uint256 vestingStartingDate;
    }

    struct TokenVested {
        bool team;
        bool cliff;
        uint256 vestingBegin;
        uint256 vestingEnd;
        uint256 lastClaim;
    }

    mapping(address => TokenVested) public tokenVested;

    mapping(address => uint256) public registeredDistributions;

    address[] public registrations;

    uint256 public totalTokens;

    uint256 private constant teamVesting = 365 days * 4;

    uint256 private constant investorVesting = 365 days * 3;



    constructor(TimeLockedToken _token) {
        token = _token;
    }




    function getRegistrations() external view returns (address[] memory) {

        return registrations;
    }


    function registerBatch(Registration[] memory _registrations) external onlyOwner {

        for (uint256 i = 0; i < _registrations.length; i++) {
            register(
                _registrations[i].receiver,
                _registrations[i].distribution,
                _registrations[i].investorType,
                _registrations[i].vestingStartingDate
            );
        }
    }

    function register(
        address receiver,
        uint256 distribution,
        bool investorType,
        uint256 vestingStartingDate
    ) public onlyOwner {

        require(receiver != address(0), 'TimeLockRegistry::register: cannot register the zero address');
        require(
            receiver != address(this),
            'TimeLockRegistry::register: Time Lock Registry contract cannot be an investor'
        );
        require(distribution != 0, 'TimeLockRegistry::register: Distribution = 0');
        require(
            registeredDistributions[receiver] == 0,
            'TimeLockRegistry::register:Distribution for this address is already registered'
        );
        require(block.timestamp >= 1614553200, 'Cannot register earlier than March 2021'); // 1614553200 is UNIX TIME of 2021 March the 1st
        require(totalTokens.add(distribution) <= IERC20(token).balanceOf(address(this)), 'Not enough tokens');

        totalTokens = totalTokens.add(distribution);
        registeredDistributions[receiver] = distribution;
        registrations.push(receiver);

        TokenVested storage newTokenVested = tokenVested[receiver];
        newTokenVested.team = investorType;
        newTokenVested.vestingBegin = vestingStartingDate;

        if (newTokenVested.team == true) {
            newTokenVested.vestingEnd = vestingStartingDate.add(teamVesting);
        } else {
            newTokenVested.vestingEnd = vestingStartingDate.add(investorVesting);
        }
        newTokenVested.lastClaim = vestingStartingDate;

        tokenVested[receiver] = newTokenVested;

        emit Register(receiver, distribution);
    }

    function cancelRegistration(address receiver) external onlyOwner returns (bool) {

        require(registeredDistributions[receiver] != 0, 'Not registered');

        uint256 amount = registeredDistributions[receiver];

        delete registeredDistributions[receiver];

        delete tokenVested[receiver];

        registrations.remove(receiver);

        totalTokens = totalTokens.sub(amount);

        emit Cancel(receiver, amount);

        return true;
    }

    function cancelDeliveredTokens(address account) external onlyOwner returns (bool) {

        uint256 loosingAmount = token.cancelVestedTokens(account);

        emit Cancel(account, loosingAmount);
        return true;
    }

    function transferToOwner(uint256 amount) external onlyOwner returns (bool) {

        SafeERC20.safeTransfer(token, msg.sender, amount);
        return true;
    }

    function claim(address _receiver) external onlyBABLToken returns (uint256) {

        require(registeredDistributions[_receiver] != 0, 'Not registered');

        uint256 amount = registeredDistributions[_receiver];
        TokenVested storage claimTokenVested = tokenVested[_receiver];

        claimTokenVested.lastClaim = block.timestamp;

        delete registeredDistributions[_receiver];

        totalTokens = totalTokens.sub(amount);

        token.registerLockup(
            _receiver,
            amount,
            claimTokenVested.team,
            claimTokenVested.vestingBegin,
            claimTokenVested.vestingEnd,
            claimTokenVested.lastClaim
        );

        delete tokenVested[_receiver];

        emit Claim(_receiver, amount);

        return amount;
    }


    function checkVesting(address address_)
        external
        view
        returns (
            bool team,
            uint256 start,
            uint256 end,
            uint256 last
        )
    {

        TokenVested storage checkTokenVested = tokenVested[address_];

        return (
            checkTokenVested.team,
            checkTokenVested.vestingBegin,
            checkTokenVested.vestingEnd,
            checkTokenVested.lastClaim
        );
    }

    function checkRegisteredDistribution(address address_) external view returns (uint256 amount) {

        return registeredDistributions[address_];
    }
}/*
    Copyright 2021 Babylon Finance.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    Apache License, Version 2.0
*/

pragma solidity 0.7.6;


interface IRewardsDistributor {

    struct PrincipalPerTimestamp {
        uint256 principal;
        uint256 time;
        uint256 timeListPointer;
    }

    function protocolPrincipal() external view returns (uint256);


    function pid() external view returns (uint256);


    function EPOCH_DURATION() external pure returns (uint256);


    function START_TIME() external view returns (uint256);


    function Q1_REWARDS() external pure returns (uint256);


    function DECAY_RATE() external pure returns (uint256);


    function updateProtocolPrincipal(uint256 _capital, bool _addOrSubstract) external;


    function getStrategyRewards(address _strategy) external view returns (uint96);


    function sendTokensToContributor(address _to, uint256 _amount) external;


    function startBABLRewards() external;


    function getRewards(
        address _garden,
        address _contributor,
        address[] calldata _finalizedStrategies
    ) external view returns (uint256[] memory);


    function getContributorPower(
        address _garden,
        address _contributor,
        uint256 _from,
        uint256 _to
    ) external view returns (uint256);


    function updateGardenPowerAndContributor(
        address _garden,
        address _contributor,
        uint256 _previousBalance,
        bool _depositOrWithdraw,
        uint256 _pid
    ) external;


    function tokenSupplyPerQuarter(uint256 quarter) external view returns (uint96);


    function checkProtocol(uint256 _time)
        external
        view
        returns (
            uint256 principal,
            uint256 time,
            uint256 quarterBelonging,
            uint256 timeListPointer,
            uint256 power
        );


    function checkQuarter(uint256 _num)
        external
        view
        returns (
            uint256 quarterPrincipal,
            uint256 quarterNumber,
            uint256 quarterPower,
            uint96 supplyPerQuarter
        );

}// MIT

pragma solidity >=0.6.0 <0.8.0;


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

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
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

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}/*
    Copyright 2021 Babylon Finance.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    Apache License, Version 2.0
*/

pragma solidity 0.7.6;


interface IVoteToken {
    function delegate(address delegatee) external;

    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bool prefix
    ) external;

    function getCurrentVotes(address account) external view returns (uint96);

    function getPriorVotes(address account, uint256 blockNumber) external view returns (uint96);

    function getMyDelegatee() external view returns (address);

    function getDelegatee(address account) external view returns (address);

    function getCheckpoints(address account, uint32 id) external view returns (uint32 fromBlock, uint96 votes);

    function getNumberOfCheckpoints(address account) external view returns (uint32);
}

interface IVoteTokenWithERC20 is IVoteToken, IERC20 {}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}/*
    Copyright 2021 Babylon Finance.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    Apache License, Version 2.0
*/

pragma solidity 0.7.6;



abstract contract VoteToken is Context, ERC20, Ownable, IVoteToken, ReentrancyGuard {
    using LowGasSafeMath for uint256;
    using Address for address;


    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);



    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256('EIP712Domain(string name,uint256 chainId,address verifyingContract)');

    bytes32 public constant DELEGATION_TYPEHASH =
        keccak256('Delegation(address delegatee,uint256 nonce,uint256 expiry)');

    mapping(address => address) public delegates;

    struct Checkpoint {
        uint32 fromBlock;
        uint96 votes;
    }

    mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

    mapping(address => uint32) public numCheckpoints;

    mapping(address => uint256) public nonces;



    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}




    function delegate(address delegatee) external override {
        return _delegate(msg.sender, delegatee);
    }


    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bool prefix
    ) external override {
        address signatory;
        bytes32 domainSeparator =
            keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name())), getChainId(), address(this)));
        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
        bytes32 digest = keccak256(abi.encodePacked('\x19\x01', domainSeparator, structHash));
        if (prefix) {
            bytes32 digestHash = keccak256(abi.encodePacked('\x19Ethereum Signed Message:\n32', digest));
            signatory = ecrecover(digestHash, v, r, s);
        } else {
            signatory = ecrecover(digest, v, r, s);
        }

        require(balanceOf(signatory) > 0, 'VoteToken::delegateBySig: invalid delegator');
        require(signatory != address(0), 'VoteToken::delegateBySig: invalid signature');
        require(nonce == nonces[signatory], 'VoteToken::delegateBySig: invalid nonce');
        nonces[signatory]++;
        require(block.timestamp <= expiry, 'VoteToken::delegateBySig: signature expired');
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account) external view virtual override returns (uint96) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint256 blockNumber) external view virtual override returns (uint96) {
        require(blockNumber < block.number, 'BABLToken::getPriorVotes: not yet determined');

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function getMyDelegatee() external view override returns (address) {
        return delegates[msg.sender];
    }

    function getDelegatee(address account) external view override returns (address) {
        return delegates[account];
    }

    function getCheckpoints(address account, uint32 id)
        external
        view
        override
        returns (uint32 fromBlock, uint96 votes)
    {
        Checkpoint storage getCheckpoint = checkpoints[account][id];
        return (getCheckpoint.fromBlock, getCheckpoint.votes);
    }

    function getNumberOfCheckpoints(address account) external view override returns (uint32) {
        return numCheckpoints[account];
    }



    function _delegate(address delegator, address delegatee) internal {
        address currentDelegate = delegates[delegator];
        uint96 delegatorBalance = safe96(_balanceOf(delegator), 'VoteToken::_delegate: uint96 overflow');
        delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _balanceOf(address account) internal view virtual returns (uint256) {
        return balanceOf(account);
    }

    function _moveDelegates(
        address srcRep,
        address dstRep,
        uint96 amount
    ) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint96 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint96 srcRepNew = sub96(srcRepOld, amount, 'VoteToken::_moveDelegates: vote amount underflows');
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }
            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint96 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint96 dstRepNew = add96(dstRepOld, amount, 'VoteToken::_moveDelegates: vote amount overflows');
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint96 oldVotes,
        uint96 newVotes
    ) internal {
        uint32 blockNumber = safe32(block.number, 'VoteToken::_writeCheckpoint: block number exceeds 32 bits');

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function safe96(uint256 n, string memory errorMessage) internal pure returns (uint96) {
        require(n < 2**96, errorMessage);
        return uint96(n);
    }

    function add96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {
        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function getChainId() internal pure returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }
}/*
    Copyright 2021 Babylon Finance.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    Apache License, Version 2.0
*/

pragma solidity 0.7.6;


abstract contract TimeLockedToken is VoteToken {
    using LowGasSafeMath for uint256;


    event NewLockout(
        address account,
        uint256 tokenslocked,
        bool isTeamOrAdvisor,
        uint256 startingVesting,
        uint256 endingVesting
    );

    event NewTimeLockRegistration(address previousAddress, address newAddress);

    event NewRewardsDistributorRegistration(address previousAddress, address newAddress);

    event Cancel(address account, uint256 amount);

    event Claim(address _receiver, uint256 amount);

    event LockedBalance(address _account, uint256 amount);


    modifier onlyTimeLockRegistry() {
        require(
            msg.sender == address(timeLockRegistry),
            'TimeLockedToken:: onlyTimeLockRegistry: can only be executed by TimeLockRegistry'
        );
        _;
    }

    modifier onlyTimeLockOwner() {
        if (address(timeLockRegistry) != address(0)) {
            require(
                msg.sender == Ownable(timeLockRegistry).owner(),
                'TimeLockedToken:: onlyTimeLockOwner: can only be executed by the owner of TimeLockRegistry'
            );
        }
        _;
    }
    modifier onlyUnpaused() {
        _require(!IBabController(controller).isPaused(address(this)), Errors.ONLY_UNPAUSED);
        _;
    }


    mapping(address => uint256) distribution;

    struct VestedToken {
        bool teamOrAdvisor;
        uint256 vestingBegin;
        uint256 vestingEnd;
        uint256 lastClaim;
    }

    mapping(address => VestedToken) public vestedToken;

    IBabController public controller;

    TimeLockRegistry public timeLockRegistry;

    IRewardsDistributor public rewardsDistributor;

    bool private tokenTransfersEnabled;
    bool private tokenTransfersWereDisabled;



    constructor(string memory _name, string memory _symbol) VoteToken(_name, _symbol) {
        tokenTransfersEnabled = true;
    }



    function disableTokensTransfers() external onlyOwner {
        require(!tokenTransfersWereDisabled, 'BABL must flow');
        tokenTransfersEnabled = false;
        tokenTransfersWereDisabled = true;
    }

    function enableTokensTransfers() external onlyOwner {
        tokenTransfersEnabled = true;
    }

    function setTimeLockRegistry(TimeLockRegistry newTimeLockRegistry) external onlyTimeLockOwner returns (bool) {
        require(address(newTimeLockRegistry) != address(0), 'cannot be zero address');
        require(address(newTimeLockRegistry) != address(this), 'cannot be this contract');
        require(address(newTimeLockRegistry) != address(timeLockRegistry), 'must be new TimeLockRegistry');
        emit NewTimeLockRegistration(address(timeLockRegistry), address(newTimeLockRegistry));

        timeLockRegistry = newTimeLockRegistry;

        return true;
    }

    function setRewardsDistributor(IRewardsDistributor newRewardsDistributor) external onlyOwner returns (bool) {
        require(address(newRewardsDistributor) != address(0), 'cannot be zero address');
        require(address(newRewardsDistributor) != address(this), 'cannot be this contract');
        require(address(newRewardsDistributor) != address(rewardsDistributor), 'must be new Rewards Distributor');
        emit NewRewardsDistributorRegistration(address(rewardsDistributor), address(newRewardsDistributor));

        rewardsDistributor = newRewardsDistributor;

        return true;
    }

    function registerLockup(
        address _receiver,
        uint256 _amount,
        bool _profile,
        uint256 _vestingBegin,
        uint256 _vestingEnd,
        uint256 _lastClaim
    ) external onlyTimeLockRegistry returns (bool) {
        require(balanceOf(msg.sender) >= _amount, 'insufficient balance');
        require(_receiver != address(0), 'cannot be zero address');
        require(_receiver != address(this), 'cannot be this contract');
        require(_receiver != address(timeLockRegistry), 'cannot be the TimeLockRegistry contract itself');
        require(_receiver != msg.sender, 'the owner cannot lockup itself');

        distribution[_receiver] = distribution[_receiver].add(_amount);

        VestedToken storage newVestedToken = vestedToken[_receiver];

        newVestedToken.teamOrAdvisor = _profile;
        newVestedToken.vestingBegin = _vestingBegin;
        newVestedToken.vestingEnd = _vestingEnd;
        newVestedToken.lastClaim = _lastClaim;

        _transfer(msg.sender, _receiver, _amount);
        emit NewLockout(_receiver, _amount, _profile, _vestingBegin, _vestingEnd);

        return true;
    }

    function cancelVestedTokens(address lockedAccount) external onlyTimeLockRegistry returns (uint256) {
        return _cancelVestedTokensFromTimeLock(lockedAccount);
    }

    function claimMyTokens() external {
        uint256 amount = timeLockRegistry.claim(msg.sender);
        if (vestedToken[msg.sender].teamOrAdvisor == true) {
            approve(address(timeLockRegistry), amount);
        }
        emit Claim(msg.sender, amount);
    }

    function unlockedBalance(address account) public returns (uint256) {
        return balanceOf(account).sub(lockedBalance(account));
    }


    function viewLockedBalance(address account) public view returns (uint256) {

        uint256 amount = distribution[account];
        uint256 lockedAmount = amount;

        if (vestedToken[account].vestingBegin.add(365 days) > block.timestamp && amount != 0) {
            return lockedAmount;
        }

        if (block.timestamp >= vestedToken[account].vestingEnd || amount == 0) {
            lockedAmount = 0;
        } else if (amount != 0) {
            lockedAmount = amount.mul(vestedToken[account].vestingEnd.sub(block.timestamp)).div(
                vestedToken[account].vestingEnd.sub(vestedToken[account].vestingBegin)
            );
        }
        return lockedAmount;
    }

    function lockedBalance(address account) public returns (uint256) {
        uint256 lockedAmount = viewLockedBalance(account);
        if (
            block.timestamp >= vestedToken[account].vestingEnd &&
            msg.sender == account &&
            lockedAmount == 0 &&
            vestedToken[account].vestingEnd != 0
        ) {
            delete distribution[account];
        }
        emit LockedBalance(account, lockedAmount);
        return lockedAmount;
    }

    function getTimeLockRegistry() external view returns (address) {
        return address(timeLockRegistry);
    }

    function approve(address spender, uint256 rawAmount) public override nonReentrant returns (bool) {
        require(spender != address(0), 'TimeLockedToken::approve: spender cannot be zero address');
        require(spender != msg.sender, 'TimeLockedToken::approve: spender cannot be the msg.sender');

        uint96 amount;
        if (rawAmount == uint256(-1)) {
            amount = uint96(-1);
        } else {
            amount = safe96(rawAmount, 'TimeLockedToken::approve: amount exceeds 96 bits');
        }

        if ((spender == address(timeLockRegistry)) && (amount < allowance(msg.sender, address(timeLockRegistry)))) {
            amount = safe96(
                allowance(msg.sender, address(timeLockRegistry)),
                'TimeLockedToken::approve: cannot decrease allowance to timelockregistry'
            );
        }
        _approve(msg.sender, spender, amount);
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public override nonReentrant returns (bool) {
        require(
            unlockedBalance(msg.sender) >= allowance(msg.sender, spender).add(addedValue) ||
                spender == address(timeLockRegistry),
            'TimeLockedToken::increaseAllowance:Not enough unlocked tokens'
        );
        require(spender != address(0), 'TimeLockedToken::increaseAllowance:Spender cannot be zero address');
        require(spender != msg.sender, 'TimeLockedToken::increaseAllowance:Spender cannot be the msg.sender');
        _approve(msg.sender, spender, allowance(msg.sender, spender).add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public override nonReentrant returns (bool) {
        require(spender != address(0), 'TimeLockedToken::decreaseAllowance:Spender cannot be zero address');
        require(spender != msg.sender, 'TimeLockedToken::decreaseAllowance:Spender cannot be the msg.sender');
        require(
            allowance(msg.sender, spender) >= subtractedValue,
            'TimeLockedToken::decreaseAllowance:Underflow condition'
        );

        require(
            address(spender) != address(timeLockRegistry),
            'TimeLockedToken::decreaseAllowance:cannot decrease allowance to timeLockRegistry'
        );

        _approve(msg.sender, spender, allowance(msg.sender, spender).sub(subtractedValue));
        return true;
    }


    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) internal override onlyUnpaused {
        require(_from != address(0), 'TimeLockedToken:: _transfer: cannot transfer from the zero address');
        require(_to != address(0), 'TimeLockedToken:: _transfer: cannot transfer to the zero address');
        require(
            _to != address(this),
            'TimeLockedToken:: _transfer: do not transfer tokens to the token contract itself'
        );

        require(balanceOf(_from) >= _value, 'TimeLockedToken:: _transfer: insufficient balance');

        require(unlockedBalance(_from) >= _value, 'TimeLockedToken:: _transfer: attempting to transfer locked funds');
        super._transfer(_from, _to, _value);
        _moveDelegates(
            delegates[_from],
            delegates[_to],
            safe96(_value, 'TimeLockedToken:: _transfer: uint96 overflow')
        );
    }


    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _value
    ) internal virtual override {
        super._beforeTokenTransfer(_from, _to, _value);
        _require(
            _from == address(0) ||
                _from == address(timeLockRegistry) ||
                _from == address(rewardsDistributor) ||
                _to == address(timeLockRegistry) ||
                tokenTransfersEnabled,
            Errors.BABL_TRANSFERS_DISABLED
        );
    }

    function _cancelVestedTokensFromTimeLock(address lockedAccount) internal onlyTimeLockRegistry returns (uint256) {
        require(distribution[lockedAccount] != 0, 'TimeLockedToken::cancelTokens:Not registered');

        uint256 loosingAmount = lockedBalance(lockedAccount);

        require(loosingAmount > 0, 'TimeLockedToken::cancelTokens:There are no more locked tokens');
        require(
            vestedToken[lockedAccount].teamOrAdvisor == true,
            'TimeLockedToken::cancelTokens:cannot cancel locked tokens to Investors'
        );

        delete distribution[lockedAccount];

        delete vestedToken[lockedAccount];

        require(
            transferFrom(lockedAccount, address(timeLockRegistry), loosingAmount),
            'TimeLockedToken::cancelTokens:Transfer failed'
        );

        emit Cancel(lockedAccount, loosingAmount);

        return loosingAmount;
    }
}/*
    Copyright 2021 Babylon Finance.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    Apache License, Version 2.0
*/

pragma solidity 0.7.6;


contract BABLToken is TimeLockedToken {
    using LowGasSafeMath for uint256;
    using Address for address;


    event MintedNewTokens(address account, uint256 tokensminted);

    event MaxSupplyChanged(uint256 previousMaxValue, uint256 newMaxValue);

    event MaxSupplyAllowedAfterChanged(uint256 previousAllowedAfterValue, uint256 newAllowedAfterValue);



    string private constant NAME = 'Babylon.Finance';

    string private constant SYMBOL = 'BABL';

    uint256 public maxSupplyAllowed = 1_000_000e18; //

    uint256 public maxSupplyAllowedAfter;

    uint8 public constant MAX_SUPPLY_CAP = 5;

    uint8 public constant MINT_CAP = 2;

    uint256 public mintingAllowedAfter;

    uint256 public BABLTokenDeploymentTimestamp;

    uint32 private constant FIRST_EPOCH_MINT = 365 days * 8;

    uint32 private constant MIN_TIME_BETWEEN_MINTS = 365 days;



    constructor(IBabController newController) TimeLockedToken(NAME, SYMBOL) {
        BABLTokenDeploymentTimestamp = block.timestamp;

        maxSupplyAllowedAfter = block.timestamp.add(FIRST_EPOCH_MINT);

        _mint(msg.sender, 1_000_000e18);

        mintingAllowedAfter = block.timestamp.add(FIRST_EPOCH_MINT);

        controller = newController;
    }



    function mint(address _to, uint256 _amount) external onlyOwner returns (bool) {
        require(totalSupply().add(_amount) <= maxSupplyAllowed, 'BABLToken::mint: max supply exceeded');
        require(
            block.timestamp >= BABLTokenDeploymentTimestamp.add(FIRST_EPOCH_MINT),
            'BABLToken::mint: minting not allowed after the FIRST_EPOCH_MINT has passed >= 8 years'
        );
        require(_amount > 0, 'BABLToken::mint: mint should be higher than zero');
        require(
            block.timestamp >= mintingAllowedAfter,
            'BABLToken::mint: minting not allowed yet because mintingAllowedAfter'
        );
        require(_to != address(0), 'BABLToken::mint: cannot transfer to the zero address');
        require(_to != address(this), 'BABLToken::mint: cannot mint to the address of this contract');

        mintingAllowedAfter = block.timestamp.add(MIN_TIME_BETWEEN_MINTS);

        uint96 amount = safe96(_amount, 'BABLToken::mint: amount exceeds 96 bits');

        require(
            amount <= totalSupply().mul(MINT_CAP).div(100),
            'BABLToken::mint: exceeded mint cap of 2% of total supply'
        );
        _mint(_to, amount);

        emit MintedNewTokens(_to, amount);

        _moveDelegates(address(0), delegates[_to], amount);

        return true;
    }

    function changeMaxSupply(uint256 newMaxSupply, uint256 newMaxSupplyAllowedAfter) external onlyOwner returns (bool) {
        require(
            block.timestamp >= BABLTokenDeploymentTimestamp.add(FIRST_EPOCH_MINT),
            'BABLToken::changeMaxSupply: a change on maxSupplyAllowed not allowed until 8 years after deployment'
        );
        require(
            block.timestamp >= maxSupplyAllowedAfter,
            'BABLToken::changeMaxSupply: a change on maxSupplyAllowed not allowed yet'
        );

        require(
            newMaxSupply > maxSupplyAllowed,
            'BABLToken::changeMaxSupply: changeMaxSupply should be higher than previous value'
        );
        uint256 limitedNewSupply = maxSupplyAllowed.add(maxSupplyAllowed.mul(MAX_SUPPLY_CAP).div(100));
        require(newMaxSupply <= limitedNewSupply, 'BABLToken::changeMaxSupply: exceeded of allowed 5% cap');
        emit MaxSupplyChanged(maxSupplyAllowed, newMaxSupply);
        maxSupplyAllowed = safe96(newMaxSupply, 'BABLToken::changeMaxSupply: potential max amount exceeds 96 bits');

        uint256 futureTime = block.timestamp.add(365 days);
        require(
            newMaxSupplyAllowedAfter >= futureTime,
            'BABLToken::changeMaxSupply: the newMaxSupplyAllowedAfter should be at least 1 year in the future'
        );
        emit MaxSupplyAllowedAfterChanged(maxSupplyAllowedAfter, newMaxSupplyAllowedAfter);
        maxSupplyAllowedAfter = safe96(
            newMaxSupplyAllowedAfter,
            'BABLToken::changeMaxSupply: new newMaxSupplyAllowedAfter exceeds 96 bits'
        );

        return true;
    }

    function maxSupply() external view returns (uint96, uint256) {
        uint96 safeMaxSupply =
            safe96(maxSupplyAllowed, 'BABLToken::maxSupplyAllowed: maxSupplyAllowed exceeds 96 bits'); // Overflow check
        return (safeMaxSupply, maxSupplyAllowedAfter);
    }
}/*
    Original version by Synthetix.io
    https://docs.synthetix.io/contracts/source/libraries/safedecimalmath

    Adapted by Babylon Finance.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    Apache License, Version 2.0
*/

pragma solidity 0.7.6;


function _require(bool condition, uint256 errorCode) pure {
    if (!condition) _revert(errorCode);
}

function _revert(uint256 errorCode) pure {
    assembly {

        let units := add(mod(errorCode, 10), 0x30)

        errorCode := div(errorCode, 10)
        let tenths := add(mod(errorCode, 10), 0x30)

        errorCode := div(errorCode, 10)
        let hundreds := add(mod(errorCode, 10), 0x30)


        let revertReason := shl(200, add(0x42414223000000, add(add(units, shl(8, tenths)), shl(16, hundreds))))


        mstore(0x0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
        mstore(0x04, 0x0000000000000000000000000000000000000000000000000000000000000020)
        mstore(0x24, 7)
        mstore(0x44, revertReason)

        revert(0, 100)
    }
}

library Errors {
    uint256 internal constant MAX_DEPOSIT_LIMIT = 0;
    uint256 internal constant MIN_CONTRIBUTION = 1;
    uint256 internal constant MIN_TOKEN_SUPPLY = 2;
    uint256 internal constant DEPOSIT_HARDLOCK = 3;
    uint256 internal constant MIN_LIQUIDITY = 4;
    uint256 internal constant MSG_VALUE_DO_NOT_MATCH = 5;
    uint256 internal constant MSG_SENDER_TOKENS_DO_NOT_MATCH = 6;
    uint256 internal constant TOKENS_STAKED = 7;
    uint256 internal constant BALANCE_TOO_LOW = 8;
    uint256 internal constant MSG_SENDER_TOKENS_TOO_LOW = 9;
    uint256 internal constant REDEMPTION_OPENED_ALREADY = 10;
    uint256 internal constant ALREADY_REQUESTED = 11;
    uint256 internal constant ALREADY_CLAIMED = 12;
    uint256 internal constant GREATER_THAN_ZERO = 13;
    uint256 internal constant MUST_BE_RESERVE_ASSET = 14;
    uint256 internal constant ONLY_CONTRIBUTOR = 15;
    uint256 internal constant ONLY_CONTROLLER = 16;
    uint256 internal constant ONLY_CREATOR = 17;
    uint256 internal constant ONLY_KEEPER = 18;
    uint256 internal constant FEE_TOO_HIGH = 19;
    uint256 internal constant ONLY_STRATEGY = 20;
    uint256 internal constant ONLY_ACTIVE = 21;
    uint256 internal constant ONLY_INACTIVE = 22;
    uint256 internal constant ADDRESS_IS_ZERO = 23;
    uint256 internal constant NOT_IN_RANGE = 24;
    uint256 internal constant VALUE_TOO_LOW = 25;
    uint256 internal constant VALUE_TOO_HIGH = 26;
    uint256 internal constant ONLY_STRATEGY_OR_CONTROLLER = 27;
    uint256 internal constant NORMAL_WITHDRAWAL_POSSIBLE = 28;
    uint256 internal constant USER_CANNOT_JOIN = 29;
    uint256 internal constant USER_CANNOT_ADD_STRATEGIES = 30;
    uint256 internal constant ONLY_PROTOCOL_OR_GARDEN = 31;
    uint256 internal constant ONLY_STRATEGIST = 32;
    uint256 internal constant ONLY_INTEGRATION = 33;
    uint256 internal constant ONLY_GARDEN_AND_DATA_NOT_SET = 34;
    uint256 internal constant ONLY_ACTIVE_GARDEN = 35;
    uint256 internal constant NOT_A_GARDEN = 36;
    uint256 internal constant STRATEGIST_TOKENS_TOO_LOW = 37;
    uint256 internal constant STAKE_HAS_TO_AT_LEAST_ONE = 38;
    uint256 internal constant DURATION_MUST_BE_IN_RANGE = 39;
    uint256 internal constant MAX_CAPITAL_REQUESTED = 41;
    uint256 internal constant VOTES_ALREADY_RESOLVED = 42;
    uint256 internal constant VOTING_WINDOW_IS_OVER = 43;
    uint256 internal constant STRATEGY_NEEDS_TO_BE_ACTIVE = 44;
    uint256 internal constant MAX_CAPITAL_REACHED = 45;
    uint256 internal constant CAPITAL_IS_LESS_THAN_REBALANCE = 46;
    uint256 internal constant STRATEGY_IN_COOLDOWN = 47;
    uint256 internal constant STRATEGY_IS_NOT_EXECUTED = 48;
    uint256 internal constant STRATEGY_IS_NOT_OVER_YET = 49;
    uint256 internal constant STRATEGY_IS_ALREADY_FINALIZED = 50;
    uint256 internal constant STRATEGY_NO_CAPITAL_TO_UNWIND = 51;
    uint256 internal constant STRATEGY_NEEDS_TO_BE_INACTIVE = 52;
    uint256 internal constant DURATION_NEEDS_TO_BE_LESS = 53;
    uint256 internal constant CANNOT_SWEEP_RESERVE_ASSET = 54;
    uint256 internal constant VOTING_WINDOW_IS_OPENED = 55;
    uint256 internal constant STRATEGY_IS_EXECUTED = 56;
    uint256 internal constant MIN_REBALANCE_CAPITAL = 57;
    uint256 internal constant NOT_STRATEGY_NFT = 58;
    uint256 internal constant GARDEN_TRANSFERS_DISABLED = 59;
    uint256 internal constant TOKENS_HARDLOCKED = 60;
    uint256 internal constant MAX_CONTRIBUTORS = 61;
    uint256 internal constant BABL_TRANSFERS_DISABLED = 62;
    uint256 internal constant DURATION_RANGE = 63;
    uint256 internal constant MIN_VOTERS_CHECK = 64;
    uint256 internal constant CONTRIBUTOR_POWER_CHECK_WINDOW = 65;
    uint256 internal constant NOT_ENOUGH_RESERVE = 66;
    uint256 internal constant GARDEN_ALREADY_PUBLIC = 67;
    uint256 internal constant WITHDRAWAL_WITH_PENALTY = 68;
    uint256 internal constant ONLY_MINING_ACTIVE = 69;
    uint256 internal constant OVERFLOW_IN_SUPPLY = 70;
    uint256 internal constant OVERFLOW_IN_POWER = 71;
    uint256 internal constant NOT_A_SYSTEM_CONTRACT = 72;
    uint256 internal constant STRATEGY_GARDEN_MISMATCH = 73;
    uint256 internal constant QUARTERS_MIN_1 = 74;
    uint256 internal constant TOO_MANY_OPS = 75;
    uint256 internal constant ONLY_OPERATION = 76;
    uint256 internal constant STRAT_PARAMS_LENGTH = 77;
    uint256 internal constant GARDEN_PARAMS_LENGTH = 78;
    uint256 internal constant NAME_TOO_LONG = 79;
    uint256 internal constant CONTRIBUTOR_POWER_OVERFLOW = 80;
    uint256 internal constant CONTRIBUTOR_POWER_CHECK_DEPOSITS = 81;
    uint256 internal constant NO_REWARDS_TO_CLAIM = 82;
    uint256 internal constant ONLY_UNPAUSED = 83;
    uint256 internal constant REENTRANT_CALL = 84;
    uint256 internal constant RESERVE_ASSET_NOT_SUPPORTED = 85;
    uint256 internal constant RECEIVE_MIN_AMOUNT = 86;
    uint256 internal constant TOTAL_VOTES_HAVE_TO_BE_POSITIVE = 87;
    uint256 internal constant GARDEN_IS_NOT_PUBLIC = 88;
}