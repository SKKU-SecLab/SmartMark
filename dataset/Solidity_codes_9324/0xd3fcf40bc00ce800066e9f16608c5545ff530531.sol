pragma solidity >=0.8.0 <0.9.0;

contract Storage {

    struct VIPStats {
        uint256 startedAt;
        uint256 expiredAt;
    }
    mapping(address => VIPStats) internal vipMap;
    address public checkoutContract;
    address[] internal vips;
}// MIT
pragma solidity ^0.8.0;

interface IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


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


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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
}//MIT
pragma solidity >=0.8.0 <0.9.0;

struct ProductItem {
    bytes32 i18nId;
    bytes32 appId;
    uint256 price;
    uint128 payType;
    uint128 off;
    uint256 duration;
    uint256 createdAt;
    address createdBy;
    address updatedBy;
}

interface IFinance {

    function queryProduct(bytes32 id) external returns (ProductItem memory);


    function checkout(
        bytes32 orderid,
        address payer,
        bytes32 skuId,
        address inviter
    ) external payable;

}

contract MultiSenderV1 is Storage, Ownable {

    event MultisendTokenOK(address indexed _from, address indexed token);
    event WithdrawSuccessed(address indexed _from);
    event WithdrawERC20Successed(address indexed _from, address indexed token);

    function setCheckoutContract(address _checkout) public onlyOwner {

        checkoutContract = _checkout;
    }

    function registerVIP(address[] memory beneficiarys, uint256 duration)
        public
        onlyOwner
    {

        for (uint256 i = 0; i < beneficiarys.length; i++) {
            if (vipMap[beneficiarys[i]].startedAt == 0) {
                vipMap[beneficiarys[i]].startedAt = block.timestamp;
                vips.push(beneficiarys[i]);
                vipMap[beneficiarys[i]].expiredAt = block.timestamp + duration;
            } else {
                vipMap[beneficiarys[i]].expiredAt =
                    vipMap[beneficiarys[i]].expiredAt +
                    duration;
            }
        }
    }

    function buyVIP(
        bytes32 skuId,
        address inviter,
        bytes32 orderid,
        address beneficiary
    ) public payable {

        IFinance finance = IFinance(checkoutContract);
        ProductItem memory productInfo = finance.queryProduct(skuId);
        require(
            productInfo.appId ==
                0x6d756c746973656e646572000000000000000000000000000000000000000000,
            "MultiSenderV1: invalid skuId"
        );

        finance.checkout{value: msg.value}(orderid, msg.sender, skuId, inviter);

        if (vipMap[beneficiary].startedAt == 0) {
            vipMap[beneficiary].startedAt = block.timestamp;
            vips.push(beneficiary);
            vipMap[beneficiary].expiredAt =
                block.timestamp +
                productInfo.duration;
        } else {
            if (vipMap[beneficiary].startedAt > vipMap[beneficiary].expiredAt) {
                vipMap[beneficiary].expiredAt = block.timestamp;
            }
            vipMap[beneficiary].expiredAt =
                vipMap[beneficiary].expiredAt +
                productInfo.duration;
        }
    }

    function multisendToken(
        address token,
        address[] memory _contributors,
        uint256[] memory _balances,
        address inviter,
        bytes32 orderid
    ) public payable {

        require(
            _contributors.length <= 100,
            "MultiSenderV1: _contributors length must be less than or equal to 100"
        );
        require(
            _contributors.length == _balances.length,
            "MultiSenderV1: _contributors length and _balances length must be the same"
        );

        uint256 total = 0;
        for (uint256 i = 0; i < _balances.length; i++) {
            total = total + _balances[i];
        }
        uint256 minMainCoin = total;

        if (address(0) != token) {
            minMainCoin = 0;
        }

        if (vipMap[msg.sender].expiredAt < block.timestamp) {
            IFinance finance = IFinance(checkoutContract);
            bytes32 skuId = querySkuId(_contributors.length);

            require(
                msg.value > minMainCoin,
                "MultiSenderV1: msg.value should greater than the amount of tokens"
            );

            uint256 v = msg.value - minMainCoin;

            finance.checkout{value: v * 1 wei}(
                orderid,
                msg.sender,
                skuId,
                inviter
            );
        } else {
            if (address(0) == token) {
                require(
                    msg.value == total,
                    "MultiSenderV1: msg.value should be equal to the amount of tokens you want to send without paying software fees"
                );
            } else {
                require(msg.value == 0, "MultiSenderV1: msg.value should be 0");
            }
        }

        if (address(0) == token) {
            require(
                msg.value >= total,
                "MultiSenderV1: insufficient MainCoin balance"
            );
            executeNativeTokenTransfer(_contributors, _balances);
        } else {
            IERC20 eRC20Token = IERC20(token);
            require(
                eRC20Token.balanceOf(msg.sender) >= total,
                "MultiSenderV1: insufficient ERC20Coin balance"
            );
            require(
                eRC20Token.allowance(msg.sender, address(this)) >= total,
                "MultiSenderV1: insufficient allowance"
            );
            executeERC20Transfer(eRC20Token, _contributors, _balances);
        }

        emit MultisendTokenOK(msg.sender, token);
    }

    function executeNativeTokenTransfer(
        address[] memory receivers,
        uint256[] memory _balances
    ) internal {

        for (uint256 i = 0; i < receivers.length; i++) {
            address payable recipient = payable(address(receivers[i]));
            (bool success, ) = recipient.call{value: _balances[i]}(
                "0x506f7765726564206279206269756269752e746f6f6c73000000000000000000"
            );
            require(
                success,
                "Address: unable to send value, recipient may have reverted"
            );
        }
    }

    function executeERC20Transfer(
        IERC20 eRC20Token,
        address[] memory receivers,
        uint256[] memory _balances
    ) internal {

        for (uint256 i = 0; i < receivers.length; i++) {
            eRC20Token.transferFrom(msg.sender, receivers[i], _balances[i]);
        }
    }

    function querySkuId(uint256 len) public pure returns (bytes32 skuId) {

        if (len <= 20) {
            return
                0x6d756c746973656e6465722d6e6f746f76657232302d7070702d306400000000;
        } else {
            return
                0x6d756c746973656e6465722d6f76657232302d7070702d306400000000000000;
        }
    }

    function queryTotalVips() public view returns (uint256 total) {

        return vips.length;
    }

    function queryVIP(address target)
        public
        view
        returns (VIPStats memory vipStats)
    {

        return vipMap[target];
    }

    function withdraw() public onlyOwner {

        require(address(this).balance > 0, "Finance: insufficient balance");
        address payable recipient = payable(address(owner()));
        (bool success, ) = recipient.call{value: address(this).balance}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );

        emit WithdrawSuccessed(address(owner()));
    }

    function withdrawERC20(address token) public onlyOwner {

        IERC20 erc20Token = IERC20(token);
        require(
            erc20Token.balanceOf(address(this)) > 0,
            "Address: insufficient balance"
        );
        erc20Token.transfer(
            address(owner()),
            erc20Token.balanceOf(address(this))
        );
        emit WithdrawERC20Successed(address(owner()), token);
    }
}