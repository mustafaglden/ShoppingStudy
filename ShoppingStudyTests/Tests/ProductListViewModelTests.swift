//
//  ProductListViewModelTests.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 21.09.2025.
//

import XCTest
import Combine
@testable import ShoppingStudy

@MainActor
final class ProductListViewModelTests: XCTestCase {
    var sut: ProductListViewModel!
    var mockProductService: MockProductService!
    var mockPersistenceManager: MockUserPersistenceManager!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockProductService = MockProductService()
        mockPersistenceManager = MockUserPersistenceManager()
        sut = ProductListViewModel(
            productService: mockProductService,
            persistenceManager: mockPersistenceManager
        )
        cancellables = []
    }
    
    func testLoadProductsSuccess() async {
        // Given
        let expectedProducts = [
            Product(id: 1, title: "Product 1", price: 10.0, description: "Desc",
                   category: "test", image: "img.jpg", rating: Product.Rating(rate: 4.0, count: 10)),
            Product(id: 2, title: "Product 2", price: 20.0, description: "Desc",
                   category: "test", image: "img.jpg", rating: Product.Rating(rate: 3.5, count: 5))
        ]
        mockProductService.mockProducts = expectedProducts
        mockProductService.mockCategories = ["test", "electronics"]
        
        // When
        await sut.loadProducts()
        
        // Then
        XCTAssertTrue(mockProductService.fetchProductsCalled)
        XCTAssertTrue(mockProductService.fetchCategoriesCalled)
        XCTAssertEqual(sut.products.count, 2)
        XCTAssertEqual(sut.filteredProducts.count, 2)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(sut.categories.count, 3) // "all" + 2 categories
    }
    
    func testSearchFilter() async {
        // Given
        let products = [
            Product(id: 1, title: "iPhone", price: 999.0, description: "Phone",
                   category: "electronics", image: "img.jpg", rating: Product.Rating(rate: 4.5, count: 100)),
            Product(id: 2, title: "Samsung", price: 899.0, description: "Phone",
                   category: "electronics", image: "img.jpg", rating: Product.Rating(rate: 4.0, count: 80))
        ]
        mockProductService.mockProducts = products
        await sut.loadProducts()
        
        // When
        sut.searchText = "iPhone"
        
        // Wait for debounce
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // Then
        XCTAssertEqual(sut.filteredProducts.count, 1)
        XCTAssertEqual(sut.filteredProducts.first?.title, "iPhone")
    }
    
    func testSortByPriceAscending() async {
        // Given
        let products = [
            Product(id: 1, title: "Expensive", price: 100.0, description: "",
                   category: "test", image: "", rating: Product.Rating(rate: 4.0, count: 10)),
            Product(id: 2, title: "Cheap", price: 10.0, description: "",
                   category: "test", image: "", rating: Product.Rating(rate: 4.0, count: 10))
        ]
        mockProductService.mockProducts = products
        await sut.loadProducts()
        
        // When
        sut.sortOption = .priceAsc
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // Then
        XCTAssertEqual(sut.filteredProducts.first?.price, 10.0)
        XCTAssertEqual(sut.filteredProducts.last?.price, 100.0)
    }
    
    func testToggleFavorite() {
        // Given
        let user = UserProfile(id: 1, username: "test", email: "test@test.com")
        mockPersistenceManager.users = [user]
        
        let mockAppState = AppState(
            persistenceManager: mockPersistenceManager,
            currencyService: MockCurrencyService()
        )
        
        // When - Add favorite
        sut.toggleFavorite(productId: 1, userId: 1, appState: mockAppState)
        
        // Then
        XCTAssertTrue(sut.isFavorite(productId: 1, userId: 1))
        
        // When - Remove favorite
        sut.toggleFavorite(productId: 1, userId: 1, appState: mockAppState)
        
        // Then
        XCTAssertFalse(sut.isFavorite(productId: 1, userId: 1))
    }
}
