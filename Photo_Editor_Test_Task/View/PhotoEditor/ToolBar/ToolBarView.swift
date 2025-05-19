
import SwiftUI

//MARK: - Structure which controlls toolBar in header of screen
struct ToolbarView: ToolbarContent {
    
    let isImageLoaded: Bool // disable Text, Export, Filters, Draw if image didn't loaded
    @Binding var isExportMenuPresented: Bool
    @Binding var isTextEditing: Bool
    @Binding var isFilterSelectorPresented: Bool
    @Binding var isSourceSelectorPresented: Bool
    @Binding var showLogoutAlert: Bool
    @Binding var isDrawing: Bool
    
    @ToolbarContentBuilder
    var body: some ToolbarContent {
        
        // MARK: - Trailing buttons
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            // Only enabled when image is loaded
            Button {
                if isImageLoaded {
                    withAnimation { isTextEditing.toggle() }
                }
            } label: {
                Image(systemName: "textformat")
                    .imageScale(.large)
            }
            .disabled(!isImageLoaded)

            Button {
                if isImageLoaded {
                    withAnimation { isFilterSelectorPresented = true }
                }
            } label: {
                Image(systemName: "wand.and.stars")
                    .imageScale(.large)
            }
            .disabled(!isImageLoaded)

            Button {
                if isImageLoaded {
                    withAnimation { isDrawing.toggle() }
                }
            } label: {
                Image(systemName: isDrawing ? "pencil.circle.fill" : "pencil")
                    .imageScale(.large)
            }
            .disabled(!isImageLoaded)
        }

        // MARK: - Leading buttons
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button {
                showLogoutAlert = true
            } label: {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .imageScale(.large)
                    .foregroundStyle(.red)
            }

            Button {
                if isImageLoaded {
                    withAnimation { isExportMenuPresented = true }
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .imageScale(.large)
                    .padding(.bottom, 3)
                    .foregroundStyle(.green)
            }
            .disabled(!isImageLoaded)

            Button {
                withAnimation {
                    isSourceSelectorPresented = true
                }
            } label: {
                Image(systemName: "photo")
                    .imageScale(.large)
            }
        }
    }

}
