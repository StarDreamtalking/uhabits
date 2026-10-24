import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';

const DB_NAME: string = 'daily_hour.db';
const DB_VERSION: number = 1;

const CREATE_GOALS: string = `
CREATE TABLE IF NOT EXISTS goals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    dimension INTEGER NOT NULL,
    default_minutes INTEGER NOT NULL DEFAULT 30,
    position INTEGER NOT NULL DEFAULT 0,
    archived INTEGER NOT NULL DEFAULT 0,
    created_at INTEGER NOT NULL
)`;

const CREATE_ENTRIES: string = `
CREATE TABLE IF NOT EXISTS entries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    goal_id INTEGER NOT NULL,
    date TEXT NOT NULL,
    done INTEGER NOT NULL DEFAULT 1,
    minutes INTEGER NOT NULL DEFAULT 0,
    UNIQUE (goal_id, date)
)`;

const CREATE_ENTRY_INDEX: string = `
CREATE INDEX IF NOT EXISTS idx_entries_date ON entries(date)`;

export class Database {
  private static instance: Database | null = null;
  private store: relationalStore.RdbStore | null = null;
  private initPromise: Promise<void> | null = null;

  static getInstance(): Database {
    if (Database.instance === null) {
      Database.instance = new Database();
    }
    return Database.instance;
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.store !== null) {
      return;
    }
    if (this.initPromise !== null) {
      await this.initPromise;
      return;
    }
    this.initPromise = this.doInit(context);
    try {
      await this.initPromise;
    } catch (error) {
      this.initPromise = null;
      throw error;
    }
  }

  private async doInit(context: common.UIAbilityContext): Promise<void> {
    const config: relationalStore.StoreConfig = {
      name: DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };
    const store = await relationalStore.getRdbStore(context, config);
    await store.executeSql(CREATE_GOALS);
    await store.executeSql(CREATE_ENTRIES);
    await store.executeSql(CREATE_ENTRY_INDEX);
    store.version = DB_VERSION;
    this.store = store;
  }

  getStore(): relationalStore.RdbStore {
    if (this.store === null) {
      throw new Error('数据库尚未初始化');
    }
    return this.store;
  }
}
