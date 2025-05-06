import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.2/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Ensure that budget can be initialized",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        
        // Initialize a budget for user 1 with 10,000 units
        let block = chain.mineBlock([
            Tx.contractCall(
                'budget-planner',
                'initialize-budget',
                [types.uint(1), types.uint(10000)],
                deployer.address
            )
        ]);
        
        // Check that the transaction was successful
        assertEquals(block.receipts[0].result, '(ok true)');
    },
});

Clarinet.test({
    name: "Can add category allocation",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        
        // Initialize a budget first
        let block = chain.mineBlock([
            Tx.contractCall(
                'budget-planner',
                'initialize-budget',
                [types.uint(1), types.uint(10000)],
                deployer.address
            ),
            
            // Add a category allocation
            Tx.contractCall(
                'budget-planner',
                'add-category-allocation',
                [types.uint(1), types.ascii('groceries'), types.uint(3000)],
                deployer.address
            )
        ]);
        
        // Check that both transactions were successful
        assertEquals(block.receipts[0].result, '(ok true)');
        assertEquals(block.receipts[1].result, '(ok true)');
    },
});

Clarinet.test({
    name: "Can record spending",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        
        // Initialize a budget first
        let block = chain.mineBlock([
            Tx.contractCall(
                'budget-planner',
                'initialize-budget',
                [types.uint(1), types.uint(10000)],
                deployer.address
            ),
            
            // Add a category allocation
            Tx.contractCall(
                'budget-planner',
                'add-category-allocation',
                [types.uint(1), types.ascii('groceries'), types.uint(3000)],
                deployer.address
            ),
            
            // Record a spending
            Tx.contractCall(
                'budget-planner',
                'record-spending',
                [types.uint(1), types.ascii('groceries'), types.uint(500)],
                deployer.address
            )
        ]);
        
        // Check that all transactions were successful
        assertEquals(block.receipts[0].result, '(ok true)');
        assertEquals(block.receipts[1].result, '(ok true)');
        assertEquals(block.receipts[2].result, '(ok true)');
    },
});

Clarinet.test({
    name: "Can create and use budget alerts",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        
        // Initialize a budget first
        let block = chain.mineBlock([
            Tx.contractCall(
                'budget-planner',
                'initialize-budget',
                [types.uint(1), types.uint(10000)],
                deployer.address
            ),
            
            // Add a budget alert (at 80% threshold)
            Tx.contractCall(
                'budget-planner',
                'add-budget-alert',
                [types.uint(1), types.ascii('groceries'), types.uint(80)],
                deployer.address
            )
        ]);
        
        // Check that transactions were successful and alert ID was returned
        assertEquals(block.receipts[0].result, '(ok true)');
        assertEquals(block.receipts[1].result, '(ok u1)');
    },
});

Clarinet.test({
    name: "Can check budget status",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        
        // Initialize a budget first
        let block = chain.mineBlock([
            Tx.contractCall(
                'budget-planner',
                'initialize-budget',
                [types.uint(1), types.uint(1000)],
                deployer.address
            ),
            
            // Record a spending that is under budget
            Tx.contractCall(
                'budget-planner',
                'record-spending',
                [types.uint(1), types.ascii('general'), types.uint(500)],
                deployer.address
            ),
            
            // Check if over budget (should be false)
            Tx.contractCall(
                'budget-planner',
                'check-budget',
                [types.uint(1)],
                deployer.address
            ),
            
            // Record another spending that brings the total over budget
            Tx.contractCall(
                'budget-planner',
                'record-spending',
                [types.uint(1), types.ascii('general'), types.uint(600)],
                deployer.address
            ),
            
            // Check if over budget again (should be true)
            Tx.contractCall(
                'budget-planner',
                'check-budget',
                [types.uint(1)],
                deployer.address
            )
        ]);
        
        // Verify the results
        assertEquals(block.receipts[0].result, '(ok true)');
        assertEquals(block.receipts[1].result, '(ok true)');
        assertEquals(block.receipts[2].result, '(ok false)');  // Not over budget yet
        assertEquals(block.receipts[3].result, '(ok true)');
        assertEquals(block.receipts[4].result, '(ok true)');   // Now over budget
    },
});
