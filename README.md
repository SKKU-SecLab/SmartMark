# **SmartMark - Software Watermarking Scheme for Smart Contracts**

*SmartMark* is a novel software watermarking scheme, aiming to protect the ownership of a smart contract against a pirate activity.

This repository contains the *SmartMark* program implemented in Python and the dataset used in the paper published at **ICSE 2023**. Please refer to our paper for the details of design and empirical results.

## Authors

Taeyoung Kim <[tykim0402@skku.edu](mailto:tykim0402@skku.edu)> *- Sungkyunkwan University*

Yunhee Jang <[unijang@skku.edu](mailto:unijang@skku.edu)> *- Sungkyunkwan University*

Chanjong Lee <[leecj323@skku.edu](mailto:leecj323@skku.edu)> *- Sungkyunkwan University*

Hyungjoon Koo <[kevin.koo@skku.edu](mailto:kevin.koo@skku.edu)> *- Sungkyunkwan University*

Hyoungshick Kim <[hyoung@skku.edu](mailto:hyoung@skku.edu)> *- Sungkyunkwan University*

---
<br>

## Requirements
- Install Python3
- Install Java
- Install [EtherSolve](https://github.com/SeUniVr/EtherSolve_ICPC2021_ReplicationPackage.git) (EtherSolve builds the control flow graph of a smart contract, which is used as input of *SmartMark*)

To execute the *SmartMark* program, the pycryptodome python package needs to be installed. The installation command is as follows:

```bash
pip3 install pycryptodome
```

We have confirmed that *SmartMark* can be executed on a 64-bit Ubuntu 18.04 system with Python3.9.


## Installation

```bash
git clone https://github.com/smartmarker/SmartMark.git
cd SmartMark/SmartMark
python3 main.py [flags]
```

<br>

## How to use SmartMark

```bash
SmartMark
    .
    |--- main.py              // Main program that builds and parses CFG and imports two modules
    |--- EmbedWatermark.py    // Module for watermark embedding
    |--- VerifyWatermark.py   // Module for watermark verification
    |--- ErrorHandler.py      // Module for handling error during embdding or verification process
    |--- samples              // Sample data (runtime bytecode, CFG, WRO, WROMAC, verify_result) to test *SmartMark*
```

*SmartMark* can be run with the `python3 main.py [flags]` command.

**Arguments:**

```bash
usage: main.py [-h] [-I CFG] [-W WRO] [-M WROMAC] [-V RESULT] [-B CFG_BUILDER] [-R BIN_RUNTIME] [-L LENGTH] [-N NUMBER]
               [-c GASCOST] [-r RATIO] [-o MAXOPNUM]

optional arguments:
  -h, --help            show this help message and exit
  -I CFG, --CFG CFG     path of a CFG json file
  -W WRO, --WRO WRO     path of a WRO file *required for verification*
  -M WROMAC, --WROMAC WROMAC
                        path of a WRO MAC file *required for verification*
  -V RESULT, --result RESULT
                        path of a file that contains the verification result
  -B CFG_BUILDER, --CFG_builder CFG_BUILDER
                        path of the EtherSolve control flow graph builder
  -R BIN_RUNTIME, --bin_runtime BIN_RUNTIME
                        path of a runtime bytecode to build control flow graph
  -L LENGTH, --length LENGTH
                        the length of watermark *required for embedding*
  -N NUMBER, --number NUMBER
                        the number of watermark *required for embedding*
  -c GASCOST, --gasCost GASCOST
                        a minumum gas cost for opcode group (default: 9)
  -r RATIO, --ratio RATIO
                        a opcode group ratio (default: 20)
  -o MAXOPNUM, --maxOpNum MAXOPNUM
                        a max opcode number for opcode grouping (default: 5)
```
<br>

*SmartMark* asks next two questions to enter the specific execution mode and confirms that the required inputs has been properly submitted.

### 1. **execution mode**

First, it asks which mode to be run (i.e., watermark embedding mode or verification mode) with the message below:

```markdown
Do you wanna embed or verify the watermark(s)? (embed:1, verify:0) [0/1] : !your answer here!
```

- If selected 1 (embed), it enters the embedding mode and calls the functions in EmbedWatermark module afterwards
- If selected 0 (verify), it enters the verification mode and calls the functions in VerifyWatermark module afterwards

The required inputs depends on the currently selected mode.

- **Embedding mode**
    - command example: ```python3 main.py -L 15 -N 3 -I samples/EthealPromoToken_CFG.json```
    - the length of the watermark(s) (flag: -L or —length)
    - the the number of the watermark(s) (flag: -N or —number)
    - [optional] the path of a WRO output file (flag: -W or —WRO)
    - [optional] the path of a WROMAC output file (flag: -M or —WROMAC)

If the embedding process  successfully completed, it shows the message below:
```markdown
[EMBEDDING SUCCEED]
This contract has been successfully watermarked. (see {your_WRO_path_here}) and {your_WROMAC_path_here})
```

- **Verification mode**
    - command example: ```python3 main.py -W SmartMark_output/WRO -M SmartMark_output/WROMAC -I samples/EthealPromoToken_CFG.json```
    - the path of a WRO input file (flag: -W or —WRO)
    - the path of a WROMAC input file (flag: -M or —WROMAC)
    - [optional] the path of a output file that contains the verification result (flag: -V or —result)

If the verification process successfully completed, it shows the message below:

```markdown
[VERIFIED]
This contract has been succesfully verified by given WRO. (see {your_result_path_here})
```

If the verification process successfully completed but the contract is failed to be verified by the given WRO, it shows the message below:
```markdown
[NOT VERIFIED]
This contract cannot be verified by given WRO. (see {your_result_path_here})
```

✅ The optional flags are related to the paths of the output files. If those paths are not given, the output files are saved in the SmartMark_output directory by default.

### 2. control flow graph (CFG) construction

Second, it checks whether the CFG construction needs to be performed before embed or verify the watermark(s) with the message below:

```markdown
Build CFG from a runtime bytecode? (It you already have one, just select 'n') [y/n] : !your answer here!
```

If the only file you have is a **contract runtime bytecode**, select ‘y’ and submits

- the path of the EtherSolve control flow graph builder in your system (flag: -B or —CFG_builder)
- the path of a runtime bytecode to build control flow graph (flag: -R or —bin_runtime)
- [optional] the path of a CFG json output file
> ❗Note: *SmartMark* requires the CFG of a contract to watermark and it only supports the [EtherSolve](https://github.com/SeUniVr/EtherSolve_ICPC2021_ReplicationPackage) CFG builder for now. Get `EtherSolve.jar` file from the EtherSolve GitHub repository, and specify its path by -B (or --CFG_builder) flag.

Otherwise if you already have a **JSON-format** **CFG built by EtherSolve**, select ‘n’ and submits

- the path of a CFG json input file (flag: -I or —CFG)
<br>

### ErrorHandler

This module includes two error-related classes, which can be invoked while embedding and verifying the watermark(s).

- **InSufficientContractSize Error**
This error occurs when the supplied length and the number of watermark(s) are too large to embed watermark(s) into the given contract
```markdown
ErrorHandler.InSufficientContractSize: This contract has insufficient number of CFG blocks ({your_contract_blockNum}) to be watermarked. Please use smaller length and number of watermark(s) that the (length * number) does not exceed {your_contract_blockNum}.
```
- **InvalidWROMAC Error**
This error occurs when the given WRO cannot be verified by the given WROMAC. This means that the Keccak-256 hash value of the WRO does not match with the WROMAC.
```markdown
ErrorHandler.InvalidWROMAC: This contract cannot be verified by given invalid WROMAC.
```

### samples

This folder contains the following data that can be used to test *SmartMark*

- **runtime bytecode data**: {DividendPayingToken, EthealPromoToken}bin-runtime
- **CFG data**: {DividendPayingToken_CFG, EthealPromoToken_CFG}.json
- **WRO data**: {DividendPayingToken, EthealPromoToken}.WRO
- **WROMAC data**: {DividendPayingToken, EthealPromoToken}.WROMAC
- **verification result data**: {DividendPayingToken, EthealPromoToken, E_DividendPayingToken-V_EthealPromoToken}.result

Especially, E_DividendPayingToken-V_EthealPromoToken.result file is the result of verifying EthealPromoToken contract using the WRO of DividendPayingToken contract

---

<br>


## Dataset

We provide the smart contract dataset involved in our experiments (Section VI).

```bash
dataset
    .
    |--- runtime_bytecodes_27824
    |--- CFG_jsons_27824    
    |--- Solidity_codes_9324
```

### **runtime_bytecodes_27824**

This dataset contains the runtime bytecodes of 27,824 unique smart contracts. 
For this, we collected a total of 4,112,336 contract runtime bytecodes from the fifteen million Ethereum Mainnet blocks (deployed between 30 July 2015 to 21 June 2022), and performed DBSCAN clustering to exclude the clone contracts.

### **CFG_jsons_27824**

This dataset contains the 27,824 JSON-format CFG files built from the above runtime bytecode dataset using EtherSolve tool.

### **Solidity_codes_9324**

This dataset contains the 9,324 Solidity source codes for the contracts that have publicly released source codes among the above 27,824 contracts. We collected these codes by crawling EtherScan.
In EtherScan, even for a single contract address, there would be multiple Solidity source codes consisting of multiple contracts that are in an inheritance relationship. For successful compilation, we collected all source codes for each address, and sorted them in the order of inheritance in a single file, and then removed all unnecessary instructions, such as annotations, *import* instructions, and redundant pragma versions.
