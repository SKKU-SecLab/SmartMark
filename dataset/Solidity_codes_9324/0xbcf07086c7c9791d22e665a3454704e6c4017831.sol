pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, 'SafeMath: division by zero');
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, 'SafeMath: modulo by zero');
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity ^0.5.0;

library Strings {


    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function strConcat(string memory _a, string memory _b)
        internal
        pure
        returns (string memory _concatenatedString)
    {

        return strConcat(_a, _b, '', '', '');
    }

    function strConcat(
        string memory _a,
        string memory _b,
        string memory _c
    ) internal pure returns (string memory _concatenatedString) {

        return strConcat(_a, _b, _c, '', '');
    }

    function strConcat(
        string memory _a,
        string memory _b,
        string memory _c,
        string memory _d
    ) internal pure returns (string memory _concatenatedString) {

        return strConcat(_a, _b, _c, _d, '');
    }

    function strConcat(
        string memory _a,
        string memory _b,
        string memory _c,
        string memory _d,
        string memory _e
    ) internal pure returns (string memory _concatenatedString) {

        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(
            _ba.length + _bb.length + _bc.length + _bd.length + _be.length
        );
        bytes memory babcde = bytes(abcde);
        uint256 k = 0;
        uint256 i = 0;
        for (i = 0; i < _ba.length; i++) {
            babcde[k++] = _ba[i];
        }
        for (i = 0; i < _bb.length; i++) {
            babcde[k++] = _bb[i];
        }
        for (i = 0; i < _bc.length; i++) {
            babcde[k++] = _bc[i];
        }
        for (i = 0; i < _bd.length; i++) {
            babcde[k++] = _bd[i];
        }
        for (i = 0; i < _be.length; i++) {
            babcde[k++] = _be[i];
        }
        return string(babcde);
    }

    function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {

        if (_i == 0) {
            return '0';
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }
}

pragma solidity ^0.5.0;

contract Context {

    constructor() internal {}


    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
pragma solidity ^0.5.0;

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
pragma solidity ^0.5.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                'ERC20: transfer amount exceeds allowance'
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                'ERC20: decreased allowance below zero'
            )
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {

        require(sender != address(0), 'ERC20: transfer from the zero address');
        require(recipient != address(0), 'ERC20: transfer to the zero address');

        _balances[sender] = _balances[sender].sub(amount, 'ERC20: transfer amount exceeds balance');
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), 'ERC20: mint to the zero address');

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), 'ERC20: burn from the zero address');

        _balances[account] = _balances[account].sub(amount, 'ERC20: burn amount exceeds balance');
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {

        require(owner != address(0), 'ERC20: approve from the zero address');
        require(spender != address(0), 'ERC20: approve to the zero address');

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(amount, 'ERC20: burn amount exceeds allowance')
        );
    }
}
pragma solidity ^0.5.0;

interface IGenArt721CoreV2 {

    function isWhitelisted(address sender) external view returns (bool);


    function admin() external view returns (address);


    function projectIdToCurrencySymbol(uint256 _projectId) external view returns (string memory);


    function projectIdToCurrencyAddress(uint256 _projectId) external view returns (address);


    function projectIdToArtistAddress(uint256 _projectId) external view returns (address payable);


    function projectIdToPricePerTokenInWei(uint256 _projectId) external view returns (uint256);


    function projectIdToAdditionalPayee(uint256 _projectId) external view returns (address payable);


    function projectIdToAdditionalPayeePercentage(uint256 _projectId)
        external
        view
        returns (uint256);


    function projectTokenInfo(uint256 _projectId)
        external
        view
        returns (
            address,
            uint256,
            uint256,
            uint256,
            bool,
            address,
            uint256,
            string memory,
            address
        );


    function renderProviderAddress() external view returns (address payable);


    function renderProviderPercentage() external view returns (uint256);


    function mint(
        address _to,
        uint256 _projectId,
        address _by
    ) external returns (uint256 tokenId);


    function ownerOf(uint256 tokenId) external view returns (address);


    function tokenIdToProjectId(uint256 tokenId) external view returns (uint256);

}

pragma solidity ^0.5.0;


interface BonusContract {

    function triggerBonus(address _to) external returns (bool);


    function bonusIsActive() external view returns (bool);

}

contract GenArt721Minter_DoodleLabs {

    using SafeMath for uint256;

    IGenArt721CoreV2 public genArtCoreContract;

    uint256 constant ONE_MILLION = 1_000_000;

    address payable public ownerAddress;
    uint256 public ownerPercentage;

    mapping(uint256 => bool) public projectIdToBonus;
    mapping(uint256 => address) public projectIdToBonusContractAddress;
    mapping(uint256 => bool) public contractFilterProject;
    mapping(address => mapping(uint256 => uint256)) public projectMintCounter;
    mapping(uint256 => uint256) public projectMintLimit;
    mapping(uint256 => bool) public projectMaxHasBeenInvoked;
    mapping(uint256 => uint256) public projectMaxInvocations;

    constructor(address _genArt721Address) public {
        genArtCoreContract = IGenArt721CoreV2(_genArt721Address);
    }

    function getYourBalanceOfProjectERC20(uint256 _projectId) public view returns (uint256) {

        uint256 balance = ERC20(genArtCoreContract.projectIdToCurrencyAddress(_projectId))
            .balanceOf(msg.sender);
        return balance;
    }

    function checkYourAllowanceOfProjectERC20(uint256 _projectId) public view returns (uint256) {

        uint256 remaining = ERC20(genArtCoreContract.projectIdToCurrencyAddress(_projectId))
            .allowance(msg.sender, address(this));
        return remaining;
    }

    function setProjectMintLimit(uint256 _projectId, uint8 _limit) public {

        require(genArtCoreContract.isWhitelisted(msg.sender), 'can only be set by admin');
        projectMintLimit[_projectId] = _limit;
    }

    function setProjectMaxInvocations(uint256 _projectId) public {

        require(genArtCoreContract.isWhitelisted(msg.sender), 'can only be set by admin');
        uint256 maxInvocations;
        uint256 invocations;
        (, , invocations, maxInvocations, , , , , ) = genArtCoreContract.projectTokenInfo(
            _projectId
        );
        projectMaxInvocations[_projectId] = maxInvocations;
        if (invocations < maxInvocations) {
            projectMaxHasBeenInvoked[_projectId] = false;
        }
    }

    function setOwnerAddress(address payable _ownerAddress) public {

        require(genArtCoreContract.isWhitelisted(msg.sender), 'can only be set by admin');
        ownerAddress = _ownerAddress;
    }

    function setOwnerPercentage(uint256 _ownerPercentage) public {

        require(genArtCoreContract.isWhitelisted(msg.sender), 'can only be set by admin');
        ownerPercentage = _ownerPercentage;
    }

    function toggleContractFilter(uint256 _projectId) public {

        require(genArtCoreContract.isWhitelisted(msg.sender), 'can only be set by admin');
        contractFilterProject[_projectId] = !contractFilterProject[_projectId];
    }

    function artistToggleBonus(uint256 _projectId) public {

        require(
            msg.sender == genArtCoreContract.projectIdToArtistAddress(_projectId),
            'can only be set by artist'
        );
        projectIdToBonus[_projectId] = !projectIdToBonus[_projectId];
    }

    function artistSetBonusContractAddress(uint256 _projectId, address _bonusContractAddress)
        public
    {

        require(
            msg.sender == genArtCoreContract.projectIdToArtistAddress(_projectId),
            'can only be set by artist'
        );
        projectIdToBonusContractAddress[_projectId] = _bonusContractAddress;
    }

    function purchase(uint256 _projectId) internal returns (uint256 _tokenId) {

        return purchaseTo(msg.sender, _projectId, false);
    }

    function purchaseTo(
        address _to,
        uint256 _projectId,
        bool _isDeferredRefund
    ) internal returns (uint256 _tokenId) {

        require(!projectMaxHasBeenInvoked[_projectId], 'Maximum number of invocations reached');
        if (
            keccak256(abi.encodePacked(genArtCoreContract.projectIdToCurrencySymbol(_projectId))) !=
            keccak256(abi.encodePacked('ETH'))
        ) {
            require(
                msg.value == 0,
                'this project accepts a different currency and cannot accept ETH'
            );
            require(
                ERC20(genArtCoreContract.projectIdToCurrencyAddress(_projectId)).allowance(
                    msg.sender,
                    address(this)
                ) >= genArtCoreContract.projectIdToPricePerTokenInWei(_projectId),
                'Insufficient Funds Approved for TX'
            );
            require(
                ERC20(genArtCoreContract.projectIdToCurrencyAddress(_projectId)).balanceOf(
                    msg.sender
                ) >= genArtCoreContract.projectIdToPricePerTokenInWei(_projectId),
                'Insufficient balance.'
            );
            _splitFundsERC20(_projectId);
        } else {
            require(
                msg.value >= genArtCoreContract.projectIdToPricePerTokenInWei(_projectId),
                'Must send minimum value to mint!'
            );
            _splitFundsETH(_projectId, _isDeferredRefund);
        }

        if (contractFilterProject[_projectId]) require(msg.sender == tx.origin, 'No Contract Buys');

        if (projectMintLimit[_projectId] > 0) {
            require(
                projectMintCounter[msg.sender][_projectId] < projectMintLimit[_projectId],
                'Reached minting limit'
            );
            projectMintCounter[msg.sender][_projectId]++;
        }

        uint256 tokenId = genArtCoreContract.mint(_to, _projectId, msg.sender);

        if (tokenId % ONE_MILLION == projectMaxInvocations[_projectId] - 1) {
            projectMaxHasBeenInvoked[_projectId] = true;
        }

        if (projectIdToBonus[_projectId]) {
            require(
                BonusContract(projectIdToBonusContractAddress[_projectId]).bonusIsActive(),
                'bonus must be active'
            );
            BonusContract(projectIdToBonusContractAddress[_projectId]).triggerBonus(msg.sender);
        }

        return tokenId;
    }

    function _splitFundsETH(uint256 _projectId, bool _isDeferredRefund) internal {

        if (msg.value > 0) {
            uint256 pricePerTokenInWei = genArtCoreContract.projectIdToPricePerTokenInWei(
                _projectId
            );
            uint256 refund = msg.value.sub(
                genArtCoreContract.projectIdToPricePerTokenInWei(_projectId)
            );
            if (!_isDeferredRefund && refund > 0) {
                msg.sender.transfer(refund);
            }
            uint256 renderProviderAmount = pricePerTokenInWei.div(100).mul(
                genArtCoreContract.renderProviderPercentage()
            );
            if (renderProviderAmount > 0) {
                genArtCoreContract.renderProviderAddress().transfer(renderProviderAmount);
            }

            uint256 remainingFunds = pricePerTokenInWei.sub(renderProviderAmount);

            uint256 ownerFunds = remainingFunds.div(100).mul(ownerPercentage);
            if (ownerFunds > 0) {
                ownerAddress.transfer(ownerFunds);
            }

            uint256 projectFunds = pricePerTokenInWei.sub(renderProviderAmount).sub(ownerFunds);
            uint256 additionalPayeeAmount;
            if (genArtCoreContract.projectIdToAdditionalPayeePercentage(_projectId) > 0) {
                additionalPayeeAmount = projectFunds.div(100).mul(
                    genArtCoreContract.projectIdToAdditionalPayeePercentage(_projectId)
                );
                if (additionalPayeeAmount > 0) {
                    genArtCoreContract.projectIdToAdditionalPayee(_projectId).transfer(
                        additionalPayeeAmount
                    );
                }
            }
            uint256 creatorFunds = projectFunds.sub(additionalPayeeAmount);
            if (creatorFunds > 0) {
                genArtCoreContract.projectIdToArtistAddress(_projectId).transfer(creatorFunds);
            }
        }
    }

    function _splitFundsERC20(uint256 _projectId) internal {

        uint256 pricePerTokenInWei = genArtCoreContract.projectIdToPricePerTokenInWei(_projectId);
        uint256 renderProviderAmount = pricePerTokenInWei.div(100).mul(
            genArtCoreContract.renderProviderPercentage()
        );
        if (renderProviderAmount > 0) {
            ERC20(genArtCoreContract.projectIdToCurrencyAddress(_projectId)).transferFrom(
                msg.sender,
                genArtCoreContract.renderProviderAddress(),
                renderProviderAmount
            );
        }
        uint256 remainingFunds = pricePerTokenInWei.sub(renderProviderAmount);

        uint256 ownerFunds = remainingFunds.div(100).mul(ownerPercentage);
        if (ownerFunds > 0) {
            ERC20(genArtCoreContract.projectIdToCurrencyAddress(_projectId)).transferFrom(
                msg.sender,
                ownerAddress,
                ownerFunds
            );
        }

        uint256 projectFunds = pricePerTokenInWei.sub(renderProviderAmount).sub(ownerFunds);
        uint256 additionalPayeeAmount;
        if (genArtCoreContract.projectIdToAdditionalPayeePercentage(_projectId) > 0) {
            additionalPayeeAmount = projectFunds.div(100).mul(
                genArtCoreContract.projectIdToAdditionalPayeePercentage(_projectId)
            );
            if (additionalPayeeAmount > 0) {
                ERC20(genArtCoreContract.projectIdToCurrencyAddress(_projectId)).transferFrom(
                    msg.sender,
                    genArtCoreContract.projectIdToAdditionalPayee(_projectId),
                    additionalPayeeAmount
                );
            }
        }
        uint256 creatorFunds = projectFunds.sub(additionalPayeeAmount);
        if (creatorFunds > 0) {
            ERC20(genArtCoreContract.projectIdToCurrencyAddress(_projectId)).transferFrom(
                msg.sender,
                genArtCoreContract.projectIdToArtistAddress(_projectId),
                creatorFunds
            );
        }
    }
}
pragma solidity ^0.5.0;


contract GenArt721Minter_DoodleLabs_MultiMinter is GenArt721Minter_DoodleLabs {

    using SafeMath for uint256;

    event PurchaseMany(uint256 projectId, uint256 amount);
    event Purchase(uint256 _projectId);

    constructor(address _genArtCore) internal GenArt721Minter_DoodleLabs(_genArtCore) {}

    function _purchaseManyTo(
        address to,
        uint256 projectId,
        uint256 amount
    ) internal returns (uint256[] memory _tokenIds) {

        uint256[] memory tokenIds = new uint256[](amount);
        bool isDeferredRefund = false;

        if (msg.value > 0) {
            uint256 pricePerTokenInWei = genArtCoreContract.projectIdToPricePerTokenInWei(
                projectId
            );
            require(msg.value >= pricePerTokenInWei.mul(amount), 'not enough funds transferred');
            uint256 refund = msg.value.sub(pricePerTokenInWei.mul(amount));
            isDeferredRefund = true;

            if (refund > 0) {
                address payable _to = address(uint160(to));
                _to.transfer(refund);
            }
        }

        for (uint256 i = 0; i < amount; i++) {
            tokenIds[i] = purchaseTo(to, projectId, isDeferredRefund);
            emit Purchase(projectId);
        }

        return tokenIds;
    }

    function _purchase(uint256 _projectId) internal returns (uint256 _tokenId) {

        emit Purchase(_projectId);
        return purchaseTo(msg.sender, _projectId, false);
    }
}

pragma solidity ^0.5.0;

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {

        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}pragma solidity ^0.5.0;


interface IGenArt721Minter_DoodleLabs_Config {

    function getPurchaseManyLimit(uint256 projectId) external view returns (uint256 limit);


    function getState(uint256 projectId) external view returns (uint256 _state);


    function setStateFamilyCollectors(uint256 projectId) external;


    function setStateRedemption(uint256 projectId) external;


    function setStatePublic(uint256 projectId) external;

}

interface IGenArt721Minter_DoodleLabs_WhiteList {

    function getMerkleRoot(uint256 projectId) external view returns (bytes32 merkleRoot);


    function getWhitelisted(uint256 projectId, address user) external view returns (uint256 amount);


    function addWhitelist(
        uint256 projectId,
        address[] calldata users,
        uint256[] calldata amounts
    ) external;


    function increaseAmount(
        uint256 projectId,
        address to,
        uint256 quantity
    ) external;

}

contract GenArt721Minter_DoodleLabs_Custom_Sale is GenArt721Minter_DoodleLabs_MultiMinter {

    using SafeMath for uint256;

    event Redeem(uint256 projectId);

    enum SaleState {
        FAMILY_COLLECTORS,
        REDEMPTION,
        PUBLIC
    }

    IGenArt721Minter_DoodleLabs_WhiteList public activeWhitelist;
    IGenArt721Minter_DoodleLabs_Config public minterState;

    modifier onlyWhitelisted() {

        require(genArtCoreContract.isWhitelisted(msg.sender), 'can only be set by admin');
        _;
    }

    modifier notRedemptionState(uint256 projectId) {

        require(
            uint256(minterState.getState(projectId)) != uint256(SaleState.REDEMPTION),
            'can not purchase in redemption phase'
        );
        _;
    }

    modifier onlyRedemptionState(uint256 projectId) {

        require(
            uint256(minterState.getState(projectId)) == uint256(SaleState.REDEMPTION),
            'not in redemption phase'
        );
        _;
    }

    constructor(address _genArtCore, address _minterStateAddress)
        public
        GenArt721Minter_DoodleLabs_MultiMinter(_genArtCore)
    {
        minterState = IGenArt721Minter_DoodleLabs_Config(_minterStateAddress);
    }

    function getMerkleRoot(uint256 projectId) public view returns (bytes32 merkleRoot) {

        require(address(activeWhitelist) != address(0), 'Active whitelist not set');
        return activeWhitelist.getMerkleRoot(projectId);
    }

    function getWhitelisted(uint256 projectId, address user)
        external
        view
        returns (uint256 amount)
    {

        require(address(activeWhitelist) != address(0), 'Active whitelist not set');
        return activeWhitelist.getWhitelisted(projectId, user);
    }

    function setActiveWhitelist(address whitelist) public onlyWhitelisted {

        activeWhitelist = IGenArt721Minter_DoodleLabs_WhiteList(whitelist);
    }

    function purchase(uint256 projectId, uint256 quantity)
        public
        payable
        notRedemptionState(projectId)
        returns (uint256[] memory _tokenIds)
    {

        return purchaseTo(msg.sender, projectId, quantity);
    }

    function purchaseTo(
        address to,
        uint256 projectId,
        uint256 quantity
    ) public payable notRedemptionState(projectId) returns (uint256[] memory _tokenIds) {

        require(
            quantity <= minterState.getPurchaseManyLimit(projectId),
            'Max purchase many limit reached'
        );
        if (
            uint256(minterState.getState(projectId)) == uint256(SaleState.FAMILY_COLLECTORS) &&
            msg.value > 0
        ) {
            require(false, 'ETH not accepted at this time');
        }
        return _purchaseManyTo(to, projectId, quantity);
    }

    function redeem(
        uint256 projectId,
        uint256 quantity,
        uint256 allottedAmount,
        bytes32[] memory proof
    ) public payable onlyRedemptionState(projectId) returns (uint256[] memory _tokenIds) {

        return redeemTo(msg.sender, projectId, quantity, allottedAmount, proof);
    }

    function redeemTo(
        address to,
        uint256 projectId,
        uint256 quantity,
        uint256 allottedAmount,
        bytes32[] memory proof
    ) public payable onlyRedemptionState(projectId) returns (uint256[] memory _tokenIds) {

        require(address(activeWhitelist) != address(0), 'Active whitelist not set');
        require(
            activeWhitelist.getWhitelisted(projectId, to).add(quantity) <= allottedAmount,
            'Address has already claimed'
        );

        string memory key = _addressToString(to);
        key = _appendStrings(key, Strings.toString(allottedAmount), Strings.toString(projectId));

        bytes32 leaf = keccak256(abi.encodePacked(key));
        require(MerkleProof.verify(proof, getMerkleRoot(projectId), leaf), 'Invalid proof');

        uint256[] memory createdTokens = _purchaseManyTo(to, projectId, quantity);

        activeWhitelist.increaseAmount(projectId, to, quantity);

        emit Redeem(projectId);
        return createdTokens;
    }

    function _appendStrings(
        string memory a,
        string memory b,
        string memory c
    ) internal pure returns (string memory) {

        return string(abi.encodePacked(a, '::', b, '::', c));
    }

    function _addressToString(address addr) private pure returns (string memory) {

        bytes memory addressBytes = abi.encodePacked(addr);

        bytes memory stringBytes = new bytes(42);

        stringBytes[0] = '0';
        stringBytes[1] = 'x';

        for (uint256 i = 0; i < 20; i++) {
            uint8 leftValue = uint8(addressBytes[i]) / 16;
            uint8 rightValue = uint8(addressBytes[i]) - 16 * leftValue;

            bytes1 leftChar = leftValue < 10 ? bytes1(leftValue + 48) : bytes1(leftValue + 87);
            bytes1 rightChar = rightValue < 10 ? bytes1(rightValue + 48) : bytes1(rightValue + 87);

            stringBytes[2 * i + 3] = rightChar;
            stringBytes[2 * i + 2] = leftChar;

        }

        return string(stringBytes);
    }
}

pragma solidity ^0.5.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

pragma solidity ^0.5.0;


library Counters {

    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {

        counter._value = counter._value.sub(1);
    }
}
pragma solidity ^0.5.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

pragma solidity ^0.5.0;


contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor() internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff, 'ERC165: invalid interface id');
        _supportedInterfaces[interfaceId] = true;
    }
}

pragma solidity ^0.5.0;


contract IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);


    function ownerOf(uint256 tokenId) public view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public;


    function approve(address to, uint256 tokenId) public;


    function getApproved(uint256 tokenId) public view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) public;


    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public;

}

pragma solidity ^0.5.0;

contract IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) public returns (bytes4);

}

pragma solidity ^0.5.0;


contract ERC721 is ERC165, IERC721 {

    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping(uint256 => address) private _tokenOwner;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => Counters.Counter) private _ownedTokensCount;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    constructor() public {
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    function balanceOf(address owner) public view returns (uint256) {

        require(owner != address(0), 'ERC721: balance query for the zero address');

        return _ownedTokensCount[owner].current();
    }

    function ownerOf(uint256 tokenId) public view returns (address) {

        address owner = _tokenOwner[tokenId];
        require(owner != address(0), 'ERC721: owner query for nonexistent token');

        return owner;
    }

    function approve(address to, uint256 tokenId) public {

        address owner = ownerOf(tokenId);
        require(to != owner, 'ERC721: approval to current owner');

        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            'ERC721: approve caller is not owner nor approved for all'
        );

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {

        require(_exists(tokenId), 'ERC721: approved query for nonexistent token');

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address to, bool approved) public {

        require(to != msg.sender, 'ERC721: approve to caller');

        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {

        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            'ERC721: transfer caller is not owner nor approved'
        );

        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {

        safeTransferFrom(from, to, tokenId, '');
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public {

        transferFrom(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            'ERC721: transfer to non ERC721Receiver implementer'
        );
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        require(_exists(tokenId), 'ERC721: operator query for nonexistent token');
        address owner = ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }

    function _mint(address to, uint256 tokenId) internal {

        require(to != address(0), 'ERC721: mint to the zero address');
        require(!_exists(tokenId), 'ERC721: token already minted');

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {

        require(ownerOf(tokenId) == owner, 'ERC721: burn of token that is not own');

        _clearApproval(tokenId);

        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    function _burn(uint256 tokenId) internal {

        _burn(ownerOf(tokenId), tokenId);
    }

    function _transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) internal {

        require(ownerOf(tokenId) == from, 'ERC721: transfer of token that is not own');
        require(to != address(0), 'ERC721: transfer to the zero address');

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal returns (bool) {

        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    function _clearApproval(uint256 tokenId) private {

        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}

pragma solidity ^0.5.0;


contract IERC721Enumerable is IERC721 {

    function totalSupply() public view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        returns (uint256 tokenId);


    function tokenByIndex(uint256 index) public view returns (uint256);

}

pragma solidity ^0.5.0;


contract ERC721Enumerable is ERC165, ERC721, IERC721Enumerable {

    mapping(address => uint256[]) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor() public {
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {

        require(index < balanceOf(owner), 'ERC721Enumerable: owner index out of bounds');
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view returns (uint256) {

        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {

        require(index < totalSupply(), 'ERC721Enumerable: global index out of bounds');
        return _allTokens[index];
    }

    function _transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) internal {

        super._transferFrom(from, to, tokenId);

        _removeTokenFromOwnerEnumeration(from, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);
    }

    function _mint(address to, uint256 tokenId) internal {

        super._mint(to, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {

        super._burn(owner, tokenId);

        _removeTokenFromOwnerEnumeration(owner, tokenId);
        _ownedTokensIndex[tokenId] = 0;

        _removeTokenFromAllTokensEnumeration(tokenId);
    }

    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {

        return _ownedTokens[owner];
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {

        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {

        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {


        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        _ownedTokens[from].length--;

    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {


        uint256 lastTokenIndex = _allTokens.length.sub(1);
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        _allTokens.length--;
        _allTokensIndex[tokenId] = 0;
    }
}

pragma solidity ^0.5.0;


contract CustomERC721Metadata is ERC165, ERC721, ERC721Enumerable {

    string private _name;

    string private _symbol;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    function name() external view returns (string memory) {

        return _name;
    }

    function symbol() external view returns (string memory) {

        return _symbol;
    }
}
pragma solidity ^0.5.0;

contract Randomizer {

    function returnValue() public view returns (bytes32) {

        uint256 time = block.timestamp;
        uint256 extra = (time % 200) + 1;

        return keccak256(abi.encodePacked(block.number, blockhash(block.number - 2), time, extra));
    }
}
