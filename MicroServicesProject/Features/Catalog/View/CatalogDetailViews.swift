import SwiftUI

struct SimpleAccountView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            Circle()
                .fill(AppTheme.orangeSoft)
                .frame(width: 92, height: 92)
                .overlay(
                    Image(systemName: "person.text.rectangle")
                        .font(.system(size: 34, weight: .medium))
                        .foregroundStyle(AppTheme.orange)
                )
            Text(title)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(AppTheme.referenceTitle)
            Text(subtitle)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(AppTheme.referenceMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.referenceBackground.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RestaurantDetailView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    let vendor: Vendor
    @State private var selectedProduct: Product?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                VendorHero(vendor: vendor)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Label(vendor.eta, systemImage: "clock.fill")
                        Spacer()
                        Label("\(vendor.rating, specifier: "%.1f")", systemImage: "star.fill")
                    }
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.subtleText)

                    Text(vendor.promoText)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.ink)

                    HStack(spacing: 8) {
                        ForEach(vendor.tags, id: \.self) { tag in
                            TagPill(text: tag, tint: vendor.theme.softTint)
                        }
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white)
                )

                ForEach(vendor.menuSections) { section in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(section.title)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)

                        ForEach(section.products) { product in
                            ProductRow(
                                vendor: vendor,
                                product: product,
                                onSelect: { selectedProduct = product },
                                onQuickAdd: {
                                    viewModel.addToCart(product: product, from: vendor)
                                }
                            )
                        }
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 32)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle(vendor.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.toggleFavorite(for: vendor)
                } label: {
                    Image(systemName: currentVendorState.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(AppTheme.orange)
                }
            }
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailSheet(vendor: vendor, product: product)
                .presentationDetents([.fraction(0.92)])
                .environmentObject(viewModel)
        }
    }

    private var currentVendorState: Vendor {
        viewModel.allVendors.first(where: { $0.id == vendor.id }) ?? vendor
    }
}

struct ProductDetailSheet: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @Environment(\.dismiss) private var dismiss

    let vendor: Vendor
    let product: Product

    @State private var quantity: Int
    @State private var note: String
    @State private var selections: [UUID: String]

    init(vendor: Vendor, product: Product) {
        self.vendor = vendor
        self.product = product
        _quantity = State(initialValue: 1)
        _note = State(initialValue: "")
        _selections = State(
            initialValue: Dictionary(
                uniqueKeysWithValues: product.optionGroups.compactMap { group in
                    guard let first = group.options.first else { return nil }
                    return (group.id, first)
                }
            )
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(product.theme.gradient)
                        .frame(height: 220)
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: product.systemImage)
                                    .font(.system(size: 54, weight: .bold))
                                    .foregroundStyle(.white)
                                Text(product.name)
                                    .font(.system(size: 26, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                            }
                        )

                    VStack(alignment: .leading, spacing: 8) {
                        Text(product.description)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.subtleText)

                        if let badge = product.badge {
                            TagPill(text: badge, tint: product.theme.softTint)
                        }
                    }

                    ForEach(product.optionGroups) { group in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(group.title)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.ink)

                            FlexibleSelectableChips(
                                items: group.options,
                                selection: Binding(
                                    get: { selections[group.id] ?? group.options.first ?? "" },
                                    set: { selections[group.id] = $0 }
                                ),
                                tint: product.theme.softTint
                            )
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Sipariş notu")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)

                        TextField("Örn. Soğansız olsun", text: $note, axis: .vertical)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color.white)
                            )
                    }

                    HStack(spacing: 12) {
                        CounterButton(symbol: "minus") {
                            quantity = max(1, quantity - 1)
                        }

                        Text("\(quantity)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .frame(minWidth: 36)

                        CounterButton(symbol: "plus") {
                            quantity += 1
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, 90)
            }
            .background(AppTheme.canvas.ignoresSafeArea())
            .navigationTitle(product.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.orange)
                }
            }
            .safeAreaInset(edge: .bottom) {
                PrimaryActionButton(
                    title: "\(quantity) adet ekle",
                    subtitle: (product.price * Double(quantity)).formatted(.currency(code: "TRY"))
                ) {
                    let selected = product.optionGroups.compactMap { group in
                        selections[group.id]
                    }
                    viewModel.addToCart(
                        product: product,
                        from: vendor,
                        selectedOptions: selected,
                        note: note,
                        quantity: quantity
                    )
                    dismiss()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
            }
        }
    }
}
