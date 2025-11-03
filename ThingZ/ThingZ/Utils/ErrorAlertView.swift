import SwiftUI

// MARK: - 错误提示修饰符
struct ErrorAlert: ViewModifier {
    @Binding var errorMessage: String?
    var onDismiss: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .alert("错误", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil; onDismiss?() } }
            )) {
                Button("确定", role: .cancel) {
                    errorMessage = nil
                    onDismiss?()
                }
            } message: {
                if let message = errorMessage {
                    Text(message)
                }
            }
    }
}

// MARK: - 成功提示修饰符
struct SuccessAlert: ViewModifier {
    @Binding var successMessage: String?
    var onDismiss: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .alert("成功", isPresented: Binding(
                get: { successMessage != nil },
                set: { if !$0 { successMessage = nil; onDismiss?() } }
            )) {
                Button("确定", role: .cancel) {
                    successMessage = nil
                    onDismiss?()
                }
            } message: {
                if let message = successMessage {
                    Text(message)
                }
            }
    }
}

// MARK: - Toast样式提示
struct ToastView: View {
    let message: String
    let type: ToastType

    enum ToastType {
        case success
        case error
        case info

        var color: Color {
            switch self {
            case .success:
                return .green
            case .error:
                return .red
            case .info:
                return .blue
            }
        }

        var icon: String {
            switch self {
            case .success:
                return "checkmark.circle.fill"
            case .error:
                return "xmark.circle.fill"
            case .info:
                return "info.circle.fill"
            }
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .font(.title2)
                .foregroundColor(.white)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding()
        .background(type.color.opacity(0.9))
        .cornerRadius(12)
        .shadow(color: type.color.opacity(0.3), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
}

// MARK: - Toast修饰符
struct ToastModifier: ViewModifier {
    @Binding var toast: Toast?

    func body(content: Content) -> some View {
        ZStack {
            content

            if let toast = toast {
                VStack {
                    ToastView(message: toast.message, type: toast.type)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration) {
                                withAnimation {
                                    self.toast = nil
                                }
                            }
                        }
                    Spacer()
                }
                .animation(.spring(), value: toast != nil)
            }
        }
    }
}

struct Toast: Equatable {
    let message: String
    let type: ToastView.ToastType
    let duration: Double

    init(message: String, type: ToastView.ToastType = .info, duration: Double = 2.0) {
        self.message = message
        self.type = type
        self.duration = duration
    }
}

// MARK: - View扩展
extension View {
    func errorAlert(_ errorMessage: Binding<String?>, onDismiss: (() -> Void)? = nil) -> some View {
        modifier(ErrorAlert(errorMessage: errorMessage, onDismiss: onDismiss))
    }

    func successAlert(_ successMessage: Binding<String?>, onDismiss: (() -> Void)? = nil) -> some View {
        modifier(SuccessAlert(successMessage: successMessage, onDismiss: onDismiss))
    }

    func toast(_ toast: Binding<Toast?>) -> some View {
        modifier(ToastModifier(toast: toast))
    }
}

// Note: LoadingView and EmptyStateView are now defined in ErrorView.swift
// to avoid duplicate declarations. Please use those instead.
