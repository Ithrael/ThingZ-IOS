import SwiftUI

// MARK: - 统一输入框
struct InputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String?
    let isSecure: Bool
    let keyboardType: UIKeyboardType

    init(
        title: String,
        placeholder: String,
        text: Binding<String>,
        icon: String? = nil,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.isSecure = isSecure
        self.keyboardType = keyboardType
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text(title)
                .font(Theme.Fonts.subheadline)
                .foregroundColor(Theme.Colors.secondaryText)

            HStack(spacing: Theme.Spacing.small) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(Theme.Colors.secondaryText)
                        .frame(width: Theme.IconSize.medium)
                }

                if isSecure {
                    SecureField(placeholder, text: $text)
                        .font(Theme.Fonts.body)
                        .foregroundColor(Theme.Colors.primaryText)
                        .keyboardType(keyboardType)
                } else {
                    TextField(placeholder, text: $text)
                        .font(Theme.Fonts.body)
                        .foregroundColor(Theme.Colors.primaryText)
                        .keyboardType(keyboardType)
                }
            }
            .padding(Theme.Spacing.medium)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.small)
            .shadow(
                color: Theme.Shadow.light.color,
                radius: Theme.Shadow.light.radius,
                x: Theme.Shadow.light.x,
                y: Theme.Shadow.light.y
            )
        }
    }
}

// MARK: - 多行文本输入框
struct TextAreaField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let height: CGFloat

    init(
        title: String,
        placeholder: String,
        text: Binding<String>,
        height: CGFloat = 100
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.height = height
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text(title)
                .font(Theme.Fonts.subheadline)
                .foregroundColor(Theme.Colors.secondaryText)

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(Theme.Fonts.body)
                        .foregroundColor(Theme.Colors.tertiaryText)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                }

                TextEditor(text: $text)
                    .font(Theme.Fonts.body)
                    .foregroundColor(Theme.Colors.primaryText)
                    .frame(height: height)
                    .scrollContentBackground(.hidden)
            }
            .padding(Theme.Spacing.medium)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.small)
            .shadow(
                color: Theme.Shadow.light.color,
                radius: Theme.Shadow.light.radius,
                x: Theme.Shadow.light.x,
                y: Theme.Shadow.light.y
            )
        }
    }
}

// MARK: - 预览
struct InputField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            InputField(
                title: "用户名",
                placeholder: "请输入用户名",
                text: .constant(""),
                icon: "person.fill"
            )

            InputField(
                title: "密码",
                placeholder: "请输入密码",
                text: .constant(""),
                icon: "lock.fill",
                isSecure: true
            )

            InputField(
                title: "邮箱",
                placeholder: "请输入邮箱",
                text: .constant(""),
                icon: "envelope.fill",
                keyboardType: .emailAddress
            )

            TextAreaField(
                title: "描述",
                placeholder: "请输入描述信息...",
                text: .constant("")
            )
        }
        .padding()
        .warmGradientBackground()
    }
}
