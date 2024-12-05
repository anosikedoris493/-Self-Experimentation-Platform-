;; ExperimentProtocol Contract

(define-map experiments
  { experiment-id: uint }
  {
    creator: principal,
    title: (string-ascii 64),
    description: (string-utf8 256),
    protocol: (string-utf8 1024),
    start-date: uint,
    end-date: uint,
    status: (string-ascii 20)
  }
)

(define-map experiment-results
  { experiment-id: uint, participant: principal }
  {
    result-hash: (buff 32),
    submission-date: uint,
    verified: bool
  }
)

(define-data-var last-experiment-id uint u0)

(define-constant err-not-found (err u404))
(define-constant err-unauthorized (err u401))
(define-constant err-invalid-dates (err u400))

(define-public (create-experiment (title (string-ascii 64)) (description (string-utf8 256)) (protocol (string-utf8 1024)) (start-date uint) (end-date uint))
  (let
    (
      (new-experiment-id (+ (var-get last-experiment-id) u1))
    )
    (asserts! (< start-date end-date) err-invalid-dates)
    (map-set experiments
      { experiment-id: new-experiment-id }
      {
        creator: tx-sender,
        title: title,
        description: description,
        protocol: protocol,
        start-date: start-date,
        end-date: end-date,
        status: "active"
      }
    )
    (var-set last-experiment-id new-experiment-id)
    (ok new-experiment-id)
  )
)

(define-public (submit-result (experiment-id uint) (result-hash (buff 32)))
  (let
    (
      (experiment (unwrap! (map-get? experiments { experiment-id: experiment-id }) err-not-found))
    )
    (asserts! (and (>= block-height (get start-date experiment)) (<= block-height (get end-date experiment))) err-unauthorized)
    (map-set experiment-results
      { experiment-id: experiment-id, participant: tx-sender }
      {
        result-hash: result-hash,
        submission-date: block-height,
        verified: false
      }
    )
    (ok true)
  )
)

(define-public (verify-result (experiment-id uint) (participant principal))
  (let
    (
      (experiment (unwrap! (map-get? experiments { experiment-id: experiment-id }) err-not-found))
      (result (unwrap! (map-get? experiment-results { experiment-id: experiment-id, participant: participant }) err-not-found))
    )
    (asserts! (is-eq (get creator experiment) tx-sender) err-unauthorized)
    (map-set experiment-results
      { experiment-id: experiment-id, participant: participant }
      (merge result { verified: true })
    )
    (ok true)
  )
)

(define-read-only (get-experiment (experiment-id uint))
  (ok (unwrap! (map-get? experiments { experiment-id: experiment-id }) err-not-found))
)

(define-read-only (get-experiment-result (experiment-id uint) (participant principal))
  (ok (unwrap! (map-get? experiment-results { experiment-id: experiment-id, participant: participant }) err-not-found))
)

