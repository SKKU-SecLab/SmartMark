
pragma solidity ^0.8.0;

library StringsUpgradeable {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// GNU GPLv3

pragma solidity =0.8.9;
pragma abicoder v2;


interface IUnifarmNFTDescriptorUpgradeable {

    function generateTokenURI(address cohortId, uint256 tokenId) external view returns (string memory);

}// GNU GPLv3

pragma solidity =0.8.9;


interface IUnifarmCohort {


    function stake(
        uint32 fid,
        uint256 tokenId,
        address account,
        address referralAddress
    ) external;



    function unStake(
        address user,
        uint256 tokenId,
        uint256 flag
    ) external;



    function collectPrematureRewards(address user, uint256 tokenId) external;



    function buyBooster(
        address user,
        uint256 bpid,
        uint256 tokenId
    ) external;



    function setPortionAmount(uint256 tokenId, uint256 stakedAmount) external;



    function disableBooster(uint256 tokenId) external;



    function safeWithdrawEth(address withdrawableAddress, uint256 amount) external returns (bool);



    function safeWithdrawAll(
        address withdrawableAddress,
        address[] memory tokens,
        uint256[] memory amounts
    ) external;



    function viewStakingDetails(uint256 tokenId)
        external
        view
        returns (
            uint32 fid,
            uint256 nftTokenId,
            uint256 stakedAmount,
            uint256 startBlock,
            uint256 endBlock,
            address originalOwner,
            address referralAddress,
            bool isBooster
        );



    event BoosterBuyHistory(uint256 indexed nftTokenId, address indexed user, uint256 bpid);


    event Claim(uint32 fid, uint256 indexed tokenId, address indexed userAddress, address indexed referralAddress, uint256 rValue);


    event ReferedBy(uint256 indexed tokenId, address indexed referralAddress, uint256 stakedAmount, uint32 fid);
}// GNU GPLv3

pragma solidity =0.8.9;

library Base64 {

    string internal constant TABLE_ENCODE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    bytes internal constant TABLE_DECODE =
        hex'0000000000000000000000000000000000000000000000000000000000000000'
        hex'00000000000000000000003e0000003f3435363738393a3b3c3d000000000000'
        hex'00000102030405060708090a0b0c0d0e0f101112131415161718190000000000'
        hex'001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000';

    function encode(bytes memory data) internal pure returns (string memory) {

        if (data.length == 0) return '';

        string memory table = TABLE_ENCODE;

        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        string memory result = new string(encodedLen + 32);

        assembly {
            mstore(result, encodedLen)

            let tablePtr := add(table, 1)

            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            let resultPtr := add(result, 32)

            for {

            } lt(dataPtr, endPtr) {

            } {
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1)
            }

            switch mod(mload(data), 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
        }

        return result;
    }

    function decode(string memory _data) internal pure returns (bytes memory) {

        bytes memory data = bytes(_data);

        if (data.length == 0) return new bytes(0);
        require(data.length % 4 == 0, 'IBDI');

        bytes memory table = TABLE_DECODE;

        uint256 decodedLen = (data.length / 4) * 3;

        bytes memory result = new bytes(decodedLen + 32);

        assembly {
            let lastBytes := mload(add(data, mload(data)))
            if eq(and(lastBytes, 0xFF), 0x3d) {
                decodedLen := sub(decodedLen, 1)
                if eq(and(lastBytes, 0xFFFF), 0x3d3d) {
                    decodedLen := sub(decodedLen, 1)
                }
            }

            mstore(result, decodedLen)

            let tablePtr := add(table, 1)

            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            let resultPtr := add(result, 32)

            for {

            } lt(dataPtr, endPtr) {

            } {
                dataPtr := add(dataPtr, 4)
                let input := mload(dataPtr)

                let output := add(
                    add(
                        shl(18, and(mload(add(tablePtr, and(shr(24, input), 0xFF))), 0xFF)),
                        shl(12, and(mload(add(tablePtr, and(shr(16, input), 0xFF))), 0xFF))
                    ),
                    add(shl(6, and(mload(add(tablePtr, and(shr(8, input), 0xFF))), 0xFF)), and(mload(add(tablePtr, and(input, 0xFF))), 0xFF))
                )
                mstore(resultPtr, shl(232, output))
                resultPtr := add(resultPtr, 3)
            }
        }

        return result;
    }
}// GNU GPLv3

pragma solidity =0.8.9;



library NFTDescriptor {

    using StringsUpgradeable for uint256;

    struct DescriptionParam {
        uint32 fid;
        string cohortName;
        string stakeTokenTicker;
        string cohortAddress;
        uint256 stakedBlock;
        uint256 tokenId;
        uint256 stakedAmount;
        uint256 confirmedEpochs;
        bool isBoosterAvailable;
    }


    function generateName(string memory cohortName, string memory farmTicker) internal pure returns (string memory) {

        return string(abi.encodePacked(farmTicker, ' ', '(', cohortName, ')'));
    }


    function generateDescriptionSegment1(
        uint256 tokenId,
        string memory cohortName,
        string memory stakeTokenTicker,
        string memory cohortId
    ) internal pure returns (string memory) {

        return (
            string(
                abi.encodePacked(
                    'This NFT denotes your staking on Unifarm. Owner of this nft can Burn or sell on any NFT marketplace. please check staking details below. \\n',
                    'Token Id :',
                    tokenId.toString(),
                    '\\n',
                    'Cohort Name :',
                    cohortName,
                    '\\n',
                    'Cohort Address :',
                    cohortId,
                    '\\n',
                    'Staked Token Ticker :',
                    stakeTokenTicker,
                    '\\n'
                )
            )
        );
    }


    function generateDescriptionSegment2(
        uint256 stakedAmount,
        uint256 confirmedEpochs,
        uint256 stakedBlock,
        bool isBoosterAvailable
    ) internal pure returns (string memory) {

        return (
            string(
                abi.encodePacked(
                    'Staked Amount :',
                    stakedAmount.toString(),
                    '\\n',
                    'Confirmed Epochs :',
                    confirmedEpochs.toString(),
                    '\\n',
                    'Staked Block :',
                    stakedBlock.toString(),
                    '\\n',
                    'Booster: ',
                    isBoosterAvailable ? 'Yes' : 'No'
                )
            )
        );
    }


    function generateSVG(DescriptionParam memory svgParams) internal pure returns (string memory) {

        return
            string(
                abi.encodePacked(
                    '<svg width="350" height="350" viewBox="0 0 350 350" fill="none" xmlns="http://www.w3.org/2000/svg">',
                    generateBoosterIndicator(svgParams.isBoosterAvailable),
                    generateRectanglesSVG(),
                    generateSVGTypography(svgParams),
                    generateSVGTypographyForRectangles(svgParams.tokenId, svgParams.stakedBlock, svgParams.confirmedEpochs),
                    '<text x="45" y="313" fill="#FFF" font-size=".75em" font-family="Arial, Helvetica, sans-serif">',
                    svgParams.stakedAmount.toString(),
                    '</text>',
                    generateSVGDefs()
                )
            );
    }


    function generateRectanglesSVG() internal pure returns (string memory) {

        return
            string(
                abi.encodePacked(
                    '<path d="M38 162a5 5 0 0 1 5-5h78a5 5 0 0 1 5 5v22a5 5 0 0 1-5 5H43a5 5 0 0 1-5-5v-22Zm0 38a5 5 0 0 1 5-5h147a5 5 0 0 1 5 5v22a5 5 0 0 1-5 5H43a5 5 0 0 1-5-5v-22Zm0 38a5 5 0 0 1 5-5h180a5 5 0 0 1 5 5v22a5 5 0 0 1-5 5H43a5 5 0 0 1-5-5v-22Zm0 42.969c0-4.401 2.239-7.969 5-7.969h210c2.761 0 5 3.568 5 7.969v35.062c0 4.401-2.239 7.969-5 7.969H43c-2.761 0-5-3.568-5-7.969v-35.062Z" fill="#293922" fill-opacity=".51"/>'
                )
            );
    }


    function generateBoosterIndicator(bool isBoosted) internal pure returns (string memory) {

        return
            string(
                abi.encodePacked(
                    '<g clip-path="url(#a)">',
                    '<rect width="350" height="350" rx="37" fill="url(#b)"/>',
                    '<rect x="15.35" y="14.35" width="315.3" height="318.3" rx="29.65" stroke="#D6D6D6" stroke-opacity=".74" stroke-width=".7"/>',
                    generateRocketIcon(isBoosted),
                    '</g>'
                )
            );
    }

    function generateRocketIcon(bool isBoosted) internal pure returns (string memory) {

        return
            isBoosted
                ? string(
                    abi.encodePacked(
                        '<path d="M49 75h62a5 5 0 0 1 5 5v12a5 5 0 0 1-5 5H49V75Z" fill="#C4C4C4"/>',
                        '<circle cx="49" cy="86" r="10.5" fill="#C4C4C4" stroke="#fff"/>',
                        '<path d="m43.832 90.407 4.284-4.284.758.757-4.285 4.284-.757-.757Z" fill="#fff"/>',
                        '<path d="M49.036 94a.536.536 0 0 1-.53-.46l-.536-3.75 1.072-.15.401 2.823 1.736-1.399v-4.028a.534.534 0 0 1 .155-.38l2.18-2.181a4.788 4.788 0 0 0 1.415-3.407v-.996h-.997a4.788 4.788 0 0 0-3.407 1.414l-2.18 2.18a.536.536 0 0 1-.38.156h-4.029l-1.398 1.746 2.823.402-.15 1.071-3.75-.536a.537.537 0 0 1-.342-.867l2.142-2.679a.536.536 0 0 1 .418-.209h4.066l2.02-2.025A5.85 5.85 0 0 1 53.932 79h.997A1.071 1.071 0 0 1 56 80.072v.996a5.853 5.853 0 0 1-1.725 4.168l-2.025 2.02v4.065a.537.537 0 0 1-.203.418l-2.679 2.143a.535.535 0 0 1-.332.118Z" fill="#fff"/>'
                    )
                )
                : '';
    }


    function generateSVGTypographyForRectangles(
        uint256 tokenId,
        uint256 stakedBlock,
        uint256 confirmedEpochs
    ) internal pure returns (string memory) {

        return
            string(
                abi.encodePacked(
                    '<text x="45" y="177" fill="#FFF" font-size=".75em" font-family="Arial, Helvetica, sans-serif">'
                    'ID: ',
                    tokenId.toString(),
                    '</text>',
                    '<text x="45" y="216" fill="#FFF" font-size=".75em" font-family="Arial, Helvetica, sans-serif">',
                    'Staked block: ',
                    stakedBlock.toString(),
                    '</text>',
                    '<text x="45" y="254" fill="#FFF" font-size=".75em" font-family="Arial, Helvetica, sans-serif">',
                    'Confirmed epochs: ',
                    confirmedEpochs.toString(),
                    '</text>'
                    '<text x="45" y="292" fill="#FFF" font-size=".75em" font-family="Arial, Helvetica, sans-serif">',
                    'Staked Amount: ',
                    '</text>'
                )
            );
    }


    function generateSVGTypography(DescriptionParam memory params) internal pure returns (string memory) {

        DescriptionParam memory svgParam = params;
        return
            string(
                abi.encodePacked(
                    '<text x="36" y="65" fill="#fff" font-size="1em" font-family="Arial, Helvetica, sans-serif">',
                    generateName(svgParam.cohortName, svgParam.stakeTokenTicker),
                    '</text>',
                    generateBoostedLabelText(svgParam.isBoosterAvailable),
                    '<text x="40" y="127" fill="#FFF" font-size=".75em" font-family="Arial, Helvetica, sans-serif">',
                    '<tspan x="40" dy="0">Cohort Address:</tspan>',
                    '<tspan x="40" dy="1.2em">',
                    svgParam.cohortAddress,
                    '</tspan>',
                    '</text>'
                )
            );
    }


    function generateBoostedLabelText(bool isBoosted) internal pure returns (string memory) {

        return
            isBoosted
                ? string(
                    abi.encodePacked(
                        '<text x="64" y="90" fill="#fff" font-size=".75em" font-family="Arial, Helvetica, sans-serif">',
                        'Boosted',
                        '</text>'
                    )
                )
                : '';
    }

    function generateSVGDefs() internal pure returns (string memory) {

        return
            string(
                abi.encodePacked(
                    '<defs>',
                    '<linearGradient id="b" x1="44.977" y1="326.188" x2="113.79" y2="-21.919" gradientUnits="userSpaceOnUse">',
                    '<stop stop-color="#730AAC"/>',
                    '<stop offset=".739" stop-color="#A2164A"/>',
                    '</linearGradient>',
                    '<clipPath id="a">',
                    '<rect width="350" height="350" rx="37" fill="#fff"/>',
                    '</clipPath>',
                    '</defs>',
                    '</svg>'
                )
            );
    }


    function createNftTokenURI(DescriptionParam memory descriptionParam) internal pure returns (string memory) {

        string memory name = generateName(descriptionParam.cohortName, descriptionParam.stakeTokenTicker);
        string memory description = string(
            abi.encodePacked(
                generateDescriptionSegment1(
                    descriptionParam.tokenId,
                    descriptionParam.cohortName,
                    descriptionParam.stakeTokenTicker,
                    descriptionParam.cohortAddress
                ),
                generateDescriptionSegment2(
                    descriptionParam.stakedAmount,
                    descriptionParam.confirmedEpochs,
                    descriptionParam.stakedBlock,
                    descriptionParam.isBoosterAvailable
                )
            )
        );
        string memory svg = Base64.encode(bytes(generateSVG(descriptionParam)));
        return
            string(
                abi.encodePacked(
                    'data:application/json;base64,',
                    string(
                        Base64.encode(
                            bytes(
                                abi.encodePacked(
                                    '{',
                                    '"name":',
                                    '"',
                                    name,
                                    '"',
                                    ',',
                                    '"description":',
                                    '"',
                                    description,
                                    '"',
                                    ',',
                                    '"image":',
                                    '"data:image/svg+xml;base64,',
                                    svg,
                                    '"',
                                    '}'
                                )
                            )
                        )
                    )
                )
            );
    }
}// GNU GPLv3
pragma solidity =0.8.9;

interface IERC20TokenMetadata {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// GNU GPLv3

pragma solidity =0.8.9;


library CheckPointReward {


    function getBlockDifference(uint256 from, uint256 to) internal pure returns (uint256) {

        return to - from;
    }


    function getCheckpoint(
        uint256 from,
        uint256 to,
        uint256 epochBlocks
    ) internal pure returns (uint256) {

        uint256 blockDifference = getBlockDifference(from, to);
        return uint256(blockDifference / epochBlocks);
    }


    function getCurrentCheckpoint(
        uint256 startBlock,
        uint256 endBlock,
        uint256 epochBlocks
    ) internal view returns (uint256 checkpoint) {

        uint256 yfEndBlock = block.number;
        if (yfEndBlock > endBlock) {
            yfEndBlock = endBlock;
        }
        checkpoint = getCheckpoint(startBlock, yfEndBlock, epochBlocks);
    }


    function getStartCheckpoint(
        uint256 startBlock,
        uint256 userStakedBlock,
        uint256 epochBlocks
    ) internal pure returns (uint256 checkpoint) {

        checkpoint = getCheckpoint(startBlock, userStakedBlock, epochBlocks);
    }
}// MIT

pragma solidity =0.8.9;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, 'Address: insufficient balance');

        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, 'Address: low-level call failed');
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

        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, 'Address: insufficient balance for call');
        require(isContract(target), 'Address: call to non-contract');

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, 'Address: low-level static call failed');
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), 'Address: static call to non-contract');

        (bool success, bytes memory returndata) = target.staticcall(data);
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
}// MIT

pragma solidity =0.8.9;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, 'CIAI');

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, 'CINI');
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// GNU GPLv3

pragma solidity =0.8.9;

abstract contract CohortFactory {
    function owner() public view virtual returns (address);


    function getStorageContracts()
        public
        view
        virtual
        returns (
            address registry,
            address nftManager,
            address rewardRegistry
        );
}// GNU GPLv3


pragma solidity =0.8.9;


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
}// GNU GPLv3

pragma solidity =0.8.9;


interface IUnifarmCohortRegistryUpgradeable {


    function setTokenMetaData(
        address cohortId,
        uint32 fid_,
        address farmToken_,
        uint256 userMinStake_,
        uint256 userMaxStake_,
        uint256 totalStakeLimit_,
        uint8 decimals_,
        bool skip_
    ) external;



    function setCohortDetails(
        address cohortId,
        string memory cohortVersion_,
        uint256 startBlock_,
        uint256 endBlock_,
        uint256 epochBlocks_,
        bool hasLiquidityMining_,
        bool hasContainsWrappedToken_,
        bool hasCohortLockinAvaliable_
    ) external;



    function addBoosterPackage(
        address cohortId_,
        address paymentToken_,
        address boosterVault_,
        uint256 bpid_,
        uint256 boosterPackAmount_
    ) external;



    function updateMulticall(address newMultiCallAddress) external;



    function setWholeCohortLock(address cohortId, bool status) external;



    function setCohortLockStatus(
        address cohortId,
        bytes4 actionToLock,
        bool status
    ) external;



    function setCohortTokenLockStatus(
        bytes32 cohortSalt,
        bytes4 actionToLock,
        bool status
    ) external;



    function validateStakeLock(address cohortId, uint32 farmId) external view;



    function validateUnStakeLock(address cohortId, uint32 farmId) external view;



    function getCohortToken(address cohortId, uint32 farmId)
        external
        view
        returns (
            uint32 fid,
            address farmToken,
            uint256 userMinStake,
            uint256 userMaxStake,
            uint256 totalStakeLimit,
            uint8 decimals,
            bool skip
        );



    function getCohort(address cohortId)
        external
        view
        returns (
            string memory cohortVersion,
            uint256 startBlock,
            uint256 endBlock,
            uint256 epochBlocks,
            bool hasLiquidityMining,
            bool hasContainsWrappedToken,
            bool hasCohortLockinAvaliable
        );



    function getBoosterPackDetails(address cohortId, uint256 bpid)
        external
        view
        returns (
            address cohortId_,
            address paymentToken_,
            address boosterVault,
            uint256 boosterPackAmount
        );



    event TokenMetaDataDetails(
        address indexed cohortId,
        address indexed farmToken,
        uint32 indexed fid,
        uint256 userMinStake,
        uint256 userMaxStake,
        uint256 totalStakeLimit,
        uint8 decimals,
        bool skip
    );


    event AddedCohortDetails(
        address indexed cohortId,
        string indexed cohortVersion,
        uint256 startBlock,
        uint256 endBlock,
        uint256 epochBlocks,
        bool indexed hasLiquidityMining,
        bool hasContainsWrappedToken,
        bool hasCohortLockinAvaliable
    );


    event BoosterDetails(address indexed cohortId, uint256 indexed bpid, address paymentToken, uint256 boosterPackAmount);
}// GNU GPLv3

pragma solidity =0.8.9;

interface IWETH {


    function deposit() external payable;


    function transfer(address to, uint256 value) external returns (bool);



    function withdraw(uint256) external;

}// GNU GPLv3

pragma solidity =0.8.9;



library CohortHelper {


    function getBlockNumber() internal view returns (uint256) {

        return block.number;
    }


    function owner(address factory) internal view returns (address) {

        return CohortFactory(factory).owner();
    }


    function verifyCaller(address factory)
        internal
        view
        returns (
            address registry,
            address nftManager,
            address rewardRegistry
        )
    {

        (registry, nftManager, rewardRegistry) = getStorageContracts(factory);
        require(msg.sender == nftManager, 'ONM');
    }


    function getCohort(address registry, address cohortId)
        internal
        view
        returns (
            string memory cohortVersion,
            uint256 startBlock,
            uint256 endBlock,
            uint256 epochBlocks,
            bool hasLiquidityMining,
            bool hasContainsWrappedToken,
            bool hasCohortLockinAvaliable
        )
    {

        (
            cohortVersion,
            startBlock,
            endBlock,
            epochBlocks,
            hasLiquidityMining,
            hasContainsWrappedToken,
            hasCohortLockinAvaliable
        ) = IUnifarmCohortRegistryUpgradeable(registry).getCohort(cohortId);
    }


    function getCohortToken(
        address registry,
        address cohortId,
        uint32 farmId
    )
        internal
        view
        returns (
            uint32 fid,
            address farmToken,
            uint256 userMinStake,
            uint256 userMaxStake,
            uint256 totalStakeLimit,
            uint8 decimals,
            bool skip
        )
    {

        (fid, farmToken, userMinStake, userMaxStake, totalStakeLimit, decimals, skip) = IUnifarmCohortRegistryUpgradeable(registry).getCohortToken(
            cohortId,
            farmId
        );
    }


    function getBoosterPackDetails(
        address registry,
        address cohortId,
        uint256 bpid
    )
        internal
        view
        returns (
            address cohortId_,
            address paymentToken_,
            address boosterVault,
            uint256 boosterPackAmount
        )
    {

        (cohortId_, paymentToken_, boosterVault, boosterPackAmount) = IUnifarmCohortRegistryUpgradeable(registry).getBoosterPackDetails(
            cohortId,
            bpid
        );
    }


    function getCohortBalance(address token, uint256 totalStaking) internal view returns (uint256 cohortBalance) {

        uint256 contractBalance = IERC20(token).balanceOf(address(this));
        cohortBalance = contractBalance - totalStaking;
    }


    function getStorageContracts(address factory)
        internal
        view
        returns (
            address registry,
            address nftManager,
            address rewardRegistry
        )
    {

        (registry, nftManager, rewardRegistry) = CohortFactory(factory).getStorageContracts();
    }


    function depositWETH(address weth, uint256 amount) internal {

        IWETH(weth).deposit{value: amount}();
    }


    function validateStakeLock(
        address registry,
        address cohortId,
        uint32 farmId
    ) internal view {

        IUnifarmCohortRegistryUpgradeable(registry).validateStakeLock(cohortId, farmId);
    }


    function validateUnStakeLock(
        address registry,
        address cohortId,
        uint32 farmId
    ) internal view {

        IUnifarmCohortRegistryUpgradeable(registry).validateUnStakeLock(cohortId, farmId);
    }
}// GNU GPLv3

pragma solidity =0.8.9;

library ConvertHexStrings {

    function addressToString(address account) internal pure returns (string memory) {

        return toString(abi.encodePacked(account));
    }


    function toString(bytes memory data) internal pure returns (string memory) {

        bytes memory alphabet = '0123456789abcdef';

        bytes memory str = new bytes(2 + data.length * 2);
        uint256 dataLength = data.length;
        str[0] = '0';
        str[1] = 'x';
        for (uint256 i = 0; i < dataLength; i++) {
            str[2 + i * 2] = alphabet[uint256(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint256(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }
}// GNU GPLv3

pragma solidity =0.8.9;


contract UnifarmNFTDescriptorUpgradeable is Initializable, IUnifarmNFTDescriptorUpgradeable {

    address public registry;


    function __UnifarmNFTDescriptorUpgradeable_init(address registry_) external initializer {

        __UnifarmNFTDescriptorUpgradeable_init_unchained(registry_);
    }


    function __UnifarmNFTDescriptorUpgradeable_init_unchained(address registry_) internal {

        registry = registry_;
    }


    function getTokenTicker(address farmToken) internal view returns (string memory) {

        return IERC20TokenMetadata(farmToken).symbol();
    }


    function getCohortDetails(
        address cohortId,
        uint256 uStartBlock,
        uint256 uEndBlock
    ) internal view returns (string memory cohortName, uint256 confirmedEpochs) {

        (string memory cohortVersion, , uint256 cEndBlock, uint256 epochBlocks, , , ) = CohortHelper.getCohort(registry, cohortId);
        cohortName = cohortVersion;
        confirmedEpochs = CheckPointReward.getCurrentCheckpoint(uStartBlock, (uEndBlock > 0 ? uEndBlock : cEndBlock), epochBlocks);
    }


    function generateTokenURI(address cohortId, uint256 tokenId) public view override returns (string memory) {

        (uint32 fid, , uint256 stakedAmount, uint256 startBlock, uint256 sEndBlock, , , bool isBooster) = IUnifarmCohort(cohortId).viewStakingDetails(
            tokenId
        );

        (string memory cohortVersion, uint256 confirmedEpochs) = getCohortDetails(cohortId, startBlock, sEndBlock);

        (, address farmToken, , , , , ) = CohortHelper.getCohortToken(registry, cohortId, fid);

        return
            NFTDescriptor.createNftTokenURI(
                NFTDescriptor.DescriptionParam({
                    fid: fid,
                    cohortName: cohortVersion,
                    stakeTokenTicker: getTokenTicker(farmToken),
                    cohortAddress: ConvertHexStrings.addressToString(cohortId),
                    stakedBlock: startBlock,
                    tokenId: tokenId,
                    stakedAmount: stakedAmount,
                    confirmedEpochs: confirmedEpochs,
                    isBoosterAvailable: isBooster
                })
            );
    }

    uint256[49] private __gap;
}