import SwiftUI

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // 应用版本信息
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "版本 \(version) (\(build))"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 1.0, green: 0.97, blue: 0.86), // 奶cream色
                        Color(red: 1.0, green: 0.95, blue: 0.9)   // 浅桃色
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // 应用Logo
                        VStack(spacing: 16) {
                            Image(systemName: "heart.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                                .shadow(
                                    color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.4),
                                    radius: 15,
                                    x: 0,
                                    y: 8
                                )
                            
                            Text("ThingZ")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                            
                            Text("你的智能储物助手")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                            
                            Text(appVersion)
                                .font(.subheadline)
                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                                .padding(.top, 4)
                        }
                        .padding(.top, 20)
                        
                        // 应用介绍
                        VStack(alignment: .leading, spacing: 20) {
                            SectionTitle(title: "关于ThingZ")
                            
                            InfoCard {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("ThingZ是一款智能储物管理应用，帮助用户高效管理家庭物品，通过拍照识别、二维码技术，实现物品的快速定位和管理。")
                                        .font(.body)
                                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                        .lineSpacing(6)
                                    
                                    Text("核心功能：")
                                        .font(.headline)
                                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                    
                                    FeatureRow(icon: "camera.fill", color: Color(red: 1.0, green: 0.75, blue: 0.8), text: "一键拍照，智能识别物品")
                                    FeatureRow(icon: "qrcode", color: Color(red: 1.0, green: 0.8, blue: 0.4), text: "二维码标签，快速定位容器")
                                    FeatureRow(icon: "magnifyingglass.circle.fill", color: Color(red: 0.7, green: 0.9, blue: 0.7), text: "强大搜索功能，秒找物品")
                                    FeatureRow(icon: "clock.fill", color: Color(red: 0.7, green: 0.9, blue: 0.9), text: "食品保质期提醒，避免浪费")
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // 开发团队
                        VStack(alignment: .leading, spacing: 20) {
                            SectionTitle(title: "开发团队")
                            
                            InfoCard {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("ThingZ由一群热爱创新的开发者共同打造，致力于用科技解决日常生活中的小问题。")
                                        .font(.body)
                                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                        .lineSpacing(6)
                                    
                                    HStack(spacing: 20) {
                                        TeamMemberView(name: "王冲", role: "产品设计", icon: "person.fill.viewfinder")
                                        TeamMemberView(name: "李明", role: "iOS开发", icon: "hammer.fill")
                                        TeamMemberView(name: "张华", role: "UI设计", icon: "paintbrush.fill")
                                    }
                                    .padding(.top, 8)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // 联系我们
                        VStack(alignment: .leading, spacing: 20) {
                            SectionTitle(title: "联系我们")

                            InfoCard {
                                VStack(alignment: .leading, spacing: 16) {
                                    ContactRow(icon: "envelope.fill", text: "support@thingz.app")
                                    ContactRow(icon: "link", text: "www.thingz.app")
                                    ContactRow(icon: "location.fill", text: "北京市海淀区中关村")
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        // 法律信息
                        VStack(alignment: .leading, spacing: 20) {
                            SectionTitle(title: "法律信息")

                            InfoCard {
                                VStack(spacing: 12) {
                                    Button(action: {
                                        if let url = URL(string: "http://192.168.3.118:9000/v1/static/privacy-policy") {
                                            UIApplication.shared.open(url)
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "hand.raised.fill")
                                                .foregroundColor(Theme.Colors.pinkAccent)
                                            Text("隐私政策")
                                                .foregroundColor(Theme.Colors.primaryText)
                                            Spacer()
                                            Image(systemName: "arrow.up.right.square")
                                                .foregroundColor(Theme.Colors.tertiaryText)
                                        }
                                        .padding(.vertical, 8)
                                    }

                                    Divider()

                                    Button(action: {
                                        if let url = URL(string: "http://192.168.3.118:9000/v1/static/user-agreement") {
                                            UIApplication.shared.open(url)
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "doc.text.fill")
                                                .foregroundColor(Theme.Colors.blueAccent)
                                            Text("用户协议")
                                                .foregroundColor(Theme.Colors.primaryText)
                                            Spacer()
                                            Image(systemName: "arrow.up.right.square")
                                                .foregroundColor(Theme.Colors.tertiaryText)
                                        }
                                        .padding(.vertical, 8)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // 版权信息
                        VStack(spacing: 8) {
                            Text("© 2024 ThingZ Team. All rights reserved.")
                                .font(.caption)
                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                            
                            Text("用❤️制作")
                                .font(.caption)
                                .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("关于应用")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                    }
                }
            }
        }
    }
}

// 功能行
struct FeatureRow: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(color)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
        }
    }
}

// 联系方式行
struct ContactRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
        }
    }
}

// 团队成员视图
struct TeamMemberView: View {
    let name: String
    let role: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
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
                    .shadow(
                        color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            Text(name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
            
            Text(role)
                .font(.caption)
                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
        }
    }
}

// 信息卡片
struct InfoCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(.all, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.8))
                    .shadow(
                        color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                        radius: 10,
                        x: 0,
                        y: 5
                    )
            )
    }
}

// 章节标题
struct SectionTitle: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
    }
}

#Preview {
    AboutView()
}