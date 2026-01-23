//
//  SettingsViewModel.swift
//  Vesta
//
//  Created on 2026-01-22.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    // MARK: - Properties

    @Published var treatments: [Treatment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAddSheet = false
    @Published var editingTreatment: Treatment?

    private let treatmentService = TreatmentService.shared
    var authService: AuthService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(authService: AuthService) {
        self.authService = authService
        print("🔍 [SettingsViewModel] init - authService: \(authService), currentUser: \(authService.currentUser?.id ?? "nil")")
        setupBindings()
    }

    // MARK: - Setup

    private func setupBindings() {
        // TreatmentService의 treatments 변경사항 구독
        treatmentService.$treatments
            .assign(to: &$treatments)

        treatmentService.$isLoading
            .assign(to: &$isLoading)

        treatmentService.$errorMessage
            .assign(to: &$errorMessage)
    }

    // MARK: - Fetch

    func fetchTreatments() async {
        guard let userId = authService.currentUser?.id else {
            print("❌ [SettingsViewModel] fetchTreatments - currentUser is nil")
            errorMessage = "사용자 정보를 찾을 수 없습니다."
            return
        }

        print("🔍 [SettingsViewModel] fetchTreatments - userId: \(userId)")
        await treatmentService.fetchTreatments(userId: userId)
    }

    // MARK: - Add Treatment

    func addTreatment(name: String, price: Int, icon: String?, color: String) async {
        guard let userId = authService.currentUser?.id else {
            print("❌ [SettingsViewModel] addTreatment - currentUser is nil")
            errorMessage = "사용자 정보를 찾을 수 없습니다."
            return
        }

        print("🔍 [SettingsViewModel] addTreatment - userId: \(userId), name: \(name)")

        do {
            _ = try await treatmentService.addTreatment(
                name: name,
                price: price,
                icon: icon,
                color: color,
                userId: userId
            )
            showingAddSheet = false
        } catch {
            errorMessage = "시술 추가 실패: \(error.localizedDescription)"
        }
    }

    // MARK: - Update Treatment

    func updateTreatment(_ treatment: Treatment) async {
        guard let userId = authService.currentUser?.id else {
            errorMessage = "사용자 정보를 찾을 수 없습니다."
            return
        }

        do {
            try await treatmentService.updateTreatment(treatment, userId: userId)
            editingTreatment = nil
            showingAddSheet = false
        } catch {
            errorMessage = "시술 수정 실패: \(error.localizedDescription)"
        }
    }

    // MARK: - Delete Treatment

    func deleteTreatment(_ treatment: Treatment) async {
        guard let userId = authService.currentUser?.id,
              let treatmentId = treatment.id else {
            errorMessage = "시술을 삭제할 수 없습니다."
            return
        }

        do {
            try await treatmentService.deleteTreatment(id: treatmentId, userId: userId)
        } catch {
            errorMessage = "시술 삭제 실패: \(error.localizedDescription)"
        }
    }

    // MARK: - Actions

    func showAddSheet() {
        editingTreatment = nil
        showingAddSheet = true
    }

    func showEditSheet(for treatment: Treatment) {
        editingTreatment = treatment
        showingAddSheet = true
    }

    func signOut() {
        do {
            try authService.signOut()
        } catch {
            errorMessage = "로그아웃 실패: \(error.localizedDescription)"
        }
    }
}
