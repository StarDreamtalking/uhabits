@Component
export struct SettingsPanel {
  @Prop initialTarget: number = 60;
  @Prop initialGrowth: boolean = true;
  onCancel: () => void = () => {
  };
  onSave: (target: number, growth: boolean) => void = () => {
  };
  @State target: number = 60;
  @State growth: boolean = true;

  aboutToAppear(): void {
    this.target = this.initialTarget;
    this.growth = this.initialGrowth;
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#66000000')
        .onClick(() => {
        })

      Column() {
        Text('设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .width('100%')

        Row() {
          Text('每日目标')
            .fontSize(14)
            .fontColor($r('app.color.text_primary'))
          Blank()
          Text(`${this.target} 分钟`)
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .margin({ top: 24 })

        Slider({
          value: this.target,
          min: 15,
          max: 240,
          step: 5,
          style: SliderStyle.OutSet
        })
          .width('100%')
          .selectedColor($r('app.color.accent'))
          .onChange((value: number, mode: SliderChangeMode) => {
            this.target = Math.round(value);
          })

        Row() {
          Text('成长模式')
            .fontSize(14)
            .fontColor($r('app.color.text_primary'))
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: this.growth })
            .selectedColor($r('app.color.accent'))
            .onChange((isOn: boolean) => {
              this.growth = isOn;
            })
        }
        .width('100%')
        .margin({ top: 8 })

        Text('关闭后隐藏今日一小时卡片，只保留习惯列表。')
          .fontSize(11)
          .fontColor($r('app.color.text_tertiary'))
          .width('100%')
          .margin({ top: 4 })

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
            .onClick(() => this.onSave(this.target, this.growth))
        }
        .width('100%')
        .margin({ top: 24 })
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
