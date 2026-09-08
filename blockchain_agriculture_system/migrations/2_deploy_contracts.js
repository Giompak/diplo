const Farmer = artifacts.require("Farmer");
const Processor = artifacts.require("Processor");
const Distributor = artifacts.require("Distributor");
const Retailer = artifacts.require("Retailer");
const Regulator = artifacts.require("Regulator");
const Customer = artifacts.require("Customer");
const SupplyChain = artifacts.require("SupplyChain");

module.exports = async function(deployer, network, accounts) {
  // Deploy Farmer contract
  await deployer.deploy(Farmer);
  const farmer = await Farmer.deployed();

  // Deploy Processor contract
  await deployer.deploy(Processor);
  const processor = await Processor.deployed();

  // Deploy Distributor contract
  await deployer.deploy(Distributor);
  const distributor = await Distributor.deployed();

  // Deploy Retailer contract
  await deployer.deploy(Retailer);
  const retailer = await Retailer.deployed();

  // Deploy Regulator contract
  await deployer.deploy(Regulator);
  const regulator = await Regulator.deployed();

  // Deploy Customer contract
  await deployer.deploy(Customer);
  const customer = await Customer.deployed();

  await deployer.deploy(SupplyChain);
  const supplychain = await SupplyChain.deployed();

  // Log addresses for verification
  console.log("Deployed Addresses:");
  console.log("Farmer:", farmer.address);
  console.log("Processor:", processor.address);
  console.log("Distributor:", distributor.address);
  console.log("Retailer:", retailer.address);
  console.log("Regulator:", regulator.address);
  console.log("Customer:", customer.address);
  console.log("SupplyChain:", supplychain.address);

  // Additional setup if necessary, e.g., initializing contracts
};