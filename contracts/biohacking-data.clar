;; BiohackingData Contract

(define-map user-data
  { user: principal }
  {
    encrypted-data: (buff 1024),
    data-hash: (buff 32),
    last-updated: uint
  }
)

(define-map data-access-permissions
  { user: principal, requester: principal }
  { allowed: bool }
)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-unauthorized (err u101))
(define-constant err-invalid-data (err u102))

(define-public (store-data (encrypted-data (buff 1024)) (data-hash (buff 32)))
  (let
    (
      (user-principal tx-sender)
    )
    (map-set user-data
      { user: user-principal }
      {
        encrypted-data: encrypted-data,
        data-hash: data-hash,
        last-updated: block-height
      }
    )
    (ok true)
  )
)

(define-public (grant-data-access (requester principal))
  (let
    (
      (user-principal tx-sender)
    )
    (map-set data-access-permissions
      { user: user-principal, requester: requester }
      { allowed: true }
    )
    (ok true)
  )
)

(define-public (revoke-data-access (requester principal))
  (let
    (
      (user-principal tx-sender)
    )
    (map-set data-access-permissions
      { user: user-principal, requester: requester }
      { allowed: false }
    )
    (ok true)
  )
)

(define-read-only (get-user-data (user principal))
  (let
    (
      (access-allowed (default-to false (get allowed (map-get? data-access-permissions { user: user, requester: tx-sender }))))
    )
    (asserts! (or (is-eq tx-sender user) access-allowed) err-unauthorized)
    (ok (map-get? user-data { user: user }))
  )
)

(define-read-only (verify-data-integrity (user principal) (data-hash (buff 32)))
  (let
    (
      (stored-data (unwrap! (map-get? user-data { user: user }) err-invalid-data))
    )
    (ok (is-eq data-hash (get data-hash stored-data)))
  )
)

