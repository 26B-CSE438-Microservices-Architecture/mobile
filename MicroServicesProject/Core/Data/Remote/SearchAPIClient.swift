import Foundation

struct SearchAPIClient {
    private let baseURL = URL(string: "https://gw.cse.akdeniz.edu.tr/cse-438")!
    private let decoder = JSONDecoder()

    func search(query: String, latitude: Double, longitude: Double) async throws -> SearchResponse {
        let url = searchURL(query: query, latitude: latitude, longitude: longitude)

        return try await fetch(url: url)
    }

    private func searchURL(query: String, latitude: Double, longitude: Double) -> URL {
        let url = baseURL.appendingPathComponent("api/v1/search")
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return url
        }

        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lng", value: String(longitude))
        ]

        return components.url ?? url
    }

    private func fetch<Response: Decodable>(url: URL) async throws -> Response {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppAuthError(message: "Arama servisinden geçerli cevap alınamadı.")
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            let raw = String(data: data, encoding: .utf8) ?? "Arama servisi hatası."
            throw AppAuthError(message: raw)
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw AppAuthError(message: "Arama response formatı çözümlenemedi.")
        }
    }
}

struct SearchResponse: Decodable {
    let total_count: Int
    let vendors: [SearchVendorResponse]
    let products: [SearchProductResponse]
}

struct SearchVendorResponse: Decodable, Identifiable {
    let id: String
    let name: String
    let rating: Double?
    let is_sponsored: Bool?
    let image_url: String?
    let eta: String?
}

struct SearchProductResponse: Decodable, Identifiable {
    let id: String
    let name: String
    let price_label: String?
    let vendor_name: String?
}

extension SearchVendorResponse {
    var appVendor: Vendor {
        let resolvedTheme: VendorTheme = name.lowercased().contains("pizza") ? .red : .orange
        let sponsoredText = (is_sponsored ?? false) ? "Sponsorlu" : "Canlı arama sonucu"

        return Vendor(
            backendID: id,
            name: name,
            summary: sponsoredText,
            kind: .restaurant,
            eta: eta ?? "20-30 dk",
            rating: rating ?? 0,
            reviewCount: 0,
            minimumBasket: 0,
            deliveryFee: 0,
            coverNote: "Detay sayfası canlı vendor endpointinden yüklenecek",
            promoText: sponsoredText,
            tags: [eta ?? "20-30 dk"],
            theme: resolvedTheme,
            isFavorite: false,
            menuSections: []
        )
    }
}
