// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

enum AgricultureSystemStates{FARMER, PROCESSOR, DISTRIBUTOR, RETAILER, CUSTOMER}

contract SupplyChain {
    struct Product {
        uint id;
        string name;
        string description;
        uint batchId;
    }

    struct Batch {
        uint id;
        uint[] productIds;
        BatchOwner owner;
    }

    enum BatchOwner {
		Farmer,
		Processor,
		Distributor,
		Retailer,
		Regulator
	}

    uint public productCounter = 0;
    uint public batchCounter = 0;

    uint payToRegulator = 0.1 ether;
	uint payToFarmer = 0.2 ether;
	uint payToProcessor = 0.9 ether;
	uint payToDistributor = 2.8 ether;
	uint payToRetailer = 0.6 ether;

    mapping(uint => Product) public products;
    mapping(uint => Batch) public batches;
    mapping(uint => bool) public productSold;

    event ProductCreated(uint id, string name, string description, uint batchId);
    event BatchCreated(uint id, uint[] productIds);
    event BatchSent(uint[] id, BatchOwner from, BatchOwner to);
    event BatchReceived(uint id);
    event ProductSent(uint batchId, uint productId, address recipient);
    event ProductReceived(uint batchId, uint productId);

    event BatchReadyForApproval(uint batchId, uint price);

    function createProduct(string memory _name, string memory _description) public returns (uint) {
        productCounter++;
        products[productCounter] = Product(productCounter, _name, _description, (batchCounter + 1));
        emit ProductCreated(productCounter, _name, _description, (batchCounter + 1));
        return productCounter;
    }

    function createBatch(uint[] memory _productIds) public returns (uint) {
        batchCounter++;
        batches[batchCounter] = Batch(batchCounter, _productIds, BatchOwner.Farmer);
        emit BatchCreated(batchCounter, _productIds);
        return batchCounter;
    }

    function updateBatchOwner(uint _batchId, BatchOwner _newOwner) public {
        batches[_batchId].owner = _newOwner;
    }

    function getProductDetails(uint _productId) public view returns (Product memory) {
        return products[_productId];
    }

    function getBatchDetails(uint _batchId) public view returns (Batch memory) {
        return batches[_batchId];
    }
}
        