import Combine
import SwiftUI

struct CategoryFilterButton: View {
    let selectedCategory: CategoryFilter
    @Binding var showingSheet: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)

            Button(action: {
                showingSheet = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: categoryIcon(for: selectedCategory))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)
                        .frame(width: 24, height: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedCategory.rawValue)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                        Text("Tap to change")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
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
}

struct CompactCategoryFilterButton: View {
    let selectedCategory: CategoryFilter
    @Binding var showingSheet: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text("Category")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.primary)

            Button(action: {
                showingSheet = true
            }) {
                VStack(spacing: 6) {
                    Image(systemName: categoryIcon(for: selectedCategory))
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.blue)

                    Text(selectedCategory.rawValue)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
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
}
