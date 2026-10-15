import VDSI.Identity.Crypto.SHA512

namespace VDSI.Identity.Crypto.Ed25519

-- Pure Ed25519, following RFC 8032 sections 5.1 and 6. This uses variable-time
-- arbitrary-precision arithmetic, with no side-channel or zeroization guarantee.
-- It is a research implementation, not a production secret-key backend.
private def p : Nat := 2^255 - 19
private def order : Nat := 2^252 + 27742317777372353535851937790883648493
private def curveD : Nat := 37095705934669439343138083508754565189542113879843219016388785533085940283555
private def sqrtMinusOne : Nat := 19681161376707505956807079304988542015446066515923890162744021073123829784752

private def powMod (base exponent : Nat) : Nat := Id.run do
  let mut b := base % p
  let mut acc := 1
  let mut n := exponent
  for _ in [:exponent.log2 + 1] do
    if n % 2 == 1 then acc := acc * b % p
    b := b * b % p
    n := n / 2
  return acc

private def sub (a b : Nat) : Nat := (a % p + p - b % p) % p
private def inverse (a : Nat) : Nat := powMod a (p - 2)
private def fromLE (bytes : List UInt8) : Nat := bytes.foldr (fun b n => b.toNat + 256 * n) 0
private def toLE (n count : Nat) : List UInt8 :=
  (List.range count).map fun i => UInt8.ofNat (n >>> (8 * i))

private structure Point where
  x : Nat
  y : Nat
  z : Nat
  t : Nat

private def neutral : Point := ⟨0, 1, 1, 0⟩
private def basePoint : Point :=
  let x := 15112221349535400772501151409588531511454012693041857206046113283949847762202
  let y := 46316835694926478169428394003475163141307993866256225615783033603165251855960
  ⟨x, y, 1, x * y % p⟩

private def add (u v : Point) : Point :=
  let a := sub u.y u.x * sub v.y v.x % p
  let b := (u.y + u.x) * (v.y + v.x) % p
  let c := 2 * u.t * v.t * curveD % p
  let d := 2 * u.z * v.z % p
  let e := sub b a
  let f := sub d c
  let g := (d + c) % p
  let h := (b + a) % p
  ⟨e * f % p, g * h % p, f * g % p, e * h % p⟩

private def multiply (scalar : Nat) (point : Point) : Point := Id.run do
  let mut acc := neutral
  let mut current := point
  let mut n := scalar
  for _ in [:scalar.log2 + 1] do
    if n % 2 == 1 then acc := add acc current
    current := add current current
    n := n / 2
  return acc

private def equal (u v : Point) : Bool :=
  u.x * v.z % p == v.x * u.z % p && u.y * v.z % p == v.y * u.z % p

private def encode (point : Point) : List UInt8 :=
  let inv := inverse point.z
  let x := point.x * inv % p
  let y := point.y * inv % p
  toLE (y + (x % 2) * 2^255) 32

private def decode (bytes : List UInt8) : Option Point := do
  if bytes.length != 32 then none else do
    let value := fromLE bytes
    let y := value % 2^255
    let sign := value / 2^255
    if y >= p then none else do
      let denominator := (curveD * y * y + 1) % p
      if denominator == 0 then none else do
        let x2 := sub (y * y) 1 * inverse denominator % p
        let root := powMod x2 ((p + 3) / 8)
        let root := if root * root % p == x2 then root else root * sqrtMinusOne % p
        if root * root % p != x2 || (root == 0 && sign == 1) then none else do
          let x := if root % 2 == sign then root else p - root
          some ⟨x, y, 1, x * y % p⟩

private def expand (seed : List UInt8) : Option (Nat × List UInt8) := do
  if seed.length != 32 then none else do
    let digest := SHA512.hash seed
    let raw := fromLE (digest.take 32)
    let scalar := (raw % 2^254 / 8) * 8 + 2^254
    some (scalar, digest.drop 32)

/-- Derive an Ed25519 public key from exactly 32 seed bytes; does not sample entropy. -/
def publicKey (seed : List UInt8) : Option (List UInt8) := do
  let (scalar, _) ← expand seed
  return encode (multiply scalar basePoint)

/-- Deterministic PureEd25519 signing; rejects an incorrectly sized seed. -/
def sign (seed message : List UInt8) : Option (List UInt8) := do
  let (scalar, noncePrefix) ← expand seed
  let key := encode (multiply scalar basePoint)
  let nonce := fromLE (SHA512.hash (noncePrefix ++ message)) % order
  let r := encode (multiply nonce basePoint)
  let challenge := fromLE (SHA512.hash (r ++ key ++ message)) % order
  return r ++ toLE ((nonce + challenge * scalar) % order) 32

/-- Strict identity verification: canonical points and scalar, nonidentity
prime-subgroup public key and R, and the uncofactored verification equation.
This deliberately rejects small-order and mixed-order points, a stricter policy
than the RFC's cofactored equation. No unforgeability proof is provided. -/
def verify (key message signature : List UInt8) : Bool := Id.run do
  if key.length != 32 || signature.length != 64 then return false
  let some a := decode key | return false
  let rBytes := signature.take 32
  let some r := decode rBytes | return false
  let s := fromLE (signature.drop 32)
  if s >= order then return false
  if equal a neutral || equal r neutral then return false
  if !equal (multiply order a) neutral || !equal (multiply order r) neutral then return false
  let challenge := fromLE (SHA512.hash (rBytes ++ key ++ message)) % order
  return equal (multiply s basePoint) (add r (multiply challenge a))

end VDSI.Identity.Crypto.Ed25519
