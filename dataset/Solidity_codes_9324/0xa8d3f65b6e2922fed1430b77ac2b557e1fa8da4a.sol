

pragma solidity 0.8.7;





interface IRegistry {

    event Lend(
        bool is721,
        address indexed lenderAddress,
        address indexed nftAddress,
        uint256 indexed tokenID,
        uint256 lendingID,
        uint8 maxRentDuration,
        bytes4 dailyRentPrice,
        uint16 lendAmount,
        IResolver.PaymentToken paymentToken
    );

    event Rent(
        address indexed renterAddress,
        uint256 indexed lendingID,
        uint256 indexed rentingID,
        uint16 rentAmount,
        uint8 rentDuration,
        uint32 rentedAt
    );

    event StopLend(uint256 indexed lendingID, uint32 stoppedAt);

    event StopRent(uint256 indexed rentingID, uint32 stoppedAt);

    event RentClaimed(uint256 indexed rentingID, uint32 collectedAt);

    enum NFTStandard {
        E721,
        E1155
    }

    struct CallData {
        uint256 left;
        uint256 right;
        IRegistry.NFTStandard[] nftStandard;
        address[] nftAddress;
        uint256[] tokenID;
        uint256[] lendAmount;
        uint8[] maxRentDuration;
        bytes4[] dailyRentPrice;
        uint256[] lendingID;
        uint256[] rentingID;
        uint8[] rentDuration;
        uint256[] rentAmount;
        IResolver.PaymentToken[] paymentToken;
    }

    struct Lending {
        NFTStandard nftStandard;
        address payable lenderAddress;
        uint8 maxRentDuration;
        bytes4 dailyRentPrice;
        uint16 lendAmount;
        uint16 availableAmount;
        IResolver.PaymentToken paymentToken;
    }

    struct Renting {
        address payable renterAddress;
        uint8 rentDuration;
        uint32 rentedAt;
        uint16 rentAmount;
    }

    function lend(
        IRegistry.NFTStandard[] memory nftStandard,
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint256[] memory lendAmount,
        uint8[] memory maxRentDuration,
        bytes4[] memory dailyRentPrice,
        IResolver.PaymentToken[] memory paymentToken
    ) external;


    function stopLend(
        IRegistry.NFTStandard[] memory nftStandard,
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint256[] memory lendingID
    ) external;


    function rent(
        IRegistry.NFTStandard[] memory nftStandard,
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint256[] memory lendingID,
        uint8[] memory rentDuration,
        uint256[] memory rentAmount
    ) external payable;


    function stopRent(
        IRegistry.NFTStandard[] memory nftStandard,
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint256[] memory lendingID,
        uint256[] memory rentingID
    ) external;


    function claimRent(
        IRegistry.NFTStandard[] memory nftStandard,
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint256[] memory lendingID,
        uint256[] memory rentingID
    ) external;

}



interface IResolver {

    enum PaymentToken {
        SENTINEL,
        DAI,
        USDC,
        TUSD
    }

    function getPaymentToken(uint8 _pt) external view returns (address);


    function setPaymentToken(uint8 _pt, address _v) external;

}


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
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


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
}


interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


contract ERC721Holder is IERC721Receiver {

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}


interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}


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

}


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
}


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}


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

}


contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}



contract Registry is IRegistry, ERC721Holder, ERC1155Receiver, ERC1155Holder {
    using SafeERC20 for ERC20;

    IResolver private resolver;
    address private admin;
    address payable private beneficiary;
    uint256 private lendingID = 1;
    uint256 private rentingID = 1;
    bool public paused = false;
    uint256 public rentFee = 0;
    uint256 private constant SECONDS_IN_DAY = 86400;
    mapping(bytes32 => Lending) private lendings;
    mapping(bytes32 => Renting) private rentings;

    modifier onlyAdmin() {
        require(msg.sender == admin, "ReNFT::not admin");
        _;
    }

    modifier notPaused() {
        require(!paused, "ReNFT::paused");
        _;
    }

    constructor(
        address newResolver,
        address payable newBeneficiary,
        address newAdmin
    ) {
        ensureIsNotZeroAddr(newResolver);
        ensureIsNotZeroAddr(newBeneficiary);
        ensureIsNotZeroAddr(newAdmin);
        resolver = IResolver(newResolver);
        beneficiary = newBeneficiary;
        admin = newAdmin;
    }

    function lend(
        IRegistry.NFTStandard[] memory nftStandard,
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint256[] memory lendAmount,
        uint8[] memory maxRentDuration,
        bytes4[] memory dailyRentPrice,
        IResolver.PaymentToken[] memory paymentToken
    ) external override notPaused {
        bundleCall(
            handleLend,
            createLendCallData(
                nftStandard,
                nftAddress,
                tokenID,
                lendAmount,
                maxRentDuration,
                dailyRentPrice,
                paymentToken
            )
        );
    }

    function stopLend(
        IRegistry.NFTStandard[] memory nftStandard,
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint256[] memory _lendingID
    ) external override notPaused {
        bundleCall(
            handleStopLend,
            createActionCallData(
                nftStandard,
                nftAddress,
                tokenID,
                _lendingID,
                new uint256[](0)
            )
        );
    }

    function rent(
        IRegistry.NFTStandard[] memory nftStandard,
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint256[] memory _lendingID,
        uint8[] memory rentDuration,
        uint256[] memory rentAmount
    ) external payable override notPaused {
        bundleCall(
            handleRent,
            createRentCallData(
                nftStandard,
                nftAddress,
                tokenID,
                _lendingID,
                rentDuration,
                rentAmount
            )
        );
    }

    function stopRent(
        IRegistry.NFTStandard[] memory nftStandard,
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint256[] memory _lendingID,
        uint256[] memory _rentingID
    ) external override notPaused {
        bundleCall(
            handleStopRent,
            createActionCallData(
                nftStandard,
                nftAddress,
                tokenID,
                _lendingID,
                _rentingID
            )
        );
    }

    function claimRent(
        IRegistry.NFTStandard[] memory nftStandard,
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint256[] memory _lendingID,
        uint256[] memory _rentingID
    ) external override notPaused {
        bundleCall(
            handleClaimRent,
            createActionCallData(
                nftStandard,
                nftAddress,
                tokenID,
                _lendingID,
                _rentingID
            )
        );
    }


    function handleLend(IRegistry.CallData memory cd) private {
        for (uint256 i = cd.left; i < cd.right; i++) {
            ensureIsLendable(cd, i);
            bytes32 identifier = keccak256(
                abi.encodePacked(
                    cd.nftAddress[cd.left],
                    cd.tokenID[i],
                    lendingID
                )
            );
            IRegistry.Lending storage lending = lendings[identifier];
            ensureIsNull(lending);
            ensureTokenNotSentinel(uint8(cd.paymentToken[i]));
            bool is721 = cd.nftStandard[i] == IRegistry.NFTStandard.E721;
            lendings[identifier] = IRegistry.Lending({
                nftStandard: cd.nftStandard[i],
                lenderAddress: payable(msg.sender),
                maxRentDuration: cd.maxRentDuration[i],
                dailyRentPrice: cd.dailyRentPrice[i],
                lendAmount: is721 ? 1 : uint16(cd.lendAmount[i]),
                availableAmount: is721 ? 1 : uint16(cd.lendAmount[i]),
                paymentToken: cd.paymentToken[i]
            });
            emit IRegistry.Lend(
                is721,
                msg.sender,
                cd.nftAddress[cd.left],
                cd.tokenID[i],
                lendingID,
                cd.maxRentDuration[i],
                cd.dailyRentPrice[i],
                is721 ? 1 : uint16(cd.lendAmount[i]),
                cd.paymentToken[i]
            );
            lendingID++;
        }
        safeTransfer(
            cd,
            msg.sender,
            address(this),
            sliceArr(cd.tokenID, cd.left, cd.right, 0),
            sliceArr(cd.lendAmount, cd.left, cd.right, 0)
        );
    }

    function handleStopLend(IRegistry.CallData memory cd) private {
        uint256[] memory lentAmounts = new uint256[](cd.right - cd.left);
        for (uint256 i = cd.left; i < cd.right; i++) {
            bytes32 lendingIdentifier = keccak256(
                abi.encodePacked(
                    cd.nftAddress[cd.left],
                    cd.tokenID[i],
                    cd.lendingID[i]
                )
            );
            Lending storage lending = lendings[lendingIdentifier];
            ensureIsNotNull(lending);
            ensureIsStoppable(lending, msg.sender);
            require(
                cd.nftStandard[i] == lending.nftStandard,
                "ReNFT::invalid nft standard"
            );
            require(
                lending.lendAmount == lending.availableAmount,
                "ReNFT::actively rented"
            );
            lentAmounts[i - cd.left] = lending.lendAmount;
            emit IRegistry.StopLend(cd.lendingID[i], uint32(block.timestamp));
            delete lendings[lendingIdentifier];
        }
        safeTransfer(
            cd,
            address(this),
            msg.sender,
            sliceArr(cd.tokenID, cd.left, cd.right, 0),
            sliceArr(lentAmounts, cd.left, cd.right, cd.left)
        );
    }

    function handleRent(IRegistry.CallData memory cd) private {
        for (uint256 i = cd.left; i < cd.right; i++) {
            bytes32 lendingIdentifier = keccak256(
                abi.encodePacked(
                    cd.nftAddress[cd.left],
                    cd.tokenID[i],
                    cd.lendingID[i]
                )
            );
            bytes32 rentingIdentifier = keccak256(
                abi.encodePacked(
                    cd.nftAddress[cd.left],
                    cd.tokenID[i],
                    rentingID
                )
            );
            IRegistry.Lending storage lending = lendings[lendingIdentifier];
            IRegistry.Renting storage renting = rentings[rentingIdentifier];
            ensureIsNotNull(lending);
            ensureIsNull(renting);
            ensureIsRentable(lending, cd, i, msg.sender);
            require(
                cd.nftStandard[i] == lending.nftStandard,
                "ReNFT::invalid nft standard"
            );
            require(
                cd.rentAmount[i] <= lending.availableAmount,
                "ReNFT::invalid rent amount"
            );
            uint8 paymentTokenIx = uint8(lending.paymentToken);
            address paymentToken = resolver.getPaymentToken(paymentTokenIx);
            uint256 decimals = ERC20(paymentToken).decimals();
            {
                uint256 scale = 10**decimals;
                uint256 rentPrice = cd.rentAmount[i] *
                    cd.rentDuration[i] *
                    unpackPrice(lending.dailyRentPrice, scale);
                require(rentPrice > 0, "ReNFT::rent price is zero");
                ERC20(paymentToken).safeTransferFrom(
                    msg.sender,
                    address(this),
                    rentPrice
                );
            }
            rentings[rentingIdentifier] = IRegistry.Renting({
                renterAddress: payable(msg.sender),
                rentAmount: uint16(cd.rentAmount[i]),
                rentDuration: cd.rentDuration[i],
                rentedAt: uint32(block.timestamp)
            });
            lendings[lendingIdentifier].availableAmount -= uint16(
                cd.rentAmount[i]
            );
            emit IRegistry.Rent(
                msg.sender,
                cd.lendingID[i],
                rentingID,
                uint16(cd.rentAmount[i]),
                cd.rentDuration[i],
                renting.rentedAt
            );
            rentingID++;
        }
    }

    function handleStopRent(IRegistry.CallData memory cd) private {
        for (uint256 i = cd.left; i < cd.right; i++) {
            bytes32 lendingIdentifier = keccak256(
                abi.encodePacked(
                    cd.nftAddress[cd.left],
                    cd.tokenID[i],
                    cd.lendingID[i]
                )
            );
            bytes32 rentingIdentifier = keccak256(
                abi.encodePacked(
                    cd.nftAddress[cd.left],
                    cd.tokenID[i],
                    cd.rentingID[i]
                )
            );
            IRegistry.Lending storage lending = lendings[lendingIdentifier];
            IRegistry.Renting storage renting = rentings[rentingIdentifier];
            ensureIsNotNull(lending);
            ensureIsNotNull(renting);
            ensureIsReturnable(renting, msg.sender, block.timestamp);
            require(
                cd.nftStandard[i] == lending.nftStandard,
                "ReNFT::invalid nft standard"
            );
            require(
                renting.rentAmount <= lending.lendAmount,
                "ReNFT::critical error"
            );
            uint256 secondsSinceRentStart = block.timestamp - renting.rentedAt;
            distributePayments(lending, renting, secondsSinceRentStart);
            lendings[lendingIdentifier].availableAmount += renting.rentAmount;
            emit IRegistry.StopRent(cd.rentingID[i], uint32(block.timestamp));
            delete rentings[rentingIdentifier];
        }
    }

    function handleClaimRent(CallData memory cd) private {
        for (uint256 i = cd.left; i < cd.right; i++) {
            bytes32 lendingIdentifier = keccak256(
                abi.encodePacked(
                    cd.nftAddress[cd.left],
                    cd.tokenID[i],
                    cd.lendingID[i]
                )
            );
            bytes32 rentingIdentifier = keccak256(
                abi.encodePacked(
                    cd.nftAddress[cd.left],
                    cd.tokenID[i],
                    cd.rentingID[i]
                )
            );
            IRegistry.Lending storage lending = lendings[lendingIdentifier];
            IRegistry.Renting storage renting = rentings[rentingIdentifier];
            ensureIsNotNull(lending);
            ensureIsNotNull(renting);
            ensureIsClaimable(renting, block.timestamp);
            distributeClaimPayment(lending, renting);
            lending.availableAmount += renting.rentAmount;
            emit IRegistry.RentClaimed(
                cd.rentingID[i],
                uint32(block.timestamp)
            );
            delete rentings[rentingIdentifier];
        }
    }


    function bundleCall(
        function(IRegistry.CallData memory) handler,
        IRegistry.CallData memory cd
    ) private {
        require(cd.nftAddress.length > 0, "ReNFT::no nfts");
        while (cd.right != cd.nftAddress.length) {
            if (
                (cd.nftAddress[cd.left] == cd.nftAddress[cd.right]) &&
                (cd.nftStandard[cd.right] == IRegistry.NFTStandard.E1155)
            ) {
                cd.right++;
            } else {
                handler(cd);
                cd.left = cd.right;
                cd.right++;
            }
        }
        handler(cd);
    }

    function takeFee(uint256 rentAmt, IResolver.PaymentToken paymentToken)
        private
        returns (uint256 fee)
    {
        fee = rentAmt * rentFee;
        fee /= 10000;
        uint8 paymentTokenIx = uint8(paymentToken);
        ERC20 pmtToken = ERC20(resolver.getPaymentToken(paymentTokenIx));
        pmtToken.safeTransfer(beneficiary, fee);
    }

    function distributePayments(
        IRegistry.Lending memory lending,
        IRegistry.Renting memory renting,
        uint256 secondsSinceRentStart
    ) private {
        uint8 paymentTokenIx = uint8(lending.paymentToken);
        address pmtToken = resolver.getPaymentToken(paymentTokenIx);
        uint256 decimals = ERC20(pmtToken).decimals();
        uint256 scale = 10**decimals;
        uint256 rentPrice = renting.rentAmount *
            unpackPrice(lending.dailyRentPrice, scale);
        uint256 totalRenterPmt = rentPrice * renting.rentDuration;
        uint256 sendLenderAmt = (secondsSinceRentStart * rentPrice) /
            SECONDS_IN_DAY;
        require(totalRenterPmt > 0, "ReNFT::total renter payment is zero");
        require(sendLenderAmt > 0, "ReNFT::lender payment is zero");
        uint256 sendRenterAmt = totalRenterPmt - sendLenderAmt;
        if (rentFee != 0) {
            uint256 takenFee = takeFee(sendLenderAmt, lending.paymentToken);
            sendLenderAmt -= takenFee;
        }
        ERC20(pmtToken).safeTransfer(lending.lenderAddress, sendLenderAmt);
        if (sendRenterAmt > 0) {
            ERC20(pmtToken).safeTransfer(renting.renterAddress, sendRenterAmt);
        }
    }

    function distributeClaimPayment(
        IRegistry.Lending memory lending,
        IRegistry.Renting memory renting
    ) private {
        uint8 paymentTokenIx = uint8(lending.paymentToken);
        ERC20 paymentToken = ERC20(resolver.getPaymentToken(paymentTokenIx));
        uint256 decimals = ERC20(paymentToken).decimals();
        uint256 scale = 10**decimals;
        uint256 rentPrice = renting.rentAmount *
            unpackPrice(lending.dailyRentPrice, scale);
        uint256 finalAmt = rentPrice * renting.rentDuration;
        uint256 takenFee = 0;
        if (rentFee != 0) {
            takenFee = takeFee(
                finalAmt,
                IResolver.PaymentToken(paymentTokenIx)
            );
        }
        paymentToken.safeTransfer(lending.lenderAddress, finalAmt - takenFee);
    }

    function safeTransfer(
        CallData memory cd,
        address from,
        address to,
        uint256[] memory tokenID,
        uint256[] memory lendAmount
    ) private {
        if (cd.nftStandard[cd.left] == IRegistry.NFTStandard.E721) {
            IERC721(cd.nftAddress[cd.left]).transferFrom(
                from,
                to,
                cd.tokenID[cd.left]
            );
        } else {
            IERC1155(cd.nftAddress[cd.left]).safeBatchTransferFrom(
                from,
                to,
                tokenID,
                lendAmount,
                ""
            );
        }
    }


    function getLending(
        address nftAddress,
        uint256 tokenID,
        uint256 _lendingID
    )
        external
        view
        returns (
            uint8,
            address,
            uint8,
            bytes4,
            uint16,
            uint16,
            uint8
        )
    {
        bytes32 identifier = keccak256(
            abi.encodePacked(nftAddress, tokenID, _lendingID)
        );
        IRegistry.Lending storage lending = lendings[identifier];
        return (
            uint8(lending.nftStandard),
            lending.lenderAddress,
            lending.maxRentDuration,
            lending.dailyRentPrice,
            lending.lendAmount,
            lending.availableAmount,
            uint8(lending.paymentToken)
        );
    }

    function getRenting(
        address nftAddress,
        uint256 tokenID,
        uint256 _rentingID
    )
        external
        view
        returns (
            address,
            uint16,
            uint8,
            uint32
        )
    {
        bytes32 identifier = keccak256(
            abi.encodePacked(nftAddress, tokenID, _rentingID)
        );
        IRegistry.Renting storage renting = rentings[identifier];
        return (
            renting.renterAddress,
            renting.rentAmount,
            renting.rentDuration,
            renting.rentedAt
        );
    }


    function createLendCallData(
        IRegistry.NFTStandard[] memory nftStandard,
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint256[] memory lendAmount,
        uint8[] memory maxRentDuration,
        bytes4[] memory dailyRentPrice,
        IResolver.PaymentToken[] memory paymentToken
    ) private pure returns (CallData memory cd) {
        cd = CallData({
            left: 0,
            right: 1,
            nftStandard: nftStandard,
            nftAddress: nftAddress,
            tokenID: tokenID,
            lendAmount: lendAmount,
            lendingID: new uint256[](0),
            rentingID: new uint256[](0),
            rentDuration: new uint8[](0),
            rentAmount: new uint256[](0),
            maxRentDuration: maxRentDuration,
            dailyRentPrice: dailyRentPrice,
            paymentToken: paymentToken
        });
    }

    function createRentCallData(
        IRegistry.NFTStandard[] memory nftStandard,
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint256[] memory _lendingID,
        uint8[] memory rentDuration,
        uint256[] memory rentAmount
    ) private pure returns (CallData memory cd) {
        cd = CallData({
            left: 0,
            right: 1,
            nftStandard: nftStandard,
            nftAddress: nftAddress,
            tokenID: tokenID,
            lendAmount: new uint256[](0),
            lendingID: _lendingID,
            rentingID: new uint256[](0),
            rentDuration: rentDuration,
            rentAmount: rentAmount,
            maxRentDuration: new uint8[](0),
            dailyRentPrice: new bytes4[](0),
            paymentToken: new IResolver.PaymentToken[](0)
        });
    }

    function createActionCallData(
        IRegistry.NFTStandard[] memory nftStandard,
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint256[] memory _lendingID,
        uint256[] memory _rentingID
    ) private pure returns (CallData memory cd) {
        cd = CallData({
            left: 0,
            right: 1,
            nftStandard: nftStandard,
            nftAddress: nftAddress,
            tokenID: tokenID,
            lendAmount: new uint256[](0),
            lendingID: _lendingID,
            rentingID: _rentingID,
            rentDuration: new uint8[](0),
            rentAmount: new uint256[](0),
            maxRentDuration: new uint8[](0),
            dailyRentPrice: new bytes4[](0),
            paymentToken: new IResolver.PaymentToken[](0)
        });
    }

    function unpackPrice(bytes4 price, uint256 scale)
        private
        pure
        returns (uint256)
    {
        ensureIsUnpackablePrice(price, scale);
        uint16 whole = uint16(bytes2(price));
        uint16 decimal = uint16(bytes2(price << 16));
        uint256 decimalScale = scale / 10000;
        if (whole > 9999) {
            whole = 9999;
        }
        if (decimal > 9999) {
            decimal = 9999;
        }
        uint256 w = whole * scale;
        uint256 d = decimal * decimalScale;
        uint256 fullPrice = w + d;
        return fullPrice;
    }

    function sliceArr(
        uint256[] memory arr,
        uint256 fromIx,
        uint256 toIx,
        uint256 arrOffset
    ) private pure returns (uint256[] memory r) {
        r = new uint256[](toIx - fromIx);
        for (uint256 i = fromIx; i < toIx; i++) {
            r[i - fromIx] = arr[i - arrOffset];
        }
    }


    function ensureIsNotZeroAddr(address addr) private pure {
        require(addr != address(0), "ReNFT::zero address");
    }

    function ensureIsZeroAddr(address addr) private pure {
        require(addr == address(0), "ReNFT::not a zero address");
    }

    function ensureIsNull(Lending memory lending) private pure {
        ensureIsZeroAddr(lending.lenderAddress);
        require(lending.maxRentDuration == 0, "ReNFT::duration not zero");
        require(lending.dailyRentPrice == 0, "ReNFT::rent price not zero");
    }

    function ensureIsNotNull(Lending memory lending) private pure {
        ensureIsNotZeroAddr(lending.lenderAddress);
        require(lending.maxRentDuration != 0, "ReNFT::duration zero");
        require(lending.dailyRentPrice != 0, "ReNFT::rent price is zero");
    }

    function ensureIsNull(Renting memory renting) private pure {
        ensureIsZeroAddr(renting.renterAddress);
        require(renting.rentDuration == 0, "ReNFT::duration not zero");
        require(renting.rentedAt == 0, "ReNFT::rented at not zero");
    }

    function ensureIsNotNull(Renting memory renting) private pure {
        ensureIsNotZeroAddr(renting.renterAddress);
        require(renting.rentDuration != 0, "ReNFT::duration is zero");
        require(renting.rentedAt != 0, "ReNFT::rented at is zero");
    }

    function ensureIsLendable(CallData memory cd, uint256 i) private pure {
        require(cd.lendAmount[i] > 0, "ReNFT::lend amount is zero");
        require(cd.lendAmount[i] <= type(uint16).max, "ReNFT::not uint16");
        require(cd.maxRentDuration[i] > 0, "ReNFT::duration is zero");
        require(cd.maxRentDuration[i] <= type(uint8).max, "ReNFT::not uint8");
        require(uint32(cd.dailyRentPrice[i]) > 0, "ReNFT::rent price is zero");
    }

    function ensureIsRentable(
        Lending memory lending,
        CallData memory cd,
        uint256 i,
        address msgSender
    ) private pure {
        require(msgSender != lending.lenderAddress, "ReNFT::cant rent own nft");
        require(cd.rentDuration[i] <= type(uint8).max, "ReNFT::not uint8");
        require(cd.rentDuration[i] > 0, "ReNFT::duration is zero");
        require(cd.rentAmount[i] <= type(uint16).max, "ReNFT::not uint16");
        require(cd.rentAmount[i] > 0, "ReNFT::rentAmount is zero");
        require(
            cd.rentDuration[i] <= lending.maxRentDuration,
            "ReNFT::rent duration exceeds allowed max"
        );
    }

    function ensureIsReturnable(
        Renting memory renting,
        address msgSender,
        uint256 blockTimestamp
    ) private pure {
        require(renting.renterAddress == msgSender, "ReNFT::not renter");
        require(
            !isPastReturnDate(renting, blockTimestamp),
            "ReNFT::past return date"
        );
    }

    function ensureIsStoppable(Lending memory lending, address msgSender)
        private
        pure
    {
        require(lending.lenderAddress == msgSender, "ReNFT::not lender");
    }

    function ensureIsUnpackablePrice(bytes4 price, uint256 scale) private pure {
        require(uint32(price) > 0, "ReNFT::invalid price");
        require(scale >= 10000, "ReNFT::invalid scale");
    }

    function ensureTokenNotSentinel(uint8 paymentIx) private pure {
        require(paymentIx > 0, "ReNFT::token is sentinel");
    }

    function ensureIsClaimable(
        IRegistry.Renting memory renting,
        uint256 blockTimestamp
    ) private pure {
        require(
            isPastReturnDate(renting, blockTimestamp),
            "ReNFT::return date not passed"
        );
    }

    function isPastReturnDate(Renting memory renting, uint256 nowTime)
        private
        pure
        returns (bool)
    {
        require(nowTime > renting.rentedAt, "ReNFT::now before rented");
        return
            nowTime - renting.rentedAt > renting.rentDuration * SECONDS_IN_DAY;
    }


    function setRentFee(uint256 newRentFee) external onlyAdmin {
        require(newRentFee < 10000, "ReNFT::fee exceeds 100pct");
        rentFee = newRentFee;
    }

    function setBeneficiary(address payable newBeneficiary) external onlyAdmin {
        beneficiary = newBeneficiary;
    }

    function setPaused(bool newPaused) external onlyAdmin {
        paused = newPaused;
    }
}