import { Database } from './Database';
import { EntryRecord } from '../model/Models';

export class EntryRepository {
  static async loadRange(start: string, end: string): Promise<EntryRecord[]> {
    const store = Database.getInstance().getStore();
    const resultSet = await store.querySql(
      'SELECT goal_id, date, done, minutes FROM entries WHERE date >= ? AND date <= ?',
      [start, end]
    );
    const entries: EntryRecord[] = [];
    while (resultSet.goToNextRow()) {
      entries.push({
        goalId: resultSet.getLong(resultSet.getColumnIndex('goal_id')),
        date: resultSet.getString(resultSet.getColumnIndex('date')),
        done: resultSet.getLong(resultSet.getColumnIndex('done')),
        minutes: resultSet.getLong(resultSet.getColumnIndex('minutes'))
      });
    }
    resultSet.close();
    return entries;
  }

  static async check(goalId: number, date: string, minutes: number): Promise<void> {
    const store = Database.getInstance().getStore();
    await store.executeSql(
      'INSERT OR REPLACE INTO entries (goal_id, date, done, minutes) VALUES (?, ?, 1, ?)',
      [goalId, date, minutes]
    );
  }

  static async uncheck(goalId: number, date: string): Promise<void> {
    const store = Database.getInstance().getStore();
    await store.executeSql(
      'DELETE FROM entries WHERE goal_id = ? AND date = ?',
      [goalId, date]
    );
  }
}
