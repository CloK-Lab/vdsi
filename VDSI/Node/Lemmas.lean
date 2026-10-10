import VDSI.Node.Spec

namespace VDSI.Node

/-- The executable sequence processor satisfies the specification for every
initial node and every request list, including lists with duplicate IDs. -/
theorem processRegistrations_satisfies_spec
    (before : Node) (requests : List Participant) :
    ProcessRegistrationsSpec before requests (before.processRegistrations requests) := by
  induction requests generalizing before with
  | nil =>
      exact .done before
  | cons participant remaining remainingMeetsSpec =>
      have registrationMeetsSpec :=
        register_satisfies_spec before.registry.participants participant
      unfold processRegistrations Node.register
      generalize registryResult : before.registry.register participant = result
      unfold Registry.register at registryResult
      split at registryResult
      · rename_i registrationRejected
        -- Reject the duplicate and continue from the unchanged node.
        cases registryResult
        rw [registrationRejected] at registrationMeetsSpec
        exact .rejected before _ participant remaining registrationMeetsSpec
          (remainingMeetsSpec before)
      · rename_i updatedParticipants registrationSucceeded
        -- Add the new participant, keep the node ID, and process the rest.
        cases registryResult
        rw [registrationSucceeded] at registrationMeetsSpec
        let next : Node := { before with registry := {
          participants := updatedParticipants
          idsAreUnique := register_preserves_unique_ids
            before.registry.participants participant updatedParticipants
            before.registry.idsAreUnique registrationSucceeded
        } }
        exact .registered before next _ participant remaining rfl registrationMeetsSpec
          (remainingMeetsSpec next)

/-- A final ID is present exactly when it was present initially or was requested.
No initial or requested ID is lost, and no other ID is introduced. -/
theorem registration_spec_contains_exactly_initial_and_requested_ids
    (before after : Node) (requests : List Participant)
    (processingMeetsSpec : ProcessRegistrationsSpec before requests after)
    (id : ParticipantId) :
    IdIsRegistered id after.registry.participants ↔
      IdIsRegistered id before.registry.participants ∨ IdIsRegistered id requests := by
  induction processingMeetsSpec with
  | done node =>
      simp [IdIsRegistered]
  | registered before next after participant remaining nodeIdIsPreserved
      registrationMeetsSpec restMeetsSpec remainingIds =>
      -- A successful request adds its ID before the remaining requests are processed.
      rw [remainingIds, registrationMeetsSpec.2]
      simp [IdIsRegistered, or_assoc]
  | rejected before after participant remaining rejectionMeetsSpec restMeetsSpec remainingIds =>
      -- The rejected request's ID is already present, so rejecting it loses no ID.
      rw [remainingIds]
      have rejectedIdWasPresent : IdIsRegistered participant.id before.registry.participants :=
        rejectionMeetsSpec
      simp only [IdIsRegistered, List.map_cons, List.mem_cons] at rejectedIdWasPresent ⊢
      constructor
      · intro presentOrRequested
        rcases presentOrRequested with wasPresent | wasRequested
        · exact Or.inl wasPresent
        · exact Or.inr (Or.inr wasRequested)
      · intro presentOrRequested
        rcases presentOrRequested with wasPresent | isRejectedId | wasRequested
        · exact Or.inl wasPresent
        · subst id
          exact Or.inl rejectedIdWasPresent
        · exact Or.inr wasRequested

/-- Equal initial ID sets and equal requested ID sets give equal final ID sets,
regardless of request order or repetition. -/
theorem registration_spec_guarantees_agreement
    (leftRequests rightRequests : List Participant)
    (leftBefore rightBefore leftAfter rightAfter : Node) :
    RegistrationAgreementSpec leftRequests rightRequests
      leftBefore rightBefore leftAfter rightAfter := by
  intro sameInitialIds sameRequestedIds leftMeetsSpec rightMeetsSpec id
  -- Each final set consists exactly of the initial IDs and the requested IDs.
  rw [registration_spec_contains_exactly_initial_and_requested_ids
        leftBefore leftAfter leftRequests leftMeetsSpec id,
      registration_spec_contains_exactly_initial_and_requested_ids
        rightBefore rightAfter rightRequests rightMeetsSpec id,
      sameInitialIds id, sameRequestedIds id]

end VDSI.Node
