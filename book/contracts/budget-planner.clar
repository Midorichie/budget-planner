;; Budget Planner Smart Contract
;; Developed for Stacks Blockchain

;; Define a trait for the contract
(define-trait budget-planner-trait
  (
    (get-spending-summary (uint) (response {
      total-budget: uint,
      available-budget: uint,
      spent-amount: uint,
      category-allocations: (list 10 {
        category: (string-ascii 20),
        allocated: uint,
        spent: uint
      })
    } uint))
  )
)

;; Define a data structure for a user's budget
(define-map user-budgets
  {user-id: uint}  ;; User ID as the key
  {total-budget: uint,        ;; Total budget amount
   available-budget: uint,    ;; Available budget amount
   spent-amount: uint,        ;; Spent amount
   category-allocations: (list 10 {
     category: (string-ascii 20),  ;; Category name
     allocated: uint,              ;; Allocated amount
     spent: uint                   ;; Spent amount
   })}
)

;; Define a data structure for budget alerts
(define-map budget-alerts
  {user-id: uint, alert-id: uint}
  {threshold: uint,        ;; Threshold percentage
   category: (string-ascii 20),  ;; Category
   is-active: bool}        ;; Is the alert active?
)

;; Define a counter for alert IDs
(define-data-var next-alert-id uint u1)

;; Define user ID counter
(define-data-var next-user-id uint u1)

;; Principal map to track user IDs
(define-map principal-to-user-id 
  {owner: principal} 
  {user-id: uint}
)

;; Define permissions for users
(define-map user-permissions
  {user-id: uint, app-id: principal}
  {can-read: bool,
   can-write: bool,
   can-admin: bool}
)

;; Contract owner
(define-constant owner tx-sender)

;; Function to get user ID from principal
(define-read-only (get-user-id (user principal))
  (default-to u0 (get user-id (map-get? principal-to-user-id {owner: user}))))

;; Check if user has permission
(define-read-only (has-permission (user-id uint) (permission-type (string-ascii 10)))
  (let ((caller-principal tx-sender))
    (if (is-eq caller-principal owner)
      true  ;; Contract owner has all permissions
      (let ((user-permission (map-get? user-permissions {user-id: user-id, app-id: caller-principal})))
        (if (is-some user-permission)
          (if (is-eq permission-type "read")
            (get can-read (unwrap-panic user-permission))
            (if (is-eq permission-type "write")
              (get can-write (unwrap-panic user-permission))
              (if (is-eq permission-type "admin")
                (get can-admin (unwrap-panic user-permission))
                false)))
          false)))))

;; Functions to manage the budget

;; Initialize a user's budget
(define-public (initialize-budget (user-id uint) (initial-budget uint))
  (begin
    (map-set user-budgets 
             {user-id: user-id}
             {total-budget: initial-budget,
              available-budget: initial-budget,
              spent-amount: u0,
              category-allocations: (list)})
    (ok true)))

;; Add a spending category allocation
(define-public (add-category-allocation (user-id uint) (category-name (string-ascii 20)) (allocation-amount uint))
  (let ((current-budget (unwrap-panic (map-get? user-budgets {user-id: user-id})))
        (new-allocation {category: category-name, allocated: allocation-amount, spent: u0}))
    (begin
      (map-set user-budgets
             {user-id: user-id}
             {total-budget: (get total-budget current-budget),
              available-budget: (get available-budget current-budget),
              spent-amount: (get spent-amount current-budget),
              category-allocations: (unwrap-panic (as-max-len? 
                                      (concat (get category-allocations current-budget) 
                                              (list new-allocation))
                                      u10))})
      (ok true))))

;; Add a budget alert
(define-public (add-budget-alert (user-id uint) (category (string-ascii 20)) (threshold uint))
  (let ((alert-id (var-get next-alert-id)))
    (begin
      (map-set budget-alerts 
               {user-id: user-id, alert-id: alert-id}
               {threshold: threshold,
                category: category,
                is-active: true})
      (var-set next-alert-id (+ alert-id u1))
      (ok alert-id))))

;; Record a spending
(define-public (record-spending (user-id uint) (category (string-ascii 20)) (amount uint))
  (let ((current-budget (unwrap-panic (map-get? user-budgets {user-id: user-id}))))
    (begin
      (map-set user-budgets
             {user-id: user-id}
             {total-budget: (get total-budget current-budget),
              available-budget: (- (get available-budget current-budget) amount),
              spent-amount: (+ amount (get spent-amount current-budget)),
              category-allocations: (update-category-allocations 
                                      (get category-allocations current-budget) 
                                      category 
                                      amount)})
      (ok true))))

;; Helper function to update a category's spending - we'll use a more direct approach
(define-private (update-category-allocations 
                (allocations (list 10 {category: (string-ascii 20), allocated: uint, spent: uint}))
                (target-category (string-ascii 20))
                (amount uint))
  ;; We'll implement this without map by building a new list manually
  ;; For simplicity and given the restrictions in Clarity, we'll rebuild using a fixed approach
  (filter is-valid-allocation
    (list
      (update-allocation-if-matches (default-to {category: "", allocated: u0, spent: u0} (element-at allocations u0)) target-category amount)
      (update-allocation-if-matches (default-to {category: "", allocated: u0, spent: u0} (element-at allocations u1)) target-category amount)
      (update-allocation-if-matches (default-to {category: "", allocated: u0, spent: u0} (element-at allocations u2)) target-category amount)
      (update-allocation-if-matches (default-to {category: "", allocated: u0, spent: u0} (element-at allocations u3)) target-category amount)
      (update-allocation-if-matches (default-to {category: "", allocated: u0, spent: u0} (element-at allocations u4)) target-category amount)
      (update-allocation-if-matches (default-to {category: "", allocated: u0, spent: u0} (element-at allocations u5)) target-category amount)
      (update-allocation-if-matches (default-to {category: "", allocated: u0, spent: u0} (element-at allocations u6)) target-category amount)
      (update-allocation-if-matches (default-to {category: "", allocated: u0, spent: u0} (element-at allocations u7)) target-category amount)
      (update-allocation-if-matches (default-to {category: "", allocated: u0, spent: u0} (element-at allocations u8)) target-category amount)
      (update-allocation-if-matches (default-to {category: "", allocated: u0, spent: u0} (element-at allocations u9)) target-category amount)
    )
  )
)

;; Helper to update a single allocation if it matches
(define-private (update-allocation-if-matches 
                (allocation {category: (string-ascii 20), allocated: uint, spent: uint})
                (target-category (string-ascii 20))
                (amount uint))
  (if (is-eq (get category allocation) target-category)
      (merge allocation {spent: (+ (get spent allocation) amount)})
      allocation))

;; Helper to filter out empty allocations
(define-private (is-valid-allocation 
                (allocation {category: (string-ascii 20), allocated: uint, spent: uint}))
  (not (is-eq (get category allocation) "")))

;; Get a user's spending summary
(define-read-only (get-spending-summary (user-id uint))
  (ok (unwrap-panic (map-get? user-budgets {user-id: user-id}))))

;; Check if a user is over budget
(define-public (check-budget (user-id uint))
  (let ((current-budget (unwrap-panic (map-get? user-budgets {user-id: user-id}))))
    (if (> (get spent-amount current-budget) (get total-budget current-budget))
      (ok true)  ;; Over budget
      (ok false) ;; Not over budget
    )))

;; Set a new budget
(define-public (set-new-budget (user-id uint) (new-budget uint))
  (let ((current-budget (unwrap-panic (map-get? user-budgets {user-id: user-id}))))
    (begin
      (map-set user-budgets 
             {user-id: user-id}
             {total-budget: new-budget,
              available-budget: (get available-budget current-budget),
              spent-amount: (get spent-amount current-budget),
              category-allocations: (get category-allocations current-budget)})
      (ok true))))

;; Add money to the budget
(define-public (fund-budget (user-id uint) (amount uint))
  (let ((current-budget (unwrap-panic (map-get? user-budgets {user-id: user-id}))))
    (begin
      (map-set user-budgets
             {user-id: user-id}
             {total-budget: (get total-budget current-budget),
              available-budget: (+ amount (get available-budget current-budget)),
              spent-amount: (get spent-amount current-budget),
              category-allocations: (get category-allocations current-budget)})
      (ok true))))

;; Check how much money is left in a category
(define-read-only (get-remaining-budget (user-id uint))
  (let ((current-budget (unwrap-panic (map-get? user-budgets {user-id: user-id}))))
    (- (get total-budget current-budget)
       (get spent-amount current-budget))))
