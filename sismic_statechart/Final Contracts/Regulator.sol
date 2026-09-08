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
    event ProductCheckedChanged(bool value);
    event FeedbackSentChanged(bool value);
    event ProductReceivedChanged(bool value);
    event ProofSentChanged(bool value);
    
    bool private productChecked = false;
    bool private feedbackSent = false;
    bool private productReceived = false;
    bool private proofSent = false; 
    
    function initialize(address _farmerContractAddress, address _processorContractAddress, address _distributorContractAddress, address _retailerContractAddress, address _regulatorWallet) public {
        currentState = States.REGULATOR;
        
        farmerContract = Farmer(payable(_farmerContractAddress));
        processorContract = Processor(payable(_processorContractAddress));
        distributorContract = Distributor(payable(_distributorContractAddress));
        retailerContract = Retailer(payable(_retailerContractAddress));
        
        regulatorWallet = payable(_regulatorWallet);
    
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
        
        // Transfer Batch back to Stakeholder
        sendBatchToRetailer(_batchIds);
        emit BatchSent(_batchIds, BatchOwner.Regulator, BatchOwner.Retailer);
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
    
}