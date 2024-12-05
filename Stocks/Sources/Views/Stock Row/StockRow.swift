import SwiftUI

protocol StockRowViewModel {
  var ticker: String { get }
  var name: String { get }
  var currentPrice: String { get }
}

struct StockRow<ViewModel: StockRowViewModel>: View {
  let viewModel: ViewModel
  
  var body: some View {
    VStack(spacing: 8) {
      HStack(alignment: .top, spacing: 16) {
        VStack(alignment: .leading, spacing: 8) {
          Text(viewModel.ticker.prefix(3))
          Text(viewModel.name)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
        Text(viewModel.currentPrice)
      }
      
      Divider()
    }
    .padding(.horizontal)
  }
}

#if DEBUG
private struct MockViewModel: StockRowViewModel {
  let name = "Vanguard FTSE Can All Cap"
  let ticker = "VCN"
  let currentPrice = "$52.52"
}

#Preview {
  StockRow(viewModel: MockViewModel())
}
#endif
