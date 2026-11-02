# Third addendum to `protocol.md` (2026-11-02)

`protocol.md` stays frozen; this file records a third change, decided by the author after the arm had passed the ceiling. The second addendum said 180M would be the last raise. This overrides that statement, and the override is itself a result.

**Change:** the hard ceiling goes from 180M to 210M, example sessions included. If the arm reaches 210M, it stops there.

**Conditions:**
- No more correction rounds on T27. Whatever fails in the second round's report stays documented as open, even if the arm proposes another package.
- After that report, the arm writes only the case study and the commit.

**Why:**
- The arm crossed 180M at about 11:42 local with no stop in place: pressing Esc was left to the author, and it was not clear Esc would stop a background tester. It was at 192.14M at 11:51 when this was decided.
- By then the tester had touched 53 of about 65 tests and was in the last block, with its report still to come. Stopping would have discarded about 25M of a nearly finished round, the one that measures the fixes for the bank leak, the PDF header and the controller's restrictions.

**Known when deciding:** T21 to T26 closed, T27 round one at 56 of 60 regular, round two not reported. No independent grading had run. The estimates that led to 180M were wrong by about 40M.

**Controls:**
- The results report four points: 80M, 140M, 180M and final. At 180M: T21 to T26 closed, T27 at 56 of 60 from round one, round two running.
- The grader receives all three addenda, and is told which results exist only past 180M.
- Other rules are unchanged.
