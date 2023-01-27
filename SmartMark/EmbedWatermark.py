import random
import re
from Crypto.Hash import keccak
from ErrorHandler import *

def generateWatermarkableBytestreams(bytestreams : list, opcodeGroupList : list, ratio : int) -> list:
    
    watermarkableBytestreamList = list()
        
    for originBytestream in bytestreams:
        tmp_bytestream = ['z' for i in range(len(originBytestream))]

        for opcodeGroup in opcodeGroupList:
            opcodeGroup_locs = list(re.finditer(opcodeGroup, originBytestream))
            if len(opcodeGroup_locs) > 0:
                for loc in opcodeGroup_locs:
                    for i in range(loc.start(), loc.end()):
                        tmp_bytestream[i] = originBytestream[i]

        watermarkableBytestream = "".join(i for i in tmp_bytestream if i != 'z')

        if len(watermarkableBytestream) >= 2 and watermarkableBytestream not in watermarkableBytestreamList:
            watermarkableBytestreamList.append(watermarkableBytestream)
    return watermarkableBytestreamList


def electWatermarkBytes(bytestreams : list, len_WM : int, num_WM : int) -> list:
    
    if len(bytestreams) < len_WM * num_WM:
        raise InSufficientContractSize(len(bytestreams))
    
    watermarkableBlock_idxs = random.sample(range(0,len(bytestreams)), len_WM*num_WM)
    
    WMLocationInfo = list()
    
    for idx in watermarkableBlock_idxs:
        
        candidateByteList = list()
        WM_bytestream = bytestreams[idx]
        
        for i in range(0, len(WM_bytestream)-1):
            this_byte = WM_bytestream[i] + WM_bytestream[i+1]
            if this_byte not in candidateByteList:
                candidateByteList.append(this_byte)
            
        WM_byte = random.choice(candidateByteList)
        WMLocationInfo.append([idx, WM_byte])
    
    return WMLocationInfo


def createWRO(bytestreams : list, WMLocationInfo : list, opcodeGroupList : list,
              len_WM : int, num_WM : int) -> str:
    
    WRO = str()
    watermark = str()
    
    for loc in WMLocationInfo:
        
        watermarkableBlock_idx = loc[0]
        WM_byte = loc[1]
        
        candidate_byte_offsets = list(re.finditer(WM_byte, bytestreams[watermarkableBlock_idx]))
        num_offsets = len(candidate_byte_offsets)
        
        which_offset = random.randint(0, num_offsets-1)
        WM_byte_offset = str(candidate_byte_offsets[which_offset].start())
        
        if len(WM_byte_offset) < 8:
            WM_byte_offset = "0"*(8-len(WM_byte_offset))+WM_byte_offset
            
        watermarkableBlock_hash = keccak.new(digest_bits=256)
        watermarkableBlock_hash.update(bytestreams[watermarkableBlock_idx].encode('utf-8'))
        
        watermark += WM_byte
        WRO += watermarkableBlock_hash.hexdigest()[:8]+WM_byte_offset
        
    CFGBuildier_ID = "0001" #constant ID value for the EtherSolve tool
    hashAlgorithm_ID = "0001" #constant ID value for the Keccak-256 hash algorithm
    
    str_len_WM = str(len_WM)
    str_num_WM = str(num_WM)
    
    if len(str_len_WM) < 4:
        str_len_WM = "0"*(4-len(str_len_WM))+str_len_WM
                
    if len(str_num_WM) < 4:
        str_num_WM = "0"*(4-len(str_num_WM))+str_num_WM
        
    WRO = CFGBuildier_ID + hashAlgorithm_ID + str_len_WM + str_num_WM + watermark + "\n" + WRO + "\n "+ str(opcodeGroupList)
    
    return WRO
            
