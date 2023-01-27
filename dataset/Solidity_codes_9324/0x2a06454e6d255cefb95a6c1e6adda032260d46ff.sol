

pragma solidity 0.8.1;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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


contract ERC20 is Context, IERC20 {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}


abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        _approve(account, _msgSender(), currentAllowance - amount);
        _burn(account, amount);
    }
}


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}


interface IERC1155 is IERC165 {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}


contract AccessControl
{
    mapping (address=>bool) ownerAddress;
    mapping (address=>bool) operatorAddress;

    constructor() {
        ownerAddress[msg.sender] = true;
    }

    modifier onlyOwner() {
        require(ownerAddress[msg.sender], "Access denied");
        _;
    }

    function isOwner(address _addr) public view returns (bool) {
        return ownerAddress[_addr];
    }

    function addOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "New owner is empty");

        ownerAddress[_newOwner] = true;
    }

    function setOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "New owner is empty");

        ownerAddress[_newOwner] = true;
        delete(ownerAddress[msg.sender]);
    }

    function removeOwner(address _oldOwner) external onlyOwner {
        delete(ownerAddress[_oldOwner]);
    }

    modifier onlyOperator() {
        require(isOperator(msg.sender), "Access denied");
        _;
    }

    function isOperator(address _addr) public view returns (bool) {
        return operatorAddress[_addr] || ownerAddress[_addr];
    }

    function addOperator(address _newOperator) external onlyOwner {
        require(_newOperator != address(0), "New operator is empty");

        operatorAddress[_newOperator] = true;
    }

    function removeOperator(address _oldOperator) external onlyOwner {
        delete(operatorAddress[_oldOperator]);
    }

    function withdrawERC20(
        IERC20 _tokenContract,
        address _withdrawToAddress
    )
        external
        onlyOperator
    {
        uint256 balance = _tokenContract.balanceOf(address(this));
        _tokenContract.transfer(_withdrawToAddress, balance);
    }

    function approveERC721(IERC721 _tokenContract, address _approveToAddress)
        external
        onlyOperator
    {
        _tokenContract.setApprovalForAll(_approveToAddress, true);
    }

    function approveERC1155(IERC1155 _tokenContract, address _approveToAddress)
        external
        onlyOperator
    {
        _tokenContract.setApprovalForAll(_approveToAddress, true);
    }

    function withdrawEth(address payable _withdrawToAddress)
        external
        onlyOperator
    {
        if (address(this).balance > 0) {
            _withdrawToAddress.transfer(address(this).balance);
        }
    }
}


interface IERC827  {
    function approveAndCall(address _spender, uint256 _value, bytes memory _data)
        external
        returns (bool);
}


interface IERC223  {
    function transfer(address _to, uint _value, bytes calldata _data)
        external
        returns (bool success);
}


interface IERC20Bulk  {
    function transferBulk(address[] calldata to, uint[] calldata tokens) external;
    function approveBulk(address[] calldata spender, uint[] calldata tokens) external;
}


interface IFungibleToken is IERC20, IERC827, IERC223, IERC20Bulk {

    function mint(address target, uint256 mintedAmount) external;

    function mintBulk(address[] calldata target, uint256[] calldata mintedAmount) external;

    function mintAddDecimals(address target, uint256 mintedAmountWithoutDecimals) external;

    function mintAddDecimalsBulk(
        address[] calldata targets,
        uint256[] calldata mintedAmountWithoutDecimals
    )
        external;
}


interface TokenRecipientInterface {
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external;
}


interface TokenFallback {
    function tokenFallback(address _from, uint _value, bytes calldata _data) external;
}


contract FungibleToken is ERC20Burnable, IFungibleToken, AccessControl, Pausable
{
    bool public allowPause = true;
    bool public allowFreeze = true;
    mapping (address => bool) private _frozen;

    event Frozen(address target);
    event Unfrozen(address target);
    event FreezeDisabled();
    event PauseDisabled();

    constructor (string memory name_, string memory symbol_)
        ERC20(name_, symbol_)
    {
    }


    function mint(address target, uint256 mintedAmount)
        external
        override
        onlyOperator
    {
        _mint(target, mintedAmount);
    }

    function mintAddDecimals(address target, uint256 mintedAmountWithoutDecimals)
        external
        override
        onlyOperator
    {
        _mint(target, mintedAmountWithoutDecimals * (10**decimals()));
    }

    function mintBulk(
        address[] calldata targets,
        uint256[] calldata mintedAmount
    )
        external
        override
        onlyOperator
    {
        require(
            targets.length == mintedAmount.length,
            "mintBulk: targets.length != mintedAmount.length"
        );
        for (uint i = 0; i < targets.length; i++) {
            _mint(targets[i], mintedAmount[i]);
        }
    }

    function mintAddDecimalsBulk(
        address[] calldata targets,
        uint256[] calldata mintedAmountWithoutDecimals
    )
        external
        override
        onlyOperator
    {
        require(
            targets.length == mintedAmountWithoutDecimals.length,
            "mintAddDecimalsBulk: targets.length != mintedAmountWithoutDecimals.length"
        );
        for (uint i = 0; i < targets.length; i++) {
            _mint(targets[i], mintedAmountWithoutDecimals[i] * (10**decimals()));
        }
    }


    function disableFreezeForever() external onlyOwner {
        require(allowFreeze, "disableFreezeForever: Freeze not allowed");
        allowFreeze = false;
        emit FreezeDisabled();
    }

    function freeze(address target) external onlyOperator {
        _freeze(target);
    }

    function _freeze(address target) internal {
        require(allowFreeze, "FungibleToken: Freeze not allowed");
        require(
            !_frozen[target],
            "FungibleToken: Target account is already frozen"
        );
        _frozen[target] = true;
        emit Frozen(target);
    }

    function isFrozen(address target) view external returns (bool) {
        return _frozen[target];
    }

    function unfreeze(address target) external onlyOperator {
        require(_frozen[target], "FungibleToken: Target account is not frozen");
        delete _frozen[target];
        emit Unfrozen(target);
    }

    function burnFrozenTokens(address target) external onlyOperator {
        require(_frozen[target], "FungibleToken: Target account is not frozen");
        _burn(target, balanceOf(target));
    }

    function freezeAndBurnTokens(address target) external onlyOperator {
        _freeze(target);
        _burn(target, balanceOf(target));
    }


    function disablePauseForever() external onlyOwner {
        require(allowPause, "Pausable: Pause was already disabled");
        allowPause = false;
        emit PauseDisabled();
    }

    function pause() external onlyOperator {
        require(allowPause, "Pausable: Pause not allowed");
        _pause();
    }

    function unpause() external onlyOperator {
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        virtual
        override
    {
        super._beforeTokenTransfer(from, to, amount);

        require(
            to != address(this),
            "FungibleToken: can't transfer to token contract self"
        );
        require(!paused(), "ERC20Pausable: token transfer while paused");
        require(
            !_frozen[from] || to == address(0x0),
            "FungibleToken: source address was frozen"
        );
    }




    function approveAndCall(address spender, uint tokens, bytes calldata data)
        external
        override
        returns (bool success)
    {
        _approve(msg.sender, spender, tokens);
        TokenRecipientInterface(spender).receiveApproval(
            msg.sender,
            tokens,
            address(this),
            data
        );
        return true;
    }


    function transferBulk(address[] calldata to, uint[] calldata tokens)
        external
        override
    {
        require(
            to.length == tokens.length,
            "transferBulk: to.length != tokens.length"
        );
        for (uint i = 0; i < to.length; i++) {
            _transfer(msg.sender, to[i], tokens[i]);
        }
    }

    function approveBulk(address[] calldata spender, uint[] calldata tokens)
        external
        override
    {
        require(
            spender.length == tokens.length,
            "approveBulk: spender.length != tokens.length"
        );
        for (uint i = 0; i < spender.length; i++) {
            _approve(msg.sender, spender[i], tokens[i]);
        }
    }

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value,
        bytes data
    );

    function transfer(address _to, uint _value, bytes calldata _data)
        external
        override
        returns (bool success)
    {
        return transferWithData(_to, _value, _data);
    }

    function transferWithData(address _to, uint _value, bytes calldata _data)
        public
        returns (bool success)
    {
        if (_isContract(_to)) {
            return transferToContract(_to, _value, _data);
        }
        else {
            return transferToAddress(_to, _value, _data);
        }
    }

    function transferToContract(address _to, uint _value, bytes calldata _data)
        public
        returns (bool success)
    {
        _transfer(msg.sender, _to, _value);
        emit Transfer(msg.sender, _to, _value, _data);
        TokenFallback receiver = TokenFallback(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        return true;
    }

    function transferToAddress(address _to, uint tokens, bytes calldata _data)
        public
        returns (bool success)
    {
        _transfer(msg.sender, _to, tokens);
        emit Transfer(msg.sender, _to, tokens, _data);
        return true;
    }

    function _isContract(address _addr) private view returns (bool is_contract) {
        uint length;
        assembly {
            length := extcodesize(_addr)
        }
        return length > 0;
    }
}


contract ERC20Capped is FungibleToken {
    uint256 private _cap;

    constructor (string memory _name, string memory _symbol, uint256 cap_)
    FungibleToken(_symbol, _name) {
        require(cap_ > 0, "ERC20Capped: cap is 0");
        _cap = cap_;
    }

    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) { // When minting tokens
            require(totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        }
    }
}


contract BCUG is ERC20Capped
{
    constructor()
        ERC20Capped(
            "BCUG",
            "Blockchain Cuties Universe Governance Token",
            1000000 ether)
    {
    }
}