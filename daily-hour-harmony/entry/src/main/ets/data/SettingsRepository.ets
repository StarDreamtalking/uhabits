import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

const PREF_NAME: string = 'daily_hour_settings';
const KEY_TARGET_MINUTES: string = 'targetMinutes';
const KEY_GROWTH_MODE: string = 'growthMode';

export class SettingsRepository {
  private static prefs: preferences.Preferences | null = null;

  static async init(context: common.UIAbilityContext): Promise<void> {
    if (SettingsRepository.prefs === null) {
      SettingsRepository.prefs =
        await preferences.getPreferences(context, PREF_NAME);
    }
  }

  static async getTargetMinutes(): Promise<number> {
    if (SettingsRepository.prefs === null) {
      return 60;
    }
    const value = await SettingsRepository.prefs.get(KEY_TARGET_MINUTES, 60);
    if (typeof value === 'number') {
      return value;
    }
    return 60;
  }

  static async setTargetMinutes(value: number): Promise<void> {
    if (SettingsRepository.prefs === null) {
      return;
    }
    await SettingsRepository.prefs.put(KEY_TARGET_MINUTES, value);
    await SettingsRepository.prefs.flush();
  }

  static async getGrowthMode(): Promise<boolean> {
    if (SettingsRepository.prefs === null) {
      return true;
    }
    const value = await SettingsRepository.prefs.get(KEY_GROWTH_MODE, true);
    if (typeof value === 'boolean') {
      return value;
    }
    return true;
  }

  static async setGrowthMode(value: boolean): Promise<void> {
    if (SettingsRepository.prefs === null) {
      return;
    }
    await SettingsRepository.prefs.put(KEY_GROWTH_MODE, value);
    await SettingsRepository.prefs.flush();
  }
}
