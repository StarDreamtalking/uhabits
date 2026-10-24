import UIAbility from '@ohos.app.ability.UIAbility';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import Want from '@ohos.app.ability.Want';
import window from '@ohos.window';
import hilog from '@ohos.hilog';
import { Database } from '../data/Database';
import { SettingsRepository } from '../data/SettingsRepository';

const DOMAIN: number = 0x0001;
const TAG: string = 'DailyHour';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, 'EntryAbility onCreate');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    try {
      await Database.getInstance().init(this.context);
      await SettingsRepository.init(this.context);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `初始化数据失败: ${JSON.stringify(error)}`);
    }

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, `加载页面失败: ${JSON.stringify(err)}`);
        return;
      }
      hilog.info(DOMAIN, TAG, '页面加载完成');
    });

    try {
      const mainWindow = windowStage.getMainWindowSync();
      await mainWindow.setWindowBackgroundColor('#F2F2F2');
      await mainWindow.setWindowSystemBarProperties({
        statusBarColor: '#303030',
        statusBarContentColor: '#FFFFFF'
      });
    } catch (error) {
      hilog.error(DOMAIN, TAG, `设置窗口属性失败: ${JSON.stringify(error)}`);
    }
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, TAG, 'EntryAbility onWindowStageDestroy');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, 'EntryAbility onDestroy');
  }
}
