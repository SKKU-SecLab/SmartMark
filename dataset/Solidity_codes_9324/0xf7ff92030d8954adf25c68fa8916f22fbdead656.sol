
pragma solidity 0.8.6;

contract LilPix {


    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    address private _owner;

    string private _base;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    uint256 public price = 0.0003 ether;

    constructor(
        string memory name,
        string memory symbol,
        string memory baseURI
    ) {
        _name = name;
        _symbol = symbol;
        _base = baseURI;
        _owner = msg.sender;
    }

    function create(uint256[] calldata tokenIds, address[] calldata recipients)
        external
        payable
    {

        uint256 mintCount = 0; // Only pay for what you mint
        uint256 _price = price;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            address to = i < recipients.length ? recipients[i] : msg.sender;
            if (_owners[tokenId] == address(0)) {
                _balances[to] += 1;
                _owners[tokenId] = to;
                if (to != msg.sender) {
                    emit Transfer(address(0), msg.sender, tokenId);
                    emit Transfer(msg.sender, to, tokenId);
                } else {
                    emit Transfer(address(0), to, tokenId);
                }
                mintCount += 1;
            }
        }

        uint256 expected = _price * mintCount;
        if (msg.value < expected) {
            revert("Not enough ETH");
        } else if (msg.value > expected) {
            payable(msg.sender).send(msg.value - expected);
        }
    }

    function collect() external {

        require(msg.sender == _owner, "NO");
        payable(_owner).call{value: address(this).balance}("");
    }

    function setPrice(uint256 _price) external {

        require(msg.sender == _owner, "NO");
        price = _price;
    }

    fallback() external {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(
                gas(),
                0x9B5D407F144dA142A0A5E3Ad9c53eE936fbBb3dd,
                0,
                calldatasize(),
                0,
                0
            )
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}