;; Budget Analytics Smart Contract
;; Companion to Budget Planner
;; Developed for Stacks Blockchain

;; Import trait from budget-planner contract
;; Use the contract's deployed name when in production
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

;; Store historical spending data by month
(define-map monthly-spending
  {user-id: uint, year: uint, month: uint}
  {total-spent: uint,
   categories: (list 10 {
     category: (string-ascii 20),
     spent: uint
   })}
)

;; Store budget savings goals
(define-map savings-goals
  {user-id: uint, goal-id: uint}
  {name: (string-ascii 50),
   target-amount: uint,
   current-amount: uint,
   target-date: uint,  ;; Unix timestamp
   is-active: bool}
)

;; Store budget performance metrics
(define-map performance-metrics
  {user-id: uint, year: uint, month: uint}
  {budget-adherence: uint,  ;; Percentage adhered to budget (0-100)
   savings-rate: uint,      ;; Percentage of income saved
   on-track-categories: uint, ;; Number of categories on track
   over-budget-categories: uint} ;; Number of categories over budget
)

;; Next goal ID counter
(define-data-var next-goal-id uint u1)

;; Input validation functions
(define-private (is-valid-month (month uint))
  (and (>= month u1) (<= month u12)))

(define-private (is-valid-year (year uint))
  (and (>= year u2000) (<= year u2100)))

;; Record monthly spending summary with input validation
(define-public (record-monthly-summary 
                (user-id uint) 
                (year uint) 
                (month uint) 
                (total-spent uint)
                (category-spending (list 10 {category: (string-ascii 20), spent: uint})))
  (begin
    ;; Validate inputs
    (asserts! (> user-id u0) (err u1)) ;; User ID must be positive
    (asserts! (is-valid-year year) (err u2)) ;; Year must be in valid range
    (asserts! (is-valid-month month) (err u3)) ;; Month must be in valid range
    
    (map-set monthly-spending
             {user-id: user-id, year: year, month: month}
             {total-spent: total-spent,
              categories: category-spending})
    (ok true)))

;; Create a new savings goal with input validation
(define-public (create-savings-goal 
                (user-id uint) 
                (name (string-ascii 50)) 
                (target-amount uint)
                (target-date uint))
  (let ((goal-id (var-get next-goal-id)))
    (begin
      ;; Validate inputs
      (asserts! (> user-id u0) (err u4)) ;; User ID must be positive
      (asserts! (> target-amount u0) (err u5)) ;; Target amount must be positive
      ;; FIXED: Removed to-uint as block-height is already a uint
      (asserts! (> target-date block-height) (err u6)) ;; Target date must be in the future
      
      (map-set savings-goals
               {user-id: user-id, goal-id: goal-id}
               {name: name,
                target-amount: target-amount,
                current-amount: u0,
                target-date: target-date,
                is-active: true})
      (var-set next-goal-id (+ goal-id u1))
      (ok goal-id))))

;; Update savings goal progress with input validation
(define-public (update-savings-progress (user-id uint) (goal-id uint) (new-amount uint))
  (begin
    ;; Validate inputs
    (asserts! (> user-id u0) (err u7)) ;; User ID must be positive
    (asserts! (is-some (map-get? savings-goals {user-id: user-id, goal-id: goal-id})) (err u8)) ;; Goal must exist
    
    (let ((current-goal (unwrap-panic (map-get? savings-goals {user-id: user-id, goal-id: goal-id}))))
      (map-set savings-goals
               {user-id: user-id, goal-id: goal-id}
               (merge current-goal {current-amount: new-amount}))
      (ok true))))

;; Check if savings goal is achieved
(define-read-only (is-goal-achieved (user-id uint) (goal-id uint))
  (match (map-get? savings-goals {user-id: user-id, goal-id: goal-id})
    goal (>= (get current-amount goal) (get target-amount goal))
    false)) ;; Return false if goal doesn't exist

;; Compute budget adherence percentage for a month with input validation
(define-public (compute-budget-adherence 
                (budget-contract <budget-planner-trait>)
                (user-id uint) 
                (year uint) 
                (month uint))
  (begin
    ;; Validate inputs
    (asserts! (> user-id u0) (err u9)) ;; User ID must be positive
    (asserts! (is-valid-year year) (err u10)) ;; Year must be in valid range
    (asserts! (is-valid-month month) (err u11)) ;; Month must be in valid range
    
    (let ((monthly-data (map-get? monthly-spending {user-id: user-id, year: year, month: month})))
      (asserts! (is-some monthly-data) (err u12)) ;; Monthly data must exist
      
      (let ((budget-summary-result (contract-call? budget-contract get-spending-summary user-id)))
        (match budget-summary-result
          budget-summary
            (let ((total-budget (get total-budget budget-summary))
                  (total-spent (get total-spent (unwrap-panic monthly-data))))
              (if (> total-budget u0)
                (if (> total-spent total-budget)
                  ;; Over budget
                  (let ((adherence-pct (- u100 (/ (* (- total-spent total-budget) u100) total-budget))))
                    (begin
                      (map-set performance-metrics
                               {user-id: user-id, year: year, month: month}
                               {budget-adherence: (if (< adherence-pct u0) u0 adherence-pct),
                                savings-rate: u0, ;; Placeholder
                                on-track-categories: u0, ;; Placeholder
                                over-budget-categories: u0}) ;; Placeholder
                      (ok adherence-pct)))
                  ;; Under or on budget
                  (let ((adherence-pct (- u100 (/ (* (- total-budget total-spent) u100) total-budget))))
                    (begin
                      (map-set performance-metrics
                               {user-id: user-id, year: year, month: month}
                               {budget-adherence: adherence-pct,
                                savings-rate: u0, ;; Placeholder
                                on-track-categories: u0, ;; Placeholder
                                over-budget-categories: u0}) ;; Placeholder
                      (ok adherence-pct))))
                (err u13)))  ;; Error if budget is zero
          error-code (err error-code))))))  ;; Pass through the error code

;; Helper function to generate list of months for analysis
(define-private (generate-month-list (count uint))
  (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10))

;; Get month spending for a specific month with validation
(define-read-only (get-month-spending (user-id uint) (year uint) (month uint))
  (begin
    ;; No assertions in read-only functions, but we'll use conditionals
    (if (or (<= user-id u0) (not (is-valid-year year)) (not (is-valid-month month)))
      {month: month, spent: u0}
      (let ((monthly-data (map-get? monthly-spending {user-id: user-id, year: year, month: month})))
        (if (is-some monthly-data)
          {month: month, spent: (get total-spent (unwrap-panic monthly-data))}
          {month: month, spent: u0})))))

;; Helper functions for getting months 1-10
(define-private (get-month-1 (user-id uint) (year uint))
  (get-month-spending user-id year u1))

(define-private (get-month-2 (user-id uint) (year uint))
  (get-month-spending user-id year u2))

(define-private (get-month-3 (user-id uint) (year uint))
  (get-month-spending user-id year u3))

(define-private (get-month-4 (user-id uint) (year uint))
  (get-month-spending user-id year u4))

(define-private (get-month-5 (user-id uint) (year uint))
  (get-month-spending user-id year u5))

(define-private (get-month-6 (user-id uint) (year uint))
  (get-month-spending user-id year u6))

(define-private (get-month-7 (user-id uint) (year uint))
  (get-month-spending user-id year u7))

(define-private (get-month-8 (user-id uint) (year uint))
  (get-month-spending user-id year u8))

(define-private (get-month-9 (user-id uint) (year uint))
  (get-month-spending user-id year u9))

(define-private (get-month-10 (user-id uint) (year uint))
  (get-month-spending user-id year u10))

;; Public function to get spending trend with input validation
(define-public (compute-spending-trend (user-id uint) (year uint) (months uint))
  (begin
    ;; Validate inputs
    (asserts! (> user-id u0) (err u14)) ;; User ID must be positive
    (asserts! (is-valid-year year) (err u15)) ;; Year must be in valid range
    (asserts! (and (>= months u1) (<= months u12)) (err u16)) ;; Months must be in valid range
    
    (ok (get-spending-trend-internal user-id year months))))

;; Simplified version with separate functions for each case
(define-private (get-spending-trend-internal (user-id uint) (year uint) (months uint))
  (if (<= months u1)
      (list (get-month-1 user-id year))
    (if (is-eq months u2)
      (list (get-month-1 user-id year) (get-month-2 user-id year))
    (if (is-eq months u3)
      (list (get-month-1 user-id year) (get-month-2 user-id year) (get-month-3 user-id year))
    (if (is-eq months u4)
      (list (get-month-1 user-id year) (get-month-2 user-id year) (get-month-3 user-id year) (get-month-4 user-id year))
    (if (is-eq months u5)
      (list (get-month-1 user-id year) (get-month-2 user-id year) (get-month-3 user-id year) (get-month-4 user-id year) (get-month-5 user-id year))
    (if (is-eq months u6)
      (list (get-month-1 user-id year) (get-month-2 user-id year) (get-month-3 user-id year) (get-month-4 user-id year) (get-month-5 user-id year) (get-month-6 user-id year))
    (if (is-eq months u7)
      (list (get-month-1 user-id year) (get-month-2 user-id year) (get-month-3 user-id year) (get-month-4 user-id year) (get-month-5 user-id year) (get-month-6 user-id year) (get-month-7 user-id year))
    (if (is-eq months u8)
      (list (get-month-1 user-id year) (get-month-2 user-id year) (get-month-3 user-id year) (get-month-4 user-id year) (get-month-5 user-id year) (get-month-6 user-id year) (get-month-7 user-id year) (get-month-8 user-id year))
    (if (is-eq months u9)
      (list (get-month-1 user-id year) (get-month-2 user-id year) (get-month-3 user-id year) (get-month-4 user-id year) (get-month-5 user-id year) (get-month-6 user-id year) (get-month-7 user-id year) (get-month-8 user-id year) (get-month-9 user-id year))
      (list (get-month-1 user-id year) (get-month-2 user-id year) (get-month-3 user-id year) (get-month-4 user-id year) (get-month-5 user-id year) (get-month-6 user-id year) (get-month-7 user-id year) (get-month-8 user-id year) (get-month-9 user-id year) (get-month-10 user-id year))
    ))))))))))

;; Read-only interface for getting spending trend (doesn't modify state)
(define-read-only (get-spending-trend (user-id uint) (year uint) (months uint))
  (if (or (<= user-id u0) 
          (not (is-valid-year year)) 
          (not (and (>= months u1) (<= months u12))))
    (list) ;; Return empty list for invalid inputs
    (get-spending-trend-internal user-id year months)))

;; Define the public interface for interoperability
(define-trait budget-analytics-trait
  (
    (record-monthly-summary (uint uint uint uint (list 10 {category: (string-ascii 20), spent: uint})) (response bool uint))
    (create-savings-goal (uint (string-ascii 50) uint uint) (response uint uint))
    (update-savings-progress (uint uint uint) (response bool uint))
    (compute-budget-adherence (<budget-planner-trait> uint uint uint) (response uint uint))
  )
)
