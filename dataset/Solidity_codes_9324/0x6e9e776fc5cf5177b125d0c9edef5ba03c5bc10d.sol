

pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;


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


contract IERC721 /*is IERC165*/ {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);


    function ownerOf(uint256 tokenId) public view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function transferFrom(address from, address to, uint256 tokenId) public;

    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

    
    function checkFeeDistributionPercentage(address[] memory _fee_receivers, uint256[] memory percentage) public;

    
    function getFeePercentage() public view returns (uint256);

    
    function getDeployer() public view returns (address);

    
    function getFeeReceivers() public returns(address[] memory);

    
    function getFeeDistribution(address fee_receiver) public returns(uint256);

    
    function stake(uint256 tokenId, address _stakingAddress) public;

    
    function clearStake(uint256 tokenId) public;

}

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

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract OperatorRole is Context {

    using Roles for Roles.Role;

    event OperatorAdded(address indexed account);
    event OperatorRemoved(address indexed account);

    Roles.Role private _operators;

    constructor () internal {

    }

    modifier onlyOperator() {

        require(isOperator(_msgSender()), "OperatorRole: caller does not have the Operator role");
        _;
    }

    function isOperator(address account) public view returns (bool) {

        return _operators.has(account);
    }

    function _addOperator(address account) internal {

        _operators.add(account);
        emit OperatorAdded(account);
    }

    function _removeOperator(address account) internal {

        _operators.remove(account);
        emit OperatorRemoved(account);
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
}

contract OwnableOperatorRole is Ownable, OperatorRole {

    function addOperator(address account) external onlyOwner {

        _addOperator(account);
    }

    function removeOperator(address account) external onlyOwner {

        _removeOperator(account);
    }
}

contract TransferProxy is OwnableOperatorRole {


    function erc721safeTransferFrom(IERC721 token, address from, address to, uint256 tokenId) external;

    function erc721clearStake(IERC721 token, uint256 tokenId) external;

    function erc721Stake(IERC721 token, uint256 tokenId, address stakingAddress) external;

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

contract ERC20TransferProxy is OwnableOperatorRole {


    function erc20safeTransferFrom(IERC20 token, address from, address to, uint256 value) external;

}

contract ExchangeV1 is Ownable {

    using SafeMath for uint;
    
    struct DistributionItem {
        address _address;
        uint256 _amount;
    }

    TransferProxy public transferProxy;
    ERC20TransferProxy public erc20TransferProxy;
    
    mapping (address => mapping(uint256 => uint256)) public buyOrder;
    mapping (address => mapping(uint256 => address)) public auctionOrder;
    mapping (address => mapping(uint256 => mapping(address => mapping(address => uint256)))) public bidOrder;
    mapping (address => mapping(uint256 => address[])) public bidMembers;
    
    uint256 public listingFee = 15 * 10** 15;
    uint256 public serviceFee = 25; // 25 / 1000 => 2.5%
    
    address payable public serviceAddress;
    
    address public caribmarsAddress;
    mapping (address => mapping (uint256 => bool)) public tokenStakings;
    mapping (address => mapping (uint256 => uint256)) public stakingBlockNumbers;
    
    uint256 public farmFeePerBlock = 1;
    uint256 public farmTokenAmount = 100000;
    address public governanceAddress;

    constructor(
        TransferProxy _transferProxy, ERC20TransferProxy _erc20TransferProxy
    ) public {
        transferProxy = _transferProxy;
        erc20TransferProxy = _erc20TransferProxy;
        
        serviceAddress = _msgSender();
    }

    function exchange(
        address sellToken, uint256 sellTokenId,
        address owner,
        address buyToken, uint256 buyValue,
        address buyer
    ) payable external {

        require(owner == _msgSender(), "Exchange: The only token owner can accept bid.");
        
        validateBidRequest(sellToken, sellTokenId, buyer, buyToken, buyValue);
        
        uint256 serviceFeeAmount = buyValue.mul(serviceFee).div(1000);
        uint256 amount = buyValue - serviceFeeAmount;
        
        address[] memory fee_receivers = IERC721(sellToken).getFeeReceivers();
        
        uint256 feePercentage = IERC721(sellToken).getFeePercentage();
        
        if (feePercentage == 0) {
            transferProxy.erc721safeTransferFrom(IERC721(sellToken), owner, buyer, sellTokenId);
            erc20TransferProxy.erc20safeTransferFrom(IERC20(buyToken), buyer, owner, amount);
        } else {
            DistributionItem[] memory distributions = getDistributions(sellToken, owner, fee_receivers, feePercentage, amount);
            
            transferProxy.erc721safeTransferFrom(IERC721(sellToken), owner, buyer, sellTokenId);
            for (uint256 i = 0; i < distributions.length; i++) {
                if (distributions[i]._amount > 0) {
                    erc20TransferProxy.erc20safeTransferFrom(IERC20(buyToken), buyer, distributions[i]._address, distributions[i]._amount);
                }
            }
        }
        
        if (serviceFeeAmount > 0) {
            erc20TransferProxy.erc20safeTransferFrom(IERC20(buyToken), buyer, serviceAddress, serviceFeeAmount);
        }
        
        CancelAllBid(sellToken, sellTokenId, buyToken);
        
        auctionOrder[sellToken][sellTokenId] = address(0);
        
    }
    
    function getDistributions(address sellToken, address owner, address[] memory fee_receivers, uint256 feePercentage, uint256 amount) internal returns (DistributionItem[] memory) {

        DistributionItem[] memory distributions = new DistributionItem[](fee_receivers.length + 1);
            
            uint256 feeAmount = amount.mul(feePercentage).div(100);
            
            uint256 total = 0;
            for (uint256 i = 0; i < fee_receivers.length; i++) {
                total += IERC721(sellToken).getFeeDistribution(fee_receivers[i]);
            }
            
            for (uint256 i = 0; i < fee_receivers.length; i++) {
                uint256 distributionAmount = 0;
                
                {
                
                    distributionAmount = IERC721(sellToken).getFeeDistribution(fee_receivers[i]) * feeAmount;
                }
                
                {
                    distributionAmount = distributionAmount / total;
                }
                    
                distributions[i] = DistributionItem(fee_receivers[i], distributionAmount);
            }
            
            distributions[fee_receivers.length] = DistributionItem(owner, amount - feeAmount);
            
            return distributions;
    }
    
    function buy(
        address sellToken, uint256 sellTokenId,
        address owner,
        uint256 buyValue,
        address buyer
    ) payable external {

        validateBuyRequest(sellToken, sellTokenId, buyValue);
        
        uint256 serviceFeeAmount = buyValue.mul(serviceFee).div(1000);
        uint256 amount = buyValue - serviceFeeAmount;
        
        address[] memory fee_receivers = IERC721(sellToken).getFeeReceivers();
        
        uint256 feePercentage = IERC721(sellToken).getFeePercentage();
        
        if (feePercentage == 0) {
            transferProxy.erc721safeTransferFrom(IERC721(sellToken), owner, buyer, sellTokenId);
            address payable to_address = address(uint160(owner));
            to_address.send(amount);
        } else {
            DistributionItem[] memory distributions = getDistributions(sellToken, owner, fee_receivers, feePercentage, amount);
            
            transferProxy.erc721safeTransferFrom(IERC721(sellToken), owner, buyer, sellTokenId);
            for (uint256 i = 0; i < distributions.length; i++) {
                if (distributions[i]._amount > 0) {
                    address payable to_address = address(uint160(distributions[i]._address));
                    to_address.transfer(distributions[i]._amount);
                }
            }
        }
        
        if (serviceFeeAmount > 0) {
            serviceAddress.transfer(serviceFeeAmount);
        }
        
        buyOrder[sellToken][sellTokenId] = 0;
    }
    
    function BuyRequest(address token, uint256 tokenId, uint256 amount) public payable {

        require(IERC721(token).getApproved(tokenId) == address(transferProxy), "Not approved yet.");
        require(IERC721(token).ownerOf(tokenId) == msg.sender, "Only owner can request.");
        
        require(msg.value == listingFee, "Incorrect listing fee.");
        
        buyOrder[token][tokenId] = amount;
    }
    
    function AuctionRequest(address token, uint256 tokenId, address buytoken) public payable {

        require(IERC721(token).getApproved(tokenId) == address(transferProxy), "Not approved yet.");
        require(IERC721(token).ownerOf(tokenId) == msg.sender, "Only owner can request.");
        
        require(msg.value == listingFee, "Incorrect listing fee.");
        
        auctionOrder[token][tokenId] = buytoken;
    }
    
    function CancelBuyRequest(address token, uint256 tokenId) public {

        require(IERC721(token).getApproved(tokenId) == address(transferProxy), "Not approved yet.");
        require(IERC721(token).ownerOf(tokenId) == msg.sender, "Only owner can request.");
        buyOrder[token][tokenId] = 0;
    }
    
    function validateBuyRequest(address token, uint256 tokenId, uint256 amount) internal {

        require(buyOrder[token][tokenId] == amount, "Amount is incorrect.");
    }
    
    function BidRequest(address sellToken, uint256 tokenId, address buyToken, uint256 amount) public {

        require(IERC20(buyToken).allowance(msg.sender, address(erc20TransferProxy)) >= amount, "Not allowed yet.");
        require(auctionOrder[sellToken][tokenId] == buyToken, "Not acceptable asset.");
        
        bidOrder[sellToken][tokenId][msg.sender][buyToken] = amount;
        bidMembers[sellToken][tokenId].push(msg.sender);
    }
    
    function validateBidRequest(address sellToken, uint256 tokenId, address buyer, address buyToken, uint256 amount) internal {

        require(bidOrder[sellToken][tokenId][buyer][buyToken] == amount, "Amount is incorrect.");
    }
    
    function CancelBid(address sellToken, uint256 tokenId, address buyToken) public {

        bidOrder[sellToken][tokenId][msg.sender][buyToken] = 0;
        for (uint256 i  = 0; i < bidMembers[sellToken][tokenId].length; i++) {
            if (bidMembers[sellToken][tokenId][i] == msg.sender) {
                bidMembers[sellToken][tokenId][i] = bidMembers[sellToken][tokenId][bidMembers[sellToken][tokenId].length - 1];
                bidMembers[sellToken][tokenId].pop();
                break;
            }
        }
    }
    
    function CancelAllBid(address sellToken, uint256 tokenId, address buyToken) internal {

        while (bidMembers[sellToken][tokenId].length != 0) {
            address member = bidMembers[sellToken][tokenId][bidMembers[sellToken][tokenId].length - 1];
            bidOrder[sellToken][tokenId][member][buyToken] = 0;
            bidMembers[sellToken][tokenId].pop();
        }
    }
    
    function CancelAuctionRequests(address sellToken, uint256 tokenId, address buyToken) public {

        require(IERC721(sellToken).getApproved(tokenId) == address(transferProxy), "Not approved nft token.");
        require(IERC721(sellToken).ownerOf(tokenId) == msg.sender, "Only owner can request.");
        
        CancelAllBid(sellToken, tokenId, buyToken);
        auctionOrder[sellToken][tokenId] = address(0);
    }
    
    function setListingFee(uint256 fee) public onlyOwner {

        listingFee = fee;
    }
    
    function depositBNB() public payable {

        require(msg.value > 0, "The sending amount must be greater than zero.");
    }
    
    function withdrawBNB(address payable receiver, uint256 amount) public onlyOwner payable {

        require(receiver != address(0), "The receiver must not be null address.");
        require(amount > 0, "The amount must be greater than zero.");
        
        receiver.transfer(amount);
    }
    
    function setCaribMarsAddress(address _caribmarsAddress) public onlyOwner {

        require(_caribmarsAddress != address(0), "Not allowed to set zero address.");
        
        caribmarsAddress = _caribmarsAddress;
    }
    
    function setGovernanceAddress(address _governanceAddress) public onlyOwner {

        require(_governanceAddress != address(0), "Now allowed to set zero address.");
        
        governanceAddress = _governanceAddress;
    }
    
    function clearStake(IERC721 token, uint256 tokenID) public {

        require(tokenStakings[address(token)][tokenID] == true, "Not staked token.");
        require(IERC721(token).ownerOf(tokenID) == _msgSender(), "Not owner.");
        uint256 feeAmount = (block.number - stakingBlockNumbers[address(token)][tokenID]) * farmFeePerBlock;
        
        erc20TransferProxy.erc20safeTransferFrom(IERC20(caribmarsAddress), _msgSender(), governanceAddress, farmTokenAmount);
        IERC721(token).clearStake(tokenID);
        erc20TransferProxy.erc20safeTransferFrom(IERC20(caribmarsAddress), governanceAddress, _msgSender(), feeAmount);
        
        tokenStakings[address(token)][tokenID] = false;
    }
    
    function stake(IERC721 token, uint256 tokenID) public {

        require(IERC721(token).ownerOf(tokenID) == _msgSender(), "Not owner.");
        
        transferProxy.erc721Stake(token, tokenID, address(this));
        erc20TransferProxy.erc20safeTransferFrom(IERC20(caribmarsAddress), governanceAddress, _msgSender(), farmTokenAmount);
        
        tokenStakings[address(token)][tokenID] = true;
        stakingBlockNumbers[address(token)][tokenID] = block.number;
    }
    
    function setERC20TransferProxy(ERC20TransferProxy _erc20TransferProxy) public onlyOwner {

        erc20TransferProxy = _erc20TransferProxy;
    }
    
    function setTransferProxy(TransferProxy _transferProxy) public onlyOwner {

        transferProxy = _transferProxy;
    }
}