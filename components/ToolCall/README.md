# ToolCall

A komando command the agent ran, shown as a row: the exact command in mono, a status pill (Running, Done, Failed, Denied, Not run), the duration, and a disclosure for the output.

**Provide:** the command, its status and duration, the output, and whether it is open.

- A Not run call that komando refused is open, and its words wrap: a plain sentence, then "komando said:" and komando's words.
- Open the calls that the agent's answer depends on; keep routine ones closed.
- Failed is `danger`, Denied (the person said no) and Not run (the app or komando refused it before it ran) are `text2`.

- Motion: a run ends → the status symbol is replaced over motion-fast (Magic Replace: spinner to check or cross). The pill's word, its color and the exit code change at once. The spinner shows only after delay-spinner (300 ms) and stays at least hold-spinner (500 ms). Output text never animates. Reduce Motion: the same (a symbol replace is a fade). iPhone: success or error haptic for a run the person started, while its screen is open.
