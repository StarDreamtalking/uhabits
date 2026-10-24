export const WEEKDAY_LABELS: string[] = ['日', '一', '二', '三', '四', '五', '六'];

function pad2(value: number): string {
  return value < 10 ? `0${value}` : `${value}`;
}

export function toDateString(date: Date): string {
  return `${date.getFullYear()}-${pad2(date.getMonth() + 1)}-${pad2(date.getDate())}`;
}

export function addDays(date: Date, days: number): Date {
  const result = new Date(date.getFullYear(), date.getMonth(), date.getDate());
  result.setDate(result.getDate() + days);
  return result;
}

export function buildLastDates(count: number): Date[] {
  const today = new Date();
  const dates: Date[] = [];
  for (let i = count - 1; i >= 0; i--) {
    dates.push(addDays(today, -i));
  }
  return dates;
}

export function weekdayLabel(date: Date): string {
  return WEEKDAY_LABELS[date.getDay()];
}

export function dayOfMonthLabel(date: Date): string {
  return `${date.getDate()}`;
}
