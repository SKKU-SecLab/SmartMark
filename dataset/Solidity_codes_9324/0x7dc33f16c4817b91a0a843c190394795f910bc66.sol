
pragma solidity 0.6.12;

contract FoldingAccountStorage {

    bytes32 constant ACCOUNT_STORAGE_POSITION = keccak256('folding.account.storage');

    struct AccountStore {
        address entryCaller;
        address callbackTarget;
        bytes4 expectedCallbackSig;
        address foldingRegistry;
        address nft;
        address owner;
    }

    modifier onlyAccountOwner() {

        AccountStore storage s = aStore();
        require(s.entryCaller == s.owner, 'FA2');
        _;
    }

    modifier onlyNFTContract() {

        AccountStore storage s = aStore();
        require(s.entryCaller == s.nft, 'FA3');
        _;
    }

    modifier onlyAccountOwnerOrRegistry() {

        AccountStore storage s = aStore();
        require(s.entryCaller == s.owner || s.entryCaller == s.foldingRegistry, 'FA4');
        _;
    }

    function aStore() internal pure returns (AccountStore storage s) {

        bytes32 position = ACCOUNT_STORAGE_POSITION;
        assembly {
            s_slot := position
        }
    }

    function accountOwner() internal view returns (address) {

        return aStore().owner;
    }
}// MIT

pragma solidity 0.6.12;

interface IFodlNFTProvider {

    function fodlNFT() external view returns (address);

}// MIT

pragma solidity 0.6.12;

interface IFodlNFT {

    function setTokenUri(string memory _tokenURI) external;

}// MIT

pragma solidity 0.6.12;


contract SetTokenURIConnector is FoldingAccountStorage {

    string private constant ETH_SIGN_PREFIX = '\x19Ethereum Signed Message:\n32';

    address public immutable authoriser;

    constructor(address _authoriser) public {
        authoriser = _authoriser;
    }

    function setTokenURI(
        string memory tokenURI,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external onlyAccountOwner {

        bytes32 h = keccak256(abi.encodePacked(ETH_SIGN_PREFIX, keccak256(abi.encodePacked(address(this), tokenURI))));
        require(ecrecover(h, v, r, s) == authoriser, 'Invalid authoriser signature');

        IFodlNFT(IFodlNFTProvider(aStore().foldingRegistry).fodlNFT()).setTokenUri(tokenURI);
    }
}