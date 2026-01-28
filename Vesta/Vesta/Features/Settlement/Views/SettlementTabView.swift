//
//  SettlementTabView.swift
//  Vesta
//
//  Created on 2026-01-19.
//  Updated on 2026-01-25.
//

import SwiftUI

struct SettlementTabView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        SettlementTabContent(authService: authService)
    }
}

private struct SettlementTabContent: View {
    // MARK: - Properties

    @StateObject private var viewModel: SettlementViewModel

    // Sheet States
    @State private var showingCategoryEdit = false
    @State private var showingExpenseInput = false
    @State private var showingCopyConfirmation = false
    @State private var editingCategory: ExpenseCategory?
    @State private var selectedCategory: ExpenseCategory?

    // MARK: - Initialization

    init(authService: AuthService) {
        _viewModel = StateObject(wrappedValue: SettlementViewModel(authService: authService))
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // 월 헤더 (네비게이션)
                    monthHeader

                    // 매출 카드
                    RevenueCard(
                        totalRevenue: viewModel.totalRevenue,
                        revenueByTreatment: viewModel.revenueByTreatment
                    )
                    .padding(.horizontal)

                    // 지출 섹션
                    ExpenseSection(
                        categories: viewModel.categories,
                        getExpenseAmount: { categoryId in
                            viewModel.getExpenseAmount(for: categoryId)
                        },
                        totalExpense: viewModel.totalExpense,
                        onAddCategory: {
                            editingCategory = nil
                            showingCategoryEdit = true
                        },
                        onCopyFromPrevious: {
                            showingCopyConfirmation = true
                        },
                        onEditCategory: { category in
                            editingCategory = category
                            showingCategoryEdit = true
                        },
                        onDeleteCategory: { category in
                            Task {
                                await deleteCategory(category)
                            }
                        },
                        onEditExpense: { category in
                            selectedCategory = category
                            showingExpenseInput = true
                        }
                    )
                    .padding(.horizontal)

                    // 순이익 카드
                    ProfitCard(
                        totalRevenue: viewModel.totalRevenue,
                        totalExpense: viewModel.totalExpense,
                        netProfit: viewModel.netProfit
                    )
                    .padding(.horizontal)

                    Spacer(minLength: 16)
                }
                .padding(.vertical)
            }
            .background(AppColors.background)
            .navigationTitle("결산")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingCategoryEdit) {
                CategoryEditSheet(
                    editingCategory: editingCategory,
                    onSave: { name, icon in
                        await saveCategory(name: name, icon: icon)
                    }
                )
            }
            .sheet(isPresented: $showingExpenseInput) {
                if let category = selectedCategory {
                    ExpenseInputSheet(
                        category: category,
                        currentAmount: viewModel.getExpenseAmount(for: category.id ?? ""),
                        onSave: { amount in
                            await saveExpense(categoryId: category.id ?? "", amount: amount)
                        }
                    )
                }
            }
            .alert("이전 달 불러오기", isPresented: $showingCopyConfirmation) {
                Button("취소", role: .cancel) {}
                Button("불러오기") {
                    Task {
                        await viewModel.copyExpensesFromPreviousMonth()
                    }
                }
            } message: {
                Text("전월 지출 데이터를 현재 월로 복사합니다.\n이미 존재하는 카테고리는 건너뜁니다.")
            }
            .task {
                await viewModel.fetchMonthlyData()
            }
            .onChange(of: viewModel.currentDate) { _, _ in
                Task {
                    await viewModel.fetchMonthlyData()
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                }
            }
        }
    }

    // MARK: - Month Header

    private var monthHeader: some View {
        HStack {
            Button(action: {
                viewModel.navigateToPreviousMonth()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(AppColors.primary)
            }

            Spacer()

            Text(viewModel.monthDisplayString)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            Button(action: {
                viewModel.navigateToNextMonth()
            }) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(AppColors.primary)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Actions

    private func saveCategory(name: String, icon: String) async {
        if let editing = editingCategory {
            // 수정
            await viewModel.updateCategory(editing, name: name, icon: icon)
        } else {
            // 추가
            await viewModel.addCategory(name: name, icon: icon)
        }
    }

    private func deleteCategory(_ category: ExpenseCategory) async {
        await viewModel.deleteCategory(category)
    }

    private func saveExpense(categoryId: String, amount: Int) async {
        await viewModel.updateExpense(categoryId: categoryId, amount: amount)
    }
}

// MARK: - Preview

#Preview {
    SettlementTabView()
        .environmentObject(AuthService())
}
