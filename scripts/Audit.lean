import VDSI

/-- info: 'VDSI.Identity.mergeRegistry_success' depends on axioms: [propext] -/
#guard_msgs in
#print axioms VDSI.Identity.mergeRegistry_success

/-- info: 'VDSI.Identity.mergeRegistry_preserves_records' depends on axioms: [propext] -/
#guard_msgs in
#print axioms VDSI.Identity.mergeRegistry_preserves_records

/-- info: 'VDSI.Identity.combineRecords_keys' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms VDSI.Identity.combineRecords_keys

/-- info: 'VDSI.Identity.mergeRegistry_keys' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms VDSI.Identity.mergeRegistry_keys

/-- info: 'VDSI.Identity.mergeRegistry_known_keys_unchanged' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms VDSI.Identity.mergeRegistry_known_keys_unchanged

/-- info: 'VDSI.Identity.mergeRegistry_exchange_agrees' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms VDSI.Identity.mergeRegistry_exchange_agrees

/-- info: 'VDSI.Identity.restoreRegistry_success_iff' does not depend on any axioms -/
#guard_msgs in
#print axioms VDSI.Identity.restoreRegistry_success_iff

/-- info: 'VDSI.Identity.restoreRegistry_preserves_invariant' does not depend on any axioms -/
#guard_msgs in
#print axioms VDSI.Identity.restoreRegistry_preserves_invariant

/-- info: 'VDSI.Identity.signingBytes_requires_supported_statement' does not depend on any axioms -/
#guard_msgs in
#print axioms VDSI.Identity.signingBytes_requires_supported_statement

/-- info: 'VDSI.Identity.signingBytes_injective' depends on axioms: [propext] -/
#guard_msgs in
#print axioms VDSI.Identity.signingBytes_injective

/-- info: 'VDSI.Identity.unsupported_encoding_rejected' depends on axioms: [propext] -/
#guard_msgs in
#print axioms VDSI.Identity.unsupported_encoding_rejected

/-- info: 'VDSI.Identity.byte_verifier_acceptance_uses_encoding' does not depend on any axioms -/
#guard_msgs in
#print axioms VDSI.Identity.byte_verifier_acceptance_uses_encoding

/-- info: 'VDSI.Identity.registration_requires_validation' depends on axioms: [propext] -/
#guard_msgs in
#print axioms VDSI.Identity.registration_requires_validation

/-- info: 'VDSI.Identity.invalid_registration_rejected' depends on axioms: [propext] -/
#guard_msgs in
#print axioms VDSI.Identity.invalid_registration_rejected

/-- info: 'VDSI.Identity.valid_replay_unchanged' depends on axioms: [propext] -/
#guard_msgs in
#print axioms VDSI.Identity.valid_replay_unchanged

/-- info: 'VDSI.Identity.registration_preserves_records' depends on axioms: [propext] -/
#guard_msgs in
#print axioms VDSI.Identity.registration_preserves_records

/-- info: 'VDSI.Identity.registration_preserves_invariant' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms VDSI.Identity.registration_preserves_invariant

/-- info: 'VDSI.IdGeneration.toParticipantId_eq_iff' depends on axioms: [propext] -/
#guard_msgs in
#print axioms VDSI.IdGeneration.toParticipantId_eq_iff

/-- info: 'VDSI.IdGeneration.birthday_bound' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms VDSI.IdGeneration.birthday_bound

/-- info: 'VDSI.IdGeneration.billion_ids_satisfy_risk_spec' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms VDSI.IdGeneration.billion_ids_satisfy_risk_spec

/-- info: 'VDSI.System.execution_preserves_safety' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms VDSI.System.execution_preserves_safety

/-- info: 'VDSI.System.successful_delivery_satisfies_spec' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms VDSI.System.successful_delivery_satisfies_spec

/-- info: 'VDSI.System.confirmed_registration_survives_execution' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms VDSI.System.confirmed_registration_survives_execution

/-- info: 'VDSI.Node.restoreRegistry_satisfies_spec' does not depend on any axioms -/
#guard_msgs in
#print axioms VDSI.Node.restoreRegistry_satisfies_spec

/-- info: 'VDSI.Node.mergeRegistry_satisfies_spec' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms VDSI.Node.mergeRegistry_satisfies_spec

/-- info: 'VDSI.Node.merging_each_others_registry_agrees' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms VDSI.Node.merging_each_others_registry_agrees

/-- info: 'VDSI.Node.same_requested_ids_produce_same_registered_ids' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms VDSI.Node.same_requested_ids_produce_same_registered_ids

/-- info: 'VDSI.Node.processRegistrations_satisfies_spec' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms VDSI.Node.processRegistrations_satisfies_spec

/-- info: 'VDSI.Node.registration_spec_contains_exactly_initial_and_requested_ids' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms VDSI.Node.registration_spec_contains_exactly_initial_and_requested_ids

/-- info: 'VDSI.Node.registration_spec_guarantees_agreement' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms VDSI.Node.registration_spec_guarantees_agreement

/-- info: 'VDSI.Registry.register_then_find_returns_participant' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms VDSI.Registry.register_then_find_returns_participant

/-- info: 'VDSI.register_satisfies_spec' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms VDSI.register_satisfies_spec

/-- info: 'VDSI.register_preserves_unique_ids' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms VDSI.register_preserves_unique_ids

/-- info: 'VDSI.findParticipant_satisfies_spec' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms VDSI.findParticipant_satisfies_spec

/-- info: 'VDSI.findParticipant_returns_iff_present_with_matching_id' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms VDSI.findParticipant_returns_iff_present_with_matching_id
