;; Weather Data Oracle Contract
;; Provides verified climate information

(define-data-var admin principal tx-sender)

;; Weather data structure by region
(define-map weather-data
  { region: (string-utf8 50) }
  {
    temperature: int,
    rainfall: uint,
    humidity: uint,
    updated-at: uint,
    updated-by: principal
  }
)

;; List of authorized data providers
(define-map authorized-providers
  { provider: principal }
  { authorized: bool }
)

;; Initialize the admin
(define-data-var oracle-admin principal tx-sender)

;; Add a data provider
(define-public (add-provider (provider principal))
  (begin
    (asserts! (is-eq tx-sender (var-get oracle-admin)) (err u1))
    (map-set authorized-providers { provider: provider } { authorized: true })
    (ok true)
  )
)

;; Remove a data provider
(define-public (remove-provider (provider principal))
  (begin
    (asserts! (is-eq tx-sender (var-get oracle-admin)) (err u1))
    (map-set authorized-providers { provider: provider } { authorized: false })
    (ok true)
  )
)

;; Check if a provider is authorized
(define-read-only (is-authorized-provider (provider principal))
  (default-to false (get authorized (map-get? authorized-providers { provider: provider })))
)

;; Update weather data for a region
(define-public (update-weather (region (string-utf8 50)) (temperature int) (rainfall uint) (humidity uint))
  (begin
    (asserts! (is-authorized-provider tx-sender) (err u2))
    (map-set weather-data { region: region }
      {
        temperature: temperature,
        rainfall: rainfall,
        humidity: humidity,
        updated-at: block-height,
        updated-by: tx-sender
      }
    )
    (ok true)
  )
)

;; Get weather data for a region
(define-read-only (get-weather (region (string-utf8 50)))
  (map-get? weather-data { region: region })
)
