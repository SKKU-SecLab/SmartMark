

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

library Roles {

    struct Role {
        mapping(address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account)
        internal
        view
        returns (bool)
    {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}



pragma solidity ^0.8.0;



contract PauserRole is Context {

    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    function initPauserRole() internal {

        _addPauser(_msgSender());
    }

    constructor() {
        _addPauser(_msgSender());
    }

    modifier onlyPauser() {

        require(
            isPauser(_msgSender()),
            "PauserRole: caller does not have the Pauser role"
        );
        _;
    }

    function isPauser(address account) public view returns (bool) {

        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {

        _addPauser(account);
    }

    function renouncePauser() public {

        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {

        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {

        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}




pragma solidity ^0.8.0;



contract Pausable is Context, PauserRole {

    event Paused(address account);
    event Unpaused(address account);
    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function pause() public onlyPauser whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function unpause() public onlyPauser whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }
}



pragma solidity ^0.8.0;



contract WhitelistAdminRole is Context {

    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    function initWhiteListAdmin() internal {

        _addWhitelistAdmin(_msgSender());
    }

    constructor() {
        _addWhitelistAdmin(_msgSender());
    }

    modifier onlyWhitelistAdmin() {

        require(
            isWhitelistAdmin(_msgSender()),
            "WhitelistAdminRole: caller does not have the WhitelistAdmin role"
        );
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {

        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {

        _addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {

        _removeWhitelistAdmin(_msgSender());
    }

    function _addWhitelistAdmin(address account) internal {

        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {

        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}



pragma solidity ^0.8.0;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath#mul: OVERFLOW");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath#div: DIVISION_BY_ZERO");
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath#sub: UNDERFLOW");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath#add: OVERFLOW");

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath#mod: DIVISION_BY_ZERO");
        return a % b;
    }
}




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

        (bool success, bytes memory returndata) =
            target.call{value: value}(data);
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




pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}



pragma solidity ^0.8.0;




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

        uint256 newAllowance =
            token.allowance(address(this), spender).add(value);
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

        uint256 newAllowance =
            token.allowance(address(this), spender).sub(value);
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


        bytes memory returndata =
            address(token).functionCall(
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



pragma solidity ^0.8.0;




contract Wrap {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    IERC20 public token;

    constructor(IERC20 _tokenAddress) {
        token = IERC20(_tokenAddress);
    }

    uint256 private _totalSupply;
    
    mapping(address => uint256) private _balances;
    mapping(address => uint256[]) public fixedBalances;
    mapping(address => uint256[]) public releaseTime;
    mapping(address => uint256) public fixedStakeLength;
    
    event WithdrawnFixedStake(address indexed user, uint256 amount);

    function totalSupply() external view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function stake(uint256 amount) public virtual {

        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
    }
    
    function fixedStake (uint256 _day, uint256 _amount) public virtual {
        fixedBalances[msg.sender].push(_amount);
        uint256 time = block.timestamp + _day * 1 days;
        releaseTime[msg.sender].push(time);
        fixedStakeLength[msg.sender] += 1;
        _totalSupply = _totalSupply.add(_amount);
        IERC20(token).safeTransferFrom(msg.sender, address(this), _amount);
    }

    function withdraw(uint256 amount) public virtual {

        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        IERC20(token).safeTransfer(msg.sender, amount);
    }

    function _rescueScore(address account) internal {

        uint256 amount = _balances[account];

        _totalSupply = _totalSupply.sub(amount);
        _balances[account] = _balances[account].sub(amount);
        IERC20(token).safeTransfer(account, amount);
    }
    
     function withdrawFixedStake(uint256 _index) public virtual {

        require(fixedBalances[msg.sender].length >= _index, "No Record Found");
        require(fixedBalances[msg.sender][_index] != 0, "No Balance To Break");
        require(releaseTime[msg.sender][_index] <= block.timestamp, "Time isn't up");
        
        _totalSupply = _totalSupply.sub(fixedBalances[msg.sender][_index]);
        IERC20(token).safeTransfer(msg.sender, fixedBalances[msg.sender][_index]);
        emit WithdrawnFixedStake(msg.sender, fixedBalances[msg.sender][_index]);
        removeBalance(_index);
        removeReleaseTime(_index);
        fixedStakeLength[msg.sender] -= 1;
        
    }
    function removeBalance(uint index) internal {

        fixedBalances[msg.sender][index] = fixedBalances[msg.sender][fixedBalances[msg.sender].length - 1];
        fixedBalances[msg.sender].pop();
    }
    
    function removeReleaseTime(uint index) internal {

        releaseTime[msg.sender][index] = releaseTime[msg.sender][releaseTime[msg.sender].length - 1];
        releaseTime[msg.sender].pop();
    }
}




pragma solidity ^0.8.0;

interface MyIERC721 {

    function mint(address _to) external;

}



pragma solidity ^0.8.0;

interface ERC721TokenReceiver {

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4);

}



pragma solidity ^0.8.0;

contract Stake is Wrap, Pausable, WhitelistAdminRole {

    struct Card {
        uint256 points;
        uint256 releaseTime;
        address erc721;
        uint256 supply;
    }

    using SafeMath for uint256;

    mapping(address => mapping(uint256 => Card)) public cards;
    mapping(address => uint256) public pendingWithdrawals;

    mapping(address => uint256) public points;
    mapping(address => uint256) public lastUpdateTime;
    uint256 public rewardRate = 8640;
    uint256 public periodStart;
    uint256 public minStake;
    uint256 public maxStake;
    uint256 public minStakeFixed;
    uint256 public maxStakeFixed;
    address public controller;
    bool public constructed = false;
    address public rescuer;
    uint256 public spentScore;
    uint256 public maxDay;
    
    
    event Staked(address indexed user, uint256 amount);
    event FixedStaked(address indexed user, uint256 indexed amount, uint256 indexed day);
    event Withdrawn(address indexed user, uint256 amount);
    event RescueRedeemed(address indexed user, uint256 amount);
    event Removed(
        address indexed erc1155,
        uint256 indexed card,
        address indexed recipient,
        uint256 amount
    );
    event Redeemed(
        address indexed user,
        address indexed erc1155,
        uint256 indexed id,
        uint256 amount
    );

    modifier updateReward(address account) {

        if (account != address(0)) {
            points[account] = earned(account);
            lastUpdateTime[account] = block.timestamp;
        }
        _;
    }

   constructor(
        uint256 _periodStart,
        uint256 _minStake,
        uint256 _maxStake,
        uint256 _minStakeFixed,
        uint256 _maxStakeFixed,
        uint256 _maxDay,
        address _controller,
        IERC20 _tokenAddress
    ) Wrap(_tokenAddress) {
        require(
            _minStake >= 0 && _maxStake > 0 && _maxStake >= _minStake,
            "Problem with min and max stake setup"
        );
        constructed = true;
        periodStart = _periodStart;
        minStake = _minStake;
        maxStake = _maxStake;
        minStakeFixed = _minStakeFixed;
        maxStakeFixed = _maxStakeFixed;
        controller = _controller;
        rescuer = _controller;
        maxDay = _maxDay;
    }

    function setRewardRate(uint256 _rewardRate) external onlyWhitelistAdmin {

        require(_rewardRate > 0, "Reward rate too low");
        rewardRate = _rewardRate;
    }
    
    function setMaxDay(uint256 _day) external onlyWhitelistAdmin {

        require(_day > 0, "Reward rate too low");
        maxDay = _day;
    }

    function setMinMaxStake(uint256 _minStake, uint256 _maxStake)
        external
        onlyWhitelistAdmin
    {

        require(
            _minStake >= 0 && _maxStake > 0 && _maxStake >= _minStake,
            "Problem with min and max stake setup"
        );
        minStake = _minStake;
        maxStake = _maxStake;
    }
    
    function setMinMaxStakeFixed(uint256 _minStake, uint256 _maxStake)
        external
        onlyWhitelistAdmin
    {

        require(
            _minStake >= 0 && _maxStake > 0 && _maxStake >= _minStake,
            "Problem with min and max stake setup"
        );
        minStake = _minStake;
        maxStake = _maxStake;
    }

    function setRescuer(address _rescuer) external onlyWhitelistAdmin {

        rescuer = _rescuer;
    }

    function earned(address account) public view returns (uint256) {

        return points[account].add(getCurrPoints(account));
    }

    function getCurrPoints(address account) internal view returns (uint256) {

        uint256 blockTime = block.timestamp;
        return
            blockTime.sub(lastUpdateTime[account]).mul(balanceOf(account)).div(
                rewardRate
            );
    }

    function stake(uint256 amount)
        public
        override
        updateReward(msg.sender)
        whenNotPaused()
    {

        require(block.timestamp >= periodStart, "Pool not open");
        require(
            amount.add(balanceOf(msg.sender)) >= minStake,
            "Too few deposit"
        );
        require(
            amount.add(balanceOf(msg.sender)) <= maxStake,
            "Deposit limit reached"
        );

        super.stake(amount);
        emit Staked(msg.sender, amount);
    }
    
    function fixedStake (uint256 _day, uint256 _amount) public override whenNotPaused() {
        require(block.timestamp >= periodStart, "Pool not open");
        require(_day > 0, "Can't stake for Zero days");
        require(maxDay <= _day, "Stake Day Limit Exceeded");
        require(
            _amount >= minStakeFixed,
            "Too few deposit"
        );
        require(
            _amount <= maxStakeFixed,
            "Deposit limit reached"
        );
        points[msg.sender] = points[msg.sender].add(_day.mul(_amount));
        super.fixedStake(_day, _amount);
        
        emit FixedStaked(msg.sender, _amount, _day);
    }

    function withdraw(uint256 amount) public override updateReward(msg.sender) {

        require(amount > 0, "Cannot withdraw 0");

        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }
    
    function withdrawFixedStake(uint256 index) public override {


        super.withdrawFixedStake(index);
    }

    function exit() external {

        withdraw(balanceOf(msg.sender));
    }

    function rescueScore(address account)
        external
        updateReward(account)
        returns (uint256)
    {

        require(msg.sender == rescuer, "!rescuer");
        uint256 earnedPoints = points[account];
        spentScore = spentScore.add(earnedPoints);
        points[account] = 0;

        if (balanceOf(account) > 0) {
            _rescueScore(account);
        }

        emit RescueRedeemed(account, earnedPoints);
        return earnedPoints;
    }

    function addNfts(
        uint256 _points,
        uint256 _releaseTime,
        address _erc721Address,
        uint256 _tokenId,
        uint256 _cardAmount
    ) public onlyWhitelistAdmin returns (uint256) {

        require(_tokenId > 0, "Invalid token id");
        require(_cardAmount > 0, "Invalid card amount");
        Card storage c = cards[_erc721Address][_tokenId];
        c.points = _points;
        c.releaseTime = _releaseTime;
        c.erc721 = _erc721Address;
        c.supply = _cardAmount;
        return _tokenId;
    }

    function redeem(address _erc721Address, uint256 id)
        external
        updateReward(msg.sender)
    {

        require(cards[_erc721Address][id].points != 0, "Card not found");
        require(
            block.timestamp >= cards[_erc721Address][id].releaseTime,
            "Card not released"
        );
        require(
            points[msg.sender] >= cards[_erc721Address][id].points,
            "Redemption exceeds point balance"
        );

        points[msg.sender] = points[msg.sender].sub(
            cards[_erc721Address][id].points
        );
        spentScore = spentScore.add(cards[_erc721Address][id].points);

        MyIERC721(cards[_erc721Address][id].erc721).mint(msg.sender);

        emit Redeemed(
            msg.sender,
            cards[_erc721Address][id].erc721,
            id,
            cards[_erc721Address][id].points
        );
    }
}