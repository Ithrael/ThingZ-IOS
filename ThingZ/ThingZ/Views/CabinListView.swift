import SwiftUI

struct CabinListView: View {
    @StateObject private var viewModel = CabinViewModel()
    @State private var showingCreateCabin = false
    @State private var toast: Toast?

    var body: some View {
        NavigationView {
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
                } else if viewModel.cabins.isEmpty {
                    EmptyStateView(
                        icon: "house.fill",
                        title: "还没有小屋",
                        message: "创建一个小屋，与家人朋友共享物品管理",
                        actionTitle: "创建小屋",
                        action: { showingCreateCabin = true }
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // 待处理邀请
                            if !viewModel.pendingInvitations.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("待处理邀请 (\(viewModel.pendingInvitations.count))")
                                        .font(.headline)
                                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                        .padding(.horizontal)

                                    ForEach(viewModel.pendingInvitations, id: \.id) { invitation in
                                        InvitationCard(invitation: invitation, viewModel: viewModel)
                                    }
                                }
                                .padding(.top)
                            }

                            // 小屋列表
                            ForEach(viewModel.cabins, id: \.id) { cabin in
                                NavigationLink(destination: CabinDetailView(cabinId: cabin.id)) {
                                    CabinCard(cabin: cabin)
                                }
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle("小屋")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateCabin = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                    }
                }
            }
            .sheet(isPresented: $showingCreateCabin) {
                CreateCabinView(viewModel: viewModel)
            }
            .task {
                await viewModel.loadCabins()
                await viewModel.loadPendingInvitations()
            }
            .errorAlert($viewModel.errorMessage)
            .toast($toast)
        }
    }
}

// MARK: - 小屋卡片
struct CabinCard: View {
    let cabin: APICabin

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // 图标
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
                        .frame(width: 50, height: 50)

                    Image(systemName: "house.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(cabin.name)
                        .font(.headline)
                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))

                    if let description = cabin.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                            .lineLimit(1)
                    }

                    Text("由 \(cabin.ownerNick ?? "未知") 创建")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // 成员数量
                VStack {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                        .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                    Text("\(cabin.currentMembers)/\(cabin.maxMembers)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
                .shadow(color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - 邀请卡片
struct InvitationCard: View {
    let invitation: APICabinInvitation
    @ObservedObject var viewModel: CabinViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                Text("\(invitation.inviterNick ?? "某人") 邀请你加入 \(invitation.cabinName)")
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
            }

            HStack(spacing: 12) {
                Button("接受") {
                    Task {
                        do {
                            try await viewModel.joinCabin(cabinId: invitation.cabinId, inviteCode: invitation.inviteCode)
                        } catch {
                            viewModel.errorMessage = error.localizedDescription
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 1.0, green: 0.75, blue: 0.8))

                Button("拒绝") {
                    // TODO: 实现拒绝邀请API
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 1.0, green: 0.9, blue: 0.85).opacity(0.5))
        )
        .padding(.horizontal)
    }
}

// MARK: - 创建小屋视图
struct CreateCabinView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: CabinViewModel

    @State private var name = ""
    @State private var description = ""
    @State private var maxMembers = 10
    @State private var isCreating = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // 名称
                        VStack(alignment: .leading, spacing: 8) {
                            Text("小屋名称")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextField("例如：我的家", text: $name)
                                .textFieldStyle(.roundedBorder)
                        }

                        // 描述
                        VStack(alignment: .leading, spacing: 8) {
                            Text("描述")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextEditor(text: $description)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(8)
                        }

                        // 最大成员数
                        VStack(alignment: .leading, spacing: 8) {
                            Text("最大成员数")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Stepper("\(maxMembers) 人", value: $maxMembers, in: 2...20)
                        }
                    }
                    .padding()
                }

                if isCreating {
                    LoadingView(message: "创建中...")
                }
            }
            .navigationTitle("创建小屋")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("创建") {
                        createCabin()
                    }
                    .disabled(name.isEmpty || isCreating)
                }
            }
            .errorAlert($errorMessage)
        }
    }

    private func createCabin() {
        isCreating = true

        Task {
            do {
                _ = try await viewModel.createCabin(
                    name: name,
                    description: description.isEmpty ? nil : description,
                    maxMembers: maxMembers
                )

                await MainActor.run {
                    isCreating = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isCreating = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    CabinListView()
}
