
import SwiftUI

struct ToolbarView: ToolbarContent {
    @Binding var isExportMenuPresented: Bool
    @Binding var isTextEditing: Bool
    @Binding var isFilterSelectorPresented: Bool
    @Binding var isSourceSelectorPresented: Bool
    @Binding var showLogoutAlert: Bool
    @Binding var isDrawing: Bool

    @ToolbarContentBuilder
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {

            Button {
                withAnimation {
                    isTextEditing.toggle()
                }
            } label: {
                Image(systemName: "textformat")
                    .imageScale(.large)
            }

            Button(action: {
                withAnimation {
                    isFilterSelectorPresented = true
                }
            }) {
                Image(systemName: "wand.and.stars")
                    .imageScale(.large)
            }

            Button(action: {
                withAnimation {
                    isSourceSelectorPresented = true
                }
            }) {
                Image(systemName: "photo")
                    .imageScale(.large)
            }
            
            Button(action: {
                withAnimation {
                    isDrawing.toggle()
                }
            }) {
                Image(systemName: isDrawing ? "pencil.circle.fill" : "pencil")
                    .imageScale(.large)
            }
        }

        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button(action: {
                showLogoutAlert = true
            }) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .imageScale(.large)
                    .foregroundStyle(.red)
            }
            Button(action: {
                withAnimation {
                    isExportMenuPresented = true
                }
            }) {
                Image(systemName: "square.and.arrow.up")
                    .imageScale(.large)
                    .padding(.bottom, 3)
                    .foregroundStyle(.green)
            }
        }
    }
}
