import { DIMENSION_SHORT_NAMES, dimensionColor } from '../utils/Dimensions';
import promptAction from '@ohos.promptAction';

const MIN_MINUTES: number = 5;
const MAX_MINUTES: number = 180;
const STEP_MINUTES: number = 5;

@Component
export struct GoalEditDialog {
  @Prop initialName: string = '';
  @Prop initialDimension: number = 0;
  @Prop initialMinutes: number = 30;
  @Prop isNew: boolean = true;
  onSave: (name: string, dimension: number, minutes: number) => void = () => {
  };
  onDelete: () => void = () => {
  };
  onCancel: () => void = () => {
  };

  @State name: string = '';
  @State dimension: number = 0;
  @State minutes: number = 30;

  aboutToAppear(): void {
    this.name = this.initialName;
    this.dimension = this.initialDimension;
    this.minutes = this.initialMinutes;
  }

  private changeMinutes(delta: number): void {
    const next = this.minutes + delta;
    if (next < MIN_MINUTES) {
      this.minutes = MIN_MINUTES;
      return;
    }
    if (next > MAX_MINUTES) {
      this.minutes = MAX_MINUTES;
      return;
    }
    this.minutes = next;
  }

  private handleSave(): void {
    const trimmed = this.name.trim();
    if (trimmed.length === 0) {
      promptAction.showToast({ message: '请填写目标名称' });
      return;
    }
    this.onSave(trimmed, this.dimension, this.minutes);
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#66000000')

      Column() {
        Text(this.isNew ? '新建目标' : '编辑目标')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .width('100%')

        Text('目标名称')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
          .margin({ top: 20 })

        TextInput({ text: this.name, placeholder: '例如：阅读 30 分钟' })
          .width('100%')
          .height(44)
          .fontSize(16)
          .backgroundColor($r('app.color.page_bg'))
          .borderRadius(10)
          .margin({ top: 8 })
          .onChange((value: string) => {
            this.name = value;
          })

        Text('所属维度')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
          .margin({ top: 20 })

        Row({ space: 8 }) {
          ForEach([0, 1, 2, 3], (index: number) => {
            Text(DIMENSION_SHORT_NAMES[index])
              .fontSize(13)
              .fontColor(this.dimension === index
                ? Color.White
                : $r('app.color.text_primary'))
              .textAlign(TextAlign.Center)
              .layoutWeight(1)
              .height(36)
              .borderRadius(18)
              .backgroundColor(this.dimension === index
                ? dimensionColor(index)
                : $r('app.color.page_bg'))
              .onClick(() => {
                this.dimension = index;
              })
          }, (index: number) => index.toString())
        }
        .width('100%')
        .margin({ top: 8 })

        Row() {
          Text('默认用时')
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
          Blank()
          Text(`${this.minutes} 分钟`)
            .fontSize(13)
            .fontColor($r('app.color.text_primary'))
        }
        .width('100%')
        .margin({ top: 20 })

        Row({ space: 16 }) {
          Button('−')
            .width(48)
            .height(36)
            .fontSize(20)
            .fontColor($r('app.color.text_primary'))
            .backgroundColor($r('app.color.page_bg'))
            .onClick(() => this.changeMinutes(-STEP_MINUTES))

          Text(`${this.minutes}`)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Button('+')
            .width(48)
            .height(36)
            .fontSize(20)
            .fontColor($r('app.color.text_primary'))
            .backgroundColor($r('app.color.page_bg'))
            .onClick(() => this.changeMinutes(STEP_MINUTES))
        }
        .width('100%')
        .margin({ top: 8 })

        Text('打卡完成后，按默认用时计入「今日一小时」。修改默认用时不影响已打卡记录。')
          .fontSize(11)
          .fontColor($r('app.color.text_tertiary'))
          .width('100%')
          .margin({ top: 8 })

        if (!this.isNew) {
          Button('归档目标')
            .width('100%')
            .height(40)
            .fontSize(14)
            .fontColor($r('app.color.danger'))
            .backgroundColor(Color.Transparent)
            .margin({ top: 16 })
            .onClick(() => this.onDelete())
        }

        Row({ space: 12 }) {
          Button('取消')
            .layoutWeight(1)
            .height(40)
            .fontSize(14)
            .fontColor($r('app.color.text_primary'))
            .backgroundColor($r('app.color.page_bg'))
            .onClick(() => this.onCancel())

          Button('保存')
            .layoutWeight(1)
            .height(40)
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor($r('app.color.accent'))
            .onClick(() => this.handleSave())
        }
        .width('100%')
        .margin({ top: this.isNew ? 28 : 12 })
      }
      .width('88%')
      .constraintSize({ maxWidth: 420 })
      .padding(20)
      .backgroundColor($r('app.color.card_bg'))
      .borderRadius(16)
      .shadow({ radius: 8, color: '#22000000', offsetY: 4 })
    }
    .width('100%')
    .height('100%')
  }
}
