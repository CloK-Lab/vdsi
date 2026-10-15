import Lean.Data.Json
import VDSI.Identity.Execution

namespace VDSI.Identity.Snapshot
open Lean

private structure Entry where
  domain : String
  version : Nat
  network : String
  publicKey : List Nat
  signature : List Nat
  deriving ToJson, FromJson

private structure File where
  version : Nat
  network : String
  records : List Entry
  deriving ToJson, FromJson

def encode (network : String) (records : Registry) : String :=
  let entries := records.map fun r =>
    { domain := r.statement.domain, version := r.statement.version,
      network := r.statement.network, publicKey := r.statement.publicKey.bytes.map UInt8.toNat,
      signature := r.signature.map UInt8.toNat : Entry }
  (toJson ({ version := 1, network, records := entries } : File)).compress

private def bytes (values : List Nat) : Except String (List UInt8) := do
  unless values.all (· < 256) do throw "Byte outside 0..255"
  return values.map UInt8.ofNat

/-- Decode the whole file, check its network/version, then call the proved
restore operation. A well-formed JSON document is not itself a valid registry. -/
def decode (network : String) (verify : Verifier) (text : String) : Except String Registry := do
  let file : File ← fromJson? (← Json.parse text)
  unless file.version == 1 && file.network == network do throw "Snapshot version or network mismatch"
  let records ← file.records.mapM fun entry => do
    let key ← bytes entry.publicKey
    let signature ← bytes entry.signature
    let statement : Statement :=
      { domain := entry.domain
        version := entry.version
        network := entry.network
        publicKey := ⟨key⟩ }
    pure ({ statement, signature } : Registration)
  match restoreRegistry network verify records with
  | some restored => return restored
  | none => throw "Invalid registration or duplicate public key"

end VDSI.Identity.Snapshot
