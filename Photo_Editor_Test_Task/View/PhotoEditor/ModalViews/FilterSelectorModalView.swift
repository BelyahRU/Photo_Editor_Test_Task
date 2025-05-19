
import SwiftUI
import CoreImage.CIFilterBuiltins

//MARK: - CoreImage filters
struct FilterSelectorModalView: View {
    let filters: [(name: String, filter: CIFilter)]
    var onSelectFilter: (_ filter: CIFilter) -> Void
    var onClose: () -> Void

    @State private var showContent = false

    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()
                .onTapGesture {
                    hideWithAnimation()
                }

            VStack(spacing: 20) {
                Text("Choose a filter")
                    .font(.title3)
                    .bold()
                    .padding(.top)

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(filters, id: \.name) { item in
                            Button {
                                onSelectFilter(item.filter)
                                hideWithAnimation()
                            } label: {
                                Text(item.name)
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(UIColor.systemGray6))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.top)
                }

                Button("Cancel") {
                    hideWithAnimation()
                }
                .foregroundColor(.red)
                .padding(.top, 10)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 10)
            .padding(.horizontal)
            .frame(maxWidth: 300, maxHeight: 300)
            .offset(y: showContent ? 0 : UIScreen.main.bounds.height / 2)
            .opacity(showContent ? 1 : 0)
            .animation(.easeOut(duration: 0.35), value: showContent)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    withAnimation {
                        showContent = true
                    }
                }
            }
        }
    }

    private func hideWithAnimation() {
        withAnimation(.easeIn(duration: 0.3)) {
            showContent = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onClose()
        }
    }
}
