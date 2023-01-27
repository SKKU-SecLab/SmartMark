
pragma solidity 0.8.4;

interface INonfungiblePositionManager {

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }
    function collect(CollectParams calldata params) external payable returns (uint256 amount0, uint256 amount1);

}

library Position {

    struct Info {
        uint256 tokenId;
        uint256 cliff;
        uint256 start;
        uint256 duration;
        bool allowFeeClaim;
        bool allowBeneficiaryUpdate;
        address feeReciever;
        address owner;
    }
    
    function isPositionValid(Info memory self) internal view {

        require(self.owner != address(0), "ULL::OWNER_ZERO_ADDRESS");
        require(self.duration >= self.cliff, "ULL::CLIFF_GT_DURATION");
        require(self.duration > 0, "ULL::INVALID_DURATION");
        require((self.start + self.duration) > block.timestamp, "ULL::INVALID_ENDING_TIME");
    }
    
    function isOwner(Info memory self) internal view {

        require(self.owner == msg.sender && self.allowBeneficiaryUpdate, "ULL::NOT_AUTHORIZED");
    }
    
    function isTokenIdValid(Info memory self, uint256 tokenId) internal pure {

        require(self.tokenId == tokenId, "ULL::INVALID_TOKEN_ID");
    }
    
    function isTokenUnlocked(Info memory self) internal view {

        require((self.start + self.duration) < block.timestamp, "ULL::NOT_UNLOCKED");
    }
    
    function isFeeClaimAllowed(Info memory self) internal view {

        require(self.allowFeeClaim, "ULL::FEE_CLAIM_NOT_ALLOWED");
        require((self.start + self.cliff) < block.timestamp, "ULL::CLIFF_NOT_ENDED");
    }
}
contract UniswapV3LiquidityLocker {

    using Position for Position.Info;
    address private constant POSITION_MANAGER = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
    uint128 private constant MAX_UINT128 = type(uint128).max;
    mapping(uint256 => Position.Info) public lockedLiquidityPositions;
    INonfungiblePositionManager private _uniswapNFPositionManager;
    event PositionUpdated(Position.Info position);
    event FeeClaimed(uint256 tokenId);
    event TokenUnlocked(uint256 tokenId);
    constructor() {
        _uniswapNFPositionManager = INonfungiblePositionManager(POSITION_MANAGER);
    }
    function lockLPToken(Position.Info calldata params) external {

        _uniswapNFPositionManager.transferFrom(msg.sender, address(this), params.tokenId);
        params.isPositionValid();
        lockedLiquidityPositions[params.tokenId] = params;
        emit PositionUpdated(params);
    }
    function claimLPFee(uint256 tokenId) external returns (uint256 amount0, uint256 amount1) {

        Position.Info memory llPosition = lockedLiquidityPositions[tokenId];
        llPosition.isTokenIdValid(tokenId);
        llPosition.isFeeClaimAllowed();
        (amount0, amount1) = _uniswapNFPositionManager.collect(
            INonfungiblePositionManager.CollectParams(tokenId, llPosition.feeReciever, MAX_UINT128, MAX_UINT128)
        );
        emit FeeClaimed(tokenId);
    }
    function updateOwner(address owner, uint256 tokenId) external {

        Position.Info storage llPosition = lockedLiquidityPositions[tokenId];
        llPosition.isTokenIdValid(tokenId);
        llPosition.isOwner();
        llPosition.owner = owner;
        emit PositionUpdated(llPosition);
    }
    function updateFeeReciever(address feeReciever, uint256 tokenId) external {

        Position.Info storage llPosition = lockedLiquidityPositions[tokenId];
        llPosition.isTokenIdValid(tokenId);
        llPosition.isOwner();
        llPosition.feeReciever = feeReciever;
        emit PositionUpdated(llPosition);
    }
    function renounceBeneficiaryUpdate(uint256 tokenId) external {

        Position.Info storage llPosition = lockedLiquidityPositions[tokenId];
        llPosition.isTokenIdValid(tokenId);
        llPosition.isOwner();
        llPosition.allowBeneficiaryUpdate = false;
        emit PositionUpdated(llPosition);
    }
    function unlockToken(uint256 tokenId) external {

        Position.Info memory llPosition = lockedLiquidityPositions[tokenId];
        llPosition.isTokenIdValid(tokenId);
        llPosition.isTokenUnlocked();
        _uniswapNFPositionManager.transferFrom(address(this), llPosition.owner, tokenId);
        delete lockedLiquidityPositions[tokenId];
        emit TokenUnlocked(tokenId);
    }
}