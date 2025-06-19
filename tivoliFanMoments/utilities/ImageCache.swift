import UIKit
import SwiftUI

final class ImageCache {
    static let shared = NSCache<NSURL, UIImage>()
}

final class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    private var url: URL?
    private var task: URLSessionDataTask?

    init(url: URL?) {
        self.url = url
    }

    func load() {
        guard let url = url else { return }

        if let cached = ImageCache.shared.object(forKey: url as NSURL) {
            self.image = cached
            return
        }

        task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let img = UIImage(data: data) else { return }
            ImageCache.shared.setObject(img, forKey: url as NSURL)
            DispatchQueue.main.async {
                self.image = img
            }
        }
        task?.resume()
    }

    func cancel() {
        task?.cancel()
    }
}

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    @StateObject private var loader: ImageLoader

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
    }

    var body: some View {
        Group {
            if let uiImage = loader.image {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
            }
        }
        .onAppear { loader.load() }
        .onDisappear { loader.cancel() }
    }
}

