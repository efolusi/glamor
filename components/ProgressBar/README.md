# ProgressBar

A 4-high capsule on `border`, filled with its tone. Use it for how full something is (a group's protected share, disk use) or how far a transfer has got.

**Provide:** the value in percent and the tone: `ok` when complete or healthy, `warn` when nearly full, `accentEdge` while in progress (copper with 3:1 on the track: plain `accent` is 2.2:1 on `border` in light).

- Put the number next to it in `mono-s` or `caption`; the bar never stands alone.

- Motion: the fill moves to each new value over motion-progress (250 ms, linear), so it never jumps; the number beside it changes at once. Reduce Motion: the fill jumps. iPhone: none.
