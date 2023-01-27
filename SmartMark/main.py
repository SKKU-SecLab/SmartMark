import EmbedWatermark as ewm
import VerifyWatermark as vwm
import subprocess as sp
import os
import sys
import re
import random
from Crypto.Hash import keccak

## Map each opcode to a byte value
opcode2Byte = {'STOP':'00', 'ADD':'01', 'MUL':'02', 'SUB':'03', 'DIV':'04', 'SDIV':'05', 'MOD':'06', 'SMOD':'07', 'ADDMOD':'08', 'MULMOD':'09', 'EXP':'0a', 'SIGNEXTEND':'0b', 
         'LT':'10', 'GT':'11', 'SLT':'12', 'SGT':'13', 'EQ':'14', 'ISZERO':'15', 'AND':'16', 'OR':'17', 'XOR':'18', 'NOT':'19', 'BYTE':'1a', 'SHL':'1b', 'SHR':'1c', 'SAR':'1d', 'SHA3':'20',
         'ADDRESS':'30', 'BALANCE':'31', 'ORIGIN':'32', 'CALLER':'33', 'CALLVALUE':'34', 'CALLDATALOAD':'35', 'CALLDATASIZE':'36', 'CALLDATACOPY':'37', 'CODESIZE':'38', 'CODECOPY':'39', 'GASPRICE':'3a', 'EXTCODESIZE':'3b', 'EXTCODECOPY':'3c', 'RETURNDATASIZE':'3d', 'RETURNDATACOPY':'3e', 'EXTCODEHASH':'3f', 'BLOCKHASH':'40', 'COINBASE':'41', 'TIMESTAMP':'42', 'NUMBER':'43', 'DIFFICULTY':'44', 'GASLIMIT':'45', 'CHAINID':'46', 'SELFBALANCE':'47', 'BASEFEE':'48',
         'POP':'50', 'MLOAD':'51', 'MSTORE':'52', 'MSTORE8':'53', 'SLOAD':'54', 'SSTORE':'55', 'JUMP':'56', 'JUMPI':'57', 'PC':'58', 'MSIZE':'59', 'GAS':'5a', 'JUMPDEST':'5b',
         'PUSH1':'60', 'PUSH2':'61', 'PUSH3':'62', 'PUSH4':'63', 'PUSH5':'64', 'PUSH6':'65', 'PUSH7':'66', 'PUSH8':'67', 'PUSH9':'68', 'PUSH10':'69', 'PUSH11':'6a', 'PUSH12':'6b', 'PUSH13':'6c', 'PUSH14':'6d', 'PUSH15':'6e', 'PUSH16':'6f', 'PUSH17':'70', 'PUSH18':'71', 'PUSH19':'72', 'PUSH20':'73', 'PUSH21':'74', 'PUSH22':'75', 'PUSH23':'76', 'PUSH24':'77', 'PUSH25':'78', 'PUSH26':'79', 'PUSH27':'7a', 'PUSH28':'7b', 'PUSH29':'7c', 'PUSH30':'7d', 'PUSH31':'7e', 'PUSH32':'7f',
         'DUP1':'80', 'DUP2':'81', 'DUP3':'82', 'DUP4':'83', 'DUP5':'84', 'DUP6':'85', 'DUP7':'86', 'DUP8':'87', 'DUP9':'88', 'DUP10':'89', 'DUP11':'8a', 'DUP12':'8b', 'DUP13':'8c', 'DUP14':'8d', 'DUP15':'8e', 'DUP16':'8f',
         'SWAP1':'90', 'SWAP2':'91', 'SWAP3':'92', 'SWAP4':'93', 'SWAP5':'94', 'SWAP6':'95', 'SWAP7':'96', 'SWAP8':'97', 'SWAP9':'98', 'SWAP10':'99', 'SWAP11':'9a', 'SWAP12':'9b', 'SWAP13':'9c', 'SWAP14':'9d', 'SWAP15':'9e', 'SWAP16':'9f',
         'LOG0':'a0', 'LOG1':'a1', 'LOG2':'a2', 'LOG3':'a3', 'LOG4':'a4', 'PUSH':'b0', 'DUP':'b1', 'SWAP':'b2', 'CREATE':'f0', 'CALL':'f1', 'CALLCODE':'f2', 'RETURN':'f3', 'DELEGATECALL':'f4', 'CREATE2':'f5', 'STATICCALL':'fa', 'REVERT':'fd', 'INVALID':'fe', 'SELFDESTRUCT':'ff'}

## Map each byte value of opcode to gas cost
byte2Cost = {'00':0, '01':3, '02':5, '03':3, '04':5, '05':5, '06':5, '07':5, '08':8, '09':8, '0a':10, '0b':5, 
 '10':3, '11':3, '12':3, '13':3, '14':3, '15':3, '16':3, '17':3, '18':3, '19':3, '1a':3, '1b':3, '1c':3, '1d':3, 
 '20':30, '30':2, '31':100, '32':2, '33':2, '34':2, '35':3, '36':2, '37':3, '38':2, '39':3, '3a':2, '3b':100, '3c':103, '3d':2, '3e':3, '3f':100, '40':20, 
 '41':2, '42':2, '43':2, '44':2, '45':2, '46':2, '47':2, '48':2, '50':2, '51':3, '52':3, '53':3, '54':100, '55':100, 
 '56':8, '57':10, '58':2, '59':2, '5a':2, '5b':1, 
 '60':3, '61':3, '62':3, '63':3, '64':3, '65':3, '66':3, '67':3, '68':3, '69':3, '6a':3, '6b':3, '6c':3, '6d':3, '6e':3, '6f':3, '70':3, '71':3, '72':3, '73':3, '74':3, '75':3, '76':3, '77':3, '78':3, '79':3, '7a':3, '7b':3, '7c':3, '7d':3, '7e':3, '7f':3, 
 '80':3, '81':3, '82':3, '83':3, '84':3, '85':3, '86':3, '87':3, '88':3, '89':3, '8a':3, '8b':3, '8c':3, '8d':3, '8e':3, '8f':3, '90':3, '91':3, '92':3, '93':3, '94':3, '95':3, '96':3, '97':3, '98':3, '99':3, '9a':3, '9b':3, '9c':3, '9d':3, '9e':3, '9f':3, 
 'a0':375, 'a1':375, 'a2':375, 'a3':375, 'a4':375, 'b0':10, 'b1':10, 'b2':10, 'f0':3200, 'f1':100, 'f2':100, 'f3':10, 'f4':100, 'f5':3200, 'fa':100, 'fd':10, 'fe':0, 'ff':5000}

singleInstReg = re.compile("([0-9]{1,5})(: )([A-Z]{1,14})([0-9]{1,2})*( )*(0x)*([0-9a-f]{1,64})*")


#####################################################################################################################


class ContractData:
    
    def __init__(self, CFG_path : str, WRO_path : str, WROMAC_path : str, WM_path : str, CFGBuilder_path : str, runtimeBytecode_path : str,
                 length_WM : int, number_WM : int, minGasCost : int, opGroupRatio : int, maxOpcodeNum : int):
        
        os.makedirs('./SmartMark_output',exist_ok=True)
        
        reply = str(input("Do you wanna embed or verify the watermark(s)? (embed:1, verify:0) [0/1] : ")).strip()
        self.status = int(reply)
        
        if self.status == 0 and (WRO_path == '' or WROMAC_path == ''):
            print("\n[Failed]\nYou have to give the paths of both WRO (flag: -W or --WRO) and WROMAC (flag: -M or --WROMAC)")
            sys.exit(0)
        elif self.status ==1 and (length_WM == 0 or number_WM == 0):
            print("\n[Failed]\nYou have to give both the length (flag: -L or --length) and the number (flag: -N or --number) of watermark(s) to be embedded.")
            sys.exit(0)
        
        self.CFG_path = CFG_path if CFG_path != '' else './SmartMark_output/CFG.json'
        self.WRO_path = WRO_path if WRO_path != '' else './SmartMark_output/WRO'
        self.WROMAC_path = WROMAC_path if WROMAC_path != '' else './SmartMark_output/WROMAC'
        self.WM_path = WM_path if WM_path != '' else './SmartMark_output/WM'
        self.CFGBuilder_path = CFGBuilder_path
        self.runtimeBytecode_path = runtimeBytecode_path
        
        self.len_WM = length_WM
        self.num_WM = number_WM
        
        self.gasCost = minGasCost
        self.ratio = opGroupRatio
        self.opcodeNum = maxOpcodeNum
        
        self.originBytestreamList = list()
        self.watermarkableBytestreamList = list()
        self.opcodeGroupList = list()
#         self.opcodeGroupList = list()
        
    
    def buildCFG(self, inputCFGBuilder_path : str, inputBytecode_path : str) -> None:
                
        reply = str(input("Build CFG from a runtime bytecode? (It you already have one, just select 'n') [y/n] : ")).lower().strip()
        if reply[0] == 'y':
            if inputCFGBuilder_path == "" or inputBytecode_path == "":
                print("\n[Failed]\nYou have to give both the path of the EtherSolve tool (flag: -B or --CFG-builder) and the path of a contract runtime bytecode (flag: -R or --bin_runtime)")
                sys.exit(0)

            build_command = "java -jar "+inputCFGBuilder_path+"/EtherSolve.jar " + inputBytecode_path + " -r -o" + self.CFG_path + " -j"
            sp.call(build_command, shell=True)
        elif reply[0] == 'n':
            if self.CFG_path == "./SmartMark_output/CFG.json":
                print("\n[Failed]\nYou have to give the path of the CFG of a contract runtime bytecode (flag: -I or --CFG)")
                sys.exit(0)
            return
        
    def parseCFG(self) -> None:
        
        self.buildCFG(self.CFGBuilder_path, self.runtimeBytecode_path)
        
        with open(self.CFG_path) as cr:
            
            CFG_line = cr.readline()
            
            cnt = 0
            while CFG_line:
                CFGBlockLine = self.findCFGBlock(CFG_line, cr)

                if CFGBlockLine == -1:
                    break
            
                CFG_line = cr.readline()
                CFG_line = cr.readline()
                
                if 'common' in CFG_line:
                    
                    CFGBlockBytecode = self.findCFGBlockBytecode(CFG_line, cr)
                    instructions = singleInstReg.finditer(CFGBlockBytecode)
                    
                    this_blockBytestream = str()
                    
                    for i in instructions:
                        if i[4] is None:
                            opcode = i[3]
                        else:
                            opcode = i[3] + i[4]
                        
                        opcode = opcode2Byte[opcode]
                        this_blockBytestream += opcode
                    
                    if this_blockBytestream not in self.originBytestreamList:
                        self.originBytestreamList.append(this_blockBytestream)
                        
                        if self.status:
                            self.genOpcodeGroup(this_blockBytestream)                 
     
    def findCFGBlock(self, CFG_line : str, CFG_fd : int) -> str:
        while 'offset' not in CFG_line:
            CFG_line = CFG_fd.readline()
            
            if not CFG_line:
                return -1
        
        CFG_line = re.split('\:', CFG_line)[1]
        CFGBlockLine = re.split('\,', CFG_line)[0]
        
        return CFGBlockLine
    
    def findCFGBlockBytecode(self, CFG_line : str, CFG_fd : int) -> str:
        while 'parsedOpcodes' not in CFG_line:
            CFG_line = CFG_fd.readline()
        
        CFG_line = re.split('\"', CFG_line)[3]
        return CFG_line
    
    def genOpcodeGroup(self, blockBytestream):
                        
        opcodeSequence = str()
        opcodeSequenceCost = 0

        breakNow = False

        for init_opcode_idx in range(0, len(blockBytestream), 2):

            if breakNow == True:
                break

            opcode_idx = init_opcode_idx

            while True:
                if len(opcodeSequence) > self.opcodeNum*2:
                    break
                    
                if opcodeSequenceCost >= self.gasCost:
                    if opcodeSequence not in self.opcodeGroupList:
                        self.opcodeGroupList.append(opcodeSequence)
                        
                    extend_opcode_idx = opcode_idx
                    
                    while (extend_opcode_idx+1) < len(blockBytestream):
                        if len(opcodeSequence) >= self.opcodeNum*2:
                            opcodeSequence = str()
                            opcodeSequenceCost = 0
                            break
                        
                        tmp_opcode = blockBytestream[extend_opcode_idx] + blockBytestream[extend_opcode_idx+1]
                        opcodeSequence = opcodeSequence + tmp_opcode
                        
                        extend_opcode_idx += 2
                        
                        if opcodeSequence not in self.opcodeGroupList:
                            self.opcodeGroupList.append(opcodeSequence)
                        
                    opcodeSequence = str()
                    opcodeSequenceCost = 0
                    break
                
                else:
                    if (opcode_idx+1) < len(blockBytestream):
                        tmp_opcode = blockBytestream[opcode_idx] + blockBytestream[opcode_idx+1]
                        opcodeSequence = opcodeSequence + tmp_opcode
                        opcodeSequenceCost = opcodeSequenceCost + byte2Cost[tmp_opcode]
                        
                        opcode_idx += 2
                    else:
                        breakNow = True
                        break
                        
    
    def embed_or_verify(self) -> None:
        if self.status:
            self.embed_watermark()
        else:
            self.verify_watermark()
    
    def embed_watermark(self) -> None:
        
        self.opcodeGroupList = random.sample(self.opcodeGroupList,int(len(self.opcodeGroupList)*(self.ratio/100)))
        
        self.watermarkableBytestreamList = ewm.generateWatermarkableBytestreams(self.originBytestreamList, self.opcodeGroupList, self.ratio)
        
        watermark_bytes = ewm.electWatermarkBytes(self.watermarkableBytestreamList, self.len_WM, self.num_WM)

        WRO = ewm.createWRO(self.watermarkableBytestreamList, watermark_bytes, self.opcodeGroupList, self.len_WM, self.num_WM)

        with open(self.WRO_path, 'w') as ww:
            ww.write(WRO)
        
        WRO_MAC = keccak.new(digest_bits=256)
        WRO_MAC.update(WRO.encode('utf-8'))
        with open(self.WROMAC_path, 'w') as ww:
            ww.write(WRO_MAC.hexdigest())
            
        print("\n[EMBEDDING SUCCEED]\nThis contract has been successfully watermarked. (see " + self.WRO_path + " and " + self.WROMAC_path + ")")
            
    def verify_watermark(self) -> None:
        
        watermarks, self.len_WM, watermarkableBlock_hashs, WM_byte_offsets, self.opcodeGroupList = vwm.readWRO(self.WRO_path, self.WROMAC_path)
        
        self.watermarkableBytestreamList = vwm.generateBytestreamsHashs(self.originBytestreamList, self.opcodeGroupList, self.ratio)
        
        this_watermarks = vwm.extractWatermark(self.watermarkableBytestreamList, watermarkableBlock_hashs, WM_byte_offsets, self.len_WM)
        
        
        with open(self.WM_path, 'w') as ww:
            ww.write("watermark verification results of : "+self.CFG_path+'\n')
        
        wa = open(self.WM_path, 'a')
        watermark_verified = False
        for w in range(0, len(watermarks)):
            if watermarks[w] == this_watermarks[w]:
                watermark_verified = True
                verify_result = "verified"
            else:
                verify_result = "not verified"
            wa.write(watermarks[w] + "  =>  " + this_watermarks[w] + "  :  [" + verify_result + "]\n")
        wa.close()
        
        if watermark_verified == True:
            print("\n[VERIFIED]\nThis contract has been succesfully verified by given WRO. (see " + self.WM_path + ")")
        else:
            print("\n[NOT VERIFIED]\nThis contract cannot be verified by given WRO. (see " + self.WM_path + ")")
        

#####################################################################################################################

import argparse
parser = argparse.ArgumentParser()
parser.add_argument('-I', '--CFG', type = str, default = "", help = 'path of a CFG json file')
parser.add_argument('-W', '--WRO', type=str, default = "", help = 'path of a WRO file **required for verification**')
parser.add_argument('-M', '--WROMAC', type=str, default = "", help = 'path of a WRO MAC file **required for verification**')
parser.add_argument('-V', '--result', type=str, default = "", help = 'path of a file that contains the verification result')

parser.add_argument('-B', '--CFG_builder', type=str, default = "", help = 'path of the EtherSolve control flow graph builder')
parser.add_argument('-R', '--bin_runtime', type=str, default = "", help = 'path of a runtime bytecode to build control flow graph')

parser.add_argument('-L', '--length', type=int, default=0, help = 'the length of the watermark(s) **required for embedding**')
parser.add_argument('-N', '--number', type=int, default=0, help = 'the number of the watermark(s) **required for embedding**')
parser.add_argument('-c', '--gasCost', type=int, default = 9, help = 'a minumum gas cost for opcode group (default: 9)')
parser.add_argument('-r', '--ratio', type=int, default = 20, help = 'a opcode group ratio (default: 20)')
parser.add_argument('-o', '--maxOpNum', type=int, default = 5, help = 'a max opcode number for opcode grouping (default: 5)')

args = parser.parse_args()

CFG_path = args.CFG
WRO_path = args.WRO
WROMAC_path = args.WROMAC
WM_path = args.result
CFGBuilder_path = args.CFG_builder
bytecode_path = args.bin_runtime

len_WM = args.length
num_WM = args.number
gasCost = args.gasCost
ratio = args.ratio
opcodeNum = args.maxOpNum

if __name__ == "__main__":
    os.makedirs('./SmartMark_output',exist_ok=True)

    conDataObj = ContractData(CFG_path, WRO_path, WROMAC_path, WM_path, CFGBuilder_path, bytecode_path, len_WM, num_WM, gasCost, ratio, opcodeNum)

    conDataObj.parseCFG()
    conDataObj.embed_or_verify()
