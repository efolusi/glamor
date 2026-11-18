# Skeleton

A placeholder bar while a list loads: a still `subtle` shape, `radius-4` (owner decision 2026-11-15: no shimmer). Heights follow the text it stands for: 12 for a line of `caption`, 16 for `body`, and the tile size for a tile.

**Provide:** a width and a height.

- Show skeletons only for the first load of a list; a refresh keeps the old rows and dims the refresh button.

- Motion: none. It is still and shows only after delay-spinner (300 ms), then for at least hold-spinner (500 ms), so a fast load shows nothing: Hosts, Connections, Jobs, the Keychain's two lists and Port Forwarding all wait this way. Reduce Motion: the same.
