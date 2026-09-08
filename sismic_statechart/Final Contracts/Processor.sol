// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
        
import "./SupplyChain.sol";
import "./Farmer.sol";
import "./Regulator.sol";
import "./Distributor.sol";


contract Processor is SupplyChain {
    
    Farmer public farmerContract;
    Regulator public regulatorContract;
    Distributor public distributorContract;
    
    address payable public processorWallet;
    
    address payable public farmerWallet;
    address payable public regulatorWallet;
    address payable public distributorWallet;
    
    mapping(uint => bool) public receivedBatch;
    mapping(uint => bool) public batchToFarmer;
    mapping(uint => bool) public batchReceivedFromFarmer;
    mapping(uint => bool) public batchToRegulator;
    mapping(uint => bool) public batchReceivedFromRegulator;
    mapping(uint => bool) public batchToDistributor;
    mapping(uint => bool) public batchReceivedFromDistributor;
    
    enum States {PROCESSOR, PROCESSORINITIALIZATION, STATE_0_6, SENDSUPPLY_PROCESSOR, EMAILCONFIRMATION, STATE_0_5_4, RECEIVERECEIPT, APPROVEGOODS_PROCESSOR, STATE_0_4_3, RECEIVEFEEDBACK, CHECKGOODS_PROCESSOR, STATE_0_3_4, RECEIVEPROOF, GOODSSENT, SENDCROP_PROCESSOR, STATE_0_2_4, SENDRECEIPT, REGISTERITEMS}
    
    States private currentState;

    // Product Queue of Blockchain
    uint[] private productQueue;
    uint[] public inventoryQueue;
    uint[] public approvedQueue;
    
    // Events
    event StateChanged(States from, States to);
    event EvaluateProcessedCropChanged(bool value);
    event CropReceivedChanged(bool value);
    event ProcessCropChanged(bool value);
    event FeedbackReceivedChanged(bool value);
    
    bool private evaluateProcessedCrop = false;
    bool private cropReceived = false;
    bool private processCrop = false;
    bool private feedbackReceived = false; 
    
    function initialize(address _farmerContractAddress, address _regulatorContractAddress, address _distributorContractAddress, address _processorWallet) public {
        currentState = States.PROCESSORINITIALIZATION;
        
        farmerContract = Farmer(payable(_farmerContractAddress));
        regulatorContract = Regulator(payable(_regulatorContractAddress));
        distributorContract = Distributor(payable(_distributorContractAddress));
        
        processorWallet = payable(_processorWallet);
    
    }
        
        
    function processorinitialization_to_sendcrop_processor() public {
        //require(currentState == States.PROCESSORINITIALIZATION, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        cropReceived=false;
        if(cropReceived != false){
			emit CropReceivedChanged(cropReceived);
		}

        currentState = States.SENDCROP_PROCESSOR;
        emit StateChanged(States.PROCESSORINITIALIZATION, States.SENDCROP_PROCESSOR);
    }
    
    function sendcrop_processor_to_checkgoods_processor() public {
        //require(currentState == States.SENDCROP_PROCESSOR, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        processCrop=true;
        if(processCrop != false){
			emit ProcessCropChanged(processCrop);
		}

        currentState = States.CHECKGOODS_PROCESSOR;
        emit StateChanged(States.SENDCROP_PROCESSOR, States.CHECKGOODS_PROCESSOR);
    }
    
    function checkgoods_processor_to_approvegoods_processor() public {
        //require(currentState == States.CHECKGOODS_PROCESSOR, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        //sendProductToRegulator();
        evaluateProcessedCrop = true;
        currentState = States.APPROVEGOODS_PROCESSOR;
        emit StateChanged(States.CHECKGOODS_PROCESSOR, States.APPROVEGOODS_PROCESSOR);
    }
    
    function approvegoods_processor_to_sendsupply_processor() public {
        //require(currentState == States.APPROVEGOODS_PROCESSOR, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        evaluateProcessedCrop=true;
        if(evaluateProcessedCrop != false){
			emit EvaluateProcessedCropChanged(evaluateProcessedCrop);
		}

        currentState = States.SENDSUPPLY_PROCESSOR;
        emit StateChanged(States.APPROVEGOODS_PROCESSOR, States.SENDSUPPLY_PROCESSOR);
    }
    
    function sendsupply_processor_to_state_0_6() public {
        //require(currentState == States.SENDSUPPLY_PROCESSOR, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        
        
        currentState = States.STATE_0_6;
        emit StateChanged(States.SENDSUPPLY_PROCESSOR, States.STATE_0_6);
    }
    
    function registeritems_to_sendreceipt() public {
        //require(currentState == States.REGISTERITEMS, "Invalid current state for this transition.");
        require(addStock(), "Guard condition failed.");
        processCrop=false;
        if(processCrop != false){
			emit ProcessCropChanged(processCrop);
		}

        currentState = States.SENDRECEIPT;
        emit StateChanged(States.REGISTERITEMS, States.SENDRECEIPT);
    }
    
    function sendreceipt_to_state_0_2_4() public {
        //require(currentState == States.SENDRECEIPT, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        
        
        currentState = States.STATE_0_2_4;
        emit StateChanged(States.SENDRECEIPT, States.STATE_0_2_4);
    }
    
    function goodssent_to_receiveproof() public {
        //require(currentState == States.GOODSSENT, "Invalid current state for this transition.");
        require(removeStock(), "Guard condition failed.");
        feedbackReceived=false;
        if(feedbackReceived != false){
			emit FeedbackReceivedChanged(feedbackReceived);
		}

        currentState = States.RECEIVEPROOF;
        emit StateChanged(States.GOODSSENT, States.RECEIVEPROOF);
    }
    
    function receiveproof_to_state_0_3_4() public {
        //require(currentState == States.RECEIVEPROOF, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        evaluateProcessedCrop=false;
        if(evaluateProcessedCrop != false){
			emit EvaluateProcessedCropChanged(evaluateProcessedCrop);
		}

        currentState = States.STATE_0_3_4;
        emit StateChanged(States.RECEIVEPROOF, States.STATE_0_3_4);
    }
    
    function receivefeedback_to_receivefeedback() public {
        //require(currentState == States.RECEIVEFEEDBACK, "Invalid current state for this transition.");
        require(evaluateProcessedCrop, "Guard condition failed.");
        
        
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
        //sendProductToDistributor();
        
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
        regulatorContract.receiveBatchFromProcessor{value: (payToRegulator)}(inventoryQueue);
        emit BatchSent(inventoryQueue, BatchOwner.Processor, BatchOwner.Regulator);
        delete inventoryQueue;
    }
    
    function sendBatchToDistributor() private {
         for (uint i = 0; i < approvedQueue.length; i++) {
            batchToDistributor[approvedQueue[i]] = true;
            updateBatchOwner(approvedQueue[i], BatchOwner.Distributor);
        }
        distributorContract.receiveBatchFromProcessor(approvedQueue);
        emit BatchSent(approvedQueue, BatchOwner.Processor, BatchOwner.Distributor);
        delete approvedQueue;
    }
    
        
    // Event Functions
    function receiveBatchFromFarmer(uint _batchId) public {
        require(address(this).balance >= payToFarmer, "Insufficient funds to send to Farmer");
        address payable farmerWalletAddress = farmerContract.farmerWallet();
        (bool success, ) = farmerWalletAddress.call{value: payToFarmer}("");
        require(success, "Transfer to Farmer failed");
        receivedBatch[_batchId] = true;
        emit BatchReceived(_batchId);
        inventoryQueue.push(_batchId);
        if (inventoryQueue.length >= 2) {
            // Function calls should be reordered according to the model
			processorinitialization_to_sendcrop_processor();
            registeritems_to_sendreceipt();
            sendreceipt_to_state_0_2_4();
            sendcrop_processor_to_checkgoods_processor();
            goodssent_to_receiveproof();
            receiveproof_to_state_0_3_4();
            checkgoods_processor_to_approvegoods_processor();
            receivefeedback_to_receivefeedback();
            receivefeedback_to_state_0_4_3();
            approvegoods_processor_to_sendsupply_processor();
            receivereceipt_to_emailconfirmation();
            emailconfirmation_to_state_0_5_4();
            sendsupply_processor_to_state_0_6();
            sendBatchToRegulator();
        }
    }
    
    function receiveBatchFromRegulator(uint[] memory _batchIds) public {
        for (uint i = 0; i < _batchIds.length; i++) {
            batchReceivedFromRegulator[_batchIds[i]] = true;
            approvedQueue.push(_batchIds[i]);
        }
        sendBatchToDistributor();

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
        require(msg.sender == processorWallet, "Only the farmer can withdraw funds");
        require(address(this).balance > 0, "No remaining balance to withdraw");

        (bool success, ) = processorWallet.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }
    
}