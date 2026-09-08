// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
        
import "./SupplyChain.sol";
import "./Distributor.sol";
import "./Regulator.sol";
import "./Customer.sol";


contract Retailer is SupplyChain {
    
    Distributor public distributorContract;
    Regulator public regulatorContract;
    Customer public customerContract;
    
    address payable public retailerWallet;
    
    address payable public distributorWallet;
    address payable public regulatorWallet;
    address payable public customerWallet;
    
    mapping(uint => bool) public receivedBatch;
    mapping(uint => bool) public batchToDistributor;
    mapping(uint => bool) public batchReceivedFromDistributor;
    mapping(uint => bool) public batchToRegulator;
    mapping(uint => bool) public batchReceivedFromRegulator;
    mapping(uint => bool) public batchToCustomer;
    mapping(uint => bool) public batchReceivedFromCustomer;
    
    enum States {RETAILER, RETAILERINITIALIZATION, STATE_0_6, PURCHASEPRODUCTS_RETAILER, STATE_0_5_4, GIVERECEIPT, SCANITEM, APPROVEPRODUCTS_RETAILER, STATE_0_4_3, RECEIVEFEEDBACK, CHECKPRODUCTS_RETAILER, STATE_0_3_4, RECEIVEPROOF, PRODUCTSSENT, SENDSTOCK_RETAILER, STATE_0_2_4, SENDRECEIPT, REGISTERITEMS}
    
    States private currentState;

    // Product Queue of Blockchain
    uint[] private productQueue;
    uint[] public inventoryQueue;
    uint[] public approvedQueue;
    
    // Events
    event ProductSold(uint batchId, uint productId, address recipient);
    event StateChanged(States from, States to);
    event StockReceivedChanged(bool value);
    event StockSentChanged(bool value);
    event EvaluateStockChanged(bool value);
    event StockRegisteredChanged(bool value);
    
    bool private stockReceived = false;
    bool private stockSent = false;
    bool private evaluateStock = false;
    bool private stockRegistered = false; 
    
    function initialize(address _distributorContractAddress, address _regulatorContractAddress, address _customerContractAddress, address _retailerWallet) public {
        currentState = States.RETAILERINITIALIZATION;
        
        distributorContract = Distributor(payable(_distributorContractAddress));
        regulatorContract = Regulator(payable(_regulatorContractAddress));
        customerContract = Customer(payable(_customerContractAddress));
        
        retailerWallet = payable(_retailerWallet);
    
    }
        
        
    function retailerinitialization_to_sendstock_retailer() public {
        //require(currentState == States.RETAILERINITIALIZATION, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        stockReceived=false;
        if(stockReceived != false){
			emit StockReceivedChanged(stockReceived);
		}

        
        currentState = States.SENDSTOCK_RETAILER;
        emit StateChanged(States.RETAILERINITIALIZATION, States.SENDSTOCK_RETAILER);
    }
    
    function sendstock_retailer_to_checkproducts_retailer() public {
        //require(currentState == States.SENDSTOCK_RETAILER, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        stockRegistered=true;
        if(stockRegistered != false){
			emit StockRegisteredChanged(stockRegistered);
		}

        
        currentState = States.CHECKPRODUCTS_RETAILER;
        emit StateChanged(States.SENDSTOCK_RETAILER, States.CHECKPRODUCTS_RETAILER);
    }
    
    function checkproducts_retailer_to_approveproducts_retailer() public {
        //require(currentState == States.CHECKPRODUCTS_RETAILER, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        //sendProductToRegulator();
        
        evaluateStock=true;
        currentState = States.APPROVEPRODUCTS_RETAILER;
        emit StateChanged(States.CHECKPRODUCTS_RETAILER, States.APPROVEPRODUCTS_RETAILER);
    }
    
    function approveproducts_retailer_to_purchaseproducts_retailer() public {
        //require(currentState == States.APPROVEPRODUCTS_RETAILER, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        evaluateStock=true;
        if(evaluateStock != false){
			emit EvaluateStockChanged(evaluateStock);
		}

        
        currentState = States.PURCHASEPRODUCTS_RETAILER;
        emit StateChanged(States.APPROVEPRODUCTS_RETAILER, States.PURCHASEPRODUCTS_RETAILER);
    }
    
    function purchaseproducts_retailer_to_state_0_6() public {
        //require(currentState == States.PURCHASEPRODUCTS_RETAILER, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        //sendProductToCustomer();
        
        
        currentState = States.STATE_0_6;
        emit StateChanged(States.PURCHASEPRODUCTS_RETAILER, States.STATE_0_6);
    }
    
    function registeritems_to_sendreceipt() public {
        //require(currentState == States.REGISTERITEMS, "Invalid current state for this transition.");
        require(addStock(), "Guard condition failed.");
        stockReceived=true;
        if(stockReceived != false){
			emit StockReceivedChanged(stockReceived);
		}

        
        currentState = States.SENDRECEIPT;
        emit StateChanged(States.REGISTERITEMS, States.SENDRECEIPT);
    }
    
    function sendreceipt_to_state_0_2_4() public {
        //require(currentState == States.SENDRECEIPT, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        stockRegistered=false;
        if(stockRegistered != false){
			emit StockRegisteredChanged(stockRegistered);
		}

        
        currentState = States.STATE_0_2_4;
        emit StateChanged(States.SENDRECEIPT, States.STATE_0_2_4);
    }
    
    function productssent_to_receiveproof() public {
        //require(currentState == States.PRODUCTSSENT, "Invalid current state for this transition.");
        require(removeStock(), "Guard condition failed.");
        stockSent=true;
        if(stockSent != false){
			emit StockSentChanged(stockSent);
		}

        
        currentState = States.RECEIVEPROOF;
        emit StateChanged(States.PRODUCTSSENT, States.RECEIVEPROOF);
    }
    
    function receiveproof_to_state_0_3_4() public {
        //require(currentState == States.RECEIVEPROOF, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        evaluateStock=false;
        if(evaluateStock != false){
			emit EvaluateStockChanged(evaluateStock);
		}

        
        currentState = States.STATE_0_3_4;
        emit StateChanged(States.RECEIVEPROOF, States.STATE_0_3_4);
    }
    
    function receivefeedback_to_receivefeedback() public {
        //require(currentState == States.RECEIVEFEEDBACK, "Invalid current state for this transition.");
        require(evaluateStock, "Guard condition failed.");
        
        
        
        currentState = States.RECEIVEFEEDBACK;
        emit StateChanged(States.RECEIVEFEEDBACK, States.RECEIVEFEEDBACK);
    }
    
    function receivefeedback_to_state_0_4_3() public {
        //require(currentState == States.RECEIVEFEEDBACK, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        
        
        
        currentState = States.STATE_0_4_3;
        emit StateChanged(States.RECEIVEFEEDBACK, States.STATE_0_4_3);
    }
    
    function scanitem_to_givereceipt() public {
        //require(currentState == States.SCANITEM, "Invalid current state for this transition.");
        require(removeFromStock(), "Guard condition failed.");
        
        
        
        currentState = States.GIVERECEIPT;
        emit StateChanged(States.SCANITEM, States.GIVERECEIPT);
    }
    
    function givereceipt_to_state_0_5_4() public {
        //require(currentState == States.GIVERECEIPT, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        updateCashier();
        
        
        currentState = States.STATE_0_5_4;
        emit StateChanged(States.GIVERECEIPT, States.STATE_0_5_4);
    }
    
        
    // Separate Guard and Action Functions Implementation
    function addStock() private pure returns (bool) {
        // TODO: Implement guard logic
        return true;
    }
    
    function removeStock() private pure returns (bool) {
        // TODO: Implement guard logic
        return true;
    }
    
    function removeFromStock() private pure returns (bool) {
        // TODO: Implement guard logic
        return true;
    }
    
    function sendBatchToRegulator() private {
        for (uint i = 0; i < inventoryQueue.length; i++) {
            batchToRegulator[inventoryQueue[i]] = true;
        }
        regulatorContract.receiveBatchFromRetailer{value: (payToRegulator)}(inventoryQueue);
        emit BatchSent(inventoryQueue, BatchOwner.Retailer, BatchOwner.Regulator);
        delete inventoryQueue;
    }
    
    function sendBatchToCustomer() private {
         for (uint i = 0; i < approvedQueue.length; i++) {
            batchToCustomer[approvedQueue[i]] = true;
            updateBatchOwner(approvedQueue[i], BatchOwner.Customer);
        }
        customerContract.receiveBatchFromRetailer(approvedQueue);
        emit BatchSent(approvedQueue, BatchOwner.Retailer, BatchOwner.Customer);
        delete approvedQueue;
    }
    
    function updateCashier() private {
        // TODO: Implement action logic
    }
    
        
    // Event Functions
    function receiveBatchFromDistributor(uint[] memory _batchIds) public {
        require(address(this).balance >= payToDistributor, "Insufficient funds to send to Distributor");
        address payable distributorAddress = distributorContract.distributorWallet();
        (bool success, ) = distributorAddress.call{value: payToDistributor}("");
        require(success, "Transfer to Distributor failed");
        for (uint i = 0; i < _batchIds.length; i++) {
            receivedBatch[_batchIds[i]] = true;
            emit BatchReceived(_batchIds[i]);
            inventoryQueue.push(_batchIds[i]);
            if (inventoryQueue.length >= 4) {
                // Function calls should be reordered according to the model
			
        retailerinitialization_to_sendstock_retailer();
        sendstock_retailer_to_checkproducts_retailer();
        checkproducts_retailer_to_approveproducts_retailer();
        approveproducts_retailer_to_purchaseproducts_retailer();
        purchaseproducts_retailer_to_state_0_6();
        registeritems_to_sendreceipt();
        sendreceipt_to_state_0_2_4();
        productssent_to_receiveproof();
        receiveproof_to_state_0_3_4();
        receivefeedback_to_receivefeedback();
        receivefeedback_to_state_0_4_3();
        scanitem_to_givereceipt();
        givereceipt_to_state_0_5_4();
                sendBatchToRegulator();
            }
        }
    }
    
    function receiveBatchFromRegulator(uint[] memory _batchIds) public {
        for (uint i = 0; i < _batchIds.length; i++) {
            batchReceivedFromRegulator[_batchIds[i]] = true;
            approvedQueue.push(_batchIds[i]);
        }
    }
    
    function sellProduct (uint _productId, address _customer) public {
        Product memory product = getProductDetails(_productId);
        uint batchId = product.batchId;
        require(productSold[_productId]==false, "Product already sold");
        productSold[_productId]=true;
        emit ProductSold(batchId, _productId, _customer);
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
        require(msg.sender == retailerWallet, "Only the retailer can withdraw funds");
        require(address(this).balance > 0, "No remaining balance to withdraw");

        (bool success, ) = retailerWallet.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }
    
}