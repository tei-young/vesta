# API Specification - Vesta iOS

> Firestore 컬렉션 구조 및 서비스 API 명세

---

## Firestore 컬렉션 구조

```
users/
  └── {userId}/
        ├── profile/info                    # 사용자 정보
        ├── treatments/                     # 시술 관리
        ├── dailyRecords/                   # 일별 기록
        ├── dailyAdjustments/               # 일별 조정
        ├── expenseCategories/              # 지출 카테고리
        └── monthlyExpenses/                # 월별 지출
```

---

## 1. TreatmentService

### fetchTreatments
```swift
func fetchTreatments(userId: String) async throws -> [Treatment]
```
- **쿼리**: `order` ASC 정렬
- **반환**: 정렬된 시술 목록

### addTreatment
```swift
func addTreatment(_ treatment: Treatment, userId: String) async throws
```
- **필수**: name, price, color, order
- **선택**: icon

### updateTreatment
```swift
func updateTreatment(_ treatment: Treatment, userId: String) async throws
```
- **Merge**: true (부분 업데이트)

### deleteTreatment
```swift
func deleteTreatment(id: String, userId: String) async throws
```
- **CASCADE**: 관련 dailyRecords도 삭제 필요 (클라이언트에서 처리)

### reorderTreatments
```swift
func reorderTreatments(_ treatments: [Treatment], userId: String) async throws
```
- **Batch Write**: 모든 order 값 한번에 업데이트

---

## 2. RecordService

### fetchRecords (특정 날짜)
```swift
func fetchRecords(userId: String, date: Date) async throws -> [DailyRecord]
```
- **쿼리**: `date >= startOfDay AND date < endOfDay`
- **조인**: Treatment 데이터 병합 (클라이언트)

### fetchMonthlyRecords
```swift
func fetchMonthlyRecords(userId: String, year: Int, month: Int) async throws -> [DailyRecord]
```
- **쿼리**: `date >= 2026-01-01 AND date < 2026-02-01`
- **용도**: 캘린더 월별 도트 표시, 월 총 매출 계산

### addOrUpdateRecord (Upsert)
```swift
func addOrUpdateRecord(userId: String, date: Date, treatmentId: String, price: Int) async throws
```
- **로직**:
  1. 같은 날짜 + treatmentId 검색
  2. 있으면: count+1, totalAmount += price
  3. 없으면: 새 문서 생성 (count=1)

### updateRecordCount
```swift
func updateRecordCount(id: String, count: Int, totalAmount: Int) async throws
```
- **직접 수정**: count, totalAmount 업데이트

### deleteRecord
```swift
func deleteRecord(id: String, userId: String) async throws
```

---

## 3. AdjustmentService

### fetchAdjustments
```swift
func fetchAdjustments(userId: String, date: Date) async throws -> [DailyAdjustment]
```
- **쿼리**: 특정 날짜의 모든 조정

### addAdjustment
```swift
func addAdjustment(_ adjustment: DailyAdjustment, userId: String) async throws
```

### updateAdjustment
```swift
func updateAdjustment(_ adjustment: DailyAdjustment, userId: String) async throws
```

### deleteAdjustment
```swift
func deleteAdjustment(id: String, userId: String) async throws
```

---

## 4. CategoryService

### fetchCategories
```swift
func fetchCategories(userId: String) async throws -> [ExpenseCategory]
```
- **쿼리**: `order` ASC 정렬

### addCategory
```swift
func addCategory(_ category: ExpenseCategory, userId: String) async throws
```

### updateCategory
```swift
func updateCategory(_ category: ExpenseCategory, userId: String) async throws
```

### deleteCategory
```swift
func deleteCategory(id: String, userId: String) async throws
```

### reorderCategories
```swift
func reorderCategories(_ categories: [ExpenseCategory], userId: String) async throws
```
- **Batch Write** 사용

---

## 5. ExpenseService

### fetchExpenses
```swift
func fetchExpenses(userId: String, yearMonth: String) async throws -> [MonthlyExpense]
```
- **쿼리**: `year_month == "2026-01"`
- **조인**: ExpenseCategory 데이터 병합

### upsertExpense (Upsert)
```swift
func upsertExpense(userId: String, yearMonth: String, categoryId: String, amount: Int) async throws
```
- **로직**:
  1. yearMonth + categoryId 검색
  2. 있으면: amount 업데이트
  3. 없으면: 새 문서 생성

### copyFromPreviousMonth
```swift
func copyFromPreviousMonth(userId: String, from: String, to: String) async throws
```
- **로직**:
  1. from 월의 모든 지출 조회
  2. to 월로 복사 (병렬 처리)
  3. 기존 카테고리만 복사 (삭제된 카테고리 제외)

---

## Firestore 쿼리 예시

### 월별 매출 계산
```swift
let records = try await fetchMonthlyRecords(userId: userId, year: 2026, month: 1)
let revenue = records.reduce(0) { $0 + $1.totalAmount }
```

### 일별 총 매출 (시술 + 조정)
```swift
let records = try await fetchRecords(userId: userId, date: date)
let adjustments = try await fetchAdjustments(userId: userId, date: date)

let treatmentTotal = records.reduce(0) { $0 + $1.totalAmount }
let adjustmentTotal = adjustments.reduce(0) { $0 + $1.amount }
let dailyTotal = treatmentTotal + adjustmentTotal
```

### 순이익 계산
```swift
let records = try await fetchMonthlyRecords(userId: userId, year: 2026, month: 1)
let expenses = try await fetchExpenses(userId: userId, yearMonth: "2026-01")

let revenue = records.reduce(0) { $0 + $1.totalAmount }
let totalExpense = expenses.reduce(0) { $0 + $1.amount }
let profit = revenue - totalExpense
```

---

## 에러 처리

모든 Service 메서드는 `throws`로 에러 전파:

```swift
do {
    let treatments = try await service.fetchTreatments(userId: userId)
} catch let error as NSError {
    if error.domain == FirestoreErrorDomain {
        switch FirestoreErrorCode(rawValue: error.code) {
        case .unavailable:
            // 네트워크 오류
        case .permissionDenied:
            // 권한 오류
        default:
            // 기타 오류
        }
    }
}
```

---

## 인덱스 필요

Firebase Console에서 생성 필요:

| 컬렉션 | 필드 | 정렬 | 용도 |
|--------|------|------|------|
| dailyRecords | date, created_at | ASC, DESC | 날짜별 조회 |
| dailyRecords | date, treatment_id | ASC, ASC | 중복 체크 |
| monthlyExpenses | year_month, category_id | ASC, ASC | 월별 지출 |
| treatments | order | ASC | 정렬 |
| expenseCategories | order | ASC | 정렬 |

---

**업데이트:** 2026-01-20
