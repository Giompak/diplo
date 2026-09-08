import os

class master_contract_generator:
    def __init__(self, name: str, stakeholders: list, payments: dict):
        self.name = name
        self.solidity_code = ''
        self.stakeholders = stakeholders
        self.payments = payments

    def generate_master_contract(self):
        # Stakeholders - Smart Contracts
        states = "enum AgricultureSystemStates{"
        # Join the stakeholders with commas
        states += ", ".join([stakeholder.upper() for stakeholder in self.stakeholders])
        states += "}"

        # Stakeholders - Smart Contracts
        stakeholders_enum = "enum BatchOwner {\n\t\t"
        for i, stakeholder in enumerate(self.stakeholders[:-1]):
            stakeholders_enum += stakeholder + ",\n\t\t"

        stakeholders_enum += "Regulator\n\t}"
        
        # Payment initialization
        payments_initialization = "\n\t".join([f"uint payTo{key} = {value} ether;" for key, value in self.payments.items()])

        # Template for the master contract
        self.solidity_code = f"""// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

{states}

contract {self.name} {{
    struct Product {{
        uint id;
        string name;
        string description;
        uint batchId;
    }}

    struct Batch {{
        uint id;
        uint[] productIds;
        BatchOwner owner;
    }}

    {stakeholders_enum}

    uint public productCounter = 0;
    uint public batchCounter = 0;

    {payments_initialization}

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

    function createProduct(string memory _name, string memory _description) public returns (uint) {{
        productCounter++;
        products[productCounter] = Product(productCounter, _name, _description, (batchCounter + 1));
        emit ProductCreated(productCounter, _name, _description, (batchCounter + 1));
        return productCounter;
    }}

    function createBatch(uint[] memory _productIds) public returns (uint) {{
        batchCounter++;
        batches[batchCounter] = Batch(batchCounter, _productIds, BatchOwner.Farmer);
        emit BatchCreated(batchCounter, _productIds);
        return batchCounter;
    }}

    function updateBatchOwner(uint _batchId, BatchOwner _newOwner) public {{
        batches[_batchId].owner = _newOwner;
    }}

    function getProductDetails(uint _productId) public view returns (Product memory) {{
        return products[_productId];
    }}

    function getBatchDetails(uint _batchId) public view returns (Batch memory) {{
        return batches[_batchId];
    }}
}}
        """

    def create_file(self):
        # Create the folder if it doesn't already exist
        folder_path = "GeneratedContracts"
        if not os.path.exists(folder_path):
            os.makedirs(folder_path)

        file_path = os.path.join(folder_path, f"{self.name}.sol")

        # Write the template to the file
        with open(file_path, 'w') as file:
            file.write(self.solidity_code)

        print("-" * 100)
        print(f"Master contract created and saved successfully at file: {file_path}")
