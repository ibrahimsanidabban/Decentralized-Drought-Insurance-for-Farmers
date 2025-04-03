;; Farm Registration Contract
;; Records details of agricultural operations

(define-data-var admin principal tx-sender)

;; Farm data structure
(define-map farms
  { owner: principal }
  {
    farm-id: (string-utf8 36),
    location: (string-utf8 100),
    size: uint,
    crop-type: (string-utf8 50),
    registered-at: uint
  }
)

;; Public function to register a farm
(define-public (register-farm (farm-id (string-utf8 36)) (location (string-utf8 100)) (size uint) (crop-type (string-utf8 50)))
  (let ((caller tx-sender))
    (if (is-farm-registered caller)
      (err u1) ;; Farm already registered
      (begin
        (map-set farms { owner: caller }
          {
            farm-id: farm-id,
            location: location,
            size: size,
            crop-type: crop-type,
            registered-at: block-height
          }
        )
        (ok true)
      )
    )
  )
)

;; Check if a farm is registered
(define-read-only (is-farm-registered (owner principal))
  (is-some (map-get? farms { owner: owner }))
)

;; Get farm details
(define-read-only (get-farm-details (owner principal))
  (map-get? farms { owner: owner })
)

;; Update farm details
(define-public (update-farm-details (location (string-utf8 100)) (size uint) (crop-type (string-utf8 50)))
  (let ((caller tx-sender))
    (if (is-farm-registered caller)
      (let ((current-farm (unwrap! (get-farm-details caller) (err u2))))
        (map-set farms { owner: caller }
          (merge current-farm {
            location: location,
            size: size,
            crop-type: crop-type
          })
        )
        (ok true)
      )
      (err u3) ;; Farm not registered
    )
  )
)
