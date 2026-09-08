const Farmer = artifacts.require("Farmer");
const Processor = artifacts.require("Processor");
const Distributor = artifacts.require("Distributor");
const Retailer = artifacts.require("Retailer");
const Regulator = artifacts.require("Regulator");
const Customer = artifacts.require("Customer");
const SupplyChain = artifacts.require("SupplyChain");

module.exports = async function(callback) {
  try {
    const { farmer, processor, distributor, retailer, regulator, customer } = await getContracts();
    const { farmerWallet, processorWallet, distributorWallet, retailerWallet, regulatorWallet, customerWallet } = await getWallets();
    
    await farmer.initialize(regulator.address, processor.address, farmerWallet);
    await processor.initialize(farmer.address, regulator.address, distributor.address, processorWallet);
    await distributor.initialize(processor.address, regulator.address, retailer.address, distributorWallet);
    await retailer.initialize(distributor.address, regulator.address, customer.address, retailerWallet);
    await regulator.initialize(farmer.address, processor.address, distributor.address, retailer.address, regulatorWallet);
    await customer.initialize(retailer.address, customerWallet);

    const initialBalance = await fetchBalance();
    var delayInMilliseconds = 2000;

    await transferInitialFunds();
  
    // Generate 16 products in 8 batches (2 products per batch)
    const totalBatches = 8;
    let productId = 1;
 
    for (let batch = 1; batch <= totalBatches; batch++) {
      const products = [
        { name: `Product ${productId}`, description: `Product ${productId} - Batch ${batch}`, id: productId },
        { name: `Product ${productId + 1}`, description: `Product ${productId + 1} - Batch ${batch}`, id: productId + 1 },
      ];
    
      // Create products for this batch
      await createProducts(farmer, products);
      
      // Log Farmer operations for every batch
      farmerLogs(batch);
    
      // Log Processor operations every 2 batches
      if (batch % 2 === 0) {
        processorLogs([batch - 1, batch]);
        setTimeout(function() {}, delayInMilliseconds); 
      }
    
      // Log Distributor operations every 4 batches
      if (batch % 4 === 0) {
        distributorLogs([batch - 3, batch - 2, batch - 1, batch]);
        setTimeout(function() {}, delayInMilliseconds);
      }
    
      // Log Retailer operations after 8 batches
      if (batch % 8 === 0) {
        retailerLogs([batch - 7, batch - 6, batch - 5, batch - 4, batch - 3, batch - 2, batch - 1, batch]);
        setTimeout(function() {}, delayInMilliseconds);
      }
    
      productId += 2; // Increment productId by 2
    }

     // Simulate product purchase by customer
    for (let i = 1; i <= totalBatches * 2; i++) {
      await customer.buyProduct(i, { value: web3.utils.toWei("0.6", "ether"), from: customerWallet });
      console.log(`Customer bought Product ${i} for 0.6 ether`);
    }

    // Transfer remaining funds back to the wallets
    await farmer.transferRemainingToWallet({ from: farmerWallet });
    await processor.transferRemainingToWallet({ from: processorWallet });
    await distributor.transferRemainingToWallet({ from: distributorWallet });
    await retailer.transferRemainingToWallet({ from: retailerWallet });
    await customer.transferRemainingToWallet({ from: customerWallet });

    const afterBalance = await fetchBalance();
    calculateProfit(initialBalance, afterBalance);

    console.log("Interaction complete");
    callback();
  } catch (error) {
    console.error(error);
    callback(error);
  }
};

async function getContracts() {
  const farmer = await Farmer.deployed();
  const processor = await Processor.deployed();
  const distributor = await Distributor.deployed();
  const retailer = await Retailer.deployed();
  const regulator = await Regulator.deployed();
  const customer = await Customer.deployed();
  const supplyChain = await SupplyChain.deployed();
  return { farmer, processor, distributor, retailer, regulator, customer, supplyChain };
}

async function getWallets() {
  const accounts = await web3.eth.getAccounts();
  return {
    farmerWallet: accounts[1],
    processorWallet: accounts[2],
    distributorWallet: accounts[3],
    retailerWallet: accounts[4],
    regulatorWallet: accounts[5],
    customerWallet: accounts[6]
  };
}

async function fetchBalance() {
  const { farmerWallet, processorWallet, distributorWallet, retailerWallet, regulatorWallet, customerWallet } = await getWallets();

  const balances = await Promise.all([
    web3.eth.getBalance(farmerWallet),
    web3.eth.getBalance(processorWallet),
    web3.eth.getBalance(distributorWallet),
    web3.eth.getBalance(retailerWallet),
    web3.eth.getBalance(regulatorWallet),
    web3.eth.getBalance(customerWallet)
  ]);
  console.log("-------------------------Balance-------------------------");
  console.log(`Farmer => ${farmerWallet} => ${web3.utils.fromWei(balances[0], 'ether')} Ether`);
  console.log(`Processor => ${processorWallet} => ${web3.utils.fromWei(balances[1], 'ether')} Ether`);
  console.log(`Distributor => ${distributorWallet} => ${web3.utils.fromWei(balances[2], 'ether')} Ether`);
  console.log(`Retailer => ${retailerWallet} => ${web3.utils.fromWei(balances[3], 'ether')} Ether`);
  console.log(`Regulator => ${regulatorWallet} => ${web3.utils.fromWei(balances[4], 'ether')} Ether`);
  console.log(`Customer => ${customerWallet} => ${web3.utils.fromWei(balances[5], 'ether')} Ether`);
  console.log("-----------------------------------------------------");
  return {
    farmerBalance: web3.utils.fromWei(balances[0], 'ether'),
    processorBalance: web3.utils.fromWei(balances[1], 'ether'),
    distributorBalance: web3.utils.fromWei(balances[2], 'ether'),
    retailerBalance: web3.utils.fromWei(balances[3], 'ether'),
    regulatorBalance: web3.utils.fromWei(balances[4], 'ether'),
    customerBalance: web3.utils.fromWei(balances[5], 'ether')
  }
}

async function transferInitialFunds() {
  const { farmerWallet, processorWallet, distributorWallet, retailerWallet, customerWallet } = await getWallets();
  const { farmer, processor, distributor, retailer, customer } = await getContracts();

  await web3.eth.sendTransaction({ from: farmerWallet, to: farmer.address, value: web3.utils.toWei("5", "ether") });
  await web3.eth.sendTransaction({ from: processorWallet, to: processor.address, value: web3.utils.toWei("10", "ether") });
  await web3.eth.sendTransaction({ from: distributorWallet, to: distributor.address, value: web3.utils.toWei("15", "ether") });
  await web3.eth.sendTransaction({ from: retailerWallet, to: retailer.address, value: web3.utils.toWei("20", "ether") });
  await web3.eth.sendTransaction({ from: customerWallet, to: customer.address, value: web3.utils.toWei("30", "ether") });
}


function farmerLogs(batchId) {
  console.log(`Batch created with ID: ${batchId}`);
  console.log(`Batch (${batchId}) sent to the Regulator`);
  console.log("Farmer paid 0.1 ether to the Regulator");
  console.log(`Regulator sent Batch (${batchId}) to the Farmer`);
  console.log(`Farmer sent Batch (${batchId}) to the Processor`);
  console.log("Processor paid 0.2 (0.1 per Product) ether to the Farmer");
  console.log("------------------------------------------------------")
}

function processorLogs(batchIds) {
  console.log(`Batches (${batchIds}) sent to the Regulator`);
  console.log("Processor paid 0.1 ether to the Regulator");
  console.log(`Regulator sent Batches (${batchIds}) to the Processor`);
  console.log(`Processor sent Batches (${batchIds}) to the Distributor`);
  console.log("Distributor paid 0.9 (0.45 x 2 Farmer Batches) ether to the Processor");
  console.log("------------------------------------------------------")
}

function distributorLogs(batchIds) {
  console.log(`Batches (${batchIds}) sent to the Regulator`);
  console.log("Distributor paid 0.1 ether to the Regulator");
  console.log(`Regulator sent Batches (${batchIds}) to the Distributor`);
  console.log(`Distributor sent Batches (${batchIds}) to the Retailer`);
  console.log("Retailer paid 2.8 (1.4 x 2 Processor Batches) ether to the Distributor");
  console.log("------------------------------------------------------")
}

function retailerLogs(batchIds) {
  console.log(`Batches (${batchIds}) sent to the Regulator`);
  console.log("Retailer paid 0.1 ether to the Regulator");
  console.log(`Regulator sent Batches (${batchIds}) to the Retailer`);
  console.log("------------------------------------------------------")
}

async function createProducts(farmer, products) {
  for (const { name, description, id } of products) {
    console.log(`Created product with ID: ${id}`);
    if ( id % 2 == 0){
      console.log("------------------------------------------------------")
      console.log("Batch Created! Processing the Batch...")
      console.log("------------------------------------------------------")
    }
    await farmer.createProductFarmer(name, description);
  }
}

function calculateProfit(initialBalance, finalBalance) {
  console.log("------------------------------------------------------")
  console.log("Farmer profit : ", (finalBalance.farmerBalance - initialBalance.farmerBalance).toFixed(2));
  console.log("Processor profit : ", (finalBalance.processorBalance - initialBalance.processorBalance).toFixed(2));
  console.log("Distributor profit : ", (finalBalance.distributorBalance - initialBalance.distributorBalance).toFixed(2));
  console.log("Retailer profit : ", (finalBalance.retailerBalance - initialBalance.retailerBalance).toFixed(2));
  console.log("Regulator profit : ", (finalBalance.regulatorBalance - initialBalance.regulatorBalance).toFixed(2));
  console.log("------------------------------------------------------")
}