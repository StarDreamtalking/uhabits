import { DailySummary, GoalItem } from '../model/Models';

export function buildSummary(goals: GoalItem[], todayMinutes: Map<number, number>,
  targetMinutes: number): DailySummary {
  const summary = new DailySummary();
  summary.targetMinutes = targetMinutes;

  let total = 0;
  let checkedCount = 0;
  const dimensions: number[] = [0, 0, 0, 0];

  for (let i = 0; i < goals.length; i++) {
    const goal = goals[i];
    const minutes = todayMinutes.get(goal.id);
    if (minutes !== undefined && minutes > 0) {
      total += minutes;
      checkedCount++;
      if (goal.dimension >= 0 && goal.dimension < 4) {
        dimensions[goal.dimension] += minutes;
      }
    }
  }

  summary.totalMinutes = total;
  summary.dimensionMinutes = dimensions;
  summary.checkedCount = checkedCount;
  summary.progress = targetMinutes <= 0 ? 0 : Math.min(1, total / targetMinutes);
  summary.remaining = Math.max(0, targetMinutes - total);
  summary.over = Math.max(0, total - targetMinutes);
  return summary;
}
