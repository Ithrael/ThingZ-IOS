import SwiftUI

/// 统一的错误提示视图组件
struct ErrorView: View {
    let message: String
    let retryAction: (() -> Void)?

    init(message: String, retryAction: (() -> Void)? = nil) {
        self.message = message
        self.retryAction = retryAction
    }

    var body: some View {
        VStack(spacing: 20) {
            // 错误图标
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.6, blue: 0.6).opacity(0.3),
                                Color(red: 1.0, green: 0.5, blue: 0.5).opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(
                        color: Color(red: 1.0, green: 0.6, blue: 0.6).opacity(0.2),
                        radius: 10,
                        x: 0,
                        y: 5
                    )

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 35))
                    .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.6))
            }

            // 错误信息
            VStack(spacing: 8) {
                Text("出错了")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            // 重试按钮
            if let retryAction = retryAction {
                Button(action: retryAction) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                            .font(.subheadline)
                        Text("重试")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.75, blue: 0.8),
                                Color(red: 1.0, green: 0.65, blue: 0.75)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(
                        color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.4),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                }
            }
        }
        .padding(.all, 30)
    }
}

/// 紧凑型错误提示组件
struct CompactErrorView: View {
    let message: String
    let retryAction: (() -> Void)?

    init(message: String, retryAction: (() -> Void)? = nil) {
        self.message = message
        self.retryAction = retryAction
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.title3)
                .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.6))

            Text(message)
                .font(.subheadline)
                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                .lineLimit(2)

            Spacer()

            if let retryAction = retryAction {
                Button(action: retryAction) {
                    Text("重试")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                }
            }
        }
        .padding(.all, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.9))
                .shadow(
                    color: Color(red: 1.0, green: 0.6, blue: 0.6).opacity(0.2),
                    radius: 6,
                    x: 0,
                    y: 3
                )
        )
        .padding(.horizontal, 16)
    }
}

/// 内联错误提示组件
struct InlineErrorView: View {
    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.caption)
                .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.6))

            Text(message)
                .font(.caption)
                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color(red: 1.0, green: 0.9, blue: 0.9))
        )
    }
}

/// 成功提示组件
struct SuccessView: View {
    let message: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundColor(Color(red: 0.7, green: 0.9, blue: 0.7))

            Text(message)
                .font(.subheadline)
                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))

            Spacer()
        }
        .padding(.all, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.9))
                .shadow(
                    color: Color(red: 0.7, green: 0.9, blue: 0.7).opacity(0.3),
                    radius: 6,
                    x: 0,
                    y: 3
                )
        )
        .padding(.horizontal, 16)
    }
}

/// 加载状态组件
struct LoadingView: View {
    let message: String

    init(message: String = "加载中...") {
        self.message = message
    }

    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 1.0, green: 0.75, blue: 0.8)))
                .scaleEffect(1.5)

            Text(message)
                .font(.subheadline)
                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// 空状态组件
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.9, blue: 0.95),
                                Color(red: 1.0, green: 0.85, blue: 0.9)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(
                        color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.3),
                        radius: 15,
                        x: 0,
                        y: 8
                    )

                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
            }

            VStack(spacing: 12) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))

                Text(message)
                    .font(.body)
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.75, blue: 0.8),
                                    Color(red: 1.0, green: 0.65, blue: 0.75)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(
                            color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.4),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                }
            }
        }
        .padding(.all, 30)
    }
}

// MARK: - Preview
#Preview("Error View") {
    VStack(spacing: 40) {
        ErrorView(message: "网络连接失败，请检查网络设置") {
            print("重试")
        }

        CompactErrorView(message: "加载失败，请稍后重试") {
            print("重试")
        }

        InlineErrorView(message: "输入格式不正确")

        SuccessView(message: "操作成功完成")

        EmptyStateView(
            icon: "heart.circle",
            title: "还没有数据",
            message: "添加第一个项目开始吧",
            actionTitle: "添加项目"
        ) {
            print("添加项目")
        }
    }
    .padding()
    .background(
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 1.0, green: 0.97, blue: 0.86),
                Color(red: 1.0, green: 0.95, blue: 0.9)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
