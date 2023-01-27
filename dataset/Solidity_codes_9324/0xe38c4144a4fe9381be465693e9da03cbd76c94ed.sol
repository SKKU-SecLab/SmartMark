
pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


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

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity ^0.8.11;


contract BadFaucet {


    using SafeMath for uint256;

    IERC721 immutable public bayc;
    IERC721 immutable public mayc;
    IERC721 immutable public badBanana;
    IERC20 immutable public bad;

    uint256 public maxClaimPerTransaction;
    uint256 public numTokensPerNFT;

    mapping(uint256 => bool) public baycTokenClaimed;
    mapping(uint256 => bool) public maycTokenClaimed;
    mapping(uint256 => bool) public badBananaTokenClaimed;

    event TokensClaimed(address _address, uint256 _amount);

    constructor() {

        bayc = IERC721(0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D);

        mayc = IERC721(0x60E4d786628Fea6478F785A6d7e704777c86a7c6);

        badBanana = IERC721(0x819b71FBb346a8fAd8f782F3E4B3Db1d551b8E6f);

        bad = IERC20(0xeb5Dc378E9532828446b73b1a948D04218a26588);

        maxClaimPerTransaction = 10;
        numTokensPerNFT = 10000 ether;

    }

    function claimBad(
        uint256[] calldata _baycTokens, 
        uint256[] calldata _maycTokens, 
        uint256[] calldata _badBananaTokens
    )
        external
    {

        uint256 totalTokensSubmitted = _baycTokens.length.add(_maycTokens.length).add(_badBananaTokens.length);
        require(totalTokensSubmitted > 0,"Must provide at least 1 NFT token");
        require(totalTokensSubmitted <= maxClaimPerTransaction,"Must provide 10 or less tokens per transaction");
        
        for(uint256 i = 0; i < _baycTokens.length; i++){
            require(bayc.ownerOf(_baycTokens[i])==msg.sender,"Sender does not own all BAYC tokens submitted");
            require(!baycTokenClaimed[_baycTokens[i]],"BAYC token already claimed");
            baycTokenClaimed[_baycTokens[i]] = true;
        }

        for(uint256 i = 0; i < _maycTokens.length; i++){
            require(mayc.ownerOf(_maycTokens[i])==msg.sender,"Sender does not own all MAYC tokens submitted");
            require(!maycTokenClaimed[_maycTokens[i]],"MAYC token already claimed");
            maycTokenClaimed[_maycTokens[i]] = true;
        }

        for(uint256 i = 0; i < _badBananaTokens.length; i++){
            require(badBanana.ownerOf(_badBananaTokens[i])==msg.sender,"Sender does not own all Bad Banana tokens submitted");
            require(!badBananaTokenClaimed[_badBananaTokens[i]],"Bad Banana token already claimed");
            badBananaTokenClaimed[_badBananaTokens[i]] = true;
        }

        uint256 numBadTokens = totalTokensSubmitted.mul(numTokensPerNFT);
        require(bad.balanceOf(address(this)) >= numBadTokens, "Not enough tokens remaining in faucet");
        require(bad.transfer(msg.sender,numBadTokens),"Error sending coins to caller");

        emit TokensClaimed(msg.sender, numBadTokens);
    
    }
}