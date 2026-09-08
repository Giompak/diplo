import os
'''
Import the Interpreter
'''
#from master_contract_generator import BlockchainGenerator
from Interpreter.master_contract_generator import master_contract_generator
from Interpreter.stct_interpreter import Statechart_Interpreter

def process_stct(path, name, master_name, stakeholders):
      curr_interpreter = Statechart_Interpreter(path, name, master_name, stakeholders)
      curr_interpreter.parse_statechart()
      curr_interpreter.generate_solidity_code()
      curr_interpreter.save_solidity_code_to_file()
      return curr_interpreter

'''
Import statecharts from stct files derived from AMOLA
NOTE: Switched import_from_amola validation to True because an unexpected error occured. Amola.py and amola.ecore at the same file. 
      Pyecore extension to be installed with pip
'''

# Create the super Smart Contract for the Supply Chain
stakeholders = ["Farmer", "Processor", "Distributor", "Retailer", 'Customer']
payments = {"Regulator": 0.1, "Farmer": 0.2, "Processor": 0.9, "Distributor": 2.8, "Retailer": 0.6}
supply_chain_master = master_contract_generator('SupplyChain', stakeholders, payments)
supply_chain_master.generate_master_contract()
supply_chain_master.create_file()

# Create the instances and generate the solidity code
farmer_interpreter = process_stct('./Statecharts/Farmer.stct', 'Farmer', supply_chain_master.name, stakeholders)
processor_interpreter = process_stct('./Statecharts/Processor.stct', 'Processor', supply_chain_master.name, stakeholders)
distributor_interpreter = process_stct('./Statecharts/Distributor.stct', 'Distributor', supply_chain_master.name, stakeholders)
retailer_interpreter = process_stct('./Statecharts/Retailer.stct', 'Retailer', supply_chain_master.name, stakeholders)
regulator_interpreter = process_stct('./Statecharts/Regulator.stct', 'Regulator', supply_chain_master.name, stakeholders)
customer_interpreter = process_stct('./Statecharts/Customer.stct', 'Customer', supply_chain_master.name, stakeholders)
print("-"*60)