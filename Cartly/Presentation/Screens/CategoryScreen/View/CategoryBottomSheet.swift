import Combine
import SwiftUI

struct CategoryBottomSheet: View {
    @Binding var selectedCategory: CategoryFilter
    let onCategorySelected: (CategoryFilter) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray4))
                    .frame(width: 40, height: 6)
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                
                VStack(spacing: 16) {
                    ForEach(CategoryFilter.allCases, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                            onCategorySelected(category)
                            dismiss()
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: categoryIcon(for: category))
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.blue)
                                    .frame(width: 32, height: 32)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(category.rawValue)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                    Text(categoryDescription(for: category))
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if selectedCategory == category {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(selectedCategory == category ? Color.blue.opacity(0.1) : Color.clear)
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 16, weight: .medium))
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    private func categoryIcon(for category: CategoryFilter) -> String {
        switch category {
        case .all: return "square.grid.2x2"
        case .kid: return "figure.child"
        case .men: return "person"
        case .sale: return "tag"
        case .women: return "person.dress"
        }
    }
    
    private func categoryDescription(for category: CategoryFilter) -> String {
        switch category {
        case .all: return "Show all products"
        case .kid: return "Children's products"
        case .men: return "Men's collection"
        case .sale: return "Discounted items"
        case .women: return "Women's collection"
        }
    }
}
