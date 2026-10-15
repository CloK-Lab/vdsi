// Independent reference check only. Project execution does not use Node crypto.
// All seeds here are reproducible PUBLIC fixtures, never user credentials.
import { createPrivateKey, createPublicKey, sign, verify } from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import assert from 'node:assert/strict';
const root = fileURLToPath(new URL('../', import.meta.url));
execFileSync('lake', ['build', 'VDSI.Identity.Crypto.Ed25519'], { cwd: root, stdio: 'inherit' });
const output = execFileSync('lake', ['env', 'lean', '--run', 'tools/IdentityInterop.lean'],
  { cwd: root, encoding: 'utf8', timeout: 120000 });
const rows = output.trim().split('\n');
assert.equal(rows.length, 27);
for (const row of rows) {
  const [indexText, sizeText, keyHex, signatureHex] = row.trim().split(' ');
  const index = Number(indexText), size = Number(sizeText);
  const seed = Buffer.from(Array.from({ length: 32 }, (_, i) => (i + index * 43) % 256));
  const message = Buffer.from(Array.from({ length: size }, (_, i) => (i * 17 + index) % 256));
  const privateKey = createPrivateKey({ key: Buffer.concat([
    Buffer.from('302e020100300506032b657004220420', 'hex'), seed]), format: 'der', type: 'pkcs8' });
  const publicKey = createPublicKey(privateKey);
  assert.equal(publicKey.export({ format: 'der', type: 'spki' }).subarray(-32).toString('hex'), keyHex);
  const nativeSignature = Buffer.from(signatureHex, 'hex');
  assert.equal(sign(null, message, privateKey).toString('hex'), signatureHex);
  assert.equal(verify(null, message, publicKey, nativeSignature), true);
  assert.equal(verify(null, Buffer.concat([message, Buffer.from([0])]), publicKey, nativeSignature), false);
}
console.log('[PASS] Ed25519 interop: 27 public-fixture key/signature/verification cases match Node crypto.');
