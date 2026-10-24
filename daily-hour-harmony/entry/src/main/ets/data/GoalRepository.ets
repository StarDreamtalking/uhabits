import relationalStore from '@ohos.data.relationalStore';
import { Database } from './Database';
import { GoalRecord } from '../model/Models';

export class GoalRepository {
  static async loadActive(): Promise<GoalRecord[]> {
    const store = Database.getInstance().getStore();
    const resultSet = await store.querySql(
      'SELECT id, name, dimension, default_minutes, position FROM goals ' +
        'WHERE archived = 0 ORDER BY position ASC, id ASC'
    );
    const goals: GoalRecord[] = [];
    while (resultSet.goToNextRow()) {
      goals.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        dimension: resultSet.getLong(resultSet.getColumnIndex('dimension')),
        defaultMinutes: resultSet.getLong(resultSet.getColumnIndex('default_minutes')),
        position: resultSet.getLong(resultSet.getColumnIndex('position'))
      });
    }
    resultSet.close();
    return goals;
  }

  static async findById(id: number): Promise<GoalRecord | null> {
    const store = Database.getInstance().getStore();
    const resultSet = await store.querySql(
      'SELECT id, name, dimension, default_minutes, position FROM goals WHERE id = ?',
      [id]
    );
    let goal: GoalRecord | null = null;
    if (resultSet.goToNextRow()) {
      goal = {
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        dimension: resultSet.getLong(resultSet.getColumnIndex('dimension')),
        defaultMinutes: resultSet.getLong(resultSet.getColumnIndex('default_minutes')),
        position: resultSet.getLong(resultSet.getColumnIndex('position'))
      };
    }
    resultSet.close();
    return goal;
  }

  static async insert(name: string, dimension: number, defaultMinutes: number): Promise<number> {
    const store = Database.getInstance().getStore();
    const values: relationalStore.ValuesBucket = {
      name: name,
      dimension: dimension,
      default_minutes: defaultMinutes,
      position: Date.now(),
      archived: 0,
      created_at: Date.now()
    };
    return await store.insert('goals', values);
  }

  static async update(id: number, name: string, dimension: number,
    defaultMinutes: number): Promise<void> {
    const store = Database.getInstance().getStore();
    const values: relationalStore.ValuesBucket = {
      name: name,
      dimension: dimension,
      default_minutes: defaultMinutes
    };
    const predicates = new relationalStore.RdbPredicates('goals');
    predicates.equalTo('id', id);
    await store.update(values, predicates);
  }

  static async archive(id: number): Promise<void> {
    const store = Database.getInstance().getStore();
    const values: relationalStore.ValuesBucket = {
      archived: 1
    };
    const predicates = new relationalStore.RdbPredicates('goals');
    predicates.equalTo('id', id);
    await store.update(values, predicates);
  }
}
