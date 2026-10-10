import VDSI

/-- info: 'VDSI.register_then_find_returns_participant' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms VDSI.register_then_find_returns_participant

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
