import Foundation

struct VendorsAPIClient {
    private let baseURL = URL(string: "https://gw.cse.akdeniz.edu.tr/cse-438")!
    private let decoder = JSONDecoder()

    func fetchVendors(page: Int = 1, limit: Int = 20) async throws -> [Vendor] {
        let url = baseURL
            .appendingPathComponent("api/v1/vendors")
            .appending(queryItems: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ])

        let response: VendorsListResponse = try await fetch(url: url)
        return response.data.map { $0.appVendor(menuSections: []) }
    }

    func fetchVendorDetail(vendorID: String) async throws -> Vendor {
        let url = baseURL.appendingPathComponent("api/v1/vendors/\(vendorID)")
        let response: VendorDetailResponse = try await fetch(url: url)
        return response.appVendor
    }

    private func fetch<Response: Decodable>(url: URL) async throws -> Response {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppAuthError(message: "Vendor servisinden geçerli cevap alınamadı.")
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            let raw = String(data: data, encoding: .utf8) ?? "Vendor servisi hatası."
            throw AppAuthError(message: raw)
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw AppAuthError(message: "Vendor response formatı çözümlenemedi.")
        }
    }
}

private struct VendorsListResponse: Decodable {
    let page: Int
    let limit: Int
    let total: Int
    let data: [VendorSummaryResponse]
}

private struct VendorSummaryResponse: Decodable {
    struct WorkingHours: Decodable {
        let open: String?
        let close: String?
        let is_open: Bool?
    }

    struct DeliveryInfo: Decodable {
        let eta_range: String?
        let minimum_basket_amount: Double?
        let delivery_fee: Double?
    }

    let id: String
    let name: String
    let kind: String?
    let rating: Double?
    let review_count: Int?
    let distance_km: Double?
    let campaign_badges: [String]?
    let working_hours: WorkingHours?
    let delivery_info: DeliveryInfo?
}

private struct VendorDetailResponse: Decodable {
    struct MenuSectionResponse: Decodable {
        struct ProductResponse: Decodable {
            struct OptionGroupResponse: Decodable {
                struct OptionResponse: Decodable {
                    let name: String?
                    let price: Double?
                }

                let id: String?
                let title: String?
                let is_required: Bool?
                let max_selections: Int?
                let options: [OptionResponse]?
            }

            let id: String
            let name: String
            let description: String?
            let price: Double?
            let badge: String?
            let image_url: String?
            let is_available: Bool?
            let allergens: [String]?
            let calories: Int?
            let option_groups: [OptionGroupResponse]?
        }

        let id: String
        let title: String
        let products: [ProductResponse]
    }

    let description: String?
    let address_text: String?
    let latitude: Double?
    let longitude: Double?
    let logo_url: String?
    let status: String?
    let menu_sections: [MenuSectionResponse]?

    let id: String
    let name: String
    let kind: String?
    let rating: Double?
    let review_count: Int?
    let distance_km: Double?
    let campaign_badges: [String]?
    let working_hours: VendorSummaryResponse.WorkingHours?
    let delivery_info: VendorSummaryResponse.DeliveryInfo?
}

private extension VendorSummaryResponse {
    func appVendor(menuSections: [MenuSection]) -> Vendor {
        let theme: VendorTheme = name.lowercased().contains("pizza") ? .red : .orange
        let openCloseText = [working_hours?.open, working_hours?.close]
            .compactMap { $0 }
            .joined(separator: " - ")

        return Vendor(
            backendID: id,
            name: name,
            summary: campaign_badges?.first ?? "Canlı restoran verisi",
            kind: kind == "RESTAURANT" ? .restaurant : .market,
            eta: delivery_info?.eta_range ?? "20-30 dk",
            rating: rating ?? 0,
            reviewCount: review_count ?? 0,
            minimumBasket: delivery_info?.minimum_basket_amount ?? 0,
            deliveryFee: delivery_info?.delivery_fee ?? 0,
            coverNote: openCloseText.isEmpty ? "Teslimat bilgisi canlı servisten geliyor" : openCloseText,
            promoText: campaign_badges?.joined(separator: " • ") ?? "Aktif kampanya bilgisi yok",
            tags: (campaign_badges ?? []) + [String(format: "%.1f km", distance_km ?? 0)],
            theme: theme,
            isFavorite: false,
            menuSections: menuSections
        )
    }
}

private extension VendorDetailResponse {
    var appVendor: Vendor {
        let sections = (menu_sections ?? []).map { section in
            MenuSection(
                backendID: section.id,
                title: section.title,
                products: section.products.map { product in
                    Product(
                        backendID: product.id,
                        name: product.name,
                        description: product.description ?? "Açıklama yok",
                        price: product.price ?? 0,
                        badge: product.badge,
                        systemImage: "fork.knife",
                        theme: name.lowercased().contains("pizza") ? .red : .orange,
                        optionGroups: (product.option_groups ?? []).map { group in
                            OptionGroup(
                                title: group.title ?? "Seçenek",
                                required: group.is_required ?? false,
                                options: (group.options ?? []).map { option in
                                    if let price = option.price, price > 0 {
                                        return "\(option.name ?? "Seçenek") +\(price.formatted(.number.precision(.fractionLength(0)))) TL"
                                    }
                                    return option.name ?? "Seçenek"
                                }
                            )
                        }
                    )
                }
            )
        }

        return VendorSummaryResponse(
            id: id,
            name: name,
            kind: kind,
            rating: rating,
            review_count: review_count,
            distance_km: distance_km,
            campaign_badges: campaign_badges,
            working_hours: working_hours,
            delivery_info: delivery_info
        ).appVendor(menuSections: sections)
    }
}

private extension URL {
    func appending(queryItems: [URLQueryItem]) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }
        components.queryItems = queryItems
        return components.url ?? self
    }
}
