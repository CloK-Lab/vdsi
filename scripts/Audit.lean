import VDSI

/-- info: 'VDSI.Network.deliverNext_satisfies_spec' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms VDSI.Network.deliverNext_satisfies_spec

/-- info: 'VDSI.Node.receiveRegistration_satisfies_spec' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms VDSI.Node.receiveRegistration_satisfies_spec

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
