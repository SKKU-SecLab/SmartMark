
pragma solidity ^0.8.0;

interface IERC20Internal {

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}// MIT

pragma solidity ^0.8.0;

library ERC20BaseStorage {

  struct Layout {
    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowances;
    uint totalSupply;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256(
    'solidstate.contracts.storage.ERC20Base'
  );

  function layout () internal pure returns (Layout storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly { l.slot := slot }
  }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC20BaseInternal is IERC20Internal {
  function _totalSupply () virtual internal view returns (uint) {
    return ERC20BaseStorage.layout().totalSupply;
  }

  function _balanceOf (
    address account
  ) virtual internal view returns (uint) {
    return ERC20BaseStorage.layout().balances[account];
  }

  function _approve (
    address holder,
    address spender,
    uint amount
  ) virtual internal {
    require(holder != address(0), 'ERC20: approve from the zero address');
    require(spender != address(0), 'ERC20: approve to the zero address');

    ERC20BaseStorage.layout().allowances[holder][spender] = amount;

    emit Approval(holder, spender, amount);
  }

  function _mint (
    address account,
    uint amount
  ) virtual internal {
    require(account != address(0), 'ERC20: mint to the zero address');

    _beforeTokenTransfer(address(0), account, amount);

    ERC20BaseStorage.Layout storage l = ERC20BaseStorage.layout();
    l.totalSupply += amount;
    l.balances[account] += amount;

    emit Transfer(address(0), account, amount);
  }

  function _burn (
    address account,
    uint amount
  ) virtual internal {
    require(account != address(0), 'ERC20: burn from the zero address');

    _beforeTokenTransfer(account, address(0), amount);

    ERC20BaseStorage.Layout storage l = ERC20BaseStorage.layout();
    uint256 balance = l.balances[account];
    require(balance >= amount, "ERC20: burn amount exceeds balance");
    unchecked {
      l.balances[account] = balance - amount;
    }
    l.totalSupply -= amount;

    emit Transfer(account, address(0), amount);
  }

  function _transfer (
    address holder,
    address recipient,
    uint amount
  ) virtual internal {
    require(holder != address(0), 'ERC20: transfer from the zero address');
    require(recipient != address(0), 'ERC20: transfer to the zero address');

    _beforeTokenTransfer(holder, recipient, amount);

    ERC20BaseStorage.Layout storage l = ERC20BaseStorage.layout();
    uint256 holderBalance = l.balances[holder];
    require(holderBalance >= amount, 'ERC20: transfer amount exceeds balance');
    unchecked {
      l.balances[holder] = holderBalance - amount;
    }
    l.balances[recipient] += amount;

    emit Transfer(holder, recipient, amount);
  }

  function _beforeTokenTransfer (
    address from,
    address to,
    uint amount
  ) virtual internal {}
}// MIT

pragma solidity ^0.8.0;

library ReentrancyGuardStorage {

  struct Layout {
    uint status;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256(
    'solidstate.contracts.storage.ReentrancyGuard'
  );

  function layout () internal pure returns (Layout storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly { l.slot := slot }
  }
}// MIT

pragma solidity ^0.8.0;


abstract contract ReentrancyGuard {
  modifier nonReentrant () {
    ReentrancyGuardStorage.Layout storage l = ReentrancyGuardStorage.layout();
    require(l.status != 2, 'ReentrancyGuard: reentrant call');
    l.status = 2;
    _;
    l.status = 1;
  }
}// UNLICENSED

pragma solidity ^0.8.0;

library MagicWhitelistStorage {

    struct Layout {
        mapping(address => bool) whitelist;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256('treasure.contracts.storage.MagicWhitelist');

    function layout() internal pure returns (Layout storage l) {

        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}// MIT

pragma solidity ^0.8.0;



contract MagicMintReentrancyFix is ERC20BaseInternal, ReentrancyGuard {

    function mint(address account, uint256 amount) external nonReentrant {

        require(
            MagicWhitelistStorage.layout().whitelist[msg.sender],
            'Magic: sender must be whitelisted'
        );
        _mint(account, amount);
    }
}