import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";

initializeApp();
const db = getFirestore();

/**
 * Starter callable for recording a poll vote.
 * Validate poll option IDs and enforce poll/community visibility before production.
 */
export const castPollVote = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Sign in required.");
  const { pollId, optionId } = request.data ?? {};
  if (typeof pollId !== "string" || typeof optionId !== "string") {
    throw new HttpsError("invalid-argument", "pollId and optionId are required.");
  }

  const pollRef = db.collection("polls").doc(pollId);
  const voteRef = pollRef.collection("votes").doc(request.auth.uid);
  await db.runTransaction(async (tx) => {
    const poll = await tx.get(pollRef);
    if (!poll.exists) throw new HttpsError("not-found", "Poll not found.");
    const options: unknown = poll.get("options");
    if (!Array.isArray(options) || !options.some((o: any) => o?.id === optionId)) {
      throw new HttpsError("invalid-argument", "Invalid poll option.");
    }
    tx.set(voteRef, {
      userId: request.auth!.uid,
      optionId,
      updatedAt: FieldValue.serverTimestamp()
    });
  });
  return { ok: true };
});
