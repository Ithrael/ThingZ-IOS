import SwiftUI

// MARK: - 主题配置
struct Theme {
    // MARK: - 颜色定义
    struct Colors {
        // MARK: - 主色调
        static let creamBackground = Color(red: 1.0, green: 0.97, blue: 0.86)
        static let peachBackground = Color(red: 1.0, green: 0.95, blue: 0.9)
        static let pinkAccent = Color(red: 1.0, green: 0.75, blue: 0.8)
        static let blueAccent = Color(red: 0.4, green: 0.7, blue: 0.9)

        // MARK: - 渐变色
        static let warmGradient = LinearGradient(
            colors: [creamBackground, peachBackground],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let pinkGradient = LinearGradient(
            colors: [Color(red: 1.0, green: 0.85, blue: 0.9), pinkAccent],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let purpleGradient = LinearGradient(
            colors: [Color(red: 0.9, green: 0.8, blue: 0.95), Color(red: 0.85, green: 0.7, blue: 0.9)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let cyanGradient = LinearGradient(
            colors: [Color(red: 0.85, green: 0.95, blue: 0.95), Color(red: 0.7, green: 0.9, blue: 0.9)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        // MARK: - 文字颜色
        static let primaryText = Color(red: 0.4, green: 0.2, blue: 0.1)
        static let secondaryText = Color(red: 0.6, green: 0.4, blue: 0.3)
        static let tertiaryText = Color.gray.opacity(0.6)

        // MARK: - 功能色
        static let successGreen = Color(red: 0.7, green: 0.9, blue: 0.7)
        static let warningYellow = Color(red: 1.0, green: 0.8, blue: 0.4)
        static let errorRed = Color(red: 1.0, green: 0.6, blue: 0.6)
        static let infoPurple = Color(red: 0.85, green: 0.7, blue: 0.9)
        static let infoCyan = Color(red: 0.7, green: 0.9, blue: 0.9)

        // MARK: - 卡片和背景色
        static let cardBackground = Color.white
        static let cardShadow = Color.black.opacity(0.1)
        static let overlay = Color.black.opacity(0.3)
    }

    // MARK: - 圆角规范
    struct CornerRadius {
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 20
        static let extraLarge: CGFloat = 24
    }

    // MARK: - 阴影规范
    struct Shadow {
        /// 标准阴影
        static let standard: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = (
            Color.black.opacity(0.1), 8, 0, 4
        )

        /// 深阴影
        static let deep: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = (
            Color.black.opacity(0.2), 12, 0, 6
        )

        /// 轻阴影
        static let light: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = (
            Color.black.opacity(0.05), 4, 0, 2
        )
    }

    // MARK: - 间距规范
    struct Spacing {
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
        static let huge: CGFloat = 48
    }

    // MARK: - 字体规范
    struct Fonts {
        // 标题
        static let largeTitle = Font.system(size: 34, weight: .bold)
        static let title1 = Font.system(size: 28, weight: .bold)
        static let title2 = Font.system(size: 22, weight: .bold)
        static let title3 = Font.system(size: 20, weight: .semibold)

        // 正文
        static let body = Font.system(size: 17, weight: .regular)
        static let bodyBold = Font.system(size: 17, weight: .semibold)

        // 次要文字
        static let callout = Font.system(size: 16, weight: .regular)
        static let subheadline = Font.system(size: 15, weight: .regular)
        static let footnote = Font.system(size: 13, weight: .regular)
        static let caption1 = Font.system(size: 12, weight: .regular)
        static let caption2 = Font.system(size: 11, weight: .regular)
    }

    // MARK: - 图标尺寸
    struct IconSize {
        static let small: CGFloat = 16
        static let medium: CGFloat = 20
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
        static let huge: CGFloat = 48
    }

    // MARK: - 动画配置
    struct Animation {
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
    }
}

// MARK: - View扩展 - 应用主题样式
extension View {
    /// 应用卡片样式
    func cardStyle(
        padding: CGFloat = Theme.Spacing.medium,
        cornerRadius: CGFloat = Theme.CornerRadius.medium
    ) -> some View {
        self
            .padding(padding)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(cornerRadius)
            .shadow(
                color: Theme.Shadow.standard.color,
                radius: Theme.Shadow.standard.radius,
                x: Theme.Shadow.standard.x,
                y: Theme.Shadow.standard.y
            )
    }

    /// 应用轻量卡片样式
    func lightCardStyle(
        padding: CGFloat = Theme.Spacing.medium,
        cornerRadius: CGFloat = Theme.CornerRadius.medium
    ) -> some View {
        self
            .padding(padding)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(cornerRadius)
            .shadow(
                color: Theme.Shadow.light.color,
                radius: Theme.Shadow.light.radius,
                x: Theme.Shadow.light.x,
                y: Theme.Shadow.light.y
            )
    }

    /// 应用深阴影卡片样式
    func deepCardStyle(
        padding: CGFloat = Theme.Spacing.medium,
        cornerRadius: CGFloat = Theme.CornerRadius.medium
    ) -> some View {
        self
            .padding(padding)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(cornerRadius)
            .shadow(
                color: Theme.Shadow.deep.color,
                radius: Theme.Shadow.deep.radius,
                x: Theme.Shadow.deep.x,
                y: Theme.Shadow.deep.y
            )
    }

    /// 应用主要文字样式
    func primaryTextStyle() -> some View {
        self
            .font(Theme.Fonts.body)
            .foregroundColor(Theme.Colors.primaryText)
    }

    /// 应用次要文字样式
    func secondaryTextStyle() -> some View {
        self
            .font(Theme.Fonts.subheadline)
            .foregroundColor(Theme.Colors.secondaryText)
    }

    /// 应用标题样式
    func titleStyle() -> some View {
        self
            .font(Theme.Fonts.title2)
            .foregroundColor(Theme.Colors.primaryText)
            .fontWeight(.bold)
    }
}

// MARK: - 预定义渐变背景
extension View {
    /// 应用温暖渐变背景
    func warmGradientBackground() -> some View {
        self.background(Theme.Colors.warmGradient.ignoresSafeArea())
    }

    /// 应用粉色渐变背景
    func pinkGradientBackground() -> some View {
        self.background(Theme.Colors.pinkGradient.ignoresSafeArea())
    }

    /// 应用紫色渐变背景
    func purpleGradientBackground() -> some View {
        self.background(Theme.Colors.purpleGradient.ignoresSafeArea())
    }

    /// 应用青色渐变背景
    func cyanGradientBackground() -> some View {
        self.background(Theme.Colors.cyanGradient.ignoresSafeArea())
    }
}
