# MVVM Migration TODO (Page by Page)

Bu liste mevcut akisi bozmadan migration yapilmasi icin hazirlandi.

## Page Envanteri (Ana Ekranlar)

- [ ] `LaunchFlowView` (onboarding/login mock akisi)
- [ ] `HomeView` (anasayfa + food service toggle)
- [ ] `SearchView` (arama ve sonuc listesi)
- [ ] `OrdersView` (aktif/gecmis siparisler)
- [ ] `ProfileView` (hesap menusu)
- [ ] `FavoritesView` (favoriler)
- [ ] `CartFlowView` / `CartView` / `CheckoutView` / `OrderTrackingView` (sepet-checkout-takip)
- [ ] `RestaurantDetailView` + `ProductDetailSheet` (menu ve urun detayi)
- [ ] `AddressSelectionView` / `AddressListView`
- [ ] `PaymentMethodsView`
- [ ] `SupportView`
- [ ] `CampaignsView`
- [ ] `MarketListView`
- [ ] `NotificationsView`

## Ortak Bilesenler (Design System'a tasinacaklar)

- [ ] `ReferenceTabBar`, `ReferenceTabBarItem`
- [ ] `ReferenceHeader`, `OrdersSegmentButton`
- [ ] `PrimaryActionButton`, `SummaryRow`, `CounterButton`, `TagPill`
- [ ] `EmptyStateView`, `FlexibleChips`, `FlexibleSelectableChips`
- [ ] Home kartlari ve artwork bilesenleri

## Fazlara Bolunmus Uygulama

### Part 1 - Navigation/Tab ayrisma (UI ayni kalir)

- [x] `TabRouterViewModel` eklendi (`selectedTab` tek sorumluluk)
- [x] `ContentView` icinde router enjekte edildi
- [x] `TrendyolGoPrototypeView` tab switch'i router'dan okur hale getirildi
- [x] `ReferenceTabBar` tab secimi router uzerinden yonetilir hale getirildi
- [x] `ContentViewModel` tab degisimi callback ile router'a delege edildi

### Part 2 - Home + Search feature ayrimi

- [x] `HomeViewModel` olustur (home'a ait state ve intentler)
- [x] `SearchViewModel` olustur (arama state/filtre)
- [x] Home/Search ekranlarini ayri dosyalara tasi
- [x] `ContentViewModel` icinden home/search state'ini temizle

### Part 3 - Orders + Favorites + Profile feature ayrimi

- [x] `OrdersViewModel`
- [x] `FavoritesViewModel`
- [x] `ProfileViewModel`
- [x] Ekranlari ayri dosyalara tasi
- [x] View -> ViewModel intentlerini netlestir

### Part 4 - Cart/Checkout/Tracking flow ayrimi

- [x] `CartViewModel` + `CheckoutViewModel` + `OrderTrackingViewModel`
- [x] `CartFlowView` ve alt ekranlarini parcali dosyalara tasi
- [x] Sepet hesap kurallari ViewModel'e sabitlenir

### Part 5 - Data katmani (API hazir)

- [x] `Repository` protokolleri
- [x] `MockRepository` implementasyonlari
- [x] ViewModel'ler `MockData` yerine repository kullanir
- [x] Composition root (dependency wiring) netlestirilir

### Part 6 - Son temizlik

- [x] `TrendyolGoPrototypeView.swift` boyutu sifira indirilir
- [x] Her feature icin `View` + `ViewModel` dosya ciftleri tamamlanir
- [x] Regression testi (tab, arama, sepet, siparis, profil)
