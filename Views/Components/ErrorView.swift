import SwiftUI

struct ErrorView: View {
    let message: String
    let onRetry: (() -> Void)?

    init(message: String, onRetry: (() -> Void)? = nil) {
        self.message = message
        self.onRetry = onRetry
    }

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.red)

            Text("Something went wrong")
                .font(.title2)
                .fontWeight(.bold)

            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if let onRetry = onRetry {
                Button(action: onRetry) {
                    Text("Try Again")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding()
    }
}

#Preview {
    VStack(spacing: 40) {
        ErrorView(
            message: "Unable to connect to the server. Please check your internet connection.",
            onRetry: {}
        )

        ErrorView(
            message: "An unexpected error occurred."
        )
    }
}
