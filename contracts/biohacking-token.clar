;; BiohackingToken Contract

(define-fungible-token biohacking-token)

(define-data-var token-uri (string-utf8 256) u"")

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-balance (err u101))

(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ft-mint? biohacking-token amount recipient)
  )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-insufficient-balance)
    (ft-transfer? biohacking-token amount sender recipient)
  )
)

(define-public (reward-sharing (recipient principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ft-mint? biohacking-token amount recipient)
  )
)

(define-public (reward-replication (recipient principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ft-mint? biohacking-token amount recipient)
  )
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance biohacking-token account))
)

(define-public (set-token-uri (new-uri (string-utf8 256)))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (var-set token-uri new-uri))
  )
)

(define-read-only (get-token-uri)
  (ok (var-get token-uri))
)

