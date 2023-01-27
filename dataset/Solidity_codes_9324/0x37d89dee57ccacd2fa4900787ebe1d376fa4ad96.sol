
pragma solidity 0.4.25;


contract ERC20Interface {

    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function allowance(address approver, address spender) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    function transferFrom(address from, address to, uint256 value) public returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed approver, address indexed spender, uint256 value);
}


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Trustee {

    using SafeMath for uint256;

    struct Holding {
        uint256 quantity;

        uint256 releaseDate;

        bool isAffiliate;
    }

    modifier onlyIssuer {

        require(msg.sender == issuer, "You must be issuer/owner to execute this function.");
        _;
    }

    modifier onlyTransferAgent {

        require(msg.sender == transferAgent, "You must be the Transfer Agent to execute this function.");
        _;
    }

    address public issuer;

    mapping(address => Holding) public heldTokens;

    address public tokenContract;

    address public transferAgent;

    uint256 public oneYear = 0;//31536000;

    event TokensHeld(address indexed who, uint256 tokens, uint256 releaseDate);

    event TokensReleased(address indexed who, uint256 tokens);

    event TokensTransferred(address indexed from, address indexed to, uint256 tokens);

    event ReleaseDateExtended(address who, uint256 newReleaseDate);

    event AffiliateStatusChanged(address who, bool isAffiliate);

    constructor(address erc20Contract) public {
        issuer = msg.sender;
        tokenContract = erc20Contract;
    }

    function setTransferAgent(address who) public onlyIssuer {

        transferAgent = who;
    }

    function hold(address who, uint256 quantity) public onlyIssuer {

        require(who != 0x0, "The null address cannot own tokens.");
        require(quantity != 0, "Quantity must be greater than zero.");
        require(!isExistingHolding(who), "Cannot overwrite an existing holding, use a new wallet.");

        Holding memory holding = Holding(quantity, block.timestamp+oneYear, false);
        heldTokens[who] = holding;
        emit TokensHeld(who, holding.quantity, holding.releaseDate);
    }
	
    function postIcoHold(address who, uint256 quantity, uint256 addedTime) public onlyTransferAgent {

        require(who != 0x0, "The null address cannot own tokens.");
        require(quantity != 0, "Quantity must be greater than zero.");
        require(!isExistingHolding(who), "Cannot overwrite an existing holding, use a new wallet.");

        Holding memory holding = Holding(quantity, block.timestamp+addedTime, false);
        heldTokens[who] = holding;
        emit TokensHeld(who, holding.quantity, holding.releaseDate);
    }

    function canRelease(address who) public view returns (bool) {

        Holding memory holding = heldTokens[who];
        if(holding.releaseDate == 0 || holding.quantity == 0)
            return false;

        return block.timestamp > holding.releaseDate;
    }

    function release(address who) public onlyTransferAgent returns (bool) {

        Holding memory holding = heldTokens[who];
        require(!holding.isAffiliate, "To release tokens for an affiliate use partialRelease().");

        if(block.timestamp > holding.releaseDate) {

            bool res = ERC20Interface(tokenContract).transfer(who, holding.quantity);
            if(res) {
                heldTokens[who] = Holding(0, 0, holding.isAffiliate);
                emit TokensReleased(who, holding.quantity);
                return true;
            }
        }

        return false;
    }
	
    function partialRelease(address who, address tradingWallet, uint256 amount) public onlyTransferAgent returns (bool) {

        require(tradingWallet != 0, "The destination wallet cannot be null.");
        require(!isExistingHolding(tradingWallet), "The destination wallet must be a new fresh wallet.");
        Holding memory holding = heldTokens[who];
        require(holding.isAffiliate, "Only affiliates can use this function; use release() for non-affiliates.");
        require(amount <= holding.quantity, "The holding has less than the specified amount of tokens.");

        if(block.timestamp > holding.releaseDate) {

            bool res = ERC20Interface(tokenContract).transfer(tradingWallet, amount);
            if(res) {
                heldTokens[who] = Holding(holding.quantity.sub(amount), holding.releaseDate, holding.isAffiliate);
                emit TokensReleased(who, amount);
                return true;
            }
        }

        return false;
    }

    function transfer(address from, address to, uint256 amount) public onlyTransferAgent returns (bool) {

        require(to != 0x0, "Cannot transfer tokens to the null address.");
        require(amount > 0, "Cannot transfer zero tokens.");
        Holding memory fromHolding = heldTokens[from];
        require(fromHolding.quantity >= amount, "Not enough tokens to perform the transfer.");
        require(!isExistingHolding(to), "Cannot overwrite an existing holding, use a new wallet.");

        heldTokens[from] = Holding(fromHolding.quantity.sub(amount), fromHolding.releaseDate, fromHolding.isAffiliate);
        heldTokens[to] = Holding(amount, fromHolding.releaseDate, false);

        emit TokensTransferred(from, to, amount);

        return true;
    }

    function addTime(address who, uint sconds) public onlyTransferAgent returns (bool) {

        require(sconds > 0, "Time added cannot be zero.");

        Holding memory holding = heldTokens[who];
        heldTokens[who] = Holding(holding.quantity, holding.releaseDate.add(sconds), holding.isAffiliate);

        emit ReleaseDateExtended(who, heldTokens[who].releaseDate);

        return true;
    }

    function setAffiliate(address who, bool isAffiliate) public onlyTransferAgent returns (bool) {

        require(who != 0, "The null address cannot be used.");

        Holding memory holding = heldTokens[who];
        require(holding.isAffiliate != isAffiliate, "Attempt to set the same affiliate status that is already set.");

        heldTokens[who] = Holding(holding.quantity, holding.releaseDate, isAffiliate);

        emit AffiliateStatusChanged(who, isAffiliate);

        return true;
    }

    function isExistingHolding(address who) public view returns (bool) {

        Holding memory h = heldTokens[who];
        return (h.quantity != 0 || h.releaseDate != 0);
    }
}