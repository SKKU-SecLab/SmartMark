
pragma solidity ^0.8.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity ^0.8.0;

library strings {

    using strings for *;
    
    struct slice {
        uint _len;
        uint _ptr;
    }

    function memcpy(uint dest, uint src, uint len_cpy) private pure {

        for(; len_cpy >= 32; len_cpy -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        uint mask = 256 ** (32 - len_cpy) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    function toSlice(string memory self) internal pure returns (slice memory) {

        uint ptr;
        assembly {
            ptr := add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }


    function copy(slice memory self) internal pure returns (slice memory) {

        return slice(self._len, self._ptr);
    }

    function toString(slice memory self) internal pure returns (string memory) {

        string memory ret = new string(self._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        memcpy(retptr, self._ptr, self._len);
        return ret;
    }

    function len(slice memory self) internal pure returns (uint l) {

        uint ptr = self._ptr - 31;
        uint end = ptr + self._len;
        for (l = 0; ptr < end; l++) {
            uint8 b;
            assembly { b := and(mload(ptr), 0xFF) }
            if (b < 0x80) {
                ptr += 1;
            } else if(b < 0xE0) {
                ptr += 2;
            } else if(b < 0xF0) {
                ptr += 3;
            } else if(b < 0xF8) {
                ptr += 4;
            } else if(b < 0xFC) {
                ptr += 5;
            } else {
                ptr += 6;
            }
        }
    }

    function empty(slice memory self) internal pure returns (bool) {

        return self._len == 0;
    }

    function compare(slice memory self, slice memory other) internal pure returns (int) {

        uint shortest = self._len;
        if (other._len < self._len)
            shortest = other._len;

        uint selfptr = self._ptr;
        uint otherptr = other._ptr;
        for (uint idx = 0; idx < shortest; idx += 32) {
            uint a;
            uint b;
            assembly {
                a := mload(selfptr)
                b := mload(otherptr)
            }
            if (a != b) {
                uint256 mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);
                uint256 diff = (a & mask) - (b & mask);
                if (diff != 0)
                    return int(diff);
            }
            selfptr += 32;
            otherptr += 32;
        }
        return int(self._len) - int(other._len);
    }

    function equals(slice memory self, slice memory other) internal pure returns (bool) {

        return compare(self, other) == 0;
    }

    function nextRune(slice memory self, slice memory rune) internal pure returns (slice memory) {

        rune._ptr = self._ptr;

        if (self._len == 0) {
            rune._len = 0;
            return rune;
        }

        uint l;
        uint b;
        assembly { b := and(mload(sub(mload(add(self, 32)), 31)), 0xFF) }
        if (b < 0x80) {
            l = 1;
        } else if(b < 0xE0) {
            l = 2;
        } else if(b < 0xF0) {
            l = 3;
        } else {
            l = 4;
        }

        if (l > self._len) {
            rune._len = self._len;
            self._ptr += self._len;
            self._len = 0;
            return rune;
        }

        self._ptr += l;
        self._len -= l;
        rune._len = l;
        return rune;
    }

    function nextRune(slice memory self) internal pure returns (slice memory ret) {

        nextRune(self, ret);
    }

    function ord(slice memory self) internal pure returns (uint ret) {

        if (self._len == 0) {
            return 0;
        }

        uint word;
        uint length;
        uint divisor = 2 ** 248;

        assembly { word:= mload(mload(add(self, 32))) }
        uint b = word / divisor;
        if (b < 0x80) {
            ret = b;
            length = 1;
        } else if(b < 0xE0) {
            ret = b & 0x1F;
            length = 2;
        } else if(b < 0xF0) {
            ret = b & 0x0F;
            length = 3;
        } else {
            ret = b & 0x07;
            length = 4;
        }

        if (length > self._len) {
            return 0;
        }

        for (uint i = 1; i < length; i++) {
            divisor = divisor / 256;
            b = (word / divisor) & 0xFF;
            if (b & 0xC0 != 0x80) {
                return 0;
            }
            ret = (ret * 64) | (b & 0x3F);
        }

        return ret;
    }

    function keccak(slice memory self) internal pure returns (bytes32 ret) {

        assembly {
            ret := keccak256(mload(add(self, 32)), mload(self))
        }
    }

    function startsWith(slice memory self, slice memory needle) internal pure returns (bool) {

        if (self._len < needle._len) {
            return false;
        }

        if (self._ptr == needle._ptr) {
            return true;
        }

        bool equal;
        assembly {
            let length := mload(needle)
            let selfptr := mload(add(self, 0x20))
            let needleptr := mload(add(needle, 0x20))
            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
        }
        return equal;
    }

    function endsWith(slice memory self, slice memory needle) internal pure returns (bool) {

        if (self._len < needle._len) {
            return false;
        }

        uint selfptr = self._ptr + self._len - needle._len;

        if (selfptr == needle._ptr) {
            return true;
        }

        bool equal;
        assembly {
            let length := mload(needle)
            let needleptr := mload(add(needle, 0x20))
            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
        }

        return equal;
    }

    function until(slice memory self, slice memory needle) internal pure returns (slice memory) {

        if (self._len < needle._len) {
            return self;
        }

        uint selfptr = self._ptr + self._len - needle._len;
        bool equal = true;
        if (selfptr != needle._ptr) {
            assembly {
                let length := mload(needle)
                let needleptr := mload(add(needle, 0x20))
                equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
            }
        }

        if (equal) {
            self._len -= needle._len;
        }

        return self;
    }

    event log_bytemask(bytes32 mask);


    function findPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {

        uint ptr = selfptr;
        uint idx;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));

                bytes32 needledata;
                assembly { needledata := and(mload(needleptr), mask) }

                uint end = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                assembly { ptrdata := and(mload(ptr), mask) }

                while (ptrdata != needledata) {
                    if (ptr >= end)
                        return selfptr + selflen;
                    ptr++;
                    assembly { ptrdata := and(mload(ptr), mask) }
                }
                return ptr;
            } else {
                bytes32 hash;
                assembly { hash := keccak256(needleptr, needlelen) }

                for (idx = 0; idx <= selflen - needlelen; idx++) {
                    bytes32 testHash;
                    assembly { testHash := keccak256(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr;
                    ptr += 1;
                }
            }
        }
        return selfptr + selflen;
    }
    function rfindPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {

        uint ptr;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));

                bytes32 needledata;
                assembly { needledata := and(mload(needleptr), mask) }

                ptr = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                assembly { ptrdata := and(mload(ptr), mask) }

                while (ptrdata != needledata) {
                    if (ptr <= selfptr) 
                        return selfptr;
                    ptr--;
                    assembly { ptrdata := and(mload(ptr), mask) }
                }
                return ptr + needlelen;
            } else {
                bytes32 hash;
                assembly { hash := keccak256(needleptr, needlelen) }
                ptr = selfptr + (selflen - needlelen);
                while (ptr >= selfptr) {
                    bytes32 testHash;
                    assembly { testHash := keccak256(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr + needlelen;
                    ptr -= 1;
                }
            }
        }
        return selfptr;
    }

    function find(slice memory self, slice memory needle) internal pure returns (slice memory) {

        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        self._len -= ptr - self._ptr;
        self._ptr = ptr;
        return self;
    }

    function rfind(slice memory self, slice memory needle) internal pure returns (slice memory) {

        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        self._len = ptr - self._ptr;
        return self;
    }

    function split(slice memory self, slice memory needle, slice memory token) internal pure returns (slice memory) {

        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = self._ptr;
        token._len = ptr - self._ptr;
        if (ptr == self._ptr + self._len) {
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
            self._ptr = ptr + needle._len;
        }
        return token;
    }

    function split(slice memory self, slice memory needle) internal pure returns (slice memory token) {

        split(self, needle, token);
    }

    function rsplit(slice memory self, slice memory needle, slice memory token) internal pure returns (slice memory) {

        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = ptr;
        token._len = self._len - (ptr - self._ptr);
        if (ptr == self._ptr) {
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
        }
        return token;
    }

    function rsplit(slice memory self, slice memory needle) internal pure returns (slice memory token) {

        rsplit(self, needle, token);
    }

    function count(slice memory self, slice memory needle) internal pure returns (uint cnt) {

        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;
        while (ptr <= self._ptr + self._len) {
            cnt++;
            ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr) + needle._len;
        }
    }

    function contains(slice memory self, slice memory needle) internal pure returns (bool) {

        return rfindPtr(self._len, self._ptr, needle._len, needle._ptr) != self._ptr;
    }

    function concat(slice memory self, slice memory other) internal pure returns (string memory) {

        string memory ret = new string(self._len + other._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }
        memcpy(retptr, self._ptr, self._len);
        memcpy(retptr + self._len, other._ptr, other._len);
        return ret;
    }

    function join(slice memory self, slice[] memory parts) internal pure returns (string memory) {

        if (parts.length == 0)
            return "";

        uint length = self._len * (parts.length - 1);
        for(uint i = 0; i < parts.length; i++)
            length += parts[i]._len;

        string memory ret = new string(length);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        for(uint i = 0; i < parts.length; i++) {
            memcpy(retptr, parts[i]._ptr, parts[i]._len);
            retptr += parts[i]._len;
            if (i < parts.length - 1) {
                memcpy(retptr, self._ptr, self._len);
                retptr += self._len;
            }
        }

        return ret;
    }

     function uint2str(uint _i) internal pure returns (string memory _uintAsString) {

        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint lenn;
        while (j != 0) {
            lenn++;
            j /= 10;
        }
        bytes memory bstr = new bytes(lenn);
        uint k = lenn - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

 function parseInt(string memory _a, uint _b) internal pure returns (uint _parsedInt) {

        bytes memory bresult = bytes(_a);
        uint mint = 0;
        bool decimals = false;
        for (uint i = 0; i < bresult.length; i++) {
            if ((uint(uint8(bresult[i])) >= 48) && (uint(uint8(bresult[i])) <= 57)) {
                if (decimals) {
                   if (_b == 0) {
                       break;
                   } else {
                       _b--;
                   }
                }
                mint *= 10;
                mint += uint(uint8(bresult[i])) - 48;
            } else if (uint(uint8(bresult[i])) == 46) {
                decimals = true;
            }
        }
        if (_b > 0) {
            mint *= 10 ** _b;
        }
        return mint;
    }

    function split_string(string memory raw, string memory by) pure internal returns(string[] memory)
	{

		strings.slice memory s = raw.toSlice();
		strings.slice memory delim = by.toSlice();
		string[] memory parts = new string[](s.count(delim));
		for (uint i = 0; i < parts.length; i++) {
			parts[i] = s.split(delim).toString();
		}
		return parts;
	}
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    function decimals() external view returns (uint8);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.8.0;

library QuickSorter {



  function sort(uint[] storage data) internal {


    uint n = data.length;
    uint[] memory arr = new uint[](n);
    uint i;

    for(i=0; i<n; i++) {
      arr[i] = data[i];
    }

    uint[] memory stack = new uint[](n+2);

    uint top = 1;
    stack[top] = 0;
    top = top + 1;
    stack[top] = n-1;

    while (top > 0) {

      uint h = stack[top];
      top = top - 1;
      uint l = stack[top];
      top = top - 1;

      i = l;
      uint x = arr[h];

      for(uint j=l; j<h; j++){
        if  (arr[j] <= x) {
          (arr[i], arr[j]) = (arr[j],arr[i]);
          i = i + 1;
        }
      }
      (arr[i], arr[h]) = (arr[h],arr[i]);
      uint p = i;

      if (p > l + 1) {
        top = top + 1;
        stack[top] = l;
        top = top + 1;
        stack[top] = p - 1;
      }

      if (p+1 < h) {
        top = top + 1;
        stack[top] = p + 1;
        top = top + 1;
        stack[top] = h;
      }
    }

    for(i=0; i<n; i++) {
      data[i] = arr[i];
    }
  }

}// MIT

pragma solidity ^0.8.0;


struct GlqStaker {
    address wallet;
    uint256 block_number;
    uint256 amount;
    uint256 index_at;
    bool already_withdrawn;
}

struct GraphLinqApyStruct {
    uint256 tier1Apy;
    uint256 tier2Apy;
    uint256 tier3Apy;      
}

contract GlqStakingContract {


    using SafeMath for uint256;
    using strings for *;
    using QuickSorter for *;

    event NewStakerRegistered (
        address staker_address,
        uint256 at_block,
        uint256 amount_registered
    );

    address private _glqTokenAddress;

    address private _glqDeployerManager;

    uint256 private _totalGlqIncentive;

    GlqStaker[]                     private _stakers;
    uint256                         private _stakersIndex;
    uint256                         private _totalStaked;
    bool                            private _emergencyWithdraw;

    mapping(address => uint256)     private _indexStaker;
    uint256                         private _blocksPerYear;
    GraphLinqApyStruct              private _apyStruct;

    constructor(address glqAddr, address manager) {
        _glqTokenAddress = glqAddr;
        _glqDeployerManager = manager;

        _totalStaked = 0;
        _stakersIndex = 1;
        
        _blocksPerYear = 2250000;
        
        _apyStruct = GraphLinqApyStruct(50*1e18, 25*1e18, 12500000000000000000);
    }



    function getWalletCurrentTier(address wallet) public view returns (uint256) {

        uint256 currentTier = 3;
        uint256 index = _indexStaker[wallet];
        require(
            index != 0,
            "You dont have any tier rank currently in the Staking contract."
        );
        uint256 walletAggregatedIndex = (index).mul(1e18);

        uint256 totalIndex = _stakers.length.mul(1e18);
        uint256 t1MaxIndex = totalIndex.div(100).mul(15);
        uint256 t2MaxIndex = totalIndex.div(100).mul(55);

        if (walletAggregatedIndex <= t1MaxIndex) {
            currentTier = 1;
        } else if (walletAggregatedIndex > t1MaxIndex && walletAggregatedIndex <= t2MaxIndex) {
            currentTier = 2;
        }

        return currentTier;
    }

    function getPosition(address wallet) public view returns (uint256) {

         uint256 index = _indexStaker[wallet];
         return index;
    }

    function getGlqToClaim(address wallet) public view returns(uint256) {

        uint256 index = _indexStaker[wallet];
        require (index > 0, "Invalid staking index");
        GlqStaker storage staker = _stakers[index - 1];

        uint256 calculatedApr = getWaitingPercentAPR(wallet);
        return staker.amount.mul(calculatedApr).div(100).div(1e18);
    }

    function getWaitingPercentAPR(address wallet) public view returns(uint256) {

        uint256 index = _indexStaker[wallet];
        require (index > 0, "Invalid staking index");
        GlqStaker storage staker = _stakers[index - 1];

        uint256 walletTier = getWalletCurrentTier(wallet);
        uint256 blocksSpent = block.number.sub(staker.block_number);
        if (blocksSpent == 0) { return 0; }
        uint256 percentYearSpent = percent(blocksSpent.mul(10000), _blocksPerYear.mul(10000), 20);

        uint256 percentAprGlq = _apyStruct.tier3Apy;
        if (walletTier == 1) {
            percentAprGlq = _apyStruct.tier1Apy;
        } else if (walletTier == 2) {
            percentAprGlq = _apyStruct.tier2Apy;
        }

        return percentAprGlq.mul(percentYearSpent).div(100).div(1e18);
    }

    function getTotalIncentive() public view returns (uint256) {

        return _totalGlqIncentive;
    }

    function getDepositedGLQ(address wallet) public view returns (uint256) {

        uint256 index = _indexStaker[wallet];
        if (index == 0) { return 0; }
        return _stakers[index-1].amount;
    }

    function getTotalStakers() public view returns(uint256) {

        return _stakers.length;
    }

    function getTiersAPY() public view returns(uint256, uint256, uint256) {

        return (_apyStruct.tier1Apy, _apyStruct.tier2Apy, _apyStruct.tier3Apy);
    }

    function getTotalStaked() public view returns(uint256) {

        return _totalStaked;
    }

    function getTopStakers() public view returns(address[] memory, uint256[] memory) {

        uint256 len = _stakers.length;
        address[] memory addresses = new address[](3);
        uint256[] memory amounts = new uint256[](3);

        for (uint i = 0; i < len && i <= 2; i++) {
            addresses[i] = _stakers[i].wallet;
            amounts[i] = _stakers[i].amount;
        }

        return (addresses, amounts);
    }

    function getTierTotalStaked(uint tier) public view returns (uint256) {

        uint256 totalAmount = 0;

        uint256 totalIndex = _stakers.length.mul(1e18);
        uint256 t1MaxIndex = totalIndex.div(100).mul(15);
        uint256 t2MaxIndex = totalIndex.div(100).mul(55);

        uint startIndex = (tier == 1) ? 0 : t1MaxIndex.div(1e18);
        uint endIndex = (tier == 1) ? t1MaxIndex.div(1e18) : t2MaxIndex.div(1e18);
        
        if (tier == 3) {
            startIndex = t2MaxIndex.div(1e18);
            endIndex = _stakers.length;
        }

        for (uint i = startIndex; i <= endIndex && i < _stakers.length; i++) {
            totalAmount +=  _stakers[i].amount;
        }
      
        return totalAmount;
    }





    function setEmergencyWithdraw(bool state) public {

        require (
            msg.sender == _glqDeployerManager,
            "Only the Glq Deployer can change the state of the emergency withdraw"
        );
        _emergencyWithdraw = state;
    }

    function setBlocksPerYear(uint256 blocks) public {

        require(
            msg.sender == _glqDeployerManager,
            "Only the Glq Deployer can change blocks spent per year");
        _blocksPerYear = blocks;
    }

    function setApyPercentRewards(uint256 t1, uint256 t2, uint256 t3) public {

        require(
            msg.sender == _glqDeployerManager,
            "Only the Glq Deployer can APY rewards");
        GraphLinqApyStruct memory newApy = GraphLinqApyStruct(t1, t2, t3);
        _apyStruct = newApy;
    }

    function addIncentive(uint256 glqAmount) public {

        IERC20 glqToken = IERC20(_glqTokenAddress);
        require(
            msg.sender == _glqDeployerManager,
            "Only the Glq Deployer can add incentive into the smart-contract");
        require(
            glqToken.balanceOf(msg.sender) >= glqAmount,
            "Insufficient funds from the deployer contract");
        require(
            glqToken.transferFrom(msg.sender, address(this), glqAmount) == true,
            "Error transferFrom on the contract"
        );
        _totalGlqIncentive += glqAmount;
    }

    function removeIncentive(uint256 glqAmount) public {

        IERC20 glqToken = IERC20(_glqTokenAddress);
        require(
            msg.sender == _glqDeployerManager,
            "Only the Glq Deployer can remove incentive from the smart-contract");
        require(
            glqToken.balanceOf(address(this)) >= glqAmount,
            "Insufficient funds from the deployer contract");
        require(
            glqToken.transfer(msg.sender, glqAmount) == true,
            "Error transfer on the contract"
        );

        _totalGlqIncentive -= glqAmount;
    }


    function depositGlq(uint256 glqAmount) public {

        IERC20 glqToken = IERC20(_glqTokenAddress);
        require(
            glqToken.balanceOf(msg.sender) >= glqAmount,
            "Insufficient funds from the sender");
        require(
           glqToken.transferFrom(msg.sender, address(this), glqAmount) == true,
           "Error transferFrom on the contract"
        );

        uint256 index = _indexStaker[msg.sender];
        _totalStaked += glqAmount;

        if (index == 0) {
            GlqStaker memory staker = GlqStaker(msg.sender, block.number, glqAmount, _stakersIndex, false);
            _stakers.push(staker);
            _indexStaker[msg.sender] = _stakersIndex;

            emit NewStakerRegistered(msg.sender, block.number, glqAmount);
            _stakersIndex = _stakersIndex.add(1);
        }
        else {
            if (_stakers[index-1].amount > 0) {
                claimGlq();
            }
            _stakers[index-1].amount += glqAmount;
        }
    }

    function removeStaker(GlqStaker storage staker) private {

        uint256 currentIndex = _indexStaker[staker.wallet]-1;
        _indexStaker[staker.wallet] = 0;
        for (uint256 i= currentIndex ; i < _stakers.length-1 ; i++) {
            _stakers[i] = _stakers[i+1];
            _stakers[i].index_at = _stakers[i].index_at.sub(1);
            _indexStaker[_stakers[i].wallet] = _stakers[i].index_at;
        }
        _stakers.pop();

        _stakersIndex = _stakersIndex.sub(1);
        if (_stakersIndex == 0) { _stakersIndex = 1; }
    }

    function emergencyWithdraw() public {

        require(
            _emergencyWithdraw == true,
            "The emergency withdraw feature is not enabled"
        );
        uint256 index = _indexStaker[msg.sender];
        require (index > 0, "Invalid staking index");
        GlqStaker storage staker = _stakers[index - 1];
        IERC20 glqToken = IERC20(_glqTokenAddress);

        require(
            staker.amount > 0,
         "Not funds deposited in the staking contract");

        require(
            glqToken.transfer(msg.sender, staker.amount) == true,
            "Error transfer on the contract"
        );
        staker.amount = 0;
    }

    function withdrawGlq() public {

        uint256 index = _indexStaker[msg.sender];
        require (index > 0, "Invalid staking index");
        GlqStaker storage staker = _stakers[index - 1];
        IERC20 glqToken = IERC20(_glqTokenAddress);
        require(
            staker.amount > 0,
         "Not funds deposited in the staking contract");
    
        claimGlq();

        _totalStaked -= staker.amount;
        require(
            glqToken.balanceOf(address(this)) >= staker.amount,
            "Insufficient funds from the deployer contract");
        require(
            glqToken.transfer(msg.sender, staker.amount) == true,
            "Error transfer on the contract"
        );
        staker.amount = 0;
        
        if (staker.already_withdrawn) {
            removeStaker(staker);
        } else {
            staker.already_withdrawn = true;
        }
    }

    function percent(uint256 numerator, uint256 denominator, uint256 precision) private pure returns(uint256) {

        uint256 _numerator  = numerator * 10 ** (precision+1);
        uint256 _quotient =  ((_numerator / denominator) + 5) / 10;
        return ( _quotient);
    }

    function claimGlq() public returns(uint256) {

        uint256 index = _indexStaker[msg.sender];
        require (index > 0, "Invalid staking index");
        GlqStaker storage staker = _stakers[index - 1];
        uint256 glqToClaim = getGlqToClaim(msg.sender);
        IERC20 glqToken = IERC20(_glqTokenAddress);
        if (glqToClaim == 0) { return 0; }

        require(
            glqToken.balanceOf(address(this)) >= glqToClaim,
            "Not enough funds in the staking program to claim rewards"
        );

        staker.block_number = block.number;

        require(
            glqToken.transfer(msg.sender, glqToClaim) == true,
            "Error transfer on the contract"
        );
        return (glqToClaim);
    }


}