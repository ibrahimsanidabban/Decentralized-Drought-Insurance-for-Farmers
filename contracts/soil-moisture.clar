;; Soil Moisture Monitoring Contract
;; Tracks drought conditions in specific areas

(define-data-var admin principal tx-sender)

;; Soil moisture data structure by farm and region
(define-map soil-moisture-data
  { farm-id: (string-utf8 36), region: (string-utf8 50) }
  {
    moisture-level: uint,
    drought-threshold: uint,
    is-drought: bool,
    updated-at: uint,
    updated-by: principal
  }
)

;; List of authorized data providers
(define-map moisture-providers
  { provider: principal }
  { authorized: bool }
)

;; Add a data provider
(define-public (add-moisture-provider (provider principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (map-set moisture-providers { provider: provider } { authorized: true })
    (ok true)
  )
)

;; Check if a provider is authorized
(define-read-only (is-moisture-provider (provider principal))
  (default-to false (get authorized (map-get? moisture-providers { provider: provider })))
)

;; Update soil moisture data for a farm in a region
(define-public (update-soil-moisture
                (farm-id (string-utf8 36))
                (region (string-utf8 50))
                (moisture-level uint)
                (drought-threshold uint))
  (begin
    (asserts! (is-moisture-provider tx-sender) (err u2))
    (let ((is-drought (< moisture-level drought-threshold)))
      (map-set soil-moisture-data
        { farm-id: farm-id, region: region }
        {
          moisture-level: moisture-level,
          drought-threshold: drought-threshold,
          is-drought: is-drought,
          updated-at: block-height,
          updated-by: tx-sender
        }
      )
      (ok is-drought)
    )
  )
)

;; Get soil moisture data for a farm in a region
(define-read-only (get-soil-moisture (farm-id (string-utf8 36)) (region (string-utf8 50)))
  (map-get? soil-moisture-data { farm-id: farm-id, region: region })
)

;; Check if a farm is experiencing drought conditions
(define-read-only (is-farm-in-drought (farm-id (string-utf8 36)) (region (string-utf8 50)))
  (default-to false (get is-drought (map-get? soil-moisture-data { farm-id: farm-id, region: region })))
)
