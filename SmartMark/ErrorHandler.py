class InSufficientContractSize(Exception):
    def __init__(self, watermarkable_CFGBlock_num : int):
        self.msg="This contract has insufficient number of CFG blocks ("+str(watermarkable_CFGBlock_num)+") to be watermarked. Please use smaller length and number of watermark(s) that the (length * number) does not exceed "+str(watermarkable_CFGBlock_num)+"."
    def __str__(self):
        return self.msg
    
    
class InvalidWROMAC(Exception):
    def __init__(self):
        self.msg="This contract cannot be verified by given invalid WROMAC."
    def __str__(self):
        return self.msg
