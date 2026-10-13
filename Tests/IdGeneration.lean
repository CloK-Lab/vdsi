import VDSI.IdGeneration.Model
import Tests.Support

namespace Tests.IdGeneration

open VDSI.IdGeneration

def run : IO Unit := do
  check (collisionProbability 2 0 == 0) "No draws cannot collide"
  check (collisionProbability 2 1 == 0) "One draw cannot collide"
  check (collisionProbability 2 2 == 1 / 4) "Two draws: four colliding outcomes out of sixteen"
  check (collisionProbability 2 3 == 5 / 8) "Three draws: forty colliding outcomes out of sixty-four"
  check (collisionProbability 1 3 == 1) "Three draws from two values must collide"
  check ((toParticipantId (bits := 2) ⟨3, by decide⟩).value == 3)
    "Conversion preserves the sampled value"

end Tests.IdGeneration
