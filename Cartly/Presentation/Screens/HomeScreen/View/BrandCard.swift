import SwiftUI

struct BrandCard: View {
    let brand: BrandMapper
    let width: CGFloat
    
    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: URL(string: brand.brand_image)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: .infinity)
                        .clipped()
                        
                case .failure:
                    VStack {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                        Text("Image not available")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                    
                @unknown default:
                    EmptyView()
                }
            }
            
            Text(brand.brand_title)
                .font(.system(size: 14, weight: .medium))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: width)
        .padding(8)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

#if false
struct BrandCard: View {
    let brand: BrandMapper
    let width: CGFloat
    
    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: URL(string: brand.brand_image)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: .infinity)
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                @unknown default:
                    EmptyView()
                }
            }
            
            Text(brand.brand_title)
                .font(.system(size: 14))
                .lineLimit(1)
        }
        .frame(width: width)
        .padding(8)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

#endif
