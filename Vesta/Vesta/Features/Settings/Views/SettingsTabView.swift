//
//  SettingsTabView.swift
//  Vesta
//
//  Created on 2026-01-19.
//  Updated on 2026-01-22.
//

import SwiftUI

struct SettingsTabView: View {
    // MARK: - Properties

    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = SettingsViewModel()

    @State private var showingDeleteAlert = false
    @State private var treatmentToDelete: Treatment?

    // MARK: - Body

    var body: some View {
        NavigationView {
            List {
                // 시술 목록 섹션
                Section {
                    // 시술 추가 버튼
                    Button(action: {
                        viewModel.showAddSheet()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(AppColors.primary)
                            Text("시술 추가")
                                .foregroundColor(AppColors.primary)
                            Spacer()
                        }
                    }

                    if viewModel.treatments.isEmpty {
                        Text("등록된 시술이 없습니다")
                            .foregroundColor(AppColors.textSecondary)
                            .font(.subheadline)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(viewModel.treatments) { treatment in
                            TreatmentRow(
                                treatment: treatment,
                                onEdit: {
                                    viewModel.showEditSheet(for: treatment)
                                },
                                onDelete: {
                                    treatmentToDelete = treatment
                                    showingDeleteAlert = true
                                }
                            )
                        }
                    }
                } header: {
                    Text("시술 관리")
                }

                // 앱 정보 섹션
                Section {
                    HStack {
                        Text("앱 버전")
                            .foregroundColor(AppColors.textPrimary)
                        Spacer()
                        Text(AppConstants.appVersion)
                            .foregroundColor(AppColors.textSecondary)
                    }

                    Button(action: {
                        viewModel.signOut()
                    }) {
                        HStack {
                            Text("로그아웃")
                            Spacer()
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                        .foregroundColor(.red)
                    }
                } header: {
                    Text("앱 정보")
                }
            }
            .navigationTitle("설정")
            .sheet(isPresented: $viewModel.showingAddSheet) {
                TreatmentEditSheet(
                    viewModel: viewModel,
                    editingTreatment: viewModel.editingTreatment
                )
            }
            .alert("시술 삭제", isPresented: $showingDeleteAlert) {
                Button("취소", role: .cancel) {
                    treatmentToDelete = nil
                }
                Button("삭제", role: .destructive) {
                    if let treatment = treatmentToDelete {
                        Task {
                            await viewModel.deleteTreatment(treatment)
                        }
                        treatmentToDelete = nil
                    }
                }
            } message: {
                Text("정말로 이 시술을 삭제하시겠습니까?")
            }
            .onAppear {
                viewModel.setAuthService(authService)
            }
            .task {
                await viewModel.fetchTreatments()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsTabView()
        .environmentObject(AuthService())
}
