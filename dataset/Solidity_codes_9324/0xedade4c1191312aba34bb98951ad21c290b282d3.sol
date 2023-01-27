
pragma solidity ^0.6.6;

pragma experimental ABIEncoderV2;

interface Erc20Token {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);  // @TOODO: convert bytes32 as needed

    function decimals() external view returns (uint8);


    function balanceOf(address addr) external view returns (uint);

}

interface Erc721Token {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);


    function ownerOf(uint tokenId) external view returns (address);

    function tokenUri(uint tokenId) external view returns (string memory);

}

contract AccountState {


    struct Erc20Info {
        bytes name;
        bytes symbol;
        uint256 decimals;

        uint balance;
    }

    struct Erc721Info {
        bytes name;
        bytes symbol;
    }

    struct Erc721TokenInfo {
        uint owner;
        bytes tokenUri;
    }


    function getUint(address addr, bytes memory data) internal view returns (uint result) {

        result = 0;

        assembly {
            let status := staticcall(16000, addr, add(data, 32), mload(data), 0, 0)

            if eq(status, 1) {
                if eq(returndatasize(), 32) {
                    returndatacopy(0, 0, 32)
                    result := mload(0)
                }
            }
        }
    }

    function getString(address addr, bytes memory data) internal view returns (bytes memory result) {

        assembly {
            result := mload(0x40)

            mstore(result, 0)
            mstore(0x40, add(result, 32))

            let status := staticcall(16000, addr, add(data, 32), mload(data), 0, 0)

            if eq(status, 1) {

                if eq(returndatasize(), 32) {
                    returndatacopy(0, 0, 32)

                    mstore(result, 32)
                    mstore(add(result, 32), mload(0))
                    mstore(0x40, add(result, 64))
                }

                if gt(returndatasize(), 95) {
                    returndatacopy(0x0, 0, 32)
                    let ptr := mload(0x0)

                    if eq(ptr, 32) {

                        let returnSize := sub(returndatasize(), ptr)

                        returndatacopy(0x0, ptr, 32)
                        let payloadSize := add(mload(0x0), 32)
                        if iszero(gt(payloadSize, returnSize)) {         // payloadSize <= returnSize

                            returndatacopy(result, ptr, payloadSize)

                            mstore(0x40, add(result, and(add(add(payloadSize, 0x20), 0x1f), not(0x1f))))
                        }
                    }
                }
            }
        }
    }

    function getErc20Info(address[] memory erc20s) internal view returns (Erc20Info[] memory) {

        Erc20Info[] memory erc20Infos = new Erc20Info[](erc20s.length);

        for (uint i = 0; i < erc20s.length; i++) {
            address token = erc20s[i];

            Erc20Info memory erc20Info = erc20Infos[i];

            erc20Info.name = getString(token, abi.encodeWithSignature("name()"));
            erc20Info.symbol = getString(token, abi.encodeWithSignature("symbol()"));
            erc20Info.decimals = getUint(token, abi.encodeWithSignature("decimals()"));

            erc20Info.balance = getUint(token, abi.encodeWithSignature("balanceOf(address)", msg.sender));
        }

        return erc20Infos;
    }

    function getErc721Info(address[] memory erc721s, uint[] memory counts, uint[] memory erc721TokenIds) internal view returns (Erc721Info[] memory, Erc721TokenInfo[] memory) {

        Erc721Info[] memory erc721Infos = new Erc721Info[](erc721s.length);
        Erc721TokenInfo[] memory erc721TokenInfos = new Erc721TokenInfo[](erc721TokenIds.length);

        uint k = 0;
        for (uint i = 0; i < erc721s.length; i++) {
            address token = erc721s[i];
            Erc721Info memory erc721Info = erc721Infos[i];

            erc721Info.name = getString(token, abi.encodeWithSignature("name()"));
            erc721Info.symbol = getString(token, abi.encodeWithSignature("symbol()"));

            uint count = counts[i];
            for (uint j = 0; j < count; j++) {
                Erc721TokenInfo memory erc721TokenInfo = erc721TokenInfos[k];

                erc721TokenInfo.owner = getUint(token, abi.encodeWithSignature("ownerOf(uint256)", erc721TokenIds[k]));
                erc721TokenInfo.tokenUri = getString(token, abi.encodeWithSignature("tokenURI(uint256)", erc721TokenIds[k]));

                k++;
            }
        }

        return (erc721Infos, erc721TokenInfos);
    }

    function getInfo(
        address[] calldata erc20s,
        address[] calldata erc721s,
        uint[] calldata erc721Counts,
        uint[] calldata erc721TokenIds
    ) external view returns(
        uint256,
        uint256,
        Erc20Info[] memory,
        Erc721Info[] memory,
        Erc721TokenInfo[] memory
    ) {

        Erc20Info[] memory erc20Infos = getErc20Info(erc20s);

        (Erc721Info[] memory erc721Infos, Erc721TokenInfo[] memory erc721TokenInfos) = getErc721Info(erc721s, erc721Counts, erc721TokenIds);

        return (
            msg.sender.balance,
            block.number,
            erc20Infos,
            erc721Infos,
            erc721TokenInfos
        );
    }
}