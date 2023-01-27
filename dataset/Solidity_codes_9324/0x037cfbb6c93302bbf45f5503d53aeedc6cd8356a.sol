

pragma solidity ^0.8.7;

struct AbnormalRangeInfo {
    bool startInit;
    bool endInit;
    uint256 startIndex;
    uint256 endIndex;
    bool continuousStart;
    bool continuousEnd;
    bool middle;
}

library BridgeScanRange {

    function getBlockScanRange(
        uint64[] memory r,
        uint64 v1,
        uint64 v2
    ) internal pure returns (uint64[] memory _r) {

        if (r.length == 0) {
            _r = new uint64[](2);
            (, _r) = _insertRange(0, _r, v1, v2);
        } else {
            uint256 total;
            uint64[2][] memory ranges = _extractBlockScanRanges(r);
            bool normality = _determineRangeNormality(ranges, v1, v2);
            if (normality) {
                total = _getNewRangeCount(r.length, ranges, v1, v2);
                if (total > 0) {
                    _r = new uint64[](total);
                    _r = _createNewRanges(ranges, v1, v2, _r);
                }
            } else {
                AbnormalRangeInfo memory info;
                (total, info) = _getAbnormalNewRangeCount(
                    r.length,
                    ranges,
                    v1,
                    v2
                );
                if (total > 0) {
                    _r = new uint64[](total);
                    _r = _createAbnormalNewRanges(ranges, v1, v2, _r, info);
                }
            }

            if (total == 0) {
                _r = new uint64[](r.length);
                _r = r;
            }
        }
    }

    function _extractBlockScanRanges(uint64[] memory r)
        private
        pure
        returns (uint64[2][] memory arr)
    {

        uint256 maxRange = r.length / 2;
        arr = new uint64[2][](maxRange);

        uint64 k = 0;
        for (uint64 i = 0; i < maxRange; i++) {
            (bool e1, uint64 v1) = _getElement(i + k, r);
            (bool e2, uint64 v2) = _getElement(i + k + 1, r);

            uint64[2] memory tmp;
            if (e1 && e2) tmp = [v1, v2];
            arr[k] = tmp;
            k++;
        }
    }

    function _getElement(uint64 i, uint64[] memory arr)
        private
        pure
        returns (bool exist, uint64 ele)
    {

        if (exist = (i >= 0 && i < arr.length)) {
            ele = arr[i];
        }
    }

    function _getElement(uint64 i, uint64[2][] memory arr)
        private
        pure
        returns (bool exist, uint64[2] memory ranges)
    {

        if (exist = (i >= 0 && i < arr.length)) {
            ranges = arr[i];
        }
    }

    function _determineRangeNormality(
        uint64[2][] memory ranges,
        uint64 v1,
        uint64 v2
    ) private pure returns (bool normality) {

        bool ended;
        for (uint64 i = 0; i < ranges.length; i++) {
            (bool e1, uint64[2] memory ele1) = _getElement(i, ranges);
            (bool e2, uint64[2] memory ele2) = _getElement(i + 1, ranges);

            if (e1 && e2)
                (ended, normality) = _checkRangeNormality(
                    i,
                    v1,
                    v2,
                    ele1,
                    ele2
                );
            else if (e1)
                (ended, normality) = _checkRangeNormality(i, v1, v2, ele1);

            if (ended) return normality;
        }
    }

    function _checkRangeNormality(
        uint64 index,
        uint64 v1,
        uint64 v2,
        uint64[2] memory ele1
    ) private pure returns (bool, bool) {

        if ((index == 0 && v2 <= ele1[0]) || v1 >= ele1[1]) {
            return (true, true);
        }
        return (true, false);
    }

    function _checkRangeNormality(
        uint64 index,
        uint64 v1,
        uint64 v2,
        uint64[2] memory ele1,
        uint64[2] memory ele2
    ) private pure returns (bool, bool) {

        if ((index == 0 && v2 <= ele1[0]) || (v1 >= ele1[1] && v2 <= ele2[0])) {
            return (true, true);
        }
        return (false, false);
    }


    function _getNewRangeCount(
        uint256 curCount,
        uint64[2][] memory ranges,
        uint64 v1,
        uint64 v2
    ) private pure returns (uint256 total) {

        for (uint64 i = 0; i < ranges.length; i++) {
            (bool e1, uint64[2] memory ele1) = _getElement(i, ranges);
            (bool e2, uint64[2] memory ele2) = _getElement(i + 1, ranges);

            if (e1 && e2) total = _calculateRange(curCount, v1, v2, ele1, ele2);
            else if (e1) total = _calculateRange(curCount, v1, v2, ele1);

            if (total > 0) return total;
        }
        return total;
    }

    function _calculateRange(
        uint256 curCount,
        uint64 v1,
        uint64 v2,
        uint64[2] memory ele1
    ) private pure returns (uint256 total) {

        if (v2 <= ele1[0]) {
            if (_checkEnd(ele1[0], v2)) {
                total = curCount;
            } else {
                total = curCount + 2;
            }
        } else if (v1 >= ele1[1]) {
            if (_checkStart(ele1[1], v1)) {
                total = curCount;
            } else {
                total = curCount + 2;
            }
        }
    }

    function _calculateRange(
        uint256 curCount,
        uint64 v1,
        uint64 v2,
        uint64[2] memory ele1,
        uint64[2] memory ele2
    ) private pure returns (uint256 total) {

        if (v2 <= ele1[0]) {
            if (_checkEnd(ele1[0], v2)) {
                total = curCount;
            } else {
                total = curCount + 2;
            }
        } else if (v1 >= ele1[1] && v2 <= ele2[0]) {
            if (_checkStart(ele1[1], v1) && _checkEnd(ele2[0], v2)) {
                total = curCount - 2;
            } else if (_checkStart(ele1[1], v1) || _checkEnd(ele2[0], v2)) {
                total = curCount;
            } else {
                total = curCount + 2;
            }
        }
    }

    function _createNewRanges(
        uint64[2][] memory ranges,
        uint64 v1,
        uint64 v2,
        uint64[] memory r
    ) private pure returns (uint64[] memory) {

        bool done = false;
        bool skip = false;
        uint256 total = 0;
        for (uint64 i = 0; i < ranges.length; i++) {
            (bool e1, uint64[2] memory ele1) = _getElement(i, ranges);
            (bool e2, uint64[2] memory ele2) = _getElement(i + 1, ranges);

            if (done) {
                if (!skip && e1)
                    (total, r) = _insertRange(total, r, ele1[0], ele1[1]);
                else skip = false;
            } else {
                if (e1 && e2) {
                    (done, total, r) = _insertRange(
                        total,
                        r,
                        v1,
                        v2,
                        ele1,
                        ele2
                    );
                    if (done) skip = true;
                } else if (e1)
                    (done, total, r) = _insertRange(total, r, v1, v2, ele1);
            }
        }
        return r;
    }

    function _insertRange(
        uint256 i,
        uint64[] memory r,
        uint64 v1,
        uint64 v2
    ) private pure returns (uint256, uint64[] memory) {

        r[i] = v1;
        r[i + 1] = v2;
        i += 2;
        return (i, r);
    }

    function _insertRange(
        uint256 i,
        uint64[] memory r,
        uint64 v1,
        uint64 v2,
        uint64[2] memory ele1
    )
        private
        pure
        returns (
            bool done,
            uint256,
            uint64[] memory
        )
    {

        if (v2 <= ele1[0]) {
            if (_checkEnd(ele1[0], v2)) {
                (i, r) = _insertRange(i, r, v1, ele1[1]);
                done = true;
            } else {
                (i, r) = _insertRange(i, r, v1, v2);
                (i, r) = _insertRange(i, r, ele1[0], ele1[1]);
                done = true;
            }
        } else if (v1 >= ele1[1]) {
            if (_checkStart(ele1[1], v1)) {
                (i, r) = _insertRange(i, r, ele1[0], v2);
                done = true;
            } else {
                (i, r) = _insertRange(i, r, ele1[0], ele1[1]);
                (i, r) = _insertRange(i, r, v1, v2);
                done = true;
            }
        }
        return (done, i, r);
    }

    function _insertRange(
        uint256 i,
        uint64[] memory r,
        uint64 v1,
        uint64 v2,
        uint64[2] memory ele1,
        uint64[2] memory ele2
    )
        private
        pure
        returns (
            bool done,
            uint256,
            uint64[] memory
        )
    {

        if (v2 <= ele1[0]) {
            if (_checkEnd(ele1[0], v2)) {
                (i, r) = _insertRange(i, r, v1, ele1[1]);
                (i, r) = _insertRange(i, r, ele2[0], ele2[1]);
                done = true;
            } else {
                (i, r) = _insertRange(i, r, v1, v2);
                (i, r) = _insertRange(i, r, ele1[0], ele1[1]);
                (i, r) = _insertRange(i, r, ele2[0], ele2[1]);
                done = true;
            }
        } else if (v1 >= ele1[1] && v2 <= ele2[0]) {
            if (_checkStart(ele1[1], v1) && _checkEnd(ele2[0], v2)) {
                (i, r) = _insertRange(i, r, ele1[0], ele2[1]);
                done = true;
            } else if (_checkStart(ele1[1], v1)) {
                (i, r) = _insertRange(i, r, ele1[0], v2);
                (i, r) = _insertRange(i, r, ele2[0], ele2[1]);
                done = true;
            } else if (_checkEnd(ele2[0], v2)) {
                (i, r) = _insertRange(i, r, ele1[0], ele1[1]);
                (i, r) = _insertRange(i, r, v1, ele2[1]);
                done = true;
            } else {
                (i, r) = _insertRange(i, r, ele1[0], ele1[1]);
                (i, r) = _insertRange(i, r, v1, v2);
                (i, r) = _insertRange(i, r, ele2[0], ele2[1]);
                done = true;
            }
        }

        if (!done) (i, r) = _insertRange(i, r, ele1[0], ele1[1]);

        return (done, i, r);
    }


    function _getAbnormalNewRangeCount(
        uint256 curCount,
        uint64[2][] memory ranges,
        uint64 v1,
        uint64 v2
    ) private pure returns (uint256 total, AbnormalRangeInfo memory info) {

        for (uint64 i = 0; i < ranges.length; i++) {
            (bool e1, uint64[2] memory ele1) = _getElement(i, ranges);
            (bool e2, uint64[2] memory ele2) = _getElement(i + 1, ranges);

            if (e1 && e2) {
                if (info.startInit)
                    info = _calculateAbnormalRangeEnd(i, v2, ele1, ele2, info);
                else
                    info = _calculateAbnormalRange(i, v1, v2, ele1, ele2, info);
            } else if (e1) {
                if (info.startInit)
                    info = _calculateAbnormalRange(i, v2, ele1, info);
                else info = _calculateAbnormalRange(i, v1, v2, ele1, info);
            }

            if (info.endInit)
                total = _calculateAbnormalRangeTotal(curCount, info);

            if (total > 0) return (total, info);
        }
    }

    function _calculateAbnormalRange(
        uint256 i,
        uint64 v1,
        uint64 v2,
        uint64[2] memory ele1,
        AbnormalRangeInfo memory info
    ) private pure returns (AbnormalRangeInfo memory) {

        if (v1 <= ele1[0] && v2 >= ele1[1]) {
            info.startInit = info.endInit = true;
            info.startIndex = info.endIndex = i;
        }
        return info;
    }

    function _calculateAbnormalRange(
        uint256 i,
        uint64 v2,
        uint64[2] memory ele1,
        AbnormalRangeInfo memory info
    ) private pure returns (AbnormalRangeInfo memory) {

        if (v2 >= ele1[1]) {
            info.endInit = true;
            info.endIndex = i;
        }
        return info;
    }

    function _calculateAbnormalRange(
        uint256 i,
        uint64 v1,
        uint64 v2,
        uint64[2] memory ele1,
        uint64[2] memory ele2,
        AbnormalRangeInfo memory info
    ) private pure returns (AbnormalRangeInfo memory) {

        if (v1 <= ele1[0] && v2 >= ele1[1] && v2 <= ele2[0]) {
            info.startInit = info.endInit = true;
            info.startIndex = info.endIndex = i;
            if (_checkEnd(ele2[0], v2)) info.continuousEnd = true;
        } else if (v1 <= ele1[0]) {
            info.startInit = true;
            info.startIndex = i;
        } else if (v1 >= ele1[1] && v1 <= ele2[0]) {
            info.startInit = true;
            info.startIndex = i;
            info.middle = true;
            if (_checkStart(ele1[1], v1)) info.continuousStart = true;
        }
        return info;
    }

    function _calculateAbnormalRangeEnd(
        uint256 i,
        uint64 v2,
        uint64[2] memory ele1,
        uint64[2] memory ele2,
        AbnormalRangeInfo memory info
    ) private pure returns (AbnormalRangeInfo memory) {

        if (v2 >= ele1[1] && v2 <= ele2[0]) {
            info.endInit = true;
            info.endIndex = i;
            if (_checkEnd(ele2[0], v2)) info.continuousEnd = true;
        }
        return info;
    }

    function _calculateAbnormalRangeTotal(
        uint256 curCount,
        AbnormalRangeInfo memory info
    ) private pure returns (uint256 total) {

        if (info.startIndex == info.endIndex) {
            if (info.continuousEnd) total = curCount - 2;
            else total = curCount;
        } else if (info.endIndex > info.startIndex) {
            uint256 diff = info.endIndex - info.startIndex;
            total = curCount - (2 * diff);
            if (
                (info.continuousStart && info.continuousEnd && info.middle) ||
                (info.continuousEnd && !info.middle)
            ) total -= 2;
            else if (
                !info.continuousStart && !info.continuousEnd && info.middle
            ) total += 2;
        }
    }

    function _createAbnormalNewRanges(
        uint64[2][] memory ranges,
        uint64 v1,
        uint64 v2,
        uint64[] memory r,
        AbnormalRangeInfo memory info
    ) private pure returns (uint64[] memory) {

        bool skip = false;
        uint256 total = 0;
        for (uint64 i = 0; i < ranges.length; i++) {
            (, uint64[2] memory ele1) = _getElement(i, ranges);
            (bool e2, uint64[2] memory ele2) = _getElement(i + 1, ranges);

            if (info.startIndex == i) {
                if (info.middle) {
                    if (info.continuousStart) {
                        (total, r) = _insertAbnormalRange(total, r, ele1[0]);
                        skip = true;
                    } else {
                        (total, r) = _insertAbnormalRange(
                            total,
                            r,
                            ele1[0],
                            ele1[1]
                        );
                        (total, r) = _insertAbnormalRange(total, r, v1);
                        skip = true;
                    }
                } else {
                    (total, r) = _insertAbnormalRange(total, r, v1);
                }
            }

            if (info.endIndex == i) {
                if (info.continuousEnd) {
                    (total, r) = _insertAbnormalRange(total, r, ele2[1]);
                    skip = true;
                } else {
                    (total, r) = _insertAbnormalRange(total, r, v2);
                    if (e2) {
                        (total, r) = _insertAbnormalRange(
                            total,
                            r,
                            ele2[0],
                            ele2[1]
                        );
                        skip = true;
                    }
                }
            }

            if (!(i >= info.startIndex && i <= info.endIndex)) {
                if (!skip)
                    (total, r) = _insertAbnormalRange(
                        total,
                        r,
                        ele1[0],
                        ele1[1]
                    );
                else skip = false;
            }
        }
        return r;
    }

    function _insertAbnormalRange(
        uint256 i,
        uint64[] memory r,
        uint64 v
    ) private pure returns (uint256, uint64[] memory) {

        r[i] = v;
        i += 1;
        return (i, r);
    }

    function _insertAbnormalRange(
        uint256 i,
        uint64[] memory r,
        uint64 v1,
        uint64 v2
    ) private pure returns (uint256, uint64[] memory) {

        r[i] = v1;
        r[i + 1] = v2;
        i += 2;
        return (i, r);
    }


    function _checkStart(uint64 ele, uint64 v) private pure returns (bool) {

        return ((uint64(ele + 1) == v) || ele == v);
    }

    function _checkEnd(uint64 ele, uint64 v) private pure returns (bool) {

        return ((uint64(ele - 1) == v) || ele == v);
    }
}


pragma solidity ^0.8.7;

library BridgeSecurity {

    function generateSignerMsgHash(uint64 epoch, address[] memory signers)
        internal
        pure
        returns (bytes32 msgHash)
    {

        msgHash = keccak256(
            abi.encodePacked(
                bytes1(0x19),
                bytes1(0),
                address(0),
                epoch,
                _encodeAddressArr(signers)
            )
        );
    }

    function generatePackMsgHash(
        address thisAddr,
        uint64 epoch,
        uint8 networkId,
        uint64[2] memory blockScanRange,
        uint256[] memory txHashes,
        address[] memory tokens,
        address[] memory recipients,
        uint256[] memory amounts
    ) internal pure returns (bytes32 msgHash) {

        msgHash = keccak256(
            abi.encodePacked(
                bytes1(0x19),
                bytes1(0),
                thisAddr,
                epoch,
                _encodeFixed2Uint64Arr(blockScanRange),
                networkId,
                _encodeUint256Arr(txHashes),
                _encodeAddressArr(tokens),
                _encodeAddressArr(recipients),
                _encodeUint256Arr(amounts)
            )
        );
    }

    function signersVerification(
        bytes32 msgHash,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s,
        address[] memory signers,
        mapping(address => bool) storage mapSigners
    ) internal view returns (bool) {

        uint64 totalSigners = 0;
        for (uint64 i = 0; i < signers.length; i++) {
            if (mapSigners[signers[i]]) totalSigners++;
        }
        return (_getVerifiedSigners(msgHash, v, r, s, mapSigners) ==
            (totalSigners / 2) + 1);
    }

    function _getVerifiedSigners(
        bytes32 msgHash,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s,
        mapping(address => bool) storage mapSigners
    ) private view returns (uint8 verifiedSigners) {

        address lastAddr = address(0);
        verifiedSigners = 0;
        for (uint64 i = 0; i < v.length; i++) {
            address recovered = ecrecover(msgHash, v[i], r[i], s[i]);
            if (recovered > lastAddr && mapSigners[recovered])
                verifiedSigners++;
            lastAddr = recovered;
        }
    }

    function _encodeAddressArr(address[] memory arr)
        private
        pure
        returns (bytes memory data)
    {

        for (uint64 i = 0; i < arr.length; i++) {
            data = abi.encodePacked(data, arr[i]);
        }
    }

    function _encodeUint256Arr(uint256[] memory arr)
        private
        pure
        returns (bytes memory data)
    {

        for (uint64 i = 0; i < arr.length; i++) {
            data = abi.encodePacked(data, arr[i]);
        }
    }

    function _encodeFixed2Uint64Arr(uint64[2] memory arr)
        private
        pure
        returns (bytes memory data)
    {

        for (uint64 i = 0; i < arr.length; i++) {
            data = abi.encodePacked(data, arr[i]);
        }
    }
}


pragma solidity ^0.8.7;

interface ITokenFactory {

    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    event BridgeChanged(address indexed oldBridge, address indexed newBridge);

    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);

    event TokenCreated(
        string name,
        string indexed symbol,
        uint256 amount,
        uint256 cap,
        address indexed token
    );

    event TokenRemoved(address indexed token);

    function owner() external view returns (address);


    function tokens() external view returns (address[] memory);


    function tokenExist(address token) external view returns (bool);


    function bridge() external view returns (address);


    function admin() external view returns (address);


    function setBridge(address bridge) external;


    function setAdmin(address admin) external;


    function createToken(
        string memory name,
        string memory symbol,
        uint256 amount,
        uint256 cap
    ) external returns (address token);


    function removeToken(address token) external;

}


pragma solidity ^0.8.7;

interface ICrossBridgeStorageToken {

    event TokenConnected(
        address indexed token,
        uint256 amount,
        uint256 percent,
        address indexed crossToken,
        string symbol
    );

    event TokenRequirementChanged(
        uint64 blockIndex,
        address indexed token,
        uint256[2] amount,
        uint256[2] percent
    );

    function owner() external view returns (address);


    function admin() external view returns (address);


    function bridge() external view returns (address);


    function mapToken(address token) external view returns (bool);


    function mapOcToken(address token) external view returns (address);


    function mapCoToken(address token) external view returns (address);


    function blockScanRange() external view returns (uint64[] memory);


    function crossToken(address token)
        external
        view
        returns (string memory, string memory);


    function tokens(
        ITokenFactory tf,
        uint64 futureBlock,
        uint64 searchBlockIndex
    )
        external
        view
        returns (
            uint8[] memory,
            address[][] memory,
            address[][] memory,
            uint256[][] memory,
            uint256[][] memory,
            uint8[][] memory
        );


    function tokens(
        ITokenFactory tf,
        uint8 id,
        uint64 futureBlock,
        uint64 searchBlockIndex
    )
        external
        view
        returns (
            address[] memory,
            address[] memory,
            uint256[] memory,
            uint256[] memory,
            uint8[] memory
        );


    function charges()
        external
        view
        returns (address[] memory tokens, uint256[] memory charges);


    function txHash(uint256 txHash) external view returns (bool);


    function transactionInfo(
        uint64 futureBlock,
        address token,
        uint256 amount
    ) external view returns (uint256 fee, uint256 amountAfterCharge);


    function setCallers(address admin, address bridge) external;


    function resetConnection(address token, address crossToken) external;


    function setConnection(
        address token,
        uint256 amount,
        uint256 percent,
        address crossToken,
        string memory name,
        string memory symbol
    ) external;


    function setInfo(
        address token,
        uint256 amount,
        uint256 percent
    ) external;


    function setAmount(address token, uint256 amount) external;


    function setPercent(address token, uint256 percent) external;


    function setTxHash(uint256 txHash) external;


    function setCollectedCharges(address token, uint256 amount) external;


    function setScanRange(uint64[2] memory scanRange) external;

}


pragma solidity ^0.8.7;

struct TokenReq {
    bool exist;
    uint256 minAmount;
    uint256 chargePercent;
}

struct CrossTokenInfo {
    string name;
    string symbol;
}

struct NetworkInfo {
    uint8 id;
    string name;
}

struct TokenData {
    address[] tokens;
    address[] crossTokens;
    uint256[] minAmounts;
    uint256[] chargePercents;
    uint8[] tokenTypes;
}

struct TokensInfo {
    uint8[] ids;
    address[][] tokens;
    address[][] crossTokens;
    uint256[][] minAmounts;
    uint256[][] chargePercents;
    uint8[][] tokenTypes;
}

struct TokensChargesInfo {
    uint8[] ids;
    address[][] tokens;
    uint256[][] charges;
}

interface IBridge {

    event TokenConnected(
        address indexed token,
        uint256 amount,
        uint256 percent,
        address indexed crossToken,
        string symbol
    );

    event TokenReqChanged(
        uint64 blockIndex,
        address indexed token,
        uint256[2] amount,
        uint256[2] percent
    );

    function initialize(
        address factory,
        address admin,
        address tokenFactory,
        address wMech,
        uint8 id,
        string memory name
    ) external;


    function factory() external view returns (address);


    function admin() external view returns (address);


    function network() external view returns (uint8, string memory);


    function activeTokenCount() external view returns (uint8);


    function crossToken(address crossToken)
        external
        view
        returns (string memory, string memory);


    function tokens(uint64 futureBlock, uint64 searchBlockIndex)
        external
        view
        returns (TokenData memory data);


    function blockScanRange() external view returns (uint64[] memory);


    function charges()
        external
        view
        returns (address[] memory tokens, uint256[] memory charges);


    function txHash(uint256 txHash_) external view returns (bool);


    function setConnection(
        address token,
        uint256 amount,
        uint256 percent,
        address crossToken,
        string memory name,
        string memory symbol
    ) external;


    function setInfo(
        address token,
        uint256 amount,
        uint256 percent
    ) external;


    function setAmount(address token, uint256 amount) external;


    function setPercent(address token, uint256 percent) external;


    function resetConnection(address token, address crossToken) external;


    function processPack(
        uint64[2] memory blockScanRange,
        uint256[] memory txHashes,
        address[] memory tokens,
        address[] memory recipients,
        uint256[] memory amounts
    ) external;

}


pragma solidity ^0.8.7;

library BridgeUtils {

    uint256 internal constant FUTURE_BLOCK_INTERVAL = 100;
    uint256 public constant CHARGE_PERCENTAGE_DIVIDER = 10000;

    function roundFuture(uint256 blockIndex) internal pure returns (uint64) {

        uint256 _futureBlockIndex;
        if (blockIndex <= FUTURE_BLOCK_INTERVAL) {
            _futureBlockIndex = FUTURE_BLOCK_INTERVAL;
        } else {
            _futureBlockIndex =
                FUTURE_BLOCK_INTERVAL *
                ((blockIndex / FUTURE_BLOCK_INTERVAL) + 1);
        }
        return uint64(_futureBlockIndex);
    }

    function getFuture(uint256 blockIndex)
        internal
        pure
        returns (uint64 futureBlockIndex)
    {

        uint256 _futureBlockIndex;
        if (blockIndex <= FUTURE_BLOCK_INTERVAL) {
            _futureBlockIndex = 0;
        } else {
            _futureBlockIndex =
                FUTURE_BLOCK_INTERVAL *
                (blockIndex / FUTURE_BLOCK_INTERVAL);
        }
        return uint64(_futureBlockIndex);
    }

    function getBlockScanRange(
        uint16 count,
        uint8[] memory networks,
        mapping(uint8 => address) storage bridges
    )
        internal
        view
        returns (uint8[] memory _networks, uint64[][] memory _ranges)
    {

        _networks = new uint8[](count);
        _ranges = new uint64[][](count);
        uint64 k = 0;
        for (uint64 i = 0; i < networks.length; i++) {
            if (bridges[networks[i]] != address(0)) {
                _networks[k] = networks[i];
                _ranges[k] = IBridge(bridges[networks[i]]).blockScanRange();
                k++;
            }
        }
    }

    function getCharges(
        uint16 count,
        uint8[] memory networks,
        mapping(uint8 => address) storage bridges
    ) internal view returns (TokensChargesInfo memory info) {

        uint8[] memory _networks = new uint8[](count);
        address[][] memory _tokens = new address[][](count);
        uint256[][] memory _charges = new uint256[][](count);
        uint64 k = 0;
        for (uint64 i = 0; i < networks.length; i++) {
            if (bridges[networks[i]] != address(0)) {
                _networks[k] = networks[i];
                (_tokens[k], _charges[k]) = IBridge(bridges[networks[i]])
                    .charges();
                k++;
            }
        }
        info.ids = _networks;
        info.tokens = _tokens;
        info.charges = _charges;
    }

    function getTokenReq(
        uint64 futureBlock,
        address token,
        uint64[] memory futureBlocks,
        mapping(address => mapping(uint64 => TokenReq)) storage tokenReqs
    ) internal view returns (uint256 amount, uint256 percent) {

        TokenReq memory _req = getReq(
            futureBlock,
            token,
            futureBlocks,
            tokenReqs
        );
        amount = _req.minAmount;
        percent = _req.chargePercent;
    }

    function getCollectedChargesCN(
        ICrossBridgeStorageToken bridgeStorage,
        uint8 networkId
    ) internal view returns (TokensChargesInfo memory info) {

        uint8[] memory _networks = new uint8[](1);
        address[][] memory _tokens = new address[][](1);
        uint256[][] memory _charges = new uint256[][](1);
        _networks[0] = networkId;
        (_tokens[0], _charges[0]) = bridgeStorage.charges();
        info.ids = _networks;
        info.tokens = _tokens;
        info.charges = _charges;
    }

    function getTransactionInfo(
        uint64 futureBlock,
        address token,
        uint256 amount,
        uint64[] memory futureBlocks,
        mapping(address => mapping(uint64 => TokenReq)) storage tokenReqs
    ) internal view returns (uint256 fee, uint256 amountAfterCharge) {

        TokenReq memory _req = getReq(
            futureBlock,
            token,
            futureBlocks,
            tokenReqs
        );
        fee = (amount * _req.chargePercent) / CHARGE_PERCENTAGE_DIVIDER;
        amountAfterCharge = amount - fee;
    }

    function updateMap(
        address[] memory arr,
        bool status,
        mapping(address => bool) storage map
    ) internal {

        for (uint64 i = 0; i < arr.length; i++) {
            map[arr[i]] = status;
        }
    }

    function getReq(
        uint64 blockIndex,
        address token,
        uint64[] memory futureBlocks,
        mapping(address => mapping(uint64 => TokenReq)) storage tokenReqs
    ) internal view returns (TokenReq memory req) {

        req = tokenReqs[token][blockIndex];
        if (!req.exist) {
            for (uint256 i = futureBlocks.length; i > 0; i--) {
                if (futureBlocks[i - 1] <= blockIndex) {
                    req = tokenReqs[token][futureBlocks[i - 1]];
                    if (req.exist) return req;
                }
            }
        }
    }

    function getCountBySearchIndex(
        uint64 searchBlockIndex,
        address[] memory tokens,
        mapping(address => bool) storage mapTokens,
        mapping(address => uint64) storage mapTokenCreatedBlockIndex
    ) internal view returns (uint64 k) {

        for (uint64 i = 0; i < tokens.length; i++) {
            if (
                mapTokens[tokens[i]] &&
                (mapTokenCreatedBlockIndex[tokens[i]] <= searchBlockIndex)
            ) {
                k++;
            }
        }
    }
}


pragma solidity ^0.8.7;

interface ICrossBridgeStorage {

    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    event SignersChanged(
        address[] indexed oldSigners,
        address[] indexed newSigners
    );

    event RelayersChanged(
        address[] indexed oldRelayers,
        address[] indexed newRelayers
    );

    function owner() external view returns (address);


    function admin() external view returns (address);


    function bridge() external view returns (address);


    function network() external view returns (NetworkInfo memory);


    function epoch() external view returns (uint64);


    function signers() external view returns (address[] memory);


    function relayers() external view returns (address[] memory);


    function mapSigner(address signer) external view returns (bool);


    function mapRelayer(address relayer) external view returns (bool);


    function setCallers(address admin, address bridge) external;


    function setEpoch(uint64 epoch) external;


    function setSigners(address[] memory signers_) external;


    function setRelayers(address[] memory relayers_) external;


    function signerVerification(
        bytes32 msgHash,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external view returns (bool);

}


pragma solidity ^0.8.7;

interface ICrossBridge {

    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    function owner() external view returns (address);


    function epoch() external view returns (uint64);


    function cap(address token) external view returns (uint256);


    function tokens(uint64 searchBlockIndex)
        external
        view
        returns (
            uint8[] memory networkIds,
            address[][] memory tokens,
            address[][] memory crossTokens,
            uint256[][] memory minAmounts,
            uint8[][] memory tokenTypes
        );


    function blockScanRange(uint8 networkId)
        external
        view
        returns (uint64[] memory);


    function processSigners(
        uint64 epoch,
        address[] memory signers,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external;


    function processPack(
        uint8 id,
        uint64[2] memory scanRange,
        uint256[] memory txHashes,
        address[] memory tokens,
        address[] memory recipients,
        uint256[] memory amounts,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external;


    function setSigners(address[] memory signers) external;


    function setRelayers(address[] memory relayers) external;


    function withdrawal(
        address token,
        address recipient,
        uint256 amount,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external;

}



pragma solidity ^0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

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

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {

        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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



pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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
}


pragma solidity ^0.8.7;

interface ITokenMintable is IERC20Upgradeable {

    function initialize(
        address factory,
        string memory name,
        string memory symbol,
        uint256 amount,
        uint256 cap
    ) external;


    function factory() external view returns (address);


    function cap() external view returns (uint256);


    function mint(address to, uint256 amount) external;


    function burn(uint256 amount) external;


    function increaseCap(uint256 cap) external;

}



pragma solidity ^0.8.0;

library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data)
        private
    {


        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}



pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(
            _initializing || !_initialized,
            "Initializable: contract is already initialized"
        );

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
}



pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {}

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}



pragma solidity ^0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}


pragma solidity ^0.8.7;

contract CrossBridgeUpgradeable is
    Initializable,
    OwnableUpgradeable,
    ICrossBridge
{

    using SafeERC20Upgradeable for ITokenMintable;
    using BridgeSecurity for *;
    using BridgeUtils for *;
    using BridgeScanRange for uint64[];

    ITokenFactory private tf;
    ICrossBridgeStorage private bs;
    ICrossBridgeStorageToken private bts;

    address[] private _wdSigners;
    mapping(address => bool) private _mapWdSigners;

    modifier onlyRelayer() {

        require(bs.mapRelayer(msg.sender), "OR");
        _;
    }

    function __CrossBridge_init(
        address tokenFactory,
        address bridgeStorage,
        address bridgeTokenStorage,
        address[] memory wdSigners_
    ) internal initializer {

        __Ownable_init();
        tf = ITokenFactory(tokenFactory);
        bs = ICrossBridgeStorage(bridgeStorage);
        bts = ICrossBridgeStorageToken(bridgeTokenStorage);
        _wdSigners = wdSigners_;
        for (uint64 i = 0; i < wdSigners_.length; i++) {
            _mapWdSigners[wdSigners_[i]] = true;
        }
    }

    function owner()
        public
        view
        virtual
        override(OwnableUpgradeable, ICrossBridge)
        returns (address)
    {

        return super.owner();
    }

    function epoch() public view virtual override returns (uint64 epoch_) {

        epoch_ = bs.epoch();
    }

    function cap(address token) external view override returns (uint256 _cap) {

        return ITokenMintable(token).cap();
    }

    function blockScanRange(uint8 networkId)
        external
        view
        virtual
        override
        returns (uint64[] memory blockScanRange_)
    {

        NetworkInfo memory network = bs.network();
        if (networkId == network.id) blockScanRange_ = bts.blockScanRange();
    }

    function tokens(uint64 searchBlockIndex)
        external
        view
        virtual
        override
        returns (
            uint8[] memory networkIds,
            address[][] memory tokens_,
            address[][] memory crossTokens,
            uint256[][] memory minAmounts,
            uint8[][] memory tokenTypes
        )
    {

        uint64 futureBlock = searchBlockIndex.getFuture();
        (networkIds, tokens_, crossTokens, minAmounts, , tokenTypes) = bts
            .tokens(tf, futureBlock, searchBlockIndex);
    }

    function processSigners(
        uint64 epoch_,
        address[] memory signers_,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external virtual override onlyRelayer {

        require(epoch_ > epoch(), "IE");
        bytes32 msgHash = epoch_.generateSignerMsgHash(signers_);
        if (bs.signerVerification(msgHash, v, r, s)) {
            bs.setEpoch(epoch_);
            bs.setSigners(signers_);
        }
    }

    function processPack(
        uint8 networkId,
        uint64[2] memory blockScanRange_,
        uint256[] memory txHashes,
        address[] memory tokens_,
        address[] memory recipients,
        uint256[] memory amounts,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external virtual override onlyRelayer {

        require(blockScanRange_[1] > blockScanRange_[0], "IR");
        bytes32 msgHash = address(this).generatePackMsgHash(
            epoch(),
            networkId,
            blockScanRange_,
            txHashes,
            tokens_,
            recipients,
            amounts
        );

        if (bs.signerVerification(msgHash, v, r, s)) {
            uint64 futureBlock = block.number.getFuture();
            for (uint64 i = 0; i < txHashes.length; i++) {
                if (!bts.txHash(txHashes[i]) && bts.mapToken(tokens_[i])) {
                    bts.setTxHash(txHashes[i]);

                    (uint256 fee, uint256 amountAfterCharge) = bts
                        .transactionInfo(futureBlock, tokens_[i], amounts[i]);

                    if (tf.tokenExist(tokens_[i])) {
                        ITokenMintable(tokens_[i]).mint(
                            recipients[i],
                            amountAfterCharge
                        );
                    } else {
                        ITokenMintable(tokens_[i]).safeTransfer(
                            recipients[i],
                            amountAfterCharge
                        );
                    }
                    bts.setCollectedCharges(tokens_[i], fee);
                }
            }
            bts.setScanRange(blockScanRange_);
        }
    }

    function setSigners(address[] memory signers)
        external
        virtual
        override
        onlyOwner
    {

        bs.setSigners(signers);
    }

    function setRelayers(address[] memory relayers)
        external
        virtual
        override
        onlyOwner
    {

        bs.setRelayers(relayers);
    }

    function withdrawal(
        address token,
        address recipient,
        uint256 amount,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external virtual override onlyOwner {

        require(token != address(0), "ZA");
        require(recipient != address(0), "ZA");
        require(r.length == _wdSigners.length, "SG1");

        bytes32 msgHash = keccak256(
            abi.encodePacked(bytes1(0x19), bytes1(0), address(this), recipient)
        );

        uint64 verified = 0;
        address lastAddr = address(0);
        for (uint64 i = 0; i < _wdSigners.length; i++) {
            address recovered = ecrecover(msgHash, v[i], r[i], s[i]);
            require(recovered > lastAddr && _mapWdSigners[recovered], "SG2");
            verified++;
        }

        if (verified == _wdSigners.length) {
            ITokenMintable(token).safeTransfer(recipient, amount);
        }
    }
}


pragma solidity ^0.8.7;

contract EthereumBridge is CrossBridgeUpgradeable {

    function initialize(
        address tokenFactory,
        address bridgeStorage,
        address bridgeTokenStorage,
        address[] memory wdSigners
    ) public initializer {

        __CrossBridge_init(
            tokenFactory,
            bridgeStorage,
            bridgeTokenStorage,
            wdSigners
        );
    }
}