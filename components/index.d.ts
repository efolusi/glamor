import type * as React from 'react';

/** A color token name, such as 'accent', 'ok', 'warn', 'danger', 'text2', 'text3' or a family tint 'tint-servers'. */
export type Tint = string;
/** A status color: what a dot, pill or banner means. */
export type Tone = 'ok' | 'warn' | 'danger' | 'accent' | 'text2' | 'text3';

/** AppLogo(size:), the prompt mark on its navy square */
export interface AppLogoProps { size?: 18 | 26 | 56 | number }
export declare function AppLogo(props: AppLogoProps): React.ReactElement;

/** Stand-in glyph keyed by SF Symbol name. In Swift: Image(systemName:). */
export interface SFSymbolProps { name: string; size?: 8 | 12 | 16 | 20 | 24 | 32; weight?: 'light' | 'regular' | 'medium' | 'semibold' | 'bold'; color?: Tint }
export declare function SFSymbol(props: SFSymbolProps): React.ReactElement;

/** IconTile(symbol:tint:size:): the glyph in its tint on the tint at 12% (opacity-tint). There is no filled variant. */
export interface IconTileProps { symbol: string; tint?: Tint; size?: 20 | 28 | 32 | 40 | 48 }
export declare function IconTile(props: IconTileProps): React.ReactElement;

/** StatusDot(color:size:) */
export interface StatusDotProps { tone?: Tone; size?: 6 | 8 }
export declare function StatusDot(props: StatusDotProps): React.ReactElement;

/** Pill(text:color:) */
export interface PillProps { tone?: Tone; children: React.ReactNode }
export declare function Pill(props: PillProps): React.ReactElement;

/** DashedDivider() */
export declare function DashedDivider(): React.ReactElement;

/** .buttonStyle(.primary / .secondary / .ghost), PrimaryButtonStyle(shortcut:wide:) */
/** size omitted: 32 (pages, forms, section headers); 'sm': 28 (toolbars, cards, rows, side panels, the header); 'xs': a 24 icon-only button in rows. No children: a square icon-only button. */
export interface ButtonProps { variant?: 'primary' | 'secondary' | 'ghost'; size?: 'sm' | 'xs'; symbol?: string; shortcut?: string; wide?: boolean; disabled?: boolean; help?: string; onClick?: () => void; className?: string; children?: React.ReactNode }
export declare function Button(props: ButtonProps): React.ReactElement;

/** LinkButton(title:action:), "View all 4 ›" */
export interface LinkButtonProps { onClick?: () => void; children: React.ReactNode }
export declare function LinkButton(props: LinkButtonProps): React.ReactElement;

/** ChipStyle(selected:) */
export interface ChipProps { selected?: boolean; onClick?: () => void; className?: string; children: React.ReactNode }
export declare function Chip(props: ChipProps): React.ReactElement;

/** FormField(label:help:) around any field */
export interface FormFieldProps { label: string; help?: string; children: React.ReactNode }
export declare function FormField(props: FormFieldProps): React.ReactElement;

/** TextFieldBox(placeholder:text:mono:secure:) inside FieldBox; with label, wrapped in FormField */
export interface TextFieldProps { placeholder?: string; value?: string; mono?: boolean; secure?: boolean; focused?: boolean; label?: string; help?: string }
export declare function TextField(props: TextFieldProps): React.ReactElement;

/** SearchBar(placeholder:text:actionTitle:action:) */
export interface SearchBarProps { placeholder?: string; value?: string; actionTitle?: string; focused?: boolean }
export declare function SearchBar(props: SearchBarProps): React.ReactElement;

/** CommandBar(placeholder:text:running:onRun:onStop:accessory:) */
export interface CommandBarProps { placeholder?: string; value?: string; running?: boolean; focused?: boolean; options?: { label: string; on?: boolean }[]; /** Extra items after the options, e.g. a spacer and a compact ghost Clear. */ accessory?: React.ReactNode }
export declare function CommandBar(props: CommandBarProps): React.ReactElement;

/** ToggleCard(title:help:isOn:extra:) */
export interface ToggleCardProps { title: string; help: string; on?: boolean; children?: React.ReactNode }
export declare function ToggleCard(props: ToggleCardProps): React.ReactElement;

/** UnderlineTabs(items:selection:) */
export interface UnderlineTabsProps { items: string[]; selected: string }
export declare function UnderlineTabs(props: UnderlineTabsProps): React.ReactElement;

/** SectionTitle(_:detail:subtitle:) */
export interface SectionTitleProps { title: string; detail?: string; subtitle?: string }
export declare function SectionTitle(props: SectionTitleProps): React.ReactElement;

/** .card(padding:) */
export interface CardProps { padding?: number; className?: string; children?: React.ReactNode }
export declare function Card(props: CardProps): React.ReactElement;
/** HoverCard(action:content:), padding 14, lights up under the pointer */
export interface HoverCardProps { hover?: boolean; onClick?: () => void; children?: React.ReactNode }
export declare function HoverCard(props: HoverCardProps): React.ReactElement;
/** .surface(padding:) */
export interface SurfaceProps { padding?: number; children?: React.ReactNode }
export declare function Surface(props: SurfaceProps): React.ReactElement;

/** CardList { InfoRow(...) ... } */
export interface CardListProps { children: React.ReactNode }
export declare function CardList(props: CardListProps): React.ReactElement;
/** InfoRow(_ label:_ value:) */
export interface InfoRowProps { label: string; value: React.ReactNode; mono?: boolean }
export declare function InfoRow(props: InfoRowProps): React.ReactElement;

/** AttentionCard(item:confirm:) */
export interface AttentionCardProps { tone?: 'warn' | 'danger'; subject: string; category?: 'Security' | 'Inventory' | 'Setup' | string; message: string; actionTitle?: 'Fix' | 'Copy Fix' | 'View' | string }
export declare function AttentionCard(props: AttentionCardProps): React.ReactElement;

/** RunningCard(symbol:tint:title:line:chip:chipColor:meta:action:) */
export interface RunningCardProps { symbol: string; tint: Tint; title: string; line: string; chip: string; chipTone?: Tone; meta?: string; hover?: boolean }
export declare function RunningCard(props: RunningCardProps): React.ReactElement;

/** TargetCard(target:) */
export interface TargetCardProps { symbol: string; tint: Tint; name: string; subtitle: string; protected?: boolean; hover?: boolean }
export declare function TargetCard(props: TargetCardProps): React.ReactElement;

/** ActivityRow(symbol:tint:title:detail:meta:actions:) */
export interface ActivityRowProps { symbol: string; tint: Tint; title: string; detail?: string; meta?: (string | null)[] }
export declare function ActivityRow(props: ActivityRowProps): React.ReactElement;

/** TerminalPane(run:placeholder:) */
export interface TerminalPaneProps { state?: 'idle' | 'running' | 'failed' | 'done'; label?: string; text?: string; exitCode?: number; meaning?: string; placeholder?: string; height?: number }
export declare function TerminalPane(props: TerminalPaneProps): React.ReactElement;
/** OutputText(text:color:) */
export interface OutputTextProps { text: string; tone?: Tone }
export declare function OutputText(props: OutputTextProps): React.ReactElement;

/** FormHeader(symbol:tint:title:subtitle:) */
export interface FormHeaderProps { symbol: string; tint: Tint; title: string; subtitle: string }
export declare function FormHeader(props: FormHeaderProps): React.ReactElement;

/** ErrorBanner(title:hint:) and SuccessBanner(title:detail:) */
export interface BannerProps { tone?: 'danger' | 'ok'; title: string; detail?: string }
export declare function Banner(props: BannerProps): React.ReactElement;

/** EmptyState(symbol:title:message:actions:) */
export interface EmptyStateProps { symbol: string; title: string; message?: string; children?: React.ReactNode }
export declare function EmptyState(props: EmptyStateProps): React.ReactElement;

/** SidebarItem(place:) */
export interface SidebarItemProps { symbol: string; title: string; count?: number; shortcut?: string; selected?: boolean }
export declare function SidebarItem(props: SidebarItemProps): React.ReactElement;

/** GroupRow(row:) */
export interface GroupRowProps { name: string; protected: number; total: number; active?: boolean }
export declare function GroupRow(props: GroupRowProps): React.ReactElement;

/** TabButton(tab:) */
export interface TabButtonProps { symbol: string; title: string; active?: boolean; home?: boolean }
export declare function TabButton(props: TabButtonProps): React.ReactElement;

/** PanelHeader() */
export interface PanelHeaderProps { title?: string; tabs?: { symbol: string; title: string }[]; activeIndex?: number; action?: { title: string; symbol?: string } }
export declare function PanelHeader(props: PanelHeaderProps): React.ReactElement;

/** A row in a popover menu, on the ListRow spec (`.buttonStyle(.row(height: K.Row.twoLine))`) */
export interface MenuRowProps { symbol: string; tint: Tint; title: string; help: string; shortcut?: string; highlighted?: boolean }
export declare function MenuRow(props: MenuRowProps): React.ReactElement;

/** CommandPalette() on ⌘K */
export interface CommandPaletteProps { query?: string; index?: number; /** Run a Command… with its Run on field (M-MV5). */ runOn?: TargetsFieldProps; items: { symbol: string; tint: Tint; title: string; detail: string }[] }
export declare function CommandPalette(props: CommandPaletteProps): React.ReactElement;

/** The profile button in SidebarFooter */
export interface ProfileCardProps { name?: string; initial?: string; where?: string }
export declare function ProfileCard(props: ProfileCardProps): React.ReactElement;

/* ---- The window, the terminal, data and the agent ---- */

/** The window: sidebar on window, the floating panel with its header, and the page inside. */
export interface AppShellProps {
  /** Home, Hosts, Connections, Port Forwarding or Recipes; or Jobs, Keychain, Audit Log (under More, which opens). Old names move: Dashboard and Doctor to Home, VPNs to Connections. */
  place?: string | null; title?: string;
  /** The page's one create button, at the right of the panel header. */ action?: { title: string; symbol?: string }; moreOpen?: boolean; tabs?: { symbol: string; title: string }[]; activeTab?: number; group?: string; flush?: boolean;
  /** false hides the places' counts and the groups (no inventory yet). */ counts?: boolean;
  /** The Jobs count under More; 0 shows no badge (no jobs). */ jobs?: number;
  children?: React.ReactNode }
export declare function AppShell(props: AppShellProps): React.ReactElement;

/** A terminal session. Each line is a string or a list of [text, style] runs; styles: red green yellow blue magenta cyan dim bold sel. */
export type TerminalRun = string | [string, string?];
export interface TerminalProps { lines: (string | TerminalRun[])[]; cursor?: boolean; inactive?: boolean; height?: number }
export declare function Terminal(props: TerminalProps): React.ReactElement;

/** The 28pt line under a terminal, query or key browser. */
export interface StatusBarProps { items?: React.ReactNode[]; right?: React.ReactNode[] }
export declare function StatusBar(props: StatusBarProps): React.ReactElement;

/** The system segmented control (Picker with .segmented). */
/** Named by label, or by labelId (the FormField label it sits in; FormField passes it, with helpId). */
export interface SegmentedProps { items: string[]; selected: string; label?: string; labelId?: string; helpId?: string; onSelect?: (item: string) => void }
export declare function Segmented(props: SegmentedProps): React.ReactElement;

/** Rows and columns: query results, keys, files, secrets, the audit log. */
export interface DataTableColumn { key: string; label: string; width?: number | string; align?: 'left' | 'right' | 'center'; mono?: boolean; render?: (value: unknown, row: Record<string, unknown>) => React.ReactNode }
export interface DataTableProps { columns: DataTableColumn[]; rows: Record<string, unknown>[]; selected?: number; dense?: boolean; bare?: boolean }
export declare function DataTable(props: DataTableProps): React.ReactElement;

/** Agent mode: one turn of the conversation. */
export interface AgentMessageProps { role: 'user' | 'agent'; children: React.ReactNode }
export declare function AgentMessage(props: AgentMessageProps): React.ReactElement;
/** A komando command the agent ran, with its output. */
export interface ToolCallProps { command: string; status?: 'ok' | 'running' | 'failed' | 'denied' | 'notrun'; duration?: string; output?: string; open?: boolean; symbol?: string }
export declare function ToolCall(props: ToolCallProps): React.ReactElement;
/** The agent asks before a command that komando would stop for safety. */
export interface ApprovalCardProps { title: string; detail?: string; command: string; allowTitle?: string; denyTitle?: string }
export declare function ApprovalCard(props: ApprovalCardProps): React.ReactElement;
/** Where the person writes to the agent: targets in scope, Ask or Act, send. */
export interface AgentComposerProps { value?: string; placeholder?: string; /** ☐ Allow changes ticked: the agent may change things, and every change asks first. */ allowChanges?: boolean; targets?: { symbol: string; tint: Tint; title: string }[] }
export declare function AgentComposer(props: AgentComposerProps): React.ReactElement;

/** A checkbox with its label (Toggle with .checkbox). */
export interface CheckboxProps { label: string; on?: boolean }
export declare function Checkbox(props: CheckboxProps): React.ReactElement;
/** A switch (Toggle with .switch, .controlSize(.small)): 28 by 16. */
/** Named by label, by labelledBy (the title next to it), or by labelId (the FormField label it sits in; FormField passes it, with helpId). */
export interface SwitchProps { on?: boolean; label?: string; labelledBy?: string; labelId?: string; describedBy?: string; helpId?: string; help?: string; onClick?: () => void }
export declare function Switch(props: SwitchProps): React.ReactElement;
/** A menu picker drawn as a field (Picker with .menu): 32, or 28 compact. */
export interface PopupButtonProps { value?: string; placeholder?: string; symbol?: string; tint?: Tint; size?: 'sm' }
export declare function PopupButton(props: PopupButtonProps): React.ReactElement;
/** The steps komando goes through to reach a target, in order (`--via a,b,c`); a VPN can only be first. */
/** One "Run on" field: komando's target words as chips, Add…, and komando's own answer of what they pick. */
export interface TargetsFieldProps { words?: string[]; picks?: string; protectedCount?: number }
export declare function TargetsField(props: TargetsFieldProps): React.ReactElement;
export interface HopListProps { steps?: { name: string; kind: 'vpn' | 'host' | 'unknown' }[]; target?: string }
export declare function HopList(props: HopListProps): React.ReactElement;
/** A 4-high progress bar. */
export interface ProgressBarProps { value: number; tone?: Tone }
export declare function ProgressBar(props: ProgressBarProps): React.ReactElement;
/** A loading placeholder bar. */
export interface SkeletonProps { width?: string; height?: 12 | 16 | 20 | 28 | 32 | number }
export declare function Skeleton(props: SkeletonProps): React.ReactElement;
/** A popover's panel (menus, the profile menu). */
export interface PopoverProps { width?: number; children: React.ReactNode }
export declare function Popover(props: PopoverProps): React.ReactElement;
/** A sheet over the window: 520 wide, title and actions. Render it as the last child of AppShell's content. */
export interface SheetProps { symbol?: string; tint?: Tint; title?: string; subtitle?: string; width?: number; actions?: React.ReactNode; children?: React.ReactNode }
export declare function Sheet(props: SheetProps): React.ReactElement;
/** A confirmation alert in Komando's sizes (the app uses the system .alert). */
export interface AlertDialogProps { title: string; message?: string; buttons: { title: string; variant?: 'primary' | 'secondary'; destructive?: boolean }[] }
export declare function AlertDialog(props: AlertDialogProps): React.ReactElement;

declare global {
  interface Window {
    Komando: {
      AppLogo: typeof AppLogo; SFSymbol: typeof SFSymbol; IconTile: typeof IconTile; StatusDot: typeof StatusDot; Pill: typeof Pill; DashedDivider: typeof DashedDivider;
      Button: typeof Button; LinkButton: typeof LinkButton; Chip: typeof Chip;
      FormField: typeof FormField; TextField: typeof TextField; SearchBar: typeof SearchBar; CommandBar: typeof CommandBar; ToggleCard: typeof ToggleCard; UnderlineTabs: typeof UnderlineTabs;
      SectionTitle: typeof SectionTitle; Card: typeof Card; HoverCard: typeof HoverCard; Surface: typeof Surface; CardList: typeof CardList; InfoRow: typeof InfoRow;
      AttentionCard: typeof AttentionCard; RunningCard: typeof RunningCard; TargetCard: typeof TargetCard; ActivityRow: typeof ActivityRow;
      TerminalPane: typeof TerminalPane; OutputText: typeof OutputText; FormHeader: typeof FormHeader;
      Banner: typeof Banner; EmptyState: typeof EmptyState;
      SidebarItem: typeof SidebarItem; GroupRow: typeof GroupRow; TabButton: typeof TabButton; PanelHeader: typeof PanelHeader; MenuRow: typeof MenuRow; CommandPalette: typeof CommandPalette;
      ProfileCard: typeof ProfileCard;
      AppShell: typeof AppShell; Terminal: typeof Terminal; StatusBar: typeof StatusBar; Segmented: typeof Segmented; DataTable: typeof DataTable;
      AgentMessage: typeof AgentMessage; ToolCall: typeof ToolCall; ApprovalCard: typeof ApprovalCard; AgentComposer: typeof AgentComposer;
      Checkbox: typeof Checkbox; Switch: typeof Switch; PopupButton: typeof PopupButton; HopList: typeof HopList; TargetsField: typeof TargetsField; ProgressBar: typeof ProgressBar; Skeleton: typeof Skeleton; Popover: typeof Popover; Sheet: typeof Sheet; AlertDialog: typeof AlertDialog;
    };
  }
}
