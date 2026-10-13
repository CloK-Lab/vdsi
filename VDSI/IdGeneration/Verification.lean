import VDSI.IdGeneration.Spec
import Mathlib.Data.Fintype.Prod
import Mathlib.Data.Finset.Prod
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Positivity

open scoped BigOperators

namespace VDSI.IdGeneration

/-- Encoding a sampled value as an ID introduces no additional collisions. -/
@[simp] theorem toParticipantId_eq_iff {bits : Nat} (a b : Draw bits) :
    toParticipantId a = toParticipantId b ↔ a = b := by
  simp [toParticipantId, ParticipantId.mk.injEq, Fin.ext_iff]

private def pairs (draws : Nat) : Finset (Fin draws × Fin draws) :=
  (Finset.univ ×ˢ Finset.univ).filter (fun p => p.1 < p.2)

private def matchingSamples (bits draws : Nat) (p : Fin draws × Fin draws) :
    Finset (Sample bits draws) :=
  Finset.univ.filter (fun sample => sample p.1 = sample p.2)

private theorem pair_count_bound (bits draws : Nat) (i j : Fin draws) (hij : i ≠ j) :
    (matchingSamples bits draws (i, j)).card * 2 ^ bits ≤
      Fintype.card (Sample bits draws) := by
  let f : {sample : Sample bits draws // sample i = sample j} × Fin (2 ^ bits) →
      Sample bits draws := fun x => Function.update x.1.val i x.2
  have hinj : Function.Injective f := by
    intro a b h
    have hv : a.2 = b.2 := by
      simpa [f] using congrFun h i
    have hs : a.1.val = b.1.val := by
      funext k
      by_cases hk : k = i
      · subst k
        rw [a.1.property, b.1.property]
        simpa [f, hij.symm] using congrFun h j
      · simpa [f, hk] using congrFun h k
    exact Prod.ext (Subtype.ext hs) hv
  simpa [matchingSamples, Fintype.card_subtype] using Fintype.card_le_of_injective f hinj

private theorem collision_count_bound (bits draws : Nat) :
    (collidingSamples bits draws).card * 2 ^ bits ≤
      draws.choose 2 * Fintype.card (Sample bits draws) := by
  have heq : collidingSamples bits draws =
      (pairs draws).biUnion (matchingSamples bits draws) := by
    ext sample
    simp [collidingSamples, HasCollision, pairs, matchingSamples]
  have hc : (pairs draws).card = draws.choose 2 := by
    simpa [pairs] using Finset.card_product_filter_lt (s := (Finset.univ : Finset (Fin draws)))
  calc
    _ ≤ (∑ p ∈ pairs draws, (matchingSamples bits draws p).card) * 2 ^ bits := by
      rw [heq]
      exact Nat.mul_le_mul_right _ Finset.card_biUnion_le
    _ = ∑ p ∈ pairs draws, (matchingSamples bits draws p).card * 2 ^ bits :=
      Finset.sum_mul ..
    _ ≤ ∑ _p ∈ pairs draws, Fintype.card (Sample bits draws) := by
      apply Finset.sum_le_sum
      intro p hp
      exact pair_count_bound bits draws p.1 p.2 (ne_of_lt (Finset.mem_filter.mp hp).2)
    _ = _ := by simp [hc]

/-- The union bound over all distinct pairs of generation positions. -/
theorem birthday_bound (bits draws : Nat) :
    collisionProbability bits draws ≤ (draws.choose 2 : ℚ) / 2 ^ bits := by
  have hspace : (0 : ℚ) < 2 ^ bits := by positivity
  have htotal : (0 : ℚ) < Fintype.card (Sample bits draws) := by
    simp only [Sample, Draw, Fintype.card_fun, Fintype.card_fin]
    positivity
  unfold collisionProbability
  apply (div_le_div_iff₀ htotal hspace).mpr
  exact_mod_cast collision_count_bound bits draws

/-- Kernel-checked instance of the birthday bound at the stated workload and risk limit. -/
theorem billion_ids_satisfy_risk_spec : BillionIdRiskSpec := by
  intro draws hdraws
  have hchoose : draws.choose 2 ≤ Nat.choose 1000000000 2 :=
    Nat.choose_le_choose 2 hdraws
  have hq : (draws.choose 2 : ℚ) ≤ Nat.choose 1000000000 2 := by
    exact_mod_cast hchoose
  calc
    _ ≤ (draws.choose 2 : ℚ) / 2 ^ 256 := birthday_bound 256 draws
    _ ≤ (Nat.choose 1000000000 2 : ℚ) / 2 ^ 256 :=
      div_le_div_of_nonneg_right hq (by positivity)
    _ < _ := by norm_num [Nat.choose_two_right]

end VDSI.IdGeneration
