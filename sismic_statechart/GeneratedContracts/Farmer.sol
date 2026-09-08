// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
        
import "./SupplyChain.sol";
import "./Regulator.sol";
import "./Processor.sol";


contract Farmer is SupplyChain {
    
    Regulator public regulatorContract;
    Processor public processorContract;
    
    address payable public farmerWallet;
    
    address payable public regulatorWallet;
    address payable public processorWallet;
    
    mapping(uint => bool) public batchToRegulator;
    mapping(uint => bool) public batchReceivedFromRegulator;
    mapping(uint => bool) public batchToProcessor;
    mapping(uint => bool) public batchReceivedFromProcessor;
    
    enum States {FARMER, FARMERINITIALIZATION, STATE_0_5, SENDCROP_FARMER, EMAILCONFIRMATION, STATE_0_4_4, RECEIVERECEIPT, APPROVECROP_FARMER, STATE_0_3_3, RECEIVEFEEDBACK, CHECKCROP_FARMER, STATE_0_2_4, RECEIVEPROOF, CROPSENT}
    
    States private currentState;

    // Product Queue of Blockchain
    uint[] private productQueue;
    uint[] public inventoryQueue;
    uint[] public approvedQueue;
    
    // Events
    
    event StateChanged(States from, States to);
    event FeedbackReceivedChanged(bool value);
    event CropHarvestedChanged(bool value);
    event EvaluateCropChanged(bool value);
    event ReceiptReceivedChanged(bool value);
    
    bool private feedbackReceived = false;
    bool private cropHarvested = false;
    bool private evaluateCrop = false;
    bool private receiptReceived = false; 
    
    function initialize(address _regulatorContractAddress, address _processorContractAddress, address _farmerWallet) public {
        currentState = States.FARMERINITIALIZATION;
        
        regulatorContract = Regulator(payable(_regulatorContractAddress));
        processorContract = Processor(payable(_processorContractAddress));
        
        farmerWallet = payable(_farmerWallet);
    
    }
        
    function createProductFarmer(string memory _name, string memory _description) public {
        uint productId = createProduct(_name, _description);
        productQueue.push(productId);
        if (productQueue.length == 2) {
            createBatchAndSendToRegulator(productQueue);
            delete productQueue;
        }
    }
    
    function createBatchAndSendToRegulator(uint[] memory _productIds) public {
        uint batchId = createBatch(_productIds);
        // Function calls should be reordered according to the model
			
        checkcrop_farmer_to_approvecrop_farmer();
        approvecrop_farmer_to_sendcrop_farmer();
        cropsent_to_receiveproof();
        receiveproof_to_state_0_2_4();
        receivefeedback_to_state_0_3_3();
        sendcrop_farmer_to_state_0_5();
        emailconfirmation_to_state_0_4_4();
        receivereceipt_to_emailconfirmation();
        farmerinitialization_to_checkcrop_farmer();
        sendBatchToRegulator(batchId);
    }
    
        
    function checkcrop_farmer_to_approvecrop_farmer() public {
        //require(currentState == States.CHECKCROP_FARMER, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        evaluateCrop=false;
        if(evaluateCrop != false){
			emit EvaluateCropChanged(evaluateCrop);
		}

        
        currentState = States.APPROVECROP_FARMER;
        emit StateChanged(States.CHECKCROP_FARMER, States.APPROVECROP_FARMER);
    }
    
    function approvecrop_farmer_to_sendcrop_farmer() public {
        //require(currentState == States.APPROVECROP_FARMER, "Invalid current state for this transition.");
        require(feedbackReceived, "Guard condition failed.");
        
        
        
        currentState = States.SENDCROP_FARMER;
        emit StateChanged(States.APPROVECROP_FARMER, States.SENDCROP_FARMER);
    }
    
    function cropsent_to_receiveproof() public {
        //require(currentState == States.CROPSENT, "Invalid current state for this transition.");
        require(cropHarvested, "Guard condition failed.");
        //sendProductToRegulator();
        
        
        currentState = States.RECEIVEPROOF;
        emit StateChanged(States.CROPSENT, States.RECEIVEPROOF);
    }
    
    function receiveproof_to_state_0_2_4() public {
        //require(currentState == States.RECEIVEPROOF, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        
        
        
        currentState = States.STATE_0_2_4;
        emit StateChanged(States.RECEIVEPROOF, States.STATE_0_2_4);
    }
    
    function receivefeedback_to_state_0_3_3() public {
        //require(currentState == States.RECEIVEFEEDBACK, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        feedbackReceived=true;
        if(feedbackReceived != false){
			emit FeedbackReceivedChanged(feedbackReceived);
		}

        
        currentState = States.STATE_0_3_3;
        emit StateChanged(States.RECEIVEFEEDBACK, States.STATE_0_3_3);
    }
    
    function sendcrop_farmer_to_state_0_5() public {
        //require(currentState == States.SENDCROP_FARMER, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        
        
        
        currentState = States.STATE_0_5;
        emit StateChanged(States.SENDCROP_FARMER, States.STATE_0_5);
    }
    
    function emailconfirmation_to_state_0_4_4() public {
        //require(currentState == States.EMAILCONFIRMATION, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        //sendProductToProcessor();
        
        
        currentState = States.STATE_0_4_4;
        emit StateChanged(States.EMAILCONFIRMATION, States.STATE_0_4_4);
    }
    
    function receivereceipt_to_emailconfirmation() public {
        //require(currentState == States.RECEIVERECEIPT, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        receiptReceived=true;
        if(receiptReceived != false){
			emit ReceiptReceivedChanged(receiptReceived);
		}

        
        currentState = States.EMAILCONFIRMATION;
        emit StateChanged(States.RECEIVERECEIPT, States.EMAILCONFIRMATION);
    }
    
    function farmerinitialization_to_checkcrop_farmer() public {
        //require(currentState == States.FARMERINITIALIZATION, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        cropHarvested=true;
        if(cropHarvested != false){
			emit CropHarvestedChanged(cropHarvested);
		}

        
        currentState = States.CHECKCROP_FARMER;
        emit StateChanged(States.FARMERINITIALIZATION, States.CHECKCROP_FARMER);
    }
    
        
    // Separate Guard and Action Functions Implementation
    function sendBatchToRegulator(uint _batchId) private {
        batchToRegulator[_batchId] = true;
        uint256[] memory batchIds = new uint256[](1);
        batchIds[0] = _batchId;
        emit BatchSent(batchIds, BatchOwner.Farmer, BatchOwner.Regulator);
        updateBatchOwner(_batchId, BatchOwner.Processor);
        regulatorContract.receiveBatchFromFarmer(_batchId);
        
    }
    
    function sendBatchToProcessor(uint _batchId) private {
        batchToProcessor[_batchId] = true;
        uint256[] memory batchIds = new uint256[](1);
        batchIds[0] = _batchId;
        emit BatchSent(batchIds, BatchOwner.Farmer, BatchOwner.Processor);
        updateBatchOwner(_batchId, BatchOwner.Processor);
        processorContract.receiveBatchFromFarmer(_batchId);
        currentState = States.FARMERINITIALIZATION;
    }
    
        
    // Event Functions
    function receiveBatchFromRegulator(uint _batchId) public {
        batchReceivedFromRegulator[_batchId] = true;
        sendBatchToProcessor(_batchId);
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
        require(msg.sender == farmerWallet, "Only the farmer can withdraw funds");
        require(address(this).balance > 0, "No remaining balance to withdraw");

        (bool success, ) = farmerWallet.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }
    
}