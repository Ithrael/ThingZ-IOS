import SwiftUI

// MARK: - 渐变按钮
struct GradientButton: View {
    let title: String
    let icon: String?
    let gradient: LinearGradient
    let action: () -> Void
    let isEnabled: Bool
    let isFullWidth: Bool

    init(
        title: String,
        icon: String? = nil,
        gradient: LinearGradient = Theme.Colors.pinkGradient,
        isEnabled: Bool = true,
        isFullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.gradient = gradient
        self.action = action
        self.isEnabled = isEnabled
        self.isFullWidth = isFullWidth
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.small) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: Theme.IconSize.medium))
                }
                Text(title)
                    .font(Theme.Fonts.bodyBold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.horizontal, Theme.Spacing.large)
            .padding(.vertical, Theme.Spacing.medium)
            .background(isEnabled ? gradient : LinearGradient(
                colors: [Color.gray.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .cornerRadius(Theme.CornerRadius.medium)
            .shadow(
                color: isEnabled ? Theme.Shadow.standard.color : Color.clear,
                radius: Theme.Shadow.standard.radius,
                x: Theme.Shadow.standard.x,
                y: Theme.Shadow.standard.y
            )
        }
        .disabled(!isEnabled)
    }
}

// MARK: - 标准样式按钮
struct StandardButton: View {
    let title: String
    let icon: String?
    let backgroundColor: Color
    let foregroundColor: Color
    let action: () -> Void
    let isEnabled: Bool
    let isFullWidth: Bool

    init(
        title: String,
        icon: String? = nil,
        backgroundColor: Color = Theme.Colors.pinkAccent,
        foregroundColor: Color = .white,
        isEnabled: Bool = true,
        isFullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.action = action
        self.isEnabled = isEnabled
        self.isFullWidth = isFullWidth
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.small) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: Theme.IconSize.medium))
                }
                Text(title)
                    .font(Theme.Fonts.bodyBold)
            }
            .foregroundColor(isEnabled ? foregroundColor : Color.gray)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.horizontal, Theme.Spacing.large)
            .padding(.vertical, Theme.Spacing.medium)
            .background(isEnabled ? backgroundColor : Color.gray.opacity(0.3))
            .cornerRadius(Theme.CornerRadius.medium)
            .shadow(
                color: isEnabled ? Theme.Shadow.light.color : Color.clear,
                radius: Theme.Shadow.light.radius,
                x: Theme.Shadow.light.x,
                y: Theme.Shadow.light.y
            )
        }
        .disabled(!isEnabled)
    }
}

// MARK: - 轮廓按钮
struct OutlineButton: View {
    let title: String
    let icon: String?
    let borderColor: Color
    let foregroundColor: Color
    let action: () -> Void
    let isEnabled: Bool
    let isFullWidth: Bool

    init(
        title: String,
        icon: String? = nil,
        borderColor: Color = Theme.Colors.pinkAccent,
        foregroundColor: Color = Theme.Colors.primaryText,
        isEnabled: Bool = true,
        isFullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.borderColor = borderColor
        self.foregroundColor = foregroundColor
        self.action = action
        self.isEnabled = isEnabled
        self.isFullWidth = isFullWidth
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.small) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: Theme.IconSize.medium))
                }
                Text(title)
                    .font(Theme.Fonts.bodyBold)
            }
            .foregroundColor(isEnabled ? foregroundColor : Color.gray)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.horizontal, Theme.Spacing.large)
            .padding(.vertical, Theme.Spacing.medium)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(isEnabled ? borderColor : Color.gray.opacity(0.3), lineWidth: 2)
            )
        }
        .disabled(!isEnabled)
    }
}

// MARK: - 预览
struct GradientButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            GradientButton(
                title: "粉色渐变按钮",
                icon: "heart.fill",
                gradient: Theme.Colors.pinkGradient,
                action: {}
            )

            GradientButton(
                title: "紫色渐变按钮",
                icon: "star.fill",
                gradient: Theme.Colors.purpleGradient,
                action: {}
            )

            GradientButton(
                title: "全宽按钮",
                isFullWidth: true,
                action: {}
            )

            GradientButton(
                title: "禁用按钮",
                isEnabled: false,
                action: {}
            )

            StandardButton(
                title: "标准按钮",
                icon: "checkmark",
                action: {}
            )

            OutlineButton(
                title: "轮廓按钮",
                icon: "arrow.right",
                action: {}
            )
        }
        .padding()
        .warmGradientBackground()
    }
}
