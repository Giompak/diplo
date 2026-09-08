// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
        
import "./SupplyChain.sol";
import "./Farmer.sol";
import "./Processor.sol";
import "./Distributor.sol";
import "./Retailer.sol";


contract Regulator is SupplyChain {
    
    Farmer public farmerContract;
    Processor public processorContract;
    Distributor public distributorContract;
    Retailer public retailerContract;
    
    event BatchApproved(uint id, address approvedBy, string stage);
       
    enum ApprovalStatus { NotApproved, ApprovedByRegulator}

    struct BatchApproval {
            
        ApprovalStatus farmerApproval;
        ApprovalStatus processorApproval;
        ApprovalStatus distributorApproval;
        ApprovalStatus retailerApproval;
        ApprovalStatus customerApproval;
    }
    address payable public regulatorWallet;
    
    address payable public farmerWallet;
    address payable public processorWallet;
    address payable public distributorWallet;
    address payable public retailerWallet;
    mapping(uint => BatchApproval) public batchApprovals;

    mapping(uint => bool) public receivedBatch;
    mapping(uint => bool) public batchToFarmer;
    mapping(uint => bool) public batchReceivedFromFarmer;
    mapping(uint => bool) public batchToProcessor;
    mapping(uint => bool) public batchReceivedFromProcessor;
    mapping(uint => bool) public batchToDistributor;
    mapping(uint => bool) public batchReceivedFromDistributor;
    mapping(uint => bool) public batchToRetailer;
    mapping(uint => bool) public batchReceivedFromRetailer;
    
    enum States {REGULATOR, STATE_0_3, _OPEN_GROUP_CHECKCROP_REGULATOR_SEQUENCE_APPROVECROP_REGULATOR_CLOSE_GROUP__PARALLEL__OPEN_GROUP_CHECKGOODS_REGULATOR_SEQUENCE_APPROVEGOODS_REGULATOR_CLOSE_GROUP__PARALLEL__OPEN_GROUP_CHECKSUPPLY_REGULATOR_SEQUENCE_APPROVESUPPLY_REGULATOR_CLOSE_GROUP__PARALLEL__OPEN_GROUP_CHECKPRODUCTS_REGULATOR_SEQUENCE_APPROVEPRODUCTS_REGULATOR_CLOSE_GROUP_, STATE_0_2_4, CHECKRETAILER, STATE_0_2_4_3, _OPEN_GROUP_CHECKPRODUCTS_REGULATOR_SEQUENCE_APPROVEPRODUCTS_REGULATOR_CLOSE_GROUP_, STATE_0_2_4_2_4, APPROVEPRODUCTS_REGULATOR, STATE_0_2_4_2_3_5, SENDFEEDBACKRETAILER, REGISTERNOTESRETAILER, PROCESSSTOCK, CHECKPRODUCTS_REGULATOR, STATE_0_2_4_2_2_4, SENDPROOFRETAILER, PRODUCTSRECEIVED, STATE_0_2_3, CHECKDISTRIBUTOR, STATE_0_2_3_3, _OPEN_GROUP_CHECKSUPPLY_REGULATOR_SEQUENCE_APPROVESUPPLY_REGULATOR_CLOSE_GROUP_, STATE_0_2_3_2_4, APPROVESUPPLY_REGULATOR, STATE_0_2_3_2_3_5, SENDFEEDBACKDISTRIBUTOR, REGISTERNOTESDISTRIBUTOR, PROCESSSUPPLY, CHECKSUPPLY_REGULATOR, STATE_0_2_3_2_2_4, SENDPROOFDISTRIBUTOR, SUPPLYRECEIVED, STATE_0_2_2, CHECKPROCESSOR, STATE_0_2_2_3, _OPEN_GROUP_CHECKGOODS_REGULATOR_SEQUENCE_APPROVEGOODS_REGULATOR_CLOSE_GROUP_, STATE_0_2_2_2_4, APPROVEGOODS_REGULATOR, STATE_0_2_2_2_3_5, SENDFEEDBACKPROCESSOR, REGISTERNOTESPROCESSOR, PROCESSGOODS, CHECKGOODS_REGULATOR, STATE_0_2_2_2_2_4, SENDPROOFPROCESSOR, GOODSRECEIVED, STATE_0_2_1, CHECKFARMER, STATE_0_2_1_3, _OPEN_GROUP_CHECKCROP_REGULATOR_SEQUENCE_APPROVECROP_REGULATOR_CLOSE_GROUP_, STATE_0_2_1_2_4, APPROVECROP_REGULATOR, STATE_0_2_1_2_3_5, SENDFEEDBACKFARMER, SENDNOTESFARMER, PROCESSCROP, CHECKCROP_REGULATOR, STATE_0_2_1_2_2_4, SENDPROOFFARMER, CROPRECEIVED}
    
    States private currentState;

    // Product Queue of Blockchain
    uint[] private productQueue;
    uint[] public inventoryQueue;
    uint[] public approvedQueue;
    
    // Events
    
    event StateChanged(States from, States to);
    event ProofSentChanged(bool value);
    event FeedbackSentChanged(bool value);
    event ProductReceivedChanged(bool value);
    event ProductCheckedChanged(bool value);
    
    bool private proofSent = false;
    bool private feedbackSent = false;
    bool private productReceived = false;
    bool private productChecked = false; 
    
    function initialize(address _farmerContractAddress, address _processorContractAddress, address _distributorContractAddress, address _retailerContractAddress, address _regulatorWallet) public {
        currentState = States.REGULATOR;
        
        farmerContract = Farmer(payable(_farmerContractAddress));
        processorContract = Processor(payable(_processorContractAddress));
        distributorContract = Distributor(payable(_distributorContractAddress));
        retailerContract = Retailer(payable(_retailerContractAddress));
        
        regulatorWallet = payable(_regulatorWallet);
    
    }
        
        
    function _open_group_checkcrop_regulator_sequence_approvecrop_regulator_close_group__parallel__open_group_checkgoods_regulator_sequence_approvegoods_regulator_close_group__parallel__open_group_checksupply_regulator_sequence_approvesupply_regulator_close_group__parallel__open_group_checkproducts_regulator_sequence_approveproducts_regulator_close_group__to_state_0_3() public {
        //require(currentState == States._OPEN_GROUP_CHECKCROP_REGULATOR_SEQUENCE_APPROVECROP_REGULATOR_CLOSE_GROUP__PARALLEL__OPEN_GROUP_CHECKGOODS_REGULATOR_SEQUENCE_APPROVEGOODS_REGULATOR_CLOSE_GROUP__PARALLEL__OPEN_GROUP_CHECKSUPPLY_REGULATOR_SEQUENCE_APPROVESUPPLY_REGULATOR_CLOSE_GROUP__PARALLEL__OPEN_GROUP_CHECKPRODUCTS_REGULATOR_SEQUENCE_APPROVEPRODUCTS_REGULATOR_CLOSE_GROUP_, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        
        
        
        currentState = States.STATE_0_3;
        emit StateChanged(States._OPEN_GROUP_CHECKCROP_REGULATOR_SEQUENCE_APPROVECROP_REGULATOR_CLOSE_GROUP__PARALLEL__OPEN_GROUP_CHECKGOODS_REGULATOR_SEQUENCE_APPROVEGOODS_REGULATOR_CLOSE_GROUP__PARALLEL__OPEN_GROUP_CHECKSUPPLY_REGULATOR_SEQUENCE_APPROVESUPPLY_REGULATOR_CLOSE_GROUP__PARALLEL__OPEN_GROUP_CHECKPRODUCTS_REGULATOR_SEQUENCE_APPROVEPRODUCTS_REGULATOR_CLOSE_GROUP_, States.STATE_0_3);
    }
    
    function checkfarmer_to__open_group_checkcrop_regulator_sequence_approvecrop_regulator_close_group_() public {
        //require(currentState == States.CHECKFARMER, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        productReceived=false;
        if(productReceived != false){
			emit ProductReceivedChanged(productReceived);
		}

        
        currentState = States._OPEN_GROUP_CHECKCROP_REGULATOR_SEQUENCE_APPROVECROP_REGULATOR_CLOSE_GROUP_;
        emit StateChanged(States.CHECKFARMER, States._OPEN_GROUP_CHECKCROP_REGULATOR_SEQUENCE_APPROVECROP_REGULATOR_CLOSE_GROUP_);
    }
    
    function _open_group_checkcrop_regulator_sequence_approvecrop_regulator_close_group__to_state_0_2_1_3() public {
        //require(currentState == States._OPEN_GROUP_CHECKCROP_REGULATOR_SEQUENCE_APPROVECROP_REGULATOR_CLOSE_GROUP_, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        
        
        
        currentState = States.STATE_0_2_1_3;
        emit StateChanged(States._OPEN_GROUP_CHECKCROP_REGULATOR_SEQUENCE_APPROVECROP_REGULATOR_CLOSE_GROUP_, States.STATE_0_2_1_3);
    }
    
    function checkprocessor_to__open_group_checkgoods_regulator_sequence_approvegoods_regulator_close_group_() public {
        //require(currentState == States.CHECKPROCESSOR, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        productReceived=false;
        if(productReceived != false){
			emit ProductReceivedChanged(productReceived);
		}

        
        currentState = States._OPEN_GROUP_CHECKGOODS_REGULATOR_SEQUENCE_APPROVEGOODS_REGULATOR_CLOSE_GROUP_;
        emit StateChanged(States.CHECKPROCESSOR, States._OPEN_GROUP_CHECKGOODS_REGULATOR_SEQUENCE_APPROVEGOODS_REGULATOR_CLOSE_GROUP_);
    }
    
    function _open_group_checkgoods_regulator_sequence_approvegoods_regulator_close_group__to_state_0_2_2_3() public {
        //require(currentState == States._OPEN_GROUP_CHECKGOODS_REGULATOR_SEQUENCE_APPROVEGOODS_REGULATOR_CLOSE_GROUP_, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        
        
        
        currentState = States.STATE_0_2_2_3;
        emit StateChanged(States._OPEN_GROUP_CHECKGOODS_REGULATOR_SEQUENCE_APPROVEGOODS_REGULATOR_CLOSE_GROUP_, States.STATE_0_2_2_3);
    }
    
    function checkdistributor_to__open_group_checksupply_regulator_sequence_approvesupply_regulator_close_group_() public {
        //require(currentState == States.CHECKDISTRIBUTOR, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        productReceived=false;
        if(productReceived != false){
			emit ProductReceivedChanged(productReceived);
		}

        
        currentState = States._OPEN_GROUP_CHECKSUPPLY_REGULATOR_SEQUENCE_APPROVESUPPLY_REGULATOR_CLOSE_GROUP_;
        emit StateChanged(States.CHECKDISTRIBUTOR, States._OPEN_GROUP_CHECKSUPPLY_REGULATOR_SEQUENCE_APPROVESUPPLY_REGULATOR_CLOSE_GROUP_);
    }
    
    function _open_group_checksupply_regulator_sequence_approvesupply_regulator_close_group__to_state_0_2_3_3() public {
        //require(currentState == States._OPEN_GROUP_CHECKSUPPLY_REGULATOR_SEQUENCE_APPROVESUPPLY_REGULATOR_CLOSE_GROUP_, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        
        
        
        currentState = States.STATE_0_2_3_3;
        emit StateChanged(States._OPEN_GROUP_CHECKSUPPLY_REGULATOR_SEQUENCE_APPROVESUPPLY_REGULATOR_CLOSE_GROUP_, States.STATE_0_2_3_3);
    }
    
    function checkretailer_to__open_group_checkproducts_regulator_sequence_approveproducts_regulator_close_group_() public {
        //require(currentState == States.CHECKRETAILER, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        productReceived=false;
        if(productReceived != false){
			emit ProductReceivedChanged(productReceived);
		}

        
        currentState = States._OPEN_GROUP_CHECKPRODUCTS_REGULATOR_SEQUENCE_APPROVEPRODUCTS_REGULATOR_CLOSE_GROUP_;
        emit StateChanged(States.CHECKRETAILER, States._OPEN_GROUP_CHECKPRODUCTS_REGULATOR_SEQUENCE_APPROVEPRODUCTS_REGULATOR_CLOSE_GROUP_);
    }
    
    function _open_group_checkproducts_regulator_sequence_approveproducts_regulator_close_group__to_state_0_2_4_3() public {
        //require(currentState == States._OPEN_GROUP_CHECKPRODUCTS_REGULATOR_SEQUENCE_APPROVEPRODUCTS_REGULATOR_CLOSE_GROUP_, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        
        
        
        currentState = States.STATE_0_2_4_3;
        emit StateChanged(States._OPEN_GROUP_CHECKPRODUCTS_REGULATOR_SEQUENCE_APPROVEPRODUCTS_REGULATOR_CLOSE_GROUP_, States.STATE_0_2_4_3);
    }
    
    function checkcrop_regulator_to_approvecrop_regulator() public {
        //require(currentState == States.CHECKCROP_REGULATOR, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        productChecked=false;
        if(productChecked != false){
			emit ProductCheckedChanged(productChecked);
		}

        
        currentState = States.APPROVECROP_REGULATOR;
        emit StateChanged(States.CHECKCROP_REGULATOR, States.APPROVECROP_REGULATOR);
    }
    
    function approvecrop_regulator_to_state_0_2_1_2_4() public {
        //require(currentState == States.APPROVECROP_REGULATOR, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        
        
        
        currentState = States.STATE_0_2_1_2_4;
        emit StateChanged(States.APPROVECROP_REGULATOR, States.STATE_0_2_1_2_4);
    }
    
    function cropreceived_to_sendprooffarmer() public {
        //require(currentState == States.CROPRECEIVED, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        productReceived=true;
        if(productReceived != false){
			emit ProductReceivedChanged(productReceived);
		}

        
        currentState = States.SENDPROOFFARMER;
        emit StateChanged(States.CROPRECEIVED, States.SENDPROOFFARMER);
    }
    
    function sendprooffarmer_to_state_0_2_1_2_2_4() public {
        //require(currentState == States.SENDPROOFFARMER, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        proofSent=true;
        if(proofSent != false){
			emit ProofSentChanged(proofSent);
		}

        
        currentState = States.STATE_0_2_1_2_2_4;
        emit StateChanged(States.SENDPROOFFARMER, States.STATE_0_2_1_2_2_4);
    }
    
    function processcrop_to_sendnotesfarmer() public {
        //require(currentState == States.PROCESSCROP, "Invalid current state for this transition.");
        require(evaluateCrop(), "Guard condition failed.");
        productChecked=true;
        if(productChecked != false){
			emit ProductCheckedChanged(productChecked);
		}

        
        currentState = States.SENDNOTESFARMER;
        emit StateChanged(States.PROCESSCROP, States.SENDNOTESFARMER);
    }
    
    function sendnotesfarmer_to_sendfeedbackfarmer() public {
        //require(currentState == States.SENDNOTESFARMER, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        feedbackSent=true;
        if(feedbackSent != false){
			emit FeedbackSentChanged(feedbackSent);
		}

        
        currentState = States.SENDFEEDBACKFARMER;
        emit StateChanged(States.SENDNOTESFARMER, States.SENDFEEDBACKFARMER);
    }
    
    function sendfeedbackfarmer_to_state_0_2_1_2_3_5() public {
        //require(currentState == States.SENDFEEDBACKFARMER, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        //sendProductToFarmer();
        
        
        currentState = States.STATE_0_2_1_2_3_5;
        emit StateChanged(States.SENDFEEDBACKFARMER, States.STATE_0_2_1_2_3_5);
    }
    
    function checkgoods_regulator_to_approvegoods_regulator() public {
        //require(currentState == States.CHECKGOODS_REGULATOR, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        productChecked=false;
        if(productChecked != false){
			emit ProductCheckedChanged(productChecked);
		}

        
        currentState = States.APPROVEGOODS_REGULATOR;
        emit StateChanged(States.CHECKGOODS_REGULATOR, States.APPROVEGOODS_REGULATOR);
    }
    
    function approvegoods_regulator_to_state_0_2_2_2_4() public {
        //require(currentState == States.APPROVEGOODS_REGULATOR, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        
        
        
        currentState = States.STATE_0_2_2_2_4;
        emit StateChanged(States.APPROVEGOODS_REGULATOR, States.STATE_0_2_2_2_4);
    }
    
    function goodsreceived_to_sendproofprocessor() public {
        //require(currentState == States.GOODSRECEIVED, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        productReceived=true;
        if(productReceived != false){
			emit ProductReceivedChanged(productReceived);
		}

        
        currentState = States.SENDPROOFPROCESSOR;
        emit StateChanged(States.GOODSRECEIVED, States.SENDPROOFPROCESSOR);
    }
    
    function sendproofprocessor_to_state_0_2_2_2_2_4() public {
        //require(currentState == States.SENDPROOFPROCESSOR, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        proofSent=true;
        if(proofSent != false){
			emit ProofSentChanged(proofSent);
		}

        
        currentState = States.STATE_0_2_2_2_2_4;
        emit StateChanged(States.SENDPROOFPROCESSOR, States.STATE_0_2_2_2_2_4);
    }
    
    function processgoods_to_registernotesprocessor() public {
        //require(currentState == States.PROCESSGOODS, "Invalid current state for this transition.");
        require(evaluateGoods(), "Guard condition failed.");
        productChecked=true;
        if(productChecked != false){
			emit ProductCheckedChanged(productChecked);
		}

        
        currentState = States.REGISTERNOTESPROCESSOR;
        emit StateChanged(States.PROCESSGOODS, States.REGISTERNOTESPROCESSOR);
    }
    
    function registernotesprocessor_to_sendfeedbackprocessor() public {
        //require(currentState == States.REGISTERNOTESPROCESSOR, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        feedbackSent=true;
        if(feedbackSent != false){
			emit FeedbackSentChanged(feedbackSent);
		}

        
        currentState = States.SENDFEEDBACKPROCESSOR;
        emit StateChanged(States.REGISTERNOTESPROCESSOR, States.SENDFEEDBACKPROCESSOR);
    }
    
    function sendfeedbackprocessor_to_state_0_2_2_2_3_5() public {
        //require(currentState == States.SENDFEEDBACKPROCESSOR, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        //sendProductToProcessor();
        
        
        currentState = States.STATE_0_2_2_2_3_5;
        emit StateChanged(States.SENDFEEDBACKPROCESSOR, States.STATE_0_2_2_2_3_5);
    }
    
    function checksupply_regulator_to_approvesupply_regulator() public {
        //require(currentState == States.CHECKSUPPLY_REGULATOR, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        productChecked=false;
        if(productChecked != false){
			emit ProductCheckedChanged(productChecked);
		}

        
        currentState = States.APPROVESUPPLY_REGULATOR;
        emit StateChanged(States.CHECKSUPPLY_REGULATOR, States.APPROVESUPPLY_REGULATOR);
    }
    
    function approvesupply_regulator_to_state_0_2_3_2_4() public {
        //require(currentState == States.APPROVESUPPLY_REGULATOR, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        
        
        
        currentState = States.STATE_0_2_3_2_4;
        emit StateChanged(States.APPROVESUPPLY_REGULATOR, States.STATE_0_2_3_2_4);
    }
    
    function supplyreceived_to_sendproofdistributor() public {
        //require(currentState == States.SUPPLYRECEIVED, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        productReceived=true;
        if(productReceived != false){
			emit ProductReceivedChanged(productReceived);
		}

        
        currentState = States.SENDPROOFDISTRIBUTOR;
        emit StateChanged(States.SUPPLYRECEIVED, States.SENDPROOFDISTRIBUTOR);
    }
    
    function sendproofdistributor_to_state_0_2_3_2_2_4() public {
        //require(currentState == States.SENDPROOFDISTRIBUTOR, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        proofSent=true;
        if(proofSent != false){
			emit ProofSentChanged(proofSent);
		}

        
        currentState = States.STATE_0_2_3_2_2_4;
        emit StateChanged(States.SENDPROOFDISTRIBUTOR, States.STATE_0_2_3_2_2_4);
    }
    
    function sendfeedbackdistributor_to_state_0_2_3_2_3_5() public {
        //require(currentState == States.SENDFEEDBACKDISTRIBUTOR, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        //sendProductToDistributor();
        
        
        currentState = States.STATE_0_2_3_2_3_5;
        emit StateChanged(States.SENDFEEDBACKDISTRIBUTOR, States.STATE_0_2_3_2_3_5);
    }
    
    function checkproducts_regulator_to_approveproducts_regulator() public {
        //require(currentState == States.CHECKPRODUCTS_REGULATOR, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        productChecked=false;
        if(productChecked != false){
			emit ProductCheckedChanged(productChecked);
		}

        evaluateCrop(product)=true;
        currentState = States.APPROVEPRODUCTS_REGULATOR;
        emit StateChanged(States.CHECKPRODUCTS_REGULATOR, States.APPROVEPRODUCTS_REGULATOR);
    }
    
    function approveproducts_regulator_to_state_0_2_4_2_4() public {
        //require(currentState == States.APPROVEPRODUCTS_REGULATOR, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        
        
        
        currentState = States.STATE_0_2_4_2_4;
        emit StateChanged(States.APPROVEPRODUCTS_REGULATOR, States.STATE_0_2_4_2_4);
    }
    
    function productsreceived_to_sendproofretailer() public {
        //require(currentState == States.PRODUCTSRECEIVED, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        productReceived=true;
        if(productReceived != false){
			emit ProductReceivedChanged(productReceived);
		}

        
        currentState = States.SENDPROOFRETAILER;
        emit StateChanged(States.PRODUCTSRECEIVED, States.SENDPROOFRETAILER);
    }
    
    function sendproofretailer_to_state_0_2_4_2_2_4() public {
        //require(currentState == States.SENDPROOFRETAILER, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        proofSent=true;
        if(proofSent != false){
			emit ProofSentChanged(proofSent);
		}

        
        currentState = States.STATE_0_2_4_2_2_4;
        emit StateChanged(States.SENDPROOFRETAILER, States.STATE_0_2_4_2_2_4);
    }
    
    function processstock_to_registernotesretailer() public {
        //require(currentState == States.PROCESSSTOCK, "Invalid current state for this transition.");
        require(evaluateStock(), "Guard condition failed.");
        productChecked=true;
        if(productChecked != false){
			emit ProductCheckedChanged(productChecked);
		}

        
        currentState = States.REGISTERNOTESRETAILER;
        emit StateChanged(States.PROCESSSTOCK, States.REGISTERNOTESRETAILER);
    }
    
    function registernotesretailer_to_sendfeedbackretailer() public {
        //require(currentState == States.REGISTERNOTESRETAILER, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        feedbackSent=true;
        if(feedbackSent != false){
			emit FeedbackSentChanged(feedbackSent);
		}

        
        currentState = States.SENDFEEDBACKRETAILER;
        emit StateChanged(States.REGISTERNOTESRETAILER, States.SENDFEEDBACKRETAILER);
    }
    
    function sendfeedbackretailer_to_state_0_2_4_2_3_5() public {
        //require(currentState == States.SENDFEEDBACKRETAILER, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        //sendProductToRetailer();
        
        
        currentState = States.STATE_0_2_4_2_3_5;
        emit StateChanged(States.SENDFEEDBACKRETAILER, States.STATE_0_2_4_2_3_5);
    }
    
    function processsupply_to_registernotesdistributor() public {
        //require(currentState == States.PROCESSSUPPLY, "Invalid current state for this transition.");
        require(evaluateSupply(), "Guard condition failed.");
        productChecked=true;
        if(productChecked != false){
			emit ProductCheckedChanged(productChecked);
		}

        
        currentState = States.REGISTERNOTESDISTRIBUTOR;
        emit StateChanged(States.PROCESSSUPPLY, States.REGISTERNOTESDISTRIBUTOR);
    }
    
    function registernotesdistributor_to_sendfeedbackdistributor() public {
        //require(currentState == States.REGISTERNOTESDISTRIBUTOR, "Invalid current state for this transition.");
        require(true, "Guard condition failed.");
        feedbackSent=true;
        if(feedbackSent != false){
			emit FeedbackSentChanged(feedbackSent);
		}

        
        currentState = States.SENDFEEDBACKDISTRIBUTOR;
        emit StateChanged(States.REGISTERNOTESDISTRIBUTOR, States.SENDFEEDBACKDISTRIBUTOR);
    }
    
        
    // Separate Guard and Action Functions Implementation
    function evaluateCrop() private pure returns (bool) {
        // TODO: Implement guard logic
        return true;
    }
    
    function evaluateGoods() private pure returns (bool) {
        // TODO: Implement guard logic
        return true;
    }
    
    function evaluateStock() private pure returns (bool) {
        // TODO: Implement guard logic
        return true;
    }
    
    function evaluateSupply() private pure returns (bool) {
        // TODO: Implement guard logic
        return true;
    }
    
    function sendBatchToFarmer(uint _batchId) private {
        farmerContract.receiveBatchFromRegulator(_batchId);
    }
    function sendBatchToProcessor(uint[] memory _batchIds) private {
        processorContract.receiveBatchFromRegulator(_batchIds);
    }
    function sendBatchToDistributor(uint[] memory _batchIds) private {
        distributorContract.receiveBatchFromRegulator(_batchIds);
    }
    function sendBatchToRetailer(uint[] memory _batchIds) private {
        retailerContract.receiveBatchFromRegulator(_batchIds);
    }
        
    // Event Functions
    function receiveBatchFromFarmer(uint _batchId) public payable {
        require(msg.value == payToRegulator, "Insufficient or excessive funds sent");
        (bool success, ) = address(regulatorWallet).call{value: payToRegulator}(""); 
        require(success, "Transfer to farmer failed");
        batchReceivedFromFarmer[_batchId] = true;
        uint256[] memory batchIds = new uint256[](1);
        batchIds[0] = _batchId;
        // Function calls
        // Function calls should be reordered according to the model
			
        _open_group_checkcrop_regulator_sequence_approvecrop_regulator_close_group__parallel__open_group_checkgoods_regulator_sequence_approvegoods_regulator_close_group__parallel__open_group_checksupply_regulator_sequence_approvesupply_regulator_close_group__parallel__open_group_checkproducts_regulator_sequence_approveproducts_regulator_close_group__to_state_0_3();
        checkfarmer_to__open_group_checkcrop_regulator_sequence_approvecrop_regulator_close_group_();
        _open_group_checkcrop_regulator_sequence_approvecrop_regulator_close_group__to_state_0_2_1_3();
        checkprocessor_to__open_group_checkgoods_regulator_sequence_approvegoods_regulator_close_group_();
        _open_group_checkgoods_regulator_sequence_approvegoods_regulator_close_group__to_state_0_2_2_3();
        checkdistributor_to__open_group_checksupply_regulator_sequence_approvesupply_regulator_close_group_();
        _open_group_checksupply_regulator_sequence_approvesupply_regulator_close_group__to_state_0_2_3_3();
        checkretailer_to__open_group_checkproducts_regulator_sequence_approveproducts_regulator_close_group_();
        _open_group_checkproducts_regulator_sequence_approveproducts_regulator_close_group__to_state_0_2_4_3();
        checkcrop_regulator_to_approvecrop_regulator();
        approvecrop_regulator_to_state_0_2_1_2_4();
        cropreceived_to_sendprooffarmer();
        sendprooffarmer_to_state_0_2_1_2_2_4();
        processcrop_to_sendnotesfarmer();
        sendnotesfarmer_to_sendfeedbackfarmer();
        sendfeedbackfarmer_to_state_0_2_1_2_3_5();
        checkgoods_regulator_to_approvegoods_regulator();
        approvegoods_regulator_to_state_0_2_2_2_4();
        goodsreceived_to_sendproofprocessor();
        sendproofprocessor_to_state_0_2_2_2_2_4();
        processgoods_to_registernotesprocessor();
        registernotesprocessor_to_sendfeedbackprocessor();
        sendfeedbackprocessor_to_state_0_2_2_2_3_5();
        checksupply_regulator_to_approvesupply_regulator();
        approvesupply_regulator_to_state_0_2_3_2_4();
        supplyreceived_to_sendproofdistributor();
        sendproofdistributor_to_state_0_2_3_2_2_4();
        sendfeedbackdistributor_to_state_0_2_3_2_3_5();
        checkproducts_regulator_to_approveproducts_regulator();
        approveproducts_regulator_to_state_0_2_4_2_4();
        productsreceived_to_sendproofretailer();
        sendproofretailer_to_state_0_2_4_2_2_4();
        processstock_to_registernotesretailer();
        registernotesretailer_to_sendfeedbackretailer();
        sendfeedbackretailer_to_state_0_2_4_2_3_5();
        processsupply_to_registernotesdistributor();
        registernotesdistributor_to_sendfeedbackdistributor();
        
        // Transfer Batch back to Stakeholder
        emit BatchSent(batchIds, BatchOwner.Regulator, BatchOwner.Farmer);
        batchApprovals[_batchId].farmerApproval = ApprovalStatus.ApprovedByRegulator;
        emit BatchReceived(_batchId);
        sendBatchToFarmer(_batchId);
    }
    function receiveBatchFromProcessor(uint[] memory _batchIds) public payable {
        require(msg.value == payToRegulator, "Insufficient or excessive funds sent");
        (bool success, ) = address(regulatorWallet).call{value: payToRegulator}("");
        require(success, "Transfer to processor failed");
        for (uint i = 0; i < _batchIds.length; i++) {
            batchReceivedFromProcessor[_batchIds[i]] = true;
            emit BatchReceived(_batchIds[i]);
            batchApprovals[_batchIds[i]].processorApproval = ApprovalStatus.ApprovedByRegulator;
            emit BatchApproved(_batchIds[i], msg.sender, "Processor");
        }
        // Function calls
        // Function calls should be reordered according to the model
			
        _open_group_checkcrop_regulator_sequence_approvecrop_regulator_close_group__parallel__open_group_checkgoods_regulator_sequence_approvegoods_regulator_close_group__parallel__open_group_checksupply_regulator_sequence_approvesupply_regulator_close_group__parallel__open_group_checkproducts_regulator_sequence_approveproducts_regulator_close_group__to_state_0_3();
        checkfarmer_to__open_group_checkcrop_regulator_sequence_approvecrop_regulator_close_group_();
        _open_group_checkcrop_regulator_sequence_approvecrop_regulator_close_group__to_state_0_2_1_3();
        checkprocessor_to__open_group_checkgoods_regulator_sequence_approvegoods_regulator_close_group_();
        _open_group_checkgoods_regulator_sequence_approvegoods_regulator_close_group__to_state_0_2_2_3();
        checkdistributor_to__open_group_checksupply_regulator_sequence_approvesupply_regulator_close_group_();
        _open_group_checksupply_regulator_sequence_approvesupply_regulator_close_group__to_state_0_2_3_3();
        checkretailer_to__open_group_checkproducts_regulator_sequence_approveproducts_regulator_close_group_();
        _open_group_checkproducts_regulator_sequence_approveproducts_regulator_close_group__to_state_0_2_4_3();
        checkcrop_regulator_to_approvecrop_regulator();
        approvecrop_regulator_to_state_0_2_1_2_4();
        cropreceived_to_sendprooffarmer();
        sendprooffarmer_to_state_0_2_1_2_2_4();
        processcrop_to_sendnotesfarmer();
        sendnotesfarmer_to_sendfeedbackfarmer();
        sendfeedbackfarmer_to_state_0_2_1_2_3_5();
        checkgoods_regulator_to_approvegoods_regulator();
        approvegoods_regulator_to_state_0_2_2_2_4();
        goodsreceived_to_sendproofprocessor();
        sendproofprocessor_to_state_0_2_2_2_2_4();
        processgoods_to_registernotesprocessor();
        registernotesprocessor_to_sendfeedbackprocessor();
        sendfeedbackprocessor_to_state_0_2_2_2_3_5();
        checksupply_regulator_to_approvesupply_regulator();
        approvesupply_regulator_to_state_0_2_3_2_4();
        supplyreceived_to_sendproofdistributor();
        sendproofdistributor_to_state_0_2_3_2_2_4();
        sendfeedbackdistributor_to_state_0_2_3_2_3_5();
        checkproducts_regulator_to_approveproducts_regulator();
        approveproducts_regulator_to_state_0_2_4_2_4();
        productsreceived_to_sendproofretailer();
        sendproofretailer_to_state_0_2_4_2_2_4();
        processstock_to_registernotesretailer();
        registernotesretailer_to_sendfeedbackretailer();
        sendfeedbackretailer_to_state_0_2_4_2_3_5();
        processsupply_to_registernotesdistributor();
        registernotesdistributor_to_sendfeedbackdistributor();
        
        // Transfer Batch back to Stakeholder
        sendBatchToProcessor(_batchIds);
        emit BatchSent(_batchIds, BatchOwner.Regulator, BatchOwner.Processor);
    }
    function receiveBatchFromDistributor(uint[] memory _batchIds) public payable {
        require(msg.value == payToRegulator, "Insufficient or excessive funds sent");
        (bool success, ) = address(regulatorWallet).call{value: payToRegulator}("");
        require(success, "Transfer to distributor failed");
        for (uint i = 0; i < _batchIds.length; i++) {
            batchReceivedFromDistributor[_batchIds[i]] = true;
            emit BatchReceived(_batchIds[i]);
            batchApprovals[_batchIds[i]].distributorApproval = ApprovalStatus.ApprovedByRegulator;
            emit BatchApproved(_batchIds[i], msg.sender, "Distributor");
        }
        // Function calls
        // Function calls should be reordered according to the model
			
        _open_group_checkcrop_regulator_sequence_approvecrop_regulator_close_group__parallel__open_group_checkgoods_regulator_sequence_approvegoods_regulator_close_group__parallel__open_group_checksupply_regulator_sequence_approvesupply_regulator_close_group__parallel__open_group_checkproducts_regulator_sequence_approveproducts_regulator_close_group__to_state_0_3();
        checkfarmer_to__open_group_checkcrop_regulator_sequence_approvecrop_regulator_close_group_();
        _open_group_checkcrop_regulator_sequence_approvecrop_regulator_close_group__to_state_0_2_1_3();
        checkprocessor_to__open_group_checkgoods_regulator_sequence_approvegoods_regulator_close_group_();
        _open_group_checkgoods_regulator_sequence_approvegoods_regulator_close_group__to_state_0_2_2_3();
        checkdistributor_to__open_group_checksupply_regulator_sequence_approvesupply_regulator_close_group_();
        _open_group_checksupply_regulator_sequence_approvesupply_regulator_close_group__to_state_0_2_3_3();
        checkretailer_to__open_group_checkproducts_regulator_sequence_approveproducts_regulator_close_group_();
        _open_group_checkproducts_regulator_sequence_approveproducts_regulator_close_group__to_state_0_2_4_3();
        checkcrop_regulator_to_approvecrop_regulator();
        approvecrop_regulator_to_state_0_2_1_2_4();
        cropreceived_to_sendprooffarmer();
        sendprooffarmer_to_state_0_2_1_2_2_4();
        processcrop_to_sendnotesfarmer();
        sendnotesfarmer_to_sendfeedbackfarmer();
        sendfeedbackfarmer_to_state_0_2_1_2_3_5();
        checkgoods_regulator_to_approvegoods_regulator();
        approvegoods_regulator_to_state_0_2_2_2_4();
        goodsreceived_to_sendproofprocessor();
        sendproofprocessor_to_state_0_2_2_2_2_4();
        processgoods_to_registernotesprocessor();
        registernotesprocessor_to_sendfeedbackprocessor();
        sendfeedbackprocessor_to_state_0_2_2_2_3_5();
        checksupply_regulator_to_approvesupply_regulator();
        approvesupply_regulator_to_state_0_2_3_2_4();
        supplyreceived_to_sendproofdistributor();
        sendproofdistributor_to_state_0_2_3_2_2_4();
        sendfeedbackdistributor_to_state_0_2_3_2_3_5();
        checkproducts_regulator_to_approveproducts_regulator();
        approveproducts_regulator_to_state_0_2_4_2_4();
        productsreceived_to_sendproofretailer();
        sendproofretailer_to_state_0_2_4_2_2_4();
        processstock_to_registernotesretailer();
        registernotesretailer_to_sendfeedbackretailer();
        sendfeedbackretailer_to_state_0_2_4_2_3_5();
        processsupply_to_registernotesdistributor();
        registernotesdistributor_to_sendfeedbackdistributor();
        
        // Transfer Batch back to Stakeholder
        sendBatchToDistributor(_batchIds);
        emit BatchSent(_batchIds, BatchOwner.Regulator, BatchOwner.Distributor);
    }
    function receiveBatchFromRetailer(uint[] memory _batchIds) public payable {
        require(msg.value == payToRegulator, "Insufficient or excessive funds sent");
        (bool success, ) = address(regulatorWallet).call{value: payToRegulator}("");
        require(success, "Transfer to retailer failed");
        for (uint i = 0; i < _batchIds.length; i++) {
            batchReceivedFromRetailer[_batchIds[i]] = true;
            emit BatchReceived(_batchIds[i]);
            batchApprovals[_batchIds[i]].retailerApproval = ApprovalStatus.ApprovedByRegulator;
            emit BatchApproved(_batchIds[i], msg.sender, "Retailer");
        }
        // Function calls
        // Function calls should be reordered according to the model
			
        _open_group_checkcrop_regulator_sequence_approvecrop_regulator_close_group__parallel__open_group_checkgoods_regulator_sequence_approvegoods_regulator_close_group__parallel__open_group_checksupply_regulator_sequence_approvesupply_regulator_close_group__parallel__open_group_checkproducts_regulator_sequence_approveproducts_regulator_close_group__to_state_0_3();
        checkfarmer_to__open_group_checkcrop_regulator_sequence_approvecrop_regulator_close_group_();
        _open_group_checkcrop_regulator_sequence_approvecrop_regulator_close_group__to_state_0_2_1_3();
        checkprocessor_to__open_group_checkgoods_regulator_sequence_approvegoods_regulator_close_group_();
        _open_group_checkgoods_regulator_sequence_approvegoods_regulator_close_group__to_state_0_2_2_3();
        checkdistributor_to__open_group_checksupply_regulator_sequence_approvesupply_regulator_close_group_();
        _open_group_checksupply_regulator_sequence_approvesupply_regulator_close_group__to_state_0_2_3_3();
        checkretailer_to__open_group_checkproducts_regulator_sequence_approveproducts_regulator_close_group_();
        _open_group_checkproducts_regulator_sequence_approveproducts_regulator_close_group__to_state_0_2_4_3();
        checkcrop_regulator_to_approvecrop_regulator();
        approvecrop_regulator_to_state_0_2_1_2_4();
        cropreceived_to_sendprooffarmer();
        sendprooffarmer_to_state_0_2_1_2_2_4();
        processcrop_to_sendnotesfarmer();
        sendnotesfarmer_to_sendfeedbackfarmer();
        sendfeedbackfarmer_to_state_0_2_1_2_3_5();
        checkgoods_regulator_to_approvegoods_regulator();
        approvegoods_regulator_to_state_0_2_2_2_4();
        goodsreceived_to_sendproofprocessor();
        sendproofprocessor_to_state_0_2_2_2_2_4();
        processgoods_to_registernotesprocessor();
        registernotesprocessor_to_sendfeedbackprocessor();
        sendfeedbackprocessor_to_state_0_2_2_2_3_5();
        checksupply_regulator_to_approvesupply_regulator();
        approvesupply_regulator_to_state_0_2_3_2_4();
        supplyreceived_to_sendproofdistributor();
        sendproofdistributor_to_state_0_2_3_2_2_4();
        sendfeedbackdistributor_to_state_0_2_3_2_3_5();
        checkproducts_regulator_to_approveproducts_regulator();
        approveproducts_regulator_to_state_0_2_4_2_4();
        productsreceived_to_sendproofretailer();
        sendproofretailer_to_state_0_2_4_2_2_4();
        processstock_to_registernotesretailer();
        registernotesretailer_to_sendfeedbackretailer();
        sendfeedbackretailer_to_state_0_2_4_2_3_5();
        processsupply_to_registernotesdistributor();
        registernotesdistributor_to_sendfeedbackdistributor();
        
        // Transfer Batch back to Stakeholder
        sendBatchToRetailer(_batchIds);
        emit BatchSent(_batchIds, BatchOwner.Regulator, BatchOwner.Retailer);
    }
    function processCrop() public {
        if (currentState == States.CHECKCROP_REGULATOR) {
            checkcrop_regulator_to_approvecrop_regulator();
        }
    }
    
    function processGoods() public {
        if (currentState == States.CHECKGOODS_REGULATOR) {
            checkgoods_regulator_to_approvegoods_regulator();
        }
    }
    
    function processSupply() public {
        if (currentState == States.CHECKSUPPLY_REGULATOR) {
            checksupply_regulator_to_approvesupply_regulator();
        }
    }
    
    function processStock() public {
        if (currentState == States.CHECKPRODUCTS_REGULATOR) {
            checkproducts_regulator_to_approveproducts_regulator();
        }
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
        require(msg.sender == regulatorWallet, "Only the regulator can withdraw funds");
        require(address(this).balance > 0, "No remaining balance to withdraw");

        (bool success, ) = regulatorWallet.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }
    
}