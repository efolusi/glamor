# User journeys

Every journey Komando is designed around, in the order a person meets the app: from installing komando to the command line. A new screen or state starts here: add it to its journey first, then draw its Page card, then build it. The journeys follow the Layout rules in the README: six places (Home, Hosts, Connections, Files, Port Forwarding, Recipes, with Jobs, Keychain and Audit Log under More; never a seventh), one way into each thing, one primary button per screen, and one safety control, ☐ Allow changes.

## How to read this file

- Every journey has the same parts: a Goal, numbered steps, If it goes wrong, and Done when.
- Screens are in bold and named by their Page card (**PageHosts**). Nothing else is bold, apart from the three part labels.
- Controls are written plain, exactly as the screen spells them: buttons and menu items in Title Case with their ellipsis when they open something that asks more (Edit Host…), labels, links and tooltips in Sentence case (☐ Allow changes, Reach through a server or VPN, Use Komando without an account, New conversation).
- What a screen says is in quotes ("Everything looks fine."). Commands, addresses and file paths are in `mono`.
- ⋯ is the More button at the end of a row or a toolbar. Right-clicking a row opens the same menu.
- Smaller parts a screen uses (AlertDialog, Banner, ApprovalCard, ToolCall, ImportSheet, CommandPalette, Notifications) are named plain; they are component cards.
- A journey whose heading says "(proposed: Komando Cloud phase N, nothing built)" follows `docs/sync.md`. Nothing in it exists in the app; its cards are drawn in the Proposed group, and it uses their control names.
- A screen that no card draws yet is marked "(to draw)" and listed under Cards still to draw at the end.

## Words used here

- komando is the free command line that does the work. Komando is this app, which runs komando for you.
- A target is anything komando can reach: a server (also called a host), or a connection (a database, cache, storage bucket, cluster, registry, message queue or VPN). The inventory is the list of all of them.
- SSH is the secure way to log in to a server. A key is a file that proves who you are to a server instead of a password.
- Protected marks a target where every change needs your confirmation, such as production.
- A finding is something komando's doctor (its health check) found wrong, said in one sentence.
- A forward makes a port on a server reachable at an address on this Mac (`localhost:15432`); komando's command for it is `komando tunnel`. A VPN is a private network you join to reach servers that are not on the internet.
- A recipe is a saved command with blanks. A job is a long command that keeps running on its server after you disconnect.
- The audit log is komando's record of every change and every attempt it blocked. The keychain is where komando keeps passwords and keys, encrypted.

## 1. Install komando

**Goal:** get the free komando command line onto this Mac, so Komando has something to run.

1. Open Komando. When komando is not found, the whole panel is **PageInstall**: "Install the komando command line", the install command in `mono`, and three buttons. The six places stay in the sidebar, without counts.
2. Click Copy Command, paste the command into the Terminal app and press Return. It downloads and installs komando.
3. Click Check Again. Komando looks for komando again, and when it answers the panel becomes **PageWelcome** (journey 5), or **PageSignIn** once accounts exist (journey 2).
4. If komando is installed somewhere Komando does not look, click Choose komando…: a file panel opens at `/usr/local/bin` with "Pick the komando program". Pick it.

**If it goes wrong:**
- Check Again finds nothing: the install did not finish, or komando went to an unusual folder. Run the command again, or use Choose komando….
- komando is found but does not answer: pages show a danger Banner "komando did not answer" with komando's error and hint, and Try Again (**PageStates**). The profile menu says "komando is not answering" (journey 23).

**Done when:** the panel shows "Welcome to Komando", and the profile menu names the komando version ("komando 1.4.0 · 0 targets").

## 2. Create an account or sign in (proposed: Komando Cloud phase 1, nothing built)

**Goal:** one Komando account, so every device you use holds the same servers, or a clear choice to stay on this Mac only.

Komando Cloud stores only what your devices encrypted: it never sees your password, your servers' addresses or anything that opens them. Two secrets unlock your account on a new device: your password and a Secret Key, a long random code made on your first device.

1. When komando answers and nobody is signed in, Komando opens **PageSignIn**, a window of its own: "Sign in to Komando", Email, Password ("Your password never leaves this Mac."), Sign In, Sign In with SSO (journey 32), Create an Account, and the link Use Komando without an account.
2. Use Komando without an account opens Home and works as today, with everything in komando's folder on this Mac. Settings → Account offers Sign In… later (**PageAccount**, journey 27).
3. Create an Account opens **PageSignUp**: "Create a Komando account", with Name, Email, Password and Confirm password. A bar and a word (Too short, Fair, Good, Strong) say how strong the password is, and "Komando can't reset it, so pick one you will remember." Click Create Account. Signing in proves you know the password without sending it (the SRP method 1Password and Termius use).
4. **PageEmergencyKit**: "Save your Emergency Kit", with your Secret Key and Copy. Click Download Emergency Kit to save a PDF to print or keep in a password manager. Tick ☐ I saved my Emergency Kit, then click Continue.
5. Home opens, signed in. This Mac is the account's first device, and the targets on it go up encrypted.
6. On a Mac that joined the account before, Sign In on **PageSignIn** opens Home. A new Mac goes on to journey 3.

**If it goes wrong:**
- A malformed email or an empty password: a danger Banner under the head on **PageSignIn**.
- Create Account stays dimmed until the name and email are filled in, the password has at least 10 characters and both passwords match ("The two passwords don't match."). Cancel goes back to Sign In.
- Closing the window before Continue on **PageEmergencyKit** shows it again at the next start. A lost kit: Download Emergency Kit on **PageAccount** on any device you are signed in on (journey 27).
- Forgot your password: journey 4.
- Komando Cloud cannot be reached: not designed yet; docs/sync.md does not say what happens offline.
- Plan: a Komando Cloud account belongs to the upgrade (sync between devices), which is not built and has no price. Without an account the app stays free and local.

**Done when:** Home opens signed in, the profile menu shows Account… and Team…, and Settings has Account and Team tabs.

## 3. Approve a new Mac or iPhone (proposed: Komando Cloud phase 1, nothing built)

**Goal:** sign in on a new device without typing the Secret Key, by saying yes from a device you already use.

1. On the new Mac, Sign In on **PageSignIn**. It goes to **PageNewDevice**: "Approve this Mac", "For your safety, a new Mac needs a yes from a device you already use.", the devices it asked, and a short code under "Both screens show this code". "Waiting for approval…" with "Expires in 15 minutes".
2. Every device already signed in shows **PageApproveDevice**: "Approve MacBook Air?" and the code under "Check that MacBook Air shows this code". On a Mac that is not in front, a notification comes first; on iPhone, a push.
3. Compare the two codes. If they match, click Approve and confirm with Touch ID (Face ID on iPhone). That device hands your keys to the new one, encrypted only for this request.
4. The new Mac says "MacBook Pro approved this Mac." with "Your servers, connections and secrets are coming over, encrypted." Click Continue: Home opens.

**If it goes wrong:**
- The codes differ, or you did not start this: click Deny. "If the codes differ, deny it: someone else may know your password." Then Change Password… on **PageAccount** (journey 27).
- Denied or expired: the new Mac says "The request was denied on MacBook Pro." or "The request expired." with "Nothing was shared with this Mac." Click Ask Again, or Use the Emergency Kit Instead (journey 4).
- No other device at hand: Use the Emergency Kit Instead on **PageNewDevice** (journey 4). There is no email link: an inbox is not a device you hold.
- Cancel on **PageNewDevice** goes back to Sign In.

**Done when:** the new device shows the same Hosts and Connections as your other devices.

## 4. Get back in: Emergency Kit and a forgotten password (proposed: Komando Cloud phase 1, nothing built)

**Goal:** get into your account when no other device can approve you, and know what nobody, Komando included, can recover.

1. On **PageNewDevice**, click Use the Emergency Kit Instead. **PageRecover** opens: "Use your Emergency Kit".
2. Type the Secret Key from the kit ("It starts with A3; capitals and dashes don't matter.") and your password, then click Sign In. This Mac joins your account without asking another device.
3. Your other devices show that this Mac joined with the Emergency Kit, so a copied kit gets noticed, and **PageAccount** lists the new Mac.
4. Forgot your password: on **PageSignIn**, click the link Forgot your password. It says first that Komando can't reset a password it never sees, then gives three ways out: change it on another device that is still signed in, ask an admin if your company turned recovery on (journey 32), or create a new account (Create an Account).

**If it goes wrong:**
- "That Secret Key and password don't open this account." with "Check both and try again. Komando can't look them up for you." Komando does not say which of the two is wrong.
- The kit alone cannot open the account without the password, and the password alone cannot open it on a new device without the kit or an approving device.
- Cancel on **PageRecover** goes back to **PageNewDevice**.

**Done when:** this Mac is signed in and shows your servers, or you know which way out is left.

## 5. Welcome and your first server

**Goal:** from an empty inventory to one working server in a few minutes.

1. komando answers and the inventory is empty: Home is **PageWelcome**, "Welcome to Komando", with three cards and no other button: Add a Host, Add something else, and Import from `~/.ssh/config`.
2. Click Add a Host. **PageNewHost** opens as a tab: "New Host".
3. Fill in Name (`web-1`, no spaces) and Address (`deploy@10.0.0.4`: the user, `@`, then the server's address; add `:port` only when SSH does not listen on 22).
4. Under Log in with, pick SSH Agent, Saved Key or Password (**PageNewHostStates**). Password stores it encrypted in komando's keychain as `secret:web-1-pass`. Ask each time waits on komando 0.15.0, which adds an ask-at-connect mode.
5. Optional: Groups (comma-separated, such as `production`, which you can then target as `@production`); Reach through a server or VPN, for a server you can only reach through another server or a VPN: add each step with Add a Step… in the order komando goes through them (a VPN first, then servers, for example office, then jump1, then jump2), and move or remove a step with the buttons on its row (**HopList**); Protected, for production.
6. Click Save Host (⌘↩). The buttons give way to a Banner "web-1 is in the inventory." and the connection test: "Testing the connection…", then "Connected" ("Answered in 23 ms"). The test is komando's first connection to the server, so komando saves its host key then; when komando says which (`meta.host_keys_pinned`), the form shows "Host key komando saved for web-1" with the key type, the `SHA256:` fingerprint and Copy (**PageNewHostStates**). Compare it with the fingerprint the server's owner gave you. If it differs, do not use web-1 and tell its owner; after a password login the form also says the password already went to that server, so change it. Removing web-1 keeps the key, so the form shows the command that replaces it once the owner gives the right one (`komando host trust web-1 --reset`, a person at a terminal), with Copy.
7. Click Close: Home is now **PageDashboard**. Or click Open web-1 to open the server as a tab (**PageHostDetail**, journey 9).
8. Later, Add (⌘N) on Hosts opens **PageNewHost** directly. Anywhere else Add (⌘N) and ⌘K → Add… open **PageAdd**, where Host is the first card. Add something else on **PageWelcome** opens **PageAdd** too (journey 6), and Import from `~/.ssh/config` opens ImportSheet (journey 7).

**If it goes wrong:**
- Save Host stays dimmed until the name has no spaces, the address has an `@` and the chosen login is complete.
- The test fails: "Saved, but the test failed: …" with komando's hint. The server is saved anyway. A wrong password or key: Edit Host… (journey 21), then Log in with, where Set a new password replaces it or another tab changes how it logs in. A wrong user or address: the Address field in the same sheet.
- Cancel (or Esc) closes the tab and adds nothing.
- komando does not answer: a danger Banner with Try Again (**PageStates**). When komando's doctor fails, the Banner shows komando's message and, on the next line, its hint, with Try Again under it; a login or host-key failure shows its plain sentence, the next steps and Details, as on every page.
- Saved Key with no key yet: New Key… beside "No saved keys yet" opens **PageNewKey** over the form, the same words as the Keychain's button; back in the form, the new key is chosen.
- Command line: `komando host add` does the same.

**Done when:** web-1 is a row on **PageHosts** and Home shows **PageDashboard**.

## 6. Add a database, cache, storage, cluster, registry, queue or VPN

**Goal:** add anything that is not a server, check that komando reaches it, and open it.

1. Click Add (⌘N) in the Connections header, choose ⌘K → Add…, or click Add something else on **PageWelcome**. **PageAdd** opens as a tab: "What do you want to add?" with eight cards: Server, Database, Cache, Storage, Cluster, Registry, Queue, VPN.
2. Click a card other than Server. **PageNewConnection** opens as a tab with that family already chosen ("Add PostgreSQL"), the cursor in Connection name. The Kind menu lists that family's kinds first and the other families after, so a wrong pick is one menu away.
3. Type a Connection name (`staging-db`, no spaces). Under Connection String paste the address (`postgres://app@db.internal:5432/app`), or switch to Individual Fields. The password has its own field and is stored encrypted as `secret:staging-db-pass`; a kind with no password (SQLite, Memcached, Google Cloud Storage, Pub/Sub) shows none, and S3 and SQS ask for a Secret access key. Options, folded, holds TLS and driver settings.
4. Optional: Groups, Reach through a server or VPN (then add its steps in order, **HopList**), and Protected.
5. A kind with no form of its own (Cisco IPsec, GlobalProtect, IKEv2, and any kind a newer komando adds) gets a form built from what komando says it needs (**PageNewConnectionKind**): the required fields, one choice for each set of alternatives, then More options, folded. A kind whose login opens a browser says so before Save. For a VPN with a form of its own, the form asks only what that VPN needs. WireGuard and OpenVPN: click Choose… and pick its file (`.conf` or `.ovpn`); komando keeps it encrypted in its keychain, so the file can be deleted afterwards. OpenVPN also asks for User, Password and a Check address. Tailscale asks for an Auth key (`tskey-auth-…`). A Check address is a `host:port` that answers only through the VPN, so komando knows the VPN is up. A VPN has no route, has Protected like any target, and its button reads Save VPN.
6. Click Save Connection (⌘↩). The column beside the form shows "staging-db is in the inventory", "Testing the connection…", then "Connected" ("Answered in 12 ms").
7. Click Open staging-db to open it as a tab (journeys 12 to 14), or Close.

**If it goes wrong:**
- Save Connection stays dimmed until the name has no spaces and the string has `://`. Save VPN stays dimmed until the file is chosen (for OpenVPN, also until the check address has a port).
- The test fails: an error Banner with komando's hint. The connection is saved anyway. A wrong password: Edit… (journey 21), then Set a new password (**PageEditConnection**). A wrong host, port, user or database: the address fields in the same sheet.
- Cancel closes the tab and adds nothing.
- Command line: `komando conn add` does the same.

**Done when:** the new target is a row under its family on **PageConnections** (a VPN under the VPNs chip).

## 7. Import what you already have

**Goal:** bring in servers and connections you already keep in other tools, seeing the list before anything is added.

1. On **PageAdd**, under "Or import what you already have", click the source: SSH Config…, .pgpass…, my.cnf…, .env…, kubeconfig…, Docker…, DBeaver…, AWS…, rclone… or FileZilla…. Import from `~/.ssh/config` on **PageWelcome**, the same button on an empty **PageHosts** ("No hosts yet"), and the File menu's Import from SSH Config… open the same sheet.
2. ImportSheet opens ("Import from .pgpass") and shows "Reading .pgpass…" while komando does a dry run, a practice run that adds nothing. Then it lists what it would add.
3. For .env, click Choose a .env File… first; a .env file has no usual place.
4. Optional: Add to group, a group to put every imported entry in (an existing one, or type a new name). komando imports them with `--group`, so ten servers from `~/.ssh/config` arrive as `@web` in one step.
5. Click Import 3 Targets (the button counts them). A Banner "Added 3 targets." lists the names, and Cancel becomes Done.
6. Later, to put more hosts in a group, use Add Hosts to Group… in the group's ⋯ on **PageHosts**: tick the hosts, then Add (`komando group add`). Change Login for Group… in the same menu sets how they all log in (journey 21).

**If it goes wrong:**
- Everything is already in the inventory: "Nothing new to add." names them, and Import stays dimmed.
- Lines komando could not import are listed under the entries, with why.
- Entries from DBeaver arrive without passwords: their rows say "Password missing" with Add Password (journey 18).
- Cancel adds nothing.

**Done when:** the new entries are rows on **PageHosts** and **PageConnections**, and their passwords are in the keychain as `secret:NAME-pass`, never shown.

## 8. Home and findings

**Goal:** see what needs attention and fix it without reading komando's output.

1. **PageDashboard** (Home) has three sections. Needs attention: up to two findings as one sentence each ("web-1 allows root to log in with a password."), what the action does, and one action. Running now: VPNs and forwards, and one line such as "3 background jobs" with View (journey 10). Recent activity: what happened, in the app's names ("Opened a forward to prod-db"), with the Audit Log link (journey 20).
2. A finding has one of seven actions:
   - Fix: komando changes the setting. It asks first on **PageSafetyPrompts**: "Run the fix?", with what changes and the exact command, and Run the Fix.
   - Protect: marks the target protected. It asks "Protect staging-db?" with Protect Connection (Protect Host for a server).
   - Remove: takes out a connection that copies another. It asks "Remove orders-copy?" with Remove Connection.
   - Add Password: opens **PageNewSecret** (journey 18).
   - Add a Host: opens **PageNewHost** (journey 5).
   - View: opens the target's tab.
   - How to Fix: for a change komando cannot make for you, because it needs a file, a value or a decision only you have. It opens **PageHowToFix**: "How to Fix", the finding, komando's own words, the command in `mono`, Copy Command and Close. Copy Command says "Copied" for a moment. It changes nothing.
3. After a fix, a Banner at the top says "Done. web-1 is fixed; the finding clears on the next check."
4. Click View all 4 to open the Findings tab, **PageDoctor**: every finding, then "Passed" with the checks that are fine. Refresh runs the checks now ("Checking your setup…").
5. A finding's longer explanation is its tooltip; VoiceOver reads it as the card's hint.

**If it goes wrong:**
- Cancel on any question changes nothing.
- A protected target: the question adds "It is protected, so komando will run this with --yes."
- komando stops a fix for safety: it asks once in plain words (**PageSafetyPrompts**), never twice for the same thing. Any other error is a danger Banner with komando's message and hint.
- komando does not answer: a danger Banner with Try Again (**PageStates**). When komando's doctor fails, the Banner shows komando's message and, on the next line, its hint, with Try Again under it; a login or host-key failure shows its plain sentence, the next steps and Details, as on every page.
- Viewer role (proposed, journey 34): sees findings, cannot Fix, Protect or Remove.

**Done when:** Needs attention is one card: "Everything looks fine." with Refresh.

## 9. Connect to a server

**Goal:** a shell (a command prompt) on any server in two steps.

1. Press ⌘K (CommandPalette), type the server's name and press Return. Or open **PageHosts**, filter with the chips (All, production, staging, lab, Protected) and click the row: the server opens as a tab, **PageHostDetail**. Double-clicking the row goes straight to its Terminal tab. An address not in the inventory connects from ⌘K too: type `deploy@10.0.0.4` and choose Connect.
2. On **PageHostDetail**, click Open Terminal, the tab's one primary button.
3. The Terminal tab shows **PageTerminalStates**: "Connecting to web-1 through bastion…", where bastion is the server web-1 is reached through (set with Reach through a server or VPN). Cancel stops it.
4. The first time, ssh asks whether to trust the server's identity (its host key, a fingerprint that proves it is the same server next time): type `yes`. If it asks for a password, type it; it is not shown.
5. Work in **PageTerminal**. The ⋯ in its toolbar holds the rest:
   - Split Right (⌘D) puts a second pane on the same server beside this one; Split Down (⇧⌘D) puts it below. Up to four panes. Drag the line between panes to size them; the split you make comes back in the next terminal tab. The × on a pane's head closes only that pane, and asks first while its session runs. (⌘W still closes the whole tab; Close Pane on ⌘W comes with the File menu work.) (The shortcuts are in the Terminal menu; the ⋯ names them in each tooltip.)
   - Broadcast Input (⌥⌘I, with two panes or more) types into every pane at once; the status bar says "Typing into 2 panes" until you turn it off.
   - New Session (⌘T), Files (journey 11), Recipes (journey 17), Reconnect, and Open in Terminal App, which opens the same session in the Mac's Terminal app (not to be confused with Open Terminal, the button on the server's tab).
6. The session ends: "Session ended" under the last output ("Session ended with an error" when it failed; the exit code is in its tooltip), with Reconnect and Close Pane. When it is the only pane, a server's tab says Close Terminal: the session ends and the server goes back to Overview, and the tab stays open. A command tab (⌘K, Open SQL Shell, a VPN login) says Close Tab and closes (**PageCommandTab**).

**If it goes wrong:**
- Login refused, server not answering, or its VPN down: the pane's head says "Could not connect" beside a red dot (**PageTerminalStates**). komando's error and hint stay in full above a bar that says "Could not connect to web-1" (exit 4) or "web-1 did not answer in time" (exit 7), with Reconnect and Close Pane. A wrong password or key: Change… beside Logs in with on Overview, or Edit Host… (journey 21), opens Log in with, where Set a new password replaces it or another tab changes how it logs in. Then check with Test on Overview (journey 10), or bring the VPN up (journey 16), then Reconnect.
- The server's identity changed since last time: komando refuses to connect. Komando checks with komando itself (`komando test web-1`) that this is komando's answer and not something the server printed, then the pane's head says "Identity changed" (**PageTerminalStates**). komando's line shows the old and the new fingerprint, and the bar says "web-1's identity changed since komando last connected". If you rebuilt the server, check the new fingerprint on its console or with its owner, then click Trust New Key… (**PageTrustHostKey**): the sheet warns that it may be someone else's server, shows Before and Now, and stays disabled until you tick "I checked that web-1 shows this new key". It opens a command tab running `komando host trust web-1 --reset`, where komando asks once more; then Reconnect. With host keys strict, a server komando has not met says "Identity not checked" and Trust Key… runs `komando host trust web-1`. A failed action elsewhere shows the same step on its banner.
- A protected server: the first command that changes something still asks first.
- Command line: `komando shell web-1`, in the Terminal app, does the same.
- Viewer role (proposed, journey 34): may connect.

**Done when:** the prompt `deploy@web-1` shows in green and the toolbar's dot is green.

## 10. Check a server, its quick checks and its jobs

**Goal:** see whether a server is healthy, and follow long work that outlives the connection.

1. Open the server (journey 9). **PageHostDetail** opens on Overview. The header says "Server · `deploy@10.0.0.4` · via bastion", with its groups and Open Terminal. Right now shows CPU, Memory and Disk; Disk turns orange with "Low space" above 80%.
2. Quick checks read and change nothing: Facts, Services, Certificates and Disk Usage, then two ready-made recipes (Top Memory and Failed Services). Click one; its output appears below it, in place.
3. "About this server" ("From the connection test.") shows Status, "Connected in 23 ms" or "Not tested yet". Click Test (⇧⌘T) to log in again; it changes nothing. A spinner shows only when the test takes more than a moment, and the check or cross changes in place when the answer comes. The header's ⋯, the row's ⋯, a right-click and the tab hold the same menu (**PageTargetMenus**): Test Connection answers in a Banner ("komando reached web-1 in 23 ms."), Run Recipe › runs a recipe that only reads at once (Choose a Recipe… opens Recipes), and Show SSH Command prints the OpenSSH line in a terminal tab to copy.
4. The Services tab (**PageHostServices**) lists the server's system services with a dot and a word for their state; click one for its status. To restart, stop or start it, tick ☐ Allow changes, click Restart, Stop or Start and check the exact command. A protected server asks through komando (**PageSafetyPrompts**).
5. A job is a long command started with `komando job start`; it keeps running on its server if you disconnect. Home's Running now says "3 background jobs": click View to open **PageJobs** (under More).
6. **PageJobs**: "Long commands keep running on their server if you disconnect." Each job reads as what it does and where ("Nightly backup on backup-1"), with Running, Done, Failed or Unknown. Chips filter them: All, Running, Done, Failed, Unknown. Refresh asks each server again.
7. A job's ⋯, or a right-click on its row (**PageRowMenus**), holds Show Log (its log follows beside the list, "Following the log…"), Run Again… (Start a Job filled in with its server and command), Copy Command (one line that runs the same thing: a command with a line break or a hidden character is copied as `sh -c $'…'` with each of them spelled out), then Stop Job… while it runs and Remove Job… once it ended. Drag the line on the log's left edge to make it wider or narrower (320 to 640); a double-click puts it back, and the width is kept.
8. Start a Job in the Jobs page's header (until the window's header gives the Jobs page its create button, the app shows it at the top of the page) opens **PageStartJob**: pick the server, type the command, check the exact line (`komando job start backup-1 -- ./backup.sh --full`) and click Start Job. The new job is selected with its log beside it. A protected server asks first (**PageSafetyPrompts**). The agent can also start one (journey 19).
9. A server with Docker has a Containers tab (**PageHostContainers**; komando's facts say whether Docker is there, and without it the tab is not shown). Pick a container to see its state, ports, CPU and memory ("Unknown" when Docker sent no reading), and its last 200 log lines under them. Restart, Stop and Start wait for ☐ Allow changes and ask first. Images shows what is stored and which container uses it; the ⋯ holds Free Up Space…, which shows what would go before anything is removed, and Docker Compose… (**PageHostContainersStates**, **PageHostContainersSheets**).

**If it goes wrong:**
- Test fails: Status says why, in komando's words, with its hint.
- Unknown: komando could not ask the server (it did not answer, or left the inventory). Refresh tries again.
- Stop Job… asks first ("Stop this job?") on every server. Remove Job… asks first ("Remove this job?"); it leaves the list and its log on the server stays.
- With no jobs, **PageJobs** says "No background jobs" · "A long command you start as a job shows here, with its log. Start one, or ask the agent (⌘J)." (**PageJobsEmpty**).
- Viewer role (proposed): looks, cannot stop or remove a job; whether a Viewer runs quick checks is not on **PageRoles** yet (journey 34).

**Done when:** Status says "Connected in … ms", and the job you follow reads Done.

## 11. Move files to and from a server

**Goal:** copy files between this Mac and a server or storage, and see each transfer finish.

1. Click Files in the sidebar (⌘4). **PageFiles** opens with the panes you used last. Files in a server's or storage's ⋯ on **PageHosts** or **PageConnections**, in the terminal's ⋯, in ⌘K ("Open Files on web-1…") or on a detail page opens the same place with that target in the right pane.
2. Each pane's head is a picker: choose This Mac, a server or a storage (**PageFilesOptions**). Swap trades the two sides. Under the head, Home, Up (⌘↑) and the breadcrumbs; click the end of the breadcrumbs, or press ⇧⌘G, to type or paste a path. Show hidden files lists `.env` and `.ssh`.
3. Select files: click, ⇧-click, ⌘-click or ⌘A. Then click Copy to web-1 (⌥⌘→) or Copy to This Mac (⌥⌘←), drag them across, or drag them in from Finder. A folder goes whole. Drag a file out to Finder to download it there.
4. Right-click for more: Download to…, Edit…, Rename…, Move…, Permissions…, Copy Paths, New Folder… and Delete…. On storage, Rename… and New Folder… are dimmed with "komando can't do this yet".
5. Transfers stack in the queue under the panes, one row each: which way, the file, "to web-1", a progress bar and "30.9 of 48.2 MB · 4 s left" (**PageFilesTransfers**). Cancel stops one; Retry starts it again; a finished one says Done with Show in Finder or Show on web-1. The queue folds to one line, and keeps running when you go to another place. The sidebar's Files shows how many run.
6. Tick Only copy changed files to send only what changed in a folder (`komando sync`). Copy to a Group… sends this Mac's files to every server in a group (`@web`).

**If it goes wrong:**
- A protected server: any change on it (a copy onto it, Rename, Move, Permissions, New Folder, Delete) asks "This target is protected" with Run Anyway (**PageSafetyPrompts**), once per action. Cancel leaves the row "Not uploaded".
- Delete always asks first, naming the items, with "This can't be undone."
- A download onto a file already on this Mac asks "Replace app.log on this Mac?" with Replace.
- A folder that cannot be listed, connecting, an empty folder and a folder cut off at 1,000 entries (Load More) show inside that pane only (**PageFilesStates**).
- A failed transfer says why, in red, in its own row, with Retry.
- Quitting while transfers run asks first.
- Command line: `komando fs list`, `komando upload`, `komando download`, `komando sync` and `komando storage` do the same.
- Viewer role (proposed): uploads are changes and are not allowed; downloads are not on **PageRoles** yet (journey 34).

**Done when:** the file shows in the other pane, its row says Done, and the transfer is in the audit log.

## 11b. Copy from one server to another

**Goal:** copy a file or folder from one server (or storage) to another, without saving it yourself in between.

1. On **PageFiles**, set the left pane to web-1 and the right pane to web-2 with the pickers.
2. Select the files on web-1 and click Copy to web-2 (⌥⌘→), or drag them across.
3. The first time, Komando explains: "Copy through this Mac?" komando can't copy from web-1 straight to web-2 yet, so Komando downloads to this Mac, uploads to web-2, then deletes the copy here (**PageFilesTransfers**). Click Copy. Tick Don't explain again to skip this next time.
4. Before it starts, Komando checks that this Mac has room for the copy, plus 1 GB.
5. The queue shows one row, "web-1 → web-2", with the note "Goes through this Mac": first "1/2 Downloading from web-1", then "2/2 Uploading to web-2". When it is done it says "The copy on this Mac is deleted".
6. The same works between a server and a storage, or two storage conns (S3 to SFTP, for example).

**If it goes wrong:**
- Not enough room: "Not enough space on this Mac" names the size needed and the space free, and nothing starts.
- web-2 is protected: it asks first, once, before step 1.
- A step fails: the row names the step ("Step 2: web-2 has no space left in /srv") and offers Retry, which starts again from web-1. The copy on this Mac is deleted either way.
- The audit log has two entries for the copy: the download from web-1 and the upload to web-2.
- Command line: `komando download web-1 PATH --to DIR` and then `komando upload web-2 DIR/FILE PATH`. With komando 0.15.0 the app runs `komando cp web-1:PATH web-2:PATH`, which streams through this Mac and saves nothing; the note then says "Streams through this Mac, nothing saved".

**Done when:** the file shows in web-2's pane and its row says Done.

## 12. Query a database, then change data on purpose

**Goal:** read production data with no chance of changing it by accident, and change it only when you mean to.

1. On **PageConnections**, click the Databases chip, then prod-db. It opens as a tab on Overview, **PageConnectionDetail**: quick checks Info, Sizes, Activity and Locks, and "About this connection" with Test. Click the Query tab.
2. **PageDatabase**: tables at the side (Filter tables finds one; ↻ at the foot is Refresh the tables, after you add one), the query editor, and the results. Drag the lines between them to size them; every database opens the way you left them. ☐ Allow changes is off, so the database refuses any change: "Allow changes is off: the database refuses any change."
3. Write a query and click Run (⌘↩). The rows appear, and the status bar says "3 rows · 5 columns" and how long it took. Click a column's header to sort the rows by it (again to turn the order around); drag a column's edge to widen it, and double-click the edge to fit it again (**DataTable**).
4. The ⋯ holds Dry Run (runs a change, shows what it would do, then undoes it), History (the last 30 queries here; picking one puts it back in the editor without running it), Export Results as CSV… (a value a spreadsheet would run as a formula gets a ' in front, so it stays text), Open SQL Shell (a SQL prompt in a tab of its own, "prod-db · SQL", **PageCommandTab**) and Open in Terminal App.
5. To change data on purpose, tick ☐ Allow changes, write the change (`UPDATE …`) and click Run. If you run a change with the box off, komando stops it and asks "This changes data", with Allow Writes, which runs that one query again with `--write`; the box stays off, so the next change asks again (**PageSafetyPrompts**).
6. On protected prod-db, a change with the box ticked asks "This target is protected", with the exact command and Run Anyway (**PageSafetyPrompts**).
7. The results say "3 rows changed." and the status bar says Committed (**PageDatabaseStates**). With Dry Run on, the status bar says Rolled back and nothing is kept. Untick ☐ Allow changes when you are done.

**If it goes wrong:**
- Cancel on either question runs nothing.
- An error is a danger Banner above the results, in komando's words with its hint. While a query runs, Run becomes Stop; a stopped query says "Stopped.". (**PageDatabaseStates** draws these moments.)
- prod-db's password is missing: its row says "Password missing" with Add Password (journey 18).
- Command line: `komando db query prod-db 'SQL'` does the same.
- Viewer role (proposed, journey 34): reads; ☐ Allow changes is not available.

**Done when:** the rows you asked for show, or a change you meant says "3 rows changed." and Committed.

## 13. Look inside a cache

**Goal:** find a key in a cache (a fast store such as Redis), read it, and change it only on purpose.

1. On **PageConnections**, click the Caches chip, then sessions. It opens on Overview (**PageConnectionDetail**, with the Info quick check). Click the Keys tab.
2. **PageCache**: type a pattern (`session:*`). Keys appear with their type and TTL, the time to live before the cache forgets the key ("none" when it never expires). The status bar says "48,201 keys in db 0 · 1,000 scanned"; Scan More reads further.
3. Click a key: its fields show as a table; a JSON value opens below in color. Click Field or Value to sort a hash; drag a column's edge to widen it (**DataTable**).
4. ☐ Allow changes is off: "Allow changes is off: the cache stays as it is." Delete is dimmed, and so is Change Expiry… in the key's ⋯; their tooltip says "Turn on Allow changes first". Drag the line between the keys and the value to size the list; every cache opens with that width.
5. Tick ☐ Allow changes. Delete asks first (AlertDialog "Delete session:7f3a9c21?", Delete Key). Change Expiry… asks for the seconds ("Change when session:7f3a9c21 expires?", Change Expiry). After a delete, a Banner says "Deleted session:7f3a9c21."
6. The key's ⋯ also holds Add Field… (a hash only; dimmed like Change Expiry… until the box is ticked: it asks for a field and a value, then shows the exact command and runs it only after Add Field) and Copy Key Name. Right-click a key for Copy Key Name, Copy Value and Delete Key… (**PageRowMenus**); a copy says "Copied …" in the key list's status bar ("Copied the first part of …" when komando read only part of a big value). The key list's ⋯ holds Refresh and Show One Type, which keeps only the scanned keys of one type.

**If it goes wrong:**
- Cancel changes nothing. A deleted key does not come back.
- A protected cache: the one question in step 5 is all komando asks.
- Command line: `komando cache keys` and `komando cache get` do the same.
- Viewer role (proposed): reads keys; cannot tick ☐ Allow changes.

**Done when:** the key's value shows, or a change you meant is confirmed by its Banner.

## 14. Look at storage, a cluster, a registry or a queue

**Goal:** check a storage bucket, a cluster (Kubernetes or Docker Swarm), a container registry or a message queue (Kafka, RabbitMQ, NATS JetStream, Amazon SQS, Google Pub/Sub) you added, without the command line.

1. On **PageConnections**, click the Storage, Clusters, Registries or Queues chip, then the row. It opens as a tab, **PageConnectionDetail** (a queue: **PageQueue**): the kind and address in the header ("Kubernetes · `k8s.internal:6443`"), and Overview as its only tab. The header has its one primary (**PageTargetMenus**): Browse Files for storage, Show Workloads for a cluster, Show Images for a registry, Peek Messages for a queue. Show Images and Show Workloads run that quick check in place; Peek Messages lists the queues and stops, so the person picks one and clicks Peek under the sentence that says what a look does. The same items are in its ⋯.
2. Quick checks read and change nothing, and show their output in place: Files for storage, which opens the files on the Files page; Status, Pods, Deployments and Events for a cluster; Repositories for a registry. A queue has a list button and Peek (**PageQueue**): on Kafka, Topics lists every topic with how many messages it keeps, and Peek, after you pick a topic, shows the newest five and leaves every one where it is. NATS says Streams and works the same way. RabbitMQ and SQS say Queues, and Pub/Sub says Subscriptions (`komando queue groups`); there Peek shows the next messages (SQS: a sample) and the sentence says what a look counts as: RabbitMQ marks them as delivered again, SQS counts a receive, Pub/Sub with a dead-letter topic counts a delivery.
3. In the Pods and Deployments answers, click a name: the object opens in its own tab (**PageClusterObject**) with its status, conditions, labels and recent events, the warnings marked. A pod's Logs tab (**PageClusterLogs**) shows its lines with the time and container, and says when komando cut them short.
4. "About this connection" ("From the connection test.") shows Status. Click Test (⇧⌘T) to check komando reaches it.
5. Changing something here (uploading to a bucket, restarting a deployment, sending a message to a queue) has no screen yet. Use ⌘K → Run a Command… (journey 37).

**If it goes wrong:**
- Test fails: Status says why, with komando's hint. Fix it with Edit… (journey 21).

**Done when:** the quick check's output shows and Status says it is connected.

## 15. Forward a port

**Goal:** reach a database or a web page on a server from this Mac, through a forward komando keeps open. On screen it is always "a forward"; only komando's command says `tunnel`.

1. Open **PagePortForwarding**. With nothing open it says "No forwards open". Click New Forward in the header.
2. The sheet: pick Through (a host, database or cache). For a server, pick Local, Remote or SOCKS Proxy and type the Rule; its help changes with the tab. For a database or cache it asks only for a Local port; leave it empty and komando picks a free one.
3. A line says what Start will do: "Opens `localhost:9090` on this Mac, connected to port 9090 on web-1." Click Start.
4. The sheet says "Forward started" and Cancel becomes Done. The forward is a row (`localhost:15432` → prod-db · Database · "started 12 minutes ago"), it shows on Home under Running now, and the menu bar icon fills (**PageMenuBar**).
5. Copy Address in the row's ⋯ copies `localhost:15432` as one clean line to paste into your database tool, and "Copied localhost:15432" shows above the page. For a web port, Open in Browser opens it. Restart fixes a stuck forward, and Save as Forward… keeps its rule as a saved forward with a switch (**PageForwardMenus**). Save as Forward and Edit Forward only save: their line starts "Save keeps the rule and starts nothing." and then says what starting it opens. A saved forward's ⋯ has Start, Edit…, Copy Address and Remove Saved Forward…, which asks first.
6. Stop in the row's ⋯ asks first ("Stop the forward to prod-db?"). The menu bar also has it: `localhost:15432 → prod-db` › Stop Forward.

**If it goes wrong:**
- Start fails: an error Banner "The forward did not start." with komando's own words.
- A saved forward's switch or Start when komando did not run (Komando is locked, or komando could not be launched): the switch turns back and the Banner says "komando did not run. Unlock Komando, or check komando in Settings, then try again."
- A forward that dies shows Stopped in red. When the window is not in front, a notification says "Forward stopped" · "localhost:15432 → prod-db is no longer open." (Notifications, journey 25).
- Command line: `komando tunnel start NAME` does the same.
- Viewer role (proposed): **PageRoles** does not say yet whether a Viewer may open a forward (see Cards still to draw).

**Done when:** your database tool connects to `localhost:15432`.

## 16. Bring a VPN up and down

**Goal:** reach targets behind a VPN without thinking about it, and know when it drops.

1. Usually nothing: when a target needs a VPN, komando brings it up by itself. It shows on Home under Running now and in the menu bar.
2. To add a VPN: Add (⌘N) → VPN on **PageAdd** opens **PageNewConnection** with the VPN family chosen (journey 6, step 5).
3. To bring it up by hand: on **PageConnections**, click the VPNs chip; a VPN that is down reads "Down" with Connect. Or click its row: the VPN opens as a tab (**PageConnectionDetail**) with Connect and the Details quick check.
4. A VPN that asks for a login (OpenVPN client-vpn, for a one-time code) opens `komando vpn up client-vpn` in a tab of its own titled client-vpn, where komando asks in its own words: "Password for ana on VPN client-vpn (with the PIN or one-time code, if it wants one): " (**PageCommandTab**). What you type is not shown. When it is up the session ends with "Session ended · exit 0", and Close Tab closes the tab.
5. The row reads "Up since 2 hours ago" with a green dot. Disconnect is in the row's ⋯, on its tab, and in the menu bar ("VPN office" › Disconnect).

**If it goes wrong:**
- The VPN drops while the window is not in front: a notification says "VPN disconnected" · "office is down. komando brings it up again when a target needs it." Notify me when a forward or VPN stops in Settings turns it off (journey 23).
- komando cannot bring a VPN up by itself (its login is needed, or it is down): not designed yet. Click Connect by hand.
- To change a VPN's server, user, password, check address or groups: Edit… in its row's ⋯ (**PageEditVPN**, journey 21). Each saved secret shows as "Saved (secret:…)" with an empty field to replace it. WireGuard and OpenVPN keep their file: to use another file, remove the VPN and add it again (**PageEditVPNStates**).

**Done when:** the row reads "Up" and the targets behind it connect.

## 17. Run, create and remove recipes

**Goal:** run a saved command on one server or a whole group, see each server's answer, and keep your own recipes tidy.

1. Open **PageRecipes**. Chips filter the list: All, Saved, Ready-made. Drag the line at the list's right edge to make it wider (224 to 400); a double-click puts it back, and the width is kept. Click a recipe: its name, a pill ("Changes the server" or "Read-only", and "sudo" when it uses sudo), and its command with blanks (`{{service}}`).
2. Fill each blank, pick where it runs under Run on (a server, or a group such as `@production`), then click Run on @production (⌘↩).
3. If a member is protected and the recipe changes the server, komando asks first: "This target is protected", with the exact command and Run Anyway (**PageSafetyPrompts**). A recipe marked Only reads does not ask.
4. The results open as a tab, **PageRunResults** ("restart-nginx on @production"): "3 of 4 succeeded · 1 failed · 2 minutes ago", then each server with Done or Failed, its output, and for a failure "exit 127 · 40 ms". No server is skipped: komando asks before it starts, so the recipe runs on every member or on none. Run Again runs it again.
5. To save your own, click New Recipe in the header. **PageRecipeEditor**: Name, What it does, and Command, with `{{name}}` for a blank and `{{name=default}}` for one with a default (Return adds a line, ⌘Return saves). Only reads starts off, so a new recipe counts as changing the server until you turn it on. Runs with sudo uses the server's sudo password. Click Save Recipe.
6. The ⋯ beside a recipe's name holds Duplicate… for any recipe (ready-made ones are copied, never edited), and for your own Edit… and Remove Recipe…. A right-click on a recipe in the list holds Run On (pick a server: a read-only recipe runs there at once; one that changes the server, or has a blank with no default, opens with that server picked, so you see its command before you click Run), Edit…, Duplicate…, Copy Command (the command with its blanks) and Remove Recipe… (**PageRowMenus**). From a host's or a group's ⋯ on **PageHosts**, Run Recipe › Choose a Recipe… opens Recipes with that host or `@group` already picked under Run on. It stays picked for whichever recipe you then open, until you run or pick another host.
7. Remove Recipe… asks first (AlertDialog "Remove the recipe restart-nginx?" · "komando forgets it. Nothing on your servers changes.", Remove), then komando forgets the recipe.

**If it goes wrong:**
- Cancel at the protected question stops the whole run: nothing runs anywhere, and the tab says "Not run on @production: you chose Cancel." Run Again asks again.
- A failed server shows its output and error under its name; the others still finish.
- Saving a name that exists asks before replacing it.
- Command line: `komando recipe run NAME @GROUP` does the same.
- Viewer role (proposed): cannot run a recipe that changes the server; Read-only recipes are not on **PageRoles** yet (journey 34).

**Done when:** every server in the run says Done.

## 18. Keychain and a missing password

**Goal:** give komando the passwords and keys it needs, without ever seeing a value again.

1. komando cannot connect to prod-db because its password is missing. Each place that says so has Add Password: Home and the Findings tab ("prod-db's password is missing from the keychain.", **PageDashboard**, **PageDoctor**), prod-db's row on Connections ("Password missing", **PageStates**), and the top of the Keychain under More (**PageKeychain**).
2. **PageNewSecret** opens with the name filled in: "prod-db looks for it as `secret:prod-db-pass`." Type the password in Value. Under the fields: "After you save, the finding on prod-db clears on the next check."
3. Click Save Secret. A Banner says "secret:prod-db-pass is in the keychain." The value is stored encrypted and stays hidden until the person chooses Show on Keychain, where komando asks first.
4. **PageKeychain** lists secrets and SSH keys, one line each, with what uses them. New Secret in the header adds one. Right-click a secret for Copy Reference (`secret:NAME`, to paste in a form) and Replace Value…, which opens **PageNewSecret** and says "A secret with this name exists. Saving replaces its value."
5. Right-click an SSH key for Copy Public Key (the line to add to `~/.ssh/authorized_keys` on a new server) or Copy Fingerprint (to compare with what a server shows).
6. New Key… makes a key or imports a key file (**PageNewKey**). A key's ⋯ (**PageKeychainMenus**) holds Put on a Host… (**PageKeyDeploy**: komando adds the public key to the server's list of allowed keys, `~/.ssh/authorized_keys`, and the server logs in with it from now on), Revoke from a Host… (**PageKeyRevoke**: komando counts the lines that hold it first), Rename… (**PageKeychainRename**) and Remove… (**PageKeychainRemove**).
7. A secret's ⋯ also holds Check Value… (**PageSecretCheck**: is the saved password the right one, without showing either), Rename… and Copy to New Name… (**PageKeychainRename**), and Remove… (**PageKeychainRemove**: type the name, as komando asks in Terminal). When komando's keychain already opens with a passphrase, Change Passphrase… beside the Secrets title (**PageVaultPassphrase**) explains what changes, then opens a Terminal tab where komando asks for the new passphrase itself.

**If it goes wrong:**
- Save Secret stays dimmed until both fields have text. Cancel saves nothing.
- komando refuses to remove a secret or a key that a target still uses; the Remove sheet says which one and offers no button.
- Revoking the key komando logs in with would lock you out: the Revoke sheet says so in komando's words and asks you to type the key's name.
- Command line: `komando secret set NAME` does the same.

**Done when:** the finding is gone from Home and prod-db's row shows its address again.

## 19. Ask the agent

**Goal:** describe a problem in words and let komando's agent (an AI assistant that runs komando for you) find it and fix it, safely.

1. Press ⌘J, click the chat bubble button in any panel header, or choose Go → Ask the Agent. The agent drawer opens on the right: **PageAgentStart**, with one line on what it does, "Try asking" and four questions, ☐ Allow changes off, and "Runs as you, with komando's safety checks. Every command it runs goes to the audit log."
2. The first time, the drawer says "Add your Anthropic API key to start." Click Settings…: Settings opens on its Agent tab (**PageSettings**). Paste your key and click Save; Get a key at console.anthropic.com opens the page that makes one. The agent runs on your own Anthropic account and is billed there.
3. Click a question, or type your own and press Return (Shift-Return adds a line, @ adds a target or group). What is in front of you comes along: over a terminal, its command (**PageAgentDrawer**); over a target's tab, that target. The agent always knows komando's findings, so to ask about one, name it.
4. The agent works in visible commands, each a ToolCall row with the exact command, how it ended and its output, and explains what it found in plain words. Stop, beside "Working…", ends its turn (⌘. does the same): a command still running is stopped, and a change still waiting for your answer is not run. The New conversation button in the drawer's head (**PageAgentDrawer**) starts over.
5. To let it change things, tick ☐ Allow changes in the composer; it then says "Each change asks first". Each change komando would stop for safety becomes an ApprovalCard: the risk ("prod-db is protected"), why, the exact command, Don't Run and Allow Once. The card fades in and the conversation scrolls to it; if you had scrolled up to read, it stays put and a "1 approval waiting ↓" chip at the bottom takes you there. For its first 300 ms the card ignores clicks, so a click meant for what was there before can't press Allow Once (**ApprovalCard**).
6. Allow Once runs that one command. On a protected target komando then asks once more in its own window (**PageKomandoConfirm**, to draw).

**If it goes wrong:**
- Don't Run: the row says Denied and the agent goes on without it.
- komando refuses a step for an AI agent (the agent tried to send a saved password or key to a new place, for example by changing a connection's host, or to read or write a file or folder that can hold passwords or keys): the row says Not run and opens with a plain sentence, for example "komando did not let the agent send a saved password or key to a new place; if you want this change, make it yourself.", then "komando said:" and komando's own words. No Allow Once is offered, and the agent does not try again. The iPhone and iPad say the same.
- A command fails: its ToolCall shows the error; the agent never claims a result a command did not show.
- Remove Key in Settings → Agent takes the key away; the drawer asks for one again.
- The agent runs on your own Anthropic key and is free in the app; it has no command-line twin. Built-in AI, without a key of your own, is part of the upgrade (**PageUpgrade**), not built.
- Viewer role (proposed): asks; ☐ Allow changes is not available.

**Done when:** the agent's answer ends in plain words, and every command it ran is in the audit log as "agent" (journey 20).

## 20. See who did what: the Audit Log

**Goal:** see every change komando made and every attempt it blocked, and check that nobody edited the record.

1. Open Audit Log under More (**PageAuditLog**), or click Audit Log under Recent activity on Home. Newest first: Time, Who, Command, Targets and Result (Done, Failed, or Blocked when komando stopped it for safety).
2. Chips filter it: All, Changes, Failed, Agent. The Last 200 menu shows 100, 200, 1,000 or 5,000 entries.
3. Click a row: beside it (drag the line on its left edge for 280 to 480; a double-click puts it back), the command as a line komando takes (the record keeps no flags), who ran it, the targets, "Change allowed by", and the exit code. A row the agent ran has Copy Command, and Open Conversation (opens the agent drawer) while the current conversation still holds that command.
4. Right-click a row for Copy Command, Show Target (opens the target's tab) and Show Only This Target, which adds a chip with its name after the filters; click the chip to see every entry again (**PageRowMenus**).
5. Click ⋯ → Verify the Record…: a sheet runs komando's check ("Check that nobody edited the record").

**If it goes wrong:**
- Verify finds a change: Home shows the finding "The audit log was changed outside komando." with How to Fix (journey 8).
- The log lives on this Mac only, so it shows no teammates (until journey 33).
- Command line: `komando audit` and `komando audit verify` do the same.

**Done when:** the entry you looked for is on screen, and Verify says the record is intact.

## 21. Edit, protect or remove a target

**Goal:** change, protect or take out a server or connection without the command line, including how it logs in.

**Built so far (2026-11-14):** steps 2, 3, 5, 7, 8 and 9 for a server (Edit Host). Still to build: Change… on Overview's Logs in with (S7), the connection and VPN sheets of step 4 (S3, S4; until then they change the name, groups, route and protection), and Change Login for Group in step 6 (S6). On iPhone and iPad a server will show a read-only Logs in with row (planned, **PageiPad**); editing stays on the Mac.

1. Right-click a row on **PageHosts** or **PageConnections**, or a target's tab, or use the row's ⋯: Edit Host… for a server, Edit… for a connection or a VPN. On a server's Overview, Change… beside Logs in with opens the same sheet at Log in with.
2. **PageEditTarget** ("Edit web-2") has the sections of New Host, filled in: Name (komando renames it everywhere it is used, with `komando host rename`), Address, Log in with, Reach through a server or VPN, Groups, Protected, and More (Sudo password, Tags, Labels, Env and Notes), folded. Address takes `user@address`, with `:port` when SSH does not listen on 22, as on New Host.
3. Log in with shows how web-2 logs in today, with that tab chosen: SSH Agent, Saved Key or Password (**PageEditTargetStates**). A saved password is never shown: "Password saved (secret:web-2-pass)" with an empty Set a new password field; empty keeps it. Another tab switches how it logs in, and the old password stays in the keychain. Ask each time is not offered until komando 0.15.0 can ask at connect. A new password never overwrites the saved one: it is saved as a new secret (`secret:web-2-pass-2`), and the old one stays in the keychain until you remove it on Keychain. When other servers share the old one, the help names them. A key file set in the terminal shows as "Key file: ~/.ssh/… (set in the terminal)".
4. A connection's sheet (**PageEditConnection**) has the sections of New Connection: the address as fields, the password or secret access key, Options, Groups, the route and Protected; a kind with no password has no password field (**PageEditConnectionStates**). The route shows as a **HopList**, one row per step in order (`--via office,jump1,jump2`), each with Move Up, Move Down and Remove, then Add a Step…. Removing the last step with the switch on sends nothing new. Turning Reach through off on a route of two or more steps asks first: "Turn off web-2's route?" with Turn Off Route and Keep Route (**PageEditTargetStates**); Keep Route changes nothing. A VPN's sheet (**PageEditVPN**) has the fields its New form asked for, with Advanced folded.
5. Click Save. It stays dimmed until something changed, and only what changed is sent; a cleared field is removed (`--unset`). A new password goes to the keychain first, never on the command line. A Banner says "Saved web-2."; a renamed target's open tab reopens under its new name.
6. To change how a whole group logs in, use Change Login for Group… in the group's ⋯ on **PageHosts** (**PageEditGroupLogin**). It lists every member with how it logs in today ("Mixed" when they differ), takes one Log in with, runs a dry run first ("3 servers will change."), and changes them with one command; protected members ask once for all.
7. To protect a target, turn on Protected here; Protect on a Home finding does the same (journey 8).
8. To take a target out, click Remove… at the left of the sheet, or Remove Host… (Remove… for a connection) in the row's menu. AlertDialog: "Remove web-2 from the inventory?" · "komando forgets it and the secrets stay in the keychain. The server itself is not touched." For a connection it names the kind ("The database itself is not touched.").
9. A Banner says "web-2 is no longer in the inventory." and an open tab of it closes.

**If it goes wrong:**
- Saving any change to a protected target, turning Protected off included, asks "This target is protected" with the exact command and Run Anyway (**PageEditTargetStates**, **PageSafetyPrompts**), before anything is stored when komando's dry run foresees the stop (`meta.would_need`); Cancel then saves nothing and stores nothing. When only the real run stops, the new password is stored already, and Cancel takes it back after you say yes ("Remove secret:web-2-pass again?"). The question always names the one flag its yes adds and shows every flag the run will carry. Removing one adds "It is protected, so komando will run this with --yes."
- The save fails: komando's message shows in the sheet, and the password you typed stays in its field so you can try again. A password this save stored is removed again; komando asks first ("Remove secret:web-2-pass again?", Remove Secret runs `komando secret rm --allow-dangerous -- web-2-pass`). Cancel there leaves it, and the sheet says it is still in the keychain.
- WireGuard and OpenVPN cannot take a new file in Edit: remove the VPN and add it again.
- Cancel saves nothing and removes nothing.
- Remove has no undo. To bring a target back, add it again (journeys 5 and 6); its password is still in the keychain.
- Viewer and Member roles (proposed, journeys 34 and 29): a Viewer cannot edit or remove; a Member can add, edit and remove targets.
- Command line: `komando host edit`, `conn edit`, `vpn edit` and `host rename` do the same; `komando host edit @web` changes a group.

**Done when:** the row shows the new details, Logs in with on Overview says the new login, or the row is gone from the list.

## 22. Free, and what an upgrade will add

**Goal:** know that everything on the Mac is free, and see what an upgrade will add later.

1. Komando is free, with no trial, like the komando command line: every place and every action works from the first run. Nothing shows a plan, a countdown or a lock.
2. Click the profile row at the foot of the sidebar. The profile menu says "Free · everything on this Mac". Click What's Coming…. (Until the sidebar change lands, the Mac menu item still reads Upgrade…; Q-107.)
3. The What's Coming sheet, **PageUpgrade**, says "Everything on this Mac is free, like the komando command line." It lists four, each marked Coming: Sync between devices, Teams, Built-in AI, Approve from your phone.
4. "An upgrade will add these services, which need a server. Nothing to buy yet: Komando says so here when it is ready." Click Close, or press Esc.

**If it goes wrong:**
- Nothing here can fail: the sheet only informs, and no screen depends on a plan.
- On iPhone the same: the phone app is free and its Settings have no license (journey 36).

**Done when:** the sheet is closed and nothing in the app has changed.

## 23. Settings, appearance and the profile menu

**Goal:** find where komando is, change how Komando looks and what it tells you, and keep the agent's key.

1. Click the profile row at the foot of the sidebar (your initial, your first name, "Local · on this Mac"). The profile menu opens: your name, "Free · everything on this Mac", "komando 1.4.0 · 21 targets", Appearance (System, Light, Dark), What's Coming… (**PageUpgrade**, journey 22) and Settings…. Signed in to Komando Cloud (proposed), it also has Account… and Team….
2. Click Settings…, or press ⌘,. **PageSettings** opens in its own window with the tabs General and Agent (signed in to Komando Cloud, proposed: General, Agent, Account and Team).
3. General: komando's path with "version 1.4.0" under it, Choose… and Find Automatically; Appearance (System, Light, Dark, the same as in the profile menu); Show Komando in the menu bar; Notify me when a forward or VPN stops.
4. Agent: the Anthropic API key ("sk-ant-…", or "Saved in the keychain"), Save and Remove Key, and the Model, "Claude Opus 5.5".

**If it goes wrong:**
- The profile menu says "komando is not answering": use Find Automatically or Choose… (journey 26).
- The first notification asks macOS for permission. If you said no, turn notifications on for Komando in System Settings.

**Done when:** the profile menu shows the komando version and the appearance you picked.

## 24. Menus, shortcuts and help

**Goal:** reach every place and action from the Mac's menus or the keyboard, and know where help is.

**PageAppMenus** draws every menu below, with its shortcuts.

1. Komando menu (**PageAppMenus**): About Komando, Settings… (⌘,, **PageSettings**), then Hide Komando, Hide Others, Show All and Quit Komando (⌘Q).
2. File menu (**PageAppMenus**): Add… (⌘N, **PageAdd**; on Hosts it opens **PageNewHost**), New Forward…, New Secret…, Import from SSH Config…, and Close (⌘W), which closes the tab in front.
3. Go menu (**PageAppMenus**): Search… (⌘K), Ask the Agent (⌘J), Reload (⌘R), the six places (⌘1 to ⌘6), then Jobs (⌥⌘1), Keychain (⌥⌘2) and Audit Log (⌥⌘3), Next Tab and Previous Tab (⌃⇥, ⌃⇧⇥), then All Findings (**PageDoctor**). View holds Hide Sidebar (⌃⌘S).
4. Terminal menu (**PageAppMenus**), while a terminal is in front: New Session (⌘T), Split Right (⌘D), Split Down (⇧⌘D), Broadcast Input (⌥⌘I; Stop Broadcasting while on), Open in Terminal App.
5. Help menu (**PageAppMenus**): Komando Help, Report a Problem, and The komando Command Line, each in the browser.
6. A page's own shortcuts are in its buttons' tooltips: Run (⌘↩), Test (⇧⌘T), and on Files Up one folder (⌘↑) and the copy buttons (⌥⌘→, ⌥⌘←).

**If it goes wrong:**
- A Terminal menu item is dimmed when no terminal is in front; Broadcast Input is dimmed with only one pane.

**Done when:** you reach a place or action without the mouse.

## 25. The menu bar and notifications

**Goal:** see what is open and whether anything is wrong, and jump back in, without the window.

1. Closing the window leaves Komando running in the menu bar (**PageMenuBar**). The icon is an outline terminal, filled while a VPN or a forward is up.
2. The first item says "Everything looks fine" or "2 things need attention" and opens Home (journey 8).
3. Running: each VPN › Disconnect (journey 16) and each forward › Copy Local Address and Stop Forward (journey 15). With nothing up it says "Nothing is running".
4. Recent: up to five targets you opened last. A server opens its terminal; anything else opens its tab.
5. Search… opens ⌘K, Open Komando shows the window, and Quit Komando (⌘Q) quits.
6. While the window is not in front, macOS notifications (Notifications) say when a forward stops ("Forward stopped"), or a VPN drops ("VPN disconnected").

**If it goes wrong:**
- With Show Komando in the menu bar off (journey 23) there is no icon, and closing the window quits Komando.
- The menu bar and notifications have no command-line twin.

**Done when:** you can tell from the menu bar alone whether anything is open or wrong.

## 26. Keep komando up to date

**Goal:** Komando keeps working after komando moves or a new version comes out.

1. See which komando and which version: the profile menu ("komando 1.4.0 · 21 targets") or Settings → General (**PageSettings**: its path, and "version 1.4.0").
2. komando moved or was reinstalled: pages say "komando did not answer" with Try Again (**PageStates**). In Settings → General, click Find Automatically, or Choose… to pick the program. If none is found, **PageInstall** shows the install command (journey 1).
3. To update, there is no button yet. Press ⌘K and choose Run a Command…; the field asks "Type a komando command, for example status". Type `update` and press Return (`update --dry-run` only says whether a new version is out).
4. When the update finishes, press ⌘R (Reload). The profile menu shows the new version.

**If it goes wrong:**
- komando sits in a folder only an administrator may change (`/usr/local/bin`): its hint says to run `sudo komando update`. Run it in the Terminal app and type your Mac password there.
- A komando that came inside Komando.app should not update itself; how it is updated is not designed yet (see Cards still to draw).

**Done when:** the profile menu shows the new version and pages load again.

## 27. Your account and devices (proposed: Komando Cloud phase 1, nothing built)

**Goal:** see who is signed in and which devices hold your account, keep your Emergency Kit, and take a lost device off.

1. Click Account… in the profile menu, or the Account tab in Settings. **PageAccount** shows your name, email, and the organization and role ("Acme · Owner") or "Personal account".
2. Password: Change Password…; "It never leaves your devices, so Komando can't reset it for you."
3. Secret Key: "Saved on this Mac". Download Emergency Kit saves a new kit; the key itself is never shown here.
4. Devices: one row each ("This Mac · now", "Komando for iPhone · 20 minutes ago"). To add one, sign in to Komando on it and approve it from one of these (journey 3).
5. A device's ⋯ → Remove Device… asks "Remove iPhone 16 from your account?". Remove gives your vaults new keys that only the devices that stay can open. A Banner says "iPhone 16 is removed."
6. Sign Out… asks "Sign out of Komando?": your servers, connections and secrets leave this Mac until you sign in again, and stay in your account and on your other devices.

**If it goes wrong:**
- A lost device could still use the passwords it already opened: "If it was lost, also change the passwords it could open."
- Delete Account… asks first and cannot be undone; this Mac keeps its own copy of your servers. While you are an organization's only Owner it is dimmed: "Acme needs another owner before you can delete your account."
- Signed out, the tab says "Not signed in" with Sign In… and Create an Account….
- Viewer role: roles do not limit this tab; everyone manages their own devices.

**Done when:** the devices list shows only devices you hold, and you have a saved Emergency Kit.

## 28. Create an organization and invite people (proposed: Komando Cloud phase 2, nothing built)

**Goal:** share servers with a team, so that nobody, Komando Cloud included, can slip a stranger in.

1. Click Team… in the profile menu, or Open Team on the Team tab of the Settings window (that tab is still to draw on **PageSettings**). **PageTeam** opens as a tab: "Acme", "Organization on Komando Cloud · `5/10` seats", and the tabs Members, Vaults, Roles, and SSO and SCIM. An organization has teams (Platform, Data), and a team opens vaults: shared sets of targets and the secrets that open them, such as production and staging. With no organization yet, the tab offers Create Organization…, which makes you its Owner (to draw on **PageTeam**).
2. Click Invite People, the tab's one primary. **PageInvite** asks three things: Email addresses ("One per line, or separated by commas."), Role (Admin, Member or Viewer, with Member chosen and one line on what it can do; journey 29), and Teams, a box per team with the vaults it opens ("They open the vaults of the teams you tick."). People join teams, never vaults one by one. Click Send Invites.
3. A Banner on Members says "Invited 2 people to Acme." Each address is a row with the Invited pill and "Not joined yet".
4. The person creates an account or signs in (journey 2) and accepts.
5. Your Mac checks their key itself, from the signed key directory, before it shares a vault: "Before anyone opens a vault, your Mac checks their key fingerprint, so Komando Cloud can't slip in a fake key." There is nothing to compare by hand. Your Mac then gives them the keys of their teams' vaults and signs the change; Komando Cloud cannot add anyone by itself. Their sheet (**PageMember**) then says "Key checked by Ana Putri when Citra joined." over the fingerprint.

**If it goes wrong:**
- A wrong address, someone already in Acme, or more people than free seats: one red line under the field ("budi@acme.example is already in Acme."). Send Invites stays dimmed until there is an address and a team, and its tooltip says why.
- Someone has not accepted: their sheet says "When Eka accepts, your Mac checks Eka's key fingerprint before it shares a vault." with Resend Invitation, and Withdraw Invitation…, which asks "Withdraw the invitation to Eka Wijaya?" with Withdraw.
- A key that does not match the key directory is not drawn yet (see Cards still to draw).
- Only Owners and Admins see Invite People (journey 35). Anyone else who reaches the sheet sees it dimmed: "Only owners and admins can change this. Ask an admin."

**Done when:** the person's row on **PageTeam** shows their teams and role without the Invited pill, and they see their teams' servers on their device.

## 29. Roles, and changing a role (proposed: Komando Cloud phase 2, nothing built)

**Goal:** give each person only what their work needs.

1. On **PageTeam**, click the Roles tab. **PageRoles** lists the four roles in one table and sums them up:
   - Owner: everything.
   - Admin: everything but billing and removing the organization.
   - Member: look, connect, change and add targets.
   - Viewer: look and connect.
2. To change a role, click the person's row on Members. **PageMember** opens as a sheet: pick the new role under Role (Admin, Member or Viewer; What each role can do opens **PageRoles**) and click Save. A Banner says "Citra Dewi is now a Viewer."
3. **PageRoles** says plainly where a role is enforced: "Viewer is enforced by komando's safety rules on this device; real enforcement needs the Gateway (phase 3)."

**If it goes wrong:**
- A Viewer who can open a password can still use it outside Komando. Real enforcement needs the phase 3 Gateway (komando installed inside the customer's network). For someone who must not keep access, remove them (journey 31).
- The owner's role stays as it is: "Acme always has an owner. Only the owner can hand that on." How the owner hands it on is not drawn yet (see Cards still to draw).
- Your own role stays as it is too: "You can't change your own role. Ask another owner."

**Done when:** the person's row shows the new role, and their device follows it.

## 30. Who can open which vault (proposed: Komando Cloud phase 2, nothing built)

**Goal:** decide which teams can open production and which only staging.

1. On **PageTeam**, click the Vaults tab. **PageVaults** shows one card per vault: its name, "6 targets · 6 secrets", "key changed 3 weeks ago", then Targets, Teams and Who can open it.
2. To make a vault, click New Vault…. Type its Name ("Lower case, like production or staging.") and tick the teams under Who can open it ("Your Mac makes the vault's key and wraps it for each person in these teams. Komando Cloud never sees it."). Click Create Vault. A Banner says "Created lab.", and its Targets read "None yet".
3. Access comes from teams. To let someone open a vault, tick a team that opens it on their sheet (**PageMember**) and click Save; your Mac gives them that vault's key.
4. To take a vault away from someone, untick the team on their sheet. The sheet says what Save does: "production gets a new key when you save, so Citra can no longer open it." After Save, the vault's card reads "key changed just now".

**If it goes wrong:**
- A new vault key does not change a password the person already saw. The checklist that changes them is drawn for removing a person (**PageRemoveMember**, journey 31), not yet for taking away a team (see Cards still to draw).
- Putting a target into a vault is not designed yet (see Cards still to draw).
- Only Owners and Admins make vaults; for anyone else New Vault… is dimmed, with the reason as its tooltip.

**Done when:** each vault's Who can open it lists only the people who should open it.

## 31. Remove a member, for real (proposed: Komando Cloud phase 2, nothing built)

**Goal:** when someone leaves, they keep nothing that opens your servers.

1. Click the person's row on **PageTeam**, then Remove from Acme… on **PageMember**. **PageRemoveMember** opens: "Remove Citra Dewi from Acme".
2. Step 1, "1. The vaults get new keys": "production and staging get new keys that only the people who stay can open. komando makes them when you press Remove Member."
3. Click Remove Member. It asks first: "Remove Citra Dewi from Acme?" · "Citra can no longer open production and staging: they get new keys now, and Citra's devices are signed out of Acme." While rows are left it starts with "3 of 4 passwords and keys aren't changed yet, so Citra can still use them." Click Remove Member. Removing does not wait for the checklist: a person who left loses the vaults now.
4. Step 2, "2. Change what Citra could open", is a checklist of every password, SSH key and token they could open, with a count (`1/4`). For an SSH key, Revoke Key runs `komando key revoke`, which takes the key out of `authorized_keys` on many servers at once; on protected servers it asks "This target is protected" with Run Anyway (**PageSafetyPrompts**). For a secret, Change Password (or Change Token) opens **PageNewSecret** with the name filled in: change it on the database yourself, then save the new value, and the row is ticked.
5. A done row says Revoked or Changed. Until every row does, Members shows an AttentionCard: "Removing Citra Dewi isn't finished." with Continue before you pressed Remove Member, "Citra can still use 3 passwords and keys." with Finish after it. Both reopen the sheet; after removal it reads "Finish removing Citra Dewi" and has only Close.

**If it goes wrong:**
- Without step 2 the person keeps whatever they already downloaded, so the AttentionCard stays until every row is changed.
- Change Password only saves the new value; the guided change of a database password that docs/sync.md describes is not drawn yet (see Cards still to draw).
- Only Owners and Admins remove people; anyone else sees the sheet read-only, with the reason.
- SCIM opens the same sheet when your identity provider says someone left (journey 32).

**Done when:** the person is gone from **PageTeam**, and every row on the checklist says Revoked or Changed.

## 32. Sign in with your company: SSO and SCIM (proposed: Komando Cloud phase 2, nothing built)

**Goal:** people sign in with the company's identity provider (such as Okta), and leaving the company removes them from Komando.

1. An Owner or Admin opens the SSO and SCIM tab on **PageTeam** (**PageSSO**). Pick the Identity provider (Okta, Microsoft Entra ID, Google Workspace, Other (SAML)), fill in Client ID and Sign-in URL, and click Test Sign-In ("Signed in as ana@acme.example through Okta."), then Save. SSO (single sign-on) then signs people in to Komando Cloud with their company login.
2. A colleague clicks Sign In with SSO on **PageSignIn**, types their Work email and clicks Continue in Browser. While the company's page is open, the sheet says "Finish signing in in your browser…" with Open Browser Again and Cancel.
3. SSO only signs the person in. A Mac that never joined still needs a yes from one of their devices or their Emergency Kit (journeys 3 and 4), and the sheet says so before the click.
4. SCIM is the identity provider telling Komando when someone joins or leaves. Turn on Sync people with SCIM ("Removing someone there starts the checklist that changes what they could open."), click New Token and paste it into the identity provider ("Copied. Paste it into Okta; it is shown only once."). A person removed there opens **PageRemoveMember** (journey 31).
5. Recovery is off by default: the switch Let SSO open vaults on a new device says "Off by default. On means someone in Acme holds a recovery key that can open anyone's vaults." Turning it on asks "Turn on recovery for Acme?" with Turn On. Then pick where under Recovery key kept on: The owners' Macs, or Your own key service. "Acme holds the recovery key, never Komando. Every recovery shows in the audit log, where the person can see it."

**If it goes wrong:**
- The browser page was closed: Open Browser Again. Back returns to the email and password.
- With recovery off, a person who forgot their password has the ways out in journey 4. With it on, how an admin recovers a person's account is not drawn yet (see Cards still to draw).
- Only Owners and Admins change this tab; anyone else sees it read-only, with the reason beside Save.

**Done when:** a new colleague signs in with the company login, and a leaver loses access the same day.

## 33. The team's audit log (proposed: Komando Cloud phase 2, nothing built)

**Goal:** see who on the team did what, on which server, with a record nobody can quietly change.

1. Open **PageAuditLog**. Signed in to an organization, Who shows teammates as well as you and the agent.
2. Each device signs its own entries and chains them, as komando's audit log already does; the entries reach the team encrypted to the organization's audit key.
3. Owners and Admins click ⋯ → Verify the Record… to check every device's chain. Komando Cloud cannot rewrite the history.

**If it goes wrong:**
- A chain that does not check out is a finding on Home, as in journey 20.

**Done when:** an Admin sees every teammate's changes and Verify says the record is intact.

## 34. Working as a Viewer (proposed: Komando Cloud phase 2, nothing built)

**Goal:** a Viewer can look and connect, and knows what they cannot do.

1. The Viewer signs in (journey 2) and sees only the vaults they were given (journey 30) on **PageHosts** and **PageConnections**.
2. **PageRoles** gives a Viewer "See every server, database, finding and log" and "Connect: open terminals, run queries that only read". So they read Home and the Findings tab (**PageDashboard**, **PageDoctor**), open a server's Overview and Test (**PageHostDetail**), connect (**PageTerminal**), and read a database or cache (**PageDatabase**, **PageCache**).
3. Quick checks, Read-only recipes, downloads (**PageFiles**) and forwards only read, but **PageRoles** does not list them yet, and it disables Run for a Viewer, which would also stop a query that only reads (see Cards still to draw).
4. They cannot add, edit or remove targets, tick ☐ Allow changes, use Fix, Protect or Remove on a finding, upload files, run a recipe that changes the server, or stop a job. Each of these is dimmed with "Viewers can look but not change. Ask an admin." as its tooltip or line, and Add leaves the header (**PageRoles**). How each looks is still to draw (see Cards still to draw).

**If it goes wrong:**
- Viewer is enforced by komando's safety rules on their device, not by encryption: a Viewer who has a password can use it outside Komando. Real enforcement needs the phase 3 Gateway.
- Needing to change something: ask an Admin to change your role (journey 29).

**Done when:** the Viewer reads and connects, and nothing they try changes a server.

## 35. Working as an Admin (proposed: Komando Cloud phase 2, nothing built)

**Goal:** an Admin runs the team day to day, everything except billing and removing the organization.

1. The Admin opens **PageTeam** from Team… in the profile menu.
2. Invites people with Invite People; their Mac checks each new key by itself (journey 28, **PageInvite**, **PageMember**).
3. Changes roles (journey 29, **PageRoles**), makes vaults and changes who opens them through teams (journey 30, **PageVaults**, **PageMember**).
4. Removes a member and works through the checklist (journey 31, **PageRemoveMember**).
5. Sets up SSO and SCIM (journey 32, **PageSSO**), which **PageRoles** gives Admins as well as Owners.
6. Checks the team's audit log (journey 33, **PageAuditLog**).
7. Billing and removing the organization are the Owner's alone (**PageRoles**).

**If it goes wrong:**
- An Admin cannot change their own role or the owner's: "You can't change your own role. Ask another owner." and "Acme always has an owner. Only the owner can hand that on." (**PageMember**).

**Done when:** the team's members, roles and vaults match who should have them.

## 36. Komando on iPhone and iPad

**Goal:** when you are away from the desk, see findings, fix them with Face ID, run quick checks and ask the agent.

Built. The app follows iOS: its screens live in `Apps/iOS/KomandoMobile.swiftpm`, and each step names the phone's own screen. On iPad at regular width the tabs are a sidebar and Targets shows the list beside the chosen target, with keyboard shortcuts ⌘1–⌘6, ⌘R, ⌘F and ⌘N (**PageiPad**, **PageiPadHome**, **PageiPadSizes**; built). The Agent at accessibility text sizes is **PageiPhoneAgent**. The places, the demo marker, the target menu and the answers under each button are **PageiPhonePlaces** (built 2026-11-16). Six places: Home, Targets, Activity, Jobs, Agent and Settings; the iPhone tab bar shows five, and Jobs opens from Home.

1. The phone app opens on Welcome, "Komando on call". The phone makes two keys in its Secure Enclave: one that "Reads, without Face ID" and one for "Changes, after Face ID". Tap Copy Both Lines and add them to `~/.ssh/authorized_keys` on the komando computer (a server, or your Mac with Remote Login on; the phone then says "your Mac"). Each line lets komando's ssh-gate decide what that key may run.
2. Under "2. Where komando lives", type its `user@address` and tap Connect. The first time, the phone shows the computer's host key: run the shown command there, and tap It Matches, Trust This Computer. Pairing stops with a plain sentence when that komando is older than 0.13.0. Try the Demo shows sample servers and findings first; every place then shows a Demo pill, Home starts with "This is the demo", and nothing asks for Face ID.
3. Home lists Needs attention, Running now and Recent activity. A fix that acts on a server runs after Face ID (journey 8): the dialog's button is Run the Fix, and when Face ID is cancelled or the change fails, the words show under the Fix button; a fix that changes komando's own settings, such as Protect or Add Password, says to do it in Komando on the Mac. Running now links to the background jobs (also the Jobs place), which show their state, full command and log; Refresh asks the servers; Stop Job and Remove Job ask first, then Face ID. Activity (a place, and All Activity under Recent activity) is the audit log with the Changes, Failed and Agent filters and Verify the Record.
4. Targets (the tab lists every target in sections by family; search "Find a target"): a long press on a target gives Open, Test Connection, Copy Name and Copy Address, and a swipe right tests it (the answer stays under the row). Each server has Test Connection and the quick checks Health, Disk and Services, which only read; their tables scroll sideways; queues have their own read-only checks. On iPad, drag the list's edge (320 to 480); it is remembered.
5. Agent works as on the Mac (journey 19), with ☐ Allow changes; Allow Once asks for Face ID first, naming the command. The newest message stays in view, Send turns into Stop while it works, and New Conversation asks first. Until a key is saved it says "Add your Anthropic API key in Settings first."
6. Settings: Your Mac (or komando computer): its address, komando's version and host key, Forget This Mac (or Leave the Demo; forgetting also deletes its keys on the device), Import from a Computer and, once something was imported, Remove Imported Inventory (asks first), Notifications, Upgrade, Agent (your Anthropic API key, Save Key, Remove Key asks first), and About (the app's version and "Old data: none"). Upgrade lists Sync between devices, Teams, Built-in AI and Approve from your phone, each "Coming", under "Komando for iPhone and iPad is free, like the komando command line." There is nothing to buy and no license (journey 22).

**If it goes wrong:**
- The machine does not accept the phone's key: add the line again, exactly as copied.
- Forget This Host Key goes back to Welcome, also after the computer was rebuilt and its host key changed.
- Face ID cancelled: "Not done: Face ID was cancelled or did not match. Nothing was changed." under the button you tapped. A change that may have run says to check Recent activity first.
- The terminal, the SQL editor, Protect and anything past komando's own safety stop (`--yes`) stay on the Mac. Files has its own phone screens (journey 36b). A protected server's change says "change it from Komando on your Mac".

**Done when:** Home on the phone shows the same findings as on the Mac.

## 36b. Files on iPhone and iPad

**Goal:** get a file from a server onto the phone, put one from the phone onto a server, or copy one between two servers, away from the desk.

1. On Targets, open a server or a storage and tap Browse Files. Its folder opens (**PageiPhoneFiles**; on iPad beside the Targets list, **PageiPadFiles**). Tap folders to go in; pull down to read again.
2. Long-press a file: Save to Files, Share…, Copy to Another Server… or Copy Path. Select picks several.
3. Upload from Files (bottom bar) picks files in the Files app and uploads them to the folder shown, after Face ID. On iPad, drag files in from the Files app.
4. Copy to Another Server…: choose where it goes and the folder. The sheet says "Copies through mac-mini": komando on the host copies it, and nothing goes through this iPhone. Tap Copy with Face ID.
5. Transfers (the arrows in the bar) lists what runs and what finished, with Cancel, Retry and Show.

**If it goes wrong:**
- A protected server: "change it from Komando on your Mac", as for every change from the phone.
- iOS stops a transfer a few minutes after you leave the app: it says "Paused when Komando went to the background" with Retry. Keep Komando open until it finishes.
- Not enough space on this iPhone: it says so and nothing starts.
- Needs komando 0.15.0 on the host (`download --to -`, `upload TARGET - PATH`, `cp SERVER_A:PATH SERVER_B:PATH`): with an older one, browsing works and the actions say "Update komando on mac-mini to 0.15.0 to move files with this iPhone".

**Done when:** the file is in the Files app, or its row in Transfers says Done.

## 37. The command line

**Goal:** do the same jobs from the free komando command line, or run any komando command from inside Komando.

1. Press ⌘K (CommandPalette) and choose Run a Command…. The field asks "Type a komando command, for example status"; type `status` and press Return. It runs in a tab of its own, titled with the command (**PageCommandTab**). Typing a command straight into ⌘K offers the same as "Run komando status". Its output uses the same colors with the same meanings: green for fine, yellow for a warning, red for an error.
2. Every journey above has a free command, named in each journey's If it goes wrong (for example `komando db query NAME 'SQL'` for journey 12), except what only the apps do: one-click fixes (journey 8), the agent (journey 19), the menu bar and notifications (journey 25), and the phone (journey 36).
3. In the Terminal app, `komando --help` lists every command.

**If it goes wrong:**
- komando stops a risky command and names the flag that would allow it (`--yes`, `--write`, `--allow-dangerous`); the app asks the same question in the same words before adding that flag.

**Done when:** the command's output shows in its tab.

## Screens

Every Page card, and the journeys that use it. (proposed) marks the Komando Cloud cards, which follow docs/sync.md and draw nothing that is built; (to draw) a card that does not exist yet. The iPhone app has no Page cards (journey 36).

| Page card | Journeys |
| --- | --- |
| **PageInstall** | 1, 26 |
| **PageSignIn** (proposed) | 1, 2, 3, 4, 32 |
| **PageSignUp** (proposed) | 2 |
| **PageEmergencyKit** (proposed) | 2 |
| **PageNewDevice** (proposed) | 3, 4 |
| **PageApproveDevice** (proposed) | 3 |
| **PageRecover** (proposed) | 4 |
| **PageWelcome** | 1, 5, 6, 7 |
| **PageAdd** | 5, 6, 7, 16, 24 |
| **PageNewHost** | 5, 8, 24 |
| **PageNewHostStates** | 5 |
| **PageNewConnection** | 6, 16 |
| **PageNewConnectionKind**, **PageNewConnectionKindStates** | 6, 16 |
| **PageDashboard** | 5, 8, 18, 34 |
| **PageDoctor** | 8, 18, 24, 34 |
| **PageHowToFix** | 8 |
| **PageSafetyPrompts** | 8, 11, 12, 17, 21, 31 |
| **PageHosts** | 5, 7, 9, 11, 21, 34 |
| **PageHostDetail** | 5, 9, 10, 21, 34 |
| **PageHostServices** | 10 |
| **PageTerminalStates** | 9 |
| **PageTerminal** | 9, 34 |
| **PageCommandTab** | 9, 12, 16, 37 |
| **PageJobs** | 10 |
| **PageJobsEmpty** | 10 |
| **PageStartJob** | 10 |
| **PageFiles** | 11, 11b, 34 |
| **PageFilesOptions**, **PageFilesStates**, **PageFilesNarrow** | 11 |
| **PageFilesTransfers** | 11, 11b |
| **PageTargetMenus** | 9, 11, 15, 17, 21 |
| **PageForwardMenus** | 15, 25 |
| **PageRowMenus** | 10, 13, 17, 20 |
| **PageConnections** | 6, 7, 12, 13, 14, 16, 21, 34 |
| **PageConnectionDetail** | 12, 13, 14, 16 |
| **PageClusterObject**, **PageClusterLogs** | 14 |
| **PageQueue** | 6, 14 |
| **PageDatabase** | 12, 34 |
| **PageDatabaseStates** | 12 |
| **PageDatabaseSchemaStates** | 12 |
| **PageCache** | 13, 34 |
| **PagePortForwarding** | 15 |
| **PageRecipes** | 17 |
| **PageRunResults** | 17 |
| **PageRecipeEditor** | 17 |
| **PageNewSecret** | 8, 18, 31 |
| **PageKeychain**, **PageKeychainMenus** | 18 |
| **PageKeyDeploy**, **PageKeyRevoke**, **PageKeychainRename**, **PageKeychainRemove** | 18 |
| **PageSecretCheck**, **PageVaultPassphrase** | 18 |
| **PageStates** | 1, 5, 8, 18, 26 |
| **PageAgentStart** | 19 |
| **PageAgentDrawer** | 19 |
| **PageKomandoConfirm** | 19 |
| **PageKomandoConfirm** (to draw) | 19 |
| **PageAuditLog** | 20, 33, 35 |
| **PageEditTarget**, **PageEditTargetStates** | 5, 9, 21 |
| **PageEditGroupLogin** | 7, 21 |
| **PageEditConnection**, **PageEditConnectionStates** | 6, 21 |
| **PageEditVPN**, **PageEditVPNStates** | 16, 21 |
| **PageUpgrade** | 22, 23 |
| **PageiPad**, **PageiPadHome**, **PageiPadSizes**, **PageiPhoneAgent**, **PageiPhonePlaces** | 36 |
| **PageiPhoneFiles**, **PageiPadFiles** | 36b |
| **PageSettings** | 19, 23, 24, 26, 28 |
| **PageAppMenus** | 24 |
| **PageMenuBar** | 15, 25 |
| **PageAccount** (proposed) | 2, 3, 4, 27 |
| **PageTeam** (proposed) | 28, 29, 30, 31, 32, 35 |
| **PageInvite** (proposed) | 28, 35 |
| **PageMember** (proposed) | 28, 29, 30, 31, 35 |
| **PageRemoveMember** (proposed) | 30, 31, 32, 35 |
| **PageRoles** (proposed) | 10, 11, 15, 17, 29, 34, 35 |
| **PageVaults** (proposed) | 30, 35 |
| **PageSSO** (proposed) | 32, 35 |

## Cards still to draw

New cards:

- **PageKomandoConfirm**: the window komando opens to ask once more after Allow Once on a protected change the agent wants. Journey 19.
- **PageHostLogs**: a host's Logs tab, the system journal, a log file or one service's log, in the **PageClusterLogs** layout. Journey 10.
- **PageHostUpdates**: a host's Updates tab, the packages to update, Update All and Reboot, with a reboot confirm on **PageSafetyPrompts**. Journey 10.
- **PageDatabaseBackups**: a database's Backups tab, the backups with Back Up Now and Restore (Restore always asks first). Journey 12.
- **PageiPhoneSafetyStates**: the safety moments the 2026-11-14 security audit changed on iPhone and iPad: the Fix dialog ending with exactly what runs ("This runs: komando …", each word quoted), Remove Imported Inventory and Forget This Mac asking first, an answer over 16 MB cut off with a plain sentence, an unknown Right now reading shown as "–", and notifications that never carry a command line.
- **PageiPhonePlaces**: the iPhone's places and answers (built 2026-11-16): Activity in the tab bar and Jobs in the iPad sidebar, the demo marked on every place, a Fix, Stop Job or Allow Once that did not happen saying why under its button, the target menu with Test Connection and a swipe, the agent's approval card (300 ms guard) and Stop, and Settings › About with "Old data".
- **PageiPadRecipes**: the Recipes place on iPad and iPhone, the fifth place beside Home, Targets, Agent and Settings: pick a saved recipe and run it on a server; a recipe that changes something goes through the Agent's approval card.
- **PageRotateSecret** (proposed): the guided change of a database password that docs/sync.md promises ("database passwords get a guided change"). Today Change Password on **PageRemoveMember** only opens **PageNewSecret** to save a new value, and the change on the database is left to the person. Journey 31.
- **PageRecoverMember** (proposed): an admin recovering a person's account on a new device with Let SSO open vaults on a new device turned on (escrow on, the recovery key held by the organization, every recovery in the audit log where the person can see it). Journey 32.
- Billing (proposed): the Owner's alone (journeys 29, 35), but nothing says yet what the upgrade costs or what billing holds; decide that before drawing a card.
- Approve on the Phone (proposed): docs/sync.md lists it as design work, but its phase table puts phone approvals in phase 3; decide the phase before drawing a card.

States and items to add to existing cards:

- **ImportSheet**: the Add to group choice (`--group`), a popup of the groups with New Group…. Journey 7.
- **PageHosts**: the Add Hosts to Group… sheet (`komando group add`), from a group's ⋯. Journey 7.

- **PageConnectionDetail**: the VPN's tab, which its README describes but does not draw: Connect as the one primary while the VPN is down (Disconnect, secondary, while it is up) and the Details quick check. Journey 16.
- **PageMenuBar**: decide whether Stop Forward asks first, as Stop… in a forward's ⋯ on **PagePortForwarding** does ("Stop the forward to prod-db?"). Journeys 15, 25.
- **PageAuditLog**: teammates in Who when signed in to an organization (its README describes it; not drawn). Journeys 20, 33.
- **PageSettings**: an update control for komando, and how a komando that came inside Komando.app is updated (journey 26); the Team tab with Open Team when signed in (journey 28).
- **PageStates**: the full-panel "komando did not answer" for when nothing has loaded (its README says to draw it as **PageInstall**'s panel). Journey 1.
- **PageSignIn** (proposed): what happens when Komando Cloud cannot be reached. Journey 2.
- **PageTeam** (proposed): the tab with no organization yet, with Create Organization…, which makes you the Owner. Journey 28.
- **PageMember** (proposed): handing on the Owner role (its Role menu offers only Admin, Member and Viewer, and says "Acme always has an owner. Only the owner can hand that on."), a new member's key that does not match the key directory, and the checklist of passwords to change after unticking a team takes a vault away. Journeys 28, 29, 30.
- **PageVaults** (proposed): putting a target into a vault (its README: "Moving a target into a vault is not designed yet."). Journey 30.
- **PageRoles** (proposed): a row or a sentence for what a Viewer may do with quick checks, Read-only recipes, downloads and forwards, and that Run stays live for a query or recipe that only reads (today the card disables Run for a Viewer). Journeys 10, 11, 12, 15, 17, 34.
- Viewer states (proposed) for every control a Viewer cannot use: Add, Edit…, Remove…, ☐ Allow changes, Fix, Protect, Remove, Upload to web-1, a recipe that changes the server, Stop Job. Journey 34.
