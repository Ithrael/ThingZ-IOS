import SwiftUI

// MARK: - 统一卡片视图
struct CardView<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    let shadowStyle: ShadowStyle

    enum ShadowStyle {
        case light
        case standard
        case deep
    }

    init(
        padding: CGFloat = Theme.Spacing.medium,
        cornerRadius: CGFloat = Theme.CornerRadius.medium,
        shadowStyle: ShadowStyle = .standard,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadowStyle = shadowStyle
    }

    var body: some View {
        content
            .padding(padding)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(cornerRadius)
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: shadowX,
                y: shadowY
            )
    }

    private var shadowColor: Color {
        switch shadowStyle {
        case .light:
            return Theme.Shadow.light.color
        case .standard:
            return Theme.Shadow.standard.color
        case .deep:
            return Theme.Shadow.deep.color
        }
    }

    private var shadowRadius: CGFloat {
        switch shadowStyle {
        case .light:
            return Theme.Shadow.light.radius
        case .standard:
            return Theme.Shadow.standard.radius
        case .deep:
            return Theme.Shadow.deep.radius
        }
    }

    private var shadowX: CGFloat {
        switch shadowStyle {
        case .light:
            return Theme.Shadow.light.x
        case .standard:
            return Theme.Shadow.standard.x
        case .deep:
            return Theme.Shadow.deep.x
        }
    }

    private var shadowY: CGFloat {
        switch shadowStyle {
        case .light:
            return Theme.Shadow.light.y
        case .standard:
            return Theme.Shadow.standard.y
        case .deep:
            return Theme.Shadow.deep.y
        }
    }
}

// MARK: - 预览
struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CardView(shadowStyle: .light) {
                Text("轻量阴影卡片")
                    .primaryTextStyle()
            }

            CardView(shadowStyle: .standard) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("标准卡片")
                        .titleStyle()
                    Text("这是一个标准阴影的卡片示例")
                        .secondaryTextStyle()
                }
            }

            CardView(shadowStyle: .deep) {
                Text("深阴影卡片")
                    .primaryTextStyle()
            }
        }
        .padding()
        .warmGradientBackground()
    }
}
