@Observed
export class DayCell {
  date: string = '';
  weekday: string = '';
  dayOfMonth: string = '';
  checked: boolean = false;
  minutes: number = 0;
}

@Observed
export class GoalItem {
  id: number = 0;
  name: string = '';
  dimension: number = 0;
  defaultMinutes: number = 30;
  position: number = 0;
  cells: DayCell[] = [];
  ringProgress: number = 0;
}

@Observed
export class DailySummary {
  totalMinutes: number = 0;
  targetMinutes: number = 60;
  dimensionMinutes: number[] = [0, 0, 0, 0];
  checkedCount: number = 0;
  progress: number = 0;
  remaining: number = 60;
  over: number = 0;
}

export class DayHeader {
  weekday: string = '';
  dayOfMonth: string = '';
  isToday: boolean = false;
}

export interface GoalRecord {
  id: number;
  name: string;
  dimension: number;
  defaultMinutes: number;
  position: number;
}

export interface EntryRecord {
  goalId: number;
  date: string;
  done: number;
  minutes: number;
}

export class GoalEditParam {
  goalId: number = 0;

  constructor(goalId: number) {
    this.goalId = goalId;
  }
}
