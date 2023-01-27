pragma solidity =0.5.16;


library SafeMath {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
    
    function div(uint a, uint b) internal pure returns (uint z) {

        require(b > 0);
        return a / b;
    }
}pragma solidity =0.5.16;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}pragma solidity =0.5.16;


contract MonetAirdrop is Ownable {

    using SafeMath for uint256;

    address public tokenCards;
    uint256 public laveCards;
    mapping(uint256 => uint256) cardNums;
    mapping(address => bool) public partner;

    constructor(address cards) public {
        tokenCards = cards;
    }

    function notify(address[] calldata accounts, uint256[] calldata cards) external onlyOwner {

        setCards(cards);
        setPartner(accounts);
    }

    function setPartner(address[] memory accounts) public onlyOwner {

        for (uint256 i = 0; i < accounts.length; i++) {
            partner[accounts[i]] = true;
        }
    }

    function setCards(uint256[] memory cards) public onlyOwner {

        require(cards.length > 0, "cards is empty");

        uint256 levelMax = 10;
        uint256 _laveCards = laveCards;
        for (uint256 i = 0; i < cards.length; i++) {
            cardNums[levelMax.sub(i)] = cards[i];
            _laveCards = _laveCards.add(cards[i]);
        }
        laveCards = _laveCards;
    }

    function airdrop() external onlyCaller(msg.sender) {

        require(laveCards > 0, "lave cards is zero");
        require(partner[msg.sender], "Caller is not partner");

        uint256 seed = uint256(
            keccak256(abi.encodePacked(block.difficulty, now))
        );
        uint256 num = 0;
        uint256 random = seed % laveCards;
        for (uint256 i = 10; i > 4; i--) {
            if (cardNums[i] == 0) continue;
            num = num.add(cardNums[i]);
            if (random <= num) {
                partner[msg.sender] = false;
                laveCards = laveCards.sub(1);
                cardNums[i] = cardNums[i].sub(1);
                uint256 color = (seed / 10 - seed) % 4;
                uint256[] memory cards = new uint256[](1);
                cards[0] = i.mul(10).add(color).add(1000);
                ICardERC(tokenCards).cardsBatchMint(msg.sender, cards);
                emit Airdrop(msg.sender, cards[0]);
                return;
            }
        }
    }

    modifier onlyCaller(address account) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        require(size == 0, "account is contract");

        _;
    }

    event Airdrop(address indexed sender, uint256 card);
}

interface ICardERC {

    function cardsBatchMint(address _to, uint256[] calldata _cards) external;

}