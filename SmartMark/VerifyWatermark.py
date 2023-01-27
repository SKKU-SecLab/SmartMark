from ErrorHandler import *
from Crypto.Hash import keccak
import ast
import json
import re

def readWRO(WRO_path, WROMAC_path):
    with open(WRO_path) as wr:
        WRO = wr.readlines()
        
    with open(WROMAC_path) as wr:
        WRO_MAC = wr.readline()
        
    this_WRO_MAC = keccak.new(digest_bits=256)
    this_WRO_MAC.update("".join(WRO).encode('utf-8'))
    if WRO_MAC != this_WRO_MAC.hexdigest():
        raise InvalidWROMAC()
        
    WRO = [wro_line.strip() for wro_line in WRO]

    WM_metadata = WRO[0]
    CFGBuildier_ID = WM_metadata[0:4]
    hashAlgorithm_ID = WM_metadata[4:8]
    len_WM = int(WM_metadata[8:12])
    num_WM = int(WM_metadata[12:16])
    watermark = [WM_metadata[w:w+len_WM*2] for w in range(16, len(WM_metadata), len_WM*2)]
    
    WM_loc_info = WRO[1]
    watermarkableBlock_hashs = [WM_loc_info[w:w+8] for w in range(0, len(WM_loc_info), 16)]
    WM_byte_offsets = [WM_loc_info[w:w+8] for w in range(8, len(WM_loc_info), 16)]
    
    opcodeGroupList = WRO[2]
    opcodeGroupList = ast.literal_eval(opcodeGroupList)
    
    return watermark, len_WM, watermarkableBlock_hashs, WM_byte_offsets,opcodeGroupList


def generateBytestreamsHashs(bytestreams : list, opcodeGroupList : list, ratio : int) -> list:
    
    bytestream_hash_list = list()
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
            
            blockHash = keccak.new(digest_bits=256)
            blockHash.update(watermarkableBytestream.encode('utf-8'))
            blockHash = blockHash.hexdigest()[:8]
            
            bytestream_hash = {"bytestream":watermarkableBytestream, "blockHash":blockHash}
            json.dumps(bytestream_hash)
            bytestream_hash_list.append(bytestream_hash)
                            
    return bytestream_hash_list
        

def extractWatermark(bytestream_hash_list : list, blockHashs : list, WM_offsets : list, len_WM : int) -> list:
    
    watermarks = list()
    watermark = str()
    
    for (recur, blockHash) in enumerate(blockHashs, start=0):
        found_WM_byte = False
        
        for bytestream_hash in bytestream_hash_list:
            if bytestream_hash["blockHash"] == blockHash:
                found_WM_byte = True
                
                WM_offset = int(WM_offsets[recur])
                watermark += bytestream_hash["bytestream"][WM_offset] + bytestream_hash["bytestream"][WM_offset+1]
                break
        if found_WM_byte == False:
            watermark += "  "
        if ((recur+1) % len_WM) ==0:
            watermarks.append(watermark)
            watermark = str()
    return watermarks
