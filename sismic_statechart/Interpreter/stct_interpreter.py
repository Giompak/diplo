from sismic.model import OrthogonalState, BasicState, CompoundState, FinalState, DeepHistoryState, ShallowHistoryState # type: ignore
import amola as am
import os

class Statechart_Interpreter:
    """
    A class to interpret statecharts and generate corresponding Solidity smart contracts.

    Attributes:
        statechart (Statechart): The imported statechart from the AMOLA library.
        name (str): The name of the statechart.
        master (str): The name of the master contract.
        states (list): A list to store state information.
        transitions (list): A list to store transition information.
        solidity_code (str): The generated Solidity code.
        all_guards (set): A set to store all guards.
        all_actions (set): A set to store all actions.
        all_events (set): A set to store all events.
        guard_funcs (dict): A dictionary to map guard function names.
        action_funcs (dict): A dictionary to map action function names.
        event_funcs (dict): A dictionary to map event function names.
        all_functions (list): A list to store all function names.
        variables_to_initialize (set): A set to track variables to be initialized.
        master_variable_name (str): The formatted master variable name.
    """

    def __init__(self, path: str, name: str, master_name: str, supply_chain: list):
        """
        Initializes the stct_interpreter with the given parameters.

        Args:
            path (str): The path to the AMOLA file.
            name (str): The name of the statechart.
            master_name (str): The name of the master contract.
        """
        self.statechart = am.import_from_amola(path)
        self.name = name  
        self.master = master_name
        self.supply_chain_order = supply_chain
        self.stakeholder_position = ''
        if self.name in supply_chain:
            self.stakeholder_position = self.supply_chain_order.index(self.name)
        self.states = []
        self.transitions = [] 
        self.solidity_code = ''
        self.all_guards = set()
        self.all_actions = set()
        self.all_events = set()
        self.guard_funcs = {}
        self.action_funcs = {}
        self.event_funcs = {}
        self.all_functions = []
        self.variables_to_initialize = set()
        self.lower_name = self.name[0].lower() + self.name[1:]
        self.master_variable_name = self.master[0].lower() + self.master[1:] + "ContractAddress" if self.master else self.master

    def parse_statechart(self):
        """
        Parses the statechart to extract states and transitions.
        """
        for state_name, state_obj in self.statechart._states.items():
            state_type = self.get_state_type(state_obj)
            self.states.append({'name': state_name, 'type': state_type})

        for transition in self.statechart.transitions:
            self.transitions.append({
                'source': transition.source,
                'target': transition.target if transition.target else None,
                'event': transition.event,
                'guard': transition.guard,
                'action': transition.action,
            })
    def get_state_type(self, state):
        """
        Determines the type of a given state.

        Args:
            state (State): The state object.

        Returns:
            str: The type of the state.
        """
        if isinstance(state, BasicState):
            return 'BASIC'
        elif isinstance(state, CompoundState):
            return 'COMPOUND'
        elif isinstance(state, OrthogonalState):
            return 'ORTHOGONAL'
        elif isinstance(state, DeepHistoryState):
            return 'DEEP_HISTORY'
        elif isinstance(state, ShallowHistoryState):
            return 'SHALLOW_HISTORY'
        elif isinstance(state, FinalState):
            return 'FINAL'
        else:
            return 'UNKNOWN'

    def process_elements(self):
        """
        Processes transitions to extract guards, actions, and events.
        """
        for transition in self.transitions:
            self.store_element(transition['guard'], 'guard')
            self.store_element(transition['action'], 'action')
            self.store_element(transition['event'], 'event')

    def store_element(self, element, element_type):
        """
        Stores an element (guard, action, or event) in the appropriate set or dictionary.

        Args:
            element (str): The element to store.
            element_type (str): The type of the element ('guard', 'action', 'event').
        """
        if not element:
            return

        func_prefix = 'func_'
        funcs = {
            'guard': self.guard_funcs,
            'action': self.action_funcs,
            'event': self.event_funcs
        }
        all_elements = {
            'guard': self.all_guards,
            'action': self.all_actions,
            'event': self.all_events
        }

        if element.startswith(func_prefix):
            element_name = element[len(func_prefix):]
            if element_name not in funcs[element_type]:
                funcs[element_type][element_name] = element_name
                self.all_functions.append(element_name)
        else:
            var_name = element.split('==')[0].split('=')[0].strip() if element_type == 'guard' else element.split('=')[0].strip()
            self.variables_to_initialize.add(var_name)

        all_elements[element_type].add(element)

    def generate_solidity_code(self):
        """
        Generates Solidity code from the parsed statechart.

        Returns:
            str: The generated Solidity code.
        """
        self.process_elements()

        variables_initialization = self.initialize_variables()
        sol_events_declaration = self.declare_events()
        state_functions, function_calls = self.generate_state_functions()
        stakeholder_imports, stakeholder_references, stakeholder_init, stakeholder_addr, contract_variables, stakeholders_mappings, stakeholder_functions= self.process_stakeholders(function_calls)
        states_enum, initial_state = self.generate_state_enum()
        function_defs = self.generate_function_definitions()
        event_trigger_functions = self.generate_event_trigger_functions(function_calls)
        master_interaction = self.generate_master_interaction()
        regulator_variables = ''
        
        transactionEvents = ''
        if self.stakeholder_position == len(self.supply_chain_order) - 1:
            transactionEvents += f'event ProductBought(uint productId, address recipient);'
        elif self.stakeholder_position == len(self.supply_chain_order) - 2:
            transactionEvents += f'event ProductSold(uint batchId, uint productId, address recipient);'
            
        if(self.name == "Regulator"):
            default_state = initial_state
            regulator_variables = f'''
    event BatchApproved(uint id, address approvedBy, string stage);
       
    enum ApprovalStatus {{ NotApproved, ApprovedBy{self.name}}}\n'''
            
            variables_approval = ''      
            for stakeholder in self.supply_chain_order:
                variables_approval += f'''
        ApprovalStatus {stakeholder.lower()}Approval;'''
            regulator_variables += f'''
    struct BatchApproval {{
            {variables_approval}
    }}'''
        else:
            default_state = f'{initial_state}INITIALIZATION'
            
        solidity_template = f'''// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
        
import "./{self.master}.sol";
{stakeholder_imports}

contract {self.name} is {self.master} {{
    {stakeholder_references}
    {regulator_variables}
    address payable public {self.lower_name + "Wallet;"}
    {contract_variables}
    {stakeholders_mappings}
    
    enum States {{{states_enum}}}
    
    States private currentState;

    // Product Queue of Blockchain
    uint[] private productQueue;
    uint[] public inventoryQueue;
    uint[] public approvedQueue;
    
    // Events
    {transactionEvents}
    event StateChanged(States from, States to);
    {sol_events_declaration}
    
    {variables_initialization} 
    
    function initialize({stakeholder_addr}) public {{
        currentState = States.{default_state};
        {stakeholder_init}
        
        {self.lower_name}Wallet = payable(_{self.lower_name}Wallet);
    
    }}
        {stakeholder_functions}
        {state_functions}
        {function_defs}
        {event_trigger_functions}
        {master_interaction}
}}
        '''
        self.solidity_code = solidity_template.strip()
        return self.solidity_code

    def initialize_variables(self):
        """
        Generates Solidity code to initialize variables.

        Returns:
            str: The Solidity code for variable initialization.
        """
        return "\n    ".join(f"bool private {var} = false;" for var in self.variables_to_initialize)

    def declare_events(self):
        """
        Generates Solidity code to declare events.

        Returns:
            str: The Solidity code for event declarations.
        """
        return "\n    ".join(f"event {var[0].upper() + var[1:]}Changed(bool value);" for var in self.variables_to_initialize)

    def process_stakeholders(self, function_calls):
        """
        Processes stakeholders to generate imports, references, and initializations.

        Returns:
            tuple: The Solidity code for imports, references, and initializations.
        """
        stakeholders = []
        for func in self.all_functions:
            if func.startswith("sendProduct") or func.startswith("receiveProduct"):
                if func.startswith("sendProduct"):
                    stakeholder = func.split("(")[0].split("sendProductTo")[1]
                else:
                    stakeholder = func.split("(")[0].split("receiveProductFrom")[1]
                if stakeholder not in stakeholders:
                    stakeholders.append(stakeholder)

        stakeholder_imports = ''
        stakeholder_references = ''
        stakeholder_init = ''
        stakeholder_addr = ''
        contract_variables = ''
        stakeholders_mappings = ''
        if self.name == 'Regulator':
            stakeholders_mappings += f'mapping(uint => BatchApproval) public batchApprovals;\n'
        
        if (self.stakeholder_position != 0 and self.stakeholder_position != len(self.supply_chain_order) - 1):
            stakeholders_mappings += f'''
    mapping(uint => bool) public receivedBatch;'''
        elif (self.stakeholder_position == len(self.supply_chain_order) - 1):
            stakeholders_mappings += f'''
    mapping(uint => bool) public receivedBatches;
    mapping(address => uint[]) public boughtProducts;'''
        stakeholder_functions = ''
        if (self.stakeholder_position == 0):
            stakeholder_functions += f'''
    function createProduct{self.name}(string memory _name, string memory _description) public {{
        uint productId = createProduct(_name, _description);
        productQueue.push(productId);
        if (productQueue.length == 2) {{
            createBatchAndSendToRegulator(productQueue);
            delete productQueue;
        }}
    }}
    
    function createBatchAndSendToRegulator(uint[] memory _productIds) public {{
        uint batchId = createBatch(_productIds);
        {function_calls}
        sendBatchToRegulator(batchId);
    }}
    '''
        for stakeholder in stakeholders:
            stakeholder_lower_case = stakeholder[0].lower() + stakeholder[1:]
            stakeholder_imports += f'import "./{stakeholder}.sol";\n'
            stakeholder_references += f'''
    {stakeholder} public {stakeholder_lower_case}Contract;'''
            stakeholder_init += f'''
        {stakeholder_lower_case}Contract = {stakeholder}(payable(_{stakeholder_lower_case}ContractAddress));'''
            stakeholder_addr += f'address _{stakeholder_lower_case}ContractAddress, '
            contract_variables += f'''
    address payable public {stakeholder_lower_case}Wallet;'''
            stakeholders_mappings += f'''
    mapping(uint => bool) public batchTo{stakeholder};
    mapping(uint => bool) public batchReceivedFrom{stakeholder};'''
            
        stakeholder_addr += f'address _{self.lower_name}Wallet'    
        return stakeholder_imports, stakeholder_references, stakeholder_init, stakeholder_addr, contract_variables, stakeholders_mappings, stakeholder_functions

    def generate_state_enum(self):
        """
        Generates the Solidity enum for states.

        Returns:
            tuple: The Solidity code for the states enum and the initial state.
        """
        states_enum = ', '.join([
            ("STATE_" + state['name'] if state['name'][0].isdigit() else state['name']).replace('.', '_').upper()
            for state in self.states
        ])
        initial_state = ("STATE_" + self.states[0]['name'] if self.states[0]['name'][0].isdigit() else self.states[0]['name']).replace('.', '_').upper()
        return states_enum, initial_state

    def generate_state_functions(self):
        """
        Generates the Solidity functions for state transitions.

        Returns:
            str: The Solidity code for state transition functions.
        """
        function_calls = "// Function calls should be reordered according to the model\n\t\t\t"
        state_functions = ""
        eval_variable = ''
        for transition in self.transitions:
            guard_call = self.guard_funcs.get(transition['guard'][5:] if transition['guard'] and transition['guard'].startswith('func_') else transition['guard'], transition['guard']) if transition['guard'] else 'true'
            action_call = self.action_funcs.get(transition['action'][5:] if transition['action'] and transition['action'].startswith('func_') else transition['action'], transition['action']) if transition['action'] else ''

            if (guard_call.startswith("evaluate")):
                eval_variable += guard_call.split("=")[0]
                break
            elif (action_call.startswith("evaluate")):
                eval_variable += action_call.split("=")[0]
                break
            
        for transition in self.transitions:
            source_state_var = ("STATE_" + transition['source'] if transition['source'][0].isdigit() else transition['source']).replace('.', '_').upper()
            target_state_var = ("STATE_" + transition['target'] if transition['target'] and transition['target'][0].isdigit() else transition['target']).replace('.', '_').upper() if transition['target'] else source_state_var
          
            guard_call = self.guard_funcs.get(transition['guard'][5:] if transition['guard'] and transition['guard'].startswith('func_') else transition['guard'], transition['guard']) if transition['guard'] else 'true'
            action_call = self.action_funcs.get(transition['action'][5:] if transition['action'] and transition['action'].startswith('func_') else transition['action'], transition['action']) if transition['action'] else ''

            if transition['guard'] and transition['guard'].startswith('func'):
                if guard_call.split('(')[0].startswith('sendProductTo') or guard_call.split('(')[0].startswith('receiveProductFrom'):
                    guard_call = f'//{guard_call.split("(")[0]}()'
                else:
                    guard_call = f'{guard_call.split("(")[0]}()'
                
            if transition['action'] and transition['action'].startswith('func'):
                if action_call.split('(')[0].startswith('sendProductTo') or action_call.split('(')[0].startswith('receiveProductFrom'):
                    action_call = f'//{action_call.split("(")[0]}()'
                else:
                    action_call = f'{action_call.split("(")[0]}()'
                    
            action_statements = ""
            if action_call:
                for var in self.variables_to_initialize:
                    if f"{var}" in transition['action'].split("=")[0]:
                        action_statements += f"if({var} != false){{\n\t\t\temit {var[0].upper() + var[1:]}Changed({var});\n\t\t}}\n"
                action_call = f"{action_call};"
            else:
                action_call = ""

            additional_check = ''
            func_name = f"{source_state_var}_TO_{target_state_var}".lower()
            if func_name.startswith("checkproducts"):
                additional_check += f'{eval_variable}=true;'
            function_calls += f'''
        {func_name}();'''
            state_functions += f'''
    function {func_name}() public {{
        //require(currentState == States.{source_state_var}, "Invalid current state for this transition.");
        require({guard_call}, "Guard condition failed.");
        {action_call}
        {action_statements}
        {additional_check}
        currentState = States.{target_state_var};
        emit StateChanged(States.{source_state_var}, States.{target_state_var});
    }}
    '''
        return state_functions, function_calls

    def generate_function_definitions(self):
        """
        Generates the Solidity functions for guards and actions.

        Returns:
            str: The Solidity code for guard and action functions.
        """
        function_defs = '''
    // Separate Guard and Action Functions Implementation'''
        for func in self.guard_funcs.values():
            if "product" in func:
                function_defs += f'''
    function {func.split("(")[0]}() private pure returns (bool) {{
        // TODO: Implement guard logic
        return true;
    }}
    '''
            else:
                function_defs += f'''
    function {func} private pure returns (bool) {{
        // TODO: Implement guard logic
        return true;
    }}
    '''
        for func in self.action_funcs.values():
            func_name = func.split("(")[0]
            if func_name.startswith("sendProductTo"):
                stakeholder = func_name[len("sendProductTo"):]
                func_name = "sendBatchTo" + stakeholder
                state_assignment = ""
                if self.name == "Regulator":
                    state_assignment = "currentState = States.REGULATOR;"
                else:
                    if stakeholder != "Regulator":
                        state_assignment = f"currentState = States.{self.name.upper()}INITIALIZATION;"
                lower_stakeholder = stakeholder[0].lower() + stakeholder[1:]
                
                if self.stakeholder_position != len(self.supply_chain_order) - 1: # Not the last stakeholder
                    # Regulator Process
                    if self.name not in self.supply_chain_order:    
                        func_parameter = ''
                        parameter = ''
                        if stakeholder == self.supply_chain_order[0]:
                            func_parameter += f'uint _batchId'
                            parameter += f'_batchId'
                        else:
                            func_parameter += f'uint[] memory _batchIds'
                            parameter += f'_batchIds'
                        function_defs += f'''
    function {func_name}({func_parameter}) private {{
        {lower_stakeholder}Contract.receiveBatchFrom{self.name}({parameter});
    }}'''
                    else:  
                        if self.stakeholder_position == 0:
                            function_defs += f'''
    function {func_name}(uint _batchId) private {{
        batchTo{stakeholder}[_batchId] = true;
        uint256[] memory batchIds = new uint256[](1);
        batchIds[0] = _batchId;
        emit BatchSent(batchIds, BatchOwner.{self.name}, BatchOwner.{stakeholder});
        updateBatchOwner(_batchId, BatchOwner.{self.supply_chain_order[self.stakeholder_position + 1]});
        {lower_stakeholder}Contract.receiveBatchFrom{self.name}(_batchId);
        {state_assignment}
    }}
    '''
                        else:
                            if stakeholder == "Regulator":
                                function_defs += f'''
    function {func_name}() private {{
        for (uint i = 0; i < inventoryQueue.length; i++) {{
            batchToRegulator[inventoryQueue[i]] = true;
        }}
        regulatorContract.receiveBatchFrom{self.name}{{value: (payToRegulator)}}(inventoryQueue);
        emit BatchSent(inventoryQueue, BatchOwner.{self.name}, BatchOwner.Regulator);
        delete inventoryQueue;
    }}
    '''
                            else:
                                next_stakeholder = self.supply_chain_order[self.stakeholder_position + 1]
                                next_stakeholder_lower_case = next_stakeholder.lower()
                                function_defs += f'''
    function {func_name}() private {{
         for (uint i = 0; i < approvedQueue.length; i++) {{
            batchTo{next_stakeholder}[approvedQueue[i]] = true;
            updateBatchOwner(approvedQueue[i], BatchOwner.{next_stakeholder});
        }}
        {next_stakeholder_lower_case}Contract.receiveBatchFrom{self.name}(approvedQueue);
        emit BatchSent(approvedQueue, BatchOwner.{self.name}, BatchOwner.{next_stakeholder});
        delete approvedQueue;
    }}
    '''
            else:
                function_defs += f'''
    function {func_name}() private {{
        // TODO: Implement action logic
    }}
    '''
        return function_defs

    def generate_event_trigger_functions(self, function_calls):
        """
        Generates the Solidity functions for event triggers.

        Returns:
            str: The Solidity code for event trigger functions.
        """
        event_trigger_functions = '''
    // Event Functions'''
        for transition in self.transitions:
            source_state_var = ("STATE_" + transition['source'] if transition['source'][0].isdigit() else transition['source']).replace('.', '_').upper()
            target_state_var = ("STATE_" + transition['target'] if transition['target'] and transition['target'][0].isdigit() else transition['target']).replace('.', '_').upper() if transition['target'] else source_state_var        
            func_name = f"{source_state_var}_TO_{target_state_var}".lower()
            if transition['event'] and transition['event'][5:] in self.event_funcs:
                curr_func_name = self.event_funcs.get(transition['event'][5:])
                curr_func_name = curr_func_name.split("(")[0]
                if curr_func_name.startswith("receiveProductFrom"):
                    stakeholder = curr_func_name[len("receiveProductFrom"):]
                    # Regulator Process
                    if self.name == 'Regulator':
                        # First stakeholder case
                        if self.supply_chain_order[0] == stakeholder:
                             event_trigger_functions += f'''
    function receiveBatchFrom{stakeholder}(uint _batchId) public payable {{
        require(msg.value == payTo{self.name}, "Insufficient or excessive funds sent");
        (bool success, ) = address({self.name.lower()}Wallet).call{{value: payTo{self.name}}}(""); 
        require(success, "Transfer to {stakeholder.lower()} failed");
        batchReceivedFrom{stakeholder}[_batchId] = true;
        uint256[] memory batchIds = new uint256[](1);
        batchIds[0] = _batchId;
        // Function calls
        {function_calls}
        
        // Transfer Batch back to Stakeholder
        emit BatchSent(batchIds, BatchOwner.{self.name}, BatchOwner.{stakeholder});
        batchApprovals[_batchId].{stakeholder.lower()}Approval = ApprovalStatus.ApprovedBy{self.name};
        emit BatchReceived(_batchId);
        sendBatchTo{stakeholder}(_batchId);
    }}'''
                        # Other stakeholders
                        else:
                            event_trigger_functions += f'''
    function receiveBatchFrom{stakeholder}(uint[] memory _batchIds) public payable {{
        require(msg.value == payTo{self.name}, "Insufficient or excessive funds sent");
        (bool success, ) = address({self.name.lower()}Wallet).call{{value: payTo{self.name}}}("");
        require(success, "Transfer to {stakeholder.lower()} failed");
        for (uint i = 0; i < _batchIds.length; i++) {{
            batchReceivedFrom{stakeholder}[_batchIds[i]] = true;
            emit BatchReceived(_batchIds[i]);
            batchApprovals[_batchIds[i]].{stakeholder.lower()}Approval = ApprovalStatus.ApprovedBy{self.name};
            emit BatchApproved(_batchIds[i], msg.sender, "{stakeholder}");
        }}
        // Function calls
        {function_calls}
        
        // Transfer Batch back to Stakeholder
        sendBatchTo{stakeholder}(_batchIds);
        emit BatchSent(_batchIds, BatchOwner.{self.name}, BatchOwner.{stakeholder});
    }}'''
                    else:
                        # Regulator Functions
                        if stakeholder not in self.supply_chain_order:
                            # Farmer process
                            if self.stakeholder_position == 0:
                                event_trigger_functions += f'''
    function receiveBatchFrom{stakeholder}(uint _batchId) public {{
        batchReceivedFrom{stakeholder}[_batchId] = true;
        sendBatchTo{self.supply_chain_order[self.stakeholder_position + 1]}(_batchId);
        }}'''
                            else:
                                if self.stakeholder_position == len(self.supply_chain_order) - 2:
                                    event_trigger_functions += f'''
    function receiveBatchFrom{stakeholder}(uint[] memory _batchIds) public {{
        for (uint i = 0; i < _batchIds.length; i++) {{
            batchReceivedFrom{stakeholder}[_batchIds[i]] = true;
            approvedQueue.push(_batchIds[i]);
        }}
    }}
    '''  
                                else:  
                                    event_trigger_functions += f'''
    function receiveBatchFrom{stakeholder}(uint[] memory _batchIds) public {{
        for (uint i = 0; i < _batchIds.length; i++) {{
            batchReceivedFrom{stakeholder}[_batchIds[i]] = true;
            approvedQueue.push(_batchIds[i]);
        }}
        sendBatchTo{self.supply_chain_order[self.stakeholder_position + 1]}();
    }}
    '''  
                        # Rest stakeholders functions  
                        else:
                            if self.stakeholder_position == len(self.supply_chain_order) - 1:
                                previous_stakeholder = self.supply_chain_order[self.stakeholder_position - 1]
                                event_trigger_functions += f'''
    function buyProduct(uint _productId) public payable {{
        {function_calls}
        address payable {previous_stakeholder.lower()}Address = {previous_stakeholder.lower()}Contract.retailerWallet();
        (bool success, ) = {previous_stakeholder.lower()}Address.call{{value: payTo{previous_stakeholder}}}("");
        require(success, "Purchase of product failed");
        {previous_stakeholder.lower()}Contract.sellProduct(_productId, msg.sender);
        boughtProducts[msg.sender].push(_productId);
        emit ProductBought(_productId, address(this));
    }}
    '''                        
                            elif self.stakeholder_position == 1:
                                 event_trigger_functions += f'''
    function receiveBatchFrom{stakeholder}(uint _batchId) public {{
        require(address(this).balance >= payTo{stakeholder}, "Insufficient funds to send to Farmer");
        address payable {stakeholder.lower()}Address = {stakeholder.lower()}Contract.{stakeholder.lower()}Wallet();
        (bool success, ) = {stakeholder.lower()}Address.call{{value: payTo{stakeholder}}}("");
        require(success, "Transfer to {stakeholder} failed");
        receivedBatch[_batchId] = true;
        emit BatchReceived(_batchId);
        inventoryQueue.push(_batchId);
        if (inventoryQueue.length >= 2) {{
            {function_calls}
            sendBatchToRegulator();
        }}
    }}
    '''
                            else:
                                event_trigger_functions += f'''
    function receiveBatchFrom{stakeholder}(uint[] memory _batchIds) public {{
        require(address(this).balance >= payTo{stakeholder}, "Insufficient funds to send to {stakeholder}");
        address payable {stakeholder.lower()}Address = {stakeholder.lower()}Contract.{stakeholder.lower()}Wallet();
        (bool success, ) = {stakeholder.lower()}Address.call{{value: payTo{stakeholder}}}("");
        require(success, "Transfer to {stakeholder} failed");
        for (uint i = 0; i < _batchIds.length; i++) {{
            receivedBatch[_batchIds[i]] = true;
            emit BatchReceived(_batchIds[i]);
            inventoryQueue.push(_batchIds[i]);
            if (inventoryQueue.length >= 4) {{
                {function_calls}
                sendBatchToRegulator();
            }}
        }}
    }}
    '''
                else:
                    event_trigger_functions += f'''
    function {curr_func_name}() public {{
        if (currentState == States.{source_state_var}) {{
            {func_name}();
        }}
    }}
    ''' 
        # Incorporate sell Product to the second from the end stakeholder
        if self.stakeholder_position == len(self.supply_chain_order)-2:
            event_trigger_functions += f'''
    function sellProduct (uint _productId, address _{self.supply_chain_order[len(self.supply_chain_order)-1].lower()}) public {{
        Product memory product = getProductDetails(_productId);
        uint batchId = product.batchId;
        require(productSold[_productId]==false, "Product already sold");
        productSold[_productId]=true;
        emit ProductSold(batchId, _productId, _{self.supply_chain_order[len(self.supply_chain_order)-1].lower()});
    }}   
    '''
        return event_trigger_functions

    def generate_master_interaction(self):
        """
        Generates the Solidity functions for interacting with the master contract and the ethereum addresses.

        Returns:
            str: The Solidity code for master contract interaction.
        """
        return f'''
    // Get Contract balance
     function getContractBalance() public view returns (uint256) {{
        return address(this).balance;
    }}

    // Function to allow the contract to receive ether
    receive() external payable {{}}

    // Function to fund the contract for testing purposes
    function fundContract() public payable {{}}

    function etherWithdraw(address payable recipient) public {{
        (bool success, ) = recipient.call{{value: address(this).balance}}("");
        require(success, "Transfer failed");
    }}
    
    function transferRemainingToWallet() public {{
        require(msg.sender == {self.lower_name}Wallet, "Only the {self.lower_name} can withdraw funds");
        require(address(this).balance > 0, "No remaining balance to withdraw");

        (bool success, ) = {self.lower_name}Wallet.call{{value: address(this).balance}}("");
        require(success, "Transfer failed");
    }}
    '''
    
    def save_solidity_code_to_file(self):
        """
        Saves the generated Solidity code to a file.
        """
        solidity_code = self.generate_solidity_code()
        solidity_filename = f"{self.name}.sol"
        save_path = os.path.join('./GeneratedContracts', solidity_filename)
        with open(save_path, 'w') as file:
            file.write(solidity_code)
        print("-"*100)
        print(f"Solidity code for {self.name} has been saved successfully to {save_path}")
