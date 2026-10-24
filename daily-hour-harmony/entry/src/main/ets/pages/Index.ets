import promptAction from '@ohos.promptAction';
import { DayCell, DayHeader, DailySummary, EntryRecord, GoalItem, GoalRecord } from '../model/Models';
import { GoalRepository } from '../data/GoalRepository';
import { EntryRepository } from '../data/EntryRepository';
import { SettingsRepository } from '../data/SettingsRepository';
import { buildLastDates, dayOfMonthLabel, toDateString, weekdayLabel } from '../utils/DateUtils';
import { buildSummary } from '../utils/Summary';
import { DailyHourCard } from '../components/DailyHourCard';
import { WeekdayHeader } from '../components/WeekdayHeader';
import { GoalRow } from '../components/GoalRow';
import { SettingsPanel } from '../components/SettingsPanel';
import { GoalEditDialog } from '../components/GoalEditDialog';

const DAYS: number = 7;
const CELL_WIDTH: number = 48;
const MIN_VISIBLE: number = 4;
const MAX_VISIBLE: number = 7;

@Entry
@Component
struct Index {
  @State private goals: GoalItem[] = [];
  @State private summary: DailySummary = new DailySummary();
  @State private headers: DayHeader[] = [];
  @State private today: string = '';
  @State private targetMinutes: number = 60;
  @State private growthMode: boolean = true;
  @State private loading: boolean = true;

  @State private showSettings: boolean = false;
  @State private showEditor: boolean = false;
  @State private editingId: number = 0;
  @State private editingName: string = '';
  @State private editingDimension: number = 0;
  @State private editingMinutes: number = 30;

  @State private nameWidth: number = 160;
  @State private visibleCount: number = 4;

  aboutToAppear(): void {
    this.loadData();
  }

  onPageShow(): void {
    const current = toDateString(new Date());
    if (this.today !== '' && this.today !== current) {
      this.loadData();
    }
  }

  private updateLayout(width: number): void {
    if (!Number.isFinite(width) || width <= 0) {
      return;
    }
    const desired = width >= 600 ? 220 : (width >= 400 ? 170 : 150);
    const maxName = width - 6 - MIN_VISIBLE * CELL_WIDTH;
    this.nameWidth = Math.max(110, Math.min(desired, maxName));
    const available = width - 6 - this.nameWidth;
    const count = Math.floor(available / CELL_WIDTH);
    this.visibleCount = Math.max(MIN_VISIBLE, Math.min(MAX_VISIBLE, count));
    if (this.visibleCount === MAX_VISIBLE) {
      this.nameWidth = Math.max(110, width - 6 - MAX_VISIBLE * CELL_WIDTH);
    }
  }

  private async loadData(): Promise<void> {
    if (this.goals.length === 0) {
      this.loading = true;
    }
    try {
      const dates: Date[] = buildLastDates(DAYS);
      const today = toDateString(dates[DAYS - 1]);
      this.today = today;

      const headers: DayHeader[] = [];
      for (let i = 0; i < dates.length; i++) {
        const header = new DayHeader();
        header.weekday = weekdayLabel(dates[i]);
        header.dayOfMonth = dayOfMonthLabel(dates[i]);
        header.isToday = toDateString(dates[i]) === today;
        headers.push(header);
      }
      this.headers = headers;

      this.targetMinutes = await SettingsRepository.getTargetMinutes();
      this.growthMode = await SettingsRepository.getGrowthMode();

      const records: GoalRecord[] = await GoalRepository.loadActive();
      const start = toDateString(dates[0]);
      const entries: EntryRecord[] = await EntryRepository.loadRange(start, today);

      const entryMap = new Map<string, EntryRecord>();
      for (let i = 0; i < entries.length; i++) {
        const entry = entries[i];
        entryMap.set(`${entry.goalId}|${entry.date}`, entry);
      }

      const goals: GoalItem[] = [];
      for (let i = 0; i < records.length; i++) {
        const record = records[i];
        const goal = new GoalItem();
        goal.id = record.id;
        goal.name = record.name;
        goal.dimension = record.dimension;
        goal.defaultMinutes = record.defaultMinutes;
        goal.position = record.position;

        const cells: DayCell[] = [];
        let checkedCount = 0;
        for (let j = 0; j < dates.length; j++) {
          const dateString = toDateString(dates[j]);
          const cell = new DayCell();
          cell.date = dateString;
          cell.weekday = weekdayLabel(dates[j]);
          cell.dayOfMonth = dayOfMonthLabel(dates[j]);

          const entry = entryMap.get(`${record.id}|${dateString}`);
          if (entry !== undefined && entry.done === 1) {
            cell.checked = true;
            cell.minutes = entry.minutes;
            checkedCount++;
          }
          cells.push(cell);
        }
        goal.cells = cells;
        goal.ringProgress = checkedCount / DAYS;
        goals.push(goal);
      }

      this.goals = goals;
      this.rebuildSummary(goals, today);
    } catch (error) {
      promptAction.showToast({ message: '加载失败，请重试' });
    } finally {
      this.loading = false;
    }
  }

  private rebuildSummary(goals: GoalItem[], today: string): void {
    const todayMinutes = new Map<number, number>();
    for (let i = 0; i < goals.length; i++) {
      const goal = goals[i];
      for (let j = 0; j < goal.cells.length; j++) {
        const cell = goal.cells[j];
        if (cell.date === today && cell.checked) {
          todayMinutes.set(goal.id, cell.minutes);
        }
      }
    }
    this.summary = buildSummary(goals, todayMinutes, this.targetMinutes);
  }

  private async handleToggle(goal: GoalItem, cellIndex: number): Promise<void> {
    const cell = goal.cells[cellIndex];
    if (cell === undefined) {
      return;
    }
    try {
      if (cell.checked) {
        await EntryRepository.uncheck(goal.id, cell.date);
      } else {
        await EntryRepository.check(goal.id, cell.date, goal.defaultMinutes);
      }

      const cells: DayCell[] = [];
      let checkedCount = 0;
      for (let i = 0; i < goal.cells.length; i++) {
        const source = goal.cells[i];
        const copy = new DayCell();
        copy.date = source.date;
        copy.weekday = source.weekday;
        copy.dayOfMonth = source.dayOfMonth;
        copy.checked = source.checked;
        copy.minutes = source.minutes;
        if (i === cellIndex) {
          copy.checked = !source.checked;
          copy.minutes = copy.checked ? goal.defaultMinutes : 0;
        }
        if (copy.checked) {
          checkedCount++;
        }
        cells.push(copy);
      }
      goal.cells = cells;
      goal.ringProgress = checkedCount / DAYS;
      this.rebuildSummary(this.goals, this.today);
    } catch (error) {
      promptAction.showToast({ message: '打卡失败，请重试' });
    }
  }

  private openCreate(): void {
    this.editingId = 0;
    this.editingName = '';
    this.editingDimension = 0;
    this.editingMinutes = 30;
    this.showEditor = true;
  }

  private openEdit(goal: GoalItem): void {
    this.editingId = goal.id;
    this.editingName = goal.name;
    this.editingDimension = goal.dimension;
    this.editingMinutes = goal.defaultMinutes;
    this.showEditor = true;
  }

  private async saveGoal(name: string, dimension: number, minutes: number): Promise<void> {
    try {
      if (this.editingId === 0) {
        await GoalRepository.insert(name, dimension, minutes);
      } else {
        await GoalRepository.update(this.editingId, name, dimension, minutes);
      }
      this.showEditor = false;
      await this.loadData();
    } catch (error) {
      promptAction.showToast({ message: '保存失败，请重试' });
    }
  }

  private async archiveGoal(): Promise<void> {
    if (this.editingId === 0) {
      return;
    }
    try {
      await GoalRepository.archive(this.editingId);
      this.showEditor = false;
      await this.loadData();
    } catch (error) {
      promptAction.showToast({ message: '归档失败，请重试' });
    }
  }

  private async saveSettings(target: number, growth: boolean): Promise<void> {
    try {
      await SettingsRepository.setTargetMinutes(target);
      await SettingsRepository.setGrowthMode(growth);
      this.targetMinutes = target;
      this.growthMode = growth;
      this.showSettings = false;
      this.rebuildSummary(this.goals, this.today);
    } catch (error) {
      promptAction.showToast({ message: '设置保存失败' });
    }
  }

  @Builder
  Toolbar() {
    Row() {
      Text('每日一小时')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)

      Blank()

      Text('＋')
        .fontSize(26)
        .fontColor(Color.White)
        .width(44)
        .height(44)
        .textAlign(TextAlign.Center)
        .onClick(() => this.openCreate())

      Text('⋯')
        .fontSize(24)
        .fontColor(Color.White)
        .width(44)
        .height(44)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          this.showSettings = true;
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 8 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor($r('app.color.toolbar_bg'))
  }

  @Builder
  EmptyState() {
    Column() {
      Text('还没有目标')
        .fontSize(15)
        .fontColor($r('app.color.text_secondary'))
      Text('点右上角 ＋ 添加第一个目标')
        .fontSize(12)
        .fontColor($r('app.color.text_tertiary'))
        .margin({ top: 6 })
      Button('新建目标')
        .height(38)
        .fontSize(14)
        .fontColor(Color.White)
        .backgroundColor($r('app.color.accent'))
        .margin({ top: 18 })
        .onClick(() => this.openCreate())
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        this.Toolbar()

        if (this.growthMode) {
          Column() {
            DailyHourCard({ summary: this.summary })
          }
          .width('100%')
          .padding({ left: 8, right: 8, top: 8, bottom: 8 })
        }

        WeekdayHeader({
          nameWidth: this.nameWidth,
          headers: this.headers,
          visibleCount: this.visibleCount
        })

        if (this.loading) {
          Column() {
            LoadingProgress()
              .width(28)
              .height(28)
              .color($r('app.color.text_tertiary'))
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.goals.length === 0) {
          this.EmptyState()
        } else {
          List() {
            ForEach(this.goals, (goal: GoalItem) => {
              ListItem() {
                GoalRow({
                  goal: goal,
                  nameWidth: this.nameWidth,
                  visibleCount: this.visibleCount,
                  today: this.today,
                  onToggle: (target: GoalItem, cellIndex: number) => {
                    this.handleToggle(target, cellIndex);
                  },
                  onEdit: (target: GoalItem) => {
                    this.openEdit(target);
                  }
                })
              }
            }, (goal: GoalItem) => goal.id.toString())
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .cachedCount(4)
          .padding({ top: 3, bottom: 24 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.page_bg'))

      if (this.showSettings) {
        SettingsPanel({
          initialTarget: this.targetMinutes,
          initialGrowth: this.growthMode,
          onCancel: () => {
            this.showSettings = false;
          },
          onSave: (target: number, growth: boolean) => {
            this.saveSettings(target, growth);
          }
        })
      }

      if (this.showEditor) {
        GoalEditDialog({
          initialName: this.editingName,
          initialDimension: this.editingDimension,
          initialMinutes: this.editingMinutes,
          isNew: this.editingId === 0,
          onSave: (name: string, dimension: number, minutes: number) => {
            this.saveGoal(name, dimension, minutes);
          },
          onDelete: () => {
            this.archiveGoal();
          },
          onCancel: () => {
            this.showEditor = false;
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .onAreaChange((oldValue: Area, newValue: Area) => {
      const width = Number.parseFloat(newValue.width.toString());
      this.updateLayout(width);
    })
  }
}
