// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
        
import "./SupplyChain.sol";
import "./Retailer.sol";


contract Customer is SupplyChain {
    
    Retailer public retailerContract;
    
    address payable public customerWallet;
    
    address payable public retailerWallet;
    
    mapping(uint => bool) public receivedBatches;
    mapping(address => uint[]) public boughtProducts;
    mapping(uint => bool) public batchToRetailer;
    mapping(uint => bool) public batchReceivedFromRetailer;
    
    enum States {CUSTOMER, CUSTOMERINITIALIZATION, STATE_0_3, PURCHASEPRODUCTS_CUSTOMER, STATE_0_2_5, RECEIVERECEIPT, PAYFORITEM, ADDITEMTOCART}
    
    States private currentState;

    // Product Queue of Blockchain
    uint[] private productQueue;
    uint[] public inventoryQueue;
    uint[] public approvedQueue;
    
    // Events
    event ProductBought(uint productId, address recipient);
    event StateChanged(States from, States to);
    event EnoughAmountChanged(bool value);
    event PaymentCompleteChanged(bool value);
    
    bool private enoughAmount = false;
    bool private paymentComplete = false; 
    
    function initialize(address _retailerContractAddress, address _customerWallet) public {
        currentState = States.CUSTOMERINITIALIZATION;
        
        retailerContract = Retailer(payable(_retailerContractAddress));
        
        customerWallet = payable(_customerWallet);
    
    }
        
        
    function additemtocart_to_payforitem() public {
        //require(currentState == States.ADDITEMTOCART, "Invalid current state for this transition.");
        require(scanCard(), "Guard condition failed.");
        enoughAmount=true;
        if(enoughAmount != false){
			emit EnoughAmountChanged(enoughAmount);
		}

        
        currentState = States.PAYFORITEM;
        emit StateChanged(States.ADDITEMTOCART, States.PAYFORITEM);
    }
    
    function payforitem_to_receivereceipt() public {
        //require(currentState == States.PAYFORITEM, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        updateAmount();
        
        
        currentState = States.RECEIVERECEIPT;
        emit StateChanged(States.PAYFORITEM, States.RECEIVERECEIPT);
    }
    
    function receivereceipt_to_state_0_2_5() public {
        //require(currentState == States.RECEIVERECEIPT, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        paymentComplete=true;
        if(paymentComplete != false){
			emit PaymentCompleteChanged(paymentComplete);
		}

        
        currentState = States.STATE_0_2_5;
        emit StateChanged(States.RECEIVERECEIPT, States.STATE_0_2_5);
    }
    
    function purchaseproducts_customer_to_state_0_3() public {
        //require(currentState == States.PURCHASEPRODUCTS_CUSTOMER, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        
        
        
        currentState = States.STATE_0_3;
        emit StateChanged(States.PURCHASEPRODUCTS_CUSTOMER, States.STATE_0_3);
    }
    
    function customerinitialization_to_purchaseproducts_customer() public {
        //require(currentState == States.CUSTOMERINITIALIZATION, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        paymentComplete=false;
        if(paymentComplete != false){
			emit PaymentCompleteChanged(paymentComplete);
		}

        
        currentState = States.PURCHASEPRODUCTS_CUSTOMER;
        emit StateChanged(States.CUSTOMERINITIALIZATION, States.PURCHASEPRODUCTS_CUSTOMER);
    }
    
        
    // Separate Guard and Action Functions Implementation
    function scanCard() private pure returns (bool) {
        // TODO: Implement guard logic
        return true;
    }
    
    function updateAmount() private {
        // TODO: Implement action logic
    }
    
        
    // Event Functions
    function buyProduct(uint _productId) public payable {
        // Function calls should be reordered according to the model
		customerinitialization_to_purchaseproducts_customer();
        additemtocart_to_payforitem();
        payforitem_to_receivereceipt();
        receivereceipt_to_state_0_2_5();
        purchaseproducts_customer_to_state_0_3();
        address payable retailerAddress = retailerContract.retailerWallet();
        (bool success, ) = retailerAddress.call{value: payToRetailer}("");
        require(success, "Purchase of product failed");
        retailerContract.sellProduct(_productId, msg.sender);
        boughtProducts[msg.sender].push(_productId);
        emit ProductBought(_productId, address(this));
    }
    
        
    // Get Contract balance
     function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Function to allow the contract to receive ether
    receive() external payable {}

    // Function to fund the contract for testing purposes
    function fundContract() public payable {}

    function etherWithdraw(address payable recipient) public {
        (bool success, ) = recipient.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }

     function transferRemainingToWallet() public {
        require(msg.sender == customerWallet, "Only the customer can withdraw funds");
        require(address(this).balance > 0, "No remaining balance to withdraw");

        (bool success, ) = customerWallet.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }
    
}