import VDSI.Participant
import Mathlib.Data.Fintype.BigOperators
import Mathlib.Data.Rat.Defs

namespace VDSI.IdGeneration

/-- One value in the complete space of `bits`-bit identifiers. -/
abbrev Draw (bits : Nat) := Fin (2 ^ bits)

/-- Preserve every sampled bit when representing the value as a participant ID.
This conversion consumes a sample; it does not obtain randomness from the OS. -/
def toParticipantId {bits : Nat} (draw : Draw bits) : ParticipantId :=
  ⟨draw.val⟩

/-- All possible outcomes of `draws` independent uniform draws.
The uniform distribution on this finite product gives every outcome equal weight. -/
abbrev Sample (bits draws : Nat) := Fin draws → Draw bits

/-- Two distinct generation positions produce the same participant ID. -/
def HasCollision {bits draws : Nat} (sample : Sample bits draws) : Prop :=
  ∃ i j, i < j ∧ toParticipantId (sample i) = toParticipantId (sample j)

instance {bits draws : Nat} (sample : Sample bits draws) :
    Decidable (HasCollision sample) :=
  inferInstanceAs (Decidable (∃ i j, i < j ∧
    toParticipantId (sample i) = toParticipantId (sample j)))

/-- The actual collision event, enumerated only for small worked examples. -/
def collidingSamples (bits draws : Nat) : Finset (Sample bits draws) :=
  Finset.univ.filter HasCollision

/-- Exact probability under the uniform product model: bad outcomes / all outcomes.
This definition counts collisions; it does not assume a birthday bound. -/
def collisionProbability (bits draws : Nat) : ℚ :=
  (collidingSamples bits draws).card / (Fintype.card (Sample bits draws) : ℚ)

end VDSI.IdGeneration
