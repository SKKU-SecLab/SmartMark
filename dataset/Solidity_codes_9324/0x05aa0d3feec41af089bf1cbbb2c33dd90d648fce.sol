
pragma solidity ^0.4.24;

contract ClearCoinAdExchange {

    
    event lineItemActivated(address indexed wallet);
    event lineItemDeactivated(address indexed wallet);
    event adSlotActivated(address indexed wallet);
    event adSlotDeactivated(address indexed wallet);
    event clickTracked(address indexed lineItem, address indexed adSlot);
    
    address owner;
    
    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {

        require(
            msg.sender == owner,
            "Only owner can call this function."
        );
        _;
    }

    function changeOwner(address new_owner) public onlyOwner {

        owner = new_owner;
    }

    struct LineItem {
        uint256 budget;          // when XCLR is transferred to this line item, it's budget increases; eventually the publisher will get paid from the budget
        string destination_url;  // clicks on creative point here
        uint256 max_cpc;         // maximum XCLR willing to spend for CPC (Cost Per Click) [8 decimals]
        uint256 max_daily_spend; // maximum XCLR to spend per 24 hours [8 decimals]
        uint256 creative_type;   // (1,2,3) => leaderboard (728x90), skyscraper (120x600), medium rectangle (300x250)
        uint256[] categories;    // (1,2,3,4,etc) => (Automotive, Education, Business, ICO, etc)
        bool active;
    }
    
    mapping (address => LineItem) line_items;
    
    modifier lineItemExists {

        require(
            line_items[msg.sender].active,
            "This address has not created a line item."
        );
        _;
    }    
        
    function createLineItem(
        string destination_url,
        uint256 max_cpc,
        uint256 max_daily_spend,
        uint256 creative_type,
        uint256[] categories
    ) public {

        line_items[msg.sender] = LineItem({
            budget: 0,
            destination_url: destination_url,
            max_cpc: max_cpc,
            max_daily_spend: max_daily_spend,
            creative_type: creative_type,
            categories: categories,
            active: true
        });

        emit lineItemActivated(msg.sender);
    }
    
    function deactivateLineItem() public lineItemExists {

        line_items[msg.sender].active = false;
        
        emit lineItemDeactivated(msg.sender);
    }
    
    function activateLineItem() public lineItemExists {

        line_items[msg.sender].active = true;
        
        emit lineItemActivated(msg.sender);
    }


    struct AdSlot {
        string domain;          // domain name of website
        uint256 creative_type;  // (1,2,3) => leaderboard (728x90), skyscraper (120x600), medium rectangle (300x250)
        uint256 min_cpc;        // minimum XCLR willing to accept to display ad
        uint256[] categories;   // (1,2,3,4,etc) => (Automotive, Education, Business, ICO, etc)
        uint256 avg_ad_quality; // reputation of this AdSlot (updated by algorithm that considers NHT% and number of historical clicks)
        bool active;
    }
    
    mapping (address => AdSlot) ad_slots;
    
    modifier adSlotExists {

        require(
            ad_slots[msg.sender].active,
            "This address has not created an ad slot."
        );
        _;
    }
    
    function createAdSlot(
        string domain,
        uint256 creative_type,
        uint256 min_cpc,
        uint256[] categories
    ) public {

        ad_slots[msg.sender] = AdSlot({
            domain: domain,
            creative_type: creative_type,
            min_cpc: min_cpc,
            categories: categories,
            avg_ad_quality: 100, // starts at 100% by default
            active: true
        });

        emit adSlotActivated(msg.sender);
    }
    
    function deactivateAdSlot() public adSlotExists {

        ad_slots[msg.sender].active = false;
        
        emit adSlotDeactivated(msg.sender);
    }
    
    function activateAdSlot() public adSlotExists {

        ad_slots[msg.sender].active = true;
        
        emit adSlotActivated(msg.sender);
    }

    function trackClick(address line_item_address, address ad_slot_address) public onlyOwner {

        emit clickTracked(line_item_address, ad_slot_address);
    }
    
}