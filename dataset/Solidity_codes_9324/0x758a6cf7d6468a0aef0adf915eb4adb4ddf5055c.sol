pragma solidity ^0.5.2;


contract DSMath {


    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        assert((z = x + y) >= x);
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        assert((z = x - y) <= x);
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        assert((z = x * y) >= x);
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x / y;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {

        return x <= y ? x : y;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {

        return x >= y ? x : y;
    }


    function hadd(uint128 x, uint128 y) internal pure returns (uint128 z) {

        assert((z = x + y) >= x);
    }

    function hsub(uint128 x, uint128 y) internal pure returns (uint128 z) {

        assert((z = x - y) <= x);
    }

    function hmul(uint128 x, uint128 y) internal pure returns (uint128 z) {

        assert((z = x * y) >= x);
    }

    function hdiv(uint128 x, uint128 y) internal pure returns (uint128 z) {

        z = x / y;
    }

    function hmin(uint128 x, uint128 y) internal pure returns (uint128 z) {

        return x <= y ? x : y;
    }

    function hmax(uint128 x, uint128 y) internal pure returns (uint128 z) {

        return x >= y ? x : y;
    }


    function imin(int256 x, int256 y) internal pure returns (int256 z) {

        return x <= y ? x : y;
    }

    function imax(int256 x, int256 y) internal pure returns (int256 z) {

        return x >= y ? x : y;
    }


    uint128 constant WAD = 10 ** 18;

    function wadd(uint128 x, uint128 y) internal pure returns (uint128) {

        return hadd(x, y);
    }

    function wsub(uint128 x, uint128 y) internal pure returns (uint128) {

        return hsub(x, y);
    }

    function wmul(uint128 x, uint128 y) internal pure returns (uint128 z) {

        z = cast((uint256(x) * y + WAD / 2) / WAD);
    }

    function wdiv(uint128 x, uint128 y) internal pure returns (uint128 z) {

        z = cast((uint256(x) * WAD + y / 2) / y);
    }

    function wmin(uint128 x, uint128 y) internal pure returns (uint128) {

        return hmin(x, y);
    }

    function wmax(uint128 x, uint128 y) internal pure returns (uint128) {

        return hmax(x, y);
    }


    uint128 constant RAY = 10 ** 27;

    function radd(uint128 x, uint128 y) internal pure returns (uint128) {

        return hadd(x, y);
    }

    function rsub(uint128 x, uint128 y) internal pure returns (uint128) {

        return hsub(x, y);
    }

    function rmul(uint128 x, uint128 y) internal pure returns (uint128 z) {

        z = cast((uint256(x) * y + RAY / 2) / RAY);
    }

    function rdiv(uint128 x, uint128 y) internal pure returns (uint128 z) {

        z = cast((uint256(x) * RAY + y / 2) / y);
    }

    function rpow(uint128 x, uint64 n) internal pure returns (uint128 z) {


        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }

    function rmin(uint128 x, uint128 y) internal pure returns (uint128) {

        return hmin(x, y);
    }

    function rmax(uint128 x, uint128 y) internal pure returns (uint128) {

        return hmax(x, y);
    }

    function cast(uint256 x) internal pure returns (uint128 z) {

        assert((z = uint128(x)) == x);
    }

}
pragma solidity ^0.5.2;


contract ERC20Events {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
}

contract ERC20 is ERC20Events {

    function totalSupply() public view returns (uint);

    function balanceOf(address guy) public view returns (uint);

    function allowance(address src, address guy) public view returns (uint);


    function approve(address guy, uint wad) public returns (bool);

    function transfer(address dst, uint wad) public returns (bool);

    function transferFrom(address src, address dst, uint wad) public returns (bool);

}
pragma solidity ^0.5.2;


contract DSTokenBase is ERC20, DSMath {

    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;

    constructor(uint supply) public {
        _supply = supply;
    }

    function totalSupply() public view returns (uint) {

        return _supply;
    }
    function balanceOf(address src) public view returns (uint) {

        return _balances[src];
    }
    function allowance(address src, address guy) public view returns (uint) {

        return _approvals[src][guy];
    }

    function transfer(address dst, uint wad) public returns (bool) {

        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {

        if (src != msg.sender) {
            require(_approvals[src][msg.sender] >= wad, "ds-token-insufficient-approval");
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        require(_balances[src] >= wad, "ds-token-insufficient-balance");
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit Transfer(src, dst, wad);

        return true;
    }

    function approve(address guy, uint wad) public returns (bool) {

        _approvals[msg.sender][guy] = wad;

        emit Approval(msg.sender, guy, wad);

        return true;
    }
}
pragma solidity ^0.5.2;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
}pragma solidity ^0.5.2;


interface ILottery {

    function getAvailablePrize() external view returns (uint256);

}

contract Lottoshi is DSTokenBase(0), Ownable {

    uint256 constant internal magnitude = 2 ** 64;
    uint256 constant internal HOUSE_PERCENTAGE = 75; // 7.5%
    uint256 constant internal REFERRAL_PERCENTAGE = 50; // 5%
    uint256 constant internal FOMO_PERCENTAGE = 120; // 12%
    uint256 constant internal PRIZE_LIMIT_TO_INVEST = 50000 ether;
    uint256 constant internal MAX_SUPPLY = 500000 * (10 ** 6);
    string constant public name = "Lottoshi";
    string constant public symbol = "LTS";
    uint256 constant public decimals = 6;

    uint256 public profitPerShare;
    uint256 public totalStakes;
    address payable public lottery;
    bool public decentralized;

    mapping (address => uint256) public stakesOf;
    mapping (address => uint256) public payout;
    mapping (address => uint256) public dividends;

    event Invest(address indexed user, uint256 ethAmount, uint256 tokenAmount, address referee);
    event Stake(address indexed user, uint256 amount);
    event Unstake(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    constructor (address payable _lottery) public {
        lottery = _lottery;
    }

    function () external {
    }

    function decentralize() external {

        require(lottery == msg.sender, "invalid sender");
        decentralized = true;
    }

    function contribute(address referral) external payable {

        uint256 referralAmount;
        if (referral != address(0)) {
            referralAmount = msg.value * REFERRAL_PERCENTAGE / 300;
            dividends[referral] += referralAmount;
        }
        uint256 houseAmount;
        if (!decentralized) {
            houseAmount = msg.value * HOUSE_PERCENTAGE / 300;
            dividends[owner()] += houseAmount;
        }
        profitPerShare += (msg.value - houseAmount - referralAmount) * magnitude / totalStakes;
    }

    function invest(address referral) public payable {

        uint256 prize = getPrize();
        require(prize < PRIZE_LIMIT_TO_INVEST, "prize is enough");
        uint256 fomoAmount;
        if (totalStakes > 0) {
            fomoAmount = msg.value * FOMO_PERCENTAGE / 1000;
            profitPerShare += fomoAmount * magnitude / totalStakes;
        }
        lottery.transfer(msg.value - fomoAmount);
        uint256 token1 = ethToTokens(prize);
        uint256 token2 = ethToTokens(prize + msg.value);
        uint256 tokenAmount = (token2 - token1) / 1000000000000;
        uint256 referralAmount;
        if (referral != address(0) && referral != msg.sender) {
            referralAmount = tokenAmount / 20;
            stakesOf[referral] += referralAmount;
            payout[referral] += referralAmount * profitPerShare;
            emit Invest(referral, 0, referralAmount, msg.sender);
            emit Transfer(address(0), referral, referralAmount);
            emit Transfer(referral, address(this), referralAmount);
            emit Stake(referral, referralAmount);
        }
        uint256 totalAmount = referralAmount + tokenAmount;
        require(_supply + totalAmount <= MAX_SUPPLY, "exceed max supply");
        stakesOf[msg.sender] += tokenAmount;
        payout[msg.sender] += tokenAmount * profitPerShare;
        _supply += totalAmount;
        totalStakes += totalAmount;
        _balances[address(this)] += totalAmount;
        emit Invest(msg.sender, msg.value, tokenAmount, address(0));
        emit Transfer(address(0), msg.sender, tokenAmount);
        emit Transfer(msg.sender, address(this), tokenAmount);
        emit Stake(msg.sender, tokenAmount);
    }

    function stake(uint256 amount) external {

        internalTransfer(msg.sender, address(this), amount);
        stakesOf[msg.sender] += amount;
        payout[msg.sender] += amount * profitPerShare;
        totalStakes += amount;
        emit Stake(msg.sender, amount);
    }

    function unstake(uint256 amount) external {

        require(stakesOf[msg.sender] >= amount, "stakesOf not enough");
        withdrawDividends(msg.sender);
        payout[msg.sender] -= amount * profitPerShare;
        stakesOf[msg.sender] -= amount;
        totalStakes -= amount;
        emit Unstake(msg.sender, amount);
        internalTransfer(address(this), msg.sender, amount);
    }

    function withdrawDividends() public {

        withdrawDividends(msg.sender);
    }

    function withdrawDividends(address payable user) internal {

        uint256 dividend = dividendOf(user);
        if (dividend > 0) {
            uint256 dividend2 = dividends[user];
            payout[user] += (dividend - dividend2) * magnitude;
            if (dividend2 > 0) {
                dividends[user] = 0;
            }
            user.transfer(dividend);
            emit Withdraw(user, dividend);
        }
    }

    function dividendOf(address user) public view returns (uint256) {

        return (profitPerShare * stakesOf[user] - payout[user]) / magnitude + dividends[user];
    }

    function ethToTokens(uint256 eth) internal pure returns (uint256) {

        return (sqrt(10000800016000000000000000000000000000000000000 + 4000000000000000000000000 * eth) - 100004000000000000000000) >> 1;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {

        uint256 z = (x + 1) >> 1;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) >> 1;
        }
    }

    function getPrize() internal view returns (uint256) {

        return ILottery(lottery).getAvailablePrize();
    }

    function internalTransfer(address src, address dst, uint wad) internal {

        require(_balances[src] >= wad, "ds-token-insufficient-balance");
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit Transfer(src, dst, wad);
    }
}
pragma solidity ^0.5.2;


contract Adminable is Ownable {

    mapping (address => bool) public admins;

    modifier onlyAdmin() {

        require(isAdmin(msg.sender), "not admin");
        _;
    }

    function setAdmin(address user, bool value) external onlyOwner {

        admins[user] = value;
    }

    function isAdmin(address user) internal view returns (bool) {

      return admins[user] || isOwner();
    }
}
