import SwiftUI

struct CabinDetailView: View {
    let cabinId: String
    @StateObject private var viewModel: CabinDetailViewModel
    @State private var showingInviteMember = false
    @State private var toast: Toast?

    init(cabinId: String) {
        self.cabinId = cabinId
        _viewModel = StateObject(wrappedValue: CabinDetailViewModel(cabinId: cabinId))
    }

    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.97, blue: 0.86),
                    Color(red: 1.0, green: 0.95, blue: 0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if viewModel.isLoading {
                LoadingView(message: "加载中...")
            } else if let cabin = viewModel.cabin {
                ScrollView {
                    VStack(spacing: 24) {
                        // 小屋信息卡片
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 1.0, green: 0.82, blue: 0.86),
                                                    Color(red: 1.0, green: 0.75, blue: 0.8)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 60, height: 60)

                                    Image(systemName: "house.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(cabin.name)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))

                                    if let description = cabin.description {
                                        Text(description)
                                            .font(.subheadline)
                                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                                    }

                                    Text("由 \(cabin.ownerNick ?? "未知") 创建")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()
                            }

                            // 成员统计
                            HStack(spacing: 20) {
                                StatItem(icon: "person.2.fill", title: "成员", value: "\(cabin.currentMembers)/\(cabin.maxMembers)")
                                StatItem(icon: "calendar", title: "创建时间", value: formatDate(cabin.createdAt))
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.8))
                                .shadow(color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2), radius: 10, x: 0, y: 5)
                        )

                        // 成员列表
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("成员列表")
                                    .font(.headline)
                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))

                                Spacer()

                                Button(action: { showingInviteMember = true }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "person.badge.plus")
                                        Text("邀请")
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                                }
                            }

                            ForEach(viewModel.members, id: \.id) { member in
                                MemberRow(member: member, viewModel: viewModel)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.8))
                                .shadow(color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2), radius: 10, x: 0, y: 5)
                        )
                    }
                    .padding()
                }
                .refreshable {
                    await viewModel.refresh()
                }
            } else {
                EmptyStateView(
                    icon: "exclamationmark.triangle",
                    title: "加载失败",
                    message: "无法加载小屋详情",
                    actionTitle: "重试",
                    action: {
                        Task {
                            await viewModel.loadCabinDetail()
                        }
                    }
                )
            }
        }
        .navigationTitle("小屋详情")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadCabinDetail()
        }
        .sheet(isPresented: $showingInviteMember) {
            InviteMemberView(viewModel: viewModel)
        }
        .errorAlert($viewModel.errorMessage)
        .toast($toast)
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .short
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - 统计项
struct StatItem: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
}

// MARK: - 成员行
struct MemberRow: View {
    let member: APICabinMember
    @ObservedObject var viewModel: CabinDetailViewModel
    @State private var showingActionSheet = false

    var body: some View {
        HStack(spacing: 12) {
            // 头像
            if let avatarUrl = member.avatarUrl, let url = URL(string: avatarUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                        )
                }
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                    )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(member.userNick ?? "未知")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))

                HStack(spacing: 4) {
                    Image(systemName: permissionIcon(member.permission))
                        .font(.caption2)
                    Text(permissionName(member.permission))
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }

            Spacer()

            if member.permission != "owner" {
                Button(action: { showingActionSheet = true }) {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(title: Text("管理成员"), buttons: [
                .default(Text("更改权限")) {
                    // TODO: 实现更改权限
                },
                .destructive(Text("移除成员")) {
                    Task {
                        do {
                            try await viewModel.removeMember(userId: member.userId)
                        } catch {
                            viewModel.errorMessage = error.localizedDescription
                        }
                    }
                },
                .cancel()
            ])
        }
    }

    private func permissionIcon(_ permission: String) -> String {
        switch permission {
        case "owner": return "crown.fill"
        case "admin": return "person.badge.key.fill"
        case "write": return "pencil.circle.fill"
        case "read": return "eye.fill"
        default: return "person.fill"
        }
    }

    private func permissionName(_ permission: String) -> String {
        CabinPermission(rawValue: permission)?.displayName ?? "未知"
    }
}

// MARK: - 邀请成员视图
struct InviteMemberView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: CabinDetailViewModel

    @State private var inviteeId = ""
    @State private var selectedPermission: CabinPermission = .read
    @State private var isInviting = false
    @State private var errorMessage: String?
    @State private var invitationCode: String?

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // 用户ID
                        VStack(alignment: .leading, spacing: 8) {
                            Text("用户ID")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextField("输入用户ID", text: $inviteeId)
                                .textFieldStyle(.roundedBorder)
                        }

                        // 权限选择
                        VStack(alignment: .leading, spacing: 8) {
                            Text("权限")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Picker("权限", selection: $selectedPermission) {
                                Text("只读").tag(CabinPermission.read)
                                Text("编辑").tag(CabinPermission.write)
                                Text("管理员").tag(CabinPermission.admin)
                            }
                            .pickerStyle(.segmented)
                        }

                        // 邀请码显示
                        if let code = invitationCode {
                            VStack(spacing: 8) {
                                Text("邀请码")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Text(code)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                                    )

                                Text("请将此邀请码发送给用户")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                }

                if isInviting {
                    LoadingView(message: "邀请中...")
                }
            }
            .navigationTitle("邀请成员")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("邀请") {
                        inviteMember()
                    }
                    .disabled(inviteeId.isEmpty || isInviting)
                }
            }
            .errorAlert($errorMessage)
        }
    }

    private func inviteMember() {
        isInviting = true

        Task {
            do {
                let invitation = try await viewModel.inviteMember(inviteeId: inviteeId, permission: selectedPermission)

                await MainActor.run {
                    isInviting = false
                    invitationCode = invitation.inviteCode
                }
            } catch {
                await MainActor.run {
                    isInviting = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    CabinDetailView(cabinId: "cabin123")
}
