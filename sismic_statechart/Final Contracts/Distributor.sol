// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
        
import "./SupplyChain.sol";
import "./Processor.sol";
import "./Regulator.sol";
import "./Retailer.sol";


contract Distributor is SupplyChain {
    
    Processor public processorContract;
    Regulator public regulatorContract;
    Retailer public retailerContract;
    
    address payable public distributorWallet;
    
    address payable public processorWallet;
    address payable public regulatorWallet;
    address payable public retailerWallet;
    
    mapping(uint => bool) public receivedBatch;
    mapping(uint => bool) public batchToProcessor;
    mapping(uint => bool) public batchReceivedFromProcessor;
    mapping(uint => bool) public batchToRegulator;
    mapping(uint => bool) public batchReceivedFromRegulator;
    mapping(uint => bool) public batchToRetailer;
    mapping(uint => bool) public batchReceivedFromRetailer;
    
    enum States {DISTRIBUTOR, DISTRIBUTORINITIALIZATION, STATE_0_6, SENDSTOCK_DISTRIBUTOR, EMAILCONFIRMATION, STATE_0_5_4, RECEIVERECEIPT, APPROVESUPPLY_DISTRIBUTOR, STATE_0_4_3, RECEIVEFEEDBACK, CHECKSUPPLY_DISTRIBUTOR, STATE_0_3_4, RECEIVEPROOF, SUPPLYSENT, SENDSUPPLY_DISTRIBUTOR, STATE_0_2_4, SENDRECEIPT, REGISTERITEMS}
    
    States private currentState;

    // Product Queue of Blockchain
    uint[] private productQueue;
    uint[] public inventoryQueue;
    uint[] public approvedQueue;
    
    // Events
    event StateChanged(States from, States to);
    event ProcessedCropReceivedChanged(bool value);
    event SupplySentChanged(bool value);
    event SupplyReadyChanged(bool value);
    event EvaluateSupplyChanged(bool value);
    event FeedbackReceivedChanged(bool value);
    
    bool private processedCropReceived = false;
    bool private supplySent = false;
    bool private supplyReady = false;
    bool private evaluateSupply = false;
    bool private feedbackReceived = false; 
    
    function initialize(address _processorContractAddress, address _regulatorContractAddress, address _retailerContractAddress, address _distributorWallet) public {
        currentState = States.DISTRIBUTORINITIALIZATION;
        
        processorContract = Processor(payable(_processorContractAddress));
        regulatorContract = Regulator(payable(_regulatorContractAddress));
        retailerContract = Retailer(payable(_retailerContractAddress));
        
        distributorWallet = payable(_distributorWallet);
    
    }
        
        
    function distributorinitialization_to_sendsupply_distributor() public {
        //require(currentState == States.DISTRIBUTORINITIALIZATION, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        processedCropReceived=false;
        if(processedCropReceived != false){
			emit ProcessedCropReceivedChanged(processedCropReceived);
		}

        currentState = States.SENDSUPPLY_DISTRIBUTOR;
        emit StateChanged(States.DISTRIBUTORINITIALIZATION, States.SENDSUPPLY_DISTRIBUTOR);
    }
    
    function sendsupply_distributor_to_checksupply_distributor() public {
        //require(currentState == States.SENDSUPPLY_DISTRIBUTOR, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        supplyReady=true;
        if(supplyReady != false){
			emit SupplyReadyChanged(supplyReady);
		}

        currentState = States.CHECKSUPPLY_DISTRIBUTOR;
        emit StateChanged(States.SENDSUPPLY_DISTRIBUTOR, States.CHECKSUPPLY_DISTRIBUTOR);
    }
    
    function checksupply_distributor_to_approvesupply_distributor() public {
        //require(currentState == States.CHECKSUPPLY_DISTRIBUTOR, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        //sendProductToRegulator();
        evaluateSupply = true;
        currentState = States.APPROVESUPPLY_DISTRIBUTOR;
        emit StateChanged(States.CHECKSUPPLY_DISTRIBUTOR, States.APPROVESUPPLY_DISTRIBUTOR);
    }
    
    function approvesupply_distributor_to_sendstock_distributor() public {
        //require(currentState == States.APPROVESUPPLY_DISTRIBUTOR, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        evaluateSupply=true;
        if(evaluateSupply != false){
			emit EvaluateSupplyChanged(evaluateSupply);
		}

        currentState = States.SENDSTOCK_DISTRIBUTOR;
        emit StateChanged(States.APPROVESUPPLY_DISTRIBUTOR, States.SENDSTOCK_DISTRIBUTOR);
    }
    
    function sendstock_distributor_to_state_0_6() public {
        //require(currentState == States.SENDSTOCK_DISTRIBUTOR, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        
        
        currentState = States.STATE_0_6;
        emit StateChanged(States.SENDSTOCK_DISTRIBUTOR, States.STATE_0_6);
    }
    
    function registeritems_to_sendreceipt() public {
        //require(currentState == States.REGISTERITEMS, "Invalid current state for this transition.");
        require(addStock(), "Guard condition failed.");
        processedCropReceived=true;
        if(processedCropReceived != false){
			emit ProcessedCropReceivedChanged(processedCropReceived);
		}

        currentState = States.SENDRECEIPT;
        emit StateChanged(States.REGISTERITEMS, States.SENDRECEIPT);
    }
    
    function sendreceipt_to_state_0_2_4() public {
        //require(currentState == States.SENDRECEIPT, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        supplyReady=false;
        if(supplyReady != false){
			emit SupplyReadyChanged(supplyReady);
		}

        currentState = States.STATE_0_2_4;
        emit StateChanged(States.SENDRECEIPT, States.STATE_0_2_4);
    }
    
    function supplysent_to_receiveproof() public {
        //require(currentState == States.SUPPLYSENT, "Invalid current state for this transition.");
        require(removeStock(), "Guard condition failed.");
        supplySent=true;
        if(supplySent != false){
			emit SupplySentChanged(supplySent);
		}

        currentState = States.RECEIVEPROOF;
        emit StateChanged(States.SUPPLYSENT, States.RECEIVEPROOF);
    }
    
    function receiveproof_to_state_0_3_4() public {
        //require(currentState == States.RECEIVEPROOF, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        
        
        currentState = States.STATE_0_3_4;
        emit StateChanged(States.RECEIVEPROOF, States.STATE_0_3_4);
    }
    
    function receivefeedback_to_receivefeedback() public {
        //require(currentState == States.RECEIVEFEEDBACK, "Invalid current state for this transition.");
        require(evaluateSupply, "Guard condition failed.");
        
        
        currentState = States.RECEIVEFEEDBACK;
        emit StateChanged(States.RECEIVEFEEDBACK, States.RECEIVEFEEDBACK);
    }
    
    function receivefeedback_to_state_0_4_3() public {
        //require(currentState == States.RECEIVEFEEDBACK, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        
        
        currentState = States.STATE_0_4_3;
        emit StateChanged(States.RECEIVEFEEDBACK, States.STATE_0_4_3);
    }
    
    function emailconfirmation_to_state_0_5_4() public {
        //require(currentState == States.EMAILCONFIRMATION, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        //sendProductToRetailer();
        
        currentState = States.STATE_0_5_4;
        emit StateChanged(States.EMAILCONFIRMATION, States.STATE_0_5_4);
    }
    
    function receivereceipt_to_emailconfirmation() public {
        //require(currentState == States.RECEIVERECEIPT, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        feedbackReceived=true;
        if(feedbackReceived != false){
			emit FeedbackReceivedChanged(feedbackReceived);
		}

        currentState = States.EMAILCONFIRMATION;
        emit StateChanged(States.RECEIVERECEIPT, States.EMAILCONFIRMATION);
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
    
    function sendBatchToRegulator() private {
        for (uint i = 0; i < inventoryQueue.length; i++) {
            batchToRegulator[inventoryQueue[i]] = true;
        }
        regulatorContract.receiveBatchFromDistributor{value: (payToRegulator)}(inventoryQueue);
        emit BatchSent(inventoryQueue, BatchOwner.Distributor, BatchOwner.Regulator);
        delete inventoryQueue;
    }
    
    function sendBatchToRetailer() private {
         for (uint i = 0; i < approvedQueue.length; i++) {
            batchToRetailer[approvedQueue[i]] = true;
            updateBatchOwner(approvedQueue[i], BatchOwner.Retailer);
        }
        retailerContract.receiveBatchFromDistributor(approvedQueue);
        emit BatchSent(approvedQueue, BatchOwner.Distributor, BatchOwner.Retailer);
        delete approvedQueue;
    }
    
        
    // Event Functions
    function receiveBatchFromProcessor(uint[] memory _batchIds) public {
        require(address(this).balance >= payToProcessor, "Insufficient funds to send to Processor");
        address payable processorWalletAddress = processorContract.processorWallet();
        (bool success, ) = processorWalletAddress.call{value: payToProcessor}("");
        require(success, "Transfer to Processor failed");
        for (uint i = 0; i < _batchIds.length; i++) {
            receivedBatch[_batchIds[i]] = true;
            emit BatchReceived(_batchIds[i]);
            inventoryQueue.push(_batchIds[i]);
            if (inventoryQueue.length >= 4) {
            // Function calls should be reordered according to the model
                distributorinitialization_to_sendsupply_distributor();
                registeritems_to_sendreceipt();
                sendreceipt_to_state_0_2_4();
                sendsupply_distributor_to_checksupply_distributor();
                supplysent_to_receiveproof();
                receiveproof_to_state_0_3_4();
                checksupply_distributor_to_approvesupply_distributor();
                receivefeedback_to_receivefeedback();
                receivefeedback_to_state_0_4_3();
                approvesupply_distributor_to_sendstock_distributor();
                receivereceipt_to_emailconfirmation();
                emailconfirmation_to_state_0_5_4();
                sendstock_distributor_to_state_0_6();
                sendBatchToRegulator();
            }
        }
    }
    
    function receiveBatchFromRegulator(uint[] memory _batchIds) public {
        for (uint i = 0; i < _batchIds.length; i++) {
            batchReceivedFromRegulator[_batchIds[i]] = true;
            approvedQueue.push(_batchIds[i]);
        }
        sendBatchToRetailer();

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
        require(msg.sender == distributorWallet, "Only the distributor can withdraw funds");
        require(address(this).balance > 0, "No remaining balance to withdraw");

        (bool success, ) = distributorWallet.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }
    
}