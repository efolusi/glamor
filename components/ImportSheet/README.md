# ImportSheet

The Import sheet (`ImportSheet`): what komando would add from a file you already have, shown before anything is added. It opens from Welcome's "Import from ~/.ssh/config" (**PageWelcome**), from Hosts' empty state and File › Import from SSH Config… (**PageAppMenus**), and from each button under "Or import what you already have" on **PageAdd** (SSH Config…, .pgpass…, my.cnf…, .env…, kubeconfig…, Docker…, DBeaver…, AWS…, rclone…, FileZilla…). New Connection's Kind menu lists kinds only. Journey 7.

- **A Sheet with one job.** A **Sheet** with `square.and.arrow.down` in a 48 `accent` tile, "Import from .pgpass" in `title-l`, and one line on what it reads, the path in mono.
- **A dry run first.** On open it runs `komando import SOURCE --dry-run` ("Reading .pgpass…" with a spinner meanwhile) and lists what it would add in a **CardList** of 32 rows, `space-12` inside and between: a 20 **IconTile** and the name in `body`. A server gets `server.rack` in `tint-servers`, a VPN its own symbol and tint, and a connection `link` in `accent`, because the dry run names connections without their kind.
- **What it leaves out.** komando's notes on lines it could not import follow in `caption` `text3`, with a command in mono. Only the backticks of a command are read: the rest is shown exactly as komando printed it, so a link or other Markdown in a .env line is never drawn as a link. A name already in the inventory is skipped; when nothing is new, an `accent` **Banner** "Nothing new to add." names the ones already there.
- **One primary that counts.** **Cancel** (secondary) and **Import 3 Targets** (primary, disabled while nothing is new) on the right, as in every Sheet. After the import an `ok` **Banner** "Added 3 targets." lists the names and Cancel becomes **Done**. One target says "Import 1 Target" and "Added 1 target."
- **A .env has no usual place.** For .env the sheet first shows **Choose a .env File…** (secondary), then the dry run.
- **Passwords go to the keychain** as `secret:NAME-pass` and are never shown, here or after. DBeaver brings none, so its connections show "Password missing" with **Add Password** on Connections (**PageStates**).

| Source | What it reads |
| --- | --- |
| SSH Config | Servers in `~/.ssh/config` become hosts. |
| .pgpass | PostgreSQL databases and their passwords from `~/.pgpass`. |
| my.cnf | MySQL and MariaDB databases from `~/.my.cnf`. |
| .env | Database, cache and storage URLs from a .env file. |
| kubeconfig | One connection per context in `~/.kube/config`. |
| Docker | Registries you are logged in to with `docker login`. |
| DBeaver | Databases from DBeaver; set their passwords afterwards. |
| AWS | An S3 connection for each bucket of each AWS profile. |
| rclone | SFTP remotes from rclone. |
| FileZilla | SFTP sites from FileZilla's Site Manager. |

- **For beginners:** nothing is added until the person has seen the list, and the button says how many targets it will add, using the app's one word for anything in the inventory.
