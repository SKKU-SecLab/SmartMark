

pragma solidity ^0.6.0;

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


pragma solidity ^0.6.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.0;





contract MultisigDeal is Context {

    using SafeMath for uint256;

    address private _radix;
    address private _seller;
    address private _buyer;
    uint256 private _amount;
    string private _tokenName;
    address private _token;
    uint256 private _uid;
    bool _executed;

    modifier onlyRadix () {

        require(_msgSender() == address(_radix), "caller is not the radix");
        _;
    }

    constructor (uint256 uid, address radix, address buyer, uint256 amount, string memory tokenName, address token) public {
        IERC20 candidate = IERC20(token);
        require(candidate.totalSupply() > 0, "token doesn't support ERC20");
        _radix = radix;
        _seller = tx.origin;
        _buyer = buyer;
        _amount = amount;
        _tokenName = tokenName;
        _token = token;
        _executed = false;
        _uid = uid;
    }

    function transferToBuyer() external onlyRadix {

        require(!_executed, "contract always executed");
        IERC20 token = IERC20(_token);
        uint256 balance = token.balanceOf(address(this));
        require(balance >= _amount, "insufficient contract address balance");

        token.transfer(_buyer, _amount);
        if (balance > _amount) {
            token.transfer(_seller, balance.sub(_amount));
        }
        _executed = true;
    }

    function returnToSeller() external onlyRadix {

        require(!_executed, "contract always executed");
        IERC20 token = IERC20(_token);
        uint256 balance = token.balanceOf(address(this));
        if (balance > 0) {
            token.transfer(_seller, balance);
        }
        _executed = true;
    }

    function radixAddress() external view returns (address) {

        return _radix;
    }

    function sellerAddress() external view returns (address) {

        return _seller;
    }

    function buyerAddress() external view returns (address) {

        return _buyer;
    }

    function amount() external view returns (uint256) {

        return _amount;
    }

    function tokenName() external view returns (string memory) {

        return _tokenName;
    }

    function tokenAddress() external view returns (address) {

        return _token;
    }

    function executed() external view returns (bool) {

        return _executed;
    }

    function uid() external view returns (uint256) {

        return _uid;
    }
}


pragma solidity ^0.6.0;





contract Factory is Context {

    using SafeMath for uint256;

    mapping (uint256 => address) private _deals; // uid -> deals address
    mapping (address => address[]) private _userDeals; // user address -> deals addresses

    function createDeal(uint256 uid, address radix, address buyer, uint256 amount, string calldata tokenName, address token) external {

        require(radix != address(0), "radix can't be zero address");
        require(buyer != address(0), "buyer can't be zero address");
        require(token != address(0), "token can't be zero address");
        require(amount > 0, "amount cat't be zero");
        require(_deals[uid] == address(0), "uid already used, collision");
        MultisigDeal newDeal = new MultisigDeal(uid, radix, buyer, amount, tokenName, token);

        _deals[uid] = address(newDeal);
        _userDeals[_msgSender()].push(address(newDeal));
        _userDeals[buyer].push(address(newDeal));
    }

    function getUserDeals(address user) external view returns (address[] memory) {

         return _userDeals[user];
    }

    function getUserDealsWithFilter(address user, bool buyersOnly) external view returns (address[] memory) {

        uint256 counter = 0;
        uint256 length = _userDeals[user].length;
        for (uint256 i = 0; i < length; ++i) {
            MultisigDeal deal = MultisigDeal(_userDeals[user][i]);
            if ((deal.buyerAddress() == user && buyersOnly) ||
                (deal.sellerAddress() == user && !buyersOnly)) {
                counter++;
            }
        }

        address[] memory deals = new address[](counter);
        uint256 index = 0;
        for (uint256 i = 0; i < length; ++i) {
            MultisigDeal deal = MultisigDeal(_userDeals[user][i]);
            if ((deal.buyerAddress() == user && buyersOnly) ||
                (deal.sellerAddress() == user && !buyersOnly)) {
                deals[index] = _userDeals[user][i];
                index++;
            }
        }

        return deals;
    }

    function getDealContract(uint256 uid) external view returns (address) {

        return _deals[uid];
    }
}